# Implementation Plan: Durable Agent Runtime Parity

**Branch**: `004-durable-agent-runtime-parity` | **Date**: 2026-11-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-durable-agent-runtime-parity/spec.md`

## Summary

Port the upstream `@earendil-works/pi-durable` 1.6.0 **durable agent runtime** and the parts of
`@earendil-works/pi-agent-core`, `@earendil-works/pi-ai`, and `@earendil-works/pi-codemode` it consumes to Dart as
one vertical slice (pi#8 slice 6, "Durable agent"), built on the pi#11 durable storage/task foundation. The port is
grounded line by line in the upstream TypeScript at `780bf31fcaeb252fa9b68df3964c735eae75bde3`:
`packages/durable/docs/spec.md` §§6–9 is normative for submissions, extensions/hooks/tools, built-in tasks, and
document observation; `packages/durable/src/harness/` defines the runtime; `packages/durable/src/signals.ts` and
`src/codemode/` define signals and durable code mode; the upstream tests (`packages/durable/test/harness-*.test.ts`,
`codemode*.test.ts`, `tools*.test.ts`) and runnable examples (`test/examples/05-harness.ts` … `47-*.ts`) are the
oracle the port's differential tests are derived from.

Seven layers, each built on the pi#11 foundation below it:

1. **Generation and tool tasks** — `pi.generation` (prepare/request/retry/poll/tools/finish/drain/afterTools/yield)
   and `pi.tool` (call/execute/parked), with replay policies, output bounding/throttling, diagnostics, and restart
   limits.
2. **Submissions, inbox, and run control** — `pi.inbox`, `pi.live`, admission/dedup, boundaries and queue modes,
   `afterFailedRun`, `continue`, and the live-document migration.
3. **Extensions and configuration** — the registry, `defineExtension`/`section`/`hook`/`wrapTool`/`wrapSection`,
   per-conversation resolution, hook dispatch, per-conversation `configure`, and registry reload.
4. **Signals, memos, parks, and nested calls** — `defineSignal`, `tx.signal()` delivery, memoized idempotency,
   tool parks (`sleep`/`wait`), nested calls via `NestedCallDoc`, and approval gates.
5. **Subagents, ownership/abort, compaction, views, usage, identity** — foreground/background subagents, the abort
   protocol and cascade, `pi.compaction`, the committed `ConversationView` and `ConversationTranscript`, `pi.usage`,
   and the `pi.provider` session identity.
6. **Durable code mode** — the code-mode tool, deterministic replay via the journal and run documents, nested-call
   reattach by key, and divergence refusal.
7. **Differential evidence and coverage** — the upstream-derived differential tests across every boundary and the
   coverage-manifest rows for this slice only.

The pi#11 foundation (schema, telemetry, chord, env, the Session, entries, documents, conversations, the task
runtime, storage) is consumed, not re-ported. Full providers, MCP, coding-agent, TUI, and evals are later slices.

## Technical Context

**Language/Version**: Dart SDK ^3.0.0 (the existing `pi_agent` constraint); the port uses only erasable Dart and
`dart:async`, `dart:convert`, `dart:typed_data`, plus the pi#11 `schema`/`telemetry`/`chord`/`env` ports
**Primary Dependencies**: none added to `pi_agent`'s runtime. The durable code-mode QuickJS/Wasm sandbox sits behind
an injectable `CodemodeSandboxBase`/host seam (a platform adapter, not in this slice, supplies the Wasm driver). The
pi-ai `Models` interface (catalog, credentials, request transforms, `streamSimple`/`fetchDeferred`/
`cancelDeferred`) is consumed as an injected seam; tests supply scripted providers and virtual clocks.
**Storage**: the pi#11 `Storage` backends (memory/JSONL/SQLite) unchanged; this slice writes its task records,
documents, entries, and submissions through the pi#11 commit boundary
**Testing**: `dart test -j 2` in `pi_agent/` (fleet concurrency cap); one test file per source file; upstream-derived
differential tests ported case by case; scripted providers and virtual clocks, no paid provider
**Target Platform**: pure Dart VM; the code-mode Wasm sandbox seam keeps the core platform-neutral
**Project Type**: single Dart library inside the existing monorepo (`pi_agent/`), exported through the pi#11
`package:pi/durable.dart` entry library
**Performance Goals**: a scripted tool round with a sequential and a parallel batch commits and reopens within a
`dart test` default timeout; a streamed response's throttled partials commit at most every
`settings.progress.partialIntervalMs`; a conversation view mount derives one Chord batch per observer per
publication
**Constraints**: no Zuraffa/browser/product imports (purity gate); no renamed or invented runtime API; no second
agent loop; no mutation of the existing `package:pi/pi.dart` surface; forward-only artifacts-only commits; no paid
provider calls in tests
**Scale/Scope**: the durable agent runtime spans ~20 upstream `harness/*.ts` source files (~12,500 lines, dominated
by `scheduler.ts` 3,401, `tool.ts` 1,501, `generation.ts` 1,369, `types.ts` 1,240), `signals.ts`, `codemode/`, and
the consumed `tools/`, `images/`, `tool-search/`; ~80 upstream `harness-*.test.ts` / `codemode*.test.ts` /
`tools*.test.ts` files and 43 `test/examples/` are the derivation source, filtered to this slice's own behavior

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` is the unfilled scaffold (every section still carries `[PLACEHOLDER]`), so there are
no project-specific gates. Checked against the hard rules in `AGENTS.md`:

- **Artifacts only, explicit paths** — automation commits stage `specs/004-durable-agent-runtime-parity/` and, when
  this slice lands code, `pi_agent/lib/src/durable/harness/`, `pi_agent/lib/src/durable/signals.dart`,
  `pi_agent/lib/src/durable/codemode/`, and `pi_agent/test/durable/`; never `git add -A`.
- **No Zuraffa/browser/product imports** — enforced as a check, not a comment; a forbidden import fails the slice.
- **No renamed or invented API, no second agent loop** — every exported Dart type and function is named in
  `data-model.md` with the upstream file and symbol it ports; a name with no upstream source, or any second model
  or durable loop, is a defect.
- **No `any`, no runtime checks on typed values** — the port is typed Dart; JSON is validated only at the storage
  and wire trust boundaries (decoded provider/DB values, tool arguments), exactly where upstream validates it.
- **Pin the oracle** — every row records upstream SHA `780bf31f…` and package version 1.6.0; the port's own version
  and the Dart SDK are recorded in the manifest header.
- **Test concurrency cap** — `dart test -j 2`, `flutter test --concurrency=2` in every documented command.
- **No changelog entry** — this slice adds new library surface but touches no `packages/*` upstream source; the
  `pi_agent/CHANGELOG.md` entry is added under `## [Unreleased]` only if `pi_agent` is versioned by this work.
- **No Zuraffa generation** — `zfa` is not applicable: `pi_agent` is a hand-written port, not a Zuraffa application.

**Verdict**: PASS — no constitutional violations. No row in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/004-durable-agent-runtime-parity/
├── plan.md                     # This file
├── research.md                 # Phase 0 — decisions and rationale
├── data-model.md               # Phase 1 — Dart types, upstream source, and contracts
├── quickstart.md               # Phase 1 — how to run and validate the slice
├── coverage-rows.md            # Phase 1 — this slice's coverage-manifest rows vs global parity
├── checklists/
│   └── requirements.md         # Spec quality checklist
└── contracts/
    ├── generation.md           # Phase 1 — pi.generation task and its phases
    ├── tools.md                # Phase 1 — pi.tool task, parks, nested calls, diagnostics
    ├── submissions.md          # Phase 1 — pi.inbox, pi.live, admission, boundaries, afterFailedRun
    ├── extensions.md           # Phase 1 — registry, sections, hooks, wrappers, resolution
    ├── signals.md              # Phase 1 — signals, memos, gates, approval
    ├── runtime.md              # Phase 1 — subagents, ownership/abort, compaction, views, usage, identity
    └── codemode.md             # Phase 1 — durable code mode and deterministic replay
```

### Source Code (repository root)

```text
pi_agent/
├── lib/
│   ├── durable.dart                       # pi#11 entry library (unchanged surface; this slice extends it)
│   └── src/
│       ├── schema/                        # pi#11 (consumed)
│       ├── telemetry/                     # pi#11 (consumed)
│       ├── chord/                         # pi#11 (consumed)
│       ├── env/                           # pi#11 (consumed)
│       └── durable/                       # pi#11 foundation + this slice's runtime
│           ├── types.dart                 # pi#11 (consumed): EntryRecord, TaskRecord, Storage, Tx, …
│           ├── entries.dart               # pi#11 (consumed): Entry tokens incl. pi.user/assistant/tool-result
│           ├── documents.dart             # pi#11 (consumed): defineDoc, defineDocFamily
│           ├── errors.dart                # pi#11 (consumed) + this slice's generation/tool errors
│           ├── session/                   # pi#11 (consumed): mutation line, transaction, writer
│           ├── storage/                   # pi#11 (consumed): memory/jsonl/sqlite + conformance
│           ├── tasks.ts → tasks.dart      # pi#11 (consumed): defineTask, TaskDefinition
│           ├── signals.dart               # NEW: defineSignal, SignalToken/Key/State, SubmissionSettled
│           ├── harness/                   # NEW: the durable agent runtime
│           │   ├── types.dart             #   Agent, AgentState, Extension, Hook*, Tool*, SubmissionDraft, HarnessOptions, HarnessSettings, LiveState, RunSummary, …
│           │   ├── define.dart            #   defineExtension, section, hook, hookTask, wrapTool, wrapSection
│           │   ├── registry.dart          #   createRegistry, Registry, RegistrySnapshot
│           │   ├── registry-reader.dart   #   registryReader
│           │   ├── generation.dart        #   pi.generation task (prepare/request/retry/poll/tools/finish/drain/afterTools/yield)
│           │   ├── tool.dart              #   pi.tool task, NestedCallDoc, ToolTaskInput/Checkpoint/Result
│           │   ├── scheduler.dart         #   reservation, reconcile, wake, abort cascade, restart limits, blocked reasons
│           │   ├── agent.dart             #   the Agent built-in task and agent resolution
│           │   ├── harness.dart           #   Harness: open, root, submit, signal, usage, inspect, close
│           │   ├── live.dart              #   pi.live document + run control helpers
│           │   ├── inbox.dart             #   InboxDoc, InboxItem, InboxState
│           │   ├── submissions.dart       #   SubmissionRecord, admission, dedup, boundaries, settleSubmission
│           │   ├── context.dart           #   ContextView, model-context derivation, range selection helpers
│           │   ├── compaction.dart        #   pi.compaction task
│           │   ├── view.dart              #   ConversationView, ConversationWindow, ConversationTranscript
│           │   ├── transcript.dart        #   ConversationTranscript, TranscriptItem/View
│           │   ├── usage.dart             #   UsageDoc, UsageState
│           │   ├── provider.dart          #   ProviderDoc, ProviderState (session identity)
│           │   ├── prompt.dart            #   system-prompt preparation (§7.4)
│           │   ├── partial-changes.dart   #   deferred partial commits
│           │   ├── task-graph.dart        #   TaskGraph view
│           │   ├── telemetry.dart         #   DURABLE_TELEMETRY_SCHEMA
│           │   ├── parks.dart             #   park helpers
│           │   └── json.dart, util.dart   #   json helpers, errorMessage
│           ├── codemode/                  # NEW: durable code mode
│           │   ├── codemode.dart          #   the code-mode tool, deterministic replay, journal/run docs
│           │   ├── describe.dart, models.dart, output.dart
│           └── tools/                     # NEW (as consumed by the harness): bash/edit/read/write + image processors
└── test/
    └── durable/                           # pi#11 tests + this slice's
        ├── harness/                        #   generation/tools/submissions/signals/parks/compaction/view/usage
        ├── codemode/                       #   deterministic-replay and divergence tests
        └── differential/                   #   scripted-provider, virtual-clock differential scenarios
```

**Structure Decision**: The runtime lives in a new `pi_agent/lib/src/durable/harness/` subtree beside the pi#11
foundation and is exported through the same `package:pi/durable.dart` entry library, mirroring upstream's package
boundary (architecture plan §6.2: "one published `pi` package with focused entry libraries that mirror upstream
package/export boundaries"). Signals and code mode live in their own subtrees because upstream keeps them as
distinct source files (`src/signals.ts`, `src/codemode/`). The consumed `tools/` and `images/` are ported only as
far as the harness needs (the `bash`/`edit`/`read`/`write` tools the examples and tests exercise). The pi-ai
`Models` interface and the QuickJS/Wasm sandbox are injectable seams so the core stays pure Dart and tests use
scripted providers and virtual clocks.

## Phase 0 — Research

See [research.md](./research.md). Decisions that shape the build:

- **Oracle and grounding** — every Dart type and behavior is derived from a named upstream file at the target SHA, not
  from the prose alone. `packages/durable/docs/spec.md` §§6–9 is normative; `packages/durable/src/harness/` and
  `src/signals.ts`/`src/codemode/` define the runtime; upstream tests and `test/examples/` are the derivation source
  for the port's own differential tests. Rejected: porting from the README or from memory of the API.
- **Build on the pi#11 foundation, do not re-derive it** — the Session, task runtime, documents, entries, storage,
  and signal *storage* are consumed as committed. This slice ports only the harness (generation, tool, submission,
  signal *delivery*, extension, compaction, view, usage, identity, code mode). Rejected: re-porting the foundation or
  inventing a second store.
- **Signals split across the foundation and this slice** — pi#11 defines the task-memo *storage* a signal uses
  (`pi.signal.<name>/<key>`); this slice defines the `SignalToken`/`SignalKey`/`SignalState` vocabulary and
  `tx.signal()`/`Harness.signal()` delivery with the upstream result taxonomy. Rejected: inventing a separate signal
  store.
- **Concurrency model** — the runtime runs on the pi#11 serialized Session line: phase handlers run off the line, the
  scheduler reserves and reconciles on it, and deferred commits publish throttled partials. Dart's single-threaded
  event loop replaces upstream's "mutation line" with a serialized async queue, as in pi#11. Rejected: `Isolate`-per
  -task (would change the value-ownership and value-detachment model).
- **Provider seam** — generation calls a pi-ai `Models` interface (`getModel`, `streamSimple`, `fetchDeferred`,
  `cancelDeferred`) built on the pi#11 `ai` port; tests inject scripted providers and a virtual clock, never a live
  paid provider. Rejected: a Durable-specific model adapter (upstream uses none) or a live provider in tests.
- **Code-mode sandbox seam** — the QuickJS/Wasm sandbox is an injectable host seam; the deterministic-replay journal,
  nested-call reattach, and divergence refusal are pure Dart over it. Rejected: a `dart:ffi`/Wasm binding in the core
  (breaks pure-Dart and the web target).
- **Testing** — port upstream test cases case by case into `pi_agent/test/durable/`; add a differential harness that
  runs scripted scenarios against the TypeScript oracle and the Dart port and compares normalized outcomes (event
  stream, transcript, task state, stored commits, errors, usage). Rejected: writing Dart-native tests that only
  assert the happy path (necessary but not sufficient per architecture plan §6.4).
- **Coverage rows** — pi#10's tooling is unbuilt, so this slice records its rows in the registry shape pi#10's spec
  defines (`coverage/registry/behavior-registry.json` per `specs/002-…/data-model.md`) and states the pi#10
  dependency. Each row distinguishes this slice's verification from full global parity and links its remaining gap.
  Rejected: inventing a second manifest format or marking rows `verified` without passing evidence.

## Phase 1 — Design

See [data-model.md](./data-model.md) for the Dart types and their upstream sources,
[contracts/generation.md](./contracts/generation.md), [contracts/tools.md](./contracts/tools.md),
[contracts/submissions.md](./contracts/submissions.md), [contracts/extensions.md](./contracts/extensions.md),
[contracts/signals.md](./contracts/signals.md), [contracts/runtime.md](./contracts/runtime.md), and
[contracts/codemode.md](./contracts/codemode.md) for the file-level contracts,
[coverage-rows.md](./coverage-rows.md) for this slice's coverage-manifest rows, and [quickstart.md](./quickstart.md)
for the validation procedure.

Key design points:

- **Type mapping** — upstream's discriminated unions (generation/tool/compaction checkpoints, wake reasons, submission
  drafts, hook results, tool parks) become Dart `sealed` classes with a `kind`/`phase`/status field; upstream's
  branded `TaskId<R>`/`SubmissionId`/`SignalKey<T>` become the pi#11 extension types; upstream's `JsonObject`
  becomes `Map<String, Object?>` validated at the provider and storage boundaries only.
- **Generation phases** — the `pi.generation` task is a phase handler map over the upstream checkpoints; `request`
  and `poll` call the injected `Models`, commit throttled deferred partials, and classify the terminal message; the
  retry/poll sleeps and the `tools`/`finish`/`drain`/`afterTools`/`yield` waits use the pi#11 sleep/wait machinery.
- **Tool task and parks** — `pi.tool` resolves the tool among the phase agent's tools, validates arguments, runs the
  `beforeTool`/`afterTool` chains, and commits intent with the replay policy; a `ToolPark` parks the task so it holds
  no invocation; nested calls are their own `pi.tool` tasks recorded in `NestedCallDoc` and returned as
  `NestedToolExecutionResult` without entering the transcript.
- **Submissions and live document** — `pi.inbox` and `pi.live` are pi#11 documents with the upstream shapes and
  migrations; admission, dedup, boundaries, queue modes, and `afterFailedRun` run on the Session line; `continue` is
  idle-only.
- **Extensions** — the registry installs immutable extensions in place and publishes synchronously; resolution
  computes the agent per conversation per request/phase; hooks dispatch by task name in extension order off the line,
  with first-writer-wins decisions through task memos.
- **Purity and no-invention** — the purity check greps the new library for forbidden imports and for a second agent
  loop; the coverage rows name the upstream file each Dart type ports, and a row with no upstream source cannot be
  marked `verified`.

## Complexity Tracking

No constitutional violations; the table is intentionally empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| _none_    | —          | —                                   |