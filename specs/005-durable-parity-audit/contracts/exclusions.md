# Contract: Exclusion and Divergence Discipline

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md) | **Data model**: [data-model.md](../data-model.md)

The exclusions sub-gate proves every behavior the port does not implement, does not differentially test, or
implements but has not verified carries an explicit, approved, machine-checkable rationale and a tracking issue —
not a free-text note. It is the audit's answer to the slow-erosion failure: "strict upstream port only" quietly
becomes "mostly a port" and full parity becomes an untestable claim.

## Inputs

- The pi#10 registry / manifest: every row's `status`, `divergence`, and `issue`.
- The set of open GitHub issues (to verify a tracking issue exists and is open).

## Check

For every row whose `status` is not `verified` (`unported`, `in_progress`, `implemented_unverified`, or
`not_applicable`), require exactly one exclusion:

| kind | required fields | additional requirement |
|------|-----------------|-------------------------|
| `not_applicable` | non-empty `reason`, non-empty `approved_by` | — |
| `deferred` | non-empty `reason`, non-empty `approved_by`, non-empty `issue` | `issue` exists and is open |
| `unverified` | non-empty `reason`, non-empty `approved_by`, non-empty `issue` | `issue` exists and is open |

A row with no exclusion, an exclusion with an empty/vague `reason`, an unnamed `approved_by`, or a
`deferred`/`unverified` exclusion whose `issue` is missing or closed fails the audit, naming the row.

## Follow-up issues

Every remaining gap (every `deferred` and `unverified` exclusion, and every `unported`/`in_progress` row that
will be ported) MUST have a precise follow-up issue stating:

- `upstream_behavior` — the exact upstream behavior;
- `upstream_coordinate` — the upstream SHA and path;
- `dart_coordinate` — the planned Dart file or seam;
- `blocking_reason` — why the gap exists;
- `depends_on` — the issues this gap depends on, in dependency order;
- `dependency_position` — the gap's position in the dependency order (e.g. `after-pi12`, `after-conformance`,
  `after-platform-adapter`).

A free-text note is not a gap; an issue with all seven fields is. The audit's gap report lists every remaining gap
as a dependency-ordered, owned follow-up issue, so the umbrella epic's finish line is falsifiable.

## Output

The exclusions section of the audit result:

```json
{
  "verdict": "pass",
  "unapproved": [],
  "gaps": [
    {
      "id": "arrrrny/pi#NN",
      "upstream_behavior": "Durable code-mode Wasm driver for QuickJS-in-Wasm sandbox.",
      "upstream_coordinate": { "sha": "780bf31fcaeb252fa9b68df3964c735eae75bde3", "path": "packages/durable/src/codemode/codemode.ts" },
      "dart_coordinate": "pi_agent/lib/src/durable/codemode/codemode.dart (sandbox seam)",
      "blocking_reason": "Needs a platform adapter (Wasm host); not a pure-Dart concern.",
      "depends_on": ["arrrrny/pi#12"],
      "dependency_position": "after-pi12"
    }
  ]
}
```

`verdict` is `pass` only when `unapproved` is empty and every remaining gap is a complete follow-up issue. Any
unapproved exclusion or incomplete gap fails the audit and is named in the `causes` set.

## Grounding

- pi#10 FR-005 (every non-`verified` row carries a divergence rationale and a tracking issue), FR-006 (every
  `not_applicable` row carries an approved platform or scope reason).
- pi#10 SC-003 (every non-`verified` row has a non-empty divergence rationale and a resolvable issue reference).
- This spec FR-018–FR-022 (exclusion kinds, approval rule, precise follow-up issue).