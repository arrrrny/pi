# Data Model: Durable pi Behavioral Parity Audit

The shapes below are the language-neutral contract between the audit gate, the pi#10 registry/manifest, the
conformance runner, and the human report. They are expressed as JSON because the audit reads the pi#10 artifacts
and the Dart mirror emits a typed result; the Dart implementation mirrors them only where it must emit or consume.

The audit consumes the pi#10 shapes in
[`specs/002-upstream-coverage-governance/data-model.md`](../002-upstream-coverage-governance/data-model.md)
(`coverage/state.json`, `coverage/registry/behavior-registry.json`, the generated manifest) and adds the audit-
specific shapes below. It does not redefine the registry, the manifest, or the state contract.

## State (consumed, not redefined)

`coverage/state.json` — the pi#10 SHA-state contract. The audit reads `target_upstream_sha` and
`verified_upstream_sha`; on a passing audit at SHA `S` it may advance `verified_upstream_sha` to `S` (and set
`verified_by` to this epic's issue, `arrrrny/pi#8`). On a failing audit it leaves `verified_upstream_sha`
unchanged or `null`. `target_upstream_sha` continues to advance on sync independently of the audit.

Invariant (from pi#10): when non-null, `verified_upstream_sha` is an ancestor of (or equal to)
`target_upstream_sha`. The audit never sets `verified_upstream_sha` to a SHA that is not the declared SHA it just
passed at.

## Audit Result (machine-readable)

`coverage/audit/<declared-sha>/result.json` — the audit's single verdict for one declared upstream SHA.

```json
{
  "schema_version": 1,
  "declared_upstream_sha": "780bf31fcaeb252fa9b68df3964c735eae75bde3",
  "target_upstream_sha": "780bf31fcaeb252fa9b68df3964c735eae75bde3",
  "target_ahead": false,
  "verdict": "pass",
  "would_advance_verified_sha": "780bf31fcaeb252fa9b68df3964c735eae75bde3",
  "sections": {
    "completeness": { "verdict": "pass", "unmapped_exports": [], "unmapped_assets": [] },
    "conformance": { "verdict": "pass", "suites": [] },
    "exclusions": { "verdict": "pass", "unapproved": [], "gaps": [] },
    "purity": { "verdict": "pass", "surfaces": [], "violations": [] },
    "evidence": { "verdict": "pass", "rejected_rows": [] }
  },
  "causes": [],
  "generated_by": "scripts/audit-durable-parity.mjs"
}
```

- `verdict` — `pass` or `fail`. `pass` is the only verdict that may advance `verified_upstream_sha` to
  `declared_upstream_sha`.
- `target_ahead` — true when `target_upstream_sha` is ahead of `declared_upstream_sha`; the audit still evaluates
  parity at `declared_upstream_sha` only and never implies parity at the target.
- `would_advance_verified_sha` — the SHA the audit would advance `verified_upstream_sha` to on `pass`; equals
  `declared_upstream_sha` on pass, `null` on fail.
- `sections` — the five sub-gates (completeness, conformance, exclusions, purity, evidence), each with its own
  verdict and named detail.
- `causes` — the named cause set on `fail` (a non-`verified` row without an approved exclusion, an unmapped
  export, a skipped conformance suite, an unapproved exclusion, a purity violation, a rejected `verified` row,
  a remaining divergence); empty on `pass`.

The result is deterministic: a re-run on an unchanged declared SHA and registry produces a byte-identical
`result.json` (stable ordering, no timestamps in the body).

## Audit Report (human-readable)

`coverage/audit/<declared-sha>/report.md` — the human-readable rendering of `result.json`. It states:

- the verdict and the declared SHA;
- the would-be new `verified_upstream_sha` on pass, or the named cause set on fail;
- the conformance-suite results (passed / failed / not_applicable with approved reason);
- the approved exclusions and the remaining gaps as dependency-ordered follow-up issues;
- the surfaces the purity guard scanned and the pass/fail of each;
- the explicit "not parity evidence" boundary (transcript persistence, export inventories, and Dart-only suites
  are not parity evidence), with any rows that would be falsely claimed under that mistake.

## Completeness Section

The completeness sub-gate's machine-readable detail.

```json
{
  "verdict": "pass",
  "declared_upstream_sha": "780bf31fcaeb252fa9b68df3964c735eae75bde3",
  "unmapped_exports": [],
  "unmapped_assets": [],
  "undecided_assets": [],
  "unmapped_rationales_used": []
}
```

- `unmapped_exports` — upstream public exports at the declared SHA with no behavior row and no approved
  `unmapped_rationales` entry. Each entry: `{ "coordinate": "<export>@<path>", "declaration_kind": "..." }`.
- `unmapped_assets` — applicable upstream source/test/spec/example files at the declared SHA with no behavior row
  and no approved `unmapped_rationales` entry. Each entry: `{ "path": "<upstream path>" }`.
- `undecided_assets` — upstream assets with no registry decision at all (neither a row nor an
  `unmapped_rationales` entry). Each entry: `{ "path": "<upstream path>" }`.
- `unmapped_rationales_used` — the `unmapped_rationales` entries the audit consumed (for traceability).

## Conformance Section

The conformance sub-gate's machine-readable detail.

```json
{
  "verdict": "pass",
  "suites": [
    {
      "id": "storage.memory",
      "kind": "storage",
      "result": "passed",
      "recorded_at": "coverage/conformance/storage.memory.json",
      "approved_reason": null
    },
    {
      "id": "storage.jsonl",
      "kind": "storage",
      "result": "passed",
      "recorded_at": "coverage/conformance/storage.jsonl.json",
      "approved_reason": null
    },
    {
      "id": "storage.sqlite",
      "kind": "storage",
      "result": "passed",
      "recorded_at": "coverage/conformance/storage.sqlite.json",
      "approved_reason": null
    },
    {
      "id": "env.node",
      "kind": "environment",
      "result": "passed",
      "recorded_at": "coverage/conformance/env.node.json",
      "approved_reason": null
    },
    {
      "id": "platform.codemode-wasm",
      "kind": "platform",
      "result": "not_applicable",
      "recorded_at": "coverage/conformance/platform.codemode-wasm.json",
      "approved_reason": "No Wasm driver in this slice; the sandbox seam is tested with a scripted host."
    }
  ]
}
```

- `id` — the conformance suite's stable id (storage.memory / storage.jsonl / storage.sqlite / env.node /
  platform.codemode-wasm / …).
- `kind` — `storage`, `environment`, or `platform`.
- `result` — `passed`, `failed`, or `not_applicable`.
- `recorded_at` — the path to the recorded suite result the audit read.
- `approved_reason` — non-null and non-empty only for `not_applicable`; the audit fails any `not_applicable`
  without an approved reason.

A suite that did not run (no `recorded_at` file), was skipped without an approved reason, or failed fails the
audit. A suite's pass alone does not make a dependent row `verified`; the row also needs its upstream-derived
differential evidence.

## Exclusion (machine-readable)

An exclusion is the approved reason a row is not `verified`. It is one of three tagged variants.

```json
{ "kind": "not_applicable", "reason": "Upstream area removed in 1.6.0.", "approved_by": "arrrrny", "issue": null }
{ "kind": "deferred", "reason": "Code-mode Wasm driver needs a platform adapter.", "approved_by": "arrrrny", "issue": "arrrrny/pi#NN" }
{ "kind": "unverified", "reason": "Implemented; provider cassette missing.", "approved_by": "arrrrny", "issue": "arrrrny/pi#NN" }
```

- `kind` — `not_applicable`, `deferred`, or `unverified`.
- `reason` — non-empty, specific (what is excluded and why).
- `approved_by` — the named owner who approved the exclusion.
- `issue` — the open tracking issue for `deferred` and `unverified` (must exist and be open); `null` for
  `not_applicable`.

An exclusion is approved only when `reason` is non-empty, `approved_by` is non-empty, and — for `deferred` and
`unverified` — `issue` names an open tracking issue.

## Follow-up Issue (machine-readable)

A precise, dependency-ordered follow-up issue for one remaining gap. The audit's gap report lists these.

```json
{
  "id": "arrrrny/pi#NN",
  "upstream_behavior": "Durable code-mode Wasm driver for QuickJS-in-Wasm sandbox.",
  "upstream_coordinate": { "sha": "780bf31fcaeb252fa9b68df3964c735eae75bde3", "path": "packages/durable/src/codemode/codemode.ts" },
  "dart_coordinate": "pi_agent/lib/src/durable/codemode/codemode.dart (sandbox seam)",
  "blocking_reason": "Needs a platform adapter (Wasm host); not a pure-Dart concern.",
  "depends_on": ["arrrrny/pi#12"],
  "dependency_position": "after-pi12"
}
```

- `id` — the tracking issue number (open).
- `upstream_behavior` — the exact upstream behavior the gap represents.
- `upstream_coordinate` — the upstream SHA and path.
- `dart_coordinate` — the planned Dart coordinate (file or seam).
- `blocking_reason` — why the gap exists.
- `depends_on` — the issues this gap depends on, in dependency order.
- `dependency_position` — the gap's position in the dependency order (e.g. `after-pi12`, `after-conformance`,
  `after-platform-adapter`).

A free-text note is not a gap; an issue with all seven fields is.

## Purity Section

The purity sub-gate's machine-readable detail.

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

- `surfaces` — the five surfaces the scan covers; each with `scanned: true` and its own `violations`.
- `violations` — the union of all surface violations, each `{ "surface": "...", "file": "...", "import": "..." }`
  (forbidden import), `{ "surface": "...", "file": "...", "type": "...", "renames": "<upstream concept>" }`
  (renamed/invented type), or `{ "surface": "...", "file": "...", "loop": "..." }` (second agent loop).

The purity guard does not weaken for optional environments or recovery-only paths; an import in either fails
exactly as a core-path import would.

## Evidence Section

The evidence sub-gate's machine-readable detail.

```json
{
  "verdict": "pass",
  "rejected_rows": []
}
```

- `rejected_rows` — rows marked `verified` whose only evidence is a green Dart-only test, an export-inventory
  match, a source-file count, or a transcript-persistence demonstration. Each entry: `{ "row": "<id>", "why": "..." }`.

The audit rejects a `verified` row whose `evidence.kind` is not `differential` (per the pi#10 schema) or whose
`evidence` lacks an upstream-derived differential reference. It states in the human report that transcript
persistence, export inventories, and Dart-only suites are not parity evidence.

## Audit Tooling (Dart)

The audit tool lives under `pi_agent/tool/audit/` with a `scripts/audit-durable-parity.mjs` governance entry.

```text
pi_agent/tool/audit/
├── audit_runner.dart       #   orchestrates the five sub-gates, writes result.json + report.md
├── completeness.dart       #   export/asset inventory diff vs registry (reads upstream tree at declared SHA)
├── conformance.dart        #   reads recorded conformance-suite results, gates them
├── exclusions.dart         #   exclusion approval + follow-up-issue checks
├── purity.dart             #   forbidden-import / rename / second-loop scan across every surface
└── (mirror scripts/audit-durable-parity.mjs for the governance-tooling entry)
```

Each Dart type and function is named in this file with the pi#10 or upstream source it grounds in. The audit
tool adds no durable runtime behavior and no `pi_agent/lib/src/durable/**` runtime code; it is governance tooling
only.

## Non-Claims

This feature is the umbrella's falsifiability layer, not a third runtime. It:

- does not port durable behavior (pi#11 and pi#12 do);
- does not re-implement the pi#10 registry, manifest, or release gate (it consumes them);
- does not advance `verified_upstream_sha` by declaring parity (only the audit passing at one SHA does, per
  FR-002/FR-004);
- does not invent implementation work already owned by pi#11/pi#12 (it files or names precise follow-up issues);
- does not declare parity from transcript persistence, export inventories, or Dart-only tests (FR-028–FR-031);
- does not add a Zuraffa wrapper, a browser integration, an MCP policy, or any product integration (FR-034).