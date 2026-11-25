import 'dart:async';

import 'package:test/test.dart';
import 'package:pi/src/types.dart' hide AgentTool;
import 'package:pi/src/tools.dart';
import 'package:pi/src/agent.dart';
import 'package:pi/src/agent_loop.dart';

void main() {
  group('Agent construction', () {
    test('creates with defaults', () {
      final agent = Agent();
      expect(agent.isRunning, isFalse);
      expect(agent.sessionId, isNull);
      expect(agent.state.messages, isEmpty);
      expect(agent.state.tools, isEmpty);
      expect(agent.state.isStreaming, isFalse);
      expect(agent.state.streamingMessage, isNull);
      expect(agent.state.errorMessage, isNull);
    });

    test('creates with individual params', () {
      final model = const Model(
          provider: 'anthropic', modelId: 'claude-3', contextWindow: 200000);
      final agent = Agent(
        model: model,
        systemPrompt: 'You are helpful.',
        sessionId: 'sess-1',
      );
      expect(agent.state.model.modelId, 'claude-3');
      expect(agent.state.systemPrompt, 'You are helpful.');
      expect(agent.sessionId, 'sess-1');
    });

    test('creates with AgentOptions', () {
      final agent = Agent(
        options: AgentOptions(
          model: const Model(
              provider: 'openai', modelId: 'gpt-4', contextWindow: 128000),
          systemPrompt: 'test prompt',
          sessionId: 'sess-opts',
        ),
      );
      expect(agent.state.model.modelId, 'gpt-4');
      expect(agent.state.systemPrompt, 'test prompt');
      expect(agent.sessionId, 'sess-opts');
    });

    test('AgentOptions takes precedence over individual params', () {
      final agent = Agent(
        model: const Model(
            provider: 'openai', modelId: 'gpt-3', contextWindow: 4000),
        options: AgentOptions(
          model: const Model(
              provider: 'anthropic',
              modelId: 'claude-3',
              contextWindow: 200000),
        ),
      );
      expect(agent.state.model.modelId, 'claude-3');
    });

    test('creates with initial messages', () {
      final agent = Agent(
        messages: [UserMessage.text('hello')],
      );
      expect(agent.state.messages, hasLength(1));
    });

    test('creates with initial tools', () {
      final agent = Agent(
        tools: [
          AgentTool(
            name: 'read',
            description: 'Read file',
            parameters: {},
            execute: (id, params, {onUpdate, isAborted}) async =>
                AgentToolResult(
                    content: [const TextBlock('ok')], details: null),
          ),
        ],
      );
      expect(agent.state.tools, hasLength(1));
    });
  });

  group('Agent prompt', () {
    test('accepts string input', () async {
      final events = <AgentEvent>[];
      final agent = Agent(
        streamFn: (ctx, config) => Stream.fromIterable([
          MessageEnd(
            message: AssistantMessage(content: [const TextBlock('response')]),
          ),
        ]),
      );
      agent.subscribe((e) => events.add(e));
      await agent.prompt('hello');
      expect(events, isNotEmpty);
      expect(events.first, isA<AgentStart>());
      expect(events.last, isA<AgentEnd>());
      expect(agent.state.messages, hasLength(2));
    });

    test('accepts List<ContentBlock>', () async {
      final agent = Agent(
        streamFn: (ctx, config) => Stream.fromIterable([
          MessageEnd(
            message: AssistantMessage(content: [const TextBlock('hi')]),
          ),
        ]),
      );
      await agent.prompt([const TextBlock('hello')]);
      expect(agent.state.messages, hasLength(2));
      expect(agent.state.messages.first, isA<UserMessage>());
    });

    test('accepts AgentMessage', () async {
      final agent = Agent(
        streamFn: (ctx, config) => Stream.empty(),
      );
      await agent.prompt(UserMessage.text('hi'));
      expect(agent.state.messages, hasLength(1));
    });

    test('accepts List<AgentMessage>', () async {
      final agent = Agent(
        streamFn: (ctx, config) => Stream.empty(),
      );
      await agent.prompt([UserMessage.text('a'), UserMessage.text('b')]);
      expect(agent.state.messages, hasLength(2));
    });

    test('throws on unsupported input type', () {
      final agent = Agent();
      expect(() => agent.prompt(42), throwsArgumentError);
    });
  });

  group('Agent concurrent rejection', () {
    test('prompt rejects when already running', () async {
      final controller = StreamController<AgentEvent>();
      final agent = Agent(
        streamFn: (ctx, config) => controller.stream,
      );

      final completer = Completer<void>();
      agent.subscribe((e) {
        if (e is AgentEnd && !completer.isCompleted) completer.complete();
      });

      agent.prompt('first');

      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(() => agent.prompt('second'), throwsStateError);

      controller.add(MessageEnd(
        message: AssistantMessage(content: [const TextBlock('done')]),
      ));
      await controller.close();
      await completer.future;
    });

    test('continue_ rejects when already running', () async {
      final controller = StreamController<AgentEvent>();
      final agent = Agent(
        messages: [UserMessage.text('exists')],
        streamFn: (ctx, config) => controller.stream,
      );

      final completer = Completer<void>();
      agent.subscribe((e) {
        if (e is AgentEnd && !completer.isCompleted) completer.complete();
      });

      agent.prompt('first');

      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(() => agent.continue_(), throwsStateError);

      controller.add(MessageEnd(
        message: AssistantMessage(content: [const TextBlock('done')]),
      ));
      await controller.close();
      await completer.future;
    });
  });

  group('Agent continue_', () {
    test('throws on empty transcript', () {
      final agent = Agent();
      expect(() => agent.continue_(), throwsStateError);
    });

    test('continues from existing messages', () async {
      final events = <AgentEvent>[];
      final agent = Agent(
        messages: [UserMessage.text('hello')],
        streamFn: (ctx, config) => Stream.fromIterable([
          MessageEnd(
            message: AssistantMessage(content: [const TextBlock('world')]),
          ),
        ]),
      );
      agent.subscribe((e) => events.add(e));
      await agent.continue_();
      expect(events.any((e) => e is AgentStart), isTrue);
      expect(agent.state.messages, hasLength(2));
    });
  });

  group('Agent event subscription', () {
    test('subscribe receives events', () async {
      final events = <AgentEvent>[];
      final agent = Agent(
        streamFn: (ctx, config) => Stream.fromIterable([
          MessageEnd(
            message: AssistantMessage(content: [const TextBlock('hi')]),
          ),
        ]),
      );
      agent.subscribe((e) => events.add(e));
      await agent.prompt('test');
      expect(events, isNotEmpty);
    });

    test('unsubscribe stops receiving events', () async {
      final events = <AgentEvent>[];
      final agent = Agent(
        streamFn: (ctx, config) => Stream.fromIterable([
          MessageEnd(
            message: AssistantMessage(content: [const TextBlock('hi')]),
          ),
        ]),
      );
      final unsub = agent.subscribe((e) => events.add(e));
      unsub();

      await agent.prompt('test');
      expect(events, isEmpty);
    });

    test('multiple listeners all receive events', () async {
      final events1 = <AgentEvent>[];
      final events2 = <AgentEvent>[];
      final agent = Agent(
        streamFn: (ctx, config) => Stream.fromIterable([
          MessageEnd(
            message: AssistantMessage(content: [const TextBlock('hi')]),
          ),
        ]),
      );
      agent.subscribe((e) => events1.add(e));
      agent.subscribe((e) => events2.add(e));
      await agent.prompt('test');
      expect(events1, isNotEmpty);
      expect(events2, isNotEmpty);
      expect(events1.length, events2.length);
    });
  });

  group('Agent abort', () {
    test('abort stops event processing', () async {
      final events = <AgentEvent>[];
      final controller = StreamController<AgentEvent>();

      final agent = Agent(
        streamFn: (ctx, config) => controller.stream,
      );
      agent.subscribe((e) => events.add(e));

      agent.prompt('go');
      await Future<void>.delayed(const Duration(milliseconds: 5));

      controller.add(MessageEnd(
        message: AssistantMessage(content: [const TextBlock('first')]),
      ));

      await Future<void>.delayed(const Duration(milliseconds: 5));

      agent.abort();

      controller.add(MessageEnd(
        message: AssistantMessage(content: [const TextBlock('second')]),
      ));

      await controller.close();
      await agent.waitForIdle();

      // The post-abort "second" message is never processed, and exactly one
      // abort outcome is added on top of the message that preceded the abort.
      final ends = events.whereType<MessageEnd>().toList();
      final texts =
          ends.map((e) => (e.message as AssistantMessage).text).toList();
      expect(texts, isNot(contains('second')));
      expect(texts, contains('first'));
      expect(ends, hasLength(2));

      // The abort outcome is recorded, not dropped: a consumer can tell an
      // aborted run from an empty one (upstream handleRunFailure,
      // agent.ts:540-556).
      final last = agent.state.messages.last as AssistantMessage;
      expect(last.stopReason, StopReason.aborted);
      expect(last.errorMessage, 'Request aborted');
      expect(last.content, isEmpty);
      expect(agent.state.errorMessage, 'Request aborted');
    });
  });

  group('Agent reset', () {
    test('clears messages and state', () async {
      final agent = Agent(
        streamFn: (ctx, config) => Stream.fromIterable([
          MessageEnd(
            message: AssistantMessage(content: [const TextBlock('hi')]),
          ),
        ]),
      );
      await agent.prompt('hello');
      expect(agent.state.messages, isNotEmpty);

      agent.reset();
      expect(agent.state.messages, isEmpty);
      expect(agent.state.errorMessage, isNull);
      expect(agent.state.isStreaming, isFalse);
      expect(agent.state.streamingMessage, isNull);
      expect(agent.state.pendingToolCalls, isEmpty);
    });

    test('clears queues', () async {
      final agent = Agent();
      agent.steer(UserMessage.text('steer'));
      agent.followUp(UserMessage.text('follow'));
      expect(agent.hasQueuedMessages(), isTrue);

      agent.reset();
      expect(agent.hasQueuedMessages(), isFalse);
    });
  });

  group('Agent steering and follow-up', () {
    test('steer queues message', () {
      final agent = Agent();
      agent.steer(UserMessage.text('correction'));
      expect(agent.hasQueuedMessages(), isTrue);
    });

    test('followUp queues message', () {
      final agent = Agent();
      agent.followUp(UserMessage.text('next'));
      expect(agent.hasQueuedMessages(), isTrue);
    });

    test('clearSteeringQueue works', () {
      final agent = Agent();
      agent.steer(UserMessage.text('a'));
      agent.followUp(UserMessage.text('b'));
      agent.clearSteeringQueue();
      expect(agent.hasQueuedMessages(), isTrue);
    });

    test('clearFollowUpQueue works', () {
      final agent = Agent();
      agent.steer(UserMessage.text('a'));
      agent.followUp(UserMessage.text('b'));
      agent.clearFollowUpQueue();
      expect(agent.hasQueuedMessages(), isTrue);
    });

    test('clearAllQueues works', () {
      final agent = Agent();
      agent.steer(UserMessage.text('a'));
      agent.followUp(UserMessage.text('b'));
      agent.clearAllQueues();
      expect(agent.hasQueuedMessages(), isFalse);
    });
  });

  group('Agent event handling', () {
    test('MessageStart sets streamingMessage', () async {
      final agent = Agent(
        streamFn: (ctx, config) => Stream.fromIterable([
          MessageStart(
            message: AssistantMessage(content: [const TextBlock('')]),
          ),
          MessageEnd(
            message: AssistantMessage(content: [const TextBlock('hi')]),
          ),
        ]),
      );

      AgentMessage? captured;
      agent.subscribe((e) {
        if (e is MessageStart) captured = e.message;
      });

      await agent.prompt('test');
      expect(captured, isNotNull);
    });

    test('MessageEnd adds to messages', () async {
      final agent = Agent(
        streamFn: (ctx, config) => Stream.fromIterable([
          MessageEnd(
            message: AssistantMessage(content: [const TextBlock('done')]),
          ),
        ]),
      );
      await agent.prompt('test');
      expect(
        agent.state.messages.last,
        isA<AssistantMessage>(),
      );
    });

    test('ToolExecutionStart/End tracks pending calls', () async {
      final agent = Agent(
        streamFn: (ctx, config) => Stream.fromIterable([
          const ToolExecutionStart(
            toolCallId: 'tc1',
            toolName: 'read',
            args: {},
          ),
          const ToolExecutionEnd(
            toolCallId: 'tc1',
            toolName: 'read',
            args: {},
            result: 'ok',
            isError: false,
          ),
          MessageEnd(
            message: AssistantMessage(content: [const TextBlock('done')]),
          ),
        ]),
      );

      final pendingIds = <String>{};
      agent.subscribe((e) {
        if (e is ToolExecutionStart) {
          pendingIds.add(e.toolCallId);
        }
      });

      await agent.prompt('test');
      expect(pendingIds, contains('tc1'));
      expect(agent.state.pendingToolCalls, isEmpty);
    });
  });

  group('Agent error handling', () {
    test('stream error sets errorMessage', () async {
      final agent = Agent(
        streamFn: (ctx, config) => Stream.error(Exception('boom')),
      );
      await agent.prompt('test');
      expect(agent.state.errorMessage, contains('boom'));
    });

    test('a provider error outcome sets state.errorMessage (#6)', () async {
      // `loopStreamFn` drives the real loop, so this covers the whole path:
      // provider failure -> loop termination -> AgentState mirror.
      final agent = Agent(
        loopStreamFn: (
                {required context,
                required config,
                required apiKey,
                required abortSignal}) =>
            Stream.fromIterable([
          MessageEnd(
            message: const AssistantMessage(
              content: [],
              stopReason: StopReason.error,
              errorMessage: '401 - unauthorized',
            ),
          ),
        ]),
      );

      final types = <String>[];
      agent.subscribe((e) => types.add(e.runtimeType.toString()));
      await agent.prompt('test');

      // The failure is reported as an error outcome, not model text.
      final last = agent.state.messages.last as AssistantMessage;
      expect(last.stopReason, StopReason.error);
      expect(last.errorMessage, '401 - unauthorized');
      expect(last.text, isEmpty);
      // AgentState mirrors the terminal message's diagnostic.
      expect(agent.state.errorMessage, '401 - unauthorized');
      expect(types, contains('TurnEnd'));
      expect(types.last, 'AgentEnd');
    });

    test('agent is not running after error', () async {
      final agent = Agent(
        streamFn: (ctx, config) => Stream.error(Exception('fail')),
      );
      await agent.prompt('test');
      expect(agent.isRunning, isFalse);
      expect(agent.state.isStreaming, isFalse);
    });

    test('a throwing default-path stream surfaces a structured error (#5)',
        () async {
      // The real conversation path runs through `_defaultStreamFn` ->
      // `turnLoop` -> `_streamFromAsync`. A loop-body failure there used to be
      // swallowed, so the caller saw a normal-looking completion with no error.
      final agent = Agent(
        loopStreamFn: (
                {required context,
                required config,
                required apiKey,
                required abortSignal}) =>
            Stream.error(Exception('provider exploded')),
      );

      final events = <AgentEvent>[];
      agent.subscribe(events.add);
      await agent.prompt('hello');

      // The failure is a structured assistant message, not model text.
      final last = agent.state.messages.last as AssistantMessage;
      expect(last.stopReason, StopReason.error);
      expect(last.errorMessage, contains('provider exploded'));
      expect(last.text, isEmpty);
      expect(agent.state.errorMessage, contains('provider exploded'));

      // The upstream lifecycle sequence is preserved (agent.ts:542-557): the
      // error message is emitted, the turn closes, then the agent ends.
      final types = events.map((e) => e.runtimeType.toString()).toList();
      expect(types.first, 'AgentStart');
      expect(types.last, 'AgentEnd');
      expect(types, contains('TurnEnd'));
      final endMessages =
          events.whereType<MessageEnd>().map((e) => e.message).toList();
      expect(endMessages.last, isA<AssistantMessage>());
      expect(
          (endMessages.last as AssistantMessage).stopReason, StopReason.error);
    });

    test('a failure during an aborted run uses the aborted stop reason (#5)',
        () async {
      // Abort differentiation: the same failure path tags the terminal message
      // `aborted` (not `error`) when the run was aborted (agent.ts:550).
      late Agent agent;
      agent = Agent(
        streamFn: (ctx, config) async* {
          agent.abort();
          throw Exception('aborted mid-stream');
        },
      );
      await agent.prompt('hello');

      final last = agent.state.messages.last as AssistantMessage;
      expect(last.stopReason, StopReason.aborted);
      expect(last.errorMessage, contains('aborted mid-stream'));
      expect(agent.state.errorMessage, contains('aborted mid-stream'));
    });

    test('a listener throwing at message_start cannot hide the failure (#5)',
        () async {
      // The failure sequence used to reduce state only after awaiting the
      // listeners, so a listener that threw at `message_start` skipped the
      // `MessageEnd` reduction and dropped `message_end`/`turn_end`/`agent_end`:
      // the run ended with `state.errorMessage` null — invisible in exactly the
      // state this change makes observable. Reducing first makes the recording
      // unconditional.
      final agent = Agent(
        streamFn: (ctx, config) => Stream.error(Exception('provider exploded')),
      );
      var messageStarts = 0;
      agent.subscribe((event) {
        if (event is MessageStart && messageStarts++ == 0) {
          throw StateError('listener exploded at message_start');
        }
      });

      // The listener's own error still propagates to the caller.
      await expectLater(agent.prompt('hello'), throwsStateError);

      // The failure is recorded anyway.
      expect(agent.state.errorMessage, contains('provider exploded'));
      final last = agent.state.messages.last as AssistantMessage;
      expect(last.stopReason, StopReason.error);
      expect(last.errorMessage, contains('provider exploded'));
    });
  });

  group('Agent setters', () {
    test('toolExecution setter', () {
      final agent = Agent();
      agent.toolExecution = ToolExecutionMode.sequential;
    });

    test('steeringMode setter', () {
      final agent = Agent();
      agent.steeringMode = QueueMode.all;
      expect(agent.steeringMode, QueueMode.all);
    });

    test('followUpMode setter', () {
      final agent = Agent();
      agent.followUpMode = QueueMode.all;
      expect(agent.followUpMode, QueueMode.all);
    });

    test('convertToLlm setter', () {
      final agent = Agent();
      agent.convertToLlm = (msgs) async => [];
    });

    test('transformContext setter', () {
      final agent = Agent();
      agent.transformContext = (msgs, {isAborted}) async => msgs;
    });

    test('streamFn setter', () {
      final agent = Agent();
      agent.streamFn = (ctx, config) => Stream.empty();
    });

    test('getApiKey setter', () {
      final agent = Agent();
      agent.getApiKey = (provider) async => 'key';
    });

    test('beforeToolCall setter', () {
      final agent = Agent();
      agent.beforeToolCall = (ctx, {isAborted}) async => null;
    });

    test('afterToolCall setter', () {
      final agent = Agent();
      agent.afterToolCall = (ctx, {isAborted}) async => null;
    });
  });

  // Regression tests for arrrrny/pi#2: SteeringMode/FollowUpMode (now a shared
  // QueueMode) must affect queue draining; one-at-a-time drains only the
  // oldest message, all drains every message. Steering/follow-up draining only
  // happens through the real turn loop, so these drive the Agent's
  // `loopStreamFn` (the per-turn streamer) rather than `streamFn`.
  group('Agent queue modes (issue #2)', () {
    AgentMessage userMsg(String text) => UserMessage.text(text);

    String textOf(AgentMessage m) {
      if (m is UserMessage) {
        return m.content.whereType<TextBlock>().map((b) => b.text).join();
      }
      if (m is AssistantMessage) {
        return m.text;
      }
      return '';
    }

    // A per-turn streamer: the first turn requests a single tool call (so the
    // loop runs a second turn and reaches a steering/follow-up drain point),
    // every later turn ends.
    LoopStreamFn scriptedLoop({required bool withTool}) {
      var turn = 0;
      return ({
        required context,
        required config,
        required apiKey,
        required abortSignal,
      }) {
        final current = turn++;
        if (withTool && current == 0) {
          const call = MessageEnd(
              message: AssistantMessage(content: [
            ToolCallBlock(id: 'tc', name: 'noop', arguments: {})
          ], stopReason: StopReason.toolUse));
          return Stream<AgentEvent>.fromIterable(const [
            MessageStart(
                message: AssistantMessage(content: [
              ToolCallBlock(id: 'tc', name: 'noop', arguments: {})
            ], stopReason: StopReason.toolUse)),
            call,
          ]);
        }
        return Stream<AgentEvent>.fromIterable(const [
          MessageStart(
              message: AssistantMessage(
                  content: [], stopReason: StopReason.endTurn)),
          MessageEnd(
              message: AssistantMessage(
                  content: [], stopReason: StopReason.endTurn)),
        ]);
      };
    }

    Agent makeAgent(QueueMode mode,
        {bool withTool = true, List<AgentTool<dynamic, dynamic>>? tools}) {
      return Agent(
        steeringMode: mode,
        followUpMode: mode,
        tools: withTool
            ? (tools ??
                [
                  AgentTool(
                    name: 'noop',
                    description: 'noop',
                    parameters: {},
                    execute: (id, params, {onUpdate, isAborted}) async =>
                        AgentToolResult(
                            content: [const TextBlock('ok')], details: null),
                  ),
                ])
            : null,
        loopStreamFn: scriptedLoop(withTool: withTool),
      );
    }

    List<String> userTexts(Agent agent) => agent.state.messages
        .whereType<UserMessage>()
        .map(textOf)
        .where((t) => t.isNotEmpty)
        .toList();

    test('one-at-a-time steering delivers across turns, one per drain',
        () async {
      final agent = makeAgent(QueueMode.oneAtATime);
      agent.steer(userMsg('first'));
      agent.steer(userMsg('second'));
      await agent.prompt('go');

      // The loop drains once before turn 1 and once after the tool turn, so the
      // two messages arrive one per drain across turns — not both in one turn.
      expect(userTexts(agent), ['go', 'first', 'second']);
      expect(agent.hasQueuedMessages(), isFalse);
    });

    test('one-at-a-time drains a single message per drain point', () async {
      // A streamer that never makes a tool call: every drain point delivers one
      // more queued message, so the two arrive in separate turns instead of both
      // in the first one.
      var turns = 0;
      final agent = Agent(
        steeringMode: QueueMode.oneAtATime,
        loopStreamFn: ({
          required context,
          required config,
          required apiKey,
          required abortSignal,
        }) {
          turns++;
          return Stream<AgentEvent>.fromIterable(const [
            MessageStart(
                message: AssistantMessage(
                    content: [], stopReason: StopReason.endTurn)),
            MessageEnd(
                message: AssistantMessage(
                    content: [], stopReason: StopReason.endTurn)),
          ]);
        },
      );
      agent.steer(userMsg('first'));
      agent.steer(userMsg('second'));
      await agent.prompt('go');

      // One message per drain, one turn per message: 'second' is not stranded.
      expect(userTexts(agent), ['go', 'first', 'second']);
      expect(turns, 2);
      expect(agent.hasQueuedMessages(), isFalse);
    });

    test('all steering drains every message in one turn', () async {
      final agent = makeAgent(QueueMode.all);
      agent.steer(userMsg('first'));
      agent.steer(userMsg('second'));
      await agent.prompt('go');

      expect(userTexts(agent), ['go', 'first', 'second']);
      expect(agent.hasQueuedMessages(), isFalse);
    });

    test('one-at-a-time follow-up: queue retains the rest', () async {
      // Follow-up drains at the loop's continuation point (reached via a tool
      // turn); one-at-a-time must leave the second message queued.
      final agent = makeAgent(QueueMode.oneAtATime);
      agent.followUp(userMsg('fu1'));
      agent.followUp(userMsg('fu2'));
      // Peek honors the follow-up queue's own mode.
      expect(agent.peekQueuedMessages().map(textOf), ['fu1']);
      agent.followUpMode = QueueMode.all;
      expect(agent.peekQueuedMessages().map(textOf), ['fu1', 'fu2']);
    });

    test('runtime mode switch affects the next drain', () async {
      final agent = makeAgent(QueueMode.oneAtATime);
      agent.steer(userMsg('first'));
      agent.steer(userMsg('second'));
      // Switch to all before the drain.
      agent.steeringMode = QueueMode.all;
      await agent.prompt('go');

      expect(userTexts(agent), ['go', 'first', 'second']);
      expect(agent.hasQueuedMessages(), isFalse);
    });

    test('queue clearing is reflected in hasQueuedMessages', () {
      final agent = Agent();
      agent.steer(userMsg('a'));
      agent.followUp(userMsg('b'));
      expect(agent.hasQueuedMessages(), isTrue);

      agent.clearSteeringQueue();
      expect(agent.hasQueuedMessages(), isTrue);
      agent.clearFollowUpQueue();
      expect(agent.hasQueuedMessages(), isFalse);
    });

    test('clearAllQueues empties both queues', () {
      final agent = Agent();
      agent.steer(userMsg('a'));
      agent.followUp(userMsg('b'));
      agent.clearAllQueues();
      expect(agent.hasQueuedMessages(), isFalse);
    });

    test('peekQueuedMessages prefers steering and does not consume', () {
      final agent = Agent();
      agent.steer(userMsg('s1'));
      agent.followUp(userMsg('f1'));
      final peeked = agent.peekQueuedMessages();
      expect(peeked.map(textOf), ['s1']);
      // Non-consuming: still queued.
      expect(agent.hasQueuedMessages(), isTrue);
      expect(agent.peekQueuedMessages().map(textOf), ['s1']);
    });

    test('peekQueuedMessages falls back to follow-up', () {
      final agent = Agent();
      agent.followUp(userMsg('f1'));
      agent.followUp(userMsg('f2'));
      // Default one-at-a-time -> only first follow-up.
      expect(agent.peekQueuedMessages().map(textOf), ['f1']);
    });

    test('peekQueuedMessages honors all mode', () {
      final agent = Agent(followUpMode: QueueMode.all);
      agent.followUp(userMsg('f1'));
      agent.followUp(userMsg('f2'));
      expect(agent.peekQueuedMessages().map(textOf), ['f1', 'f2']);
    });

    test('steering precedence over follow-up', () async {
      final agent = makeAgent(QueueMode.all);
      agent.steer(userMsg('steer'));
      agent.followUp(userMsg('follow'));
      await agent.prompt('go');

      // Steering drains first; the follow-up is then delivered in its own turn
      // rather than being stranded at the end of the run.
      final users = userTexts(agent);
      expect(users.first, 'go');
      expect(users.contains('steer'), isTrue);
      expect(users.contains('follow'), isTrue);
      expect(users.indexOf('steer'), lessThan(users.indexOf('follow')));
      expect(agent.hasQueuedMessages(), isFalse);
    });

    test('continuation from an assistant message drains queued steering',
        () async {
      final agent = makeAgent(QueueMode.oneAtATime, withTool: false);
      await agent.prompt('seed');
      // Last message is now an assistant endTurn message.
      agent.steer(userMsg('steer'));
      await agent.continue_();

      final users = userTexts(agent);
      expect(users.contains('steer'), isTrue);
    });

    test('constructor configures mode via AgentOptions', () {
      final agent = Agent(
          options: const AgentOptions(
              steeringMode: QueueMode.all, followUpMode: QueueMode.all));
      expect(agent.steeringMode, QueueMode.all);
      expect(agent.followUpMode, QueueMode.all);
    });

    test('constructor configures mode via individual params', () {
      final agent =
          Agent(steeringMode: QueueMode.all, followUpMode: QueueMode.all);
      expect(agent.steeringMode, QueueMode.all);
      expect(agent.followUpMode, QueueMode.all);
    });

    // Review fix on #16: the drain closures used to be installed only when the
    // queue was already non-empty at config-build time, so a message queued
    // DURING the run (the normal case) had no drain path and sat forever.
    test('steer() from a tool body is delivered in the same run', () async {
      late Agent agent;
      var turn = 0;
      agent = Agent(
        steeringMode: QueueMode.oneAtATime,
        tools: [
          AgentTool(
            name: 'noop',
            description: 'noop',
            parameters: {},
            execute: (id, params, {onUpdate, isAborted}) async {
              agent.steer(userMsg('midrun'));
              return AgentToolResult(
                  content: [const TextBlock('ok')], details: null);
            },
          ),
        ],
        loopStreamFn: ({
          required context,
          required config,
          required apiKey,
          required abortSignal,
        }) {
          if (turn++ == 0) {
            return Stream<AgentEvent>.fromIterable(const [
              MessageStart(
                  message: AssistantMessage(content: [
                ToolCallBlock(id: 'tc', name: 'noop', arguments: {})
              ], stopReason: StopReason.toolUse)),
              MessageEnd(
                  message: AssistantMessage(content: [
                ToolCallBlock(id: 'tc', name: 'noop', arguments: {})
              ], stopReason: StopReason.toolUse)),
            ]);
          }
          return Stream<AgentEvent>.fromIterable(const [
            MessageStart(
                message: AssistantMessage(
                    content: [], stopReason: StopReason.endTurn)),
            MessageEnd(
                message: AssistantMessage(
                    content: [], stopReason: StopReason.endTurn)),
          ]);
        },
      );

      await agent.prompt('go');

      // The queued message arrives after the turn that queued it, not never.
      expect(userTexts(agent), ['go', 'midrun']);
      expect(agent.hasQueuedMessages(), isFalse);
    });

    // Review fix on #16: `followUp()` queued outside an explicit
    // shouldStopAfterTurn was never delivered — the loop broke before the
    // follow-up drain point.
    test('followUp() is delivered without a shouldStopAfterTurn override',
        () async {
      final agent = makeAgent(QueueMode.all);
      agent.followUp(userMsg('follow'));
      await agent.prompt('go');

      expect(userTexts(agent), ['go', 'follow']);
      expect(agent.hasQueuedMessages(), isFalse);
    });
  });
}
