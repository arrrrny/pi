# Implementation Plan: Upstream Coverage Governance

**Branch**: `002-upstream-coverage-governance` | **Date**: 2026-11-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-upstream-coverage-governance/spec.md`

## Summary

Build the governance layer that makes pi's "Dart port of upstream" claim falsifiable. Four mechanisms, all
driven from a single pinned upstream SHA:

1. **A deterministic coverage generator** (`scripts/coverage/`) that combines a versioned, human-reviewed
   **behavior registry** with compiler-derived public-export/source inventories and the upstream
   test/spec/example references for a local checkout of upstream `earendil-works/pi` at a pinned SHA, and
   emits `coverage/upstream/<sha>/manifest.json` plus a human `report.md`. Public-export enumeration alone
   cannot construct the ledger: the registry declares the behaviors, and a completeness check fails any public
   export or applicable upstream source/test/spec/example asset that maps to no behavior row and carries no
   reviewed rationale. Behavior is never inferred from a filename, and status is never inferred from a missing
   Dart path.
2. **SHA governance** — `coverage/state.json` holds `target_upstream_sha` and `verified_upstream_sha`
   separately (`verified_upstream_sha` may be `null` until the first complete baseline); full parity is global
   at one declared SHA (every applicable row verified, every exclusion approved, no known divergence), so a
   slice marks only its own rows and never advances the verified SHA on its own.
   `check-release-evidence.mjs` is the full-parity gate and runs **only** for an explicitly parity-labeled
   release (the release workflow, or `workflow_dispatch` with an explicit parity-release input). Ordinary
   push/pull-request coverage CI never runs it — it generates the manifest and inventories checks and
   differential evidence, which are intentionally red while known rows are unported.
3. **A differential harness** that runs the same scripted scenario (scripted provider, virtual clock,
   sanitized cassettes, crash points) against the TypeScript upstream and the Dart port, normalizes both
   outcomes, and diffs them into goldens under `coverage/differential/`.
4. **A coverage-aware sync** — extend `.github/workflows/sync-upstream.yml` to group every changed file by all
   12 package areas and file one `dart-port` issue per area with `Depends on:` declarations, and delete the
   "OpenAI-compatible-only" / "other packages are informational" assumptions.

No upstream behavior is ported by this feature; it delivers the registry schema, completeness checks, the
generator, the differential harness, the sync policy, and the explicitly scoped release gate that the
per-package porting slices move against.

## Technical Context

**Language/Version**: TypeScript 5.x tooling on Node >= 22.19 (type-stripping for `.ts` imports, `node:test`);
Dart SDK ^3.0.0 for the port under test
**Primary Dependencies**: dev-only — `typescript` (public-export/source inventory via the compiler API),
`esbuild` (bundling the TS differential entry point); Dart side adds no runtime dependency (`dart:io`,
`dart:convert` only). The behavior registry is a checked-in human-reviewed JSON input, not a dependency.
**Storage**: a checked-in human-reviewed registry under `coverage/registry/` plus generated JSON/Markdown
artifacts under `coverage/` (manifest, report, export/source/asset inventories, app decisions, goldens,
per-scenario results); no database
**Testing**: `node --test scripts/coverage/*.test.mjs` for the tooling; `dart test -j 2` in `pi_agent/` for the
port; `flutter test --concurrency=2` only for platform-gated rows
**Target Platform**: Node 22.19+ and Dart VM for the governance tooling; rows may declare platform
requirements (`vm`, `flutter`, `web`) without narrowing the claim
**Project Type**: Polyglot monorepo — governance tooling at the repo root plus a Dart library port under
`pi_agent/`
**Performance Goals**: full-tree manifest generation under 60 s; a single differential scenario round-trip
under 5 s excluding the (mocked) provider
**Constraints**: zero paid provider calls; no new runtime dependencies in `pi_agent/`; deterministic,
byte-stable generated output; no fork-patches to upstream TypeScript; artifacts only, never source edits, in
the automation commits
**Scale/Scope**: 12 upstream package areas + every upstream `apps/*` target; 17 existing Dart test files;
one manifest per pinned SHA, retained immutably

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` is the unfilled scaffold (every section still carries `[PLACEHOLDER]`), so
there are no project-specific gates to satisfy. The same reasoning as `specs/001-dart-agent-package/plan.md`
applies: standard practice plus the hard rules in `AGENTS.md`. Checked against those:

- **Artifacts only, explicit paths** — every automation commit stages `coverage/` and `.github/workflows/`
  only; no `git add -A`.
- **No source edits to upstream TS** — the generator reads upstream; it never writes into `packages/`.
- **No paid tokens in tests** — scripted providers and sanitized cassettes only.
- **Pin exact tool versions** — the generator records its own version and the `typescript` version in the
  manifest header so a ledger can be regenerated or challenged.
- **Test concurrency cap** — `dart test -j 2`, `flutter test --concurrency=2` in every command this feature
  documents or runs.
- **No changelog entry** — this feature targets `master` but touches no `packages/*` source; no
  `CHANGELOG.md` change is required (and none is created).
- **No `any`, no runtime checks on typed values** — tooling is plain `.mjs`, so the typed-value rules bind
  the Dart side, which is unchanged by this feature.

**Verdict**: PASS — no constitutional violations. No row in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/002-upstream-coverage-governance/
├── plan.md                     # This file
├── research.md                 # Phase 0 — decisions and rationale
├── data-model.md               # Phase 1 — ledger, manifest, and state shapes
├── quickstart.md               # Phase 1 — how to generate, verify, and gate
└── contracts/
    └── coverage-ledger.md      # Phase 1 — manifest/report/check contracts
```

### Source Code (repository root)

```text
coverage/
├── registry/
│   └── behavior-registry.json          # versioned, human-reviewed INPUT: the behaviors that exist
├── state.json                          # target_upstream_sha, verified_upstream_sha (latter may be null)
├── upstream/
│   └── <sha>/                          # immutable, one directory per pinned SHA
│       ├── manifest.json               # behavior rows (from registry) + inventories + app decisions
│       ├── exports.json                # public-export inventory (compiler-derived; diff source)
│       ├── sources.json                # source-file inventory (compiler-derived; completeness source)
│       ├── assets.json                 # upstream test/spec/example references (completeness source)
│       ├── app-decisions.json          # apps/* → port | adapt | not_applicable + reason
│       └── report.md                   # generated human-readable rendering
└── differential/
    ├── scenarios/<name>.json           # language-neutral scripted scenario
    ├── goldens/<name>.json             # normalized expected outcome
    └── results/<sha>/<name>.json       # actual outcome per implementation

scripts/coverage/
├── generate-coverage-manifest.mjs      # registry + inventories → manifest.json
├── generate-coverage-report.mjs        # manifest.json → report.md
├── check-coverage.mjs                  # manifest invariants + registry/inventory completeness
├── check-release-evidence.mjs          # full-parity gate; parity-labeled release only
├── check-purity.mjs                    # no zuraffa/browser/product imports in pi_agent/lib
├── differential/
│   ├── run-scenario.mjs                # scenario → TS run + Dart run → normalized diff
│   └── run-ts.mjs                      # TypeScript side entry (type-stripped import)
├── lib/
│   ├── upstream-tree.mjs               # pinned checkout resolution, package discovery
│   ├── exports.mjs                     # export/schema/source enumeration (typescript API)
│   ├── registry.mjs                    # behavior-registry schema, validation, completeness
│   ├── normalize.mjs                   # event/transcript/state/commit/error/usage normalizers
│   └── manifest.mjs                    # manifest schema, ordering, hashing
└── *.test.mjs                          # one test file per module

pi_agent/
└── tool/
    └── parity_harness.dart             # dev-only scenario runner; reads JSON, emits normalized JSONL

.github/workflows/
├── sync-upstream.yml                   # extended: 12-area grouping + Depends on: + SHA state
├── coverage.yml                        # new: generate + check-coverage + purity + differential (NO parity gate)
└── release.yml                         # parity-labeled release: runs check-release-evidence.mjs only here
```

**Structure Decision**: Tooling lives at the repo root beside the existing `scripts/*.mjs` check scripts
(`scripts/biome-check.mjs`, `scripts/check-entry-graphs.mjs`) because it operates on the upstream TypeScript
tree and is wired into the same `npm run check`-style gates. The Dart side gains exactly one dev-only entry
point, `pi_agent/tool/parity_harness.dart`, which is not exported from `package:pi/pi.dart` and is excluded
from the published library surface. Generated evidence lives under a root `coverage/` directory, kept out of
`packages/` so the fork's no-edit policy on upstream TypeScript is structurally obvious.

## Phase 0 — Research

See [research.md](./research.md). Decisions that shape the build:

- **Ledger location and ownership** — root `coverage/`, generated by Node, read by both the gate and the
  Dart differential runner. Rejected: a Dart-side generator (cannot parse TS exports without a hand-rolled
  parser) and a committed hand-maintained YAML manifest (drifts silently).
- **Behavior registry as the human input** — a versioned, human-reviewed `coverage/registry/behavior-
  registry.json` declares which behaviors exist; the generator resolves it against the generated inventories.
  Public-export enumeration alone cannot construct a behavior ledger (an export is a symbol, not a behavior),
  and inferring behavior from a filename is unsound. Rejected: synthesizing rows from filenames, and treating
  the export list as the ledger.
- **Export/source enumeration** — `typescript` compiler API over each package's entry points, `exports` map,
  and `src/**`, plus an inventory of upstream test/spec/example references; these are completeness inputs the
  registry is checked against, not the behavior source. Rejected: regex over barrel files (misses re-exports
  and type-only exports).
- **Differential transport** — scenario JSON on stdin/argv, normalized JSONL on stdout, per implementation.
  Rejected: a shared FFI or an in-process Dart VM embed (impossible without a Dart embedding API).
- **Normalization** — a single canonical event schema with explicit rules for timestamps, IDs, and
  interleavings. Rejected: byte-comparing raw transcripts (legitimately nondeterministic).
- **SHA state** — a checked-in `state.json`; the sync advances `target_upstream_sha`, and `verified_upstream_sha`
  (which may be `null`) advances only when full parity holds globally at one SHA (every applicable row
  verified, every exclusion approved, no known divergence) — never by a single slice and never by the
  generator. Rejected: deriving verified-SHA from git tags (a tag records a merge, not a verification), and
  advancing it on slice completion (that is exactly the false-parity claim this feature prevents).
- **App decisions** — a checked-in `app-decisions.json` keyed by upstream path, with `not_applicable`
  requiring a reason and an approver. Rejected: inferring from the manifest (silent omission risk).

## Phase 1 — Design

See [data-model.md](./data-model.md) for the entity shapes and
[contracts/coverage-ledger.md](./contracts/coverage-ledger.md) for the file-level contracts, and
[quickstart.md](./quickstart.md) for the operating procedure.

Key design points:

- **Determinism**: the generator sorts every collection by a stable key, excludes timestamps and absolute
  paths from the ledger body, and records the generator + `typescript` versions in a header block. Two runs
  on the same checkout and the same registry must be byte-identical (SC-002).
- **Registry-driven rows and completeness**: rows come from the human-reviewed registry, never from
  filenames; the generator joins each row to the compiler-derived export/source inventories and the upstream
  test/spec/example references, and `check-coverage.mjs` fails any public export or applicable upstream
  source/test/spec/example asset that maps to no row and carries no reviewed rationale. Internal,
  non-exported behavior is covered by rows that target internal source paths (with an internal marker) and by
  the source-asset completeness check.
- **Row identity**: a behavior row is keyed by `(package, source_path, export, behavior_kind)` (export `null`
  for internal behavior). This survives SHA advances and is the unit the export diff and the release gate
  reason about.
- **Evidence binding**: a row is `verified` only when it names a differential scenario id or an
  upstream-derived test that exists and passes; the check re-runs the named evidence rather than trusting the
  status string. Status is never inferred from a missing Dart path.
- **Fail-closed gate, parity-release only**: `check-release-evidence.mjs` exits non-zero on a `null` verified
  SHA, target > verified, any unproven applicable row, or any unapproved exclusion; it never
  warns-and-continues. It runs only for an explicitly parity-labeled release, and global full parity
  (every applicable row verified, every exclusion approved, no known divergence at one SHA) is required before
  `verified_upstream_sha` can advance.
- **Purity**: `check-purity.mjs` greps `pi_agent/lib` imports against a forbidden-prefix list
  (`package:zuraffa`, `package:zuraffa_agent`, browser packages, product-domain packages) and fails on any
  hit, so the architecture rule is a gate, not a comment.

## Complexity Tracking

No constitutional violations; the table is intentionally empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| _none_    | —          | —                                   |