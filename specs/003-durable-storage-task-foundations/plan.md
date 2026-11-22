# Implementation Plan: Durable Storage and Task Foundations

**Branch**: `003-durable-storage-task-foundations` | **Date**: 2026-11-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-durable-storage-task-foundations/spec.md`

## Summary

Port upstream `@earendil-works/pi-durable` 1.6.0 and the Chord primitives it rests on to Dart as one vertical slice
(pi#8 slice 5, "Durable foundation"), plus the `schema` and `telemetry` prerequisites. The port is grounded line by
line in the upstream TypeScript at `780bf31fcaeb252fa9b68df3964c735eae75bde3`: `packages/durable/docs/spec.md` is
normative, `packages/chord/docs/design.md` and its layer specs define the primitives, and the upstream test suite
(`packages/durable/test/`, `packages/chord/test/`) and runnable examples (`test/examples/`) are the oracle the port's
own tests are derived from.

Six layers, each built on the one below:

1. **Prereqs** — `schema` (JSON value, JSON Schema, validate/coerce) and `telemetry` (context, propagation, typed
   spans/events/metrics, no-op).
2. **Chord primitives** — context, JSON value + copy, delta operations with immutable apply, drafts/pending, document
   handles and transactions, watches, and branded IDs.
3. **Records and documents** — immutable entries and their built-in kinds, typed document definitions and families with
   scope/version/migrate/checkpoint semantics, conversations.
4. **Session and storage** — the mutation line, atomic commit with a durability receipt, table access rules, detached
   ownership, the failure taxonomy, close semantics, and the `Storage` contract.
5. **Tasks** — definitions, records and checkpoints, the scheduler, waits, sleeps and timers, ownership and child
   graphs, structured concurrency, abort protocol and cascades.
6. **Backends and conformance** — memory (reference), JSONL, and SQLite behind one shared conformance suite, plus
   crash/reopen evidence.

Generation, tools, submissions, signals, product missions, hooks, extensions, compaction, and code mode are pi#12 and
are not ported here.

## Technical Context

**Language/Version**: Dart SDK ^3.0.0 (the existing `pi_agent` constraint); the port uses only erasable Dart and
`dart:async`, `dart:convert`, `dart:typed_data`
**Primary Dependencies**: none added to `pi_agent`'s runtime. The SQLite backend sits behind an injectable
`DurableSqliteExecutor` seam; a platform adapter (not in this slice) supplies the driver. Tests add no runtime
dependency beyond the existing `test` and `lints` dev-dependencies.
**Storage**: three backends — memory (reference semantics, copies on retain and on read), JSONL (a `FileSystem`
capability plus reclaimable sidecars), SQLite (one transaction per storage call, batched statements, migrations on
open)
**Testing**: `dart test -j 2` in `pi_agent/` (fleet concurrency cap); one test file per source file; upstream-derived
tests ported case by case; a shared storage conformance suite registered per backend
**Target Platform**: pure Dart VM; the SQLite seam keeps the core platform-neutral so `flutter test --concurrency=2`
is required only for a future platform-gated adapter, not for this slice
**Project Type**: single Dart library inside the existing monorepo (`pi_agent/`), exported through a new
`package:pi/durable.dart` entry library
**Performance Goals**: a 1,000-entry transcript commits and reopens within a `dart test` default timeout; a single
commit's storage round trips are batched per the SQLite spec (a few statements per call, not per row); document
reads replay only the base-plus-tail range
**Constraints**: no Zuraffa/browser/product imports (purity gate); no renamed or invented runtime API; no mutation of
the existing `package:pi/pi.dart` surface; forward-only artifacts-only commits; no paid provider calls in tests
**Scale/Scope**: ~103 upstream durable source files, ~336 chord source files, and 34 upstream storage conformance cases
in scope for the foundation; ~178 upstream durable test files and ~563 chord test files are the derivation source,
filtered to the foundation's own behavior

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` is the unfilled scaffold (every section still carries `[PLACEHOLDER]`), so there are
no project-specific gates. Checked against the hard rules in `AGENTS.md`:

- **Artifacts only, explicit paths** — automation commits stage `specs/003-durable-storage-task-foundations/` and, when
  this slice lands code, `pi_agent/lib/src/durable/`, `pi_agent/lib/durable.dart`, and `pi_agent/test/durable/`; never
  `git add -A`.
- **No Zuraffa/browser/product imports** — enforced as a check, not a comment; a forbidden import fails the slice.
- **No renamed or invented API** — every exported Dart type and function is named in `data-model.md` with the upstream
  file and symbol it ports; a name with no upstream source is a defect.
- **No `any`, no runtime checks on typed values** — the port is typed Dart; JSON is validated only at the storage
  trust boundary (decoded wire/DB values), exactly where upstream validates it.
- **Pin the oracle** — every row records upstream SHA `780bf31f…` and package version 1.6.0; the port's own version and
  the Dart SDK are recorded in the manifest header.
- **Test concurrency cap** — `dart test -j 2`, `flutter test --concurrency=2` in every documented command.
- **No changelog entry** — this slice adds new library surface but touches no `packages/*` upstream source; the
  `pi_agent/CHANGELOG.md` entry is added under `## [Unreleased]` only if `pi_agent` is versioned by this work.
- **No Zuraffa generation** — `zfa` is not applicable: `pi_agent` is a hand-written port, not a Zuraffa application.

**Verdict**: PASS — no constitutional violations. No row in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/003-durable-storage-task-foundations/
├── plan.md                     # This file
├── research.md                 # Phase 0 — decisions and rationale
├── data-model.md               # Phase 1 — Dart types, upstream source, and contracts
├── quickstart.md               # Phase 1 — how to run and validate the slice
├── checklists/
│   └── requirements.md         # Spec quality checklist
└── contracts/
    ├── storage.md              # Phase 1 — Storage contract and the three backends
    ├── session.md              # Phase 1 — Session, commit, publication, and failure contract
    ├── tasks.md                # Phase 1 — Task definition, record, scheduler, and abort contract
    └── documents.md            # Phase 1 — Document/entry/watch contract
```

### Source Code (repository root)

```text
pi_agent/
├── lib/
│   ├── durable.dart                       # New entry library: the durable foundation's public surface
│   └── src/
│       ├── schema/                        # Port of packages/schema (json, schema, validate, coerce, formats)
│       │   ├── json.dart                  #   JsonValue, copyJson, isJsonValue
│       │   ├── schema.dart                #   builders, compile, Validator, CoercingValidator
│       │   └── ...
│       ├── telemetry/                     # Port of packages/telemetry (context, propagation, typed, noop)
│       │   ├── context.dart
│       │   ├── telemetry.dart
│       │   └── ...
│       ├── chord/                         # Port of the chord primitives durable rests on
│       │   ├── context.dart               #   Context, cancellation, telemetry carrier
│       │   ├── json.dart                  #   JsonValue + copy
│       │   ├── delta.dart                 #   Op vocabulary, applyImmutable, Draft, Pending
│       │   ├── documents.dart             #   handles, transactions, line
│       │   ├── watch.dart                 #   WatchHandle, WatchCall, WatchEnd
│       │   └── ids.dart                   #   branded Id + Seq
│       └── durable/
│           ├── types.dart                 #   EntryRecord, DocDefinition, TaskRecord, Storage, CommitResult
│           ├── entries.dart               #   defineEntry + built-in kinds
│           ├── documents.dart             #   defineDoc, defineDocFamily, checkpoint policy
│           ├── errors.dart                #   ReadAfterWrite, StorageRequestError, SessionFailed, …
│           ├── session/                   #   mutation line, transaction, writer, adoption
│           ├── storage/
│           │   ├── storage.dart           #   Storage interface
│           │   ├── memory.dart            #   MemoryStorage (reference semantics)
│           │   ├── jsonl.dart             #   JSONL backend
│           │   ├── sqlite.dart            #   SQLite backend
│           │   └── conformance.dart       #   shared storage conformance suite
│           └── tasks/
│               ├── definition.dart        #   defineTask, TaskDefinition
│               ├── record.dart            #   TaskState, TaskRecord, WakeReason
│               ├── scheduler.dart         #   reservation, reconcile, wake
│               └── abort.dart             #   abort protocol and cascade
└── test/
    └── durable/                           # One test file per source file; upstream-derived cases
        ├── conformance/                   #   the shared suite registered per backend
        ├── crash/                         #   crash-and-reopen evidence
        └── ...
```

**Structure Decision**: The foundation lives in a new `pi_agent/lib/src/durable/` subtree with a single public entry
library, `pi_agent/lib/durable.dart`, mirroring upstream's package boundary (architecture plan §6.2: "one published
`pi` package with focused entry libraries that mirror upstream package/export boundaries"). The existing
`pi_agent/lib/pi.dart` surface (`Agent`, `AgentLoop`, `Conversation`, harness) is untouched by this slice — the
durable foundation is additive. Prereqs (`schema`, `telemetry`) and Chord primitives live in their own subtrees because
upstream keeps them as separate packages and the port must keep the same seams, so a later slice can port `ai` or
`agent` against them without reshuffling. The SQLite driver seam keeps the core pure Dart.

## Phase 0 — Research

See [research.md](./research.md). Decisions that shape the build:

- **Oracle and grounding** — every Dart type and behavior is derived from a named upstream file at the target SHA, not
  from the prose alone. `packages/durable/docs/spec.md` is normative; `packages/chord/docs/design.md` and the layer
  specs define the primitives; upstream tests and `test/examples/` are the derivation source for the port's own tests.
  Rejected: porting from the README or from memory of the API.
- **Scope slicing** — the foundation is ports of `schema`, `telemetry`, the chord primitives durable imports
  (`context`, `json`, `delta`, `documents`, `watch`, `store` only as far as durable's storage backends need), and
  `durable`'s `types`/`entries`/`documents`/`errors`/`session`/`storage`/`tasks` plus the scheduler, timers, and abort
  in `harness/`. Rejected: porting all of chord (plugins, jobs, react, remote, sqlite store engine) or all of durable
  (generation, tool, submissions, signals, compaction, codemode) — those are later slices.
- **Storage contract as the spine** — the `Storage` interface (`storage/store/storage.ts`) is ported first, because
  session, tasks, and all three backends are expressed against it. Rejected: porting a backend first and deriving the
  interface (that inverts the dependency and invents API).
- **Detached-value ownership** — memory copies on retain and on read; JSONL detaches through serialization; SQLite
  through decoded indexes. This is upstream's own boundary rule, and the conformance suite tests it directly. Rejected:
  sharing mutable containers (the exact bug the suite catches).
- **Concurrency model** — Dart's single-threaded event loop replaces upstream's "mutation line" with a serialized
  async queue: one commit callback at a time, storage overlapping via async, publication in line order. Rejected:
  `Isolate`-per-commit (upstream's group commit is an optimization, not a semantic, and isolates would change the
  value-ownership model).
- **Testing** — port upstream test cases case by case into `pi_agent/test/durable/`; register the shared conformance
  suite once per backend; add a crash suite that kills the session at each commit boundary. Rejected: writing
  Dart-native tests that only assert the happy path (necessary but not sufficient per architecture plan §6.4).
- **Platform seam for SQLite** — an injectable executor interface with an in-memory fake for tests; the real driver
  lands with a platform adapter. Rejected: a `dart:ffi` sqlite binding in the core (breaks pure-Dart and the web
  target).
- **Coverage rows** — pi#10's tooling is unbuilt, so this slice records its rows in the registry shape pi#10's spec
  defines (`coverage/registry/behavior-registry.json` plus the manifest schema in `specs/002-…/data-model.md`) and
  states the pi#10 dependency. Rejected: inventing a second manifest format or marking rows `verified` without
  passing evidence.

## Phase 1 — Design

See [data-model.md](./data-model.md) for the Dart types and their upstream sources,
[contracts/storage.md](./contracts/storage.md), [contracts/session.md](./contracts/session.md),
[contracts/tasks.md](./contracts/tasks.md), and [contracts/documents.md](./contracts/documents.md) for the file-level
contracts, and [quickstart.md](./quickstart.md) for the validation procedure.

Key design points:

- **Type mapping** — upstream's branded numeric `Id<Kind>`/`Seq` become Dart extension types over `int` (sound, no
  runtime cost); upstream's discriminated unions become Dart `sealed` classes with a `kind`/status field; upstream's
  `JsonObject` becomes `Map<String, Object?>` validated as strict JSON at the storage boundary only.
- **Commit atomicity** — a commit is one async transaction on a serialized line; all its writes (entries, documents,
  tasks, conversations, submissions) become one `Storage.commit()` call; nothing is observable until the storage call
  settles and the receipt fires.
- **Failure taxonomy** — `StorageRequestError` (invalid read, no durable effect, fails only the call),
  `SessionFailed` (a storage/commit error, fails the session), `ReadAfterWrite` (a table read after a write), exactly
  as `packages/durable/src/errors.ts` defines.
- **Task runtime** — the scheduler reserves eligible tasks off the line, runs phase handlers, and commits checkpoints;
  a task that crashes or closes re-parks as `pending` with its wake, so it resumes at its checkpoint. Abort marks
  cascade down the ownership tree; a task holds a `completing` outcome until its ordinary owned work drains.
- **Backends** — memory is the reference; JSONL and SQLite implement the same interface and pass the same conformance
  suite; the SQLite schema follows `storage/sqlite/migrations.ts` (metadata, record IDs, conversations, entries,
  tasks, submissions, documents, document revisions) with the version-2 task table that admits `sleeping`.
- **Purity and no-invention** — the purity check greps the new library for forbidden imports; the coverage rows name
  the upstream file each Dart type ports, and a row with no upstream source cannot be marked `verified`.

## Complexity Tracking

No constitutional violations; the table is intentionally empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| _none_    | —          | —                                   |