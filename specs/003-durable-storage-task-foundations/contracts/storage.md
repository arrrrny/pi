# Contract: Storage and Backends

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md)
**Upstream**: `packages/durable/src/storage/store/storage.ts`, `types.ts`, `storage/memory.ts`,
`storage/jsonl/`, `storage/sqlite/`, `src/testing/storage-conformance.ts`; spec §10, §10.1, §11

## Storage interface

Ported from `types.ts` (`Storage`) and `storage/store/storage.ts`. One abstract interface, one contract, three
backends.

```dart
abstract interface class Storage {
  Future<CommitResult> commit(
    List<List<StorageWrite>> batches,
    void Function(int index, Seq seq) receive,
    Context context,
  );

  void publishing(void Function() publish, Context context); // optional

  Future<Id<I>> mintId<I extends Id<String>>();
  Future<ConversationRecord?> conversation(ConversationId id, Context context);
  Future<Page<ConversationRecord, Cursor>> scanConversations(
      ConversationQuery query, int limit, Cursor? cursor, Context context);
  Future<({EntryRecord entry, Seq commitSeq})?> entry(EntryId id, Context context);
  Future<({EntryRecord entry, Seq commitSeq})?> entryIn(
      ConversationId conversationId, EntryId id, Context context);
  Future<({EntryRecord entry, EntryId head})?> findLatestHeadMarker(
      ConversationId conversationId, EntryId? atOrBefore, Context context);
  Future<Page<EntryRecord, Cursor>> scanEntries(
      EntryQuery query, int limit, Cursor? cursor, Context context);
  Future<TaskRecord?> task(TaskId id, Context context);
  Future<Page<TaskRecord, Cursor>> scanTasks(
      TaskQuery query, int limit, Cursor? cursor, Context context);
  Future<SubmissionRecord?> submission(SubmissionId id, Context context);
  Future<Page<SubmissionRecord, Cursor>> scanSubmissions(
      SubmissionQuery query, int limit, Cursor? cursor, Context context);
  Future<SubmissionRecord?> submissionByRequest(
      ConversationId conversationId, String requestId, Context context);
  Future<DocumentRecord?> findDocument(
      DocumentAddress address, DocumentPoint at, Context context);
  Future<StoredDocument?> document(DocumentId id, DocumentPoint at, Context context);
  Future<Page<DocumentRecord, Cursor>> scanDocuments(
      DocumentQuery query, int limit, Cursor? cursor, Context context);
  Future<void> close(Context context);
}
```

### Contract guarantees (spec §10)

1. **Atomic commit.** `commit` persists `batches` in order, each as one atomic commit with its own `seq`, checked
   against the state the earlier ones left. Every batch has at least one write.
2. **Receipt before resolve.** `receive(index, seq)` is called once per durable batch, in order, synchronously, after
   all of them are durable and before the next commit starts.
3. **Refusal.** Stops at the first batch Durable's own checks refuse; the batches before it are durable, it and the
   ones after are not. Resolves with `{kind: "refused", stored, refused}`.
4. **Unknown outcome rejects.** A connection loss or a failed statement rejects; `receive` calls already made still
   stand.
5. **Global IDs.** `mintId` returns a fresh branded candidate greater than every ID minted since open and every ID
   stored, also across reopen.
6. **Detached values.** Every read returns a detached JSON value; retained write values are detached before they are
   kept.
7. **Close is final.** After `close`, every later operation rejects.

## CommitResult

```dart
sealed class CommitResult {}
class CommitStored extends CommitResult { final int stored; }
class CommitRefused extends CommitResult { final int stored; final Object refused; }
```

## StorageWrite

```dart
sealed class StorageWrite {}
// conversation / entry / task / submission / document.create / document.copy / document.change / document.retire
```

Each variant carries exactly the upstream fields (`types.ts`): a `conversation` write is a `ConversationRecord`; a
`document.create` is a `DocumentCreate` plus a base `DocumentContent`; a `document.copy` is a `DocumentCreate` plus a
source `{id, at}`; a `document.change` is an id plus a `DocumentContent`; a `document.retire` is an id.

## DocumentContent

```dart
sealed class DocumentContent {}
class DocumentBase extends DocumentContent { final int version; final Map<String, Object?> value; }
class DocumentDelta extends DocumentContent { final int version; final List<Op> ops; }
```

## Query and cursor types

`Page<T, C> = ({List<T> items, C? next})`; `Cursor` is an opaque `Map<String, Object?>`; `ScanOrder` is
`ascending` (oldest first) or `descending` (newest first). Query filters are exactly the upstream fields:

- `ConversationQuery`: `ownerConversationId?`, `ownerTaskId?`, `order?` (default ascending).
- `EntryQuery`: `conversationId`, `minEntryId?`, `maxEntryId?`, `order?` (default descending).
- `TaskQuery`: `conversationId?`, `kind?`, `status?`, `abortRequested?`, `background?`, `order?`.
- `SubmissionQuery`: `conversationId?`, `status?`, `order?`.
- `DocumentQuery`: `scope`, `at`, `kind?`.

## Backends

### Memory (`storage/memory.ts`)

- The reference semantics (spec §11.1). Copies retained write values and all read results.
- Preserves rewindable records; reclaims latest records only after a committed base or retirement.
- No file, no driver, no platform dependency.

### JSONL (`storage/jsonl/`)

- Depends on a `FileSystem` capability, not `ExecutionEnv` (spec §11.3).
- Uses reclaimable sidecars without exposing them to the harness.
- Every decoded index, materialized value, or cache retained in memory is detached from commit arguments and never
  exposed directly by reads.

### SQLite (`storage/sqlite/`)

- One SQL transaction is one storage call: the batches of a `commit()` call, each checked before it writes (spec
  §11.2).
- Checks read the stored state of all the call's batches in a few statements and run in memory, each batch against
  what the batches before it left.
- Accepted batches are written per table in multi-row statements (rows as one JSON array parameter; rows with much
  text bound column by column within a bounded parameter count).
- A copy reads its source from the database, so the batches before it are written first.
- Stores conversation, entry, task, submission, and document records, plus indexed document bases/deltas by document
  and commit sequence. Live task transitions replace one row; terminal tasks remain as small records.
- Opening applies pending schema migrations in one transaction; schema version 2 rebuilds the task table to admit the
  `sleeping` status; a database migrated by a newer version is refused by an older one.
- Document reads use indexed base-plus-tail ranges.

### Executor seam

```dart
abstract interface class DurableSqliteExecutor {
  Future<void> execute(String sql, List<Object?> params);
  Future<List<Map<String, Object?>>> select(String sql, List<Object?> params);
  Future<T> transaction<T>(Future<T> Function() body);
}
```

Tests supply an in-memory fake; a platform adapter (not in this slice) supplies the real driver.

## Shared conformance suite

Ported from `src/testing/storage-conformance.ts` (34 cases) and registered once per backend. The suite MUST cover:

- ID 1 reserved for the immutable root conversation; a second root creation is refused.
- A durable commit is received once before resolving, and a refused commit is never received.
- Mixed table writes commit atomically and roll all of them back on failure.
- Request IDs are indexed per conversation and complete submission records are replaced.
- Stored document bases are copied independently and ambiguous sources are rejected.
- Bases are used for version transitions and historical reads of current-only documents are rejected.
- Document lifecycle failures are atomic and a create-plus-retire yields an empty lifetime.
- A creation and a change of one document in one commit are refused, in either order.
- Record tables and secondary indexes roll back when a document command fails.
- Batches commit in order, each with its seq, checked against the earlier ones.
- A later batch whose own malformed actions fail is refused, keeping the batches before it.
- Retained writes and every returned record are detached; prototype-like JSON keys do not change object prototypes.
- Entries committed out of ID order are indexed; an entry cursor continues below its last item after a newer commit.
- Conversations paginate by opaque cursor in ascending ID order and filter by durable owner edges.
- Deep fork history scans newest-first through every ancestor cap.
- Tables scan in either ID order and a cursor continues in its order.
- Complete task records are replaced and filtered task scans page.
- Owners are stored and waiting/completing/sleeping tasks scan by status.
- Sleeps on signals, any waits, and wakes round-trip.
- Rewindable documents are reconstructed and half-open incarnations preserved.

A backend that fails any case is not conforming, regardless of its own tests (SC-003).

## Crash and reopen evidence

A dedicated suite (`pi_agent/test/durable/crash/`) kills the session at each commit boundary — before admission,
mid-write, after durable, before publish — and asserts the reopened state is always a complete prefix of the log
(SC-002). Derived from upstream `harness-tasks-recovery.test.ts`, `harness-generation-recovery.test.ts`,
`session-*.test.ts`, and the crash example `chord/test/examples/42-worker-crash/`.