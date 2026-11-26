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
                  ToolCallBlock(
                      id: 'c1', name: 'echo', arguments: {'text': 'x'}),
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
          return AgentToolResult(
              content: [const TextBlock('ran')], details: null);
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
      AgentTool<dynamic, dynamic> makeTool(
              String name, ToolExecutionMode mode) =>
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
          return AgentToolResult(
              content: [const TextBlock('x')], details: null);
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
          return AgentToolResult(
              content: [const TextBlock('x')], details: null);
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

    test('propagates a loop-body failure instead of swallowing it (#5)',
        () async {
      // `_streamFromAsync` wrapped the loop body in `catch (_) {}`, so a
      // failure that escaped `_runLoop` (a throwing stream function, a throwing
      // transformContext, tool internals) never reached the caller: `agentLoop`
      // completed with only the events emitted before the throw. The stream must
      // carry the error so `Agent._run` can surface a structured outcome.
      await expectLater(
        () => agentLoop(
          _context(),
          _config(),
          streamFn: (
                  {required context,
                  required config,
                  required apiKey,
                  required abortSignal}) =>
              Stream<AgentEvent>.error(Exception('loop body exploded')),
        ).toList(),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'toString', contains('loop body exploded'))),
      );
    });

    test('propagates a loop-body failure to a late subscriber (#5)', () async {
      // The loop body runs in a microtask, so a consumer that subscribes after
      // its first suspension reaches the throw with no listener yet attached.
      // A `hasListener` guard on the `addError` dropped the error for exactly
      // that consumer — the same silent completion #5 is about, in the
      // late-subscriber case. A single-subscription controller buffers an error
      // added before the first listen, so the caller must still see it.
      final stream = agentLoop(
        _context(),
        _config(),
        streamFn: (
                {required context,
                required config,
                required apiKey,
                required abortSignal}) =>
            Stream<AgentEvent>.error(Exception('body exploded')),
      );

      // Let the microtask run to completion, so the subscription is armed
      // strictly after the throw.
      await Future<void>.delayed(Duration.zero);

      await expectLater(
        stream.toList(),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'toString', contains('body exploded'))),
      );
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
          streamFn: (
              {required context,
              required config,
              required apiKey,
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

    // pi#4: malformed tool-call arguments must fail closed, not run as {}.
    test('does not execute a tool whose arguments failed to parse', () async {
      var executed = false;
      var prepared = false;
      var hooked = false;
      final tool = AgentTool(
        name: 'write',
        description: 'writes',
        parameters: const {
          'type': 'object',
          'required': ['path']
        },
        prepareArguments: (args) {
          prepared = true;
          return null;
        },
        execute: (id, params, {onUpdate, isAborted}) async {
          executed = true;
          return AgentToolResult(
              content: [const TextBlock('ran')], details: null);
        },
      );

      final events = await agentLoop(
        _context(tools: [tool]),
        _config(beforeToolCall: (ctx, {isAborted}) async {
          hooked = true;
          return null;
        }),
        streamFn: scriptedStream((turn) {
          if (turn == 0) {
            return [
              _assistant(AssistantMessage(
                content: [
                  ToolCallBlock(
                    id: 'c1',
                    name: 'write',
                    arguments: const {},
                    argumentsError:
                        'Unexpected end of input\n\nReceived arguments:\n{"path":',
                  ),
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

      expect(executed, isFalse);
      expect(prepared, isFalse);
      expect(hooked, isFalse);

      final end = events.last as AgentEnd;
      final toolResult = end.messages.whereType<ToolResultMessage>().single;
      expect(toolResult.isError, isTrue);
      final text = toolResult.content.whereType<TextBlock>().single.text;
      expect(text, contains('Invalid arguments for tool "write"'));
      expect(text, contains('Received arguments:'));
    });
  });

  // pi#3: tool arguments are validated (and coerced) between argument
  // preparation and the beforeToolCall hook, as upstream's
  // validateToolArguments does. A schema-invalid call becomes an error result
  // and never reaches the hook or the tool body; a coercible call reaches both
  // with the coerced values.
  group('agentLoop tool argument validation (pi#3)', () {
    /// Runs one scripted tool call and returns every event the loop emitted.
    Future<List<AgentEvent>> runOneCall({
      required AgentTool<dynamic, dynamic> tool,
      required ToolCallBlock toolCall,
      Future<BeforeToolCallResult?> Function(BeforeToolCallContext,
              {bool Function()? isAborted})?
          beforeToolCall,
      ToolExecutionMode toolExecution = ToolExecutionMode.parallel,
    }) =>
        agentLoop(
          _context(tools: [tool]),
          _config(
            beforeToolCall: beforeToolCall,
            toolExecution: toolExecution,
          ),
          streamFn: scriptedStream((turn) {
            if (turn == 0) {
              return [
                _assistant(AssistantMessage(
                  content: [toolCall],
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

    ToolResultMessage singleResult(List<AgentEvent> events) =>
        (events.last as AgentEnd)
            .messages
            .whereType<ToolResultMessage>()
            .single;

    test('rejects a call missing a required field without executing it',
        () async {
      var executed = false;
      var hooked = false;
      final tool = AgentTool(
        name: 'write',
        description: 'writes',
        parameters: const {
          'type': 'object',
          'properties': {
            'path': {'type': 'string'},
          },
          'required': ['path'],
        },
        execute: (id, params, {onUpdate, isAborted}) async {
          executed = true;
          return AgentToolResult(
              content: [const TextBlock('ran')], details: null);
        },
      );

      final events = await runOneCall(
        tool: tool,
        toolCall: ToolCallBlock(id: 'c1', name: 'write', arguments: const {}),
        beforeToolCall: (ctx, {isAborted}) async {
          hooked = true;
          return null;
        },
      );

      expect(executed, isFalse);
      expect(hooked, isFalse);
      final result = singleResult(events);
      expect(result.isError, isTrue);
      final text = result.content.whereType<TextBlock>().single.text;
      expect(text, contains('Validation failed for tool "write"'));
      expect(text, contains('path: required field missing'));
      expect(text, contains('Received arguments:'));
    });

    test('rejects wrong types that coercion cannot fix', () async {
      var executed = false;
      final tool = AgentTool(
        name: 'count',
        description: 'counts',
        parameters: const {
          'type': 'object',
          'properties': {
            'value': {'type': 'integer'},
          },
          'required': ['value'],
        },
        execute: (id, params, {onUpdate, isAborted}) async {
          executed = true;
          return AgentToolResult(
              content: [const TextBlock('ran')], details: null);
        },
      );

      final events = await runOneCall(
        tool: tool,
        toolCall: ToolCallBlock(
            id: 'c1', name: 'count', arguments: const {'value': 'many'}),
      );

      expect(executed, isFalse);
      final result = singleResult(events);
      expect(result.isError, isTrue);
      expect(result.content.whereType<TextBlock>().single.text,
          contains('Validation failed for tool "count"'));
    });

    test('coerces arguments and delivers the coerced values to hook and tool',
        () async {
      Map<String, dynamic>? executedWith;
      Map<String, dynamic>? hookedWith;
      final tool = AgentTool(
        name: 'tag',
        description: 'tags',
        parameters: const {
          'type': 'object',
          'properties': {
            'count': {'type': 'integer'},
            'active': {'type': 'boolean'},
            'tags': {
              'type': 'array',
              'items': {'type': 'string'},
            },
          },
          'required': ['count', 'active', 'tags'],
        },
        execute: (id, params, {onUpdate, isAborted}) async {
          executedWith = params;
          return AgentToolResult(
              content: [const TextBlock('ok')], details: null);
        },
      );

      final events = await runOneCall(
        tool: tool,
        toolCall: ToolCallBlock(
          id: 'c1',
          name: 'tag',
          arguments: const {'count': '42', 'active': 'true', 'tags': 'solo'},
        ),
        beforeToolCall: (ctx, {isAborted}) async {
          hookedWith = ctx.args;
          return null;
        },
      );

      expect(hookedWith, isNotNull);
      expect(hookedWith!['count'], 42);
      expect(hookedWith!['active'], isTrue);
      expect(hookedWith!['tags'], ['solo']);
      expect(executedWith, isNotNull);
      expect(executedWith!['count'], 42);
      expect(executedWith!['active'], isTrue);
      expect(executedWith!['tags'], ['solo']);
      expect(singleResult(events).isError, isFalse);
    });

    test('validates the arguments prepareArguments produced', () async {
      var executedWith = <Map<String, dynamic>>[];
      final tool = AgentTool(
        name: 'edit',
        description: 'edits',
        parameters: const {
          'type': 'object',
          'properties': {
            'edits': {
              'type': 'array',
              'items': {
                'type': 'object',
                'properties': {
                  'oldText': {'type': 'string'},
                  'newText': {'type': 'string'},
                },
                'required': ['oldText', 'newText'],
              },
            },
          },
          'required': ['edits'],
        },
        // Mirrors upstream's "should prepare tool arguments for validation":
        // the raw single-edit shape is rewritten into the schema's array shape.
        prepareArguments: (args) {
          final input = args;
          if (input['oldText'] is! String || input['newText'] is! String) {
            return null;
          }
          return {
            'edits': [
              {'oldText': input['oldText'], 'newText': input['newText']},
            ],
          };
        },
        execute: (id, params, {onUpdate, isAborted}) async {
          executedWith.add(params);
          return AgentToolResult(
              content: [const TextBlock('edited')], details: null);
        },
      );

      final events = await runOneCall(
        tool: tool,
        toolCall: ToolCallBlock(
          id: 'c1',
          name: 'edit',
          arguments: const {'oldText': 'before', 'newText': 'after'},
        ),
      );

      expect(executedWith, hasLength(1));
      expect(singleResult(events).isError, isFalse);

      // The prepared shape is what gets validated: a prepareArguments output
      // that breaks the schema is rejected instead of executing.
      final brokenTool = AgentTool(
        name: 'edit',
        description: 'edits',
        parameters: tool.parameters,
        prepareArguments: (args) => const {'edits': 'not an array'},
        execute: (id, params, {onUpdate, isAborted}) async {
          executedWith.add(params);
          return AgentToolResult(
              content: [const TextBlock('edited')], details: null);
        },
      );

      final brokenEvents = await runOneCall(
        tool: brokenTool,
        toolCall: ToolCallBlock(
          id: 'c2',
          name: 'edit',
          arguments: const {'oldText': 'a', 'newText': 'b'},
        ),
      );

      expect(executedWith, hasLength(1),
          reason: 'an invalid prepared shape must not execute');
      final result = singleResult(brokenEvents);
      expect(result.isError, isTrue);
      expect(result.content.whereType<TextBlock>().single.text,
          contains('Validation failed for tool "edit"'));
    });

    test('unknown tools stay an error result with no execution', () async {
      var executed = false;
      final tool = AgentTool(
        name: 'known',
        description: 'known',
        parameters: const {'type': 'object'},
        execute: (id, params, {onUpdate, isAborted}) async {
          executed = true;
          return AgentToolResult(
              content: [const TextBlock('ran')], details: null);
        },
      );

      final events = await runOneCall(
        tool: tool,
        toolCall: ToolCallBlock(id: 'c1', name: 'unknown', arguments: const {}),
      );

      expect(executed, isFalse);
      final result = singleResult(events);
      expect(result.isError, isTrue);
      expect(result.content.whereType<TextBlock>().single.text,
          contains('Tool unknown not found'));
    });

    test('a validated-then-overridden call executes without revalidation',
        () async {
      Map<String, dynamic>? executedWith;
      final tool = AgentTool(
        name: 'echo',
        description: 'echoes',
        parameters: const {
          'type': 'object',
          'properties': {
            'value': {'type': 'string'},
          },
          'required': ['value'],
        },
        execute: (id, params, {onUpdate, isAborted}) async {
          executedWith = params;
          return AgentToolResult(
              content: [const TextBlock('ran')], details: null);
        },
      );

      final events = await runOneCall(
        tool: tool,
        toolCall: ToolCallBlock(
            id: 'c1', name: 'echo', arguments: const {'value': 'hello'}),
        beforeToolCall: (ctx, {isAborted}) async {
          // Upstream: the hook's override is not revalidated, even when it no
          // longer matches the schema.
          ctx.overrideArgs(const {'value': 123});
          return null;
        },
      );

      expect(executedWith, {'value': 123});
      expect(singleResult(events).isError, isFalse);
    });

    test('validation runs in sequential mode too', () async {
      var executed = false;
      var hooked = false;
      final tool = AgentTool(
        name: 'write',
        description: 'writes',
        parameters: const {
          'type': 'object',
          'properties': {
            'path': {'type': 'string'},
          },
          'required': ['path'],
        },
        execute: (id, params, {onUpdate, isAborted}) async {
          executed = true;
          return AgentToolResult(
              content: [const TextBlock('ran')], details: null);
        },
      );

      final events = await runOneCall(
        tool: tool,
        toolCall: ToolCallBlock(id: 'c1', name: 'write', arguments: const {}),
        toolExecution: ToolExecutionMode.sequential,
        beforeToolCall: (ctx, {isAborted}) async {
          hooked = true;
          return null;
        },
      );

      expect(executed, isFalse);
      expect(hooked, isFalse);
      expect(singleResult(events).isError, isTrue);
    });

    test('does not mutate the tool call arguments in the transcript', () async {
      final tool = AgentTool(
        name: 'tag',
        description: 'tags',
        parameters: const {
          'type': 'object',
          'properties': {
            'count': {'type': 'integer'},
          },
          'required': ['count'],
        },
        execute: (id, params, {onUpdate, isAborted}) async =>
            AgentToolResult(content: [const TextBlock('ok')], details: null),
      );
      final rawArguments = <String, dynamic>{'count': '42'};
      final toolCall =
          ToolCallBlock(id: 'c1', name: 'tag', arguments: rawArguments);

      final events = await runOneCall(tool: tool, toolCall: toolCall);

      expect(singleResult(events).isError, isFalse);
      expect(rawArguments, {'count': '42'},
          reason: 'coercion must not rewrite the recorded tool call');
      final start = events.whereType<ToolExecutionStart>().single;
      expect(start.args, {'count': '42'});
    });
  });
}
