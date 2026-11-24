// Cross-backend parity: the three backends must agree on the same operations,
// and a deliberately broken backend must fail the shared suite (spec SC-003).

import 'package:pi/durable.dart';
import 'package:test/test.dart';

/// A backend that hands back its own live list instead of a detached read: the
/// exact bug the conformance suite exists to catch.
class _LeakyStorage implements Storage {
  _LeakyStorage(this._inner);

  final Storage _inner;
  final Map<String, Object?> _leak = <String, Object?>{};

  @override
  Future<CommitResult> commit(
    List<List<StorageWrite>> batches,
    void Function(int index, Seq seq) receive,
    Context context,
  ) =>
      _inner.commit(batches, receive, context);

  @override
  void publishing(void Function() publish, Context context) =>
      _inner.publishing(publish, context);

  @override
  Future<Id<K>> mintId<K extends Object>() => _inner.mintId<K>();

  @override
  Future<ConversationRecord?> conversation(
          ConversationId id, Context context) =>
      _inner.conversation(id, context);

  @override
  Future<Page<ConversationRecord>> scanConversations(
    ConversationQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  ) =>
      _inner.scanConversations(query, limit, cursor, context);

  @override
  Future<({EntryRecord entry, Seq commitSeq})?> entry(
      EntryId id, Context context) async {
    final found = await _inner.entry(id, context);
    if (found == null) return null;
    // The leak: the SAME container is handed out on every read.
    final shared = _leak.putIfAbsent('entry', () => found.entry);
    return (entry: shared! as EntryRecord, commitSeq: found.commitSeq);
  }

  @override
  Future<({EntryRecord entry, Seq commitSeq})?> entryIn(
          ConversationId conversationId, EntryId id, Context context) =>
      _inner.entryIn(conversationId, id, context);

  @override
  Future<({EntryRecord entry, EntryId head})?> findLatestHeadMarker(
    ConversationId conversationId,
    EntryId? atOrBefore,
    Context context,
  ) =>
      _inner.findLatestHeadMarker(conversationId, atOrBefore, context);

  @override
  Future<Page<EntryRecord>> scanEntries(
          EntryQuery query, int limit, Cursor? cursor, Context context) =>
      _inner.scanEntries(query, limit, cursor, context);

  @override
  Future<TaskRecord<Object?, Object?, Object?>?> task(
          TaskId id, Context context) =>
      _inner.task(id, context);

  @override
  Future<Page<TaskRecord<Object?, Object?, Object?>>> scanTasks(
    TaskQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  ) =>
      _inner.scanTasks(query, limit, cursor, context);

  @override
  Future<SubmissionRecord?> submission(SubmissionId id, Context context) =>
      _inner.submission(id, context);

  @override
  Future<Page<SubmissionRecord>> scanSubmissions(
    SubmissionQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  ) =>
      _inner.scanSubmissions(query, limit, cursor, context);

  @override
  Future<SubmissionRecord?> submissionByRequest(
          ConversationId conversationId, String requestId, Context context) =>
      _inner.submissionByRequest(conversationId, requestId, context);

  @override
  Future<DocumentRecord?> findDocument(
          DocumentAddress address, DocumentPoint at, Context context) =>
      _inner.findDocument(address, at, context);

  @override
  Future<StoredDocument?> document(
          DocumentId id, DocumentPoint at, Context context) =>
      _inner.document(id, at, context);

  @override
  Future<Page<DocumentRecord>> scanDocuments(
    DocumentQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  ) =>
      _inner.scanDocuments(query, limit, cursor, context);

  @override
  Future<void> close(Context context) => _inner.close(context);
}

class _Assertions implements ConformanceAssertions {
  @override
  void ok(bool value, [String? message]) =>
      expect(value, isTrue, reason: message);

  @override
  void strictEqual(Object? actual, Object? expected) =>
      expect(actual, equals(expected));

  @override
  void deepEqual(Object? actual, Object? expected) =>
      expect(actual, equals(expected));

  @override
  void partialDeepEqual(Object? actual, Object? expected) =>
      expect(actual, equals(expected));

  @override
  void greaterThan(int actual, int expected) => expect(actual,
      predicate<int>((value) => value > expected, 'greater than $expected'));

  @override
  Future<void> rejects(
      Future<Object?> operation, String messageIncludes) async {
    await expectLater(operation,
        throwsA(predicate((error) => '$error'.contains(messageIncludes))));
  }
}

void main() {
  final assertions = _Assertions();
  final detachedCase = createStorageConformance().firstWhere(
      (testCase) => testCase.name.startsWith('detaches retained writes'));

  test('an honest backend passes the detachment case', () async {
    await detachedCase.run(MemoryStorage(), assertions);
  });

  test('a backend that shares a read container fails the suite and is named',
      () async {
    final broken = _LeakyStorage(MemoryStorage());
    await expectLater(detachedCase.run(broken, assertions), throwsA(anything));
  });
}
