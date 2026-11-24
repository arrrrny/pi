/// Context compaction utilities.
library;

import 'dart:async';

import 'types.dart';
import 'agent_loop.dart';
import 'conversion.dart' as conversion;
import 'llm_client.dart';

/// Default compaction settings.
const CompactionSettings defaultCompactionSettings = CompactionSettings();

/// Calculates context tokens from a [Usage] object.
int calculateContextTokens(Usage usage) =>
    usage.inputTokens + usage.outputTokens;

/// Estimates context tokens from a list of messages.
///
/// Uses a chars/4 heuristic per message when usage data is unavailable.
int estimateContextTokens(List<AgentMessage> messages) {
  var total = 0;
  for (final msg in messages) {
    total += _estimateMessageTokens(msg);
  }
  return total;
}

/// Checks if compaction should be triggered based on estimated tokens.
bool shouldCompact(
  List<AgentMessage> messages,
  int contextWindow, {
  CompactionSettings settings = defaultCompactionSettings,
}) {
  if (!settings.enabled) return false;
  final estimated = estimateContextTokens(messages);
  return estimated > contextWindow - settings.reserveTokens;
}

/// Finds the cut point index in entries to keep [keepTokens] recent tokens.
///
/// Walks entries from leaf backward and returns the index where older
/// entries should be summarized.
int? findCutPoint(
  List<SessionTreeEntry> entries,
  int keepTokens, {
  int startIndex = 0,
}) {
  var accumulated = 0;
  for (var i = entries.length - 1; i >= startIndex; i--) {
    final entry = entries[i];
    if (entry is MessageEntry) {
      accumulated += _estimateMessageTokens(entry.message);
    }
    if (accumulated >= keepTokens) {
      return i;
    }
  }
  return null;
}

/// Serializes messages to text for summarization.
String serializeConversation(List<AgentMessage> messages) {
  final buffer = StringBuffer();
  for (final msg in messages) {
    final role = switch (msg) {
      UserMessage() => 'User',
      AssistantMessage() => 'Assistant',
      ToolResultMessage() => 'Tool',
      CustomMessage() => 'System',
    };
    final text = switch (msg) {
      UserMessage(:final content) =>
        content.whereType<TextBlock>().map((b) => b.text).join(),
      AssistantMessage(:final content) =>
        content.whereType<TextBlock>().map((b) => b.text).join(),
      ToolResultMessage(:final content) =>
        content.whereType<TextBlock>().map((b) => b.text).join(),
      CustomMessage(:final display) => display,
    };
    buffer.writeln('$role: $text');
    buffer.writeln();
  }
  return buffer.toString();
}

/// Prepares compaction by identifying the cut point and categorizing entries.
CompactionPreparation prepareCompaction(
  List<SessionTreeEntry> entries,
  int keepTokens, {
  String? previousSummary,
}) {
  final cutIndex = findCutPoint(entries, keepTokens) ?? 0;
  var tokensCut = 0;
  for (var i = 0; i < cutIndex; i++) {
    final entry = entries[i];
    if (entry is MessageEntry) {
      tokensCut += _estimateMessageTokens(entry.message);
    }
  }

  return CompactionPreparation(
    cutIndex: cutIndex,
    tokensCut: tokensCut,
    keptEntries: entries.sublist(cutIndex),
    cutEntries: entries.sublist(0, cutIndex),
    previousSummary: previousSummary,
  );
}

/// Runs full compaction: find cut point, generate summary, return result.
///
/// The entries before the cut point are summarized by [model] through
/// [loopStreamFn] — the same canonical summarization path
/// [summarizeMessagesWithUsage] provides for the durable conversation harness,
/// so the two compaction entry points cannot diverge semantically.
///
/// A [previousSummary] switches the request to the update prompt and is
/// carried in `<previous-summary>` tags; [customInstructions] is appended as an
/// additional focus.
///
/// Throws a [StateError] when the model response cannot be persisted as a
/// summary: a provider error, an aborted request, a response capped at the
/// token limit, or a response that attempted a tool call.
Future<CompactionResult> compact(
  List<SessionTreeEntry> entries,
  Model model, {
  LoopStreamFn loopStreamFn = streamLLM,
  String? apiKey,
  CompactionSettings? settings,
  String? customInstructions,
  String? previousSummary,
  Completer<void>? abortSignal,
}) async {
  settings ??= defaultCompactionSettings;
  final preparation = prepareCompaction(
    entries,
    settings.keepRecentTokens,
    previousSummary: previousSummary,
  );

  final messages = preparation.cutEntries
      .whereType<MessageEntry>()
      .map((e) => e.message)
      .toList();

  final summarized = await summarizeMessagesWithUsage(
    messages,
    model,
    loopStreamFn: loopStreamFn,
    apiKey: apiKey,
    customInstructions: customInstructions,
    previousSummary: preparation.previousSummary,
    abortSignal: abortSignal,
  );

  final firstKeptEntryId = preparation.keptEntries.isNotEmpty
      ? preparation.keptEntries.first.id
      : '';

  return CompactionResult(
    summary: summarized.text,
    firstKeptEntryId: firstKeptEntryId,
    tokensBefore: preparation.tokensCut,
    usage: summarized.usage,
  );
}

int _estimateMessageTokens(AgentMessage message) {
  final text = switch (message) {
    UserMessage(:final content) =>
      content.whereType<TextBlock>().map((b) => b.text).join(),
    AssistantMessage(:final content) =>
      content.whereType<TextBlock>().map((b) => b.text).join(),
    ToolResultMessage(:final content) =>
      content.whereType<TextBlock>().map((b) => b.text).join(),
    CustomMessage(:final display) => display,
  };
  return (text.length / 4).ceil();
}

/// System prompt for a summarization request ([SUMMARIZATION_SYSTEM_PROMPT]).
const String summarizationSystemPrompt =
    'You are a context summarization assistant. Your task is to read a '
    'conversation between a user and an AI assistant, then produce a '
    'structured summary following the exact format specified.\n\n'
    'Do NOT continue the conversation. Do NOT respond to any questions in the '
    'conversation. ONLY output the structured summary.';

/// Instructions for an initial compaction summary ([SUMMARIZATION_PROMPT]).
const String defaultCompactionInstructions = '''
The messages above are a conversation to summarize. Create a structured context checkpoint summary that another LLM will use to continue the work.

Use this EXACT format:

## Goal
[What is the user trying to accomplish? Can be multiple items if the session covers different tasks.]

## Constraints & Preferences
- [Any constraints, preferences, or requirements mentioned by user]
- [Or "(none)" if none were mentioned]

## Progress
### Done
- [x] [Completed tasks/changes]

### In Progress
- [ ] [Current work]

### Blocked
- [Issues preventing progress, if any]

## Key Decisions
- **[Decision]**: [Brief rationale]

## Next Steps
1. [Ordered list of what should happen next]

## Critical Context
- [Any data, examples, or references needed to continue]
- [Or "(none)" if not applicable]

Keep each section concise. Preserve exact file paths, function names, and error messages.''';

/// Instructions for updating an existing summary ([UPDATE_SUMMARIZATION_PROMPT]).
const String updateCompactionInstructions = '''
The messages above are NEW conversation messages to incorporate into the existing summary provided in <previous-summary> tags.

Update the existing structured summary with new information. RULES:
- PRESERVE all existing information from the previous summary
- ADD new progress, decisions, and context from the new messages
- UPDATE the Progress section: move items from "In Progress" to "Done" when completed
- UPDATE "Next Steps" based on what was accomplished
- PRESERVE exact file paths, function names, and error messages
- If something is no longer relevant, you may remove it

Use this EXACT format:

## Goal
[Preserve existing goals, add new ones if the task expanded]

## Constraints & Preferences
- [Preserve existing, add new ones discovered]

## Progress
### Done
- [x] [Include previously done items AND newly completed items]

### In Progress
- [ ] [Current work - update based on progress]

### Blocked
- [Current blockers - remove if resolved]

## Key Decisions
- **[Decision]**: [Brief rationale] (preserve all previous, add new)

## Next Steps
1. [Update based on current state]

## Critical Context
- [Preserve important context, add new if needed]

Keep each section concise. Preserve exact file paths, function names, and error messages.''';

/// A generated summary plus the token usage of the request that produced it.
class SummaryResult {
  /// The summary text.
  final String text;

  /// Usage reported by the summarizing response, when the provider sent any.
  final Usage? usage;

  /// Creates a summary result.
  const SummaryResult({required this.text, this.usage});
}

/// Returns a diagnostic when a summarization [response] cannot be persisted.
///
/// A response that failed at the provider, was aborted, or hit the token cap
/// carries no trustworthy summary: the text is either absent or a partial
/// generation, so persisting it as a checkpoint would silently lie about the
/// context ([getSummarizationFailure]).
String? summarizationFailure(AssistantMessage response) {
  switch (response.stopReason) {
    case StopReason.error:
      return 'Summarization failed: ${response.errorMessage ?? 'Unknown error'}';
    case StopReason.aborted:
      return 'Summarization aborted';
    case StopReason.maxTokens:
      return 'Summarization failed: generation hit the token cap and the '
          'summary is incomplete';
    default:
      return null;
  }
}

/// Summarizes [messages] into a compact context summary using [loopStreamFn].
///
/// Returns an empty string for an empty transcript. Throws a [StateError] for a
/// response [summarizationFailure] rejects or one that attempted a tool call.
Future<String> summarizeMessages(
  List<AgentMessage> messages,
  Model model, {
  required LoopStreamFn loopStreamFn,
  String? apiKey,
  String? instructions,
  String? previousSummary,
  Completer<void>? abortSignal,
}) async {
  final result = await summarizeMessagesWithUsage(
    messages,
    model,
    loopStreamFn: loopStreamFn,
    apiKey: apiKey,
    customInstructions: instructions,
    previousSummary: previousSummary,
    abortSignal: abortSignal,
  );
  return result.text;
}

/// Generates or updates a conversation summary and returns its usage.
///
/// The transcript is serialized into `<conversation>` tags and sent as a single
/// user prompt; a [previousSummary] is carried in `<previous-summary>` tags and
/// selects the update instructions. [customInstructions] is appended as
/// "Additional focus".
///
/// Returns an empty result for an empty transcript. Throws a [StateError] when
/// the response cannot be persisted as a summary — see
/// [summarizationFailure] — or when it attempted a tool call.
Future<SummaryResult> summarizeMessagesWithUsage(
  List<AgentMessage> messages,
  Model model, {
  required LoopStreamFn loopStreamFn,
  String? apiKey,
  String? previousSummary,
  String? customInstructions,
  Completer<void>? abortSignal,
}) async {
  if (messages.isEmpty) return const SummaryResult(text: '');

  var basePrompt = previousSummary == null
      ? defaultCompactionInstructions
      : updateCompactionInstructions;
  if (customInstructions != null && customInstructions.trim().isNotEmpty) {
    basePrompt = '$basePrompt\n\nAdditional focus: $customInstructions';
  }

  final transcript = serializeConversation(messages);
  final buffer =
      StringBuffer('<conversation>\n$transcript\n</conversation>\n\n');
  if (previousSummary != null) {
    buffer
        .write('<previous-summary>\n$previousSummary\n</previous-summary>\n\n');
  }
  buffer.write(basePrompt);

  final context = AgentContext(
    systemPrompt: summarizationSystemPrompt,
    messages: [UserMessage.text(buffer.toString())],
    tools: null,
  );
  final config = AgentLoopConfig(
    model: model,
    convertToLlm: conversion.convertToLlm,
  );

  AssistantMessage? response;
  await for (final event in loopStreamFn(
    context: context,
    config: config,
    apiKey: apiKey ?? '',
    abortSignal: abortSignal,
  )) {
    if (event case MessageEnd(message: final AssistantMessage message)) {
      response = message;
    }
  }

  if (response == null) {
    throw StateError('Summarization failed: the model produced no response');
  }
  final failure = summarizationFailure(response);
  if (failure != null) throw StateError(failure);
  if (response.toolCalls.isNotEmpty) {
    throw StateError('Summarization attempted to call a tool');
  }

  return SummaryResult(text: response.text, usage: response.usage);
}
