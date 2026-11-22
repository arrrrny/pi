# Contract: Durable Code Mode and Deterministic Replay

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md)
**Upstream**: `packages/durable/src/codemode/codemode.ts`, `describe.ts`, `models.ts`, `output.ts`;
`packages/codemode/src/portable.ts`, `runtime/execution.ts`; spec (code-mode tool), `packages/codemode/README.md`

## The problem and the solution (codemode.ts header)

A code-mode script is in-memory VM state. A restart while

```js
const results = await Promise.all(paths.map((path) => tools.read({ path })));
```

waits for the last of 200 reads would lose the script and every read it made. The solution is deterministic replay:
the VM runs only when the host hands it a result; given the same start data, clock, seed, and results in the same
order, it makes the same calls with the same arguments. The tool is replay-safe: after a restart, `execute()` runs
again, starts the script again from the stored start data, and hands it the results it got before, in the order it got
them, from a journal written before each delivery.

## Documents (task-scoped, gone when the call settles)

- **`pi.codemode.run`** — the start data (written once before the VM starts) and the outcome (written once when the
  call decides it, with the store writes, in one transaction), so a rerun after that returns the outcome without a
  VM.
- **`pi.codemode.journal`** — one entry per delivered result, in delivery order: the VM call ID, the clock value, the
  calls the VM had issued after processing it (once acknowledged), and a global's outcome, which nothing else stores.

## Nested-call reattach (codemode.ts, spec §7.3)

- A code-mode nested call is keyed `c<VM call id>`, so it reattaches to its task by key and never runs twice unless
  its own replay policy reruns it; its result comes from `NestedCallDoc`.
- A call is launched only once the count of calls issued in the drain that made it is committed. Every key an earlier
  attempt admitted is at most its last recorded count; a replay checks every recorded count, so when it releases its
  calls it has made every call an earlier attempt could have admitted, and later calls are new.

## Refusal to replay (codemode.ts)

A rerun refuses to replay (no new nested calls; nested calls admitted earlier may still resume on their own and are
aborted by the call's cleanup) and ends with an error result when:

- this module's version or the VM's fingerprint changed;
- the deadline passed;
- the script diverges: it makes another call, or calls in another order, than the journal says.

## Sandbox host seam (packages/codemode)

```dart
// The portable surface the durable tool drives; the concrete sandbox (QuickJS-in-Wasm) is behind it.
abstract interface class CodemodeSandboxBase {
  Future<CodemodeOutcome> start(VmStartData start);   // begin the script
  // deliver a tool result -> the VM continues; may issue more calls
}
```

- The sandbox runs in a worker thread (Node/Bun), a Durable Object (Cloudflare), or inline; the durable tool depends
  only on the portable `CodemodeSandboxBase`/host boundary and the `VmStartData`/`CodemodeOutcome` shapes.
- The script's capabilities are `tools`, `ALL_TOOLS`, `text`, `image`, `exit`, `store`, `load`, and an optional
  `// @options:` line; nested tool calls never enter the LLM context — only the script's output and return value do.

## Script-environment contract (packages/codemode)

- `tools.<name>(args)` calls an injected tool and returns its `structuredOutput` (a schema tool's validated value, a
  schema-less tool's bounded output); the script may `return` a value and call `text()`/`image()` to emit output.
- `store`/`load` persist JSON values across a replay (used for a script's own idempotency).
- The host enforces a `timeoutMs` and the script's output is the durable result's `structuredOutput`/`output`.