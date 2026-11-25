# Coverage Rows: Durable Agent Runtime Parity

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)
**Oracle**: `earendil-works/pi` at `780bf31fcaeb252fa9b68df3964c735eae75bde3`
**Registry shape**: `coverage/registry/behavior-registry.json` per
[`specs/002-upstream-coverage-governance/data-model.md`](../002-upstream-coverage-governance/data-model.md) (the pi#10
schema; pi#10's generator is unbuilt, so this slice records its rows in that shape and states the pi#10 dependency)

## What this file is and is not

This file lists the coverage-manifest rows this slice **adds** for the durable agent runtime. It is a planning
artifact: it defines the rows, their upstream coordinate, and their planned Dart coordinate. It is **not** the
generated manifest and it is **not** a parity claim.

Three facts hold for every row here:

1. **This slice's verification is not full global parity.** A row becomes `verified` only when its upstream-derived
   differential test passes against the Dart implementation at the declared SHA. Full parity is *global at one SHA*:
   every applicable row across all 12 package areas verified, every exclusion approved, no known divergence. No slice
   advances `verified_upstream_sha`; it stays `null` until that complete condition holds.
2. **Planning rows are not `verified`.** No Dart code exists at planning time, so every row below is
   `in_progress` (a Dart implementation is planned but incomplete) or, where even the design is a later slice,
   `unported`. Each carries a non-null `divergence` and a tracking `issue` per the registry schema.
3. **Every remaining gap is linked.** Each row names the issue that owns the gap — pi#12 for the rest of this slice,
   pi#8 for global parity, or the per-package `dart-port` issue for full providers, MCP, coding-agent, TUI, and evals.

The row status legend (from pi#10's data-model): `unported` (no Dart implementation), `in_progress` (Dart
implementation exists but incomplete), `implemented_unverified` (code exists, no passing evidence bound), `verified`
(passing differential evidence at the declared SHA), `not_applicable` (approved platform/scope reason).

## Registry header

```json
{
  "schema_version": 1,
  "registry_version": "2026-11-22",
  "reviewed_base_sha": "780bf31fcaeb252fa9b68df3964c735eae75bde3",
  "areas": ["schema", "telemetry", "chord", "ai", "agent", "durable", "codemode", "env", "mcp", "coding-agent", "tui", "evals"]
}
```

`target_upstream_sha` = `780bf31fcaeb252fa9b68df3964c735eae75bde3`; `verified_upstream_sha` = `null` (unchanged by
this slice).

## Rows added by this slice

Each row carries the pi#10 fields. `status` is the planning-stage status; `evidence` is `null` (no test has run);
`divergence` names what remains; `issue` names its owner. `dart_entrypoint` is the planned
`package:pi/durable.dart` surface.

| id | area | upstream_path | export | behavior_kind | dart_impl (planned) | dart_test (planned) | status | divergence | issue |
|---|---|---|---|---|---|---|---|---|---|
| `durable.generation.prepare` | durable | `packages/durable/src/harness/generation.ts` | `GenerationTask` | task-phase | `pi_agent/lib/src/durable/harness/generation.dart` | `pi_agent/test/durable/harness/generation_test.dart` | in_progress | Port planned; needs scripted-provider differential evidence | arrrrny/pi#12 |
| `durable.generation.request-stream` | durable | `packages/durable/src/harness/generation.ts` | `GenerationTask` | streaming | `pi_agent/lib/src/durable/harness/generation.dart` | `pi_agent/test/durable/harness/generation_test.dart` | in_progress | Port planned; needs crash-mid-stream differential evidence | arrrrny/pi#12 |
| `durable.generation.retry-poll` | durable | `packages/durable/src/harness/generation.ts` | `GenerationTask` | recovery | `pi_agent/lib/src/durable/harness/generation.dart` | `pi_agent/test/durable/harness/generation_recovery_test.dart` | in_progress | Port planned; needs retry/poll/restart-limit evidence | arrrrny/pi#12 |
| `durable.generation.classify` | durable | `packages/durable/src/harness/generation.ts` | `GenerationTask` | classification | `pi_agent/lib/src/durable/harness/generation.dart` | `pi_agent/test/durable/harness/generation_test.dart` | in_progress | Port planned; needs stop/length/toolUse/error/deferred evidence | arrrrny/pi#12 |
| `durable.generation.hooks` | durable | `packages/durable/src/harness/generation.ts` | `GenerationHooks` | hook | `pi_agent/lib/src/durable/harness/generation.dart` | `pi_agent/test/durable/harness/hook_reads_test.dart` | in_progress | Port planned; needs onYield/afterTools/afterRun evidence | arrrrny/pi#12 |
| `durable.tool.call-validate-hooks` | durable | `packages/durable/src/harness/tool.ts` | `ToolTask` | task-phase | `pi_agent/lib/src/durable/harness/tool.dart` | `pi_agent/test/durable/harness/tools_test.dart` | in_progress | Port planned; needs validate/beforeTool/block evidence | arrrrny/pi#12 |
| `durable.tool.execute-result` | durable | `packages/durable/src/harness/tool.ts` | `ToolTask` | execution | `pi_agent/lib/src/durable/harness/tool.dart` | `pi_agent/test/durable/harness/tools_test.dart` | in_progress | Port planned; needs afterTool/throw/output-bound evidence | arrrrny/pi#12 |
| `durable.tool.replay-policy` | durable | `packages/durable/src/harness/tool.ts` | `ToolRegistration.replay` | replay | `pi_agent/lib/src/durable/harness/tool.dart` | `pi_agent/test/durable/harness/tools_recovery_test.dart` | in_progress | Port planned; needs safe-rerun / unsafe-interrupted evidence | arrrrny/pi#12 |
| `durable.tool.parks` | durable | `packages/durable/src/harness/tool.ts` | `ToolPark` | park | `pi_agent/lib/src/durable/harness/tool.dart` | `pi_agent/test/durable/harness/tool_parks_test.dart` | in_progress | Port planned; needs sleep/wait/invalid_park evidence | arrrrny/pi#12 |
| `durable.tool.nested-calls` | durable | `packages/durable/src/harness/tool.ts` | `NestedCallDoc` | nested-call | `pi_agent/lib/src/durable/harness/tool.dart` | `pi_agent/test/durable/harness/nested_tools_test.dart` | in_progress | Port planned; needs keyed reattach/abandon/restart evidence | arrrrny/pi#12 |
| `durable.tool.diagnostics-output` | durable | `packages/durable/src/harness/tool.ts` | `ToolExecutionResult` | presentation | `pi_agent/lib/src/durable/harness/tool.dart` | `pi_agent/test/durable/harness/tool_hooks_test.dart` | in_progress | Port planned; needs truncation/diagnostic-channel evidence | arrrrny/pi#12 |
| `durable.tool.rounds` | durable | `packages/durable/src/harness/generation.ts` | `GenerationTask` | tool-round | `pi_agent/lib/src/durable/harness/generation.dart` | `pi_agent/test/durable/harness/turn_limit_test.dart` | in_progress | Port planned; needs sequential/parallel/handoff/terminate evidence | arrrrny/pi#12 |
| `durable.submission.admission-dedup` | durable | `packages/durable/src/harness/submissions.ts` | `Submission` | admission | `pi_agent/lib/src/durable/harness/submissions.dart` | `pi_agent/test/durable/harness/submissions_test.dart` | in_progress | Port planned; needs requestId-dedup/whenBusy/whenIdle evidence | arrrrny/pi#12 |
| `durable.submission.boundaries` | durable | `packages/durable/src/harness/submissions.ts` | `Submission` | boundary | `pi_agent/lib/src/durable/harness/submissions.dart` | `pi_agent/test/durable/harness/input_entries_test.dart` | in_progress | Port planned; needs steeringMode/followUpMode/reset evidence | arrrrny/pi#12 |
| `durable.submission.after-failed-run` | durable | `packages/durable/src/harness/submissions.ts` | `AfterFailedRun` | continuation | `pi_agent/lib/src/durable/harness/submissions.dart` | `pi_agent/test/durable/harness/failed_run_inbox_test.dart` | in_progress | Port planned; needs continue/keep/withdraw evidence | arrrrny/pi#12 |
| `durable.submission.continue` | durable | `packages/durable/src/harness/submissions.ts` | `SubmissionDraft` (continue) | continuation | `pi_agent/lib/src/durable/harness/submissions.dart` | `pi_agent/test/durable/harness/continue_test.dart` | in_progress | Port planned; needs idle-only/nothing_to_answer evidence | arrrrny/pi#12 |
| `durable.submission.admit-in-commit` | durable | `packages/durable/src/harness/submissions.ts` | `ConversationHandle.admit` | admission | `pi_agent/lib/src/durable/harness/submissions.dart` | `pi_agent/test/durable/harness/submit_in_commit_test.dart` | in_progress | Port planned; needs ReadAfterWrite/byTaskId evidence | arrrrny/pi#12 |
| `durable.live.run-control` | durable | `packages/durable/src/harness/live.ts` | `LiveState` | document | `pi_agent/lib/src/durable/harness/live.dart` | `pi_agent/test/durable/harness/live_deltas_test.dart` | in_progress | Port planned; needs run/generation/tools/deferred evidence | arrrrny/pi#12 |
| `durable.live.run-failure` | durable | `packages/durable/src/harness/live.ts` | `RunFailure` | document | `pi_agent/lib/src/durable/harness/live.dart` | `pi_agent/test/durable/harness/run_failure_test.dart` | in_progress | Port planned; needs runFailure-reason evidence | arrrrny/pi#12 |
| `durable.inbox.document` | durable | `packages/durable/src/harness/inbox.ts` | `InboxDoc` | document | `pi_agent/lib/src/durable/harness/inbox.dart` | `pi_agent/test/durable/harness/inbox_test.dart` | in_progress | Port planned; needs ordered-items/fork-empty evidence | arrrrny/pi#12 |
| `durable.extension.registry` | durable | `packages/durable/src/harness/registry.ts` | `Registry` | registry | `pi_agent/lib/src/durable/harness/registry.dart` | `pi_agent/test/durable/harness/registry_test.dart` | in_progress | Port planned; needs install/replace/validate/publish evidence | arrrrny/pi#12 |
| `durable.extension.resolution` | durable | `packages/durable/src/harness/agent.ts` | `Agent` | resolution | `pi_agent/lib/src/durable/harness/agent.dart` | `pi_agent/test/durable/harness/agent_test.dart` | in_progress | Port planned; needs tools/sections/hooks/model resolution evidence | arrrrny/pi#12 |
| `durable.extension.hooks` | durable | `packages/durable/src/harness/types.ts` | `HookRegistration` | hook | `pi_agent/lib/src/durable/harness/define.dart` | `pi_agent/test/durable/harness/hook_tasks_test.dart` | in_progress | Port planned; needs composition/extension-order/memo evidence | arrrrny/pi#12 |
| `durable.extension.wrappers` | durable | `packages/durable/src/harness/define.ts` | `Wrap` | wrapper | `pi_agent/lib/src/durable/harness/define.dart` | `pi_agent/test/durable/harness/tool_override_test.dart` | in_progress | Port planned; needs tool/section wrap/rename-drop evidence | arrrrny/pi#12 |
| `durable.extension.configure` | durable | `packages/durable/src/harness/harness.ts` | `Conversation.configure` | config | `pi_agent/lib/src/durable/harness/harness.dart` | `pi_agent/test/durable/harness/conversations_test.dart` | in_progress | Port planned; needs per-conversation isolation evidence | arrrrny/pi#12 |
| `durable.extension.reload` | durable | `packages/durable/src/harness/registry.ts` | `Registry` | reload | `pi_agent/lib/src/durable/harness/registry.dart` | `pi_agent/test/durable/harness/registry_test.dart` | in_progress | Port planned; needs no-commit/publish-wakes-gates evidence | arrrrny/pi#12 |
| `durable.signal.delivery` | durable | `packages/durable/src/signals.ts` | `SignalToken` | signal | `pi_agent/lib/src/durable/signals.dart` | `pi_agent/test/durable/signals_test.dart` | in_progress | Dart `defineSignal`/`deliverSignal` landed with delivered/duplicate/invalid/closed/not_found unit evidence; needs upstream-derived differential evidence at the SHA | arrrrny/pi#12 |
| `durable.signal.one-wait-per-key` | durable | `packages/durable/src/signals.ts` | `SignalState` | signal | `pi_agent/lib/src/durable/signals.dart` | `pi_agent/test/durable/signals_test.dart` | in_progress | Dart `readSignal`/`checkSleep`/`sleepDue`/`sleepWake` landed with consumed/expired-reject unit evidence; needs upstream-derived differential evidence at the SHA | arrrrny/pi#12 |
| `durable.signal.memo-idempotency` | durable | `packages/durable/src/harness/types.ts` | `TaskRuntime.memo` | idempotency | `pi_agent/lib/src/durable/harness/tool.dart` | `pi_agent/test/durable/harness/tools_recovery_test.dart` | in_progress | Port planned; needs first-writer-wins evidence | arrrrny/pi#12 |
| `durable.approval.gate` | durable | `packages/durable/src/harness/types.ts` | `ToolHooks.beforeTool` | approval | `pi_agent/lib/src/durable/harness/tool.dart` | `pi_agent/test/durable/harness/tool_gates_test.dart` | in_progress | Port planned; needs sleep-until/expired-block evidence | arrrrny/pi#12 |
| `durable.subagent.foreground-background` | durable | `packages/durable/src/harness/task-graph.ts` | `TaskGraph` | ownership | `pi_agent/lib/src/durable/harness/task_graph.dart` | `pi_agent/test/durable/harness/ownership_test.dart` | in_progress | Port planned; needs ownership/background-boundary evidence | arrrrny/pi#12 |
| `durable.abort.cascade` | durable | `packages/durable/src/harness/scheduler.ts` | `Harness` | abort | `pi_agent/lib/src/durable/harness/scheduler.dart` | `pi_agent/test/durable/harness/ownership_test.dart` | in_progress | Port planned; needs idempotent-cascade/background-stop evidence | arrrrny/pi#12 |
| `durable.compaction.select-summarize` | durable | `packages/durable/src/harness/compaction.ts` | `CompactionTask` | compaction | `pi_agent/lib/src/durable/harness/compaction.dart` | `pi_agent/test/durable/harness/compaction_test.dart` | in_progress | Port planned; needs range-selection/placement evidence | arrrrny/pi#12 |
| `durable.compaction.policy` | durable | `packages/durable/src/harness/compaction.ts` | `CompactionPolicy` | policy | `pi_agent/lib/src/durable/harness/compaction.dart` | `pi_agent/test/durable/harness/compaction_test.dart` | in_progress | Port planned; needs field-by-field/modelOverrides evidence | arrrrny/pi#12 |
| `durable.view.conversation` | durable | `packages/durable/src/harness/view.ts` | `ConversationView` | view | `pi_agent/lib/src/durable/harness/view.dart` | `pi_agent/test/durable/harness/view_test.dart` | in_progress | Port planned; needs window/docs-mount/splice evidence | arrrrny/pi#12 |
| `durable.transcript.merge` | durable | `packages/durable/src/harness/transcript.ts` | `ConversationTranscript` | view | `pi_agent/lib/src/durable/harness/transcript.dart` | `pi_agent/test/durable/harness/view_run_test.dart` | in_progress | Port planned; needs merge/loadEarlier/fillGap evidence | arrrrny/pi#12 |
| `durable.usage.ledger` | durable | `packages/durable/src/harness/usage.ts` | `UsageDoc` | usage | `pi_agent/lib/src/durable/usage.dart` | `pi_agent/test/durable/usage_test.dart` | in_progress | Dart `UsageState`/`addUsage`/`addUsageState` arithmetic landed with per-model/per-tool unit evidence; `UsageDoc`/`recordUsage` wait on `documents.dart` (not in pi#11); needs upstream-derived differential evidence | arrrrny/pi#12 |
| `durable.provider.identity` | durable | `packages/durable/src/harness/provider.ts` | `ProviderDoc` | identity | `pi_agent/lib/src/durable/provider.dart` | `pi_agent/test/durable/provider_test.dart` | in_progress | Dart `ProviderState` + `uuidv7` landed with unit evidence; `ProviderDoc`/`ensureProviderSessionId` wait on `documents.dart` (not in pi#11); needs sessionId-across-request differential evidence | arrrrny/pi#12 |
| `durable.harness.facade` | durable | `packages/durable/src/harness/harness.ts` | `Harness` | facade | `pi_agent/lib/src/durable/harness/harness.dart` | `pi_agent/test/durable/harness/lifecycle_test.dart` | in_progress | Port planned; needs open/root/submit/signal/usage/close evidence | arrrrny/pi#12 |
| `durable.harness.context-prompt` | durable | `packages/durable/src/harness/context.ts` | `ContextView` | context | `pi_agent/lib/src/durable/harness/context.dart` | `pi_agent/test/durable/harness/context_test.dart` | in_progress | Port planned; needs model-context-derivation evidence | arrrrny/pi#12 |
| `durable.telemetry.schema` | durable | `packages/durable/src/harness/telemetry.ts` | `DURABLE_TELEMETRY_SCHEMA` | telemetry | `pi_agent/lib/src/durable/harness/telemetry.dart` | `pi_agent/test/durable/harness/telemetry_test.dart` | in_progress | Port planned; needs typed-span/event evidence | arrrrny/pi#12 |
| `codemode.durable.replay` | codemode | `packages/durable/src/codemode/codemode.ts` | the code-mode tool | replay | `pi_agent/lib/src/durable/codemode/codemode.dart` | `pi_agent/test/durable/codemode/codemode_test.dart` | in_progress | Port planned; needs deterministic-replay/journal evidence | arrrrny/pi#12 |
| `codemode.durable.reattach` | codemode | `packages/durable/src/codemode/codemode.ts` | `NestedCallDoc` | nested-call | `pi_agent/lib/src/durable/codemode/codemode.dart` | `pi_agent/test/durable/codemode/codemode_test.dart` | in_progress | Port planned; needs key-reattach/no-rerun evidence | arrrrny/pi#12 |
| `codemode.durable.divergence-refusal` | codemode | `packages/durable/src/codemode/codemode.ts` | the code-mode tool | recovery | `pi_agent/lib/src/durable/codemode/codemode.dart` | `pi_agent/test/durable/codemode/codemode_checkpoints_test.dart` | in_progress | Port planned; needs version/deadline/divergence-refusal evidence | arrrrny/pi#12 |

## What this slice does NOT claim (and who owns the gap)

These are deliberately **not** rows this slice marks verified, and they are the reason `verified_upstream_sha` stays
`null`:

| Area | Why not here | Owner |
|---|---|---|
| Full pi-ai providers, OAuth, images, streaming matrix | This slice consumes pi-ai through the `Models` seam only | The AI slice (`dart-port` issue for `packages/ai`) |
| `packages/mcp` protocol/client | Not in this slice | The MCP slice (`dart-port` issue for `packages/mcp`) |
| `packages/coding-agent` product behavior, coding tools, RPC, assets | Product package; this slice ports only the durable compaction task | The coding-agent slice (`dart-port` issue for `packages/coding-agent`) |
| `packages/tui` terminal UI | Not in this slice | The TUI slice (`dart-port` issue for `packages/tui`) |
| `packages/evals` evaluation model | Not in this slice | The evals slice (`dart-port` issue for `packages/evals`) |
| Global full parity at one SHA (every applicable row verified) | Global, not per-slice; advances only when every area is verified | arrrrny/pi#8 (the umbrella epic and final coverage audit) |

## Purity and no-second-runtime guard (this slice)

- **SC-006 / FR-038**: a scan of `pi_agent/lib/src/durable/harness/`, `signals.dart`, and `codemode/` finds zero
  imports of `zuraffa`, `zuraffa_agent`, a browser package, or product-domain code.
- **SC-010 / FR-039**: the scan also finds zero renamed/invented runtime types and zero second agent loop; the
  existing `package:pi/pi.dart` surface is untouched.
- **SC-011 / FR-040–FR-041**: only durable-agent-runtime rows change; `verified_upstream_sha` is unchanged; each row
  distinguishes this slice's verification from full global parity and links its remaining gap to the issue above.