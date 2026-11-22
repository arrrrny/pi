import 'dart:async';

import 'package:test/test.dart';
import 'package:pi/src/types.dart' hide AgentTool;
import 'package:pi/src/tools.dart';
import 'package:pi/src/agent_loop.dart';

/// A faux stream function that yields a scripted assistant turn per call.
///
/// Each invocation returns the events for the next turn, so the loop can be
/// driven through tool calls and multi-turn conversations without a network.
LoopStreamFn scriptedStream(List<AgentEvent> Function(int turn) script) {
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

AgentLoopConfig _config({
  Future<List<Map<String, dynamic>>> Function(List<AgentMessage>)? convertToLlm,
  bool Function(ShouldStopAfterTurnContext)? shouldStopAfterTurn,
  Future<List<AgentMessage>> Function()? getSteeringMessages,
  Future<List<AgentMessage>> Function()? getFollowUpMessages,
  Future<BeforeToolCallResult?> Function(BeforeToolCallContext,
          {bool Function()? isAborted})?
      beforeToolCall,
  Future<AfterToolCallResult?> Function(AfterToolCallContext,
          {bool Function()? isAborted})?
      afterToolCall,
  ToolExecutionMode? toolExecution,
}) =>
    AgentLoopConfig(
      model: const Model(
          provider: 'openai', modelId: 'gpt-4o', contextWindow: 128000),
      convertToLlm: convertToLlm ??
          (msgs) async =>
              msgs.map((m) => {'role': 'user', 'content': 'test'}).toList(),
      shouldStopAfterTurn: shouldStopAfterTurn,
      getSteeringMessages: getSteeringMessages,
      getFollowUpMessages: getFollowUpMessages,
      beforeToolCall: beforeToolCall,
      afterToolCall: afterToolCall,
      toolExecution: toolExecution ?? ToolExecutionMode.parallel,
    );

AgentContext _context({
  List<AgentMessage>? messages,
  List<AgentTool<dynamic, dynamic>>? tools,
}) =>
    AgentContext(
      systemPrompt: 'test',
      messages: messages ?? [UserMessage.text('hello')],
      tools: tools,
    );

void main() {
  group('agentLoop (real loop)', () {
    test('emits AgentStart … AgentEnd around a single turn', () async {
      final events = await agentLoop(
        _context(),
        _config(),
        streamFn: scriptedStream((_) => [
          _assistant(AssistantMessage(
              content: [const TextBlock('hi')],
              stopReason: StopReason.endTurn)),
        ]),
      ).toList();

      expect(events.first, isA<AgentStart>());
      expect(events.last, isA<AgentEnd>());
      expect(events.whereType<TurnStart>(), hasLength(1));
      expect(events.whereType<TurnEnd>(), hasLength(1));
      final end = events.last as AgentEnd;
      final assistant = end.messages.whereType<AssistantMessage>().single;
      expect(assistant.text, 'hi');
    });

    test('executes a tool call and feeds the result into the next turn',
        () async {
      var echoCalled = false;
      Map<String, dynamic>? seenArgs;
      final tool = AgentTool(
        name: 'echo',
        description: 'Echo input',
        parameters: {'type': 'object'},
        execute: (id, params, {onUpdate, isAborted}) async {
          echoCalled = true;
          seenArgs = params;
          return AgentToolResult(
              content: [TextBlock('echoed ${params['text']}')], details: null);
        },
      );

      final events = await agentLoop(
        _context(tools: [tool]),
        _config(),
        streamFn: scriptedStream((turn) {
          if (turn == 0) {
            return [
              _assistant(AssistantMessage(
                content: [
                  ToolCallBlock(id: 'c1', name: 'echo', arguments: {'text': 'x'}),
                ],
                stopReason: StopReason.toolUse,
              )),
            ];
          }
          return [
            _assistant(AssistantMessage(
                content: [const TextBlock('done')],
                stopReason: StopReason.endTurn)),
          ];
        }),
      ).toList();

      expect(echoCalled, isTrue);
      expect(seenArgs, {'text': 'x'});
      expect(events.whereType<ToolExecutionStart>(), hasLength(1));
      expect(events.whereType<ToolExecutionEnd>(), hasLength(1));
      expect(events.whereType<TurnEnd>(), hasLength(2));

      final end = events.last as AgentEnd;
      final toolResult = end.messages.whereType<ToolResultMessage>().single;
      expect(toolResult.toolCallId, 'c1');
      expect(toolResult.isError, isFalse);
      expect(toolResult.content.whereType<TextBlock>().single.text, 'echoed x');
    });

    test('beforeToolCall hook can block a call without executing it', () async {
      var executed = false;
      final tool = AgentTool(
        name: 'danger',
        description: 'A blocked tool',
        parameters: {'type': 'object'},
        execute: (id, params, {onUpdate, isAborted}) async {
          executed = true;
          return AgentToolResult(content: [const TextBlock('ran')], details: null);
        },
      );

      final events = await agentLoop(
        _context(tools: [tool]),
        _config(
          beforeToolCall: (ctx, {isAborted}) async => BeforeToolCallResult(
            block: [const TextBlock('not allowed')],
            reason: 'not allowed',
          ),
        ),
        streamFn: scriptedStream((turn) {
          if (turn == 0) {
            return [
              _assistant(AssistantMessage(
                content: [
                  ToolCallBlock(id: 'c1', name: 'danger', arguments: const {}),
                ],
                stopReason: StopReason.toolUse,
              )),
            ];
          }
          return [
            _assistant(AssistantMessage(
                content: [const TextBlock('ok')],
                stopReason: StopReason.endTurn)),
          ];
        }),
      ).toList();

      expect(executed, isFalse);
      final end = events.last as AgentEnd;
      final toolResult = end.messages.whereType<ToolResultMessage>().single;
      expect(toolResult.isError, isTrue);
      expect(toolResult.content.whereType<TextBlock>().single.text,
          contains('not allowed'));
    });

    test('follow-up messages continue the loop', () async {
      var followUpCalls = 0;
      final events = await agentLoop(
        _context(),
        _config(
          shouldStopAfterTurn: (_) => false,
          getFollowUpMessages: () async {
            followUpCalls++;
            return followUpCalls <= 2 ? [UserMessage.text('more')] : [];
          },
        ),
        streamFn: scriptedStream((_) => [
          _assistant(AssistantMessage(
              content: [const TextBlock('ok')],
              stopReason: StopReason.endTurn)),
        ]),
      ).toList();

      expect(events.whereType<TurnEnd>().length, greaterThanOrEqualTo(2));
    });

    test('steering messages are injected before the next turn', () async {
      var steerCalls = 0;
      await agentLoop(
        _context(),
        _config(
          shouldStopAfterTurn: (_) => false,
          getSteeringMessages: () async {
            steerCalls++;
            return steerCalls <= 1 ? [UserMessage.text('steer')] : [];
          },
        ),
        streamFn: scriptedStream((_) => [
          _assistant(AssistantMessage(
              content: [const TextBlock('ok')],
              stopReason: StopReason.endTurn)),
        ]),
      ).toList();

      expect(steerCalls, greaterThanOrEqualTo(1));
    });

    test('defaults to a single turn when no tools or follow-ups', () async {
      final events = await agentLoop(
        _context(),
        _config(),
        streamFn: scriptedStream((_) => [
          _assistant(AssistantMessage(
              content: [const TextBlock('once')],
              stopReason: StopReason.endTurn)),
        ]),
      ).toList();

      expect(events.whereType<TurnEnd>(), hasLength(1));
    });
  });

  group('agentLoopContinue', () {
    test('continues from existing context', () async {
      final events = await agentLoopContinue(
        _context(messages: [UserMessage.text('hi')]),
        _config(),
        streamFn: scriptedStream((_) => [
          _assistant(AssistantMessage(
              content: [const TextBlock('continued')],
              stopReason: StopReason.endTurn)),
        ]),
      ).toList();

      expect(events.first, isA<AgentStart>());
      expect(events.last, isA<AgentEnd>());
    });

    test('throws on empty context', () {
      expect(
        () => agentLoopContinue(_context(messages: []), _config()),
        throwsStateError,
      );
    });
  });

  group('runAgentLoop', () {
    test('collects the final messages', () async {
      final messages = await runAgentLoop(
        _context(),
        _config(),
        streamFn: scriptedStream((_) => [
          _assistant(AssistantMessage(
              content: [const TextBlock('hi')],
              stopReason: StopReason.endTurn)),
        ]),
      );

      expect(messages, isA<List<AgentMessage>>());
      expect(messages.whereType<AssistantMessage>(), isNotEmpty);
    });
  });

  group('agentLoop parity (edge paths)', () {
    test('executes tool calls sequentially when the config says so', () async {
      final order = <String>[];
      AgentTool<dynamic, dynamic> makeTool(String name) => AgentTool(
            name: name,
            description: name,
            parameters: const {'type': 'object'},
            execute: (id, params, {onUpdate, isAborted}) async {
              order.add(name);
              return AgentToolResult(content: [TextBlock(name)], details: null);
            },
          );

      await agentLoop(
        _context(tools: [makeTool('a'), makeTool('b')]),
        _config(toolExecution: ToolExecutionMode.sequential),
        streamFn: scriptedStream((turn) {
          if (turn == 0) {
            return [
              _assistant(AssistantMessage(
                content: [
                  ToolCallBlock(id: '1', name: 'a', arguments: const {}),
                  ToolCallBlock(id: '2', name: 'b', arguments: const {}),
                ],
                stopReason: StopReason.toolUse,
              )),
            ];
          }
          return [
            _assistant(AssistantMessage(
                content: [const TextBlock('done')],
                stopReason: StopReason.endTurn)),
          ];
        }),
      ).toList();

      expect(order, ['a', 'b']);
    });

    test('a per-tool sequential mode forces sequential execution', () async {
      final order = <String>[];
      AgentTool<dynamic, dynamic> makeTool(String name, ToolExecutionMode mode) =>
          AgentTool(
            name: name,
            description: name,
            parameters: const {'type': 'object'},
            executionMode: mode,
            execute: (id, params, {onUpdate, isAborted}) async {
              await Future<void>.delayed(const Duration(milliseconds: 5));
              order.add(name);
              return AgentToolResult(content: [TextBlock(name)], details: null);
            },
          );

      await agentLoop(
        _context(tools: [
          makeTool('a', ToolExecutionMode.sequential),
          makeTool('b', ToolExecutionMode.parallel),
        ]),
        _config(), // config is parallel, but tool 'a' forces sequential
        streamFn: scriptedStream((turn) {
          if (turn == 0) {
            return [
              _assistant(AssistantMessage(
                content: [
                  ToolCallBlock(id: '1', name: 'a', arguments: const {}),
                  ToolCallBlock(id: '2', name: 'b', arguments: const {}),
                ],
                stopReason: StopReason.toolUse,
              )),
            ];
          }
          return [
            _assistant(AssistantMessage(
                content: [const TextBlock('done')],
                stopReason: StopReason.endTurn)),
          ];
        }),
      ).toList();

      expect(order, ['a', 'b']);
    });

    test('afterToolCall can replace the result content', () async {
      final tool = AgentTool(
        name: 'raw',
        description: 'returns raw',
        parameters: const {'type': 'object'},
        execute: (id, params, {onUpdate, isAborted}) async =>
            AgentToolResult(content: [const TextBlock('raw')], details: null),
      );

      final events = await agentLoop(
        _context(tools: [tool]),
        _config(
          afterToolCall: (ctx, {isAborted}) async =>
              AfterToolCallResult(content: [const TextBlock('modified')]),
        ),
        streamFn: scriptedStream((turn) {
          if (turn == 0) {
            return [
              _assistant(AssistantMessage(
                content: [
                  ToolCallBlock(id: '1', name: 'raw', arguments: const {}),
                ],
                stopReason: StopReason.toolUse,
              )),
            ];
          }
          return [
            _assistant(AssistantMessage(
                content: [const TextBlock('done')],
                stopReason: StopReason.endTurn)),
          ];
        }),
      ).toList();

      final end = events.last as AgentEnd;
      final toolResult = end.messages.whereType<ToolResultMessage>().single;
      expect(toolResult.content.whereType<TextBlock>().single.text, 'modified');
    });

    test('afterToolCall terminate ends the run after this batch', () async {
      final tool = AgentTool(
        name: 'stop',
        description: 'terminates',
        parameters: const {'type': 'object'},
        execute: (id, params, {onUpdate, isAborted}) async =>
            AgentToolResult(content: [const TextBlock('x')], details: null),
      );

      final events = await agentLoop(
        _context(tools: [tool]),
        _config(
          afterToolCall: (ctx, {isAborted}) async =>
              const AfterToolCallResult(terminate: true),
        ),
        streamFn: scriptedStream((turn) {
          if (turn == 0) {
            return [
              _assistant(AssistantMessage(
                content: [
                  ToolCallBlock(id: '1', name: 'stop', arguments: const {}),
                ],
                stopReason: StopReason.toolUse,
              )),
            ];
          }
          return [
            _assistant(AssistantMessage(
                content: [const TextBlock('should not happen')],
                stopReason: StopReason.endTurn)),
          ];
        }),
      ).toList();

      // terminate stops the loop after the tool batch: no second LLM turn.
      expect(events.whereType<TurnEnd>(), hasLength(1));
    });

    test('does not execute tools from a max-tokens truncated message',
        () async {
      var executed = false;
      final tool = AgentTool(
        name: 'a',
        description: 'a',
        parameters: const {'type': 'object'},
        execute: (id, params, {onUpdate, isAborted}) async {
          executed = true;
          return AgentToolResult(content: [const TextBlock('x')], details: null);
        },
      );

      final events = await agentLoop(
        _context(tools: [tool]),
        _config(),
        streamFn: scriptedStream((turn) {
          if (turn == 0) {
            return [
              _assistant(AssistantMessage(
                content: [
                  ToolCallBlock(id: '1', name: 'a', arguments: const {}),
                ],
                stopReason: StopReason.maxTokens,
              )),
            ];
          }
          return [
            _assistant(AssistantMessage(
                content: [const TextBlock('done')],
                stopReason: StopReason.endTurn)),
          ];
        }),
      ).toList();

      expect(executed, isFalse);
      final end = events.last as AgentEnd;
      final toolResult = end.messages.whereType<ToolResultMessage>().single;
      expect(toolResult.isError, isTrue);
      expect(toolResult.content.whereType<TextBlock>().single.text,
          contains('output token limit'));
    });

    test('aborts mid-run: no further turn after the abort', () async {
      final abort = Completer<void>();
      final tool = AgentTool(
        name: 'slow',
        description: 'completes the abort while running',
        parameters: const {'type': 'object'},
        execute: (id, params, {onUpdate, isAborted}) async {
          abort.complete();
          return AgentToolResult(content: [const TextBlock('x')], details: null);
        },
      );

      final events = await agentLoop(
        _context(tools: [tool]),
        _config(),
        abortSignal: abort,
        streamFn: scriptedStream((turn) {
          if (turn == 0) {
            return [
              _assistant(AssistantMessage(
                content: [
                  ToolCallBlock(id: '1', name: 'slow', arguments: const {}),
                ],
                stopReason: StopReason.toolUse,
              )),
            ];
          }
          return [
            _assistant(AssistantMessage(
                content: [const TextBlock('should not happen')],
                stopReason: StopReason.endTurn)),
          ];
        }),
      ).toList();

      // After the tool aborts the run, the loop must not start a second turn.
      expect(events.whereType<TurnEnd>(), hasLength(1));
    });

    for (final reason in [StopReason.error, StopReason.aborted]) {
      test('terminates on $reason with no tool execution (#6)', () async {
        var providerCalls = 0;
        var toolExecuted = false;
        final tool = AgentTool(
          name: 'echo',
          description: 'must never run after a failed provider response',
          parameters: const {'type': 'object'},
          execute: (id, params, {onUpdate, isAborted}) async {
            toolExecuted = true;
            return AgentToolResult(
                content: [const TextBlock('x')], details: null);
          },
        );

        final events = await agentLoop(
          _context(tools: [tool]),
          _config(getFollowUpMessages: () async => [UserMessage.text('again')]),
          streamFn: ({required context, required config, required apiKey,
                  required abortSignal}) {
            providerCalls++;
            // A failed provider response carries a tool call in some broken
            // providers; it must never be executed.
            return Stream.fromIterable([
              _assistant(AssistantMessage(
                content: [
                  ToolCallBlock(id: 'c1', name: 'echo', arguments: const {}),
                ],
                stopReason: reason,
                errorMessage: 'provider failed',
              )),
            ]);
          },
        ).toList();

        expect(providerCalls, 1);
        expect(toolExecuted, isFalse);
        expect(events.whereType<ToolExecutionStart>(), isEmpty);
        expect(events.whereType<TurnEnd>(), hasLength(1));
        // Terminal ordering: the run ends right after the failed turn, with no
        // further turn started.
        expect(events.whereType<TurnStart>(), hasLength(1));
        expect(events.last, isA<AgentEnd>());
        expect(events[events.length - 2], isA<TurnEnd>());
        expect(events[events.length - 3], isA<MessageEnd>());
      });
    }
  });
}