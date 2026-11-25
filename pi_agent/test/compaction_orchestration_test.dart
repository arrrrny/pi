import 'dart:async';

import 'package:test/test.dart';
import 'package:pi/pi.dart';

LoopStreamFn _scripted(
  List<AgentEvent> Function(int turn) script, {
  void Function(AgentContext context)? onCall,
}) {
  var turn = 0;
  return ({
    required context,
    required config,
    required apiKey,
    required abortSignal,
  }) {
    onCall?.call(context);
    return Stream<AgentEvent>.fromIterable(script(turn++));
  };
}

AgentEvent _assistant(AssistantMessage m) => MessageEnd(message: m);

String _userText(AgentMessage m) => switch (m) {
      UserMessage(:final content) =>
        content.whereType<TextBlock>().map((b) => b.text).join(),
      AssistantMessage(:final content) =>
        content.whereType<TextBlock>().map((b) => b.text).join(),
      ToolResultMessage(:final content) =>
        content.whereType<TextBlock>().map((b) => b.text).join(),
      CustomMessage(:final display) => display,
    };

void main() {
  group('summarizeMessages', () {
    test('returns the model summary and sends the transcript', () async {
      AgentContext? seen;
      final summary = await summarizeMessages(
        [
          UserMessage.text('the question'),
          AssistantMessage(content: [const TextBlock('the answer')]),
        ],
        const Model(provider: 'openai', modelId: 'gpt-x', contextWindow: 8000),
        loopStreamFn: _scripted(
          (_) => [
            MessageUpdate(
                message: AssistantMessage(content: [const TextBlock('SUM')])),
            _assistant(AssistantMessage(
                content: [const TextBlock('SUM')],
                stopReason: StopReason.endTurn)),
          ],
          onCall: (ctx) => seen = ctx,
        ),
      );

      expect(summary, 'SUM');
      expect(seen, isNotNull);
      final prompt = (seen!.messages.first as UserMessage)
          .content
          .whereType<TextBlock>()
          .single
          .text;
      expect(prompt, contains('the question'));
      expect(prompt, contains('the answer'));
    });
  });

  group('Session.buildContext compaction', () {
    test('applies the summary and drops the summarized entries', () async {
      final storage = InMemorySessionStorage();
      final session = Session(storage);
      await session.appendMessage(UserMessage.text('old one'));
      await session.appendMessage(
          AssistantMessage(content: [const TextBlock('old two')]));
      await session.appendMessage(UserMessage.text('recent'));
      final recentId = (await storage.getLeafId())!;

      await session.appendCompaction('THE SUMMARY', recentId, 1234);

      final ctx = await session.buildContext();
      expect(ctx.messages.first, isA<CustomMessage>());
      expect(_userText(ctx.messages.first), 'THE SUMMARY');

      final userTexts =
          ctx.messages.whereType<UserMessage>().map(_userText).toList();
      expect(userTexts, contains('recent'));
      expect(userTexts, isNot(contains('old one')));
    });
  });

  group('Conversation.compact', () {
    test('summarizes old entries and reseeds the agent with the summary',
        () async {
      final storage = InMemorySessionStorage();
      final conv = await Conversation.create(
        storage,
        model: const Model(
            provider: 'openai', modelId: 'gpt-x', contextWindow: 20),
        systemPrompt: 'sys',
        loopStreamFn: _scripted(
          (_) => [
            _assistant(AssistantMessage(
                content: [const TextBlock('reply')],
                stopReason: StopReason.endTurn)),
          ],
        ),
      );

      await conv
          .prompt('this first message is definitely long enough to matter');
      await conv
          .prompt('and a second equally long message here for good measure');
      final beforeCount = conv.messages.length;
      expect(beforeCount, greaterThanOrEqualTo(4));

      final didCompact = await conv.compact(
        settings:
            const CompactionSettings(reserveTokens: 0, keepRecentTokens: 1),
        summarize: (messages, model) async => 'THE SUMMARY',
      );

      expect(didCompact, isTrue);
      expect(conv.messages.first, isA<CustomMessage>());
      expect(_userText(conv.messages.first), 'THE SUMMARY');
      // The summarized older turns are gone from the live context.
      expect(conv.messages.length, lessThan(beforeCount));
    });

    test('returns false when the context is below the threshold', () async {
      final storage = InMemorySessionStorage();
      final conv = await Conversation.create(
        storage,
        model: const Model(
            provider: 'openai', modelId: 'gpt-x', contextWindow: 1000000),
        loopStreamFn: _scripted(
          (_) => [
            _assistant(AssistantMessage(
                content: [const TextBlock('ok')],
                stopReason: StopReason.endTurn)),
          ],
        ),
      );
      await conv.prompt('hi');

      final didCompact = await conv.compact(
        settings:
            const CompactionSettings(reserveTokens: 0, keepRecentTokens: 1),
        summarize: (messages, model) async => 'unused',
      );
      expect(didCompact, isFalse);
    });
  });
}
