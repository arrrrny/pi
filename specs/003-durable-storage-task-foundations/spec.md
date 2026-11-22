# Feature Specification: Durable Storage and Task Foundations

**Feature Branch**: `003-durable-storage-task-foundations`
**Created**: 2026-11-22
**Status**: Draft
**Input**: GitHub issue [`arrrrny/pi#11`](https://github.com/arrrrny/pi/issues/11) — "dart-port: port durable storage and task foundations", the first vertical slice of the durable-pi parity epic [`arrrrny/pi#8`](https://github.com/arrrrny/pi/issues/8)
**Normative reference**: [pi, Zuraffa Agent, and BrowserAgent Architecture Plan](https://github.com/arrrrny/zuraffa_browser/blob/master/handoffs/2026-11-22-pi-zuraffa-browser-agent-architecture-plan.md), §2.1, §6.1–§6.6 (slice 5 "Durable foundation")
**Upstream oracle**: `earendil-works/pi` at commit `780bf31fcaeb252fa9b68df3964c735eae75bde3` (`@earendil-works/pi-durable` 1.6.0, `@earendil-works/pi-chord` 1.6.0, `@earendil-works/pi-schema` 1.6.0, `@earendil-works/pi-telemetry` 1.6.0)
**Depends on**: arrrrny/pi#10, arrrrny/pi#3, arrrrny/pi#4, arrrrny/pi#5, arrrrny/pi#6

## Why This Exists

The Dart `Conversation` under `pi_agent/lib/src/harness.dart` persists transcript messages: it restores context, forks,
compacts, and resumes a dangling user turn. It has no atomic commit boundary, no immutable entry log, no document
state, no task runtime, and no storage contract shared across backends. It is therefore not a port of upstream
`@earendil-works/pi-durable`, and nothing built on top of it can honestly claim durable behavior.

Upstream pi-durable is a durable, extensible agent harness. Its normative spec
(`packages/durable/docs/spec.md`, 7,303 lines) opens with the rule that governs everything else:

> A Session atomically commits immutable entries, full task records, and Chord-tracked documents. Only committed state
> is observable.

This feature ports that foundation to Dart as the first vertical slice of pi#8. It delivers the substrate only: the
prerequisite schema and telemetry behavior; Chord's document, transaction, watch, and ID primitives; the Session's
immutable entries, typed documents, conversations, atomic commits, durability receipts, and failure semantics; the task
runtime's definitions, checkpoints, scheduling, sleep, wait, ownership, child graphs, and abort cascades; and the
storage backends (memory, JSONL, SQLite) under one storage conformance contract with crash-and-reopen evidence.

It deliberately stops there. Generation, tools, submissions, signals, product missions, hooks, extensions, compaction,
and code mode belong to pi#12, the second durable slice. A foundation that reaches into them would have to invent
their contracts before the upstream source that defines them is ported, which is exactly the speculative API this
port forbids.

## User Scenarios & Testing

### User Story 1 - Atomic, Crash-Safe Transcript Persistence (Priority: P1)

A host application stores an agent transcript in the Dart port. Every entry it appends is immutable and is committed
atomically with the rest of that commit's writes. When the process dies — between a model response and its
persistence, mid-commit, or after the commit is durable but before it is published — the host reopens the same storage
and finds that either the whole commit is present or none of it is. No entry is ever half-written, no ID is ever
reused, and a committed entry never changes.

**Why this priority**: This is the definition of "durable". Every later slice — generation, tools, submissions — writes
through this boundary, so a foundation whose commits are not atomic and crash-safe would make every claim above it
false. It is also the behavior the current Dart `Conversation` most clearly lacks.

**Independent Test**: Append entries and documents through a session; reopen the same storage in a fresh session and
read the transcript and documents back; repeat while killing the process at each commit boundary (before admission,
mid-write, after durable, before publish) and assert the reopened state is always a complete prefix of the log.

**Acceptance Scenarios**:

1. **Given** a session with committed entries, **When** the storage is closed and reopened, **Then** every committed
   entry, document, task record, and conversation is read back byte-for-byte equal, and no partial entry appears.
2. **Given** a commit in flight, **When** the process dies before the commit is durable, **Then** the reopened session
   shows none of that commit's writes.
3. **Given** a commit that was durable but not yet published, **When** the process dies before publication, **Then**
   the reopened session publishes it, and no observer ever saw a partial version of it.
4. **Given** a committed entry, **When** any later read occurs, **Then** the entry's id, conversationId, kind, model,
   data, head, edits, and byTaskId are unchanged (immutability).
5. **Given** two sessions sharing one storage, **When** both mint IDs, **Then** every ID is globally unique across
   reopen and strictly greater than every ID minted or stored before it.

---

### User Story 2 - Typed Documents with Defined Lifetimes and Checkpoints (Priority: P1)

A host keeps mutable JSON state — a settings object, a live run view, per-conversation notes — beside the transcript.
Each piece of state is declared once as a typed definition with an explicit scope: session, conversation, or task.
Conversation documents may be "latest-only" (fork keeps the current value) or "rewindable" (history stays addressable
for as-of reads). Each definition decides when a change is stored as a complete base rather than a delta, and how an
older stored version migrates forward. Reads and writes go through the document's definition, so a state written under
one version is never silently misinterpreted under another.

**Why this priority**: Tasks, conversations, and the harness all keep their state in documents. The lifetime rules
(session/conversation/task), the base-versus-delta policy, and migration are what make stored state survive reopen,
fork, and version change. Without them there is no typed durable state to build tasks on.

**Independent Test**: Define one document of each scope; write, mutate, checkpoint, and migrate it; assert the stored
representation switches between base and delta exactly where the definition's predicate says; reopen and assert the
materialized value and its history policy are preserved; fork a conversation and assert latest vs. rewindable behavior
differs as declared.

**Acceptance Scenarios**:

1. **Given** a definition whose checkpoint predicate selects a base, **When** the change is committed, **Then** the
   stored content is a complete base, not a delta, and no further Storage read was needed to decide that.
2. **Given** a rewindable conversation document with committed deltas, **When** the document is read as-of an earlier
   entry, **Then** the value reflects the deltas replayed after the selected base up to that entry.
3. **Given** a document stored by version *n*, **When** it is read after the definition is bumped to version *n+1*,
   **Then** the definition's migrate step runs and produces the new shape without reinterpreting lifetime semantics.
4. **Given** a document watch, **When** the document is retired, **Then** the watch's next call carries `retired: true`
   with the last value and no operations, and a later creation at the same address arrives as a root replacement.
5. **Given** a task document, **When** its task becomes terminal, **Then** the document retires and the watch ends
   with `ended` after that retirement call is delivered.

---

### User Story 3 - Durable Task Runtime: Checkpoints, Waiting, Sleeping, Ownership (Priority: P1)

A host defines a task: a durable state machine with a named kind, a versioned input, an initial checkpoint, and an
exhaustive map of phase handlers. The task runs phases, commits its progress, and can park — waiting on other tasks or
sleeping until a clock deadline — without holding a live invocation. When the process restarts, each task resumes at
its last committed checkpoint. A task always names an owner: its conversation, or another task. Owned tasks form a
tree; owned work cannot outlive its owner.

**Why this priority**: Tasks are how all durable work is expressed upstream — generation, tool calls, compaction,
subagents are all tasks. The runtime's checkpoint/resume, wait, sleep, and ownership semantics are the foundation pi#12
builds on, and they are the part the current Dart port does not have at all.

**Independent Test**: Define a two-phase task that commits a checkpoint, parks on a sibling task, then resumes and
completes; restart the session between phases and assert it resumes at the checkpoint with the same wake reason; define
a task that sleeps past a deadline and assert it resumes at the checkpoint when the virtual clock reaches it.

**Acceptance Scenarios**:

1. **Given** a task that committed `{status: "running", checkpoint}`, **When** the session is closed and reopened,
   **Then** the task resumes at that checkpoint with its `wake` preserved, exactly as if it had not been interrupted.
2. **Given** a task parked `{status: "waiting", on: [a, b], policy: "allSettled"}`, **When** both *a* and *b* become
   terminal, **Then** the task resumes with `wake.reason === "tasks"` naming the terminal tasks.
3. **Given** a task parked `{status: "sleeping", until: T}`, **When** the virtual clock reaches *T*, **Then** the task
   resumes at its checkpoint with `wake.reason === "time"`.
4. **Given** a task that returned a terminal outcome while it still owns live work, **When** the commit is stored,
   **Then** the record is `completing`, not `terminal`, and becomes `terminal` only in a later commit once that owned
   work drained.
5. **Given** a task parked in a wait, **When** the wait would close a cycle in the wait-for graph, **Then** the commit
   is refused and names the cycle.

---

### User Story 4 - Structured Concurrency and Abort Cascades (Priority: P1)

A host cancels work: aborting a conversation marks its live non-background tasks and withdraws their queued inputs;
aborting a task marks it and, through ownership, everything it owns. Abort flows down the ownership tree; it never
crosses a background boundary unless explicitly asked to. An abort handler runs only after the task's owned work has
drained, so it observes final child outcomes. New work cannot be created under an owner that is completing, terminal,
or already abort-marked.

**Why this priority**: Cancellation that half-works is worse than none: a cascade that stops midway leaves orphaned
work holding storage and running after its owner finished. The abort protocol is what makes the durable runtime
safe to compose into a host application.

**Independent Test**: Build a parent task that owns a child; mark the parent aborted; assert the child receives its
abort mark, its abort handler runs after the child's own owned work drained, and the parent resumes only after the
child is terminal; assert `createTask` under an abort-marked owner is rejected.

**Acceptance Scenarios**:

1. **Given** a live parent task with one live child, **When** the parent is aborted, **Then** the child receives an
   abort mark and its abort handler runs before the parent's, observing the child's final outcome.
2. **Given** a task that owns a background task, **When** the owner is aborted, **Then** the background task is not
   marked and does not block the owner's finish, but is still stopped by a plain session close.
3. **Given** an owner that is completing, terminal, or abort-marked, **When** new owned work is created under it,
   **Then** the creation is refused.
4. **Given** a conversation with queued inputs, **When** the conversation is aborted, **Then** those inputs are
   withdrawn and the conversation becomes ordinarily idle once its non-background work drains.
5. **Given** a session that is closed, **When** every invocation is stopped, **Then** running work resumes on reopen
   from its last committed checkpoint rather than being lost or written as aborted.

---

### User Story 5 - One Storage Contract, Three Backends, Conformance Evidence (Priority: P1)

A host chooses a storage backend — in-memory, JSONL file, or SQLite — and gets the same semantics from all three.
Each backend is validated by one shared conformance contract that exercises atomic commit, global ID ownership,
immutable conversation/entry creation, document record consistency, detached values, ordered cursor scans, and
refusal behavior. A backend that skips any of it is not a conforming backend, regardless of its own tests.

**Why this priority**: Upstream's own rule is that `MemoryStorage`, JSONL, and SQLite adapters run the same pi storage
conformance suite (architecture plan §5.3). Without that shared contract, "Dart has a SQLite backend" would be a
claim no evidence supports, and platform adapters could drift silently.

**Independent Test**: Run the identical conformance suite against all three Dart backends; assert each passes; then
break one backend deliberately (e.g. return a shared mutable list from a read) and assert the suite fails and names
the backend.

**Acceptance Scenarios**:

1. **Given** the storage conformance suite, **When** it runs against each of the memory, JSONL, and SQLite backends,
   **Then** every backend passes every case with no per-backend exception.
2. **Given** a write value with nested mutable containers, **When** it is committed and read back, **Then** the read
   value is detached: mutating it does not change what storage holds.
3. **Given** a commit whose batch is refused by the backend's own checks, **When** the commit call settles, **Then**
   the batches before it are durable, it is refused with a reason, and the batches after it are not stored.
4. **Given** a read with a cursor from a different scan order, **When** it is issued, **Then** it fails as an invalid
   request with no durable effect and does not fail the session.
5. **Given** a storage method that throws, **When** the failure propagates, **Then** the session fails, every later
   call rejects with the session-failed cause, and reopening recovers from the last consistent commit.

---

### User Story 6 - Foundation-Only Parity, Provably Scoped (Priority: P2)

A maintainer wants to know that this slice ported the foundation and nothing more: no Zuraffa entities, no browser
concepts, no MCP policy, no renamed runtime model, no convenience API invented ahead of the upstream source that
defines it. The slice updates only its own coverage-manifest rows, and it does not advance the verified upstream SHA or
claim parity for the port as a whole.

**Why this priority**: The port's value is that it is a faithful, provable port. A foundation slice that quietly
invents API or imports a product package would make every parity claim built above it unverifiable. This is a
guardrail, so it follows the mechanisms it protects.

**Independent Test**: Scan the new Dart source for imports of `zuraffa`, `zuraffa_agent`, browser packages, or
product-domain code, and for any type or function not grounded in a named upstream source file; assert none exist;
inspect the coverage rows this slice touched and assert no row outside the foundation set changed and the verified
SHA is unchanged.

**Acceptance Scenarios**:

1. **Given** the new Dart library code, **When** the purity scan runs, **Then** zero imports of `zuraffa`,
   `zuraffa_agent`, browser packages, or product-domain code are found.
2. **Given** the coverage manifest, **When** this slice is recorded, **Then** only foundation rows (schema,
   telemetry, chord, durable storage/session/task foundation) changed, and `verified_upstream_sha` is unchanged.
3. **Given** a foundation behavior with no upstream source, specification, test, or example behind it, **When** the
   row is reviewed, **Then** it is absent rather than marked verified.
4. **Given** generation, tools, submissions, signals, and product missions, **When** their coverage rows are
   inspected, **Then** they remain unported and point at pi#12, not this slice.

---

### Edge Cases

- **Crash mid-commit, after the storage call was admitted but before it returned.** The commit may or may not have
  become durable; reopening must produce a consistent state either way, and a host resubmitting must reuse its
  request identity so no work is duplicated.
- **Crash after a commit is durable but before publication.** Reopen publishes it; no observer saw a partial version.
- **Crash during a deferred commit.** What memory held ahead of storage is lost; the stored prefix is intact.
- **A document read as-of an entry that predates its creation, or after its retirement.** The read returns the
  defined absence, not an error and not a fabricated value.
- **A task definition version bump while tasks are mid-flight.** Each task migrates at reservation; a task written by
  an older version is converted, not misread.
- **A wait that names a task already terminal, a task not owned by the waiter, or a missing task.** The join policy
  decides; `allSettled` and `any` accept unowned tasks, and a missing task refuses the commit.
- **A timer host that declines background timers.** Memory is reclaimed at later commits instead; no correctness is
  lost, only promptness.
- **A cursor from another scan order, a malformed cursor, or an unknown conversation in an exact lookup.** These fail
  only the call as an invalid request, with no durable effect.
- **An abort mark arriving while a task is running vs. parked.** A running invocation is signalled and joined; a parked
  task's abort handler runs once its owned work drains, without waiting out its sleep or signal.
- **A definition that never checkpoints.** Replay grows unbounded; that is a definition bug, not a backend heuristic,
  and is documented rather than papered over.

## Requirements

### Functional Requirements

#### Prerequisite Schema and Telemetry

- **FR-001**: The port MUST provide the JSON value type, JSON Schema builders, validation/coercion, and the schema
  formats and errors that upstream `packages/schema` exposes and that durable documents and tool arguments depend on.
- **FR-002**: The port MUST provide the telemetry context, propagation carrier, typed span/event/metric definitions,
  no-op behavior, and the attribute typing that upstream `packages/telemetry` exposes and that the durable harness
  reports through.
- **FR-003**: The prerequisite ports MUST NOT add fields, behaviors, or convenience beyond what the upstream source at
  the declared SHA defines.

#### Chord Foundations

- **FR-004**: The port MUST provide the Chord context (cancellation and telemetry carrier) and the JSON value
  utilities (strict JSON checks, deep copy) that durable and Chord documents are built on.
- **FR-005**: The port MUST provide the Chord delta model: the operation vocabulary (set, delete, append, truncate,
  insert, move, root-replace), immutable application of operations, and the draft/pending machinery that prepares a
  change for storage.
- **FR-006**: The port MUST provide Chord document definitions and handles: singleton and keyed documents, their
  transactions, retirement, and the line that runs one transaction at a time.
- **FR-007**: The port MUST provide Chord watches: a handle whose acquisition atomically captures the current value and
  registers for later commits, a serialized listener, and a terminal result tagged by kind.
- **FR-008**: The port MUST provide Chord IDs: branded numeric identifiers that are globally unique within a session's
  namespace and never reused.

#### Entries, Documents, and Conversations

- **FR-009**: The port MUST define immutable entries with the upstream `EntryRecord` contract: `id`, `conversationId`,
  `kind`, optional `model`, `data`, `head`, `edits`, and `byTaskId`; a committed entry MUST NOT change.
- **FR-010**: The port MUST define the built-in entry kinds upstream ships: user, assistant, system, tool-result,
  reset, and compaction, each with its declared payload shape and guard.
- **FR-011**: The port MUST define typed document definitions with scope (session, conversation, task), version,
  initial value, optional migrate, and a required checkpoint predicate, plus keyed document families.
- **FR-012**: The port MUST enforce the lifetime rules: session documents survive close and reopen; conversation
  documents are latest-only or rewindable and follow the declared fork policy; task documents retire with their task.
- **FR-013**: The port MUST enforce the base/delta rule: creation stores a base; a later change stores a base exactly
  when the definition's predicate selects one; otherwise it stores a delta; and rewindable bases bound replay without
  permitting history removal.
- **FR-014**: The port MUST provide conversations: a transcript scope with identity, an optional fork parent, and an
  optional owner, whose entries are appended through the commit boundary.

#### Atomic Commits, Receipts, and Failures

- **FR-015**: The port MUST provide one mutation line that runs one commit callback at a time and commits atomically
  across all of that commit's entry, document, conversation, task, and submission writes.
- **FR-016**: The port MUST provide a storage durability receipt: a commit becomes observable only once storage has
  made it durable, and the receipt is delivered once per durable batch, in order.
- **FR-017**: The port MUST publish a stored commit only after the storage call that stored it settled, in line order,
  and MUST NOT publish a commit that failed before becoming durable.
- **FR-018**: The port MUST implement the table access rules: table reads are allowed before the first table write, any
  table read after the first table write fails with the upstream read-after-write error, and document access remains
  available after table writes.
- **FR-019**: The port MUST implement detached-value ownership: anything retained after a storage call settles is
  detached first, every read returns a detached JSON value, and mutable arrays and objects are never shared.
- **FR-020**: The port MUST implement the failure taxonomy: a storage error fails the session and every later call
  rejects with the session-failed cause; an invalid-read error and a read rejected by an aborted context fail only
  their own call; a commit callback's own error affects only its commit.
- **FR-021**: The port MUST implement close semantics: close seals mutation admission, runs close listeners, lets
  admitted work settle, publishes held changes, and then closes storage; a session that failed closes itself and
  settles its closed state as failed.

#### Durable Tasks

- **FR-022**: The port MUST provide task definitions with name, version, an initial checkpoint, an exhaustive phase
  handler map, an abort handler, an optional migrate step, and optional hooks.
- **FR-023**: The port MUST provide task records whose state is one of pending, running, waiting, sleeping,
  completing, or terminal, each carrying its checkpoint and, while parked, its wake reason.
- **FR-024**: The port MUST implement checkpoints: a task that crashes or closes resumes at its last committed
  checkpoint, with its wake reason preserved.
- **FR-025**: The port MUST implement waits: a task parks until the tasks it names are terminal (per its join policy)
  and resumes with a `tasks` wake; a wait that would close a cycle in the wait-for graph is refused.
- **FR-026**: The port MUST implement sleeps: a task parks until the clock reaches its deadline or one of its signals
  holds an unused value, whichever comes first, and resumes with a `time`, `expired`, or `signal` wake.
- **FR-027**: The port MUST implement ownership: every task names its owner at creation (its conversation or another
  task); owner edges are immutable; owned work cannot outlive its owner.
- **FR-028**: The port MUST implement child graphs: a task's ordinary owned work is the tree of tasks it owns, the
  tasks in the conversations it owns, transitively, excluding background subtrees; a task becomes terminal only once
  that work drained, holding a `completing` outcome until then.
- **FR-029**: The port MUST implement abort cascades: an abort mark flows down the ownership tree to foreground work,
  stops at background boundaries unless explicitly crossed, is applied idempotently, and drives each abort handler only
  after its owned work drained.
- **FR-030**: The port MUST implement the scheduler: it serially reserves eligible tasks, runs handlers off the
  mutation line, and re-evaluates a decision on the candidate commit records so work created by a finishing commit
  still holds its owner.
- **FR-031**: The port MUST implement timers through an injectable host seam: foreground timers pace or resume work,
  background timers free memory, a host may decline a background timer, and every caller re-checks its clock when a
  timer fires.
- **FR-032**: The port MUST implement wakeups: the session reports whether it has work that can run now or a clock
  deadline at which it must run, and a host can arm or decline the wakeup.

#### Storage Backends and Conformance

- **FR-033**: The port MUST provide a storage interface with atomic commit, global ID minting, keyed conversation/entry
  /task/submission lookups, ordered cursor scans, document lookup at a point, and close, matching the upstream
  `Storage` contract.
- **FR-034**: The port MUST provide a memory backend that implements the reference semantics and copies retained write
  values and all read results.
- **FR-035**: The port MUST provide a JSONL backend that persists through a file-system capability and detaches its
  decoded indexes, materialized values, and caches from commit arguments and reads.
- **FR-036**: The port MUST provide a SQLite backend that executes each storage call as one transaction, checks each
  batch before writing it, writes accepted batches in batched statements, and applies pending schema migrations on
  open.
- **FR-037**: The port MUST provide one shared storage conformance suite and run it unchanged against all three
  backends, covering atomic commit, global IDs, immutable creation, document consistency, detached values, ordered
  scans, and refusal.
- **FR-038**: The port MUST provide crash-and-reopen evidence: tests that kill the session at every commit boundary
  and assert that a partial commit is never published and that running work resumes from its last committed
  checkpoint.

#### Scope Discipline and Coverage

- **FR-039**: The port MUST NOT import `zuraffa`, `zuraffa_agent`, a browser package, or product-domain code, and the
  check MUST fail on any such import.
- **FR-040**: The port MUST NOT introduce a runtime model, type, or function that renames or reinterprets an upstream
  concept, and MUST NOT invent convenience API ahead of the upstream source that defines it.
- **FR-041**: This slice MUST add coverage-manifest rows for the foundation areas only, each naming the exact verified
  upstream SHA and every remaining durable-runtime gap, and MUST NOT advance `verified_upstream_sha` or imply global
  parity.
- **FR-042**: This slice MUST leave generation, tools, submissions, signals, and product missions unported and
  explicitly deferred to pi#12 in the coverage manifest.

### Key Entities

- **Session**: The owner of one mutation line, its conversations, entries, tasks, submissions, and documents; the unit
  that commits atomically and fails as a whole.
- **Conversation**: A transcript scope with an identity, an optional fork parent, and an optional owner.
- **Entry**: An immutable transcript record (id, conversationId, kind, optional model/data/head/edits/byTaskId).
- **Document**: Mutable JSON state with a scope, a version, an initial value, an optional migrate step, and a
  checkpoint predicate; stored as a base or a delta.
- **Document Definition**: The typed token (singleton or family) that describes one document's shape and lifetime.
- **Delta**: One Chord operation batch that transforms a document from one value to the next.
- **Task**: A durable state machine with a kind, a versioned input, a checkpoint, phases, and an owner.
- **Task Record**: The persisted state of one task: pending, running, waiting, sleeping, completing, or terminal.
- **Checkpoint**: The durable state a task resumes from after a crash, close, or wait.
- **Wake Reason**: Why a parked task resumed: time, expired, signal, or tasks.
- **Ownership Edge**: The immutable link from a task to its owner (its conversation or another task).
- **Storage**: The atomic persistence boundary: commit with receipts, mint, keyed lookups, ordered scans, document
  reads, and close.
- **Commit Receipt**: The per-batch durability signal that precedes publication.
- **Conformance Suite**: The shared set of storage cases every backend must pass unchanged.
- **Coverage Row**: One foundation behavior's ledger record, pinned to the verified upstream SHA, with its Dart
  implementation, tests, status, and any remaining gap.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A transcript of 1,000 entries committed through the Dart port reopens with all 1,000 entries
  byte-for-byte equal and zero partial or mutated entries, across memory, JSONL, and SQLite backends.
- **SC-002**: Killing the process at every commit boundary in a scripted crash suite leaves the reopened state always
  a complete prefix of the commit log; zero runs publish a partial commit.
- **SC-003**: The same storage conformance suite passes unmodified against all three Dart backends; a deliberately
  broken backend fails the suite and is named.
- **SC-004**: A task killed after any checkpoint resumes at that checkpoint with its wake reason preserved; across the
  crash suite, zero tasks lose committed progress and zero resume from a checkpoint they never committed.
- **SC-005**: An abort of a parent task reaches every foreground descendant in the crash suite, every abort handler
  observes final child outcomes, and zero work outlives its owner.
- **SC-006**: A scan of the new Dart library finds zero imports of `zuraffa`, `zuraffa_agent`, browser packages, or
  product-domain code, and zero renamed or invented runtime types.
- **SC-007**: Only foundation coverage rows change; `verified_upstream_sha` is unchanged; generation, tools,
  submissions, signals, and product missions remain unported and point at pi#12.
- **SC-008**: Every new foundation behavior is grounded in a named upstream source file, specification section, test,
  or example at the declared SHA; zero rows are grounded in nothing.

## Assumptions

- **Depends on**: arrrrny/pi#10, arrrrny/pi#3, arrrrny/pi#4, arrrrny/pi#5, arrrrny/pi#6 — preserved verbatim. pi#10
  provides the coverage-manifest and SHA-governance schema this slice's rows are recorded in; pi#3–#6 are the
  baseline correctness fixes this foundation must not regress. Where pi#10's tooling is not yet built, this slice
  records its rows in the registry shape pi#10's spec defines and states that dependency explicitly rather than
  inventing a second manifest format.
- **Target SHA**: `780bf31fcaeb252fa9b68df3964c735eae75bde3`, the upstream commit every foundation package
  (`schema`, `telemetry`, `chord`, `durable`, `env`) is read at. Those five package trees are byte-identical between
  that commit and this checkout's `HEAD`, so the port reads the target SHA's content.
- **Normative reference wins**: the architecture plan linked in the header is normative; where this spec and that plan
  disagree, the plan wins and this spec is corrected.
- **Strict port only**: every Dart type, function, and error in this slice is grounded in a named upstream source file,
  specification section, test, or example at the target SHA. No Zuraffa entities, no browser concepts, no MCP policy,
  no renamed runtime model, no speculative convenience API. `zfa` is not applicable: this package is a hand-written
  port, not a Zuraffa application.
- **Scope boundary**: generation, tools, submissions, signals, and product missions are pi#12, not this slice. The
  foundation provides the task runtime that generation and tools are written as, but does not port generation or tool
  execution itself. The Dart `Agent`/`Conversation`/`AgentLoop` wrappers are out of scope here; this slice ports the
  durable foundation as new library surface and does not rewire the existing wrappers onto it.
- **One package, new entry library**: the foundation lives under `pi_agent/lib/src/durable/` and is exported through a
  new `package:pi/durable.dart` entry library, mirroring upstream's package boundary without disturbing the existing
  `package:pi/pi.dart` surface.
- **Pure Dart**: the foundation adds no runtime dependency beyond `dart:async`, `dart:convert`, and `dart:typed_data`;
  the SQLite backend sits behind an injectable executor seam so the core stays platform-neutral and platform adapters
  supply the driver.
- **Storage adapters preserve upstream semantics**: memory, JSONL, and SQLite differ only in durability and encoding;
  all three satisfy the same conformance contract and none is treated as the reference the others must approximate.
- **Coverage rows never advance global parity**: this slice marks only its own rows and leaves
  `verified_upstream_sha` untouched; full parity is global at one SHA and is not implied by any slice.
- **Differential evidence is best-effort where practical**: where a behavior cannot be differentially tested against
  the TypeScript oracle, its row says so explicitly and is not `verified` on that basis.