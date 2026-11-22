# Phase 1 Data Model: Durable Storage and Task Foundations

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)
**Oracle**: `earendil-works/pi` at `780bf31fcaeb252fa9b68df3964c735eae75bde3`

Every Dart type below names the upstream file and symbol it ports. A type with no upstream source cannot be marked
`verified`. Shapes are given as the Dart declaration plus the upstream declaration it mirrors.

## Layer 1 — Prerequisites

### Schema (`packages/schema/src/`)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| `JsonValue` | `packages/chord/src/json.ts` (`JsonValue`) | `null`, `bool`, `int`/`double` (finite), `String`, `List<JsonValue>`, `Map<String, JsonValue>`; no `undefined`, no non-finite numbers. |
| `copyJson(Object?)` | `json.ts` (`copyJson`) | Deep copy; used at trust boundaries. |
| `isJsonValue(Object?)` | `json.ts` (`isJsonValue`) | Strict JSON predicate. |
| `Schema` builders, `compile`, `Validator`, `CoercingValidator` | `packages/schema/src/builders.ts`, `validator.ts`, `coerce.ts`, `types.ts` | JSON Schema build, validate, coerce, and the `ValidationError`/`ParseResult` shapes (`index.ts` exports). |
| Formats | `packages/schema/src/formats/` | The format checks `packages/schema` exposes. |

**Rationale**: Durable documents and tool arguments are validated against JSON Schema upstream
(`packages/ai/src/utils/validation.ts` is the consumer), so the schema layer is a hard prerequisite. The Dart port
keeps the same surface; no new format or keyword is added.

### Telemetry (`packages/telemetry/src/`)

| Dart | Upstream source | Contract |
| --- | --- | --- |
| `TelemetryContext`, `TelemetrySpan`, `TelemetryCarrier` | `index.ts`, `memory.ts`, `noop.ts` | Context carries a current span; `TelemetryCarrier` is `Map<String, String>` for propagation. |
| `SpanOptions`, `SpanStatus`, `StoredSpan`, `StoredTrace` | `index.ts` | Span shape and status union (`ok`/`error`). |
| `TelemetryStore`, `TraceQuery`, `MetricQuery`, `StoredMetric` | `index.ts` | Read/query side of telemetry. |
| `createTypedMetrics`, `defineTelemetrySchema` | `metrics.ts`, `index.ts` | Typed metric/span definitions. |
| `NOOP_TELEMETRY_CONTEXT`, `NOOP_TELEMETRY_METRICS`, `NOOP_TELEMETRY_PROPAGATION` | `noop.ts` | The no-op implementations. |

**Rationale**: The durable harness reports through `TelemetryContext` (spec §4, the publication sequence emits
`pi.durable.*` events) and accepts an optional host context. The port must provide the no-op path so the foundation
works with no telemetry host configured.

## Layer 2 — Chord primitives (`packages/chord/src/`)

### Context (`context/`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `Context` | `context/index.ts` | Carries cancellation (an abort reason) and a `TelemetryCarrier`. |
| `BACKGROUND_CONTEXT` | `context/index.ts` | A context that never cancels and uses the no-op span. |
| `withAbortSignal`, `withoutAbortSignal`, `awaitWithContext`, `withTelemetry` | `context/index.ts` | Context combinators. |

### JSON (`json.ts`) — see Layer 1.

### Delta (`delta/`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `Op` (sealed) | `delta/index.ts` (`Op`) | `["r", value]`, `["s", path, value]`, `["d", path]`, `["a", path, string]`, `["t", path, number]`, `["p", path, start, deleteCount, items]`, `["m", path, permutation]`. |
| `applyImmutable(target, ops)` | `delta/index.ts` | Apply ops to a value, returning a new value; the input is not mutated. |
| `applyImmutableBatches(target, batches)` | `delta/index.ts` | Fold a sequence of op batches. |
| `applyImmutableTrusted(target, ops)` | `delta/apply-immutable-trusted.ts` | Trusted fast path with the same result. |
| `Draft<T>`, `Pending` | `delta/draft.ts`, `delta/pending.ts` | A document's mutable draft during a transaction; pending ops. |
| `RevisionValidator` | `delta/revision-validator.ts` | Validates a revision's ops. |

**Rationale**: Documents are "mutable JSON state represented by Chord operations and occasional complete bases"
(spec §1). The op vocabulary and its immutable application are the primitive the document layer and both delta
backends (memory, SQLite) are built on.

### Documents (`documents/`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `SingletonHandle<T>`, `KeyedHandle<T, Key>` | `documents/handles.ts` | `change`/`retire` for singletons; `get`/`keys`/`watch` for keyed. |
| `Documents`, `DocumentsOwner` | `documents/documents.ts` | An object's documents, line, seal fence, and residency. |
| `Transaction`, `Tx` | `documents/transaction.ts` | One transaction's drafts, retires, and job starts; the line runs one at a time. |
| `Line` | `documents/line.ts` | Serializes transactions on the object's line. |
| `KeyedSlot`, `SingletonSlot` | `documents/keyed-slot.ts`, `slot.ts` | Slot machinery. |
| `SealToken` | `documents/fence.ts` | Fences a transaction to its seal. |
| `Persistence` | `documents/persistence.ts` | Load/check/adopt of stored documents. |
| `Residency` | `documents/residency.ts` | Which keyed documents are resident in memory. |

**Rationale**: Durable's documents are Chord documents; the session keeps them as Chord trackers (spec §4). The port
needs the handles, the transaction, and the line, because the session's document access is expressed through them.

### Watch (`watch.ts`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `WatchEnd` (sealed) | `watch.ts` | `stopped`, `aborted`, `ended`, `listener_error`, `failed`. |
| `WatchCall<T>` (sealed) | `watch.ts` | `value` (value, ops, retired) or `failed`. |
| `WatchHandle<T>` | `watch.ts` | `value`, `start(listener)`, `stop()`, `closed`. |

**Rationale**: "Durable exposes committed state only through watches" (spec §9.1). The watch handle's acquisition
(atomic capture + registration) and terminal result are the primitive the session's `watchDoc` and the conversation
view use.

### IDs (`ids.ts`, and durable's `types.ts`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `Id<Kind>` (extension type over `int`) | `packages/durable/src/types.ts` (`Id`) | Branded numeric identifier. |
| `Seq` (extension type over `int`) | `types.ts` (`Seq`) | Strictly increasing commit sequence; gaps permitted. |
| `ConversationId`, `EntryId`, `TaskId<R>`, `SubmissionId`, `DocumentId` | `types.ts` | The five record kinds. |
| `ROOT_CONVERSATION_ID = 1` | `types.ts` | The root conversation always uses ID 1. |
| `idFromNumber`, `seqFromNumber` | `packages/durable/src/ids.ts` | Trusted-boundary brand application. |

**Rationale**: IDs are "immutable and never reused after a committed write" (spec §1 invariant 5) and "scans order by
ID as creation order" (spec §10 `mintId`). The brand makes a `ConversationId` unusable where an `EntryId` is
required, at compile time, exactly as upstream.

## Layer 3 — Records and documents (`packages/durable/src/`)

### Entries (`entries.ts`, `types.ts`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `Entry<D>` | `types.ts` (`Entry`) | A typed entry kind with a `kind` string and an `is()` guard. |
| `defineEntry<D>(kind)` | `entries.ts` | Define a typed entry kind; validates the kind is a non-empty string. |
| `EntryRecord` | `types.ts` | `id`, `conversationId`, `kind`, optional `model`, `data`, `head`, `edits`, `byTaskId`. |
| `EntryDraft` | `types.ts` | `EntryRecord` minus `id`/`conversationId`/`byTaskId`/`head`, with `head?: EntryId \| "self"`. |
| `TypedEntry<D>` | `types.ts` | `EntryRecord` with `data: D`. |
| `UserEntry`, `AssistantEntry`, `SystemEntry`, `ToolResultEntry`, `ResetEntry`, `CompactionEntry` | `entries.ts` | The six built-in kinds, each with its declared payload (`pi.user`, `pi.assistant`, `pi.system`, `pi.tool-result`, `pi.reset`, `pi.compaction`). |
| `ContextEdit` | `types.ts` | `{target, action: "omit"} \| {target, action: "replace", messages}`. |

**Rationale**: Entries are immutable (spec §2: `EntryRecord`) and the built-in kinds are the vocabulary every later
slice writes (spec §8.1). The port defines them exactly, with no new kind.

### Documents (`documents.ts`, `types.ts`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `DocumentSemantics` (sealed) | `types.ts` | `session`, `conversation` with `history: latest\|rewindable` and `fork`, or `task`. |
| `CommonDocDefinition<T>` | `types.ts` | `kind`, `version`, `initial()`, optional `migrate(value, fromVersion)`, required `checkpointWhen(value, ops, info)`. |
| `DocDefinition<T>`, `DocFamilyDefinition<T, I>` | `types.ts` | Singleton and keyed-family definitions. |
| `DocToken<T, D>`, `DocFamilyToken<T, I, D>` | `types.ts` | Typed tokens passed explicitly to typed access. |
| `defineDoc`, `defineDocFamily` | `documents.ts` | Define and validate a definition. |
| `CheckpointInfo` | `types.ts` | `{deltasSinceBase}` supplied to the predicate. |

**Rationale**: Scope determines ownership and lifetime (spec §3.1); the checkpoint predicate decides base vs. delta
(spec §3.5). These are the exact fields upstream persists, so a port that adds a field would change the stored
format.

### Conversations (`types.ts`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `ConversationRecord` | `types.ts` | `id`, optional `parent {conversationId, at}`, optional `owner {conversationId, taskId}`. |
| `ConversationOwnership` (sealed) | `types.ts` | `ownerless` or `task {taskId}`. |
| `ConversationInit`, `ConversationCreateOptions` | `types.ts` | Creation inputs. |

**Rationale**: A conversation is a transcript scope with an optional fork parent and an optional owner (spec §2). The
record is the persisted shape.

### Errors (`errors.ts`)

Port exactly as listed in research D7.

## Layer 4 — Session and storage (`packages/durable/src/session/`, `storage/`)

### Storage (`storage/store/storage.ts`, `types.ts`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `Storage` (abstract interface) | `types.ts` (`Storage`), `storage/store/storage.ts` | `commit`, optional `publishing`, `mintId`, `conversation`, `scanConversations`, `entry` (both overloads), `findLatestHeadMarker`, `scanEntries`, `task`, `scanTasks`, `submission`, `scanSubmissions`, `submissionByRequest`, `findDocument`, `document`, `scanDocuments`, `close`. |
| `CommitResult` (sealed) | `types.ts` | `stored {stored}` or `refused {stored, refused}`. |
| `StorageWrite` (sealed) | `types.ts` | `conversation`, `entry`, `task`, `submission`, `document.create`, `document.copy`, `document.change`, `document.retire`. |
| `DocumentContent` (sealed) | `types.ts` | `base {version, value}` or `delta {version, ops}`. |
| `StoredDocument` | `types.ts` | `record`, `version`, `value`, `deltasSinceBase`. |
| `DocumentAddress`, `DocumentPoint`, `DocumentQuery` | `types.ts` | `{kind, scope, key?}`, `Seq \| "current"`, `{scope, at, kind?}`. |
| `Page<T, C>`, `Cursor`, `ScanOrder` | `types.ts` | `{items, next?}`, opaque cursor, `ascending\|descending`. |
| `ConversationQuery`, `EntryQuery`, `TaskQuery`, `SubmissionQuery` | `types.ts` | The scan filters. |

**Rationale**: This is the spine (research D3). The port implements it once; the session, tasks, and all three
backends target it.

### Session (`session/session.ts`, `transaction.ts`, `writer.ts`, `keys.ts`, `cached-storage.ts`, `forks.ts`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `Session` | `session/session.ts` (`SessionImpl`) | One mutation line; `commit`, `close`, `closed`, `subscribeClose`, `observeCommits`, `watchDoc`, document access. |
| `Transaction`/`Tx` | `session/transaction.ts` | `conversation`, `doc`, `appendEntry`, `createTask`, `createConversation`, `admit`, `signal`; table access rules enforced. |
| `SessionWriter` | `session/writer.ts` | Group-commit writer: batches admitted commits into one `Storage.commit()` call. |
| `SessionKeys` | `session/keys.ts` | The key scheme the scheduler and line use. |
| `CachedStorage` | `session/cached-storage.ts` | The session's bounded document cache with retention. |
| `Forks` | `session/forks.ts` | Fork resolution. |

**Rationale**: The session is the "owner of one mutation line, conversations, entries, tasks, submissions, and
documents" (spec §1). The transaction enforces the table access rules (spec §4: "Any table read after the first
table write throws `ReadAfterWrite`"). The writer implements group commit (spec §4).

## Layer 5 — Tasks (`packages/durable/src/harness/`)

### Task definitions and records (`types.ts`, `harness/types.ts`, `tasks.ts`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `TaskDefinition<I, S, R>` | `types.ts` | `name`, `version`, `initial(input)`, `phases` map, `abort`, optional `migrate`, optional `hooks`. |
| `Task<I, S, R>`, `defineTask` | `types.ts`, `tasks.ts` | A typed executable task. |
| `TaskState<S, R>` (sealed) | `types.ts` | `pending {checkpoint, wake?}`, `running {checkpoint, wake?}`, `waiting {checkpoint, on, policy}`, `sleeping {checkpoint, until?, signals?}`, `completing {outcome}`, `terminal {outcome}`. |
| `TaskRecord<I, S, R>` | `types.ts` | `id`, `conversationId`, `kind`, `version`, `input`, optional `owner`, `background`, `abortRequested`, optional `abortReason`, optional `abandonOnRestart`, optional `startedAt`, `endedAt`, `restarts`, `state`, optional `memos`. |
| `TaskOutcome<R>` (sealed) | `types.ts` | `completed {result}`, `failed {error, result?}`, `aborted {reason?, result?}`, `orphaned {reason}`, `faulted {error}`. |
| `TaskOutcomeError` | `types.ts` | `{message, detail?}`. |
| `JoinPolicy` | `types.ts` | `failFast`, `allSettled`, `any`. |
| `WakeReason` (sealed) | `types.ts` | `time`, `expired`, `signal {signal, key}`, `tasks {ended}`. |
| `TaskOwnership` (sealed) | `types.ts` | `conversation` or `task {taskId}`. |
| `TaskOptions` | `types.ts` | `ownership` (required), optional `conversationId`, `background`, `abandonOnRestart`. |
| `NextTaskState<S, R>` | `types.ts` | A task's own committed state change. |

**Rationale**: These are the exact persisted task shapes (spec §5.1). The port does not add a field: a task written by
an older version is migrated, not reinterpreted.

### Scheduler, timers, abort (`harness/scheduler.ts`, `timers.ts`, `signals.ts`, `harness/task-graph.ts`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `Scheduler` | `harness/scheduler.ts` | Serially reserves eligible tasks; runs handlers off the line; re-evaluates decisions on candidate records; writes memberships. |
| `BlockedReason` | `harness/scheduler.ts` | Why a task is blocked. |
| `Timers`, `nativeTimer`, `SetTimer` | `timers.ts` | Timer seam; foreground vs. background; decline path. |
| `TaskGraph`, `TaskGraphNode`, `TaskGraphState`, `TaskGraphWatch` | `harness/task-graph.ts` | The ownership graph view. |

**Rationale**: The scheduler is "the unit of live work counted by idle and marked by abort" (spec §5.4). Abort
propagation and the `completing` hold are scheduler decisions, so they live with it.

## Layer 6 — Backends and conformance (`storage/`, `testing/`)

| Dart | Upstream | Contract |
| --- | --- | --- |
| `MemoryStorage` | `storage/memory.ts` | Reference semantics; copies retained writes and reads. |
| `JsonlStorage` | `storage/jsonl/storage.ts` | File-system capability; reclaimable sidecars; detached indexes. |
| `SqliteStorage` | `storage/sqlite/storage.ts`, `commit.ts`, `migrations.ts`, `statements.ts`, `rows.ts`, `schema.ts` | One transaction per call; batched statements; migrations on open. |
| `DurableSqliteExecutor` | `storage/sqlite/database.ts` | The injected executor seam (research D8). |
| `StorageConformance` | `src/testing/storage-conformance.ts` | The 34-case shared suite, registered per backend. |

**Rationale**: All three backends satisfy the same contract (spec §11). The conformance suite is the evidence
(SC-003); the SQLite schema follows `migrations.ts` (metadata, record IDs, conversations, entries, tasks,
submissions, documents, document revisions; schema version 2 rebuilds the task table to admit `sleeping`).

## Type Mapping Summary

| Upstream construct | Dart construct |
| --- | --- |
| `type X = A \| B` (union) | `sealed class X` with one subclass per case |
| `type Id<K>` (branded number) | `extension type Id<K extends String>(int)` |
| `interface X` | `abstract interface class X` |
| `type JsonValue` | `Object?` validated at the trust boundary |
| `readonly T[]` | `List<T>` (immutable by convention; copied at boundaries) |
| `Record<string, T>` | `Map<String, T>` |
| `Uint8Array` (where present) | `Uint8List` |
| Discriminated tuple `["r", value]` | `sealed class Op` subclass `OpR(value)` |

No Dart construct renames an upstream concept. No `any`/`dynamic` appears in typed positions.