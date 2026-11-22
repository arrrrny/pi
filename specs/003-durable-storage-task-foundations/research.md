# Phase 0 Research: Durable Storage and Task Foundations

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)
**Oracle**: `earendil-works/pi` at `780bf31fcaeb252fa9b68df3964c735eae75bde3` (packages `durable`, `chord`,
`schema`, `telemetry`, `env`, all at version 1.6.0)

Every decision below is anchored in a named upstream file, specification section, test, or example at the target SHA.
Where this document and the upstream source disagree, the upstream source wins and this document is corrected.

## D1 — Grounding rule: source, spec, tests, examples, not memory

**Decision**: Every Dart type, function, error, and behavior in this slice is derived from a named upstream artifact at
the target SHA. The four artifact classes are:

- **Source** — `packages/durable/src/**`, `packages/chord/src/**`, `packages/schema/src/**`,
  `packages/telemetry/src/**`. The exported types and the behavior in their bodies are the port's contract.
- **Specification** — `packages/durable/docs/spec.md` (normative, 7,303 lines) and `packages/chord/docs/design.md`
  plus `layer-1.md`/`layer-2.md` and the slice specs. Where source and spec prose disagree, the source's executable
  behavior wins and the spec is read as the intent.
- **Tests** — `packages/durable/test/**` (178 files, of which ~34 storage conformance cases in
  `src/testing/storage-conformance.ts`) and `packages/chord/test/**` (563 files). The port's own tests are ports of
  these, case by case, not new Dart-native assertions.
- **Examples** — `packages/durable/test/examples/**` (48 runnable topics) and `packages/chord/test/examples/**`
  (43 topics). The foundation-relevant examples (`00-conversation`, `01-documents`, `02-forks`, `03-owned-conversations`,
  `04-watches`, `05-harness`, `08-context`, `11-tasks`, `12-recovery`, `21-subagent-foreground`,
  `23-child-tasks`, `30-reload-and-restart`) are the behavioral references the port's tests mirror.

**Rationale**: The port's value is that it is falsifiably a port. A type named from memory, or a behavior asserted
without an upstream test behind it, is exactly the "speculative convenience API" the architecture plan forbids
(§6.3, §6.4). The governance layer (pi#10) makes this a check, not a convention: a row with no upstream coordinate
cannot be `verified`.

**Alternatives considered**: (a) Port from the README quick-start alone — rejected: the README is a tour, not a
contract, and omits the invariants (atomic commit, detached values, abort cascade) that the spec states. (b) Port from
the TypeScript declarations and infer bodies — rejected: inference is how a port silently diverges.

## D2 — Scope boundary: what is in this slice and what is pi#12

**Decision**: In scope: `schema`, `telemetry`, the chord primitives durable imports (`context`, `json`, `delta`,
`documents`, `watch`, `ids`, and `store` only as far as durable's storage backends require), and durable's
`types.ts`, `entries.ts`, `documents.ts`, `errors.ts`, `ids.ts`, `timers.ts`, `session/**`, `storage/**`, and the
`harness/` scheduler/abort/task-graph machinery. Out of scope (pi#12): generation, tools, submissions, signals,
compaction, hooks, extensions, code mode, product missions, and the `Harness`/`Conversation` facade.

**Rationale**: The architecture plan ( §6.6) orders the work: slice 5 is "Durable foundation: atomic storage/commits,
sessions, tasks, scheduler, recovery, and conformance"; slice 6 is "Durable agent: generation/tools, submissions,
extensions, signals, parked/nested tools, approvals, subagents, compaction, watches, and usage." Issue pi#11's
acceptance criteria name exactly the slice-5 set, and the user instruction keeps "generation, tools, submissions,
signals and product missions in pi#12." A foundation that reached into generation would have to invent the generation
task's contract before `harness/generation.ts` is ported.

**Alternatives considered**: (a) Port the whole `Harness` facade too — rejected: the facade wires in generation,
tools, and submissions, so it cannot be built until those exist; the foundation is the layer under it. (b) Port
`signals.ts` because sleeping tasks reference signal keys — rejected: `sleeping` states *carry* signal keys (a JSON
list) without needing the signal delivery machinery, which is pi#12; the port stores and resumes on them, and
`readSignal` lands with pi#12.

## D3 — Storage contract first, backends second

**Decision**: Port the `Storage` interface (`packages/durable/src/storage/store/storage.ts`, spec §10) and its
supporting types (`CommitResult`, `StorageWrite`, `DocumentContent`, `StoredDocument`, the query/cursor types) before
any backend. Session, tasks, and all three backends are then expressed against it.

**Rationale**: In upstream, `Storage` is the atomic persistence boundary (spec §10: "Atomic persistence boundary for
Session records") and every other layer depends on it. Porting a backend first would invert the dependency and force
the interface to be derived from one backend's quirks. The conformance suite
(`packages/durable/src/testing/storage-conformance.ts`, 34 cases) is written against the interface, so the interface
must be stable first.

**Alternatives considered**: (a) Define the interface from the memory backend — rejected: memory is "the reference
semantics" (spec §11.1) but the interface must accommodate SQLite's one-transaction-per-call and JSONL's sidecar
model, which memory does not exercise. (b) Skip the interface and use a Dart abstract class per backend — rejected:
the conformance suite and the session both need one contract to target.

## D4 — Detached-value ownership

**Decision**: Memory copies retained write values and all read results (spec §11.1: "It copies retained write values
and all read results. This deliberately simulates the ownership boundary naturally created by SQLite
encoding/decoding and JSONL serialization"). JSONL detaches through serialization and decoded indexes (spec §11.3).
SQLite detaches through decoded rows. Immutable strings may be shared; mutable arrays and objects may not (spec §4,
"Storage ownership").

**Rationale**: Upstream treats aliasing as a correctness bug, not a performance choice, and the conformance suite has
explicit cases for it ("detaches retained writes and every returned record", "detaches prototype-like JSON keys
without changing object prototypes"). A Dart port that returns the same `List`/`Map` instance it stored would pass a
happy-path test and fail the boundary.

**Alternatives considered**: (a) Rely on Dart's lack of `Object.freeze` and document "do not mutate" — rejected: that
is the exact class of bug the conformance suite catches, and a comment is not a gate.

## D5 — Concurrency: a serialized line, not isolates

**Decision**: Upstream's "Session mutation line runs one job at a time" (spec §4) becomes a Dart serialized async
queue: one commit callback at a time; storage overlaps the line through `await`; commits publish in line order after
their storage call settles. Group commit (batching several admitted commits into one `Storage.commit()` call) is
implemented as a batching writer, because it is upstream's optimization and is observable in the receipt order.

**Rationale**: Dart's single-threaded event loop gives the same serialization upstream's line provides, without the
value-ownership cost of isolates. Upstream's line is a logical construct ("The mutation line runs one commit callback
at a time"), not a thread. A port that used an isolate per commit would have to copy every value across the isolate
boundary, contradicting D4's detached-value model and upstream's shared-immutable-string rule.

**Alternatives considered**: (a) `synchronized`/mutex — rejected: Dart has no mutex in the core; a serialized
async queue is the idiomatic and correct equivalent. (b) `Isolate`-per-commit — rejected: changes the value model and
the group-commit semantics.

## D6 — Type mapping from TypeScript to Dart

**Decision**:

| Upstream | Dart | Why |
| --- | --- | --- |
| `type Id<Kind, Type> = number & {brand}` | `extension type Id<Kind extends String>(int)` | Branded int; no runtime cost, compile-time nominal typing. |
| `type Seq = number & {brand}` | `extension type Seq(int)` | Same. |
| `type JsonValue` | `Object?` with a `Json` validator at the storage boundary | Dart has no union types; validation at the trust boundary (decoded JSON, DB rows) is where upstream validates too. |
| Discriminated union (`TaskState`, `WakeReason`, `TaskOutcome`) | `sealed class` with a `kind`/status getter and one subclass per case | Dart 3 sealed classes give exhaustive `switch` over the union. |
| `type JsonObject = { [k: string]: JsonValue }` | `Map<String, Object?>` | Same. |
| `type Op = readonly [...]` tuple union | `sealed class Op` with `r`, `s`, `d`, `a`, `t`, `p`, `m` subclasses | Tuple unions become sealed classes; the encoded wire form is `List<Object?>`. |
| `interface Storage` | `abstract interface class Storage` | Same contract. |
| `type TaskDefinition` | `abstract interface class TaskDefinition<I, S, R>` | Same. |
| `type WatchHandle<T>` | `abstract interface class WatchHandle<T>` | Same. |

**Rationale**: Sealed classes and extension types are the Dart 3 tools that preserve upstream's nominal typing without
`any` or runtime shape checks. The mapping is one-to-one; no Dart type renames an upstream concept.

**Alternatives considered**: (a) `typedef` aliases — rejected: aliases are structurally typed in Dart and would lose
the nominal brand. (b) `dynamic` for JSON — rejected: violates the no-`any` rule and loses the boundary check.

## D7 — Errors

**Decision**: Port `packages/durable/src/errors.ts` exactly: `ReadAfterWrite` (a table read after its first table
write), `StorageRequestError` (an invalid read with no durable effect, failing only its own call),
`SessionFailed` (a storage/commit error, failing the session, carrying the first error as `cause`),
`ReadOnlySession`, `ConversationBusy`, `ConversationIdle`, plus the `errorMessage` helper.

**Rationale**: The failure taxonomy is part of the contract (spec §10.1), not an implementation detail: a host keys
its recovery on which error it got. Renaming or merging these errors would change observable behavior.

**Alternatives considered**: (a) A single `DurableException` with a code — rejected: the spec's per-kind rule ("One
rule per kind of error, so a host knows what happens without reading code") requires the types to be distinct.

## D8 — SQLite platform seam

**Decision**: Define `abstract interface class DurableSqliteExecutor` with the operations the backend needs
(`execute`, `select`, `transaction`), plus an in-memory fake for tests. The backend depends only on this interface.
A platform adapter (not in this slice) supplies the real driver.

**Rationale**: `packages/durable/src/storage/sqlite/database.ts` is a one-line re-export of the host's
`SqliteExecutor` (`@earendil-works/chord/sqlite`), and the backend's own tests inject an in-memory executor. Dart has
no built-in SQLite, so the port keeps the same seam: the core stays pure Dart and platform-neutral (spec §11.2's
"Schema shape, WAL checkpoint cadence, and synchronous defaults are backend implementation choices validated by
conformance"), and the conformance suite runs against the fake without a native driver.

**Alternatives considered**: (a) `dart:ffi` sqlite in the core — rejected: breaks the web target and the pure-Dart
constraint. (b) `sqflite`/`sqlite3` package dependency — rejected: adds a runtime dependency to a foundation that must
stay dependency-free.

## D9 — JSONL file-system seam

**Decision**: Define a minimal `FileSystem` capability (read/write/append/list/delete over a path) that the JSONL
backend depends on, mirroring upstream's "JSONL depends on the portable `FileSystem` capability, not the broader
`ExecutionEnv`" (spec §11.3). The default test implementation is an in-memory or temp-dir file system.

**Rationale**: The portability rule is explicit upstream, and it keeps the JSONL backend testable without touching the
host's real file system in unit tests.

**Alternatives considered**: (a) Use `dart:io` directly in the backend — rejected: couples the backend to the VM and
breaks the web target, contradicting upstream's own capability seam.

## D10 — Crash-and-reopen evidence

**Decision**: A dedicated crash test suite drives a session, kills it at every commit boundary (before admission,
mid-write, after durable, before publish), reopens the same storage, and asserts the reopened state is always a
complete prefix of the log. Upstream's own `harness-tasks-recovery.test.ts`, `harness-generation-recovery.test.ts`,
`session-*.test.ts`, and the crash example `chord/test/examples/42-worker-crash/` are the derivation source.

**Rationale**: Issue pi#11 requires "Crash/reopen tests verify partial commits are never published and running work
resumes from the last committed checkpoint." Upstream states the invariant (spec §1 invariant 2: "a commit that fails
before it is durable publishes nothing … reopening recovers it") and tests it directly. A happy-path test cannot show
this.

**Alternatives considered**: (a) A single crash test — rejected: the invariant must hold at *every* boundary, and
"crash before durable vs. after durable" are different assertions. (b) Chaos/replay tools — rejected: overkill for a
foundation; a scripted boundary matrix is deterministic and sufficient.

## D11 — Coverage rows without pi#10's tooling

**Decision**: pi#10's generator (`scripts/coverage/`, `coverage/`) is unbuilt. This slice records its foundation rows
in the registry shape pi#10's spec defines (`specs/002-upstream-coverage-governance/data-model.md`: a
`coverage/registry/behavior-registry.json` with `schema_version`, `registry_version`, `reviewed_base_sha`,
`areas`, `behaviors[]`, `unmapped_rationales[]`), each row carrying `area`, `upstream_path`, `export`, `internal`,
`behavior_kind`, `normative_refs`, `platforms`, `dart_entrypoint`, `dart_impl`, `dart_test`, `status`, `evidence`,
`divergence`, `issue`. Rows are added, never `verified_upstream_sha`; the file states the pi#10 dependency.

**Rationale**: The user requires coverage-manifest rows with the exact verified SHA and every remaining gap, without
advancing `verified_upstream_sha`. pi#10 defines the shape; this slice uses that shape rather than inventing a second
one. The pi#10 dependency (already declared on the issue) is explicit.

**Alternatives considered**: (a) Wait for pi#10 to land — rejected: this slice must ship its rows now, and the
registry shape is fixed by pi#10's committed spec. (b) Invent a new manifest file — rejected: two formats would
guarantee drift.

## D12 — Testing and verification

**Decision**: One test file per source file under `pi_agent/test/durable/`. The storage conformance suite is ported as
a single parameterized suite registered once per backend. Crash evidence lives under `pi_agent/test/durable/crash/`.
Tests run with `dart test -j 2` from `pi_agent/`. A test file created or modified by this work is run and iterated
until it passes, per `AGENTS.md`.

**Rationale**: The fleet's concurrency cap is mandatory, and the "one test file per source file" rule is the Chord v2
code style the repo applies to `packages/chord` — the port inherits it so the Dart source stays auditable.

**Alternatives considered**: (a) A single monolithic test file — rejected: the repo's style rule and auditability.
(b) Running the full suite without the cap — rejected: it starves shared services (fleet guard).