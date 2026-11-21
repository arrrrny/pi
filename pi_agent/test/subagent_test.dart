import 'dart:async';

import 'package:test/test.dart';
import 'package:pi/pi.dart';

LoopStreamFn _scripted(
  List<AgentEvent> Function(int turn) script,
) {
  var turn = 0;
  return ({
    required context,
    required config,
    required apiKey,
    required abortSignal,
  }) =>
      Stream<AgentEvent>.fromIterable(script(turn++));
}

AgentEvent _assistant(AssistantMessage m) => MessageEnd(message: m);

const _model = Model(provider: 'openai', modelId: 'gpt-x', contextWindow: 8000);

void main() {
  group('subagentTool', () {
    test('delegates a task to a child agent and returns its answer', () async {
      var childSawTask = '';

      // The child agent: captures the task it was handed (via its context) and
      // returns a result derived from it.
      Agent makeChild() => Agent(
            model: _model,
            loopStreamFn: ({
              required context,
              required config,
              required apiKey,
              required abortSignal,
            }) {
              final user = context.messages.whereType<UserMessage>().toList();
              if (user.isNotEmpty) {
                childSawTask = user.first.content
                    .whereType<TextBlock>()
                    .map((b) => b.text)
                    .join();
              }
              return Stream<AgentEvent>.fromIterable([
                _assistant(AssistantMessage(
                    content: [const TextBlock('child result')],
                    stopReason: StopReason.endTurn)),
              ]);
            },
          );

      final parent = Agent(
        model: _model,
        tools: [
          subagentTool(
            name: 'task',
            description: 'Delegate a task to a subagent',
            childFactory: makeChild,
          ),
        ],
        loopStreamFn: _scripted((turn) {
          if (turn == 0) {
            return [
              _assistant(AssistantMessage(
                content: [
                  ToolCallBlock(
                      id: 's1', name: 'task', arguments: {'task': 'summarize X'}),
                ],
                stopReason: StopReason.toolUse,
              )),
            ];
          }
          return [
            _assistant(AssistantMessage(
                content: [const TextBlock('parent answer')],
                stopReason: StopReason.endTurn)),
          ];
        }),
      );

      final events = <AgentEvent>[];
      parent.subscribe(events.add);
      await parent.prompt('go');

      // The child received the delegated task.
      expect(childSawTask, 'summarize X');

      // The parent's transcript carries the tool result with the child answer.
      final toolResult =
          parent.state.messages.whereType<ToolResultMessage>().single;
      expect(toolResult.toolName, 'task');
      expect(toolResult.isError, isFalse);
      expect(toolResult.content.whereType<TextBlock>().single.text,
          'child result');

      // The parent then produced its own final answer.
      final assistants =
          parent.state.messages.whereType<AssistantMessage>().toList();
      expect(assistants.last.text, 'parent answer');

      // Tool execution events fired for the subagent call.
      expect(events.whereType<ToolExecutionEnd>(), hasLength(1));
    });

    test('returns empty string when the child produced no assistant message',
        () async {
      final tool = subagentTool(
        name: 'task',
        description: 'empty child',
        childFactory: () => Agent(
          model: _model,
          loopStreamFn: _scripted((_) => const []),
        ),
      );

      final result = await tool.execute('id', {'task': 'nothing'});
      expect(result.content.whereType<TextBlock>().single.text, '');
    });
  });
}