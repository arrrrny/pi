/// The shared storage conformance suite every backend must pass unchanged.
///
/// Port of `packages/durable/src/testing/storage-conformance.ts` at upstream
/// `780bf31fcaeb252fa9b68df3964c735eae75bde3`. A backend that fails any case is
/// not a conforming backend, regardless of its own tests.
///
/// The suite takes an assertion facade so this library keeps no dependency on a
/// test framework; a test registers it once per backend and supplies the
/// assertions.
library;

import '../../chord/context.dart';
import '../../chord/delta.dart';
import '../../chord/ids.dart';
import '../../chord/json.dart';
import '../types.dart';
import 'storage.dart';

/// A task record with input, checkpoint and result left as JSON.
typedef ConformanceTask = TaskRecord<Object?, Object?, Object?>;

/// The assertions a conformance case needs.
abstract interface class ConformanceAssertions {
  /// Assert [value] is truthy, reporting [message] when it is not.
  void ok(bool value, [String? message]);

  /// Assert [actual] equals [expected] by identity/value equality.
  void strictEqual(Object? actual, Object? expected);

  /// Assert [actual] deep-equals [expected].
  void deepEqual(Object? actual, Object? expected);

  /// Assert [actual] deep-contains every field of [expected].
  void partialDeepEqual(Object? actual, Object? expected);

  /// Assert [actual] is greater than [expected].
  void greaterThan(int actual, int expected);

  /// Assert [operation] rejects with a message containing [messageIncludes].
  Future<void> rejects(Future<Object?> operation, String messageIncludes);
}

/// One conformance case.
class StorageConformanceCase {
  /// A case named [name] that runs [run].
  const StorageConformanceCase(this.name, this.run);

  /// The case's name, as the upstream suite words it.
  final String name;

  /// Run the case against [storage].
  final Future<void> Function(Storage storage, ConformanceAssertions assertions)
      run;
}

/// Commit [writes] as one batch and resolve with its seq.
///
/// Rejects with the refusal when the storage refused the batch.
Future<Seq> commitWrites(
    Storage storage, List<StorageWrite> writes, Context context) async {
  Seq? stored;
  final result = await storage.commit(
      <List<StorageWrite>>[writes], (index, seq) => stored = seq, context);
  if (result is CommitRefused) throw result.refused;
  return stored!;
}

/// The upstream suite's cases, in its order.
List<StorageConformanceCase> createStorageConformance() =>
    <StorageConformanceCase>[
      StorageConformanceCase(
          'reserves ID 1 for the immutable root conversation', _rootId),
      StorageConformanceCase(
          'receives a durable commit once before resolving, and never a refused one',
          _receipts),
      StorageConformanceCase(
          'commits mixed table writes atomically and rolls all of them back on failure',
          _mixedRollback),
      StorageConformanceCase(
          'detaches retained writes and every returned record',
          _detachedValues),
      StorageConformanceCase(
          'detaches special JSON keys without changing how they read back',
          _specialKeys),
      StorageConformanceCase(
          'indexes entries committed out of ID order', _outOfOrderEntries),
      StorageConformanceCase(
          'continues an entry cursor below its last item after a newer commit',
          _entryCursor),
      StorageConformanceCase(
          'paginates conversations by opaque cursor in ascending ID order',
          _conversationPaging),
      StorageConformanceCase(
          'filters and pages conversations by durable owner edges',
          _conversationOwners),
      StorageConformanceCase(
          'scans deep fork history newest-first through every ancestor cap',
          _forkHistory),
      StorageConformanceCase(
          'scans tables in either ID order and continues a cursor in its order',
          _scanOrders),
      StorageConformanceCase(
          'replaces complete task records and pages filtered task scans',
          _taskRecords),
      StorageConformanceCase(
          'stores owners and scans waiting and completing tasks by status',
          _taskStatuses),
      StorageConformanceCase(
          'stores and scans sleeping tasks by status', _sleepingTasks),
      StorageConformanceCase(
          'round-trips sleeps on signals, any waits, and wakes', _wakes),
      StorageConformanceCase(
          'indexes request IDs per conversation and replaces complete submission records',
          _requestIds),
      StorageConformanceCase(
          'stores passive write submissions without input-only lifecycle states',
          _writeSubmissions),
      StorageConformanceCase(
          'stores continue submissions, which have no entry and are never queued',
          _continueSubmissions),
      StorageConformanceCase(
          'reconstructs rewindable documents and preserves half-open incarnations',
          _rewindable),
      StorageConformanceCase(
          'streams long document tails across root replacement deltas',
          _longTail),
      StorageConformanceCase(
          'copies stored document bases independently and rejects ambiguous sources',
          _copies),
      StorageConformanceCase(
          'uses bases for version transitions and rejects historical reads of current-only documents',
          _versionTransitions),
      StorageConformanceCase(
          'indexes logical addresses and exact-scope scans independently',
          _addresses),
      StorageConformanceCase(
          'keeps document lifecycle failures atomic and gives create-plus-retire an empty lifetime',
          _lifecycle),
      StorageConformanceCase(
          'refuses a creation and a change of one document in one commit, in either order',
          _doubleContent),
      StorageConformanceCase(
          'rolls back record tables and secondary indexes when a document command fails',
          _documentRollback),
      StorageConformanceCase(
          'keeps indexed string identities lossless', _losslessStrings),
      StorageConformanceCase(
          'keeps one global record ID namespace and rejects exhausted ID minting',
          _globalNamespace),
      StorageConformanceCase(
          'commits batches in order, each with its seq, checked against the earlier ones',
          _batchOrder),
      StorageConformanceCase(
          'stores the batches before the first one refused, and none after it',
          _batchRefusal),
      StorageConformanceCase(
          'refuses a later batch its own malformed actions fail, keeping the batches before it',
          _malformedBatch),
      StorageConformanceCase(
          'resolves a batched copy against the state the earlier batches left',
          _batchedCopy),
      StorageConformanceCase(
          'rejects every operation after close', _afterClose),
    ];

// ── helpers ──────────────────────────────────────────────────────────────────

const Context _context = backgroundContext;

Future<ConversationId> _createRoot(Storage storage) async {
  await commitWrites(
      storage,
      <StorageWrite>[
        ConversationWrite(const ConversationRecord(id: rootConversationId))
      ],
      _context);
  return rootConversationId;
}

ConformanceTask _pendingTask(TaskId id, ConversationId conversationId,
        [String phase = 'ready']) =>
    TaskRecord<Object?, Object?, Object?>(
      id: id,
      conversationId: conversationId,
      kind: 'test.task',
      version: 1,
      input: <String, Object?>{'value': id.value},
      state: TaskPending<Object?, Object?>(<String, Object?>{'phase': phase}),
    );

EntryRecord _entry(EntryId id, ConversationId conversationId,
    [String kind = 'message',
    Map<String, Object?> extra = const <String, Object?>{}]) {
  final model = extra['model'] as List<Object?>?;
  final data = extra['data'];
  final head = extra['head'] as int?;
  return EntryRecord(
    id: id,
    conversationId: conversationId,
    kind: kind,
    model: model,
    data: data,
    head: head == null ? null : idFromNumber<EntryKind>(head),
  );
}

List<int> _ids(Object? items) => <int>[
      for (final item in items! as Iterable<Object?>)
        (item! as dynamic).id.value as int
    ];

const int _maxSafeId = 9007199254740991;

// ── cases ────────────────────────────────────────────────────────────────────

Future<void> _rootId(Storage storage, ConformanceAssertions expect) async {
  expect.strictEqual((await storage.mintId<ConversationKind>()).value, 2);
  expect.strictEqual((await _createRoot(storage)).value, 1);
  expect.deepEqual(
      (await storage.conversation(rootConversationId, _context))!.toJson(),
      <String, Object?>{'id': 1});
  await expect.rejects(
    commitWrites(
        storage,
        <StorageWrite>[
          ConversationWrite(const ConversationRecord(id: rootConversationId))
        ],
        _context),
    'ID 1 already belongs to conversation',
  );
}

Future<void> _receipts(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final events = <String>[];
  final entryId = await storage.mintId<EntryKind>();
  Future<Object?>? read;
  Seq? seq;
  final result = await storage.commit(
    <List<StorageWrite>>[
      <StorageWrite>[EntryWrite(_entry(entryId, rootId))],
    ],
    (index, received) {
      seq = received;
      events.add('receive ${received.value}');
      read = storage.entry(entryId, _context);
    },
    _context,
  );
  events.add('resolve ${result.stored}');
  expect.deepEqual(events, <String>['receive ${seq!.value}', 'resolve 1']);
  expect.strictEqual(
      ((await read! as ({EntryRecord entry, Seq commitSeq})?)!).commitSeq.value,
      seq!.value);

  events.clear();
  final refused = await storage.commit(
    <List<StorageWrite>>[
      <StorageWrite>[ConversationWrite(ConversationRecord(id: rootId))],
    ],
    (index, received) => events.add('receive ${received.value}'),
    _context,
  );
  expect.strictEqual(refused.stored, 0);
  expect.ok(refused is CommitRefused &&
      '${refused.refused}'.contains('ID 1 already belongs to conversation'));
  expect.deepEqual(events, <String>[]);

  final next = await commitWrites(
      storage,
      <StorageWrite>[
        EntryWrite(_entry(await storage.mintId<EntryKind>(), rootId))
      ],
      _context);
  expect.greaterThan(next.value, seq!.value);
}

Future<void> _mixedRollback(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final entryId = await storage.mintId<EntryKind>();
  final taskId = await storage.mintId<TaskKind>();
  final submissionId = await storage.mintId<SubmissionKind>();
  final task = _pendingTask(taskId, rootId);
  final input = SubmissionRecord(
    id: submissionId,
    conversationId: rootId,
    requestId: 'request-1',
    type: 'input',
    status: 'placed',
    entry: entryId,
  );
  final initialSeq = await commitWrites(
      storage,
      <StorageWrite>[
        EntryWrite(_entry(entryId, rootId, 'user', <String, Object?>{
          'data': <String, Object?>{'text': 'hello'}
        })),
        TaskWrite(task),
        SubmissionWrite(input),
      ],
      _context);

  final storedEntry = (await storage.entry(entryId, _context))!;
  expect.strictEqual(storedEntry.entry.kind, 'user');
  expect.deepEqual(storedEntry.entry.data, <String, Object?>{'text': 'hello'});
  expect.strictEqual(storedEntry.commitSeq.value, initialSeq.value);
  expect.deepEqual(
      (await storage.task(taskId, _context))!.toJson(), task.toJson());
  expect.deepEqual((await storage.submission(submissionId, _context))!.toJson(),
      input.toJson());

  final transientEntryId = await storage.mintId<EntryKind>();
  final runningTask = task.withState(
      TaskRunning<Object?, Object?>(<String, Object?>{'phase': 'effect'}));
  await expect.rejects(
    commitWrites(
        storage,
        <StorageWrite>[
          TaskWrite(runningTask),
          SubmissionWrite(
              input.withStatus(status: 'done', answer: transientEntryId)),
          EntryWrite(_entry(transientEntryId, rootId, 'assistant')),
          ConversationWrite(ConversationRecord(id: rootId)),
        ],
        _context),
    'ID 1 already belongs to conversation',
  );

  expect.deepEqual(
      (await storage.task(taskId, _context))!.toJson(), task.toJson());
  expect.deepEqual((await storage.submission(submissionId, _context))!.toJson(),
      input.toJson());
  expect.ok((await storage.entry(transientEntryId, _context)) == null);
  final afterRollbackSeq = await commitWrites(
      storage,
      <StorageWrite>[
        EntryWrite(
            _entry(await storage.mintId<EntryKind>(), rootId, 'after-rollback'))
      ],
      _context);
  expect.greaterThan(afterRollbackSeq.value, initialSeq.value);
}

Future<void> _detachedValues(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final entryId = await storage.mintId<EntryKind>();
  final taskId = await storage.mintId<TaskKind>();
  final submissionId = await storage.mintId<SubmissionKind>();
  final entryData = <String, Object?>{
    'nested': <Object?>[1, 2]
  };
  final checkpoint = <String, Object?>{
    'phase': 'ready',
    'nested': <String, Object?>{'count': 1}
  };
  final detail = <String, Object?>{
    'codes': <Object?>['initial']
  };
  await commitWrites(
      storage,
      <StorageWrite>[
        EntryWrite(_entry(
            entryId, rootId, 'note', <String, Object?>{'data': entryData})),
        TaskWrite(TaskRecord<Object?, Object?, Object?>(
          id: taskId,
          conversationId: rootId,
          kind: 'test.task',
          version: 1,
          input: <String, Object?>{'value': taskId.value},
          state: TaskPending<Object?, Object?>(checkpoint),
        )),
        SubmissionWrite(SubmissionRecord(
          id: submissionId,
          conversationId: rootId,
          type: 'input',
          status: 'unanswered',
          reason: 'failed',
          detail: detail,
        )),
      ],
      _context);

  (entryData['nested']! as List<Object?>).add(3);
  (checkpoint['nested']! as Map<String, Object?>)['count'] = 2;
  (detail['codes']! as List<Object?>).add('mutated');
  expect.deepEqual(
      (await storage.entry(entryId, _context))!.entry.data, <String, Object?>{
    'nested': <Object?>[1, 2]
  });
  expect.deepEqual(
      ((await storage.task(taskId, _context))!.state
              as TaskPending<Object?, Object?>)
          .checkpoint,
      <String, Object?>{
        'phase': 'ready',
        'nested': <String, Object?>{'count': 1}
      });
  expect.deepEqual(
      (await storage.submission(submissionId, _context))!.detail,
      <String, Object?>{
        'codes': <Object?>['initial']
      });

  final readEntry = (await storage.entry(entryId, _context))!.entry;
  ((readEntry.data! as Map<String, Object?>)['nested']! as List<Object?>)
      .add(9);
  final readTask = (await storage.task(taskId, _context))!;
  (((readTask.state as TaskPending<Object?, Object?>).checkpoint
      as Map<String, Object?>)['nested']! as Map<String, Object?>)['count'] = 9;
  (((await storage.submission(submissionId, _context))!.detail!
          as Map<String, Object?>)['codes']! as List<Object?>)
      .add('read mutation');

  expect.deepEqual(
      (await storage.entry(entryId, _context))!.entry.data, <String, Object?>{
    'nested': <Object?>[1, 2]
  });
  expect.deepEqual(
      ((await storage.task(taskId, _context))!.state
              as TaskPending<Object?, Object?>)
          .checkpoint,
      <String, Object?>{
        'phase': 'ready',
        'nested': <String, Object?>{'count': 1}
      });
  expect.deepEqual(
      (await storage.submission(submissionId, _context))!.detail,
      <String, Object?>{
        'codes': <Object?>['initial']
      });
}

Future<void> _specialKeys(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final entryId = await storage.mintId<EntryKind>();
  final data = <String, Object?>{
    '__proto__': <String, Object?>{'polluted': false},
    'constructor': <String, Object?>{'label': 'stored'},
    'toString': 'value',
  };
  await commitWrites(
      storage,
      <StorageWrite>[
        EntryWrite(
            _entry(entryId, rootId, 'note', <String, Object?>{'data': data})),
      ],
      _context);

  (data['__proto__']! as Map<String, Object?>)['polluted'] = true;
  (data['constructor']! as Map<String, Object?>)['label'] = 'mutated';
  final firstRead = (await storage.entry(entryId, _context))!.entry.data!
      as Map<String, Object?>;
  expect
      .deepEqual(firstRead['__proto__'], <String, Object?>{'polluted': false});
  expect.deepEqual(
      firstRead['constructor'], <String, Object?>{'label': 'stored'});
  expect.strictEqual(firstRead['toString'], 'value');

  (firstRead['__proto__']! as Map<String, Object?>)['polluted'] = true;
  final secondRead = (await storage.entry(entryId, _context))!.entry.data!
      as Map<String, Object?>;
  expect
      .deepEqual(secondRead['__proto__'], <String, Object?>{'polluted': false});
  expect.deepEqual(
      secondRead['constructor'], <String, Object?>{'label': 'stored'});
  expect.strictEqual(secondRead['toString'], 'value');
}

Future<void> _outOfOrderEntries(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  await commitWrites(
      storage,
      <StorageWrite>[
        EntryWrite(_entry(idFromNumber<EntryKind>(30), rootId)),
        EntryWrite(_entry(idFromNumber<EntryKind>(10), rootId)),
        EntryWrite(_entry(idFromNumber<EntryKind>(20), rootId, 'marker',
            <String, Object?>{'head': 10})),
      ],
      _context);

  expect.deepEqual(
    _ids((await storage.scanEntries(
            EntryQuery(conversationId: rootId), 10, null, _context))
        .items),
    <int>[30, 20, 10],
  );
  expect.strictEqual(
      (await storage.findLatestHeadMarker(rootId, null, _context))!
          .entry
          .id
          .value,
      20);
}

Future<void> _entryCursor(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final oldestId = await storage.mintId<EntryKind>();
  final middleId = await storage.mintId<EntryKind>();
  final newestId = await storage.mintId<EntryKind>();
  await commitWrites(
      storage,
      <StorageWrite>[
        EntryWrite(_entry(oldestId, rootId)),
        EntryWrite(_entry(middleId, rootId)),
        EntryWrite(_entry(newestId, rootId)),
      ],
      _context);

  final first = await storage.scanEntries(
      EntryQuery(conversationId: rootId), 2, null, _context);
  expect.deepEqual(_ids(first.items), <int>[newestId.value, middleId.value]);
  final appendedId = await storage.mintId<EntryKind>();
  await commitWrites(storage,
      <StorageWrite>[EntryWrite(_entry(appendedId, rootId))], _context);
  final second = await storage.scanEntries(
      EntryQuery(conversationId: rootId), 2, first.next, _context);
  expect.deepEqual(_ids(second.items), <int>[oldestId.value]);
  expect.ok(second.next == null);
}

Future<void> _conversationPaging(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final secondId = await storage.mintId<ConversationKind>();
  final thirdId = await storage.mintId<ConversationKind>();
  await commitWrites(
      storage,
      <StorageWrite>[
        ConversationWrite(ConversationRecord(id: thirdId)),
        ConversationWrite(ConversationRecord(id: secondId)),
      ],
      _context);

  final first = await storage.scanConversations(
      const ConversationQuery(), 2, null, _context);
  expect.deepEqual(_ids(first.items), <int>[rootId.value, secondId.value]);
  expect.ok(first.next != null);
  final roundTripped =
      Cursor.fromJson(Map<String, Object?>.from(first.next!.toJson()));
  final second = await storage.scanConversations(
      const ConversationQuery(), 2, roundTripped, _context);
  expect.deepEqual(_ids(second.items), <int>[thirdId.value]);
  expect.ok(second.next == null);
}

Future<void> _conversationOwners(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final otherOwnerId = await storage.mintId<ConversationKind>();
  final firstTaskId = await storage.mintId<TaskKind>();
  final secondTaskId = await storage.mintId<TaskKind>();
  final firstId = await storage.mintId<ConversationKind>();
  final secondId = await storage.mintId<ConversationKind>();
  final thirdId = await storage.mintId<ConversationKind>();
  await commitWrites(
      storage,
      <StorageWrite>[
        ConversationWrite(ConversationRecord(id: otherOwnerId)),
        ConversationWrite(ConversationRecord(
          id: firstId,
          owner: ConversationOwner(conversationId: rootId, taskId: firstTaskId),
        )),
        ConversationWrite(ConversationRecord(
          id: secondId,
          owner:
              ConversationOwner(conversationId: rootId, taskId: secondTaskId),
        )),
        ConversationWrite(ConversationRecord(
          id: thirdId,
          owner: ConversationOwner(
              conversationId: otherOwnerId, taskId: firstTaskId),
        )),
      ],
      _context);

  final first = await storage.scanConversations(
      ConversationQuery(ownerConversationId: rootId), 1, null, _context);
  expect.deepEqual(_ids(first.items), <int>[firstId.value]);
  expect.ok(first.next != null);
  final second = await storage.scanConversations(
      ConversationQuery(ownerConversationId: rootId), 1, first.next, _context);
  expect.deepEqual(_ids(second.items), <int>[secondId.value]);
  expect.ok(second.next == null);
  expect.deepEqual(
    _ids((await storage.scanConversations(
            ConversationQuery(ownerTaskId: firstTaskId), 10, null, _context))
        .items),
    <int>[firstId.value, thirdId.value],
  );
  expect.deepEqual(
    _ids((await storage.scanConversations(
      ConversationQuery(ownerConversationId: rootId, ownerTaskId: firstTaskId),
      10,
      null,
      _context,
    ))
        .items),
    <int>[firstId.value],
  );
}

Future<void> _forkHistory(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final rootFirst = await storage.mintId<EntryKind>();
  final rootForkPoint = await storage.mintId<EntryKind>();
  final rootExcludedSameCommit = await storage.mintId<EntryKind>();
  final rootEntriesSeq = await commitWrites(
      storage,
      <StorageWrite>[
        EntryWrite(_entry(rootFirst, rootId)),
        EntryWrite(_entry(rootForkPoint, rootId, 'marker',
            <String, Object?>{'head': rootFirst.value})),
        EntryWrite(_entry(rootExcludedSameCommit, rootId)),
      ],
      _context);
  final childId = await storage.mintId<ConversationKind>();
  await commitWrites(
      storage,
      <StorageWrite>[
        ConversationWrite(ConversationRecord(
          id: childId,
          parent: ConversationParent(conversationId: rootId, at: rootForkPoint),
        )),
      ],
      _context);
  final childForkPoint = await storage.mintId<EntryKind>();
  final childExcluded = await storage.mintId<EntryKind>();
  await commitWrites(
      storage,
      <StorageWrite>[
        EntryWrite(_entry(childForkPoint, childId, 'note')),
        EntryWrite(_entry(childExcluded, childId)),
      ],
      _context);
  final rootExcludedLater = await storage.mintId<EntryKind>();
  await commitWrites(storage,
      <StorageWrite>[EntryWrite(_entry(rootExcludedLater, rootId))], _context);
  final grandchildId = await storage.mintId<ConversationKind>();
  await commitWrites(
      storage,
      <StorageWrite>[
        ConversationWrite(ConversationRecord(
          id: grandchildId,
          parent:
              ConversationParent(conversationId: childId, at: childForkPoint),
        )),
      ],
      _context);
  final grandchildHead = await storage.mintId<EntryKind>();
  final grandchildTail = await storage.mintId<EntryKind>();
  final grandchildEntriesSeq = await commitWrites(
      storage,
      <StorageWrite>[
        EntryWrite(_entry(grandchildHead, grandchildId, 'marker',
            <String, Object?>{'head': grandchildHead.value})),
        EntryWrite(_entry(grandchildTail, grandchildId)),
      ],
      _context);
  final childExcludedLater = await storage.mintId<EntryKind>();
  await commitWrites(
      storage,
      <StorageWrite>[EntryWrite(_entry(childExcludedLater, childId))],
      _context);

  final first = await storage.scanEntries(
      EntryQuery(conversationId: grandchildId), 2, null, _context);
  expect.deepEqual(
      _ids(first.items), <int>[grandchildTail.value, grandchildHead.value]);
  final second = await storage.scanEntries(
      EntryQuery(conversationId: grandchildId), 2, first.next, _context);
  expect.deepEqual(
      _ids(second.items), <int>[childForkPoint.value, rootForkPoint.value]);
  final third = await storage.scanEntries(
      EntryQuery(conversationId: grandchildId), 2, second.next, _context);
  expect.deepEqual(_ids(third.items), <int>[rootFirst.value]);
  expect.ok(third.next == null);

  const ascending = ScanOrder.ascending;
  final firstUp = await storage.scanEntries(
      EntryQuery(conversationId: grandchildId, order: ascending),
      2,
      null,
      _context);
  expect.deepEqual(
      _ids(firstUp.items), <int>[rootFirst.value, rootForkPoint.value]);
  final secondUp = await storage.scanEntries(
      EntryQuery(conversationId: grandchildId, order: ascending),
      2,
      firstUp.next,
      _context);
  expect.deepEqual(
      _ids(secondUp.items), <int>[childForkPoint.value, grandchildHead.value]);
  final thirdUp = await storage.scanEntries(
      EntryQuery(conversationId: grandchildId), 2, secondUp.next, _context);
  expect.deepEqual(_ids(thirdUp.items), <int>[grandchildTail.value]);
  expect.ok(thirdUp.next == null);
  expect.deepEqual(
    _ids((await storage.scanEntries(
      EntryQuery(
        conversationId: grandchildId,
        order: ascending,
        minEntryId: rootForkPoint,
        maxEntryId: childForkPoint,
      ),
      10,
      null,
      _context,
    ))
        .items),
    <int>[rootForkPoint.value, childForkPoint.value],
  );
  await expect.rejects(
    storage.scanEntries(
        EntryQuery(conversationId: grandchildId, order: ScanOrder.descending),
        2,
        firstUp.next,
        _context),
    'cursor',
  );

  final currentMarker =
      await storage.findLatestHeadMarker(grandchildId, null, _context);
  expect.strictEqual(currentMarker!.entry.id.value, grandchildHead.value);
  expect.strictEqual(currentMarker.head.value, grandchildHead.value);
  final historicalMarker = await storage.findLatestHeadMarker(
      grandchildId, childForkPoint, _context);
  expect.strictEqual(historicalMarker!.entry.id.value, rootForkPoint.value);
  expect.strictEqual(historicalMarker.head.value, rootFirst.value);
  expect.ok(
      (await storage.findLatestHeadMarker(grandchildId, rootFirst, _context)) ==
          null);

  final activeFirst = await storage.scanEntries(
    EntryQuery(conversationId: grandchildId, minEntryId: currentMarker.head),
    1,
    null,
    _context,
  );
  expect.deepEqual(_ids(activeFirst.items), <int>[grandchildTail.value]);
  expect.ok(activeFirst.next != null);
  final activeSecond = await storage.scanEntries(
    EntryQuery(conversationId: grandchildId, minEntryId: currentMarker.head),
    1,
    activeFirst.next,
    _context,
  );
  expect.deepEqual(_ids(activeSecond.items), <int>[grandchildHead.value]);
  expect.ok(activeSecond.next == null);

  expect.ok((await storage.entry(rootFirst, _context))!.commitSeq.value ==
      rootEntriesSeq.value);
  expect.strictEqual(
      (await storage.entry(rootForkPoint, _context))!.commitSeq.value,
      rootEntriesSeq.value);
  expect.strictEqual(
      (await storage.entry(grandchildHead, _context))!.commitSeq.value,
      grandchildEntriesSeq.value);
  expect.ok(
      (await storage.entry(idFromNumber<EntryKind>(999999), _context)) == null);

  expect.ok((await storage.entryIn(grandchildId, rootFirst, _context))!
          .entry
          .conversationId
          .value ==
      rootId.value);
  expect.ok((await storage.entryIn(grandchildId, childForkPoint, _context))!
          .entry
          .conversationId
          .value ==
      childId.value);
  expect.ok(
      (await storage.entryIn(grandchildId, rootExcludedSameCommit, _context)) ==
          null);
  expect.ok(
      (await storage.entryIn(grandchildId, rootExcludedLater, _context)) ==
          null);
  expect.ok(
      (await storage.entryIn(grandchildId, childExcluded, _context)) == null);
  expect.ok(
      (await storage.entryIn(grandchildId, childExcludedLater, _context)) ==
          null);
  expect.ok((await storage.entryIn(rootId, grandchildHead, _context)) == null);
  await expect.rejects(
    storage.entryIn(
        idFromNumber<ConversationKind>(999999), rootFirst, _context),
    'Unknown conversation',
  );
  await expect.rejects(
    storage.scanEntries(
        EntryQuery(conversationId: idFromNumber<ConversationKind>(999999)),
        10,
        null,
        _context),
    'Unknown conversation',
  );
}

Future<void> _scanOrders(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final conversationIds = <int>[rootId.value];
  final taskIds = <int>[];
  final submissionIds = <int>[];
  for (var index = 0; index < 3; index++) {
    final conversationId = await storage.mintId<ConversationKind>();
    final taskId = await storage.mintId<TaskKind>();
    final submissionId = await storage.mintId<SubmissionKind>();
    await commitWrites(
        storage,
        <StorageWrite>[
          ConversationWrite(ConversationRecord(id: conversationId)),
          TaskWrite(_pendingTask(taskId, rootId)),
          SubmissionWrite(SubmissionRecord(
            id: submissionId,
            conversationId: rootId,
            type: 'input',
            status: 'queued',
          )),
        ],
        _context);
    conversationIds.add(conversationId.value);
    taskIds.add(taskId.value);
    submissionIds.add(submissionId.value);
  }

  Future<List<int>> all(
    Future<Page<Object?>> Function(ScanOrder?, Cursor?) scan,
    ScanOrder? order,
  ) async {
    final found = <int>[];
    var page = await scan(order, null);
    found.addAll(_ids(page.items));
    while (page.next != null) {
      page = await scan(null,
          Cursor.fromJson(Map<String, Object?>.from(page.next!.toJson())));
      found.addAll(_ids(page.items));
    }
    return found;
  }

  final scans =
      <(Future<Page<Object?>> Function(ScanOrder?, Cursor?), List<int>)>[
    (
      (order, cursor) => storage
          .scanConversations(
              ConversationQuery(order: order), 2, cursor, _context)
          .then(_erase),
      conversationIds
    ),
    (
      (order, cursor) => storage
          .scanTasks(TaskQuery(order: order), 2, cursor, _context)
          .then(_erase),
      taskIds
    ),
    (
      (order, cursor) => storage
          .scanSubmissions(SubmissionQuery(order: order), 2, cursor, _context)
          .then(_erase),
      submissionIds
    ),
  ];
  for (final (scan, ids) in scans) {
    final reversed = ids.reversed.toList();
    expect.deepEqual(await all(scan, null), ids);
    expect.deepEqual(await all(scan, ScanOrder.ascending), ids);
    expect.deepEqual(await all(scan, ScanOrder.descending), reversed);
    final descending = await scan(ScanOrder.descending, null);
    expect.deepEqual(
        _ids((await scan(ScanOrder.descending, descending.next)).items),
        reversed.skip(2).take(2).toList());
    await expect.rejects(scan(ScanOrder.ascending, descending.next), 'cursor');
  }
}

Page<Object?> _erase<T>(Page<T> page) =>
    Page<Object?>(page.items.cast<Object?>(), next: page.next);

Future<void> _taskRecords(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final firstId = await storage.mintId<TaskKind>();
  final secondId = await storage.mintId<TaskKind>();
  final thirdId = await storage.mintId<TaskKind>();
  final first = TaskRecord<Object?, Object?, Object?>(
    id: firstId,
    conversationId: rootId,
    kind: 'test.task',
    version: 1,
    input: <String, Object?>{'value': firstId.value},
    state: TaskPending<Object?, Object?>(<String, Object?>{'phase': 'ready'}),
    memos: <String, Object?>{'winner': 'first'},
  );
  final second = TaskRecord<Object?, Object?, Object?>(
    id: secondId,
    conversationId: rootId,
    kind: 'test.task',
    version: 1,
    input: <String, Object?>{'value': secondId.value},
    state: TaskPending<Object?, Object?>(<String, Object?>{'phase': 'ready'}),
    background: true,
  );
  final third = TaskRecord<Object?, Object?, Object?>(
    id: thirdId,
    conversationId: rootId,
    kind: 'test.task',
    version: 1,
    input: <String, Object?>{'value': thirdId.value},
    state: TaskPending<Object?, Object?>(<String, Object?>{'phase': 'ready'}),
    abortRequested: true,
  );
  await commitWrites(
      storage,
      <StorageWrite>[TaskWrite(first), TaskWrite(second), TaskWrite(third)],
      _context);

  final running = first
      .withState(TaskRunning<Object?, Object?>(
          <String, Object?>{'phase': 'effect', 'attempt': 1}))
      .withAbort(abortRequested: true);
  await commitWrites(storage, <StorageWrite>[TaskWrite(running)], _context);
  expect.deepEqual(
      (await storage.task(firstId, _context))!.toJson(), running.toJson());
  final terminal = TaskRecord<Object?, Object?, Object?>(
    id: firstId,
    conversationId: rootId,
    kind: first.kind,
    version: 1,
    input: first.input,
    state: TaskTerminal<Object?, Object?>(
      TaskCompleted<Object?>(<String, Object?>{'entryId': 99}),
    ),
    abortRequested: true,
  );
  await commitWrites(storage, <StorageWrite>[TaskWrite(terminal)], _context);
  expect.deepEqual(
      (await storage.task(firstId, _context))!.toJson(), terminal.toJson());

  final pendingPage = await storage.scanTasks(
      const TaskQuery(status: 'pending'), 1, null, _context);
  expect.deepEqual(_ids(pendingPage.items), <int>[secondId.value]);
  expect.ok(pendingPage.next != null);
  expect.deepEqual(
    _ids((await storage.scanTasks(
            const TaskQuery(status: 'pending'), 1, pendingPage.next, _context))
        .items),
    <int>[thirdId.value],
  );
  expect.deepEqual(
    _ids((await storage.scanTasks(
            const TaskQuery(status: 'terminal', abortRequested: true),
            10,
            null,
            _context))
        .items),
    <int>[firstId.value],
  );
  expect.deepEqual(
    _ids((await storage.scanTasks(
            const TaskQuery(background: true), 10, null, _context))
        .items),
    <int>[secondId.value],
  );
}

Future<void> _taskStatuses(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final ownerId = await storage.mintId<TaskKind>();
  final waitingId = await storage.mintId<TaskKind>();
  final completingId = await storage.mintId<TaskKind>();
  final owner = _pendingTask(ownerId, rootId);
  final waiting = TaskRecord<Object?, Object?, Object?>(
    id: waitingId,
    conversationId: rootId,
    kind: 'test.task',
    version: 1,
    input: <String, Object?>{'value': waitingId.value},
    owner: ownerId,
    state: TaskWaiting<Object?, Object?>(
      <String, Object?>{'phase': 'next'},
      on: <TaskId>[ownerId],
      policy: JoinPolicy.allSettled,
    ),
    memos: <String, Object?>{'kept': true},
  );
  final completing = TaskRecord<Object?, Object?, Object?>(
    id: completingId,
    conversationId: rootId,
    kind: 'test.task',
    version: 1,
    input: <String, Object?>{'value': completingId.value},
    owner: ownerId,
    state: TaskCompleting<Object?, Object?>(
      TaskFailed<Object?>(const TaskOutcomeError('held')),
    ),
  );
  await commitWrites(
      storage,
      <StorageWrite>[
        TaskWrite(owner),
        TaskWrite(waiting),
        TaskWrite(completing)
      ],
      _context);
  expect.deepEqual(
      (await storage.task(waitingId, _context))!.toJson(), waiting.toJson());
  expect.deepEqual((await storage.task(completingId, _context))!.toJson(),
      completing.toJson());
  Future<List<int>> scan(String status) async => _ids(
      (await storage.scanTasks(TaskQuery(status: status), 10, null, _context))
          .items);
  expect.deepEqual(await scan('waiting'), <int>[waitingId.value]);
  expect.deepEqual(await scan('completing'), <int>[completingId.value]);
  expect.deepEqual(await scan('pending'), <int>[ownerId.value]);
  final terminal = completing.withState(TaskTerminal<Object?, Object?>(
      (completing.state as TaskCompleting<Object?, Object?>).outcome));
  await commitWrites(storage, <StorageWrite>[TaskWrite(terminal)], _context);
  expect.deepEqual(await scan('completing'), <int>[]);
  expect.deepEqual(await scan('terminal'), <int>[completingId.value]);
}

Future<void> _sleepingTasks(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final sleepingId = await storage.mintId<TaskKind>();
  final sleeping = TaskRecord<Object?, Object?, Object?>(
    id: sleepingId,
    conversationId: rootId,
    kind: 'test.task',
    version: 1,
    input: <String, Object?>{'value': sleepingId.value},
    state: TaskSleeping<Object?, Object?>(<String, Object?>{'phase': 'next'},
        until: 61000),
    memos: <String, Object?>{'kept': true},
  );
  await commitWrites(storage, <StorageWrite>[TaskWrite(sleeping)], _context);
  expect.deepEqual(
      (await storage.task(sleepingId, _context))!.toJson(), sleeping.toJson());
  Future<List<int>> scan(String status) async => _ids(
      (await storage.scanTasks(TaskQuery(status: status), 10, null, _context))
          .items);
  expect.deepEqual(await scan('sleeping'), <int>[sleepingId.value]);
  final running = sleeping.withState(
      TaskRunning<Object?, Object?>(<String, Object?>{'phase': 'next'}));
  await commitWrites(storage, <StorageWrite>[TaskWrite(running)], _context);
  expect.deepEqual(await scan('sleeping'), <int>[]);
  expect.deepEqual(await scan('running'), <int>[sleepingId.value]);
}

Future<void> _wakes(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final ids = <TaskId>[];
  for (var index = 0; index < 5; index++) {
    ids.add(await storage.mintId<TaskKind>());
  }
  final signals = <SignalName>[const SignalName('a')];
  final memos = <String, Object?>{
    'pi.signal.app.answer/a': <String, Object?>{
      'version': 1,
      'value': <String, Object?>{'text': 'yes'}
    },
  };
  final tasks = <ConformanceTask>[
    TaskRecord<Object?, Object?, Object?>(
      id: ids[0],
      conversationId: rootId,
      kind: 'test.task',
      version: 1,
      input: <String, Object?>{'value': ids[0].value},
      state: TaskSleeping<Object?, Object?>(<String, Object?>{'phase': 'next'},
          signals: signals),
    ),
    TaskRecord<Object?, Object?, Object?>(
      id: ids[1],
      conversationId: rootId,
      kind: 'test.task',
      version: 1,
      input: <String, Object?>{'value': ids[1].value},
      state: TaskSleeping<Object?, Object?>(<String, Object?>{'phase': 'next'},
          until: 61000, signals: signals),
      memos: memos,
    ),
    TaskRecord<Object?, Object?, Object?>(
      id: ids[2],
      conversationId: rootId,
      kind: 'test.task',
      version: 1,
      input: <String, Object?>{'value': ids[2].value},
      state: TaskWaiting<Object?, Object?>(
        <String, Object?>{'phase': 'next'},
        on: <TaskId>[ids[0], ids[1]],
        policy: JoinPolicy.any,
      ),
    ),
    TaskRecord<Object?, Object?, Object?>(
      id: ids[3],
      conversationId: rootId,
      kind: 'test.task',
      version: 1,
      input: <String, Object?>{'value': ids[3].value},
      state: TaskPending<Object?, Object?>(
        <String, Object?>{'phase': 'next'},
        wake: WakeTasks(<TaskId>[ids[0]]),
      ),
    ),
    TaskRecord<Object?, Object?, Object?>(
      id: ids[4],
      conversationId: rootId,
      kind: 'test.task',
      version: 1,
      input: <String, Object?>{'value': ids[4].value},
      state: TaskRunning<Object?, Object?>(
        <String, Object?>{'phase': 'next'},
        wake: const WakeSignal(signal: 'app.answer', key: 'a'),
      ),
    ),
  ];
  await commitWrites(storage,
      <StorageWrite>[for (final task in tasks) TaskWrite(task)], _context);
  for (final task in tasks) {
    expect.deepEqual(
        (await storage.task(task.id, _context))!.toJson(), task.toJson());
  }
  Future<List<int>> scan(String status) async => _ids(
      (await storage.scanTasks(TaskQuery(status: status), 10, null, _context))
          .items);
  expect.deepEqual(await scan('sleeping'), <int>[ids[0].value, ids[1].value]);
  expect.deepEqual(await scan('waiting'), <int>[ids[2].value]);
}

Future<void> _requestIds(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final secondConversationId = await storage.mintId<ConversationKind>();
  await commitWrites(
      storage,
      <StorageWrite>[
        ConversationWrite(ConversationRecord(id: secondConversationId))
      ],
      _context);
  final firstId = await storage.mintId<SubmissionKind>();
  final secondId = await storage.mintId<SubmissionKind>();
  final otherConversationId = await storage.mintId<SubmissionKind>();
  final first = SubmissionRecord(
      id: firstId,
      conversationId: rootId,
      requestId: 'same',
      type: 'input',
      status: 'queued');
  final second = SubmissionRecord(
      id: secondId,
      conversationId: rootId,
      requestId: 'other',
      type: 'input',
      status: 'queued');
  final otherConversation = SubmissionRecord(
    id: otherConversationId,
    conversationId: secondConversationId,
    requestId: 'same',
    type: 'input',
    status: 'queued',
  );
  await commitWrites(
      storage,
      <StorageWrite>[
        SubmissionWrite(first),
        SubmissionWrite(second),
        SubmissionWrite(otherConversation),
      ],
      _context);
  expect.deepEqual(
      (await storage.submissionByRequest(rootId, 'same', _context))!.toJson(),
      first.toJson());
  expect.deepEqual(
    (await storage.submissionByRequest(secondConversationId, 'same', _context))!
        .toJson(),
    otherConversation.toJson(),
  );

  final placedSecond = second.withStatus(
      status: 'placed', entry: await storage.mintId<EntryKind>());
  await commitWrites(
      storage, <StorageWrite>[SubmissionWrite(placedSecond)], _context);
  expect.deepEqual((await storage.submission(secondId, _context))!.toJson(),
      placedSecond.toJson());
  expect.deepEqual(
      (await storage.submissionByRequest(rootId, 'other', _context))!.toJson(),
      placedSecond.toJson());

  Future<List<int>> ids(SubmissionQuery query) async {
    final found = <int>[];
    Cursor? cursor;
    do {
      final page = await storage.scanSubmissions(query, 1, cursor, _context);
      found.addAll(_ids(page.items));
      cursor = page.next;
    } while (cursor != null);
    return found;
  }

  expect.deepEqual(await ids(const SubmissionQuery()),
      <int>[firstId.value, secondId.value, otherConversationId.value]);
  expect.deepEqual(await ids(SubmissionQuery(conversationId: rootId)),
      <int>[firstId.value, secondId.value]);
  expect.deepEqual(await ids(const SubmissionQuery(status: 'queued')),
      <int>[firstId.value, otherConversationId.value]);
  expect.deepEqual(await ids(const SubmissionQuery(status: 'placed')),
      <int>[secondId.value]);
  expect.deepEqual(
    await ids(SubmissionQuery(
        conversationId: secondConversationId, status: 'queued')),
    <int>[otherConversationId.value],
  );
  expect.deepEqual(
      await ids(SubmissionQuery(
          conversationId: secondConversationId, status: 'placed')),
      <int>[]);
}

Future<void> _writeSubmissions(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final doneId = await storage.mintId<SubmissionKind>();
  final failedId = await storage.mintId<SubmissionKind>();
  final queuedDone = SubmissionRecord(
      id: doneId,
      conversationId: rootId,
      requestId: 'passive-done',
      type: 'write',
      status: 'queued');
  final queuedFailed = SubmissionRecord(
      id: failedId,
      conversationId: rootId,
      requestId: 'passive-failed',
      type: 'write',
      status: 'queued');
  await commitWrites(
      storage,
      <StorageWrite>[
        SubmissionWrite(queuedDone),
        SubmissionWrite(queuedFailed)
      ],
      _context);

  final done = queuedDone.withStatus(
      status: 'done', entry: await storage.mintId<EntryKind>());
  final unanswered = queuedFailed.withStatus(
    status: 'unanswered',
    reason: 'closed',
    detail: <String, Object?>{'retryable': false},
  );
  await commitWrites(
      storage,
      <StorageWrite>[SubmissionWrite(done), SubmissionWrite(unanswered)],
      _context);
  expect.deepEqual(
      (await storage.submission(doneId, _context))!.toJson(), done.toJson());
  expect.deepEqual(
      (await storage.submissionByRequest(rootId, 'passive-done', _context))!
          .toJson(),
      done.toJson());
  expect.deepEqual((await storage.submission(failedId, _context))!.toJson(),
      unanswered.toJson());
  expect.deepEqual(
    (await storage.submissionByRequest(rootId, 'passive-failed', _context))!
        .toJson(),
    unanswered.toJson(),
  );
}

Future<void> _continueSubmissions(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final doneId = await storage.mintId<SubmissionKind>();
  final failedId = await storage.mintId<SubmissionKind>();
  final placedDone = SubmissionRecord(
    id: doneId,
    conversationId: rootId,
    requestId: 'continue-done',
    type: 'continue',
    status: 'placed',
  );
  final placedFailed = SubmissionRecord(
    id: failedId,
    conversationId: rootId,
    requestId: 'continue-failed',
    type: 'continue',
    status: 'placed',
  );
  await commitWrites(
      storage,
      <StorageWrite>[
        SubmissionWrite(placedDone),
        SubmissionWrite(placedFailed)
      ],
      _context);
  expect.deepEqual((await storage.submission(doneId, _context))!.toJson(),
      placedDone.toJson());
  expect.deepEqual(
    _ids((await storage.scanSubmissions(
            const SubmissionQuery(status: 'placed'), 10, null, _context))
        .items),
    <int>[doneId.value, failedId.value],
  );

  final done = placedDone.withStatus(
      status: 'done', answer: await storage.mintId<EntryKind>());
  final unanswered = placedFailed.withStatus(
      status: 'unanswered', reason: 'nothing_to_answer');
  await commitWrites(
      storage,
      <StorageWrite>[SubmissionWrite(done), SubmissionWrite(unanswered)],
      _context);
  expect.deepEqual(
      (await storage.submission(doneId, _context))!.toJson(), done.toJson());
  expect.deepEqual(
      (await storage.submissionByRequest(rootId, 'continue-done', _context))!
          .toJson(),
      done.toJson());
  expect.deepEqual((await storage.submission(failedId, _context))!.toJson(),
      unanswered.toJson());
  expect.deepEqual(
    (await storage.submissionByRequest(rootId, 'continue-failed', _context))!
        .toJson(),
    unanswered.toJson(),
  );
}

Future<void> _rewindable(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final firstId = await storage.mintId<DocumentKindId>();
  final firstRecord = DocumentCreate(
    id: firstId,
    kind: 'conversation.notes',
    scope: ConversationScope(rootId),
    history: 'rewindable',
    fork: ForkPolicy.asOf,
  );
  final initial = <String, Object?>{
    'items': <Object?>['a'],
    'nested': <String, Object?>{'count': 1},
  };
  final createdAt = await commitWrites(
      storage,
      <StorageWrite>[
        DocumentCreateWrite(
            record: firstRecord, content: DocumentBase(1, initial)),
      ],
      _context);
  final appended = <Object?>['b'];
  final ops = <Op>[
    OpInsert(<Seg>['items'], 1, 0, appended),
    OpSet(<Seg>['nested', 'count'], 2),
  ];
  final changedAt = await commitWrites(
      storage,
      <StorageWrite>[
        DocumentChangeWrite(id: firstId, content: DocumentDelta(1, ops)),
      ],
      _context);

  (initial['items']! as List<Object?>).add('caller mutation');
  appended.add('caller mutation');
  expect.partialDeepEqual(
      (await storage.document(firstId, SeqPoint(createdAt), _context))!.value,
      <String, Object?>{
        'items': <Object?>['a'],
        'nested': <String, Object?>{'count': 1},
      });
  expect.strictEqual(
      (await storage.document(firstId, SeqPoint(createdAt), _context))!
          .deltasSinceBase,
      0);
  final changed =
      (await storage.document(firstId, SeqPoint(changedAt), _context))!;
  expect.deepEqual(changed.value, <String, Object?>{
    'items': <Object?>['a', 'b'],
    'nested': <String, Object?>{'count': 2},
  });
  expect.strictEqual(changed.deltasSinceBase, 1);
  (changed.value['items']! as List<Object?>).add('read mutation');
  expect.deepEqual(
      (await storage.document(firstId, currentPoint, _context))!.value,
      <String, Object?>{
        'items': <Object?>['a', 'b'],
        'nested': <String, Object?>{'count': 2},
      });

  final checkpointAt = await commitWrites(
      storage,
      <StorageWrite>[
        DocumentChangeWrite(
          id: firstId,
          content: DocumentBase(2, <String, Object?>{
            'items': <Object?>['checkpoint'],
            'nested': <String, Object?>{'count': 3},
          }),
        ),
      ],
      _context);
  final replacedAt = await commitWrites(
      storage,
      <StorageWrite>[
        DocumentChangeWrite(
          id: firstId,
          content: DocumentDelta(2, <Op>[
            OpReplace(<String, Object?>{
              'items': <Object?>['replacement'],
              'nested': <String, Object?>{'count': 4},
            }),
          ]),
        ),
      ],
      _context);
  expect.deepEqual(
      (await storage.document(firstId, SeqPoint(changedAt), _context))!.value,
      <String, Object?>{
        'items': <Object?>['a', 'b'],
        'nested': <String, Object?>{'count': 2},
      });
  expect.partialDeepEqual(
      (await storage.document(firstId, SeqPoint(checkpointAt), _context))!
          .value,
      <String, Object?>{
        'items': <Object?>['checkpoint'],
        'nested': <String, Object?>{'count': 3},
      });
  expect.strictEqual(
      (await storage.document(firstId, SeqPoint(checkpointAt), _context))!
          .deltasSinceBase,
      0);
  expect.deepEqual(
      (await storage.document(firstId, SeqPoint(replacedAt), _context))!.value,
      <String, Object?>{
        'items': <Object?>['replacement'],
        'nested': <String, Object?>{'count': 4},
      });
  expect.strictEqual(
      (await storage.document(firstId, currentPoint, _context))!
          .deltasSinceBase,
      1);

  final secondId = await storage.mintId<DocumentKindId>();
  final retiredAt = await commitWrites(
      storage,
      <StorageWrite>[
        DocumentCreateWrite(
          record: DocumentCreate(
            id: secondId,
            kind: firstRecord.kind,
            scope: firstRecord.scope,
            history: firstRecord.history,
            fork: firstRecord.fork,
          ),
          content: DocumentBase(1, <String, Object?>{
            'items': <Object?>['new'],
          }),
        ),
        DocumentRetireWrite(firstId),
        DocumentChangeWrite(
            id: firstId,
            content: DocumentDelta(2, <Op>[
              OpSet(<Seg>['retiring'], true)
            ])),
      ],
      _context);
  final address =
      DocumentAddress(kind: firstRecord.kind, scope: firstRecord.scope);
  expect.strictEqual(
      (await storage.findDocument(address, SeqPoint(changedAt), _context))!
          .id
          .value,
      firstId.value);
  expect.strictEqual(
      (await storage.findDocument(address, SeqPoint(retiredAt), _context))!
          .id
          .value,
      secondId.value);
  expect.deepEqual(
    _ids((await storage.scanDocuments(
      DocumentQuery(scope: firstRecord.scope, at: SeqPoint(changedAt)),
      10,
      null,
      _context,
    ))
        .items),
    <int>[firstId.value],
  );
  expect.deepEqual(
    _ids((await storage.scanDocuments(
      DocumentQuery(scope: firstRecord.scope, at: SeqPoint(retiredAt)),
      10,
      null,
      _context,
    ))
        .items),
    <int>[secondId.value],
  );
  expect.ok(
      (await storage.document(firstId, SeqPoint(retiredAt), _context)) == null);
  expect.deepEqual(
      (await storage.document(secondId, currentPoint, _context))!.value,
      <String, Object?>{
        'items': <Object?>['new'],
      });
}

Future<void> _longTail(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final id = await storage.mintId<DocumentKindId>();
  final record = DocumentCreate(
    id: id,
    kind: 'conversation.long-tail',
    scope: ConversationScope(rootId),
    history: 'rewindable',
    fork: ForkPolicy.asOf,
  );
  final initial = <String, Object?>{
    'revision': 0,
    'rows': <Object?>[
      for (var value = 0; value < 512; value++)
        <String, Object?>{'value': value, 'stable': 'row-$value'},
    ],
  };
  final createdAt = await commitWrites(
      storage,
      <StorageWrite>[
        DocumentCreateWrite(record: record, content: DocumentBase(1, initial)),
      ],
      _context);
  final beforeReplacement = copyJson(initial)! as Map<String, Object?>;
  var beforeReplacementAt = createdAt;
  final rows = beforeReplacement['rows']! as List<Object?>;
  for (var revision = 1; revision <= 24; revision++) {
    final index = (revision * 17) % rows.length;
    (rows[index]! as Map<String, Object?>)['value'] = -revision;
    beforeReplacement['revision'] = revision;
    beforeReplacementAt = await commitWrites(
        storage,
        <StorageWrite>[
          DocumentChangeWrite(
            id: id,
            content: DocumentDelta(1, <Op>[
              OpSet(<Seg>['rows', index, 'value'], -revision),
              OpSet(<Seg>['revision'], revision),
            ]),
          ),
        ],
        _context);
  }

  final replacement = <String, Object?>{
    'revision': 100,
    'rows': <Object?>[
      for (var value = 0; value < 512; value++)
        <String, Object?>{'value': 10000 + value, 'stable': 'new-$value'},
    ],
  };
  final replacementSnapshot = copyJson(replacement)! as Map<String, Object?>;
  final replacementAt = await commitWrites(
      storage,
      <StorageWrite>[
        DocumentChangeWrite(
            id: id, content: DocumentDelta(1, <Op>[OpReplace(replacement)])),
      ],
      _context);
  (replacement['rows']! as List<Object?>)[0] = <String, Object?>{'value': -999};

  final current = copyJson(replacementSnapshot)! as Map<String, Object?>;
  final currentRows = current['rows']! as List<Object?>;
  for (var revision = 101; revision <= 124; revision++) {
    final index = (revision * 19) % currentRows.length;
    (currentRows[index]! as Map<String, Object?>)['value'] = -revision;
    current['revision'] = revision;
    await commitWrites(
        storage,
        <StorageWrite>[
          DocumentChangeWrite(
            id: id,
            content: DocumentDelta(1, <Op>[
              OpSet(<Seg>['rows', index, 'value'], -revision),
              OpSet(<Seg>['revision'], revision),
            ]),
          ),
        ],
        _context);
  }

  expect.deepEqual(
      (await storage.document(id, SeqPoint(createdAt), _context))!.value,
      initial);
  expect.deepEqual(
      (await storage.document(id, SeqPoint(beforeReplacementAt), _context))!
          .value,
      beforeReplacement);
  expect.deepEqual(
      (await storage.document(id, SeqPoint(replacementAt), _context))!.value,
      replacementSnapshot);
  final read = (await storage.document(id, currentPoint, _context))!;
  expect.deepEqual(read.value, current);
  ((read.value['rows']! as List<Object?>)[0]!
      as Map<String, Object?>)['value'] = -1000;
  expect.deepEqual(
      (await storage.document(id, currentPoint, _context))!.value, current);
}

Future<void> _copies(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final childId = await storage.mintId<ConversationKind>();
  final secondChildId = await storage.mintId<ConversationKind>();
  await commitWrites(
      storage,
      <StorageWrite>[
        ConversationWrite(ConversationRecord(id: childId)),
        ConversationWrite(ConversationRecord(id: secondChildId)),
      ],
      _context);
  final sourceId = await storage.mintId<DocumentKindId>();
  final sourceRecord = DocumentCreate(
    id: sourceId,
    kind: 'copy.source',
    scope: ConversationScope(rootId),
    history: 'rewindable',
    fork: ForkPolicy.asOf,
  );
  final createdAt = await commitWrites(
      storage,
      <StorageWrite>[
        DocumentCreateWrite(
          record: sourceRecord,
          content: DocumentBase(2, <String, Object?>{
            'count': 1,
            'rows': <Object?>[
              <String, Object?>{'value': 'base'},
            ],
          }),
        ),
      ],
      _context);
  await commitWrites(
      storage,
      <StorageWrite>[
        DocumentChangeWrite(
          id: sourceId,
          content: DocumentDelta(2, <Op>[
            OpSet(<Seg>['count'], 2),
            OpInsert(
                <Seg>['rows'],
                1,
                0,
                <Object?>[
                  <String, Object?>{'value': 'current'},
                ]),
          ]),
        ),
      ],
      _context);
  final historicalCopyId = await storage.mintId<DocumentKindId>();
  final currentCopyId = await storage.mintId<DocumentKindId>();
  final retiredCopyId = await storage.mintId<DocumentKindId>();
  DocumentCreate childRecord(DocumentId id, ConversationId conversationId) =>
      DocumentCreate(
        id: id,
        kind: sourceRecord.kind,
        scope: ConversationScope(conversationId),
        history: 'rewindable',
        fork: ForkPolicy.asOf,
      );
  await commitWrites(
      storage,
      <StorageWrite>[
        DocumentCopyWrite(
            record: childRecord(historicalCopyId, childId),
            source: DocumentCopySource(id: sourceId, at: SeqPoint(createdAt))),
        DocumentCopyWrite(
            record: childRecord(currentCopyId, secondChildId),
            source: DocumentCopySource(id: sourceId, at: currentPoint)),
        DocumentCopyWrite(
            record: childRecord(retiredCopyId, rootId),
            source: DocumentCopySource(id: sourceId, at: currentPoint)),
        DocumentRetireWrite(retiredCopyId),
      ],
      _context);
  expect.deepEqual(
      (await storage.document(historicalCopyId, currentPoint, _context))!.value,
      <String, Object?>{
        'count': 1,
        'rows': <Object?>[
          <String, Object?>{'value': 'base'},
        ],
      });
  expect.deepEqual(
      (await storage.document(currentCopyId, currentPoint, _context))!.value,
      <String, Object?>{
        'count': 2,
        'rows': <Object?>[
          <String, Object?>{'value': 'base'},
          <String, Object?>{'value': 'current'},
        ],
      });
  expect.ok(
      (await storage.document(retiredCopyId, currentPoint, _context)) == null);

  await commitWrites(
      storage,
      <StorageWrite>[
        DocumentChangeWrite(
          id: sourceId,
          content: DocumentBase(
              2, <String, Object?>{'count': 99, 'rows': <Object?>[]}),
        ),
        DocumentRetireWrite(sourceId),
      ],
      _context);
  expect.deepEqual(
      (await storage.document(currentCopyId, currentPoint, _context))!.value,
      <String, Object?>{
        'count': 2,
        'rows': <Object?>[
          <String, Object?>{'value': 'base'},
          <String, Object?>{'value': 'current'},
        ],
      });

  final latestSourceId = await storage.mintId<DocumentKindId>();
  final latestCopyId = await storage.mintId<DocumentKindId>();
  final latestSource = DocumentCreate(
    id: latestSourceId,
    kind: 'copy.latest',
    scope: ConversationScope(rootId),
    history: 'latest',
    fork: ForkPolicy.current,
  );
  await commitWrites(
      storage,
      <StorageWrite>[
        DocumentCreateWrite(
            record: latestSource,
            content: DocumentBase(4, <String, Object?>{'retained': 'copy'})),
      ],
      _context);
  await commitWrites(
      storage,
      <StorageWrite>[
        DocumentCopyWrite(
          record: DocumentCreate(
            id: latestCopyId,
            kind: latestSource.kind,
            scope: ConversationScope(childId),
            history: latestSource.history,
            fork: latestSource.fork,
          ),
          source: DocumentCopySource(id: latestSourceId, at: currentPoint),
        ),
      ],
      _context);
  await commitWrites(
      storage,
      <StorageWrite>[
        DocumentChangeWrite(
            id: latestSourceId,
            content:
                DocumentBase(4, <String, Object?>{'retained': 'source-only'})),
        DocumentRetireWrite(latestSourceId),
      ],
      _context);
  expect.deepEqual(
      (await storage.document(latestCopyId, currentPoint, _context))!.value,
      <String, Object?>{'retained': 'copy'});

  final conflictId = await storage.mintId<DocumentKindId>();
  Object? conflictError;
  try {
    await commitWrites(
        storage,
        <StorageWrite>[
          DocumentCopyWrite(
              record: childRecord(conflictId, childId),
              source: DocumentCopySource(id: currentCopyId, at: currentPoint)),
          DocumentRetireWrite(currentCopyId),
        ],
        _context);
  } catch (error) {
    conflictError = error;
  }
  expect.ok(conflictError != null);
  expect
      .ok((await storage.document(conflictId, currentPoint, _context)) == null);
  expect.deepEqual(
      (await storage.document(currentCopyId, currentPoint, _context))!.value,
      <String, Object?>{
        'count': 2,
        'rows': <Object?>[
          <String, Object?>{'value': 'base'},
          <String, Object?>{'value': 'current'},
        ],
      });

  final mismatchId = await storage.mintId<DocumentKindId>();
  Object? mismatchError;
  try {
    await commitWrites(
        storage,
        <StorageWrite>[
          DocumentCopyWrite(
            record: DocumentCreate(
              id: mismatchId,
              kind: 'copy.mismatch',
              scope: ConversationScope(childId),
              history: 'rewindable',
              fork: ForkPolicy.asOf,
            ),
            source: DocumentCopySource(id: currentCopyId, at: currentPoint),
          ),
        ],
        _context);
  } catch (error) {
    mismatchError = error;
  }
  expect.ok(mismatchError != null);
  expect
      .ok((await storage.document(mismatchId, currentPoint, _context)) == null);
}

Future<void> _versionTransitions(
    Storage storage, ConformanceAssertions expect) async {
  await _createRoot(storage);
  final id = await storage.mintId<DocumentKindId>();
  final record = DocumentCreate(
      id: id, kind: 'session.settings', scope: const SessionScope());
  await commitWrites(
      storage,
      <StorageWrite>[
        DocumentCreateWrite(
            record: record,
            content: DocumentBase(1, <String, Object?>{'count': 1})),
      ],
      _context);
  await commitWrites(
      storage,
      <StorageWrite>[
        DocumentChangeWrite(
            id: id,
            content: DocumentDelta(1, <Op>[
              OpSet(<Seg>['count'], 2)
            ])),
      ],
      _context);
  final migratedAt = await commitWrites(
      storage,
      <StorageWrite>[
        DocumentChangeWrite(
            id: id, content: DocumentBase(2, <String, Object?>{'count': 3})),
      ],
      _context);
  expect.deepEqual((await storage.document(id, currentPoint, _context))!.value,
      <String, Object?>{'count': 3});
  await expect.rejects(storage.document(id, SeqPoint(migratedAt), _context),
      'does not retain historical content');
  await expect.rejects(
    commitWrites(
        storage,
        <StorageWrite>[
          DocumentChangeWrite(
              id: id,
              content: DocumentDelta(1, <Op>[
                OpSet(<Seg>['count'], 4)
              ])),
        ],
        _context),
    'version transition requires a base',
  );
  expect.deepEqual((await storage.document(id, currentPoint, _context))!.value,
      <String, Object?>{'count': 3});
  await commitWrites(
      storage, <StorageWrite>[DocumentRetireWrite(id)], _context);
  expect.ok((await storage.document(id, currentPoint, _context)) == null);
}

Future<void> _addresses(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final firstId = await storage.mintId<DocumentKindId>();
  final secondId = await storage.mintId<DocumentKindId>();
  final conversationId = await storage.mintId<DocumentKindId>();
  final taskId = await storage.mintId<TaskKind>();
  final taskSingletonId = await storage.mintId<DocumentKindId>();
  final taskFamilyId = await storage.mintId<DocumentKindId>();
  final taskOtherKindId = await storage.mintId<DocumentKindId>();
  final createdAt = await commitWrites(
      storage,
      <StorageWrite>[
        TaskWrite(_pendingTask(taskId, rootId)),
        DocumentCreateWrite(
          record: DocumentCreate(
              id: firstId,
              kind: 'cache',
              scope: const SessionScope(),
              key: '__proto__'),
          content: DocumentBase(1, <String, Object?>{'owner': 'first'}),
        ),
        DocumentCreateWrite(
          record: DocumentCreate(
              id: secondId,
              kind: 'cache',
              scope: const SessionScope(),
              key: 'constructor'),
          content: DocumentBase(1, <String, Object?>{'owner': 'second'}),
        ),
        DocumentCreateWrite(
          record: DocumentCreate(
            id: conversationId,
            kind: 'cache',
            scope: ConversationScope(rootId),
            history: 'latest',
            fork: ForkPolicy.current,
            key: '__proto__',
          ),
          content: DocumentBase(1, <String, Object?>{'owner': 'conversation'}),
        ),
        DocumentCreateWrite(
          record: DocumentCreate(
              id: taskSingletonId,
              kind: 'task.cache',
              scope: TaskScope(taskId)),
          content: DocumentBase(1, <String, Object?>{'owner': 'singleton'}),
        ),
        DocumentCreateWrite(
          record: DocumentCreate(
              id: taskFamilyId,
              kind: 'task.cache',
              scope: TaskScope(taskId),
              key: 'member'),
          content: DocumentBase(1, <String, Object?>{'owner': 'family'}),
        ),
        DocumentCreateWrite(
          record: DocumentCreate(
              id: taskOtherKindId,
              kind: 'task.other',
              scope: TaskScope(taskId)),
          content: DocumentBase(1, <String, Object?>{'owner': 'other'}),
        ),
      ],
      _context);

  expect.strictEqual(
    (await storage.findDocument(
      DocumentAddress(
          kind: 'cache', scope: const SessionScope(), key: '__proto__'),
      currentPoint,
      _context,
    ))!
        .id
        .value,
    firstId.value,
  );
  expect.strictEqual(
    (await storage.scanDocuments(
            DocumentQuery(scope: const SessionScope(), at: currentPoint),
            1,
            null,
            _context))
        .items
        .length,
    1,
  );
  final first = await storage.scanDocuments(
      DocumentQuery(scope: const SessionScope(), at: currentPoint),
      1,
      null,
      _context);
  final second = await storage.scanDocuments(
      DocumentQuery(scope: const SessionScope(), at: currentPoint),
      1,
      first.next,
      _context);
  expect.deepEqual(<int>[..._ids(first.items), ..._ids(second.items)],
      <int>[firstId.value, secondId.value]);
  expect.deepEqual(
    _ids((await storage.scanDocuments(
      DocumentQuery(scope: ConversationScope(rootId), at: currentPoint),
      10,
      null,
      _context,
    ))
        .items),
    <int>[conversationId.value],
  );
  expect.strictEqual(
    (await storage.findDocument(
            DocumentAddress(kind: 'task.cache', scope: TaskScope(taskId)),
            currentPoint,
            _context))!
        .id
        .value,
    taskSingletonId.value,
  );
  expect.strictEqual(
    (await storage.findDocument(
      DocumentAddress(
          kind: 'task.cache', scope: TaskScope(taskId), key: 'member'),
      currentPoint,
      _context,
    ))!
        .id
        .value,
    taskFamilyId.value,
  );
  expect.deepEqual(
    _ids((await storage.scanDocuments(
      DocumentQuery(
          scope: TaskScope(taskId), at: currentPoint, kind: 'task.cache'),
      10,
      null,
      _context,
    ))
        .items),
    <int>[taskSingletonId.value, taskFamilyId.value],
  );
  await expect.rejects(
      storage.document(taskSingletonId, SeqPoint(createdAt), _context),
      'does not retain historical content');
}

Future<void> _lifecycle(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final firstId = await storage.mintId<DocumentKindId>();
  final secondId = await storage.mintId<DocumentKindId>();
  final record = DocumentCreate(
      id: firstId, kind: 'singleton', scope: const SessionScope());
  await commitWrites(
      storage,
      <StorageWrite>[
        DocumentCreateWrite(
            record: record,
            content: DocumentBase(1, <String, Object?>{'value': 1})),
      ],
      _context);
  await expect.rejects(
    commitWrites(
        storage,
        <StorageWrite>[
          DocumentCreateWrite(
            record: DocumentCreate(
                id: secondId, kind: 'singleton', scope: const SessionScope()),
            content: DocumentBase(1, <String, Object?>{'value': 2}),
          ),
          DocumentChangeWrite(id: firstId, content: DocumentDelta(1, <Op>[])),
        ],
        _context),
    'already has a current incarnation',
  );
  expect.deepEqual(
      (await storage.document(firstId, currentPoint, _context))!.value,
      <String, Object?>{'value': 1});
  expect.ok((await storage.document(secondId, currentPoint, _context)) == null);

  final emptyId = await storage.mintId<DocumentKindId>();
  final emptyAt = await commitWrites(
      storage,
      <StorageWrite>[
        DocumentCreateWrite(
          record: DocumentCreate(
            id: emptyId,
            kind: record.kind,
            key: 'empty',
            scope: ConversationScope(rootId),
            history: 'rewindable',
            fork: ForkPolicy.initial,
          ),
          content: DocumentBase(1, <String, Object?>{}),
        ),
        DocumentRetireWrite(emptyId),
      ],
      _context);
  expect.ok((await storage.document(emptyId, currentPoint, _context)) == null);
  expect.ok(
      (await storage.document(emptyId, SeqPoint(emptyAt), _context)) == null);
  expect.ok(
    (await storage.findDocument(
          DocumentAddress(
            kind: record.kind,
            scope: ConversationScope(rootId),
            key: 'empty',
          ),
          SeqPoint(emptyAt),
          _context,
        )) ==
        null,
  );
}

Future<void> _doubleContent(
    Storage storage, ConformanceAssertions expect) async {
  await _createRoot(storage);
  for (final order in <String>['create first', 'change first']) {
    final id = await storage.mintId<DocumentKindId>();
    final create = DocumentCreateWrite(
      record: DocumentCreate(
          id: id, kind: 'twice', scope: const SessionScope(), key: order),
      content: DocumentBase(1, <String, Object?>{'x': 1}),
    );
    final change = DocumentChangeWrite(
        id: id,
        content: DocumentDelta(1, <Op>[
          OpSet(<Seg>['x'], 2)
        ]));
    final writes = order == 'create first'
        ? <StorageWrite>[create, change]
        : <StorageWrite>[change, create];
    await expect.rejects(commitWrites(storage, writes, _context),
        'more than one content command');
    expect.ok((await storage.document(id, currentPoint, _context)) == null);
  }
}

Future<void> _documentRollback(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final taskId = await storage.mintId<TaskKind>();
  final submissionId = await storage.mintId<SubmissionKind>();
  final documentId = await storage.mintId<DocumentKindId>();
  final task = _pendingTask(taskId, rootId);
  final submission = SubmissionRecord(
      id: submissionId,
      conversationId: rootId,
      requestId: 'atomic',
      type: 'input',
      status: 'queued');
  final record = DocumentCreate(
      id: documentId, kind: 'atomic', scope: const SessionScope());
  final baselineSeq = await commitWrites(
      storage,
      <StorageWrite>[
        TaskWrite(task),
        SubmissionWrite(submission),
        DocumentCreateWrite(
            record: record,
            content: DocumentBase(1, <String, Object?>{'count': 1})),
      ],
      _context);

  final entryId = await storage.mintId<EntryKind>();
  final conflictingDocumentId = await storage.mintId<DocumentKindId>();
  await expect.rejects(
    commitWrites(
        storage,
        <StorageWrite>[
          TaskWrite(task.withState(TaskRunning<Object?, Object?>(
              <String, Object?>{'phase': 'effect'}))),
          SubmissionWrite(
              submission.withStatus(status: 'unanswered', reason: 'failed')),
          EntryWrite(_entry(entryId, rootId, 'transient')),
          DocumentCreateWrite(
            record: DocumentCreate(
                id: conflictingDocumentId,
                kind: 'atomic',
                scope: const SessionScope()),
            content: DocumentBase(1, <String, Object?>{'count': 2}),
          ),
        ],
        _context),
    'already has a current incarnation',
  );

  expect.deepEqual(
      (await storage.task(taskId, _context))!.toJson(), task.toJson());
  expect.deepEqual(
      _ids((await storage.scanTasks(
              const TaskQuery(status: 'pending'), 10, null, _context))
          .items),
      <int>[taskId.value]);
  expect.deepEqual(
      (await storage.submissionByRequest(rootId, 'atomic', _context))!.toJson(),
      submission.toJson());
  expect.ok((await storage.entry(entryId, _context)) == null);
  expect.ok(
      (await storage.document(conflictingDocumentId, currentPoint, _context)) ==
          null);
  expect.strictEqual(
    (await storage.findDocument(
            DocumentAddress(kind: record.kind, scope: record.scope),
            currentPoint,
            _context))!
        .id
        .value,
    documentId.value,
  );
  final afterRollbackSeq = await commitWrites(
      storage,
      <StorageWrite>[
        DocumentChangeWrite(
            id: documentId,
            content: DocumentDelta(1, <Op>[
              OpSet(<Seg>['count'], 3)
            ])),
      ],
      _context);
  expect.greaterThan(afterRollbackSeq.value, baselineSeq.value);
}

Future<void> _losslessStrings(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  const first = '\ud800';
  const second = '\ud801';
  final firstTaskId = await storage.mintId<TaskKind>();
  final secondTaskId = await storage.mintId<TaskKind>();
  final firstSubmissionId = await storage.mintId<SubmissionKind>();
  final secondSubmissionId = await storage.mintId<SubmissionKind>();
  final firstKindDocumentId = await storage.mintId<DocumentKindId>();
  final secondKindDocumentId = await storage.mintId<DocumentKindId>();
  final firstKeyDocumentId = await storage.mintId<DocumentKindId>();
  final secondKeyDocumentId = await storage.mintId<DocumentKindId>();
  await commitWrites(
      storage,
      <StorageWrite>[
        TaskWrite(_pendingTask(firstTaskId, rootId).withKind(first)),
        TaskWrite(_pendingTask(secondTaskId, rootId).withKind(second)),
        SubmissionWrite(SubmissionRecord(
          id: firstSubmissionId,
          conversationId: rootId,
          requestId: first,
          type: 'input',
          status: 'queued',
        )),
        SubmissionWrite(SubmissionRecord(
          id: secondSubmissionId,
          conversationId: rootId,
          requestId: second,
          type: 'input',
          status: 'queued',
        )),
        DocumentCreateWrite(
          record: DocumentCreate(
              id: firstKindDocumentId,
              kind: first,
              scope: const SessionScope()),
          content: DocumentBase(1, <String, Object?>{'identity': 'first kind'}),
        ),
        DocumentCreateWrite(
          record: DocumentCreate(
              id: secondKindDocumentId,
              kind: second,
              scope: const SessionScope()),
          content:
              DocumentBase(1, <String, Object?>{'identity': 'second kind'}),
        ),
        DocumentCreateWrite(
          record: DocumentCreate(
              id: firstKeyDocumentId,
              kind: 'family',
              key: first,
              scope: const SessionScope()),
          content: DocumentBase(1, <String, Object?>{'identity': 'first key'}),
        ),
        DocumentCreateWrite(
          record: DocumentCreate(
              id: secondKeyDocumentId,
              kind: 'family',
              key: second,
              scope: const SessionScope()),
          content: DocumentBase(1, <String, Object?>{'identity': 'second key'}),
        ),
      ],
      _context);

  expect.deepEqual(
      _ids((await storage.scanTasks(
              const TaskQuery(kind: first), 10, null, _context))
          .items),
      <int>[firstTaskId.value]);
  expect.deepEqual(
      _ids((await storage.scanTasks(
              const TaskQuery(kind: second), 10, null, _context))
          .items),
      <int>[secondTaskId.value]);
  expect.strictEqual((await storage.task(firstTaskId, _context))!.kind, first);
  expect.strictEqual(
      (await storage.task(secondTaskId, _context))!.kind, second);
  expect.strictEqual(
      (await storage.submissionByRequest(rootId, first, _context))!.id.value,
      firstSubmissionId.value);
  expect.strictEqual(
      (await storage.submissionByRequest(rootId, second, _context))!.id.value,
      secondSubmissionId.value);
  expect.strictEqual(
    (await storage.findDocument(
            DocumentAddress(kind: first, scope: const SessionScope()),
            currentPoint,
            _context))!
        .id
        .value,
    firstKindDocumentId.value,
  );
  expect.strictEqual(
    (await storage.findDocument(
            DocumentAddress(kind: second, scope: const SessionScope()),
            currentPoint,
            _context))!
        .id
        .value,
    secondKindDocumentId.value,
  );
  expect.strictEqual(
    (await storage.findDocument(
      DocumentAddress(kind: 'family', scope: const SessionScope(), key: first),
      currentPoint,
      _context,
    ))!
        .id
        .value,
    firstKeyDocumentId.value,
  );
  expect.strictEqual(
    (await storage.findDocument(
      DocumentAddress(kind: 'family', scope: const SessionScope(), key: second),
      currentPoint,
      _context,
    ))!
        .id
        .value,
    secondKeyDocumentId.value,
  );
}

Future<void> _globalNamespace(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final explicitEntryId = idFromNumber<EntryKind>(100);
  await commitWrites(storage,
      <StorageWrite>[EntryWrite(_entry(explicitEntryId, rootId))], _context);
  expect.strictEqual((await storage.mintId<EntryKind>()).value, 101);
  await expect.rejects(
    commitWrites(
        storage,
        <StorageWrite>[
          TaskWrite(_pendingTask(
              idFromNumber<TaskKind>(explicitEntryId.value), rootId)),
        ],
        _context),
    'ID 100 already belongs to entry',
  );

  await commitWrites(
      storage,
      <StorageWrite>[
        EntryWrite(
            _entry(idFromNumber<EntryKind>(_maxSafeId), rootId, 'last-id')),
      ],
      _context);
  await expect.rejects(storage.mintId<EntryKind>(), 'ID space is exhausted');
  await expect.rejects(storage.mintId<EntryKind>(), 'ID space is exhausted');
}

Future<void> _batchOrder(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final firstId = await storage.mintId<EntryKind>();
  final lastId = await storage.mintId<EntryKind>();
  final documentId = await storage.mintId<DocumentKindId>();
  final receipts = <(int, int)>[];
  Future<Object?>? read;
  final result = await storage.commit(
    <List<StorageWrite>>[
      <StorageWrite>[
        EntryWrite(_entry(firstId, rootId)),
        DocumentCreateWrite(
          record: DocumentCreate(
            id: documentId,
            kind: 'batch.doc',
            scope: ConversationScope(rootId),
            history: 'latest',
            fork: ForkPolicy.initial,
          ),
          content: DocumentBase(1, <String, Object?>{'count': 1}),
        ),
      ],
      <StorageWrite>[
        DocumentChangeWrite(
            id: documentId,
            content: DocumentDelta(1, <Op>[
              OpSet(<Seg>['count'], 2)
            ])),
      ],
      <StorageWrite>[EntryWrite(_entry(lastId, rootId))],
    ],
    (index, seq) {
      receipts.add((index, seq.value));
      read ??= storage.entry(lastId, _context);
    },
    _context,
  );
  expect.strictEqual(result.stored, 3);
  expect.deepEqual(
      <int>[for (final (index, _) in receipts) index], <int>[0, 1, 2]);
  expect.ok(receipts[1].$2 > receipts[0].$2);
  expect.ok(receipts[2].$2 > receipts[1].$2);
  expect.strictEqual(
      ((await read! as ({EntryRecord entry, Seq commitSeq})?)!).commitSeq.value,
      receipts[2].$2);
  expect.strictEqual((await storage.entry(firstId, _context))!.commitSeq.value,
      receipts[0].$2);
  expect.deepEqual(
      (await storage.document(documentId, currentPoint, _context))!.value,
      <String, Object?>{'count': 2});
  final next = await commitWrites(
    storage,
    <StorageWrite>[
      EntryWrite(_entry(await storage.mintId<EntryKind>(), rootId))
    ],
    _context,
  );
  expect.greaterThan(next.value, receipts[2].$2);
}

Future<void> _batchRefusal(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final firstId = await storage.mintId<EntryKind>();
  final afterId = await storage.mintId<EntryKind>();
  final receipts = <int>[];
  final result = await storage.commit(
    <List<StorageWrite>>[
      <StorageWrite>[EntryWrite(_entry(firstId, rootId))],
      <StorageWrite>[
        TaskWrite(_pendingTask(await storage.mintId<TaskKind>(), rootId)),
        EntryWrite(_entry(firstId, rootId)),
      ],
      <StorageWrite>[EntryWrite(_entry(afterId, rootId))],
    ],
    (index, seq) => receipts.add(index),
    _context,
  );
  expect.strictEqual(result.stored, 1);
  expect.ok(result is CommitRefused);
  expect.strictEqual((await storage.entry(firstId, _context)) == null, false);
  expect.ok((await storage.entry(afterId, _context)) == null);
  expect.deepEqual(
      _ids((await storage.scanTasks(const TaskQuery(), 10, null, _context))
          .items),
      <int>[]);
  expect.deepEqual(receipts, <int>[0]);

  final refused = await storage.commit(
    <List<StorageWrite>>[
      <StorageWrite>[ConversationWrite(ConversationRecord(id: rootId))],
    ],
    (index, seq) => receipts.add(index),
    _context,
  );
  expect.strictEqual(refused.stored, 0);
  expect.ok(refused is CommitRefused);
  expect.deepEqual(receipts, <int>[0]);
  await commitWrites(
      storage, <StorageWrite>[EntryWrite(_entry(afterId, rootId))], _context);
  expect.ok((await storage.entry(afterId, _context)) != null);
}

Future<void> _malformedBatch(
    Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final documentId = await storage.mintId<DocumentKindId>();
  await commitWrites(
      storage,
      <StorageWrite>[
        DocumentCreateWrite(
          record: DocumentCreate(
              id: documentId, kind: 'staged', scope: const SessionScope()),
          content: DocumentBase(1, <String, Object?>{'n': 1}),
        ),
      ],
      _context);
  final firstId = await storage.mintId<EntryKind>();
  final secondId = await storage.mintId<EntryKind>();
  final afterId = await storage.mintId<EntryKind>();
  final receipts = <int>[];
  final result = await storage.commit(
    <List<StorageWrite>>[
      <StorageWrite>[EntryWrite(_entry(firstId, rootId))],
      <StorageWrite>[
        EntryWrite(_entry(secondId, rootId)),
        DocumentRetireWrite(documentId),
        DocumentRetireWrite(documentId),
      ],
      <StorageWrite>[EntryWrite(_entry(afterId, rootId))],
    ],
    (index, seq) => receipts.add(index),
    _context,
  );
  expect.strictEqual(result.stored, 1);
  expect.ok(result is CommitRefused);
  expect.deepEqual(receipts, <int>[0]);
  expect.ok((await storage.entry(firstId, _context)) != null);
  expect.ok((await storage.entry(secondId, _context)) == null);
  expect.ok((await storage.entry(afterId, _context)) == null);
  expect.deepEqual(
      (await storage.document(documentId, currentPoint, _context))!.value,
      <String, Object?>{'n': 1});
}

Future<void> _batchedCopy(Storage storage, ConformanceAssertions expect) async {
  final rootId = await _createRoot(storage);
  final childId = await storage.mintId<ConversationKind>();
  final sourceId = await storage.mintId<DocumentKindId>();
  final copyId = await storage.mintId<DocumentKindId>();
  DocumentCreate record(DocumentId id, ConversationId conversationId) =>
      DocumentCreate(
        id: id,
        kind: 'batch.copy',
        scope: ConversationScope(conversationId),
        history: 'rewindable',
        fork: ForkPolicy.asOf,
      );
  final seqs = <int>[];
  final result = await storage.commit(
    <List<StorageWrite>>[
      <StorageWrite>[
        DocumentCreateWrite(
            record: record(sourceId, rootId),
            content: DocumentBase(1, <String, Object?>{'count': 1})),
      ],
      <StorageWrite>[
        DocumentChangeWrite(
            id: sourceId,
            content: DocumentDelta(1, <Op>[
              OpSet(<Seg>['count'], 2)
            ])),
      ],
      <StorageWrite>[
        ConversationWrite(ConversationRecord(id: childId)),
        DocumentCopyWrite(
            record: record(copyId, childId),
            source: DocumentCopySource(id: sourceId, at: currentPoint)),
      ],
    ],
    (index, seq) => seqs.add(seq.value),
    _context,
  );
  expect.strictEqual(result.stored, 3);
  expect.deepEqual(
      (await storage.document(copyId, currentPoint, _context))!.value,
      <String, Object?>{'count': 2});
  expect.deepEqual(
      (await storage.document(
              sourceId, SeqPoint(seqFromNumber(seqs[0])), _context))!
          .value,
      <String, Object?>{'count': 1});

  final laterId = await storage.mintId<ConversationKind>();
  final laterCopyId = await storage.mintId<DocumentKindId>();
  final refused = await storage.commit(
    <List<StorageWrite>>[
      <StorageWrite>[
        ConversationWrite(ConversationRecord(id: laterId)),
        DocumentCopyWrite(
            record: record(laterCopyId, laterId),
            source: DocumentCopySource(id: sourceId, at: currentPoint)),
        DocumentChangeWrite(
            id: sourceId,
            content: DocumentDelta(1, <Op>[
              OpSet(<Seg>['count'], 3)
            ])),
      ],
    ],
    (index, seq) {},
    _context,
  );
  expect.strictEqual(refused.stored, 0);
  expect.ok(refused is CommitRefused);
  expect.ok((await storage.conversation(laterId, _context)) == null);
  expect.deepEqual(
      (await storage.document(sourceId, currentPoint, _context))!.value,
      <String, Object?>{'count': 2});
}

Future<void> _afterClose(Storage storage, ConformanceAssertions expect) async {
  await _createRoot(storage);
  await storage.close(_context);
  await expect.rejects(
      storage.conversation(rootConversationId, _context), 'closed');
  await expect.rejects(
    commitWrites(
        storage,
        <StorageWrite>[
          ConversationWrite(ConversationRecord(id: rootConversationId))
        ],
        _context),
    'closed',
  );
  await expect.rejects(storage.mintId<ConversationKind>(), 'closed');
}
