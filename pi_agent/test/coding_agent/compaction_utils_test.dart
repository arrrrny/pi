// File-operation tracking, conversation serialization, and branch-entry
// preparation for context compaction.
//
// Port of the model-free core of
// `packages/coding-agent/src/core/compaction/utils.ts` (`createFileOps`,
// `extractFileOpsFromMessage`, `computeFileLists`, `formatFileOperations`,
// `serializeConversation`) and
// `packages/coding-agent/src/core/compaction/branch-summarization.ts`
// (`collectEntriesForBranchSummary`, `prepareBranchEntries`) at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b`. The test cases are derived from
// `packages/coding-agent/test/branch-summarization.test.ts` and the file-op
// behavior the upstream utils document. The provider-backed
// `generateBranchSummary` is a separate slice; this file covers only the pure
// preparation layer.

import 'dart:convert';

import 'package:pi/coding_agent.dart';
import 'package:test/test.dart';

void main() {
  group('FileOperations', () {
    test('extractFileOpsFromMessage records read/write/edit tool calls', () {
      final ops = createFileOps();
      final message = AssistantMessage(content: <dynamic>[
        const ToolCallBlock(
            id: 'c1', name: 'read', arguments: <String, dynamic>{'path': 'a.dart'}),
        const ToolCallBlock(
            id: 'c2', name: 'write', arguments: <String, dynamic>{'path': 'b.dart'}),
        const ToolCallBlock(
            id: 'c3', name: 'edit', arguments: <String, dynamic>{'path': 'c.dart'}),
        const ToolCallBlock(
            id: 'c4', name: 'bash', arguments: <String, dynamic>{'command': 'ls'}),
        const ToolCallBlock(id: 'c5', name: 'read', arguments: <String, dynamic>{}),
      ]);

      extractFileOpsFromMessage(message, ops);

      expect(ops.read, <String>{'a.dart'});
      expect(ops.written, <String>{'b.dart'});
      expect(ops.edited, <String>{'c.dart'});
    });

    test('computeFileLists separates read-only from modified, sorted', () {
      final ops = createFileOps();
      ops.read
        ..add('z.dart')
        ..add('a.dart')
        ..add('m.dart');
      ops.written.add('m.dart');
      ops.edited.add('b.dart');

      final lists = computeFileLists(ops);

      // m.dart was both read and written -> modified, not read-only.
      expect(lists.readOnly, <String>['a.dart', 'z.dart']);
      expect(lists.modified, <String>['b.dart', 'm.dart']);
    });

    test('formatFileOperations renders XML sections, empty when none', () {
      expect(formatFileOperations(<String>[], <String>[]), '');
      expect(formatFileOperations(<String>['a.dart'], <String>['b.dart']),
          '\n\n<read-files>\na.dart\n</read-files>'
          '\n\n<modified-files>\nb.dart\n</modified-files>');
    });
  });

  group('serializeConversation', () {
    test('renders user, assistant text, tool calls, and tool results', () {
      final messages = <AgentMessage>[
        UserMessage.text('hello'),
        const AssistantMessage(content: <dynamic>[
          TextBlock('working'),
          ToolCallBlock(
              id: 'c1',
              name: 'read',
              arguments: <String, dynamic>{'path': 'a.dart'}),
        ]),
        ToolResultMessage.text(
            toolCallId: 'c1', toolName: 'read', text: 'file body'),
      ];

      final text = serializeConversation(messages);

      expect(text, contains('[User]: hello'));
      expect(text, contains('[Assistant]: working'));
      expect(text, contains('[Assistant tool calls]: read(path="a.dart")'));
      expect(text, contains('[Tool result]: file body'));
    });

    test('joins multiple text blocks with the upstream newline separator', () {
      final messages = <AgentMessage>[
        UserMessage(content: <ContentBlock>[
          const TextBlock('a'),
          const TextBlock('b'),
        ]),
      ];

      expect(serializeConversation(messages), '[User]: a\nb');
    });

    test('escapes string arguments like JSON.stringify', () {
      final messages = <AgentMessage>[
        AssistantMessage(content: <dynamic>[
          const ToolCallBlock(
              id: 'c1',
              name: 'bash',
              arguments: <String, dynamic>{'cmd': 'a"b\\c\nd'}),
        ]),
      ];

      // jsonEncode quotes and escapes the value; the hand-rolled '"$value"'
      // emitted a broken, unescaped JSON string.
      expect(
        serializeConversation(messages),
        '[Assistant tool calls]: bash(cmd=${jsonEncode('a"b\\c\nd')})',
      );
    });

    test('truncates a long tool result and notes the remainder', () {
      final long = 'x' * 2500;
      final messages = <AgentMessage>[
        ToolResultMessage.text(
            toolCallId: 'c1', toolName: 'read', text: long),
      ];

      final text = serializeConversation(messages);

      expect(text, contains('[Tool result]: '));
      expect(text, contains('more characters truncated'));
      // 2000 kept + marker; the raw 2500-char body is not fully present.
      expect(text.contains('x' * 2001), isFalse);
    });
  });

  group('collectEntriesForBranchSummary', () {
    test('collects entries from the old leaf back to the common ancestor', () {
      // root -> a -> b -> c (old leaf); root -> a -> d (target)
      final root = MessageEntry(
          id: 'root', parentId: '', timestamp: DateTime(1), role: 'user', message: UserMessage.text('r'));
      final a = MessageEntry(
          id: 'a', parentId: 'root', timestamp: DateTime(2), role: 'user', message: UserMessage.text('a'));
      final b = MessageEntry(
          id: 'b', parentId: 'a', timestamp: DateTime(3), role: 'user', message: UserMessage.text('b'));
      final c = MessageEntry(
          id: 'c', parentId: 'b', timestamp: DateTime(4), role: 'user', message: UserMessage.text('c'));
      final d = MessageEntry(
          id: 'd', parentId: 'a', timestamp: DateTime(5), role: 'user', message: UserMessage.text('d'));
      final session = FakeSession(<SessionTreeEntry>[root, a, b, c, d]);

      final result = collectEntriesForBranchSummary(session, oldLeafId: 'c', targetId: 'd');

      expect(result.commonAncestorId, 'a');
      expect(result.entries.map((e) => e.id), <String>['b', 'c']);
    });

    test('returns nothing when there is no old position', () {
      final session = FakeSession(<SessionTreeEntry>[]);
      final result = collectEntriesForBranchSummary(session, oldLeafId: null, targetId: 'x');
      expect(result.entries, isEmpty);
      expect(result.commonAncestorId, isNull);
    });
  });

  group('prepareBranchEntries', () {
    test('keeps the most recent messages within the token budget', () {
      final entries = <SessionTreeEntry>[
        MessageEntry(
            id: 'u1', parentId: '', timestamp: DateTime(1), role: 'user', message: UserMessage.text('old')),
        MessageEntry(
            id: 'u2', parentId: 'u1', timestamp: DateTime(2), role: 'user', message: UserMessage.text('new')),
      ];

      // Unlimited budget keeps every message in chronological order.
      final unlimited = prepareBranchEntries(entries, 0);
      expect(unlimited.messages.map((m) => (m as UserMessage).content.first.toString()),
          <String>['TextBlock(old)', 'TextBlock(new)']);

      // Each 3-char message is 1 token; a 1-token budget keeps only the newest.
      final limited = prepareBranchEntries(entries, 1);
      expect(limited.messages, hasLength(1));
      expect((limited.messages.single as UserMessage).content.first.toString(),
          'TextBlock(new)');
      expect(limited.totalTokens, 1);
    });

    test('counts tool-call and thinking blocks toward the token budget', () {
      final callEntry = MessageEntry(
          id: 'c1',
          parentId: '',
          timestamp: DateTime(1),
          role: 'assistant',
          message: AssistantMessage(content: <dynamic>[
            const ToolCallBlock(
                id: 't1',
                name: 'read',
                arguments: <String, dynamic>{'path': 'a.dart'}),
          ]));
      final thinkingEntry = MessageEntry(
          id: 't1',
          parentId: '',
          timestamp: DateTime(2),
          role: 'assistant',
          message: AssistantMessage(
              content: <dynamic>[const ThinkingBlock('abcd')]));

      // Upstream counts name.length + JSON.stringify(arguments).length for a
      // tool call and thinking.length for a thinking block; chars/4, ceil.
      final callChars = 'read'.length + '{"path":"a.dart"}'.length;
      expect(prepareBranchEntries(<SessionTreeEntry>[callEntry], 0).totalTokens,
          (callChars / 4).ceil());
      expect(
          prepareBranchEntries(<SessionTreeEntry>[thinkingEntry], 0).totalTokens,
          1);

      // A tool-call-only turn that exceeds the budget must not be kept — this
      // was the bug when only text blocks contributed tokens (estimate 0).
      expect(prepareBranchEntries(<SessionTreeEntry>[callEntry], 1).messages,
          isEmpty);
    });

    test('returns no messages for an empty branch', () {
      final prep = prepareBranchEntries(<SessionTreeEntry>[], 0);
      expect(prep.messages, isEmpty);
      expect(prep.totalTokens, 0);
    });
  });
}

/// A minimal read-only session over a fixed entry list, matching the surface
/// `collectEntriesForBranchSummary` consumes.
class FakeSession implements ReadonlySession {
  final List<SessionTreeEntry> _entries;
  final Map<String, SessionTreeEntry> _byId;

  FakeSession(List<SessionTreeEntry> entries)
      : _entries = entries,
        _byId = {for (final e in entries) e.id: e};

  @override
  List<SessionTreeEntry> getBranch(String leafId) {
    final leafFirst = <SessionTreeEntry>[];
    String? current = leafId;
    while (current != null && current.isNotEmpty) {
      final entry = _byId[current];
      if (entry == null) break;
      leafFirst.add(entry);
      current = entry.parentId.isEmpty ? null : entry.parentId;
    }
    return leafFirst.reversed.toList();
  }

  @override
  SessionTreeEntry? getEntry(String id) => _byId[id];

  List<SessionTreeEntry> get allEntries => List<SessionTreeEntry>.unmodifiable(_entries);
}