import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:pi/pi.dart';

/// A scripted OpenAI-compatible SSE server. Returns the frames for each
/// successive request, recording every request body it receives.
class _ScriptedServer {
  _ScriptedServer(this._responses);

  final List<List<String>> _responses;
  HttpServer? _server;
  int _request = 0;
  final List<Map<String, dynamic>> bodies = [];

  Uri get url => Uri.parse('http://127.0.0.1:${_server!.port}/v1');

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      final raw = await utf8.decoder.bind(request).join();
      if (raw.isNotEmpty) {
        bodies.add(jsonDecode(raw) as Map<String, dynamic>);
      }
      final frames =
          _request < _responses.length ? _responses[_request] : _responses.last;
      _request++;
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

void main() {
  test(
      'Agent default path runs the full loop end to end (LLM -> tool -> LLM)',
      () async {
    final server = _ScriptedServer([
      // Turn 1: the model issues a tool call.
      [
        jsonEncode({
          'id': 'c1',
          'choices': [
            {
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'id': 'call_1',
                    'function': {'name': 'echo', 'arguments': '{"text":"hi"}'},
                  },
                ],
              },
              'finish_reason': 'tool_calls',
            },
          ],
        }),
      ],
      // Turn 2: the model answers using the tool result.
      [
        jsonEncode({
          'id': 'c2',
          'choices': [
            {
              'delta': {'content': 'final answer'},
              'finish_reason': 'stop',
            },
          ],
        }),
      ],
    ]);
    await server.start();
    addTearDown(server.stop);

    var echoArgs = '';
    final tool = AgentTool(
      name: 'echo',
      description: 'Echo the text back',
      parameters: {
        'type': 'object',
        'properties': {
          'text': {'type': 'string'},
        },
        'required': ['text'],
      },
      execute: (id, params, {onUpdate, isAborted}) async {
        echoArgs = params['text'] as String? ?? '';
        return AgentToolResult(
            content: [TextBlock('echo:$echoArgs')], details: null);
      },
    );

    final agent = Agent(
      model: Model(
        provider: 'openai',
        modelId: 'gpt-x',
        contextWindow: 8000,
        baseUrl: server.url.toString(),
      ),
      systemPrompt: 'sys',
      tools: [tool],
    );

    final events = <AgentEvent>[];
    agent.subscribe(events.add);

    await agent.prompt('go');

    // The tool actually ran with the model's arguments.
    expect(echoArgs, 'hi');
    expect(events.whereType<ToolExecutionEnd>(), hasLength(1));

    // The transcript holds the whole conversation: user, assistant(tool call),
    // tool result, assistant(final answer).
    final messages = agent.state.messages;
    expect(messages.whereType<UserMessage>(), hasLength(1));
    final toolResults = messages.whereType<ToolResultMessage>().toList();
    expect(toolResults, hasLength(1));
    expect(toolResults.single.isError, isFalse);

    final assistants = messages.whereType<AssistantMessage>().toList();
    expect(assistants, hasLength(2));
    expect(assistants.last.text, 'final answer');

    // Both turns were sent to the model with the system prompt.
    expect(server.bodies.length, greaterThanOrEqualTo(2));
    expect(server.bodies.first['messages'].first,
        {'role': 'system', 'content': 'sys'});
  });
}