# Contract: Session, Commit, and Failure

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md)
**Upstream**: `packages/durable/src/session/session.ts`, `transaction.ts`, `writer.ts`, `keys.ts`,
`cached-storage.ts`, `errors.ts`; spec §1, §2, §4, §4.1, §10.1

## Session

A session owns one mutation line, its conversations, entries, tasks, submissions, and documents.

```dart
abstract interface class Session {
  Future<T> commit<T>(Future<T> Function(Tx tx) change, Context context);
  Future<ConversationHandle> conversation(ConversationId id, Context context);
  Future<DocumentWatch<T>?> watchDoc<T extends JsonObject>(DocToken<T> token, Context context);
  Future<void> Function() subscribeClose(void Function() listener);
  Stream<ObservedCommit> observeCommits();
  Future<void> close(Context context);
  Future<({SessionCloseKind kind, Object? error})> get closed;
}
```

## Required invariants (spec §1)

1. One session commit is atomic across all record and document writes.
2. A stored commit is published once storage made it durable, after the storage call that stored it settled, in line
   order, also when that call then rejects; a commit that fails before it is durable publishes nothing. Once the
   session has failed, nothing more is published.
3. All visible progress is durable, except what a deferred commit holds.
4. External effects do not run inside the session mutation transaction.
5. Entries and IDs are immutable and never reused after a committed write.
6. Document drafts are fully revoked when their transaction callback settles.
7. The mutation line runs one commit callback at a time; their storage overlaps (group commit). A callback never
   observes what an unpublished commit wrote: at its first read or write of such a key it waits until that commit is
   stored and published. Commits are published in line order, and every outcome is delivered in line order.
8. A storage error is fatal to the open session, which must be reopened. A commit it fails publishes nothing, unless
   storage had already made it durable (a durability receipt). Preparation and checkpoint failures occur before
   storage admission and roll back normally.

## Transaction (`Tx`)

```dart
abstract interface class Tx {
  Future<ConversationRecord> conversation(ConversationId id);
  Future<ConversationRecord> createConversation(ConversationInit init);
  Future<DocumentRead<T>> doc<T extends JsonObject>(DocToken<T> token);
  Future<void> appendEntry(ConversationId id, Object message);
  Future<TaskRecord> createTask(Task task, Object input, TaskOptions options);
  Future<void> retireDoc<T extends JsonObject>(DocToken<T> token);
  Future<void> admit(ConversationHandle handle, InputSubmissionDraft draft);
  AbortSignal signal();
}
```

### Table access rules (spec §4)

- Tables are conversations, entries, tasks, and submissions.
- Table reads are allowed before the first table write.
- Any table read after the first table write throws `ReadAfterWrite`.
- Document access and read-your-writes remain available after table writes.
- Creation methods return their created ID/record; callers do not read it back.
- `admit` and `signal` come before the commit's first table write, another admission's included; otherwise they throw
  `ReadAfterWrite`.

## Commit and publication sequence (spec §4)

```text
commit([..]) settles
publish: caches, trackers, telemetry events, own observers (views advance, waits resolve)
microtask: observeCommits() observers
microtasks after it: wait continuations, session.commit() resolves, abort listeners
microtasks, in no order relative to the above: watch listeners, onWake
```

- A commit is published after the storage call that stored it settled, so every view changes in the same step as
  memory.
- A storage with `publishing()` runs each commit's publication inside its own scope.
- Publication applies the commit to the session's read caches and adopts it in memory; then come the commit's
  telemetry events, then the session's own observers synchronously.
- Host `observeCommits()` observers run one microtask after the publication.
- Two commits of one storage call are published a macrotask apart.

## Deferred commits (spec §4.1)

- A commit is deferred only when its caller marks it so, and only when it changes nothing but existing latest,
  initial-fork conversation documents.
- A deferred commit is published to watches and the conversation view when memory adopts it, once the commits before
  it are published, and to `observeCommits()` once it is stored.
- What watches see can be ahead of storage by up to that commit's window; a crash loses it.

## Group commit (spec §4)

- A writer off the line sends every commit admitted while no storage call is in flight as one `Storage.commit()` call,
  each with its own `seq`, and publishes them one by one, in line order.
- Memory always shows a complete prefix of the log, plus what deferred commits hold.
- At most 256 admitted jobs wait for their outcome; beyond that the line waits.

## Detached-value ownership (spec §4)

- Commit arguments are borrowed until `Storage.commit()` settles.
- Anything retained after settlement is detached first.
- Memory storage recursively copies retained JSON containers.
- JSONL and SQLite detach through serialization and decoded indexes.
- Every storage read returns a detached JSON value.
- Immutable strings may be shared; mutable arrays and objects may not.

## Failure taxonomy (`errors.ts`, spec §10.1)

| Error | When | Effect |
| --- | --- | --- |
| `ReadAfterWrite` | A table read after the first table write | Thrown to the caller; no durable effect. |
| `StorageRequestError` | An invalid read (unknown conversation, malformed cursor, history a document does not keep) | Fails only that read; no durable effect. |
| `SessionFailed` | A storage method throws, a commit cannot be adopted, or the harness's own bookkeeping throws | Fails the session; `cause` is the first error; every later call rejects with it. |
| `ReadOnlySession` | A commit with writes or a task-running call under `readOnly` | Refused; nothing written; the session stays usable for reads. |
| `ConversationBusy` | A submission reached a busy conversation with `whenIdle: "reject"` | Not admitted. |
| `ConversationIdle` | An input with `whenIdle: "reject"` reached an idle conversation | Not admitted. |

### On the first storage failure (spec §10.1)

- The call that hit it rejects with that error.
- Every later call, every pending wait, and every wait that starts later rejects with `SessionFailed`, whose `cause`
  is the first error.
- Watches end with `{kind: "failed", error}` and keep their last value.
- Running task invocations get their abort signal.
- `onReport` gets the error once, after the session is sealed.
- The session closes itself; `closed` settles `{kind: "failed", error}`.

## Close semantics (spec §4, §10.1)

- Closing seals mutation admission and task reservation, runs the close listeners, and signals every task invocation.
- The callbacks already admitted finish, waits at their touches included; every pending and in-flight storage call
  settles and is published; the writes at close and the held changes go through the same writer; then storage closes.
- Once a commit is admitted, caller cancellation does not interrupt storage settlement or undo the commit.
- Cancelling a close wait does not reopen admission.
- `subscribeClose()` observes close synchronously when it begins, after admission is sealed; its listeners must not
  block or call session APIs; one that throws is reported without affecting the others.
- `closed` settles `{kind: "closed"}` after a plain `close()`, or `{kind: "failed", error}` after a failed one.

## Conversation handle

```dart
abstract interface class ConversationHandle {
  ConversationId get id;
  Future<void> abort(Context context, {bool background});
  Future<void> waitForIdle(Context context);
  Future<Submission> submit(Object input, Context context);
  Future<List<EntryRecord>> entries(EntryQuery query, int limit, Cursor? cursor, Context context);
}
```

## Session close kinds

```dart
sealed class SessionCloseKind {}
class SessionClosed extends SessionCloseKind {}
class SessionCloseFailed extends SessionCloseKind { final Object error; }
```