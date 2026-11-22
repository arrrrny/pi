# Phase 1 Data Model: Durable Agent Runtime Parity

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)
**Oracle**: `earendil-works/pi` at `780bf31fcaeb252fa9b68df3964c735eae75bde3`

Every Dart type below names the upstream file and symbol it ports. A type with no upstream source cannot be marked
`verified`. Shapes are given as the Dart declaration plus the upstream declaration it mirrors. The pi#11 foundation
(Session, EntryRecord, TaskRecord, DocDefinition, Storage, Context, the task runtime) is consumed as committed and is
not re-declared here.

## Layer 1 — Harness vocabulary (`packages/durable/src/harness/types.ts`, `define.ts`, `registry.ts`)

### Extensions, sections, hooks, wrappers (`define.ts`, `registry.ts`, spec §7.1)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| `Extension<Tool>` | `types.ts` (`Extension`) | `{name, tools?, sections?, hooks?, wraps?, tasks?}`; immutable. |
| `defineExtension` | `define.ts` (`defineExtension`) | Identity that types an extension literal. |
| `PromptSection<Tool>` | `types.ts` (`PromptSection`) | `{key, render, tag?}`; `key` matches `^[a-z][a-z0-9_-]*$`. |
| `section` | `define.ts` (`section`) | Builds a `PromptSection`. |
| `PromptInput<Tool>` | `types.ts` (`PromptInput`) | `{conversationId, agent, env, shown, read}` passed to a section render. |
| `HookRegistration` | `types.ts` (`HookRegistration`) | `{task, handlers}` built by `hook()`, matched by task name. |
| `hook` / `hookTask` | `define.ts` (`hook`, `hookTask`) | Builds a hook registration / a `HookTask`. |
| `Wrap<Tool>` | `types.ts` (`Wrap`) | `{kind: "tool"\|"section", …}` built by `wrapTool`/`wrapSection`. |
| `wrapTool` / `wrapSection` | `define.ts` (`wrapTool`, `wrapSection`) | Builds a pure wrapper over a tool or a section. |
| `Registry<Tool>` / `RegistryReader` | `registry.ts` (`createRegistry`), `types.ts` | `install`/`uninstall` + `snapshot`/`subscribe`; publishes synchronously, validates uniqueness/section keys. |
| `RegistrySnapshot<Tool>` | `types.ts` (`RegistrySnapshot`) | `installed()`/`extension()`/`tools()`/`sections()`/`tasks()`/`task()`; immutable per phase. |

### Agent and resolution (`types.ts`, spec §7.1)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| `Agent<Tool>` / `AgentState` | `types.ts` (`Agent`, `AgentState`) | The resolved per-conversation agent: `tools`, `modelTools`, `sections`, `model`, `thinking`, `cwd`, `compaction`, `maxTurns`. |
| `AgentChange` | `types.ts` (`AgentChange`) | A stored or configured agent change (extensions add/remove, tools, model, …). |
| `QueueMode` | `types.ts` (`QueueMode`) | `"one-at-a-time" \| "all"` for `steeringMode`/`followUpMode`. |
| `ToolExecutionMode` | `types.ts` (`ToolExecutionMode`) | `"parallel" \| "sequential"`; per-tool or per-settings. |
| `HookResult<T>` | `types.ts` (`HookResult`) | `T \| undefined \| Future<…>`; the hook return union. |
| `HookApi` | `types.ts` (`HookApi`) | Committed reads + the asking task's memos + `readSignal` + `now`/`entry`/`entries`. |
| `GenerationHooks` / `ToolHooks` / `CompactionHooks` | `types.ts` | The typed hook interfaces (`beforeRequest`…`beforeCompact`). |
| `HookTask` / `YieldDecision` / `AfterToolsDecision` / `RunSummary` | `types.ts` | Hook-returned tasks and decisions; `RunSummary` = `{reason, first, answer, last}`. |

### Tools and results (`types.ts`, spec §7.3)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| `ToolRegistration<TParameters,TDetails,C>` | `types.ts` (`ToolRegistration`) | A `Tool` + `replay?`, `executionMode?`, `prepareArguments?`, `structuredOutputSchema?`, `callers?`, `outputLimits?`, `execute()`, `cancel?`. |
| `defineTool` | `tool.ts`/`define.ts` (`defineTool`) | Identity that infers the tool's types. |
| `ToolExecutionResult<TDetails>` | `types.ts` (`ToolExecutionResult`) | `{output?, structuredOutput?, isError?, details?, diagnostics?, usage?, control?}`; `kind?: never`. |
| `ToolPark<C>` | `types.ts` (`ToolPark`) | `{kind: "sleep", checkpoint?, until?, signals?} \| {kind: "wait", checkpoint?, on, policy}`. |
| `ToolControl` | `types.ts` (`ToolControl`) | `{addTools?, terminate?, handoff?}`. |
| `ToolDiagnostic` | `types.ts` (`ToolDiagnostic`) | `{severity, message, code?}`; a channel, never the model's data. |
| `ToolExecutionApi<TDetails,C>` | `types.ts` (`ToolExecutionApi`) | The tool's `api`: `taskId`, `conversationId`, `callId`, `wake`, `checkpoint`, `registry`, `agent()`, `models`, `env`, `output`, `retainedOutput`, `diagnostic`, `details`, `commit`, `memo`, `readSignal`, `createTask`, `getTask`, `waitForTask`, `conversation`, `executeTool`. |
| `ToolHookCall` | `types.ts` (`ToolHookCall`) | `ToolCall & {parent?}` for a nested call. |
| `NestedToolCall` / `NestedToolExecutionResult` | `types.ts` | A nested call handle and its result (no model output; `control` does not apply). |

## Layer 2 — Built-in tasks (`harness/generation.ts`, `harness/tool.ts`, `harness/compaction.ts`)

### `pi.generation` (`generation.ts`, spec §8.3)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| `GenerationInput` | `generation.ts` (`GenerationInput`) | `{}` (empty). |
| `GenerationCheckpoint` | `generation.ts` (`GenerationCheckpoint`) | Sealed union of `prepare`/`request`/`retry`/`poll`/`tools`/`finish`/`drain`/`afterTools`/`yield` checkpoints (see contract). |
| `GenerationResult` | `generation.ts` (`GenerationResult`) | `{entryId}`; version 3. |

### `pi.tool` (`tool.ts`, spec §8.4)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| `ToolTaskInput` | `tool.ts` (`ToolTaskInput`) | `{kind: "model", assistant, callId} \| {kind: "nested", parent, parentCallId, key, call, progress?}`. |
| `ToolTaskCheckpoint` | `tool.ts` (`ToolTaskCheckpoint`) | `{phase: "call"} \| {phase: "execute", arguments, replay, wake?, checkpoint?} \| {phase: "parked", arguments, replay, checkpoint?}`; version 4. |
| `ToolTaskResult` | `tool.ts` (`ToolTaskResult`) | `{kind: "model", entryId, control?} \| {kind: "nested"}`. |
| `NestedCallDoc` / `NestedCallState` | `tool.ts` (`NestedCallDoc`) | The task-scoped document family `pi.tool.nested-call` recording `{kind: "nested"\|"task", taskId}` per key. |

### `pi.compaction` (`compaction.ts`, spec §8.7)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| `CompactionReason` | `compaction.ts` | `"manual" \| "threshold" \| "overflow"`. |
| `CompactionInput` | `compaction.ts` | `{reason, instructions?}`. |
| `SummaryRequest` | `compaction.ts` | The pinned summarization request `{attempt, model, thinkingLevel, streamOptions, maxTokens, tail, firstKept}`. |
| `CompactionCheckpoint` | `compaction.ts` | `{phase: "select"} \| ({phase: "summarize"} & SummaryRequest) \| ({phase: "retry", until} & SummaryRequest)`; version 1. |
| `CompactionResult` | `compaction.ts` | `{entryId?, submissionId?}`. |
| `CompactionPolicy` / `CompactionSettings` | `types.ts` | The resolved policy (keepRecentTokens, reserveTokens, backgroundTokens, enabled, modelOverrides). |

## Layer 3 — Live document, submissions, inbox (`harness/live.ts`, `submissions.ts`, `inbox.ts`)

### Live document (`live.ts`, spec §8.2)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| `LiveState` | `live.ts` (`LiveState`) | `{run?, generation?, tools?, nestedTools?, compactions?, compactionFailure?, runFailure?}`; kind `pi.live`, version 3, conversation/latest/initial. |
| `RunFailure` | `live.ts` (`RunFailure`) | `{taskId, inputs, reason, detail?, first?}`; reason = `model_error\|no_model\|aborted\|reset\|faulted\|orphaned\|interrupted\|restart_limit\|nothing_to_answer\|turn_limit`. |
| `CompactionFailure` / `CompactionStatus` | `live.ts` | The live compaction status and failure shapes. |

### Submissions (`submissions.ts`, spec §6)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| `SubmissionDraft` | `types.ts` (`SubmissionDraft`) | `{requestId?, notify?} & (input \| write \| continue)` (see contract). |
| `InputSubmissionDraft` | `types.ts` | The `input` variant. |
| `Submission` / `SubmissionRecord` / `SubmissionId` / `SubmissionSettlement` | `submissions.ts`, `types.ts` | The awaitable submission, its record, and its settlement states. |
| `SubmissionNotify` | `types.ts` | `{taskId, key}` to deliver `SubmissionSettled` on settlement. |
| `InboxDoc` / `InboxItem` / `InboxState` | `inbox.ts` | The `pi.inbox` document, its ordered items, and `{items}` state. |
| `AfterFailedRun` | `types.ts` | `"keep" \| "continue" \| "withdraw"`. |

## Layer 4 — Signals, memos, gates (`src/signals.ts`, spec §5.7, §7.2)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| `SignalToken<T>` | `signals.ts` (`SignalToken`) | `{name, version, key()}`; `key()` produces a `SignalKey<T>` (throws on empty key). |
| `SignalKey<T>` | `signals.ts` (`SignalKey`) | `{signal, key}` JSON; `T` phantom. |
| `SignalState<T>` | `signals.ts` (`SignalState`) | `{kind: "value", value} \| {kind: "expired"}`. |
| `SignalResult` | `signals.ts` (`SignalResult`) | `"delivered" \| "duplicate" \| "invalid" \| "closed" \| "not_found"`. |
| `defineSignal` | `signals.ts` (`defineSignal`) | Validates name (no `/`), positive version, JSON schema; optional `migrate`. |
| `SubmissionSettled` | `signals.ts` | Built-in token `pi.submission-settled` for `notify`. |
| `tx.signal()` / `Harness.signal()` / `readSignal()` | `session/transaction.ts`, `harness/harness.ts`, `tasks` runtime | Delivery/read with the taxonomy; storage in `pi.signal.<name>/<key>` task memos. |
| `GateSleep` | `types.ts` | `{until?, signals?}` a `beforeTool` hook sleeps for. |
| `memo` / `memoSet` | `TaskRuntime` (pi#11), `types.ts` | First-writer-wins durable values in the task's memos. |

## Layer 5 — Subagents, views, usage, identity (`harness/agent.ts`, `view.ts`, `transcript.ts`, `usage.ts`, `provider.ts`, `task-graph.ts`)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| `ConversationView` / `ConversationWindow` | `view.ts`, `types.ts` | `{conversation, entries, before?, docs}`; window `{from?, min?, max?}`. |
| `ConversationTranscript` / `TranscriptItem` / `TranscriptView` / `EntryLoader` | `transcript.ts` | A client-side transcript over any view with `merge`/`loadEarlier`/`fillGap`/`resume`. |
| `ConversationHandle` | `types.ts` (`ConversationHandle`) | `{id, submit, admit, abort, waitForIdle}` a task/tool uses. |
| `TaskGraph` / `TaskGraphNode` / `TaskGraphState` / `TaskGraphWatch` | `task-graph.ts` | The watchable ownership-tree view. |
| `UsageDoc` / `UsageState` | `usage.ts` | `{models, tools}` spend; kind `pi.usage`, version 1. |
| `ProviderDoc` / `ProviderState` | `provider.ts` | The persisted provider `sessionId` per conversation. |
| `Harness` / `HarnessOptions` / `HarnessSettings` / `Settings` | `harness.ts`, `types.ts` | The host-facing facade: `open`, `root`, `submit`, `signal`, `usage`, `inspect`, `close`, and the options/settings. |
| `HarnessInspection` / `TaskInspection` / `Report` / `Wake` | `types.ts` | Inspection, failure reports, and the wakeup value. |
| `DURABLE_TELEMETRY_SCHEMA` | `telemetry.ts` | The typed telemetry schema the harness reports through. |

## Layer 6 — Durable code mode (`src/codemode/codemode.ts`, `packages/codemode/src/`)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| the code-mode tool | `codemode/codemode.ts` | A `ToolRegistration` running model JS in a QuickJS sandbox, replay-safe by deterministic replay. |
| `pi.codemode.run` | `codemode/codemode.ts` | Task-scoped doc: the start data (written once before the VM) and the outcome (written once on decision). |
| `pi.codemode.journal` | `codemode/codemode.ts` | One entry per delivered result in delivery order: VM call ID, clock value, issued calls (once acked), a global's outcome. |
| nested-call reattach (`c<VM call id>`) | `codemode/codemode.ts` + `NestedCallDoc` | A nested call keyed by the VM call id; never runs twice unless its replay policy reruns it. |
| `CodemodeSandboxBase` / host seam | `packages/codemode/src/runtime/execution.ts`, `portable.ts` | The sandbox host seam: `start()`, deliver-a-result, `VmStartData`, `CodemodeOutcome`. |

## Validation rules (from spec §§6–9)

- **Tool arguments** are validated against the tool's schema before and after the `beforeTool` chain (§7.3); a
  `structuredOutputSchema` tool's `structuredOutput` is validated after the `afterTool` chain.
- **Signals** reject a name with `/`, a non-positive version, and a non-JSON schema; delivery rejects an empty key,
  a non-JSON/schema-mismatched value, a duplicate key, and an expired deadline (§5.7).
- **Restarts** count every surviving `running` task at open; a close counts none; `restarts >= restartLimit` ends the
  task per the §5.4 table.
- **Submission admission** runs before the commit's first table write (`ReadAfterWrite` otherwise) and its result is
  provisional until the commit is stored (§6).
- **Live document** streamed fields are written by deferred commits and every commit that derives from or clears them
  acquires `pi.live` first (§8.2).