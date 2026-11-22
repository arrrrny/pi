# Contract: Conformance-Suite Gate

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md) | **Data model**: [data-model.md](../data-model.md)

The conformance sub-gate proves the Dart port passes the upstream conformance suites, not just its own Dart tests.
It is the audit's answer to the false-parity failure: a backend that passes its own tests but fails the upstream
conformance contract is treated as done.

## Inputs

- The declared upstream SHA.
- The recorded conformance-suite results under `coverage/conformance/`:
  - `storage.memory` — memory backend (atomic commits, read-only opens, commit receipts, failure semantics).
  - `storage.jsonl` — JSONL backend (same contract).
  - `storage.sqlite` — SQLite backend (same contract, including migrations).
  - `env.node` — environment conformance (env read/decode/line-scan/node-watch, as the pi#11 env port claims).
  - `platform.codemode-wasm` — the durable code-mode sandbox seam, when a real Wasm driver exists.
  - any other platform adapter the port claims to support.

Each recorded result is one of `passed`, `failed`, or `not_applicable` with an `approved_reason`.

## Check

For each suite the port claims to support:

- `passed` → the suite is recorded as passing.
- `failed` → the audit fails, naming the suite and the failing assertion (read from the recorded result).
- `not_applicable` → the audit passes for that suite only when `approved_reason` is non-empty and names the
  missing platform adapter or approved scope; every row that depended on that suite MUST NOT be `verified`.
- a suite that did not run (no recorded result file) or was skipped without an approved reason → the audit fails,
  naming the suite and the reason.

A conformance-suite pass alone does NOT make a dependent row `verified`; the row also needs its upstream-derived
differential evidence per the pi#10 schema (FR-016).

## Output

The conformance section of the audit result:

```json
{
  "verdict": "pass",
  "suites": [
    { "id": "storage.memory", "kind": "storage", "result": "passed", "recorded_at": "coverage/conformance/storage.memory.json", "approved_reason": null },
    { "id": "storage.jsonl", "kind": "storage", "result": "passed", "recorded_at": "coverage/conformance/storage.jsonl.json", "approved_reason": null },
    { "id": "storage.sqlite", "kind": "storage", "result": "passed", "recorded_at": "coverage/conformance/storage.sqlite.json", "approved_reason": null },
    { "id": "env.node", "kind": "environment", "result": "passed", "recorded_at": "coverage/conformance/env.node.json", "approved_reason": null },
    { "id": "platform.codemode-wasm", "kind": "platform", "result": "not_applicable", "recorded_at": "coverage/conformance/platform.codemode-wasm.json", "approved_reason": "No Wasm driver in this slice; the sandbox seam is tested with a scripted host." }
  ]
}
```

`verdict` is `pass` only when every claimed suite is `passed` or `not_applicable` with an approved reason. Any
suite that did not run, was skipped without approval, or failed fails the audit and is named in the `causes` set.

## No Dart-only substitute

The audit does not accept a Dart-only test suite as a substitute for an applicable upstream conformance suite
(FR-017) or upstream-derived differential evidence (FR-028). A row whose only evidence is a green Dart test is
rejected by the evidence sub-gate.

## Grounding

- pi#10 FR-021 (port storage and environment conformance suites before new backends are added).
- pi#10 FR-022 (a Dart-only green suite is not sufficient evidence of parity).
- Upstream `packages/durable/src/testing/storage-conformance.ts`, `env-conformance.ts`, `commit-writes.ts`,
  `runner.ts`, and the `packages/durable/test/storage-*.test.ts`, `env-*.test.ts` suites at the declared SHA.
- Architecture plan §6.4 (differential evidence is the only credible proof; a passing Dart-only suite is not
  sufficient).