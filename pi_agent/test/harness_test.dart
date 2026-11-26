import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:pi/pi.dart';

/// Yields a scripted assistant turn per call, so the conversation can be driven
/// through a tool call without a network.
LoopStreamFn scriptedStream(List<AgentEvent> Function(int turn) s) {
  var turn = 0;
  return ({
    required context,
    required config,
    required apiKey,
    required abortSignal,
  }) =>
      Stream<AgentEvent>.fromIterable(s(turn++));
}

AgentEvent _assistant(AssistantMessage m) => MessageEnd(message: m);

AgentTool<dynamic, dynamic> _echoTool(void Function(String) onArgs) =>
    AgentTool(
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
        final text = params['text'] as String? ?? '';
        onArgs(text);
        return AgentToolResult(
            content: [TextBlock('echo:$text')], details: null);
      },
    );

const _model = Model(provider: 'openai', modelId: 'gpt-x', contextWindow: 8000);

void main() {
  group('Conversation (durable harness)', () {
    test('persists the transcript to storage as it runs', () async {
      final storage = InMemorySessionStorage();
      final conv = await Conversation.create(
        storage,
        model: _model,
        systemPrompt: 'sys',
        loopStreamFn: scriptedStream((_) => [
              _assistant(AssistantMessage(
                  content: [const TextBlock('hello')],
                  stopReason: StopReason.endTurn)),
            ]),
      );

      await conv.prompt('hi');

      final entries = await conv.session.getEntries();
      final messages = entries.whereType<MessageEntry>().toList();
      expect(messages, hasLength(2)); // user + assistant

      final ctx = await conv.buildContext();
      expect(ctx.messages, hasLength(2));
      expect(ctx.messages.first, isA<UserMessage>());
      expect(ctx.messages.last, isA<AssistantMessage>());
    });

    test('JSONL round-trips full content and recovers after restart', () async {
      final dir = await Directory.systemTemp.createTemp('pi_harness_');
      final path = '${dir.path}/session.jsonl';
      addTearDown(() => dir.delete(recursive: true));

      var echoArgs = '';
      final first = await Conversation.create(
        JsonlSessionStorage(path),
        model: _model,
        systemPrompt: 'sys',
        tools: [_echoTool((a) => echoArgs = a)],
        loopStreamFn: scriptedStream((turn) {
          if (turn == 0) {
            return [
              _assistant(AssistantMessage(
                content: [
                  ToolCallBlock(
                      id: 'c1', name: 'echo', arguments: {'text': 'hi'}),
                ],
                stopReason: StopReason.toolUse,
              )),
            ];
          }
          return [
            _assistant(AssistantMessage(
                content: [const TextBlock('final answer')],
                stopReason: StopReason.endTurn)),
          ];
        }),
      );

      await first.prompt('go');
      expect(echoArgs, 'hi');
      await first.close();

      // Simulate a process restart: reopen from the same file.
      final resumed = await Conversation.resume(
        JsonlSessionStorage(path),
        systemPrompt: 'sys',
        tools: [_echoTool((_) {})],
        loopStreamFn: scriptedStream((_) => [
              _assistant(AssistantMessage(
                  content: [const TextBlock('unused')],
                  stopReason: StopReason.endTurn)),
            ]),
      );
      addTearDown(resumed.close);

      final messages = resumed.messages;
      expect(messages, hasLength(4));
      expect(messages[0], isA<UserMessage>());
      expect(
          (messages[0] as UserMessage)
              .content
              .whereType<TextBlock>()
              .single
              .text,
          'go');

      final callMsg = messages[1] as AssistantMessage;
      expect(callMsg.toolCalls, hasLength(1));
      expect(callMsg.toolCalls.single.name, 'echo');
      expect(callMsg.toolCalls.single.arguments, {'text': 'hi'});

      final toolResult = messages[2] as ToolResultMessage;
      expect(toolResult.content.whereType<TextBlock>().single.text, 'echo:hi');

      final finalMsg = messages[3] as AssistantMessage;
      expect(finalMsg.text, 'final answer');
    });

    test('a resumed conversation continues with the full prior context',
        () async {
      final dir = await Directory.systemTemp.createTemp('pi_harness_');
      final path = '${dir.path}/session.jsonl';
      addTearDown(() => dir.delete(recursive: true));

      final first = await Conversation.create(
        JsonlSessionStorage(path),
        model: _model,
        systemPrompt: 'sys',
        loopStreamFn: scriptedStream((_) => [
              _assistant(AssistantMessage(
                  content: [const TextBlock('first reply')],
                  stopReason: StopReason.endTurn)),
            ]),
      );
      await first.prompt('hello');
      await first.close();

      List<AgentMessage>? captured;
      final resumed = await Conversation.resume(
        JsonlSessionStorage(path),
        systemPrompt: 'sys',
        loopStreamFn: ({
          required context,
          required config,
          required apiKey,
          required abortSignal,
        }) {
          captured = context.messages;
          return Stream<AgentEvent>.fromIterable([
            _assistant(AssistantMessage(
                content: [const TextBlock('second reply')],
                stopReason: StopReason.endTurn)),
          ]);
        },
      );
      addTearDown(resumed.close);

      await resumed.prompt('again');

      // The model saw the prior user + assistant plus the new user message.
      expect(captured, isNotNull);
      expect(captured!.length, greaterThanOrEqualTo(3));
      expect(captured!.last, isA<UserMessage>());
    });

    test('fork branches the conversation at an earlier entry', () async {
      final storage = InMemorySessionStorage();
      final conv = await Conversation.create(
        storage,
        model: _model,
        loopStreamFn: scriptedStream((_) => [
              _assistant(AssistantMessage(
                  content: [const TextBlock('r')],
                  stopReason: StopReason.endTurn)),
            ]),
      );

      await conv.prompt('one');
      await conv.prompt('two');
      expect((await conv.buildContext()).messages, hasLength(4));

      // Fork back to the first user message and verify the branch shrinks.
      final entries = await conv.session.getEntries();
      final firstUserId = entries.whereType<MessageEntry>().first.id;
      await conv.fork(firstUserId);

      final ctx = await conv.buildContext();
      expect(ctx.messages, hasLength(1));
      expect(
          (ctx.messages.single as UserMessage)
              .content
              .whereType<TextBlock>()
              .single
              .text,
          'one');
    });
  });

  group('Conversation in-flight resume', () {
    test('detects and completes a dangling user turn', () async {
      final storage = InMemorySessionStorage();
      // Simulate a crash after the input was persisted, before the model answered.
      final seed = Session(storage);
      await seed.appendMessage(UserMessage.text('do work'));

      final conv = await Conversation.resume(
        storage,
        systemPrompt: 'sys',
        loopStreamFn: scriptedStream((_) => [
              _assistant(AssistantMessage(
                  content: [const TextBlock('resumed answer')],
                  stopReason: StopReason.endTurn)),
            ]),
      );

      expect(conv.hasPendingTurn, isTrue);
      final resumed = await conv.resumeInterruptedTurn();
      expect(resumed, isTrue);
      expect(conv.hasPendingTurn, isFalse);

      final last = conv.messages.last;
      expect(last, isA<AssistantMessage>());
      expect((last as AssistantMessage).text, 'resumed answer');
    });

    test('resumeInterruptedTurn is a no-op without a pending turn', () async {
      final storage = InMemorySessionStorage();
      final seed = Session(storage);
      await seed.appendMessage(UserMessage.text('q'));
      await seed
          .appendMessage(AssistantMessage(content: [const TextBlock('a')]));

      final conv = await Conversation.resume(
        storage,
        loopStreamFn: scriptedStream((_) => [
              _assistant(AssistantMessage(
                  content: [const TextBlock('x')],
                  stopReason: StopReason.endTurn)),
            ]),
      );

      expect(conv.hasPendingTurn, isFalse);
      expect(await conv.resumeInterruptedTurn(), isFalse);
    });

    test('an interrupted turn survives restart (JSONL) and resumes', () async {
      final dir = await Directory.systemTemp.createTemp('pi_harness_');
      final path = '${dir.path}/session.jsonl';
      addTearDown(() => dir.delete(recursive: true));

      // Persist a dangling user message, then "crash".
      final seed = JsonlSessionStorage(path);
      await seed.init();
      final session = Session(seed);
      await session.appendMessage(UserMessage.text('unfinished task'));

      final conv = await Conversation.resume(
        JsonlSessionStorage(path),
        systemPrompt: 'sys',
        loopStreamFn: scriptedStream((_) => [
              _assistant(AssistantMessage(
                  content: [const TextBlock('finished after restart')],
                  stopReason: StopReason.endTurn)),
            ]),
      );
      addTearDown(conv.close);

      expect(conv.hasPendingTurn, isTrue);
      await conv.resumeInterruptedTurn();
      expect(conv.hasPendingTurn, isFalse);
      expect((conv.messages.last as AssistantMessage).text,
          'finished after restart');
    });
  });
}
