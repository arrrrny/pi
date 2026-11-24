/// Low-level agent loop.
///
/// Faithful Dart port of pi's `agent-loop.ts`: drives the conversation turn by
/// turn — calling the LLM, executing any tool calls (parallel or sequential),
/// running the before/after tool hooks, and honoring steering, follow-up, and
/// abort — emitting [AgentEvent]s as it goes.
library;

import 'dart:async';

import 'types.dart' hide AgentTool;
import 'tools.dart';
import 'llm_client.dart';

/// The streaming function the loop calls once per assistant turn.
///
/// Defaults to [streamLLM] (the OpenAI-compatible client). Tests and embedders
/// inject a fake to drive the loop without a network call.
typedef LoopStreamFn = Stream<AgentEvent> Function({
  required AgentContext context,
  required AgentLoopConfig config,
  required String apiKey,
  required Completer<void>? abortSignal,
});

/// Runs the turn loop and emits turn-level events (everything except
/// `agent_start`/`agent_end`), which the [Agent] wraps with its own lifecycle
/// events. This is the default path a real conversation takes.
Stream<AgentEvent> turnLoop(
  AgentContext context,
  AgentLoopConfig config, {
  LoopStreamFn? streamFn,
  Completer<void>? abortSignal,
}) =>
    _streamFromAsync(
      (emit) => _runLoop(
        _clone(context),
        <AgentMessage>[],
        config,
        streamFn ?? streamLLM,
        abortSignal,
        emit,
      ),
    );

/// Starts a new agent loop with prompt messages, emitting the full event set
/// (`agent_start` … `agent_end`).
Stream<AgentEvent> agentLoop(
  AgentContext context,
  AgentLoopConfig config, {
  List<AgentMessage>? prompts,
  LoopStreamFn? streamFn,
  Completer<void>? abortSignal,
}) =>
    _streamFromAsync((emit) async {
      final initial = prompts ?? <AgentMessage>[];
      await emit(const AgentStart());
      final newMessages = <AgentMessage>[...initial];
      final currentContext = _withMessages(context, initial);
      for (final m in initial) {
        await emit(MessageStart(message: m));
        await emit(MessageEnd(message: m));
      }
      final result = await _runLoop(
        currentContext,
        newMessages,
        config,
        streamFn ?? streamLLM,
        abortSignal,
        emit,
      );
      await emit(AgentEnd(messages: result));
    });

/// Continues a loop from existing context without adding a prompt message.
Stream<AgentEvent> agentLoopContinue(
  AgentContext context,
  AgentLoopConfig config, {
  LoopStreamFn? streamFn,
  Completer<void>? abortSignal,
}) {
  if (context.messages.isEmpty) {
    throw StateError('Cannot continue: no messages in context');
  }
  return _streamFromAsync((emit) async {
    await emit(const AgentStart());
    final newMessages = <AgentMessage>[];
    final result = await _runLoop(
      _clone(context),
      newMessages,
      config,
      streamFn ?? streamLLM,
      abortSignal,
      emit,
    );
    await emit(AgentEnd(messages: result));
  });
}

/// Async wrapper that collects the final messages from [agentLoop].
Future<List<AgentMessage>> runAgentLoop(
  AgentContext context,
  AgentLoopConfig config, {
  List<AgentMessage>? prompts,
  LoopStreamFn? streamFn,
  Completer<void>? abortSignal,
}) async {
  final messages = <AgentMessage>[];
  await for (final event in agentLoop(
    context,
    config,
    prompts: prompts,
    streamFn: streamFn,
    abortSignal: abortSignal,
  )) {
    if (event case AgentEnd(messages: final m)) {
      messages.addAll(m);
    }
  }
  return messages;
}

/// Async wrapper that collects the final messages from [agentLoopContinue].
Future<List<AgentMessage>> runAgentLoopContinue(
  AgentContext context,
  AgentLoopConfig config, {
  LoopStreamFn? streamFn,
  Completer<void>? abortSignal,
}) async {
  final messages = <AgentMessage>[];
  await for (final event in agentLoopContinue(
    context,
    config,
    streamFn: streamFn,
    abortSignal: abortSignal,
  )) {
    if (event case AgentEnd(messages: final m)) {
      messages.addAll(m);
    }
  }
  return messages;
}

/// Core turn loop. Mutates [newMessages] and the working context, emitting
/// events through [emit], and returns the messages produced this run.
Future<List<AgentMessage>> _runLoop(
  AgentContext initialContext,
  List<AgentMessage> newMessages,
  AgentLoopConfig config,
  LoopStreamFn streamFn,
  Completer<void>? abortSignal,
  Future<void> Function(AgentEvent) emit,
) async {
  var context = initialContext;
  var pending = await config.getSteeringMessages?.call() ?? <AgentMessage>[];
  var turnCount = 0;

  while (true) {
    if (abortSignal?.isCompleted ?? false) break;

    // Inject any queued steering/follow-up messages before the assistant turn.
    for (final m in pending) {
      await emit(MessageStart(message: m));
      await emit(MessageEnd(message: m));
      context = _withMessages(context, [m]);
      newMessages.add(m);
    }
    pending = <AgentMessage>[];

    turnCount++;
    await emit(const TurnStart());

    final assistant =
        await _streamAssistant(context, config, streamFn, abortSignal, emit);
    context = _withMessages(context, [assistant]);
    newMessages.add(assistant);

    if (isTerminalStopReason(assistant.stopReason) ||
        (abortSignal?.isCompleted ?? false)) {
      await emit(TurnEnd(message: assistant, toolResults: const []));
      return newMessages;
    }

    final toolCalls = assistant.toolCalls;
    final toolResults = <ToolResultMessage>[];
    var allTerminated = false;
    if (toolCalls.isNotEmpty) {
      final batch = assistant.stopReason == StopReason.maxTokens
          ? await _failTruncatedToolCalls(toolCalls, emit)
          : await _executeToolCalls(
              context, assistant, config, abortSignal, emit);
      toolResults.addAll(batch.results);
      allTerminated = batch.terminate;
      for (final r in toolResults) {
        context = _withMessages(context, [r]);
        newMessages.add(r);
      }
    }

    await emit(TurnEnd(message: assistant, toolResults: toolResults));

    // Tool calls always continue the loop so their results feed the next turn,
    // unless every call asked to terminate.
    if (toolCalls.isNotEmpty && !allTerminated) {
      pending = await config.getSteeringMessages?.call() ??
          <AgentMessage>[];
      continue;
    }

    // An explicit `true` ends the run; an absent hook (the [Agent] default)
    // decides nothing and falls through to the queue check below.
    final shouldStop = config.shouldStopAfterTurn?.call(
          ShouldStopAfterTurnContext(
            lastMessage: assistant,
            toolResults: toolResults,
            turnCount: turnCount,
          ),
        );
    if (shouldStop ?? false) break;

    // The agent would stop here, so drain what arrived while it was working:
    // steering first, then follow-up (upstream `agent-loop.ts:293-311`). Each
    // non-empty drain buys the message its own turn; only when both queues are
    // empty does the run end.
    final steering =
        await config.getSteeringMessages?.call() ?? <AgentMessage>[];
    if (steering.isNotEmpty) {
      pending = steering;
      continue;
    }
    final followUp =
        await config.getFollowUpMessages?.call() ?? <AgentMessage>[];
    if (followUp.isNotEmpty) {
      pending = followUp;
      continue;
    }
    break;
  }

  return newMessages;
}

/// Streams one assistant response, relaying message events and returning the
/// final [AssistantMessage].
Future<AssistantMessage> _streamAssistant(
  AgentContext context,
  AgentLoopConfig config,
  LoopStreamFn streamFn,
  Completer<void>? abortSignal,
  Future<void> Function(AgentEvent) emit,
) async {
  var effectiveContext = context;
  if (config.transformContext != null) {
    final transformed = await config.transformContext!(
      context.messages,
      isAborted: () => abortSignal?.isCompleted ?? false,
    );
    effectiveContext = _withMessages(context, transformed);
  }

  final apiKey =
      await config.getApiKey?.call(config.model.provider) ?? '';

  final stream = streamFn(
    context: effectiveContext,
    config: config,
    apiKey: apiKey,
    abortSignal: abortSignal,
  );

  var started = false;
  AssistantMessage? finalMessage;

  await for (final event in stream) {
    switch (event) {
      case MessageStart(message: final m):
        started = true;
        await emit(MessageStart(message: m));
      case MessageUpdate(message: final m):
        if (!started) {
          started = true;
          await emit(MessageStart(message: m));
        }
        await emit(MessageUpdate(message: m));
      case MessageEnd(message: final m):
        if (!started) {
          started = true;
          await emit(MessageStart(message: m));
        }
        finalMessage = m is AssistantMessage ? m : _asAssistant(m);
        await emit(MessageEnd(message: finalMessage));
      default:
        await emit(event);
    }
  }

  return finalMessage ??
      AssistantMessage(
        content: [const TextBlock('')],
        stopReason: StopReason.endTurn,
      );
}

/// Executes the tool calls of [assistantMessage] in parallel or sequentially.
Future<_ToolBatch> _executeToolCalls(
  AgentContext context,
  AssistantMessage assistantMessage,
  AgentLoopConfig config,
  Completer<void>? abortSignal,
  Future<void> Function(AgentEvent) emit,
) {
  final toolCalls = assistantMessage.toolCalls;
  final tools = (context.tools ?? const <dynamic>[])
      .cast<AgentTool<dynamic, dynamic>>();
  final hasSequential = toolCalls.any((tc) => tools
      .any((t) => t.name == tc.name && t.executionMode == ToolExecutionMode.sequential));
  if (config.toolExecution == ToolExecutionMode.sequential || hasSequential) {
    return _executeSequential(
        context, assistantMessage, toolCalls, config, abortSignal, emit);
  }
  return _executeParallel(
      context, assistantMessage, toolCalls, config, abortSignal, emit);
}

Future<_ToolBatch> _executeSequential(
  AgentContext context,
  AssistantMessage assistantMessage,
  List<ToolCallBlock> toolCalls,
  AgentLoopConfig config,
  Completer<void>? abortSignal,
  Future<void> Function(AgentEvent) emit,
) async {
  final finalized = <_Finalized>[];
  for (final toolCall in toolCalls) {
    await emit(ToolExecutionStart(
      toolCallId: toolCall.id,
      toolName: toolCall.name,
      args: toolCall.arguments,
    ));
    final f = await _runOneToolCall(
        context, assistantMessage, toolCall, config, abortSignal, emit);
    await _emitToolEnd(f, emit);
    finalized.add(f);
  }
  return _ToolBatch(
    [for (final f in finalized) _toolResultMessage(f)],
    _allTerminated(finalized),
  );
}

Future<_ToolBatch> _executeParallel(
  AgentContext context,
  AssistantMessage assistantMessage,
  List<ToolCallBlock> toolCalls,
  AgentLoopConfig config,
  Completer<void>? abortSignal,
  Future<void> Function(AgentEvent) emit,
) async {
  // Prepare (and run the beforeToolCall hook for) every call first, in order,
  // then execute them concurrently, then emit results in source order.
  final finalized = <_Finalized>[];
  final pendingExecutions = <Future<_Finalized>>[];

  for (final toolCall in toolCalls) {
    await emit(ToolExecutionStart(
      toolCallId: toolCall.id,
      toolName: toolCall.name,
      args: toolCall.arguments,
    ));
    final prepared = await _prepareToolCall(
        context, assistantMessage, toolCall, config, abortSignal);
    if (prepared.isImmediate) {
      final f = _Finalized(toolCall, prepared.result!, prepared.isError!);
      await _emitToolEnd(f, emit);
      finalized.add(f);
    } else {
      pendingExecutions.add(_executePrepared(
        context,
        assistantMessage,
        prepared.prepared!,
        config,
        abortSignal,
        emit,
        toolCall,
      ));
    }
  }

  final executed = await Future.wait(pendingExecutions);
  for (final f in executed) {
    await _emitToolEnd(f, emit);
    finalized.add(f);
  }

  return _ToolBatch(
    [for (final f in finalized) _toolResultMessage(f)],
    _allTerminated(finalized),
  );
}

/// Runs one tool call end to end (prepare → execute → afterToolCall hook).
Future<_Finalized> _runOneToolCall(
  AgentContext context,
  AssistantMessage assistantMessage,
  ToolCallBlock toolCall,
  AgentLoopConfig config,
  Completer<void>? abortSignal,
  Future<void> Function(AgentEvent) emit,
) async {
  final prepared =
      await _prepareToolCall(context, assistantMessage, toolCall, config, abortSignal);
  if (prepared.isImmediate) {
    return _Finalized(toolCall, prepared.result!, prepared.isError!);
  }
  return _executePrepared(
    context,
    assistantMessage,
    prepared.prepared!,
    config,
    abortSignal,
    emit,
    toolCall,
  );
}

/// Prepares a call: resolves the tool, applies argument preparation, validates,
/// and runs the `beforeToolCall` hook.
Future<_Prepared> _prepareToolCall(
  AgentContext context,
  AssistantMessage assistantMessage,
  ToolCallBlock toolCall,
  AgentLoopConfig config,
  Completer<void>? abortSignal,
) async {
  if (abortSignal?.isCompleted ?? false) {
    return _Prepared.immediate(_errorResult('Operation aborted'));
  }

  final tools = (context.tools ?? const <dynamic>[])
      .cast<AgentTool<dynamic, dynamic>>();
  AgentTool<dynamic, dynamic>? tool;
  for (final t in tools) {
    if (t.name == toolCall.name) {
      tool = t;
      break;
    }
  }
  if (tool == null) {
    return _Prepared.immediate(_errorResult('Tool ${toolCall.name} not found'));
  }

  // Fail closed before argument preparation and the user's hook: a call whose
  // argument text did not parse as a JSON object must never reach them.
  final argumentsError = toolCall.argumentsError;
  if (argumentsError != null) {
    return _Prepared.immediate(
        _errorResult('Invalid arguments for tool "${toolCall.name}": '
            '$argumentsError'));
  }

  try {
    var args = toolCall.arguments;
    final prepare = tool.prepareArguments;
    if (prepare != null) {
      final preparedArgs = prepare(args);
      if (preparedArgs != null) args = preparedArgs;
    }

    final before = config.beforeToolCall;
    if (before != null) {
      var captured = args;
      final hookContext = BeforeToolCallContext(
        toolCallId: toolCall.id,
        toolName: toolCall.name,
        args: args,
        overrideArgs: (newArgs) => captured = newArgs,
      );
      final result = await before(
        hookContext,
        isAborted: () => abortSignal?.isCompleted ?? false,
      );
      args = captured;
      if (abortSignal?.isCompleted ?? false) {
        return _Prepared.immediate(_errorResult('Operation aborted'));
      }
      if (result != null && result.block != null) {
        final block = result.block;
        final content = block is List<ContentBlock>
            ? List<ContentBlock>.from(block)
            : <ContentBlock>[
                TextBlock(result.reason ?? 'Tool execution was blocked')
              ];
        return _Prepared.immediate(
            AgentToolResult<dynamic>(content: content, details: null));
      }
    }

    return _Prepared.ok(
      toolCall: toolCall,
      tool: tool,
      args: args,
    );
  } catch (e) {
    return _Prepared.immediate(_errorResult(_messageOf(e)));
  }
}

/// Executes a prepared call and runs the `afterToolCall` hook.
Future<_Finalized> _executePrepared(
  AgentContext context,
  AssistantMessage assistantMessage,
  _PreparedTool prepared,
  AgentLoopConfig config,
  Completer<void>? abortSignal,
  Future<void> Function(AgentEvent) emit,
  ToolCallBlock toolCall,
) async {
  final executed = await _executeTool(prepared, abortSignal, emit, toolCall);

  var result = executed.result;
  var isError = executed.isError;

  final after = config.afterToolCall;
  if (after != null) {
    try {
      final afterResult = await after(
        AfterToolCallContext(
          toolCallId: toolCall.id,
          toolName: toolCall.name,
          args: prepared.args,
          result: result,
        ),
        isAborted: () => abortSignal?.isCompleted ?? false,
      );
      if (afterResult != null) {
        result = AgentToolResult<dynamic>(
          content: afterResult.content ?? result.content,
          details: afterResult.details ?? result.details,
          terminate: afterResult.terminate ?? result.terminate,
        );
        isError = afterResult.isError ?? isError;
      }
    } catch (e) {
      result = _errorResult(_messageOf(e));
      isError = true;
    }
  }

  return _Finalized(toolCall, result, isError);
}

Future<_Executed> _executeTool(
  _PreparedTool prepared,
  Completer<void>? abortSignal,
  Future<void> Function(AgentEvent) emit,
  ToolCallBlock toolCall,
) async {
  final pendingUpdates = <Future<void>>[];
  try {
    final result = await prepared.tool.execute(
      toolCall.id,
      prepared.args,
      isAborted: () => abortSignal?.isCompleted ?? false,
      onUpdate: (partial) {
        pendingUpdates.add(emit(ToolExecutionUpdate(
          toolCallId: toolCall.id,
          toolName: toolCall.name,
          args: toolCall.arguments,
          partialResult: partial,
        )));
      },
    );
    await Future.wait(pendingUpdates);
    return _Executed(result, false);
  } catch (e) {
    await Future.wait(pendingUpdates);
    return _Executed(_errorResult(_messageOf(e)), true);
  }
}

/// Emits the `tool_execution_end` event and the tool-result message events.
Future<void> _emitToolEnd(
    _Finalized f, Future<void> Function(AgentEvent) emit) async {
  await emit(ToolExecutionEnd(
    toolCallId: f.toolCall.id,
    toolName: f.toolCall.name,
    args: f.toolCall.arguments,
    result: f.result,
    isError: f.isError,
  ));
  final trm = _toolResultMessage(f);
  await emit(MessageStart(message: trm));
  await emit(MessageEnd(message: trm));
}

/// Fails every tool call of a message truncated by the output token limit.
///
/// Streamed arguments can be silently incomplete, so none are safe to execute.
Future<_ToolBatch> _failTruncatedToolCalls(
  List<ToolCallBlock> toolCalls,
  Future<void> Function(AgentEvent) emit,
) async {
  final results = <ToolResultMessage>[];
  for (final toolCall in toolCalls) {
    await emit(ToolExecutionStart(
      toolCallId: toolCall.id,
      toolName: toolCall.name,
      args: toolCall.arguments,
    ));
    final f = _Finalized(
      toolCall,
      _errorResult(
        'Tool call "${toolCall.name}" was not executed: the response hit the '
        'output token limit, so its arguments may be truncated. Re-issue the '
        'tool call with complete arguments.',
      ),
      true,
    );
    await _emitToolEnd(f, emit);
    results.add(_toolResultMessage(f));
  }
  return _ToolBatch(results, false);
}

ToolResultMessage _toolResultMessage(_Finalized f) => ToolResultMessage(
      toolCallId: f.toolCall.id,
      toolName: f.toolCall.name,
      content: List<ContentBlock>.from(f.result.content),
      isError: f.isError,
    );

bool _allTerminated(List<_Finalized> finalized) =>
    finalized.isNotEmpty && finalized.every((f) => f.result.terminate);

AgentToolResult<dynamic> _errorResult(String message) =>
    AgentToolResult<dynamic>(content: [TextBlock(message)], details: null);

AssistantMessage _asAssistant(AgentMessage m) =>
    m is AssistantMessage ? m : AssistantMessage(content: const [TextBlock('')]);

String _messageOf(Object e) => e is Error ? e.toString() : e.toString();

// --- Context helpers (AgentContext is immutable) ---

AgentContext _clone(AgentContext c) => AgentContext(
      systemPrompt: c.systemPrompt,
      messages: List<AgentMessage>.from(c.messages),
      tools: c.tools,
    );

AgentContext _withMessages(AgentContext c, List<AgentMessage> extra) =>
    AgentContext(
      systemPrompt: c.systemPrompt,
      messages: [...c.messages, ...extra],
      tools: c.tools,
    );

// --- Stream plumbing ---

Stream<AgentEvent> _streamFromAsync(
  Future<void> Function(Future<void> Function(AgentEvent) emit) body,
) {
  final controller = StreamController<AgentEvent>();
  Future<void>.microtask(() async {
    try {
      await body((event) async {
        if (!controller.isClosed) controller.add(event);
      });
    } catch (e, st) {
      // Surface the failure instead of swallowing it. The loop body (LLM
      // stream, transformContext, tool internals) can throw, and a discarded
      // error left the run looking like a clean completion: the caller's
      // `await for` finished with no error event and no terminal message (#5).
      // A cancelled subscription (an aborted run that stopped listening) has no
      // one left to receive the error, so adding it there would only raise an
      // unhandled async error — the abort outcome is synthesized by the caller.
      if (!controller.isClosed && controller.hasListener) {
        controller.addError(e, st);
      }
    } finally {
      if (!controller.isClosed) await controller.close();
    }
  });
  return controller.stream;
}

// --- Internal value types ---

class _Prepared {
  final bool isImmediate;
  final _PreparedTool? prepared;
  final AgentToolResult<dynamic>? result;
  final bool? isError;

  const _Prepared.immediate(this.result)
      : isImmediate = true,
        prepared = null,
        isError = true;

  _Prepared.ok({
    required ToolCallBlock toolCall,
    required AgentTool<dynamic, dynamic> tool,
    required Map<String, dynamic> args,
  })  : isImmediate = false,
        result = null,
        isError = null,
        prepared = _PreparedTool._(toolCall, tool, args);
}

class _PreparedTool {
  final ToolCallBlock toolCall;
  final AgentTool<dynamic, dynamic> tool;
  final Map<String, dynamic> args;

  const _PreparedTool._(this.toolCall, this.tool, this.args);
}

class _Executed {
  final AgentToolResult<dynamic> result;
  final bool isError;

  const _Executed(this.result, this.isError);
}

class _Finalized {
  final ToolCallBlock toolCall;
  final AgentToolResult<dynamic> result;
  final bool isError;

  const _Finalized(this.toolCall, this.result, this.isError);
}

class _ToolBatch {
  final List<ToolResultMessage> results;
  final bool terminate;

  const _ToolBatch(this.results, this.terminate);
}
