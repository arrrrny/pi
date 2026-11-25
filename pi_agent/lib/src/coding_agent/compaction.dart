// File-operation tracking, conversation serialization, and branch-entry
// preparation for context compaction.
//
// Port of the model-free core of
// `packages/coding-agent/src/core/compaction/utils.ts` and
// `packages/coding-agent/src/core/compaction/branch-summarization.ts` at
// upstream `c11a73bfba1310dc4075ad836254ea87003f409b`. The provider-backed
// `generateBranchSummary` is a separate slice; this file is the pure
// preparation layer it builds on, so it has no provider or stream dependency.
library;

import '../types.dart';

/// File paths touched by a conversation branch, deduplicated per kind.
///
/// Port of `FileOperations` in `compaction/utils.ts`: three sets — files read,
/// written, and edited — that [extractFileOpsFromMessage] fills from tool calls
/// and [computeFileLists] reduces to the read-only and modified lists a summary
/// records.
class FileOperations {
  /// Paths passed to a `read` tool call.
  final Set<String> read;

  /// Paths passed to a `write` tool call.
  final Set<String> written;

  /// Paths passed to an `edit` tool call.
  final Set<String> edited;

  /// Creates an empty file-operation accumulator.
  FileOperations()
      : read = <String>{},
        written = <String>{},
        edited = <String>{};
}

/// Creates an empty [FileOperations] accumulator.
///
/// Port of `createFileOps` in `compaction/utils.ts`.
FileOperations createFileOps() => FileOperations();

/// Extracts file operations from the tool calls in [message] into [fileOps].
///
/// Port of `extractFileOpsFromMessage` in `compaction/utils.ts`. Only `read`,
/// `write`, and `edit` calls with a string `path` argument contribute; every
/// other tool (e.g. `bash`) and a call without a path is ignored. A
/// [ToolResultMessage] contributes nothing here — upstream reads nested codemode
/// calls off a tool result, a field the Dart [ToolResultMessage] does not carry,
/// so that branch has no Dart equivalent yet.
void extractFileOpsFromMessage(AgentMessage message, FileOperations fileOps) {
  if (message is! AssistantMessage) return;
  for (final block in message.content) {
    if (block is! ToolCallBlock) continue;
    final path = block.arguments['path'];
    if (path is! String) continue;
    switch (block.name) {
      case 'read':
        fileOps.read.add(path);
      case 'write':
        fileOps.written.add(path);
      case 'edit':
        fileOps.edited.add(path);
    }
  }
}

/// Reduces [fileOps] to the read-only and modified path lists a summary records.
///
/// Port of `computeFileLists` in `compaction/utils.ts`: a path that was written
/// or edited is modified (never also read-only); each list is sorted so the
/// summary is deterministic.
({List<String> readOnly, List<String> modified}) computeFileLists(
    FileOperations fileOps) {
  final modified = <String>{...fileOps.edited, ...fileOps.written};
  final readOnly = fileOps.read.where((f) => !modified.contains(f)).toList()
    ..sort();
  final modifiedList = modified.toList()..sort();
  return (readOnly: readOnly, modified: modifiedList);
}

/// Formats [readFiles] and [modifiedFiles] as XML sections for a summary.
///
/// Port of `formatFileOperations` in `compaction/utils.ts`: each non-empty list
/// becomes a `<read-files>` or `<modified-files>` block, prefixed by a blank
/// line; two empty lists render the empty string so a summary with no file
/// activity carries no trailing markup.
String formatFileOperations(List<String> readFiles, List<String> modifiedFiles) {
  final sections = <String>[];
  if (readFiles.isNotEmpty) {
    sections.add('<read-files>\n${readFiles.join('\n')}\n</read-files>');
  }
  if (modifiedFiles.isNotEmpty) {
    sections.add('<modified-files>\n${modifiedFiles.join('\n')}\n</modified-files>');
  }
  if (sections.isEmpty) return '';
  return '\n\n${sections.join('\n\n')}';
}

/// Maximum characters of a tool result kept in a serialized summary.
const int _toolResultMaxChars = 2000;

/// Serializes [messages] to text for a summarization request.
///
/// Port of `serializeConversation` in `compaction/utils.ts`. The transcript is
/// rendered as `[User]` / `[Assistant]` / `[Assistant tool calls]` /
/// `[Tool result]` lines so the model treats it as data to summarize, not a
/// conversation to continue. A tool result longer than [_toolResultMaxChars] is
/// truncated with a `[... N more characters truncated]` marker; thinking blocks
/// are omitted. Callers pass model messages (custom messages already converted).
String serializeConversation(List<AgentMessage> messages) {
  final parts = <String>[];

  for (final msg in messages) {
    switch (msg) {
      case UserMessage(:final content):
        final text = _contentText(content);
        if (text.isNotEmpty) parts.add('[User]: $text');
      case AssistantMessage(:final content):
        final toolCalls = <String>[];
        for (final block in content) {
          if (block is ToolCallBlock) {
            final args = block.arguments.entries
                .map((e) => '${e.key}=${_jsonEncode(e.value)}')
                .join(', ');
            toolCalls.add('${block.name}($args)');
          }
        }
        final text = _contentText(content);
        if (text.isNotEmpty) parts.add('[Assistant]: $text');
        if (toolCalls.isNotEmpty) {
          parts.add('[Assistant tool calls]: ${toolCalls.join('; ')}');
        }
      case ToolResultMessage(:final content):
        final text = _contentText(content);
        if (text.isNotEmpty) {
          parts.add('[Tool result]: ${_truncateForSummary(text)}');
        }
      case CustomMessage():
        break;
    }
  }

  return parts.join('\n\n');
}

/// Truncates [text] to [_toolResultMaxChars] with a remainder marker.
String _truncateForSummary(String text) {
  if (text.length <= _toolResultMaxChars) return text;
  final truncatedChars = text.length - _toolResultMaxChars;
  return '${text.substring(0, _toolResultMaxChars)}\n\n'
      '[... $truncatedChars more characters truncated]';
}

/// Concatenates the text blocks of [content] (image and tool-call blocks are
/// ignored, matching upstream `contentText`).
String _contentText(List<dynamic> content) {
  final buffer = StringBuffer();
  for (final block in content) {
    if (block is TextBlock) buffer.write(block.text);
  }
  return buffer.toString();
}

/// JSON-encodes a tool-call argument value the way upstream's
/// `JSON.stringify` renders it inside a serialized tool call.
String _jsonEncode(Object? value) {
  if (value is String) return '"$value"';
  return '$value';
}

/// The entries to summarize and the common ancestor a branch navigation shares.
///
/// Port of `CollectEntriesResult` in `branch-summarization.ts`.
class CollectEntriesResult {
  /// Entries to summarize, in chronological (root-before-leaf) order.
  final List<SessionTreeEntry> entries;

  /// Deepest entry on both the old and target paths, or null when none.
  final String? commonAncestorId;

  /// Creates a collect-entries result.
  const CollectEntriesResult({required this.entries, required this.commonAncestorId});
}

/// Read-only session surface [collectEntriesForBranchSummary] consumes.
///
/// Mirrors the upstream `ReadonlySessionManager` methods the collector calls:
/// the current branch from a leaf and a single entry by id. [getBranch] returns
/// entries in root-first (chronological) order, matching upstream.
abstract class ReadonlySession {
  /// Entries from the root down to [leafId], root first.
  List<SessionTreeEntry> getBranch(String leafId);

  /// The entry with [id], or null when absent.
  SessionTreeEntry? getEntry(String id);
}

/// Collects the entries to summarize when navigating from [oldLeafId] to
/// [targetId].
///
/// Port of `collectEntriesForBranchSummary` in `branch-summarization.ts`: walks
/// from the old leaf back to the deepest common ancestor with the target,
/// returning those entries in chronological order. Does not stop at compaction
/// boundaries — a compaction entry's summary is itself context. Returns nothing
/// when there is no old position.
CollectEntriesResult collectEntriesForBranchSummary(
  ReadonlySession session, {
  required String? oldLeafId,
  required String targetId,
}) {
  if (oldLeafId == null) {
    return const CollectEntriesResult(entries: [], commonAncestorId: null);
  }

  final oldPath = session.getBranch(oldLeafId).map((e) => e.id).toSet();
  final targetPath = session.getBranch(targetId);

  String? commonAncestorId;
  for (var i = targetPath.length - 1; i >= 0; i--) {
    if (oldPath.contains(targetPath[i].id)) {
      commonAncestorId = targetPath[i].id;
      break;
    }
  }

  // Walk leaf-first back to the common ancestor, then reverse into
  // chronological (root-before-leaf) order.
  final reversed = <SessionTreeEntry>[];
  String? current = oldLeafId;
  while (current != null && current != commonAncestorId) {
    final entry = session.getEntry(current);
    if (entry == null) break;
    reversed.add(entry);
    current = entry.parentId.isEmpty ? null : entry.parentId;
  }

  return CollectEntriesResult(
    entries: reversed.reversed.toList(),
    commonAncestorId: commonAncestorId,
  );
}

/// Messages extracted for summarization plus the tokens they occupy.
///
/// Port of `BranchPreparation` in `branch-summarization.ts`.
class BranchPreparation {
  /// Messages extracted for summarization, in chronological order.
  final List<AgentMessage> messages;

  /// Total estimated tokens across [messages].
  final int totalTokens;

  /// Creates a branch preparation.
  const BranchPreparation({required this.messages, required this.totalTokens});
}

/// Prepares [entries] for summarization within [tokenBudget].
///
/// Port of `prepareBranchEntries` in `branch-summarization.ts`: walks entries
/// newest to oldest, keeping the most recent messages that fit [tokenBudget]
/// (0 means no limit), and returns them in chronological order. Context edits
/// and the cumulative file lists carried on prior branch summaries have no Dart
/// [SessionTreeEntry] representation yet, so this slice omits them; the
/// token-budget selection is the ported behavior.
BranchPreparation prepareBranchEntries(
  List<SessionTreeEntry> entries,
  int tokenBudget,
) {
  final messages = <AgentMessage>[];
  var totalTokens = 0;

  for (var i = entries.length - 1; i >= 0; i--) {
    final entry = entries[i];
    if (entry is! MessageEntry) continue;
    final message = entry.message;
    final tokens = _estimateTokens(message);
    if (tokenBudget > 0 && totalTokens + tokens > tokenBudget) break;
    messages.insert(0, message);
    totalTokens += tokens;
  }

  return BranchPreparation(messages: messages, totalTokens: totalTokens);
}

/// Estimates the tokens [message] occupies (chars/4, rounded up).
int _estimateTokens(AgentMessage message) {
  final text = switch (message) {
    UserMessage(:final content) => _contentText(content),
    AssistantMessage(:final content) => _contentText(content),
    ToolResultMessage(:final content) => _contentText(content),
    CustomMessage(:final display) => display,
  };
  return (text.length / 4).ceil();
}