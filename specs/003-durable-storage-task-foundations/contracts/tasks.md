# Contract: Tasks

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md)
**Upstream**: `packages/durable/src/types.ts`, `tasks.ts`, `harness/scheduler.ts`, `harness/task-graph.ts`,
`timers.ts`; spec §5.1–§5.6

## Task definition

```dart
abstract interface class TaskDefinition<I, S extends TaskCheckpoint, R> {
  String get name;
  int get version;
  S initial(I input);
  Map<String, PhaseHandler<I, S, R>> get phases; // exhaustive over S.phase
  Future<void> abort(RunningTask<I, S, R> task, TaskRuntime<I, S, R> runtime, Context context);
  ({I input, S checkpoint})? migrate(Object? input, Object? checkpoint, int fromVersion);
}

class Task<I, S extends TaskCheckpoint, R> {
  final TaskDefinition<I, S, R> definition;
}

Task<I, S, R> defineTask<I, S extends TaskCheckpoint, R>(TaskDefinition<I, S, R> definition);
```

`S extends TaskCheckpoint` means `S` carries a `phase` string; each phase handler receives the task narrowed to its
phase. `phases` is exhaustive: every phase named in `S` has a handler.

## Task record

```dart
sealed class TaskState<S, R> {}
class TaskPending<S> extends TaskState<S, Never> { final S checkpoint; final WakeReason? wake; }
class TaskRunning<S> extends TaskState<S, Never> { final S checkpoint; final WakeReason? wake; }
class TaskWaiting<S> extends TaskState<S, Never> {
  final S checkpoint; final List<TaskId> on; final JoinPolicy policy;
}
class TaskSleeping<S> extends TaskState<S, Never> {
  final S checkpoint; final int? until; final List<SignalKey<Object?>>? signals;
}
class TaskCompleting<S, R> extends TaskState<S, R> { final TaskOutcome<R> outcome; }
class TaskTerminal<S, R> extends TaskState<S, R> { final TaskOutcome<R> outcome; }
```

```dart
class TaskRecord<I, S extends TaskCheckpoint, R> {
  final TaskId<R> id;
  final ConversationId conversationId;
  final String kind;
  final int version;
  final I input;
  final TaskId? owner;          // absent for a conversation-owned task; immutable
  final bool background;
  final bool abortRequested;
  final String? abortReason;    // "restart" only
  final bool? abandonOnRestart;
  final int? startedAt;
  final int? endedAt;
  final int? restarts;
  final TaskState<S, R> state;
  final Map<String, Object?>? memos; // only while pending/running/waiting/sleeping
}
```

## Task outcome and wake

```dart
sealed class TaskOutcome<R> {}
class TaskCompleted<R> extends TaskOutcome<R> { final R result; }
class TaskFailed<R> extends TaskOutcome<R> { final TaskOutcomeError error; final R? result; }
class TaskAborted<R> extends TaskOutcome<R> { final String? reason; final R? result; }
class TaskOrphaned<R> extends TaskOutcome<R> { final String reason; }
class TaskFaulted<R> extends TaskOutcome<R> { final TaskOutcomeError error; }

class TaskOutcomeError { final String message; final Object? detail; }

enum JoinPolicy { failFast, allSettled, any }

sealed class WakeReason {}
class WakeTime extends WakeReason {}
class WakeExpired extends WakeReason {}
class WakeSignal extends WakeReason { final String signal; final String key; }
class WakeTasks extends WakeReason { final List<TaskId> ended; }

sealed class TaskOwnership {}
class ConversationOwnership extends TaskOwnership {}
class TaskOwnershipTask extends TaskOwnership { final TaskId taskId; }

class TaskOptions {
  final TaskOwnership ownership; // required
  final ConversationId? conversationId;
  final bool? background;
  final bool? abandonOnRestart;
}
```

## Next task state (what a task commits for itself)

```dart
sealed class NextTaskState<S, R> {}
class NextRunning<S> extends NextTaskState<S, Never> { final S checkpoint; }
class NextWaiting<S> extends NextTaskState<S, Never> { final S checkpoint; final List<TaskId> on; final JoinPolicy policy; }
class NextSleeping<S> extends NextTaskState<S, Never> { final S checkpoint; final int? until; final List<SignalKey<Object?>>? signals; }
class NextTerminal<S, R> extends NextTaskState<S, R> { final TaskOutcome<R> outcome; }
```

A returned terminal state becomes `completing` while ordinary owned work below is live (§5.5). A task never writes its
own `wake`.

## Task runtime

```dart
abstract interface class TaskRuntime<I, S extends TaskCheckpoint, R> {
  TaskId<R> get taskId;
  ConversationId get conversationId;
  AbortSignal get signal;
  Future<void> commit(
      Future<NextTaskState<S, R>?> Function(Tx tx, RunningTask<I, S, R> current) change,
      Context context,
      {CommitOptions? options});
  Future<Object?> memo(String name, Context context);
  Future<Object?> memoSet(String name, Object? candidate, Context context);
  Future<ConversationHandle?> conversation(ConversationId id, Context context);
  Future<TaskRecord?> getTask(TaskId id, Context context);
  Future<TaskRecord> waitForTask(TaskId id, Context context);
  Future<void> abortOwned(TaskId id, Context context);
  Future<List<TaskRecord>> ownedTasks(Context context);
  Future<List<TaskOutcome<Object?>>> outcomes(List<TaskId> ids, Context context);
  Future<EntryRecord?> entry(EntryId id, Context context);
  Future<Page<EntryRecord, Cursor>> entries(EntryQuery query, int limit, Cursor? cursor, Context context);
  int now();
  void report(Object? error, {ReportFrom? from});
  Future<void> sleepUntil(int until, S checkpoint, Context context);
  void Function() setTimer(void Function() callback, int delayMs, {bool background});
}
```

## Phase handler

```dart
typedef PhaseHandler<I, S extends TaskCheckpoint, R> = Future<void> Function(
    RunningTask<I, S, R> task, TaskRuntime<I, S, R> runtime, Context context);
```

## Scheduler contract (§5.4)

- Serially reserves eligible tasks, then runs handlers off the session line.
- Its decisions stay serialized on the line while their storage overlaps: each reads the scheduler's memory in a
  region that records what it reads (a task's record, the live work below an ownership node, the ownerless roots, the
  cancellation intent set) and stages nothing; when a commit that writes one of those is unpublished, the region waits
  for it and runs again.
- Every commit writes the memberships its task changes alter: a task created or ended changes the live work of every
  node from its parent up to the nearest live task or the root conversation.

### Abort protocol

```text
commit abortRequested
signal and join active run invocation
wait until ordinary owned work is no longer live
start a fresh abort invocation
abort handler commits terminal outcome
```

- A run invocation may not commit after its durable abort mark appears.
- Every runtime operation rejects after its owning invocation ends.
- Cancelling one caller's context only cancels that call or wait; it does not durably abort shared work.

### Traversal

- Ordinary traversal starts at an explicitly addressed conversation, visits its conversation-owned tasks, follows the
  tasks each non-background task owns, and follows the conversations each non-background task owns.
- A background task is a boundary: ordinary traversal skips that task and its complete owned subtree.
- Direct conversation operations start inside that conversation regardless of its owner.
- `close()` stops every invocation, foreground and background, without writing an outcome, so the work resumes on
  reopen.

### Abort cascade

- `Conversation.abort()` withdraws queued inputs and marks live non-background tasks selected by ordinary traversal.
  With `{background: true}` it crosses background boundaries.
- An abort mark cascades idempotently to foreground-owned work.
- A terminal owner never cascades: it became terminal only after its ordinary owned work drained.

## Structured concurrency (§5.5)

- Every task names its owner at creation: its conversation (`{kind: "conversation"}`) or a task
  (`{kind: "task", taskId}`).
- Owner edges are immutable.
- **Abort flows down**: a live owner's cancellation intent marks its ordinary owned work; background tasks are
  boundaries unless aborted directly.
- **Owned work does not outlive its owner's finish**: a terminal state while ordinary owned work is live is stored as
  `completing`; the final `terminal` record lands in a later commit once no ordinary owned work is live.
- A held outcome is final: no phase, runtime commit, or abort handler runs again.
- New owned work needs a live owner: `createTask` with task ownership and `createConversation` with task ownership
  reject an owner that is `completing`, `terminal`, or abort-marked.

## Waiting (§5.5)

- A phase may commit `{status: "waiting", checkpoint, on, policy}`.
- The task stops without an invocation and resumes at `checkpoint` once every task in `on` is terminal (`allSettled`,
  `failFast`) or once at least one is (`any`), possibly several; its `wake` names the terminal ones.
- `on` may not name a missing task or close a cycle in the wait-for graph; the rejection names the cycle.
- With `failFast`, the first task in `on` that holds or ends with a non-`completed` outcome gives every other live
  task in `on` an abort mark.

## Sleeping, timers, wakeups (§5.6)

- A phase may commit `{status: "sleeping", checkpoint, until?, signals?}`, or call `sleepUntil(until, checkpoint)`.
- The task resumes at `checkpoint` once the clock reaches `until`, or once one of `signals` holds a value no wake
  used, whichever comes first.
- A sleep needs `until`, a non-empty `signals`, or both. `until` is finite, `0` or more. An abort handler cannot
  sleep.
- Wakes: a sleep with a listed key that holds a value no wake used gets `signal`; otherwise a sleep whose `until` the
  clock reached gets `expired` (with signals) or `time` (without); a wait gets `tasks`.
- An abort invocation gets no wake.
- Timers are armed through `HarnessOptions.setTimer` (default `setTimeout`). A host may decline a background timer;
  foreground timers pace or resume work.
- `wake()` reports `active` (some task can run now or is running) or `at` (the earliest `until` of the sleeps not yet
  due).

## Task graph view (§9.4)

```dart
sealed class TaskGraphState {}
class TaskGraphNode { final TaskId id; final TaskId? owner; final String kind; final TaskGraphStatus status; }
class TaskGraph { final List<TaskGraphNode> nodes; }
```

A watchable view of the ownership tree, used by inspection and by a host's task graph UI.