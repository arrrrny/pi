# Contract: No-Leakage and Purity Guard

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md) | **Data model**: [data-model.md](../data-model.md)

The purity sub-gate proves the Dart port remained a strict pi port: no Zuraffa entities, no browser concepts, no
MCP policy, no product-domain code, no renamed or invented runtime model, no second agent loop — and no leakage
through optional environments or extension/recovery surfaces. It is the audit's continuous enforcement of the
architecture plan's load-bearing rule: "Zuraffa extends pi through upstream seams, not by editing pi."

## Surfaces scanned

The scan covers five surfaces, all required (`scanned: true`):

1. **core** — `pi_agent/lib/src/durable/**` and `pi_agent/lib/durable.dart`.
2. **optional-env** — `pi_agent/lib/src/env/**` and any platform adapter the port ships.
3. **extensions** — `pi_agent/lib/src/durable/harness/registry*.dart`, `define.dart`, and every hook/wrapper
   surface.
4. **recovery-replay** — `pi_agent/lib/src/durable/harness/generation.dart` (recovery), `tool.dart` (replay),
   `codemode/` (journal/reattach), `scheduler.dart` (abort cascade), and every replay/recovery path.
5. **existing-wrappers** — `pi_agent/lib/pi.dart` and the existing `Agent`/`AgentLoop`/`Conversation` surface.

"Optional" and "only on recovery" are not exemptions. An import in an optional environment or a recovery-only path
fails exactly as a core-path import would (FR-026).

## Checks

For each surface, fail on:

- **forbidden import** — any import of `zuraffa`, `zuraffa_agent`, a browser package, or product-domain code.
  Violation: `{ "surface": "...", "file": "...", "import": "..." }`.
- **renamed or invented runtime type** — a new name for an upstream concept (a type that renames or reinterprets
  an upstream type). Violation: `{ "surface": "...", "file": "...", "type": "...", "renames": "<upstream concept>" }`.
- **second agent loop / parallel runtime model** — a second model or durable loop. Violation:
  `{ "surface": "...", "file": "...", "loop": "..." }`.

The rename check is grounded: every exported Dart type in the new surface is named in
[this feature's `data-model.md`](../data-model.md) or in pi#11/pi#12's data-model with the upstream file and
symbol it ports. A type with no upstream source, or a type whose name differs from the upstream concept it
reimplements, is a violation.

## Output

The purity section of the audit result:

```json
{
  "verdict": "pass",
  "surfaces": [
    { "surface": "core", "scanned": true, "violations": [] },
    { "surface": "optional-env", "scanned": true, "violations": [] },
    { "surface": "extensions", "scanned": true, "violations": [] },
    { "surface": "recovery-replay", "scanned": true, "violations": [] },
    { "surface": "existing-wrappers", "scanned": true, "violations": [] }
  ],
  "violations": []
}
```

`verdict` is `pass` only when every surface is `scanned: true` and `violations` is empty. Any violation fails the
audit and is named in the `causes` set with its surface, file, and import/type/loop.

## Recorded as parity evidence

A clean-tree purity result is recorded as passing evidence for the parity gate and names the surfaces it scanned
(FR-027). The human report lists the surfaces and the pass/fail of each.

## Grounding

- pi#10 FR-030 (no import of `zuraffa`, `zuraffa_agent`, a browser package, or product-domain code; the check
  runs as part of the parity gate).
- pi#10 SC-007 (zero such imports under `pi_agent/lib`).
- This spec FR-023–FR-027 (every surface, rename and second-loop scans, no weakening for optional/recovery paths).
- Architecture plan §5.2, §7.3 (the extension model; Zuraffa extends pi through upstream seams).