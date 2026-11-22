# Contract: Upstream Asset Completeness Gate

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md) | **Data model**: [data-model.md](../data-model.md)

The completeness sub-gate proves nothing upstream escaped the ledger. It is the audit's answer to the silent-drift
failure: a new public export or source/test/spec/example asset lands upstream and no behavior row claims it.

## Inputs

- The declared upstream SHA (`780bf31fcaeb252fa9b68df3964c735eae75bde3`), resolved through the local checkout.
- The pi#10 registry (`coverage/registry/behavior-registry.json`): the human-reviewed behaviors, each with its
  upstream coordinate (path, export or internal marker) and its `unmapped_rationales` entries.
- The generated manifest (the pi#10 resolved ledger), if present; otherwise the registry alone.

## Derivation

At the declared SHA, derive two inventories of `packages/durable` (and any other package area the epic covers):

1. **Public-export inventory** — every named export the package exposes, with its source path and declaration
   kind (`function`, `class`, `interface`, `type`, `const`, …). This is the same source pi#10's generator uses
   (the compiler-derived export inventory).
2. **Applicable asset inventory** — every source (`.ts`), test (`*.test.ts`), spec (`docs/spec.md` and its
   sections), and example (`test/examples/*.ts`) file under `packages/durable/` at the declared SHA.

## Check

For each inventory item, require one of:

- **a behavior row** in the registry whose `upstream_path` and `export` (or internal marker) match the item; or
- **an approved `unmapped_rationales` entry** in the registry (`kind: "export"` or `kind: "asset"`) whose
  `coordinate` matches the item and whose `reason` is non-empty and `approved_by` is non-empty.

An item with neither is a failure:

- a public export with neither → `unmapped_exports` entry `{ "coordinate": "<export>@<path>", "declaration_kind": "..." }`;
- an applicable asset with neither → `unmapped_assets` entry `{ "path": "<upstream path>" }`;
- an asset with no registry decision at all (neither a row nor an `unmapped_rationales` entry, and not marked
  `not_applicable` with an approved reason) → `undecided_assets` entry `{ "path": "<upstream path>" }`.

A package area upstream deleted entirely is `not_applicable` with an approved "upstream removed" rationale; an
area with no decision is a failure.

## Output

The completeness section of the audit result:

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

`verdict` is `pass` only when all four detail arrays are empty. Any non-empty array fails the audit and is named
in the `causes` set.

## Determinism

The completeness check is deterministic: a re-run on an unchanged declared SHA and registry produces a
byte-identical section (stable ordering of exports and assets, no timestamps).

## Grounding

- pi#10 FR-001, FR-003, FR-010, FR-010a–FR-010c (the registry, the manifest, the export/source inventories, the
  completeness rule).
- pi#10 SC-001 (every public export and applicable upstream source/test/spec/example asset maps to a row or an
  explicit reviewed rationale; zero silent omissions).
- Upstream `packages/durable/package.json` exports map and the `packages/durable/src/**`, `test/**`,
  `docs/spec.md` tree at the declared SHA.