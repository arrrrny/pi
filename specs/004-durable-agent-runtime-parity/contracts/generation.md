# Contract: Generation Task

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md)
**Upstream**: `packages/durable/src/harness/generation.ts`, `live.ts`, `usage.ts`; spec §8.2–§8.3, §8.6

## Checkpoint

```dart
sealed class GenerationCheckpoint {}

class GenerationPrepare extends GenerationCheckpoint {
  final int attempt;
  final TaskId<CompactionResult>? compacted;
  final String? overflow;     // checked once when prepare resumes
  final bool threshold;       // set when the blocking threshold started compacted
}

class GenerationRequest extends GenerationCheckpoint {
  final int attempt;
  final TaskId<CompactionResult>? compacted;
  final ModelRef model;
  final ModelThinkingLevel thinkingLevel;
  final ConversationStreamOptions streamOptions;
  final EntryId cutoff;       // newest entry included in the request
}

class GenerationRetry extends GenerationCheckpoint {
  final int attempt;
  final TaskId<CompactionResult>? compacted;
  final int until;
}

class GenerationPoll extends GenerationCheckpoint {
  final int attempt;
  final TaskId<CompactionResult>? compacted;
  final ModelRef model;
  final EntryId cutoff;
  final DeferredHandle handle;
  final int pollAt;
}

class GenerationTools extends GenerationCheckpoint {
  final EntryId assistant;
  final List<TaskId<ToolTaskResult>> tools;
  final List<String> pending;  // sequential round calls not started yet
}

class GenerationFinish extends GenerationCheckpoint {
  final RunSummary run;
}

class GenerationDrain extends GenerationCheckpoint {
  final EntryId answer;
  final List<TaskId> tasks;
}

class GenerationAfterTools extends GenerationCheckpoint {
  final EntryId assistant;
  final List<TaskId<ToolTaskResult>> tools;
  final List<TaskId> tasks;
}

class GenerationYield extends GenerationCheckpoint {
  final EntryId answer;
  final List<TaskId> tasks;
}

class GenerationResult {
  final EntryId entryId;
}
```

`pi.generation` is version 3 and starts at `{phase: "prepare", attempt: 1}`. `migrate` keeps older records as they
are; a version-2 sequential round keeps unoffered calls in `pending`; version 1 is left blocked (`task_too_old`).

## Phases

- **`prepare`** — resolve the conversation's agent and settings once; fail `no_model` when no model is configured or
  `models.getModel()` does not know it; fail `nothing_to_answer` when the committed context does not end in a user
  message or tool results (system messages aside). Check compaction thresholds (blocking above
  `contextWindow - reserveTokens`; background above `contextWindow - reserveTokens - backgroundTokens`). One commit
  appends the planned `pi.system` entries and moves to `request` with the new tail as `cutoff`, the agent's model and
  thinking level, and the settings' stream options.
- **`request` / `poll`** — resolve the checkpoint's model; `request` converts a leftover partial to an aborted
  `pi.assistant` entry and sets `pi.live.generation`; when the host died mid-request the attempt is charged against
  the retry policy (a close does not charge); stream the model context through `cutoff` with the invocation signal,
  `reasoning` (omitted for `off`), the conversation's persisted provider `sessionId`, and the pinned stream options,
  committing throttled deferred partials. Run `beforeRequest` (per request) and `beforeProviderRequest` (per built
  body) chains. `poll` calls `models.fetchDeferred()`; a still-deferred result sleeps to a strictly later `pollAt`.
- **classification** (one commit, after `afterResponse` observes the terminal message) —
  - `stop`/`length`: run the `onYield` chain; on `{tasks}` create them as children of the generation and wait with
    `allSettled` at `yield`; otherwise append the answer and apply the final boundary or start a successor
    generation.
  - `toolUse` with at least one call: append the assistant entry and start the tool round (see the tools contract),
    moving to `waiting` in `tools`.
  - `error` recognized by `isContextOverflow()` while compaction is enabled and `compacted` is absent and range
    selection finds a cut: create a blocking compaction and wait at `prepare`.
  - retryable `error` within the retry policy: sleep at `retry` until `now + retryDelayMs(policy, attempt)`.
  - any other `error`, or `aborted` without an abort mark: settle the inputs `unanswered` with `model_error`.
  - `deferred`: sleep at `poll` until `now + (handle.pollAfterMs ?? 5000)`.
- **`retry`** — runs once the backoff is due and returns to `prepare` with the next attempt.
- **`poll`** — runs once due, calls `models.fetchDeferred()`; a model gone after reopen fails `no_model` once due.
- **`tools`** — resumes once every waited tool task is terminal (see the tools contract for the round commit).
- **`finish`** — ask the `afterRun` hooks with `{reason, first, answer, last}` and create the requested tasks as
  children of the generation; wait with `allSettled` at `drain`. A crash in `finish` re-asks the hooks; once the
  tasks exist the hooks are not asked again.
- **`drain`** — runs once every after-run task is terminal; applies the final boundary, removes `run`, starts a
  successor run for the selected user items, completes `{entryId: answer}`.
- **`afterTools`** — runs once every `afterTools` task is terminal and ends the round as `tools` does; a task that
  completed with `{terminate: true}` ends the round as one whose calls all asked to terminate.
- **`yield`** — runs once every `onYield` task is terminal; the first task in creation order whose `YieldDecision`
  holds a valid `UserInput` provides a continuation (applied only when the inbox holds no steer, follow-up, or
  reset); otherwise the run ends as a `stop` answer ends.

## Restart limit

At `restarts >= settings.restartLimit`: a generation whose run is not yet answered ends its run `unanswered` with
`runFailure` reason `restart_limit`; one that answered already in `finish`/`drain`/`yield` ends without a failure,
its inputs `done` with that answer, and completes.

## Usage

Every `pi.assistant` entry adds its message's `usage` to `pi.usage.models` under `provider/modelId` in the same
commit. Every compaction summarization attempt adds its response's usage in the commit that classifies it. Failed
and aborted attempts count. A fork starts at zero.