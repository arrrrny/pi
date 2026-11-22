# Contract: Tool Task, Parks, and Nested Calls

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md)
**Upstream**: `packages/durable/src/harness/tool.ts`, `live.ts`, `usage.ts`; spec §7.2–§7.3, §8.2, §8.4–§8.5

## Task input, checkpoint, result

```dart
sealed class ToolTaskInput {}

class ToolTaskModelInput extends ToolTaskInput {
  final EntryId assistant;
  final String callId;
}

class ToolTaskNestedInput extends ToolTaskInput {
  final TaskId parent;
  final String parentCallId;
  final String key;
  final ToolCall call;
  final bool progress;   // absent => true; false => status-only slot
}

sealed class ToolTaskCheckpoint {}

class ToolTaskCall extends ToolTaskCheckpoint {}            // { phase: "call" }

class ToolTaskExecute extends ToolTaskCheckpoint {
  final Map<String, Object?> arguments;
  final String replay;          // "safe" | "unsafe"
  final WakeReason? wake;       // set after a park
  final Object? checkpoint;     // the park's checkpoint
}

class ToolTaskParked extends ToolTaskCheckpoint {
  final Map<String, Object?> arguments;
  final String replay;
  final Object? checkpoint;
}

sealed class ToolTaskResult {}

class ToolTaskModelResult extends ToolTaskResult {
  final EntryId entryId;
  final ToolControl? control;
}

class ToolTaskNestedResult extends ToolTaskResult {}        // { kind: "nested" }
```

`pi.tool` is version 4 and starts at `{phase: "call"}`. `migrate` gives a version-1 input `kind: "model"`, keeps a
version-2 input (version 3 added `unoffered`) and older checkpoints (version 4 added `parked` and the optional
`execute` fields); a terminal result without `kind` is read as a model-issued call's.

## `call` phase (spec §8.4, §7.2–§7.3)

1. Read the call with `runtime.entry()`; an `unoffered` call settles `tool_unavailable` without resolving the name.
2. Resolve the tool among the phase agent's `tools`.
3. Validate the arguments with the tool's schema.
4. Run the `beforeTool` chain in extension order: argument replacements, and the first `block` (settle with the block
   text) or `sleep` (park at the gates: one commit sets the slot `sleeping` and commits `sleeping` at
   `{phase: "call"}`; every wake re-runs `call` from the top) stops it.
5. Validate again.
6. A deferred commit sets the slot `running`; one commit records intent: move to `execute` with the final arguments
   and the tool's replay policy. The same handler then executes the tool (below).

## `execute` phase (spec §7.3, §8.4)

- `execute(args, api, context)` returns a `ToolExecutionResult` or a `ToolPark`.
- Run the `afterTool` chain on every result (including the Harness's own error results, except past the restart
  limit).
- A throw becomes a `tool_error` result (its message in a `tool_error` diagnostic).
- A `ToolPark` (`sleep`/`wait`) parks the call: the commit stores the checkpoint and the `sleeping`/`waiting` state
  and the call holds no invocation. A park that breaks a rule (both `sleep` and `wait`, a result field beside either,
  the §5.6/§5.7 sleep rules, `on` naming a task the call does not own, a wait cycle) becomes an `invalid_park` error
  result.
- `output(chunk)` appends running text output to a bounded buffer; `details(value)` replaces the running details;
  `diagnostic(d)` records a diagnostic. None is sent to the model while the tool runs.
- `cancel` runs for a call that parked (or was woken and cut off before it parked again) to clean up external work;
  `api.wake` is undefined, `api.checkpoint` is the last park's, and `executeTool()`/`createTask()` throw. It is
  idempotent.

## Replay policy (spec §7.3)

- `replay` defaults to `unsafe`. A `safe` tool reruns `execute()` after a crash before its result committed; an
  `unsafe` tool runs `cancel` and settles an `interrupted` error result.
- Omitted `outputLimits` are 50 KiB, 2,000 lines, `retain: "head"`. Retained output is an exact slice of whole lines;
  a single over-long line is cut on a character boundary; control characters other than tab/newline are removed.

## Nested calls (spec §7.3)

```dart
// Inside a running tool's api:
Future<NestedToolExecutionResult> executeTool(String name, Map<String, Object?> args, Context context,
        {String? key, bool? progress, bool wait = true});
Future<NestedToolCall> executeTool(String name, Map<String, Object?> args, Context context,
        {String? key, bool? progress, bool wait = false});   // wait: false
```

- A nested call is its own `pi.tool` task, owned by the calling tool's task, with its own task ID, replay policy, and
  key; the nested call ID is `<callId>/<key>` (default key is the call's position `1, 2, …`; an explicit key must be
  non-empty, without `/`, not `__proto__`, not a positive integer).
- One commit creates the nested task, its `pi.live.nestedTools` slot, and its `NestedCallDoc` member
  (`{kind: "nested", taskId}`); the doc retires with the caller.
- The nested result returns as a `NestedToolExecutionResult` (its own value, `isError`, `details`, `diagnostics`,
  `usage`, `durationMs`) and never enters the transcript; the model sees only what the caller puts in its own result.
- A replay-safe caller reruns and finds its nested calls by key; a different tool name or non-equal arguments throw.
- A caller that is not replay-safe creates its nested calls with `abandonOnRestart`; a restart abandons them, so the
  caller settles `interrupted` and they were abandoned before they ran.
- Before a caller settles it aborts every live nested call it owns (`runtime.ownedTasks()` + `runtime.abortOwned()`)
  so they settle into their slots before the caller's settlement removes them.

## Tool rounds (spec §8.5)

- A tool round starts in the commit that appends the tool-calling answer: replay the offered tools with
  `getCurrentTools()` through `cutoff`, create a `pi.tool` task per call owned by the generation, and commit `waiting`
  with `allSettled` and the `tools` checkpoint.
- A round is sequential when `settings.toolExecution` is `sequential` or any offered called tool has
  `executionMode: "sequential"`: only the first call gets its task now, the rest wait in `pending`.
- The generation's `tools` phase, once every waited task is terminal (and any `afterTools` tasks): edit the
  conversation's stored `pi.agent` `tools`/`modelTools` for `addTools`; place a `handoff` reset; settle inputs `done`
  and apply the final boundary when every result asks to `terminate`; end `turn_limit` when `turns >= maxTurns`;
  otherwise apply the `postTools` boundary and create the next generation.