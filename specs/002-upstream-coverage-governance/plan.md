# Implementation Plan: Upstream Coverage Governance

**Branch**: `002-upstream-coverage-governance` | **Date**: 2026-11-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-upstream-coverage-governance/spec.md`

## Summary

Build the governance layer that makes pi's "Dart port of upstream" claim falsifiable. Four mechanisms, all
driven from a single pinned upstream SHA:

1. **A deterministic coverage generator** (`scripts/coverage/`) that walks a local checkout of upstream
   `earendil-works/pi` at a pinned SHA, enumerates every package's public exports and behaviors, and emits
   `coverage/upstream/<sha>/manifest.json` plus a human `report.md`.
2. **SHA governance** — `coverage/state.json` holds `target_upstream_sha` and `verified_upstream_sha`
   separately; `check-release-evidence.mjs` fails a parity-labeled release when the target is ahead of the
   verified SHA or any applicable row is unproven.
3. **A differential harness** that runs the same scripted scenario (scripted provider, virtual clock,
   sanitized cassettes, crash points) against the TypeScript upstream and the Dart port, normalizes both
   outcomes, and diffs them into goldens under `coverage/differential/`.
4. **A coverage-aware sync** — extend `.github/workflows/sync-upstream.yml` to group every changed file by all
   12 package areas and file one `dart-port` issue per area with `Depends on:` declarations, and delete the
   "OpenAI-compatible-only" / "other packages are informational" assumptions.

No upstream behavior is ported by this feature; it produces the ledger, the harness, and the policy that the
per-package porting slices move against.

## Technical Context

**Language/Version**: TypeScript 5.x tooling on Node >= 22.19 (type-stripping for `.ts` imports, `node:test`);
Dart SDK ^3.0.0 for the port under test
**Primary Dependencies**: dev-only — `typescript` (public-export enumeration via the compiler API),
`esbuild` (bundling the TS differential entry point); Dart side adds no runtime dependency (`dart:io`,
`dart:convert` only)
**Storage**: checked-in JSON/Markdown artifacts under `coverage/` (manifest, report, export inventory, app
decisions, goldens, per-scenario results); no database
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
├── state.json                          # target_upstream_sha, verified_upstream_sha
├── upstream/
│   └── <sha>/                          # immutable, one directory per pinned SHA
│       ├── manifest.json               # behavior rows + export inventory + app decisions
│       ├── exports.json                # public-export inventory (diff source)
│       ├── app-decisions.json          # apps/* → port | adapt | not_applicable + reason
│       └── report.md                   # generated human-readable rendering
└── differential/
    ├── scenarios/<name>.json           # language-neutral scripted scenario
    ├── goldens/<name>.json             # normalized expected outcome
    └── results/<sha>/<name>.json       # actual outcome per implementation

scripts/coverage/
├── generate-coverage-manifest.mjs      # upstream tree → manifest.json
├── generate-coverage-report.mjs        # manifest.json → report.md
├── check-coverage.mjs                  # manifest invariants (rows, reasons, decisions)
├── check-release-evidence.mjs          # target vs verified SHA gate
├── check-purity.mjs                    # no zuraffa/browser/product imports in pi_agent/lib
├── differential/
│   ├── run-scenario.mjs                # scenario → TS run + Dart run → normalized diff
│   └── run-ts.mjs                      # TypeScript side entry (type-stripped import)
├── lib/
│   ├── upstream-tree.mjs               # pinned checkout resolution, package discovery
│   ├── exports.mjs                     # export/schema enumeration (typescript API)
│   ├── normalize.mjs                   # event/transcript/state/commit/error/usage normalizers
│   └── manifest.mjs                    # manifest schema, ordering, hashing
└── *.test.mjs                          # one test file per module

pi_agent/
└── tool/
    └── parity_harness.dart             # dev-only scenario runner; reads JSON, emits normalized JSONL

.github/workflows/
├── sync-upstream.yml                   # extended: 12-area grouping + Depends on: + SHA state
└── coverage.yml                        # new: generate + check + release-evidence gate
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
  parser) and a committed hand-maintained YAML (drifts silently).
- **Export enumeration** — `typescript` compiler API over each package's entry points plus its `exports`
  map. Rejected: regex over barrel files (misses re-exports and type-only exports).
- **Differential transport** — scenario JSON on stdin/argv, normalized JSONL on stdout, per implementation.
  Rejected: a shared FFI or an in-process Dart VM embed (impossible without a Dart embedding API).
- **Normalization** — a single canonical event schema with explicit rules for timestamps, IDs, and
  interleavings. Rejected: byte-comparing raw transcripts (legitimately nondeterministic).
- **SHA state** — a checked-in `state.json`, advanced by the sync and by explicit slice completion, never by
  the generator. Rejected: deriving verified-SHA from git tags (a tag records a merge, not a verification).
- **App decisions** — a checked-in `app-decisions.json` keyed by upstream path, with `not_applicable`
  requiring a reason and an approver. Rejected: inferring from the manifest (silent omission risk).

## Phase 1 — Design

See [data-model.md](./data-model.md) for the entity shapes and
[contracts/coverage-ledger.md](./contracts/coverage-ledger.md) for the file-level contracts, and
[quickstart.md](./quickstart.md) for the operating procedure.

Key design points:

- **Determinism**: the generator sorts every collection by a stable key, excludes timestamps and absolute
  paths from the ledger body, and records the generator + `typescript` versions in a header block. Two runs
  on the same checkout must be byte-identical (SC-002).
- **Row identity**: a behavior row is keyed by `(package, source_path, export, behavior_kind)`. This survives
  SHA advances and is the unit the export diff and the release gate reason about.
- **Evidence binding**: a row is `verified` only when it names a differential scenario id or an
  upstream-derived test that exists and passes; the check re-runs the named evidence rather than trusting the
  status string.
- **Fail-closed gate**: `check-release-evidence.mjs` exits non-zero on target > verified, any unproven
  applicable row, or any unapproved exclusion; it never warns-and-continues.
- **Purity**: `check-purity.mjs` greps `pi_agent/lib` imports against a forbidden-prefix list
  (`package:zuraffa`, `package:zuraffa_agent`, browser packages, product-domain packages) and fails on any
  hit, so the architecture rule is a gate, not a comment.

## Complexity Tracking

No constitutional violations; the table is intentionally empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| _none_    | —          | —                                   |