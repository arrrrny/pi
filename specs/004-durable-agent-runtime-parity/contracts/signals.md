# Contract: Signals, Memos, and Approval Gates

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md)
**Upstream**: `packages/durable/src/signals.ts`, `harness/types.ts`, `harness/tool.ts`; spec §5.7, §7.2

## Signal vocabulary (spec §5.7)

```dart
class SignalDefinition<S extends Map<String, Object?>> {
  final String name;          // unique like a task/document kind; non-empty, without "/"
  final int version;          // positive integer
  final Schema<S> schema;
  final S Function(Object?, int fromVersion)? migrate;
}

SignalToken<S> defineSignal<S extends Map<String, Object?>>(SignalDefinition<S> definition);

abstract interface class SignalToken<T> {
  String get name;
  int get version;
  SignalKey<T> key(String key);   // throws on an empty key
}

class SignalKey<T> {
  final String signal;   // the token's name
  final String key;      // the wait's key
}

sealed class SignalState<T> {}

class SignalValue<T> extends SignalState<T> { final T value; }   // { kind: "value" }
class SignalExpired<T> extends SignalState<T> {}                 // { kind: "expired" }

typedef SignalResult = String;   // "delivered" | "duplicate" | "invalid" | "closed" | "not_found"

const SubmissionSettled = /* built-in token, named "pi.submission-settled" */;
```

`defineSignal()` throws for a name with `/`, a version that is not a positive integer, and a schema that admits
non-JSON values (`bigint()`, `bytes()`).

## Delivery (spec §5.7)

`tx.signal(taskId, token, key, value)` reads the task record and, in order, returns:

1. `not_found` for no task; `closed` for a terminal, `completing`, or abort-marked task;
2. `invalid` for an empty key, or a value that is not JSON or does not match the token's schema;
3. `duplicate` when the key holds a value, consumed or not; `closed` when it is expired;
4. `closed` when the task sleeps on this key and its `until` has passed; the key is marked expired in the same commit;
5. otherwise `delivered`: it stores the value with the token's version.

`Harness.signal()` runs it in a commit of its own. Neither checks who calls it. A value delivered before any wake used
it is kept; a later sleep on that key wakes at once.

## Storage and reading (spec §5.7)

- A key's state lives in the task's memos under `pi.signal.<signal name>/<key>`:
  `{version, value}` with `consumed: true` once a wake used it, or `{expired: true}`.
- `readSignal(token, key, context)` of `TaskRuntime`, `HookApi`, and `ToolExecutionApi` returns the key's committed
  state in the asking task, or `undefined` while nothing came; it never waits. A value stored by an older version is
  migrated with `migrate` and checked against the schema; a missing/throwing `migrate`, an invalid result, or a newer
  stored version throws.

## One wait per key (spec §5.7)

- The reservation that wakes a task on a key marks it consumed; a sleep on a consumed or expired key rejects (the
  task's commit throws; a tool or gate ends `invalid_park`).
- A value delivered early is not consumed: the sleep wakes at once. A second wait for the same kind of signal uses a
  new key (`ci-1`, `ci-2`); retries of the first delivery get `duplicate`.

## Memos (spec §5.2, §7.3)

- `memo(name, context)` reads the task's memo; `memo(name, candidate, context)` writes it first-writer-wins. A tool
  uses a memo for a stable idempotency key before an external effect, so a replayed effect is not duplicated.
- A hook's memos and the task's own memos share one namespace; hook authors prefix their memo names.

## Approval gate (spec §7.2)

```dart
// A beforeTool hook that sleeps a risky call until an approval signal.
final Approval = defineSignal(name: "approvals.decision", version: 1, schema: obj({allow: bool()}));
final DAY = 24 * 60 * 60 * 1000;

beforeTool: (call, api, context) async {
  if (call.name != "bash" || !isRisky(call.arguments)) return null;
  final key = canonicalDigest(call.arguments);              // other arguments, another question
  final state = await api.readSignal(Approval, key, context);
  final until = await api.memo('approvals.until.$key', api.now() + DAY, context);  // one deadline per question
  if (state == null) return {sleep: {signals: [Approval.key(key)], until: until}};
  if (state.kind == "expired") return {block: "No approval within a day"};
  return state.value.allow ? null : {block: "Not approved"};
}
```

- A `sleep` commits the tool task `sleeping` at `{phase: "call"}`, its slot `sleeping`; every wake re-runs `call`
  from the top (resolve, repair, validate, every `beforeTool` in order, validate again).
- A gate that sleeps with a deadline fixes it once in a memo; later passes (wakes, registry changes) keep it.
- Whatever shows the question keeps its own record and calls `harness.signal()` with the task ID from the call's slot.