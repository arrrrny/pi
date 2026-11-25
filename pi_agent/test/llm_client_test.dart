import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:pi/src/types.dart' hide AgentTool;
import 'package:pi/src/tools.dart';
import 'package:pi/src/conversion.dart';
import 'package:pi/src/llm_client.dart';

/// A minimal OpenAI-compatible SSE server for hermetic client tests.
///
/// Records the last request it received and streams back a canned set of
/// `data:` frames, so the client's request building and response parsing can be
/// verified without any real network access.
class _FakeOpenAIServer {
  _FakeOpenAIServer(this.frames);

  final List<String> frames;
  HttpServer? _server;
  Map<String, dynamic>? lastBody;
  String? lastAuth;
  String? lastPath;

  Uri get url => Uri.parse('http://127.0.0.1:${_server!.port}/v1');

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      lastPath = request.uri.path;
      lastAuth = request.headers.value('authorization');
      final raw = await utf8.decoder.bind(request).join();
      lastBody = raw.isEmpty ? null : jsonDecode(raw) as Map<String, dynamic>;
      request.response.statusCode = 200;
      request.response.headers.set('content-type', 'text/event-stream');
      for (final frame in frames) {
        request.response.write('data: $frame\n\n');
      }
      request.response.write('data: [DONE]\n\n');
      await request.response.close();
    });
  }

  Future<void> stop() => _server!.close(force: true);
}

AgentLoopConfig makeConfig(Model model) =>
    AgentLoopConfig(model: model, convertToLlm: convertToLlm);

Model makeModel(String baseUrl) => Model(
      provider: 'openai',
      modelId: 'gpt-test',
      contextWindow: 8000,
      baseUrl: baseUrl,
    );

MessageEnd singleEnd(List<AgentEvent> events) =>
    events.whereType<MessageEnd>().single;

void main() {
  group('streamLLM (OpenAI-compatible)', () {
    late _FakeOpenAIServer server;

    setUp(() async {
      server = _FakeOpenAIServer([]);
      await server.start();
    });

    tearDown(() async {
      await server.stop();
    });

    test('posts to /chat/completions with bearer auth', () async {
      server.frames.addAll([
        jsonEncode({
          'id': 'cmpl-1',
          'choices': [
            {
              'delta': {'content': 'Hello'},
              'finish_reason': null
            },
          ],
        }),
        jsonEncode({
          'id': 'cmpl-1',
          'choices': [
            {'delta': {}, 'finish_reason': 'stop'},
          ],
          'usage': {'prompt_tokens': 5, 'completion_tokens': 2},
        }),
      ]);

      final events = await streamLLM(
        context: AgentContext(
            systemPrompt: 'sys', messages: [UserMessage.text('hi')]),
        config: makeConfig(makeModel(server.url.toString())),
        apiKey: 'secret-key',
        abortSignal: null,
      ).toList();

      expect(server.lastPath, '/v1/chat/completions');
      expect(server.lastAuth, 'Bearer secret-key');

      final body = server.lastBody!;
      expect(body['model'], 'gpt-test');
      expect(body['stream'], true);
      final messages = body['messages'] as List<dynamic>;
      expect(messages.first, {'role': 'system', 'content': 'sys'});
      expect(messages[1]['role'], 'user');
      expect(messages[1]['content'], 'hi');

      expect(events.whereType<MessageUpdate>(), isNotEmpty);
      final msg = singleEnd(events).message as AssistantMessage;
      expect(msg.text, 'Hello');
      expect(msg.stopReason, StopReason.endTurn);
      expect(msg.usage?.inputTokens, 5);
      expect(msg.usage?.outputTokens, 2);
    });

    test('accumulates streamed tool calls', () async {
      server.frames.addAll([
        jsonEncode({
          'id': 'cmpl-2',
          'choices': [
            {
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'id': 'call_a',
                    'function': {'name': 'read_file', 'arguments': '{"p'},
                  },
                ],
              },
              'finish_reason': null,
            },
          ],
        }),
        jsonEncode({
          'id': 'cmpl-2',
          'choices': [
            {
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'function': {
                      'arguments': 'ath":"x"}',
                    },
                  },
                ],
              },
              'finish_reason': 'tool_calls',
            },
          ],
        }),
      ]);

      final events = await streamLLM(
        context:
            AgentContext(systemPrompt: '', messages: [UserMessage.text('go')]),
        config: makeConfig(makeModel(server.url.toString())),
        apiKey: 'k',
        abortSignal: null,
      ).toList();

      final msg = singleEnd(events).message as AssistantMessage;
      final calls = msg.toolCalls;
      expect(calls, hasLength(1));
      expect(calls.single.id, 'call_a');
      expect(calls.single.name, 'read_file');
      expect(calls.single.arguments, {'path': 'x'});
      expect(msg.stopReason, StopReason.toolUse);
    });

    // pi#4: malformed arguments keep their diagnostic instead of a silent {}.
    test('keeps malformed arguments as a diagnostic, not silent {}', () async {
      server.frames.addAll([
        jsonEncode({
          'id': 'cmpl-bad',
          'choices': [
            {
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'id': 'call_bad',
                    'function': {'name': 'read_file', 'arguments': '{"p'},
                  },
                ],
              },
              'finish_reason': null,
            },
          ],
        }),
        jsonEncode({
          'id': 'cmpl-bad',
          'choices': [
            {'delta': const {}, 'finish_reason': 'tool_calls'},
          ],
        }),
      ]);

      final events = await streamLLM(
        context:
            AgentContext(systemPrompt: '', messages: [UserMessage.text('go')]),
        config: makeConfig(makeModel(server.url.toString())),
        apiKey: 'k',
        abortSignal: null,
      ).toList();

      final msg = singleEnd(events).message as AssistantMessage;
      final call = msg.toolCalls.single;
      expect(call.arguments, isEmpty);
      expect(call.argumentsError, isNotNull);
      expect(call.argumentsError, endsWith('{"p'));
    });

    // pi#4: a non-object argument root is a parse failure, not {}.
    test('keeps a non-object argument root as a diagnostic', () async {
      server.frames.addAll([
        jsonEncode({
          'id': 'cmpl-arr',
          'choices': [
            {
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'id': 'call_arr',
                    'function': {'name': 'read_file', 'arguments': '[1,2]'},
                  },
                ],
              },
              'finish_reason': 'tool_calls',
            },
          ],
        }),
      ]);

      final events = await streamLLM(
        context:
            AgentContext(systemPrompt: '', messages: [UserMessage.text('go')]),
        config: makeConfig(makeModel(server.url.toString())),
        apiKey: 'k',
        abortSignal: null,
      ).toList();

      final msg = singleEnd(events).message as AssistantMessage;
      final call = msg.toolCalls.single;
      expect(call.arguments, isEmpty);
      expect(call.argumentsError,
          contains('Tool arguments must be a JSON object'));
      expect(call.argumentsError, endsWith('[1,2]'));
    });

    test('surfaces non-200 as a provider error outcome (#6)', () async {
      final bad = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      bad.listen((request) {
        request.response.statusCode = 401;
        request.response.write('unauthorized');
        request.response.close();
      });
      addTearDown(() => bad.close(force: true));

      final events = await streamLLM(
        context:
            AgentContext(systemPrompt: '', messages: [UserMessage.text('hi')]),
        config: makeConfig(makeModel('http://127.0.0.1:${bad.port}/v1')),
        apiKey: 'bad',
        abortSignal: null,
      ).toList();

      final msg = singleEnd(events).message as AssistantMessage;
      expect(msg.stopReason, StopReason.error);
      expect(msg.errorMessage, contains('401'));
      expect(msg.errorMessage, contains('unauthorized'));
      // The failure is a diagnostic, not model-authored content.
      expect(msg.content, isEmpty);
      expect(msg.text, isEmpty);
    });

    test('maps an unrecognized finish_reason to an error outcome (#14)',
        () async {
      // A safety guard, a network error and any future vendor value are not
      // clean ends. Upstream maps them to error with the raw reason
      // (openai-completions.ts:1583-1590).
      server.frames.add(jsonEncode({
        'choices': [
          {
            'delta': {'content': 'hello'},
            'finish_reason': 'safety_guard_triggered'
          },
        ],
      }));

      final events = await streamLLM(
        context:
            AgentContext(systemPrompt: '', messages: [UserMessage.text('hi')]),
        config: makeConfig(makeModel(server.url.toString())),
        apiKey: 'k',
        abortSignal: null,
      ).toList();

      final msg = singleEnd(events).message as AssistantMessage;
      expect(msg.stopReason, StopReason.error);
      expect(
          msg.errorMessage, 'Provider finish_reason: safety_guard_triggered');
      // The failure is a diagnostic, not model-authored content.
      expect(msg.content, isEmpty);
      expect(msg.text, isEmpty);
    });

    test('clamps an oversized provider error body (#14)', () async {
      // `errorMessage` is persisted into JSONL, so a proxy answering with a
      // large HTML page must not write it in full (upstream caps at 4000).
      final big = 'x' * 10000;
      final bad = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      bad.listen((request) {
        request.response.statusCode = 502;
        request.response.write(big);
        request.response.close();
      });
      addTearDown(() => bad.close(force: true));

      final events = await streamLLM(
        context:
            AgentContext(systemPrompt: '', messages: [UserMessage.text('hi')]),
        config: makeConfig(makeModel('http://127.0.0.1:${bad.port}/v1')),
        apiKey: 'k',
        abortSignal: null,
      ).toList();

      final msg = singleEnd(events).message as AssistantMessage;
      expect(msg.stopReason, StopReason.error);
      expect(msg.errorMessage, contains('502'));
      expect(msg.errorMessage, contains('... [truncated 6000 chars]'));
      expect(msg.errorMessage!.length, lessThan(4100));
    });

    test('maps transport failures to an error outcome (#6)', () async {
      // A bound-then-closed port gives a connection failure without a server.
      final closed = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final deadPort = closed.port;
      await closed.close(force: true);

      final events = await streamLLM(
        context:
            AgentContext(systemPrompt: '', messages: [UserMessage.text('hi')]),
        config: makeConfig(makeModel('http://127.0.0.1:$deadPort/v1')),
        apiKey: 'k',
        abortSignal: null,
      ).toList();

      final msg = singleEnd(events).message as AssistantMessage;
      expect(msg.stopReason, StopReason.error);
      expect(msg.errorMessage, isNotNull);
      expect(msg.errorMessage, isNotEmpty);
      expect(msg.content, isEmpty);
    });

    test('maps malformed SSE frames to an error outcome (#6)', () async {
      server.frames.addAll(['{not json']);
      // Frames after the malformed one must not become model output.
      server.frames.add(jsonEncode({
        'choices': [
          {
            'delta': {'content': 'should not appear'},
            'finish_reason': 'stop'
          },
        ],
      }));

      final events = await streamLLM(
        context:
            AgentContext(systemPrompt: '', messages: [UserMessage.text('hi')]),
        config: makeConfig(makeModel(server.url.toString())),
        apiKey: 'k',
        abortSignal: null,
      ).toList();

      final msg = singleEnd(events).message as AssistantMessage;
      expect(msg.stopReason, StopReason.error);
      expect(msg.errorMessage, isNotNull);
      expect(msg.text, isNot(contains('should not appear')));
    });

    test('maps a stream ending without a finish reason to an error (#6)',
        () async {
      server.frames.add(jsonEncode({
        'choices': [
          {
            'delta': {'content': 'partial'},
            'finish_reason': null
          },
        ],
      }));

      final events = await streamLLM(
        context:
            AgentContext(systemPrompt: '', messages: [UserMessage.text('hi')]),
        config: makeConfig(makeModel(server.url.toString())),
        apiKey: 'k',
        abortSignal: null,
      ).toList();

      final msg = singleEnd(events).message as AssistantMessage;
      expect(msg.stopReason, StopReason.error);
      expect(msg.errorMessage, contains('finish reason'));
    });

    test('distinguishes a caller abort from a provider error (#6)', () async {
      final abort = Completer<void>();
      server.frames.add(jsonEncode({
        'choices': [
          {
            'delta': {'content': 'partial'},
            'finish_reason': null
          },
        ],
      }));

      final future = streamLLM(
        context:
            AgentContext(systemPrompt: '', messages: [UserMessage.text('hi')]),
        config: makeConfig(makeModel(server.url.toString())),
        apiKey: 'k',
        abortSignal: abort,
      ).toList();

      abort.complete();
      final events = await future;

      final msg = singleEnd(events).message as AssistantMessage;
      expect(msg.stopReason, StopReason.aborted);
      expect(msg.content, isEmpty);
    });

    test('keeps a content filter as a refusal, not an error (#6)', () async {
      server.frames.add(jsonEncode({
        'choices': [
          {'delta': {}, 'finish_reason': 'content_filter'},
        ],
      }));

      final events = await streamLLM(
        context:
            AgentContext(systemPrompt: '', messages: [UserMessage.text('hi')]),
        config: makeConfig(makeModel(server.url.toString())),
        apiKey: 'k',
        abortSignal: null,
      ).toList();

      final msg = singleEnd(events).message as AssistantMessage;
      expect(msg.stopReason, StopReason.refused);
      expect(msg.errorMessage, isNull);
    });

    test('sends serialized tools in the request', () async {
      server.frames.addAll([
        jsonEncode({
          'id': 'cmpl-3',
          'choices': [
            {
              'delta': {'content': 'ok'},
              'finish_reason': 'stop'
            },
          ],
        }),
      ]);

      final tool = AgentTool(
        name: 'echo',
        description: 'Echo input',
        parameters: {
          'type': 'object',
          'properties': {
            'text': {'type': 'string'},
          },
          'required': ['text'],
        },
        execute: (id, params, {onUpdate, isAborted}) async =>
            AgentToolResult(content: [const TextBlock('ok')], details: null),
      );

      await streamLLM(
        context: AgentContext(
          systemPrompt: '',
          messages: [UserMessage.text('hi')],
          tools: [tool],
        ),
        config: makeConfig(makeModel(server.url.toString())),
        apiKey: 'k',
        abortSignal: null,
      ).toList();

      final tools = server.lastBody!['tools'] as List<dynamic>;
      expect(tools, hasLength(1));
      final fn = (tools.single as Map<String, dynamic>)['function']
          as Map<String, dynamic>;
      expect(fn['name'], 'echo');
      expect(fn['description'], 'Echo input');
      expect(fn['parameters'], isA<Map<String, dynamic>>());
    });
  });
}
