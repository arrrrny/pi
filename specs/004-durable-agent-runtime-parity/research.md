# Phase 0 Research: Durable Agent Runtime Parity

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)
**Oracle**: `earendil-works/pi` at `780bf31fcaeb252fa9b68df3964c735eae75bde3` (packages `durable`,
`agent`, `ai`, `codemode`, with `schema`, `telemetry`, `chord`, `env`, all at version 1.6.0)

Every decision below is anchored in a named upstream file, specification section, test, or example at the target SHA.
Where this document and the upstream source disagree, the upstream source wins and this document is corrected.

## D1 — Grounding rule: source, spec, tests, examples, not memory

**Decision**: Every Dart type, function, error, and behavior in this slice is derived from a named upstream artifact at
the target SHA. The four artifact classes are:

- **Source** — `packages/durable/src/harness/**` (generation, tool, scheduler, submissions, registry, agent, harness,
  live, compaction, view, context, inbox, usage, provider, prompt, partial-changes, task-graph, telemetry, parks,
  define, json, util, types), `packages/durable/src/signals.ts`, `packages/durable/src/codemode/**`,
  `packages/durable/src/tools/**`, `packages/durable/src/images/**`, `packages/durable/src/tool-search/**`, and the
  consumed `packages/agent/src/**`, `packages/ai/src/**`, `packages/codemode/src/**`. The exported types and the
  behavior in their bodies are the port's contract.
- **Specification** — `packages/durable/docs/spec.md` (normative, 7,303 lines), §§6–9 in particular: §6 Submissions
  and inbox, §7 Extensions/hooks/tools/system prompt, §8 Built-in tasks (generation/tool/compaction/usage/live),
  §9 Document observation (watches, view, task-graph). Where source and spec prose disagree, the source's executable
  behavior wins and the spec is read as the intent.
- **Tests** — `packages/durable/test/harness-*.test.ts` (~70 files: generation, generation-recovery, tools,
  tools-recovery, nested-tools, nested-tools-restart, tool-parks, tool-gates, tool-hooks, signals, submissions,
  failed-run-inbox, submit-in-commit, input-entries, inbox, continue, run-failure, restart-failure, tasks,
  tasks-recovery, ownership, park-children, compaction, structured-output, structured, turn-limit, view, view-run,
  live-deltas, hook-reads, hook-tasks, registry, registry-reader, scheduler-indexes, scheduler-retention,
  telemetry, telemetry-options, reports, observers, after-run, blocked, cancellation-barrier, callers,
  conversations, context, context-range, deferred-progress, group-commit, host-inputs, idle-scopes, inspect,
  json, lifecycle, partial-changes, prompt, read-only, storage-failure, task-graph), plus `codemode*.test.ts`
  (codemode, codemode-checkpoints, codemode-describe, codemode-imports, codemode-models) and `tools*.test.ts`
  (tools, tool-args-typebox, tool-output-bench). The port's own tests are ports of these, case by case, not new
  Dart-native assertions.
- **Examples** — `packages/durable/test/examples/**` (47 runnable topics). The slice-6-relevant examples
  (`05-harness`, `06-configuration`, `07-harness-conversations`, `09-registry-reload`, `10-extension-state`,
  `11-tasks`, `12-recovery`, `13-chat`, `14-system-prompt`, `16-coding-tools`, `18-json`, `19-inbox`, `20-late-join`,
  `21-subagent-foreground`, `22-subagent-background`, `23-child-tasks`, `24-compaction`, `28-sandbox-per-conversation`,
  `29-tool-override`, `30-reload-and-restart`, `31-transcript`, `32-tests-after-edits`, `33-turn-limit-and-continue`,
  `34-submit-in-commit`, `36-durable-views`, `37-harness-registry`, `38-signals`, `39-ask-a-person`,
  `40-tool-waits-for-webhook`, `41-tool-polls`, `42-parallel-children`, `43-subagent-waits`, `44-approval-gate`,
  `45-review-on-yield`, `46-after-tools-terminate`) are the behavioral references the port's tests mirror.

**Rationale**: The port's value is that it is falsifiably a port. A type named from memory, or a behavior asserted
without an upstream test behind it, is exactly the "speculative convenience API" the architecture plan forbids
(§6.3, §6.4). The governance layer (pi#10) makes this a check, not a convention: a row with no upstream coordinate
cannot be `verified`.

**Alternatives considered**: (a) Port from the README quick-start alone — rejected: the README is a tour, not a
contract, and omits the invariants (restart limits, replay policy, failed-run continuation) that the spec states.
(b) Port from the TypeScript declarations and infer bodies — rejected: inference is how a port silently diverges.

## D2 — Scope boundary: what is this slice and what is a later slice

**Decision**: In scope: the durable agent runtime — `pi.generation` (`harness/generation.ts`), `pi.tool`
(`harness/tool.ts`), `pi.compaction` (`harness/compaction.ts`), the scheduler's runtime-facing surface
(`harness/scheduler.ts` as consumed by the built-in tasks, not re-ported), the submission/inbox/live machinery
(`harness/submissions.ts`, `harness/inbox.ts`, `harness/live.ts`, `harness/agent.ts`), the extension registry and
resolution (`harness/registry.ts`, `harness/registry-reader.ts`, `harness/define.ts`, the resolution rules in
spec §7.1), the hook dispatch, signals and delivery (`src/signals.ts` + the `TaskRuntime.readSignal`/`tx.signal`
surface), memos and parks and nested calls (`harness/tool.ts`), subagents/ownership/abort (the scheduler's runtime
surface + `harness/task-graph.ts`), the committed view and transcript (`harness/view.ts`, `harness/transcript.ts`),
usage (`harness/usage.ts`), provider identity (`harness/provider.ts`), durable code mode (`src/codemode/**`), and the
`Harness`/`Conversation` facade (`harness/harness.ts`, `harness/context.ts`, `harness/prompt.ts`,
`harness/partial-changes.ts`). Out of scope (later slices): full pi-ai providers/APIs/OAuth/images beyond the
`Models` seam this slice calls; MCP (`packages/mcp`); coding-agent product behavior (`packages/coding-agent`); TUI
(`packages/tui`); evals (`packages/evals`); and the Zuraffa wrapper (`zuraffa_agent`, `zuraffa_browser_agent`).

**Rationale**: The architecture plan (§6.6) orders the work: slice 6 is "Durable agent: generation/tools,
submissions, extensions, signals, parked/nested tools, approvals, subagents, compaction, watches, and usage." Issue
pi#12's acceptance criteria name exactly the slice-6 set plus durable code mode. A slice that reached into providers,
MCP, or the coding agent would have to invent those contracts before their source is ported.

**Alternatives considered**: (a) Port the full pi-ai provider matrix too — rejected: this slice consumes pi-ai
through the `Models` seam (`getModel`/`streamSimple`/`fetchDeferred`/`cancelDeferred`); the provider matrix is the
AI slice. (b) Port `packages/coding-agent`'s coding tools and compaction policy — rejected: the coding agent is a
product package; this slice ports the *durable* compaction task and consumes the coding tools only as far as the
examples/tests exercise them.

## D3 — Build on the pi#11 foundation, do not re-derive it

**Decision**: The Session (mutation line, atomic commit, durability receipt, table-access rules, detached ownership,
failure taxonomy, close), immutable entries and built-in kinds, typed documents and families, conversations, the task
runtime (definitions, records, checkpoints, waits, sleeps, ownership, child graphs, abort cascades), the signal
*storage* in task memos (`pi.signal.<name>/<key>`), and the three storage backends with the conformance suite are all
consumed as committed pi#11 surface. This slice ports only the harness that runs on top: generation, tool,
submission, signal *delivery* (`tx.signal()`/`Harness.signal()`/`readSignal`), extension, compaction, view, usage,
identity, and code mode.

**Rationale**: pi#11's spec and plan fix the foundation's seams (`Storage`, `Session`, `TaskRuntime`, `DocDefinition`,
`defineTask`, the `Context`/abort signal). Re-porting them here would fork the contract and guarantee drift. The
signal split is deliberate: pi#11 defines the task-memo *storage* a signal uses (so sleeping tasks can carry signal
keys without a delivery engine); this slice defines the `SignalToken`/`SignalKey`/`SignalState` vocabulary and the
`tx.signal()`/`Harness.signal()` delivery with the upstream result taxonomy, which is what generation, tools, and
submissions call.

**Alternatives considered**: (a) Re-port the Session in this slice — rejected: the foundation is a released
dependency of this slice. (b) Move signal *storage* into this slice — rejected: pi#11's sleeping-task records and
`readSignal`-during-sleep already depend on the memo layout; changing it would break the foundation.

## D4 — Concurrency model: the pi#11 Session line, handlers off the line

**Decision**: The runtime runs on the pi#11 serialized Session line: the scheduler serially reserves eligible tasks
and reconciles on the line, while phase handlers (generation's request/poll, a tool's `execute`, a compaction's
summarize, a hook) run off the line with the invocation's abort `Context`. Deferred commits publish throttled
partials (generation's streamed message, a tool's running output/details/diagnostics) so watches see each at once
while Storage gets them with the next commit that reads `pi.live` or within `settings.progress.persistWithinMs`.
Dart's single-threaded event loop replaces upstream's "mutation line" with a serialized async queue, exactly as pi#11
established.

**Rationale**: Upstream's line/region/reconcile design (§5.4, §4) is what makes the scheduler's decisions stay
serialized while their storage overlaps, so `migrate`, registry snapshots, reports, and cleanup run once, after a
decision stands. The deferred-commit rule (§4.1, §8.2) is what bounds the `pi.live` delta chain to one generation or
one tool round. Dart's event loop gives the same single-line serialization without isolates.

**Alternatives considered**: (a) `Isolate`-per-task — rejected: isolates cannot share the in-memory task records and
value-detachment model the scheduler and session rely on; upstream's group commit is an optimization, not a semantic.
(b) A free-threaded task model — rejected: the runtime's whole correctness argument is single-line serialization.

## D5 — Provider seam: an injected `Models`, scripted in tests

**Decision**: Generation and compaction call a pi-ai `Models` interface (`getModel(ref)`, `streamSimple()`,
`fetchDeferred()`, `cancelDeferred()`) built on the pi#11 `ai` port, passed through `HarnessOptions.models` (a
`Models` or a function returning the current one, read at each use). Tests inject scripted providers that emit a
scripted sequence (a tool call, a retryable error, an answer, a deferred response) and a virtual clock; no live paid
provider is ever a test dependency. Provider errors and missing models are classified into the durable generation
outcomes (`no_model`, `model_error`, `interrupted`, `restart_limit`) per §8.3.

**Rationale**: Upstream uses `HarnessOptions.models` "without a Durable-specific model adapter" (§8) and classifies
pi-ai errors and `isContextOverflow()`/`isRetryableAssistantError()` into durable outcomes. The seam is the upstream
contract; the scripted provider is how the architecture plan's §6.4 rule ("paid live providers are never unit-test
dependencies") is honored.

**Alternatives considered**: (a) A Durable-specific model adapter — rejected: upstream has none; adding one invents
API. (b) Sanitized HTTP cassettes for every test — rejected as the *only* mechanism: useful for request/streaming
parity, but scripted providers cover the crash/commit boundaries more directly; cassettes supplement where practical.

## D6 — Code-mode sandbox seam and deterministic replay

**Decision**: The durable code-mode tool runs model-written JavaScript in a QuickJS-in-Wasm sandbox behind an
injectable host seam (the upstream `CodemodeSandboxBase`/host boundary). The deterministic-replay machinery — the
`pi.codemode.run` (start data + outcome) and `pi.codemode.journal` (one entry per delivered result) documents,
nested-call reattach by key (`c<VM call id>`), the acknowledged-call-count commit, and the divergence/version/
deadline refusal — is pure Dart over that seam. A real Wasm driver lands with a platform adapter, not in this slice's
core.

**Rationale**: `packages/durable/src/codemode/codemode.ts`'s header states the contract exactly: the VM runs only
when the host hands it a result; given the same start data, clock, seed, and ordered results, it makes the same calls;
a restart replays from the journal; a rerun refuses on version/fingerprint change, deadline, or divergence. This is
the architecture plan's slice-7 prerequisite landing here because the durable harness's code-mode tool is built on
this slice's generation/tool/nested-call machinery.

**Alternatives considered**: (a) A `dart:ffi`/Wasm binding in the core — rejected: breaks pure-Dart and the web
target. (b) Replaying by re-running the whole script from scratch — rejected: that is exactly the non-deterministic
divergence the journal exists to prevent.

## D7 — Testing: upstream-derived differential harness

**Decision**: Port the upstream `harness-*.test.ts` cases case by case into `pi_agent/test/durable/harness/`, and add
a differential harness that runs the same scripted scenario (scripted provider, virtual clock, storage ops, signals,
crash points) against the TypeScript oracle and the Dart port and compares normalized outcomes: event stream,
transcript, task state, stored commits, errors, and usage. Crash durable work before and after every commit boundary;
verify replay policy, idempotency, settlement, retry, and restart-limit behavior.

**Rationale**: Architecture plan §6.4: "A green Dart-only suite is necessary but not sufficient for a parity claim."
The differential harness is the evidence a ledger row needs to become `verified`; a Dart-only green suite is not.

**Alternatives considered**: (a) Dart-native tests only — rejected: necessary but not sufficient. (b) Cassettes for
every scenario — rejected as the sole mechanism: cassettes cover request/streaming parity, but crash/commit boundary
parity needs the scripted-provider + crash-point harness.

## D8 — Coverage rows without pi#10's tooling

**Decision**: pi#10's generator (`scripts/coverage/`, `coverage/`) is unbuilt. This slice records its durable-agent
rows in the registry shape pi#10's spec defines (`specs/002-upstream-coverage-governance/data-model.md`: a
`coverage/registry/behavior-registry.json` with `schema_version`, `registry_version`, `reviewed_base_sha`,
`target_upstream_sha`, `verified_upstream_sha`, and a `behaviors` array whose rows carry `id`, `area`,
`upstream_path`, `export`, `behavior_kind`, `normative_refs`, `dart_entrypoint`, `dart_impl`, `dart_test`,
`status`, `evidence`, `divergence`, `issue`). Rows are added, never `verified_upstream_sha`; the file states the pi#10
dependency. Each row's `status` is `in_progress`/`implemented_unverified` (with a divergence + tracking issue) for
this planning stage, since no code exists yet, and each distinguishes this slice's verification from full global
parity and links the remaining gap (full providers, MCP, coding-agent, TUI, evals, or global parity at one SHA).

**Rationale**: The user requires coverage-manifest rows with the exact verified SHA and every remaining gap, without
advancing `verified_upstream_sha`. pi#10 defines the shape; this slice uses that shape rather than inventing a second
manifest format. The row statuses are honest: a planning artifact is not `verified` (that needs passing differential
evidence), so the rows are `in_progress` with a divergence and issue, and the manifest header's
`verified_upstream_sha` stays `null`.

**Alternatives considered**: (a) Wait for pi#10 and record nothing now — rejected: the user requires the rows with
this slice. (b) Invent a new manifest file — rejected: two formats would make the later pi#10 generator reconcile
two sources.

## D9 — No second runtime model, no product leakage

**Decision**: The port imports nothing from `zuraffa`, `zuraffa_agent`, a browser package, or product-domain code;
the purity check fails on any such import. It introduces no runtime type or function that renames or reinterprets an
upstream concept, stands up no second agent loop, and invents no convenience API ahead of the upstream source that
defines it. The existing `package:pi/pi.dart` surface (`Agent`, `AgentLoop`, `Conversation`) is untouched; the
runtime is additive under `package:pi/durable.dart`.

**Rationale**: The architecture plan's compile-time rules (§4) and delivery gates (§12) are explicit: "`pi` never
imports `zuraffa`, `zuraffa_agent`, or either browser package." The Zuraffa wrapper is a separate package
(`zuraffa_agent`) that consumes this runtime; a leak here would collapse the four-package boundary the plan is built
on.

**Alternatives considered**: (a) Reuse the existing Dart `AgentLoop` as the durable generation loop — rejected: that
would be a second, non-durable runtime model; the durable generation is `pi.generation`, and the existing wrappers are
out of scope for this slice. (b) Add a convenience `BrowserAgent` facade — rejected: that is `zuraffa_browser_agent`,
a different package.