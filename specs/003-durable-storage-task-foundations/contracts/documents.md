# Contract: Documents, Entries, and Watches

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md)
**Upstream**: `packages/durable/src/documents.ts`, `entries.ts`, `types.ts`; `packages/chord/src/documents/`,
`delta/`, `watch.ts`; spec §2, §3, §9

## Entry record

```dart
class EntryRecord {
  final EntryId id;
  final ConversationId conversationId;
  final String kind;
  final List<Object?>? model;   // the pi-ai Message list
  final Object? data;
  final EntryId? head;
  final List<ContextEdit>? edits;
  final TaskId? byTaskId;
}
```

Immutable once committed. A later read never changes any field.

## Typed entries

```dart
class Entry<D extends Object?> {
  final String kind;
  bool is(EntryRecord? entry); // narrows by kind
}

Entry<D> defineEntry<D extends Object?>(String kind);
```

Built-in kinds (spec §8.1, `entries.ts`):

| Dart constant | `kind` | `model` | `data` |
| --- | --- | --- | --- |
| `userEntry` | `pi.user` | `[UserMessage]` | absent |
| `assistantEntry` | `pi.assistant` | `[AssistantMessage]` | absent |
| `systemEntry` | `pi.system` | `[SystemMessage]` with empty content | absent |
| `toolResultEntry` | `pi.tool-result` | `[ToolResultMessage]` | `{diagnostics: ToolDiagnostic[]}` |
| `resetEntry` | `pi.reset` | absent, or `[UserMessage]` for a handoff | absent |
| `compactionEntry` | `pi.compaction` | `[UserMessage]` with the summary | `{reason: CompactionReason}` |

`defineEntry` throws a `TypeError` for an empty kind (upstream: "Entry kind must be a non-empty string").

## Context edit

```dart
sealed class ContextEdit {}
class ContextOmit extends ContextEdit { final EntryId target; }
class ContextReplace extends ContextEdit { final EntryId target; final List<Object?> messages; }
```

## Document semantics

```dart
sealed class DocumentSemantics {}
class SessionSemantics extends DocumentSemantics {}
class LatestConversationSemantics extends DocumentSemantics { final ForkPolicy fork; }   // "current" | "initial"
class RewindableConversationSemantics extends DocumentSemantics { final ForkPolicy fork; } // "asOf" | "current" | "initial"
class TaskSemantics extends DocumentSemantics {}
```

Only conversation documents declare `history` and `fork`; session and task documents are current-only.

## Definition

```dart
abstract class CommonDocDefinition<T extends JsonObject> {
  String get kind;
  int get version;
  T initial();
  T? migrate(JsonObject value, int fromVersion);
  bool checkpointWhen(T value, List<Op> ops, CheckpointInfo info); // required, no default
}

abstract class DocDefinition<T extends JsonObject> extends CommonDocDefinition<T> {
  DocumentSemantics get semantics;
}

abstract class DocFamilyDefinition<T extends JsonObject, I extends Object?> extends CommonDocDefinition<T> {
  bool get family;
  T initialFor(I seed);
}
```

Validation rules (spec §3.1):

- Versions are positive integers.
- Typed access rejects when the token's scope or conversation history/fork policy disagrees with the persisted
  incarnation.
- Session documents are current-only and belong to the session; close and reopen does not retire them.
- Task documents retire with their task and are never created again.

## Tokens

```dart
class DocToken<T extends JsonObject, D extends DocDefinition<T>> { final D definition; }
class DocFamilyToken<T extends JsonObject, I extends Object?, D extends DocFamilyDefinition<T, I>> {
  final D definition;
}

typedef SessionDocToken<T extends JsonObject> = DocToken<T, ...>;
typedef ConversationDocToken<T extends JsonObject> = DocToken<T, ...>;
typedef RewindableConversationDocToken<T extends JsonObject> = DocToken<T, ...>;
typedef TaskDocToken<T extends JsonObject> = DocToken<T, ...>;
```

Typed access is explicit: `tx.doc(token)` and `watchDoc(token, …)` take the token whose type determines the returned
`T`.

## Definition constructors

```dart
SessionDocToken<T> defineDoc<T extends JsonObject>(... session definition);
ConversationDocToken<T> defineDoc<T extends JsonObject>(... latest conversation definition);
RewindableConversationDocToken<T> defineDoc<T extends JsonObject>(... rewindable conversation definition);
TaskDocToken<T> defineDoc<T extends JsonObject>(... task definition);

// and the four defineDocFamily overloads, keyed by a seed of type I
```

Each validates the definition (version is a positive integer, kind non-empty, `checkpointWhen` present) and returns a
token carrying the definition.

## Bases and checkpoints (spec §3.5)

- Creation always stores a complete base.
- For an ordinary later mutation, the definition alone decides: `checkpointWhen(candidateValue, ops, {deltasSinceBase})`.
- The session evaluates the predicate exactly once after tracker preparation; `deltasSinceBase` counts the deltas
  already stored after the incarnation's newest base, excluding the change being evaluated.
- Required or predicate true → base with complete value; otherwise → delta with the prepared op batch.
- A Chord root-replacement operation remains a delta unless the definition selected a checkpoint.
- A committed base permits physical reclamation of older records for session, task, and latest conversation
  documents; for rewindable conversation documents, bases bound replay but never permit removal of addressable
  history.

## Versions and migrations (spec §3.6)

- A definition's `migrate(value, fromVersion)` converts a record stored by any older supported version; it runs at
  reservation for tasks and on load for documents.
- A migration cannot reinterpret lifetime semantics (scope, history, fork).

## Forks (spec §3.7)

- A conversation may fork another at an entry (`parent {conversationId, at}`).
- `latest` history: a fork keeps the current value.
- `rewindable` history: a fork may be `asOf` an entry, `current`, or `initial`.
- Scans follow fork ancestry newest-first through every ancestor cap.

## Watches (spec §9.1)

```dart
sealed class WatchEnd {}
class WatchStopped extends WatchEnd {}
class WatchAborted extends WatchEnd {}
class WatchEnded extends WatchEnd {}
class WatchListenerError extends WatchEnd { final Object error; }
class WatchFailed extends WatchEnd { final Object error; }

sealed class WatchCall<T> {}
class WatchValue<T> extends WatchCall<T> {
  final T value;
  final List<Op> ops;
  final bool retired;
}
class WatchFailedCall<T> extends WatchCall<T> { final Object error; }

abstract interface class WatchHandle<T> {
  T get value;
  void start(Future<void> Function(WatchCall<T> call, Context context) listener);
  Future<WatchEnd> stop();
  Future<WatchEnd> get closed;
}
```

### Watch semantics

- Acquisition captures the value and registers for later commits atomically, on the session line: the acquisition
  value includes every commit before acquisition, and every later commit is buffered until `start()`.
- A watch ends once, with the first end that applies: `stopped` by `stop()`, `aborted` when its acquisition context is
  aborted, `ended` when the owner of what it watches ends, `listener_error` when its listener threw, `failed` when the
  session failed.
- Durable's failures are final, so a durable watch only gets `value` calls.
- A retirement does not end a watch: the next call has `retired` set, with the last value and no ops.
- A commit that changes a document and retires it publishes the retirement only.
- A document created at the address later arrives as a root replacement `[["r", value]]` of the new incarnation.
- Task documents retire when their task becomes terminal and are never created again; a task document's watch gets the
  retirement as its last call and then ends `ended`.
- Session close ends every watch at its seal; a watch keeps its last value and receives no frame from a commit that
  settles during close.
- Termination drops every reference the watch holds into its source; a stopped watch that is still referenced keeps only
  its last value alive.
- Reopen creates a new watch lifetime.

## Document observation (spec §9.1)

```dart
abstract interface class DocumentObserver {
  Future<DocumentWatch<T>?> watchDoc<T extends JsonObject>(SessionDocToken<T> token, Context context);
  Future<DocumentWatch<T>?> watchDoc<T extends JsonObject>(ConversationDocToken<T> token, ConversationId id, Context context);
  Future<DocumentWatch<T>?> watchDoc<T extends JsonObject>(TaskDocToken<T> token, TaskId id, Context context);
  Future<DocumentWatch<T>?> watchDoc<T extends JsonObject, I extends Object?>(
      SessionDocFamilyToken<T, I> token, String key, Context context);
  Future<DocumentWatch<T>?> watchDoc<T extends JsonObject, I extends Object?>(
      ConversationDocFamilyToken<T, I> token, ConversationId id, String key, Context context);
  Future<DocumentWatch<T>?> watchDoc<T extends JsonObject, I extends Object?>(
      TaskDocFamilyToken<T, I> token, TaskId id, String key, Context context);
}
```

Absence returns `undefined` (Dart `null`); acquisition never creates.

## Delta operations (Chord, `delta/index.ts`)

```dart
sealed class Op {}
class OpReplace extends Op { final Object? value; }                       // ["r", value]
class OpSet extends Op { final List<Object?> path; final Object? value; } // ["s", path, value]
class OpDelete extends Op { final List<Object?> path; }                   // ["d", path]
class OpAppend extends Op { final List<Object?> path; final String value; } // ["a", path, string]
class OpTruncate extends Op { final List<Object?> path; final int length; } // ["t", path, number]
class OpInsert extends Op {                                                // ["p", path, start, deleteCount, items]
  final List<Object?> path; final int start; final int deleteCount; final List<Object?> items;
}
class OpMove extends Op { final List<Object?> path; final List<int> permutation; } // ["m", path, permutation]
```

`applyImmutable(target, ops)` returns a new value; the input is not mutated. The wire encoding
(`WireOp`) compresses repeated paths with `["#", id, path]` definitions and numeric path references, exactly as
upstream.

## Conversation record

```dart
class ConversationRecord {
  final ConversationId id;
  final ({ConversationId conversationId, EntryId at})? parent;
  final ({ConversationId conversationId, TaskId taskId})? owner;
}
```

`ROOT_CONVERSATION_ID = 1`; a second root creation is refused.