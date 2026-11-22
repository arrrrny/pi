# Contract: Coverage Ledger and Gates

The command-line and file contracts the implementation must satisfy. Everything here is observable from a
clean checkout of the pinned SHAs; nothing depends on a local dashboard or a human's memory.

## 1. Generator

```
node scripts/coverage/generate-coverage-manifest.mjs \
  --upstream <path-to-upstream-checkout> \
  --registry coverage/registry/behavior-registry.json \
  --sha <full-sha> \
  --out coverage/upstream/<sha>
```

- **Reads**: the human-reviewed behavior registry (`--registry`), the upstream checkout at `<sha>`
  (packages' `package.json`, entry points, `src/**`, `test/**`, `README.md`, examples, `apps/*`), and
  `coverage/upstream/<sha>/app-decisions.json` if present.
- **Produces**: `manifest.json` (behavior rows resolved from the registry against the generated
  inventories), `exports.json`, `sources.json`, and `assets.json` (the test/spec/example references) under
  `--out`. Does **not** write `report.md` (that is the reporter's job) and does **not** write `state.json`.
- **Behavior source**: rows come only from the registry. The generator MUST NOT synthesize a behavior from a
  filename, and MUST NOT infer a row's `status` from the presence or absence of a Dart path.
- **Exit 0** when the files are written; **exit 2** when the checkout is not at `<sha>`, when a package
  cannot be parsed, when the registry does not validate against its schema, or when an `apps/*` target has no
  decision entry. The message names the offending path.
- **Determinism**: two runs over the same checkout and the same registry produce byte-identical files. The
  header records `generator.version` and the resolved `typescript` version; no timestamps or absolute paths
  appear in the body.

## 2. Reporter

```
node scripts/coverage/generate-coverage-report.mjs --manifest coverage/upstream/<sha>/manifest.json
```

- Pure function of the manifest. Writes `report.md` beside it.
- Sections: header (SHA, generator version), per-package status table, a "Not verified" section (one entry
  per row with its divergence and issue), and an "Approved exclusions" section.

## 3. Coverage check

```
node scripts/coverage/check-coverage.mjs --manifest <path>
```

Fails (exit 1) on any of:

- a row with an unknown status;
- a row whose status is `unported` / `in_progress` / `implemented_unverified` without a non-empty
  `divergence` and `issue`;
- a `not_applicable` row without an approved reason;
- a `verified` row without a resolvable `evidence` target, or whose `dart_test` path does not exist;
- an `apps/*` target missing from `app-decisions.json`, or a decision entry whose path is not an `apps/*`
  target at the pinned SHA;
- an export present upstream but absent from `exports.json` (inventory incompleteness);
- **completeness**: a public export, or an applicable upstream source/test/spec/example asset (from
  `sources.json` / `assets.json`), that maps to no behavior row and carries no entry in the registry's
  reviewed-rationale list (`unmapped_rationales`); the failure names the unmapped item;
- a behavior row whose `upstream_path` does not resolve to a real file at the pinned SHA.

Each failure is printed as `<item-id>: <reason>` on its own line. Exit 0 prints the counts.

## 4. Release evidence (full-parity gate — parity-labeled release only)

```
node scripts/coverage/check-release-evidence.mjs [--json]
```

- **Scope**: this is the full-parity gate. It runs **only** for an explicitly parity-labeled release (the
  release workflow, or `workflow_dispatch` with an explicit parity-release input). It MUST NOT run in the
  ordinary push/pull-request coverage workflow, which is intentionally red while known rows are unported.
- Reads `coverage/state.json` and the manifest for `verified_upstream_sha` (and the target's, for the gap).
- **Fails (exit 1)** when any of:
  - `verified_upstream_sha` is `null` (no complete baseline yet);
  - `verified_upstream_sha` is not an ancestor of `target_upstream_sha`;
  - `target_upstream_sha` ≠ `verified_upstream_sha` and unresolved changes exist between them;
  - any applicable row is not `verified` (global full parity requires every applicable row verified);
  - any exclusion is not approved, or any known divergence remains.
- On success, prints the release-evidence object (see `data-model.md`) including the exact verified SHA, and
  names it as the SHA the parity claim refers to.
- `--json` emits the object only, for the release workflow to capture as an artifact.

## 5. Purity check

```
node scripts/coverage/check-purity.mjs [--root pi_agent/lib]
```

- Fails (exit 1) on any import or export directive under the root whose target begins with a forbidden
  prefix: `package:zuraffa`, `package:zuraffa_agent`, a browser package, or a product-domain package.
- Output: `<file>:<line>: forbidden import <uri>`.
- This is a gate, not a warning; it runs in `coverage.yml`.

## 6. Differential runner

```
node scripts/coverage/differential/run-scenario.mjs --scenario <file> --sha <sha>
```

- Runs the scenario against the TypeScript implementation and the Dart harness:
  - TS: `node scripts/coverage/differential/run-ts.mjs --scenario <file>`
  - Dart: `dart run pi_agent/tool/parity_harness.dart --scenario <file>`
- Normalizes both outputs with `normalization_version` from the scenario, diffs them, and writes
  `coverage/differential/results/<sha>/<name>.json`.
- Exit 0 on match; exit 1 on divergence (the diff is printed); exit 2 on harness failure (a scenario that
  could not run is not a pass).
- **Never** performs a live provider call: a scenario that names a non-scripted, non-cassette provider is
  rejected with exit 2.

### Dart harness

```
dart run pi_agent/tool/parity_harness.dart --scenario <file>
```

- Reads the scenario JSON, executes it against the Dart implementation, emits normalized JSONL to stdout.
- Dev-only: not exported from `package:pi/pi.dart`, not part of the published surface.
- Uses `dart:io` and `dart:convert` only; adds no dependency to `pi_agent/pubspec.yaml`.

## 7. Sync workflow

`.github/workflows/sync-upstream.yml` post-merge behavior:

- Classifies every changed file under `packages/**` and `apps/**` by area:
  - area from `packages/<area>/…` for the 12 known areas;
  - `apps` bucket for `apps/**`;
  - file class from the extension/path: `source`, `test`, `export`, `asset`, `migration`, `manifest`.
- Groups by area and opens or updates one `dart-port` issue per area. The issue body lists:
  - the file groups with their class labels;
  - the upstream commit range and the new `target_upstream_sha`;
  - `Depends on: owner/repo#n` lines where the area's slice depends on earlier work;
  - the exact command to regenerate the ledger and the row ids the slice must move to `verified`.
- Updates `coverage/state.json`'s `target_upstream_sha` and commits it with the artifacts-only rule.
- Preserves the existing conflict path: abort, file a `sync`-labeled issue, fail the job.
- The strings "OpenAI-compatible-only" and "other packages are informational" MUST NOT appear in the
  workflow or in any documentation it links.

## 8. Coverage workflow (routine push / pull-request)

`.github/workflows/coverage.yml` runs on push to `master` and on pull requests:

1. checkout with enough history to resolve the pinned SHAs;
2. `node scripts/coverage/generate-coverage-manifest.mjs` for the target SHA (registry + inventories);
3. `node scripts/coverage/check-coverage.mjs` (manifest invariants + registry/inventory completeness);
4. `node scripts/coverage/check-purity.mjs`;
5. `dart test -j 2` in `pi_agent/` (existing suite; the governance layer's own tests are Node-side and run
   in the existing `npm run test:scripts`).

This workflow MUST NOT run `check-release-evidence.mjs`. It generates the manifest and inventories checks and
differential evidence; it is **intentionally red while known rows are unported**, so it is a build-health and
inventory signal, never a parity gate. A red routine run blocks nothing that is not already known to be
unported.

## 8a. Release workflow (explicitly parity-labeled only)

`.github/workflows/release.yml` (and a `workflow_dispatch` with an explicit `parity_release` boolean input,
defaulting to false) runs the full-parity gate:

1. the same checkout, generation, `check-coverage.mjs`, and purity steps as above;
2. `node scripts/coverage/check-release-evidence.mjs --json`, captured as a release artifact.

A parity-labeled release fails when `verified_upstream_sha` is `null`, the target is ahead of verified, any
applicable row is not `verified`, or any exclusion is unapproved. The gate never runs implicitly on an
ordinary push or pull request.

## 9. Compatibility rules

- The manifest `schema_version` is bumped only with a migration note in `data-model.md`; readers reject a
  manifest whose major `schema_version` they do not know.
- The normalization `normalization_version` is bumped only when a rule changes; goldens record their version
  and a mismatch is reported as a version mismatch, never as a behavioral divergence.
- Adding a package area to the ledger is a manifest change, not a code change, but the area list is pinned in
  the checker and MUST be extended deliberately (with the upstream package name) rather than inferred.