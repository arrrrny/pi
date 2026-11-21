/// Durable conversation harness.
///
/// A [Conversation] pairs an [Agent] with a [Session] so the transcript is
/// persisted to storage as the agent runs. The conversation therefore survives a
/// process restart ([Conversation.resume] rebuilds the agent's context from
/// storage) and can be forked ([Conversation.fork]). This is the Dart-native
/// "durable harness" layer, modeled on pi-durable's durable-conversation
/// behavior but backed by a simple [SessionStorage] (JSONL / in-memory).
library;

import 'dart:async';

import 'types.dart' hide AgentTool;
import 'tools.dart';
import 'agent.dart';
import 'agent_loop.dart';
import 'compaction.dart';
import 'llm_client.dart';
import 'session.dart';
import 'session_storage.dart';

/// A `beforeToolCall` hook, matching [Agent].
typedef BeforeToolCallHook = Future<BeforeToolCallResult?> Function(
    BeforeToolCallContext ctx,
    {bool Function()? isAborted});

/// An `afterToolCall` hook, matching [Agent].
typedef AfterToolCallHook = Future<AfterToolCallResult?> Function(
    AfterToolCallContext ctx,
    {bool Function()? isAborted});

/// Resolves an API key for a provider.
typedef ConversationGetApiKey = Future<String?> Function(String provider);

/// A durable conversation: an [Agent] whose transcript is written to a
/// [SessionStorage] as it runs, so it can be reopened and resumed later.
class Conversation {
  final Agent _agent;
  final Session _session;
  final LoopStreamFn? _loopStreamFn;
  final ConversationGetApiKey? _getApiKey;
  final StreamController<AgentEvent> _events =
      StreamController<AgentEvent>.broadcast();
  bool _closed = false;

  Conversation._(this._agent, this._session, this._loopStreamFn, this._getApiKey);

  /// Creates a new, empty conversation backed by [storage].
  static Future<Conversation> create(
    SessionStorage storage, {
    Model? model,
    String? systemPrompt,
    ThinkingLevel? thinkingLevel,
    List<AgentTool<dynamic, dynamic>>? tools,
    LoopStreamFn? loopStreamFn,
    ConversationGetApiKey? getApiKey,
    Future<List<Map<String, dynamic>>> Function(List<AgentMessage>)?
        convertToLlm,
    BeforeToolCallHook? beforeToolCall,
    AfterToolCallHook? afterToolCall,
    ToolExecutionMode? toolExecution,
    Map<String, String>? extraHeaders,
  }) async {
    await storage.init();
    final session = Session(storage);
    final agent = Agent(
      model: model,
      systemPrompt: systemPrompt,
      thinkingLevel: thinkingLevel,
      tools: tools,
      streamFn: null,
      loopStreamFn: loopStreamFn,
      getApiKey: getApiKey,
      convertToLlm: convertToLlm,
      beforeToolCall: beforeToolCall,
      afterToolCall: afterToolCall,
      toolExecution: toolExecution,
      extraHeaders: extraHeaders,
    );
    return Conversation._(agent, session, loopStreamFn, getApiKey);
  }

  /// Reopens a conversation from [storage], rebuilding the agent's transcript,
  /// model, and thinking level from the persisted entries (crash recovery).
  ///
  /// The host still supplies the [systemPrompt] and [tools] the agent needs;
  /// everything conversational comes from storage.
  static Future<Conversation> resume(
    SessionStorage storage, {
    String? systemPrompt,
    List<AgentTool<dynamic, dynamic>>? tools,
    LoopStreamFn? loopStreamFn,
    ConversationGetApiKey? getApiKey,
    Future<List<Map<String, dynamic>>> Function(List<AgentMessage>)?
        convertToLlm,
    BeforeToolCallHook? beforeToolCall,
    AfterToolCallHook? afterToolCall,
    ToolExecutionMode? toolExecution,
    Map<String, String>? extraHeaders,
  }) async {
    await storage.init();
    final session = Session(storage);
    final context = await session.buildContext();
    final agent = Agent(
      model: context.model,
      systemPrompt: systemPrompt ?? '',
      thinkingLevel: context.thinkingLevel,
      tools: tools,
      messages: context.messages,
      streamFn: null,
      loopStreamFn: loopStreamFn,
      getApiKey: getApiKey,
      convertToLlm: convertToLlm,
      beforeToolCall: beforeToolCall,
      afterToolCall: afterToolCall,
      toolExecution: toolExecution,
      extraHeaders: extraHeaders,
    );
    return Conversation._(agent, session, loopStreamFn, getApiKey);
  }

  /// The underlying agent.
  Agent get agent => _agent;

  /// The underlying session.
  Session get session => _session;

  /// The current transcript.
  List<AgentMessage> get messages => _agent.state.messages;

  /// Whether a run is currently in progress.
  bool get isRunning => _agent.isRunning;

  /// A broadcast stream of the agent's events for this run.
  Stream<AgentEvent> get events => _events.stream;

  /// Sends a prompt and runs the conversation to completion, persisting the
  /// input and every message the agent produces.
  ///
  /// [input] may be a `String`, `List<ContentBlock>`, `AgentMessage`, or
  /// `List<AgentMessage>`.
  Future<List<AgentMessage>> prompt(dynamic input) async {
    for (final message in _inputMessages(input)) {
      await _session.appendMessage(message);
    }

    final subscription = _agent.subscribe(_persistAndForward);
    try {
      await _agent.prompt(input);
    } finally {
      subscription();
    }
    return _agent.state.messages;
  }

  /// Forks the conversation at [atEntryId] (or the current leaf when null),
  /// optionally recording a [summary] for the new branch.
  Future<String?> fork(String? atEntryId, {String? summary}) =>
      _session.moveTo(atEntryId, summary: summary);

  /// Compacts the conversation when it exceeds the model's context window.
  ///
  /// Summarizes the older entries, appends a compaction entry to the session,
  /// and reseeds the agent with the compacted context. Pass [summarize] to
  /// override how the summary is produced (defaults to an LLM call through the
  /// conversation's own stream function). Returns whether compaction happened.
  Future<bool> compact({
    CompactionSettings? settings,
    String? apiKey,
    Future<String> Function(List<AgentMessage> messages, Model model)? summarize,
  }) async {
    final effective = settings ?? defaultCompactionSettings;
    final model = _agent.state.model;
    final liveMessages = _agent.state.messages;
    if (liveMessages.length < 2 ||
        !shouldCompact(liveMessages, model.contextWindow, settings: effective)) {
      return false;
    }

    final entries = await _session.getEntries();
    final preparation = prepareCompaction(entries, effective.keepRecentTokens);
    final cutMessages = preparation.cutEntries
        .whereType<MessageEntry>()
        .map((e) => e.message)
        .toList();
    if (cutMessages.isEmpty) return false;

    final summary = summarize != null
        ? await summarize(cutMessages, model)
        : await summarizeMessages(
            cutMessages,
            model,
            loopStreamFn: _loopStreamFn ?? streamLLM,
            apiKey: apiKey ?? await _getApiKey?.call(model.provider),
          );

    final firstKept =
        preparation.keptEntries.isNotEmpty ? preparation.keptEntries.first.id : '';
    await _session.appendCompaction(summary, firstKept, preparation.tokensCut);

    final rebuilt = await _session.buildContext();
    _agent.state.messages = rebuilt.messages;
    return true;
  }

  /// Reconstructs the conversation context from storage.
  Future<SessionContext> buildContext() => _session.buildContext();

  /// Whether the transcript ends with a user message that never received a
  /// response — a run interrupted mid-turn (e.g. a crash after the input was
  /// persisted but before the model answered).
  bool get hasPendingTurn {
    final messages = _agent.state.messages;
    return messages.isNotEmpty && messages.last is UserMessage;
  }

  /// Completes an interrupted turn.
  ///
  /// When [hasPendingTurn] is true, runs the agent to produce the missing
  /// response and persists it. Returns whether a turn was resumed.
  Future<bool> resumeInterruptedTurn() async {
    if (!hasPendingTurn) return false;
    final subscription = _agent.subscribe(_persistAndForward);
    try {
      await _agent.continue_();
    } finally {
      subscription();
    }
    return true;
  }

  /// Releases the event stream. The underlying storage is left intact so the
  /// conversation can be resumed later.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _events.close();
  }

  Future<void> _persistAndForward(AgentEvent event) async {
    switch (event) {
      case MessageEnd(message: final message):
        if (message is AssistantMessage || message is ToolResultMessage) {
          await _session.appendMessage(message);
        }
      default:
        break;
    }
    if (!_events.isClosed) _events.add(event);
  }

  List<AgentMessage> _inputMessages(dynamic input) {
    if (input is String) return [UserMessage.text(input)];
    if (input is List<ContentBlock>) return [UserMessage(content: input)];
    if (input is AgentMessage) return [input];
    if (input is List<AgentMessage>) return List<AgentMessage>.from(input);
    return const <AgentMessage>[];
  }
}