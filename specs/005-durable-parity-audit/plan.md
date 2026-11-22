# Implementation Plan: Durable pi Behavioral Parity Audit

**Branch**: `005-durable-parity-audit` | **Date**: 2026-11-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/005-durable-parity-audit/spec.md`

## Summary

Define the **global parity-audit gate** that closes the durable-pi parity epic (arrrrny/pi#8) as a final coverage
audit over pi#11 (`003-durable-storage-task-foundations`) and pi#12 (`004-durable-agent-runtime-parity`) — not as a
third runtime implementation. The audit is the falsifiability layer: at one declared upstream SHA
(`780bf31fcaeb252fa9b68df3964c735eae75bde3`), it proves that every applicable durable behavior row in the pi#10
ledger is `verified`, that every upstream `packages/durable` public export and every applicable source/test/spec/
example asset maps to a row or carries an approved rationale, that every storage/backend/environment/platform
conformance suite ran and passed, that every exclusion is approved with a precise dependency-ordered follow-up
issue, that the purity/no-leakage guard passed across every surface (core, optional environments, extensions,
recovery/replay, existing wrappers), and that no known divergence remains. Only a passing audit at a single SHA
may advance `verified_upstream_sha`; otherwise it stays unchanged or `null` while `target_upstream_sha` continues
to advance on sync.

The audit is built on the pi#10 governance tooling (`specs/002-upstream-coverage-governance`): it consumes the
registry (`coverage/registry/behavior-registry.json`), the generated manifest, and the release gate's SHA-state
contract (`coverage/state.json`). Where pi#10's generator and release gate are unbuilt when this slice runs, the
audit consumes the registry shape pi#10's spec defines and states the pi#10 dependency explicitly rather than
inventing a second manifest format.

The audit ports no durable behavior and adds no `pi_agent/lib/src/durable/**` runtime code beyond the audit
tooling itself. It is a strict upstream-port audit: every type, function, and rule it defines is grounded in a
named pi#10 spec section, the upstream `packages/durable` source/test/spec/example inventory at the target SHA, or
the architecture plan. No Zuraffa entities, no browser concepts, no MCP policy, no renamed runtime model, no second
agent loop, no speculative convenience API.

## Technical Context

**Language/Version**: Dart SDK ^3.0.0 (the existing `pi_agent` constraint) for the audit tooling; the conformance
runner contract is language-neutral JSON per the pi#10 data-model. The audit uses only erasable Dart and
`dart:async`, `dart:convert`, `dart:io`, plus the pi#10 governance tooling once built.
**Primary Dependencies**: none added to `pi_agent`'s runtime. The audit reads the pi#10 registry, the upstream tree
at the target SHA (via the local checkout), the Dart implementation tree, and the recorded conformance-suite
results. It may invoke the upstream conformance suites (Node) as a recorded step; it does not replace them.
**Storage**: reads the pi#10 `coverage/` artifacts and `coverage/state.json`; writes `coverage/audit/<sha>/` result
+ human report. The conformance-suite results are recorded under `coverage/conformance/`.
**Testing**: the audit is itself tested by perturbation — seed a missing row, an unmapped export, a skipped
conformance suite, an unapproved exclusion, a purity violation, and a Dart-only "verified" row, and assert the
audit fails and names the cause; remove each and assert the audit passes. No paid provider.
**Target Platform**: pure Dart VM; the conformance suites run where their adapters exist (Node for the upstream
storage/env suites; a platform adapter for the durable code-mode sandbox seam when a real Wasm driver exists).
**Project Type**: a new audit tool inside the existing monorepo, under `scripts/` (governance tooling) with its
Dart mirror under `pi_agent/tool/audit/` and its output under `coverage/audit/`; the existing `package:pi/durable.dart`
surface is untouched.
**Performance Goals**: a full audit at one SHA completes within a `dart test` default timeout when the conformance
suites are cached; an incremental audit (single package area) completes in under a minute.
**Constraints**: no Zuraffa/browser/product imports (purity gate, including optional and recovery surfaces); no
renamed or invented runtime API; no second agent loop; no mutation of the pi#11/pi#12 runtime; forward-only
artifacts-only commits; no paid provider calls; `Depends on: arrrrny/pi#12` preserved verbatim.
**Scale/Scope**: the audit spans the pi#10 registry (~hundreds of rows across 12 package areas once generated),
the `packages/durable` tree at the target SHA (~120 source/test/spec/example files), the Dart implementation tree,
and the conformance-suite result set. The audit tool itself is small; the value is the gate.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` is the unfilled scaffold (every section still carries `[PLACEHOLDER]`), so there
are no project-specific gates. Checked against the hard rules in `AGENTS.md`:

- **Artifacts only, explicit paths** — automation commits stage `specs/005-durable-parity-audit/` only; never
  `git add -A`.
- **No Zuraffa/browser/product imports** — enforced as a check across every surface, including optional environments
  and recovery paths; a forbidden import fails the audit.
- **No renamed or invented API, no second agent loop** — the audit's own type names are grounded in the pi#10
  data-model and the architecture plan; a name with no upstream/pi#10 source, or any second model or durable loop,
  is a defect.
- **No `any`, no runtime checks on typed values** — the audit is typed Dart; JSON is validated only at the registry
  and wire trust boundaries (decoded registry, decoded conformance results), exactly where the pi#10 data-model
  validates it.
- **Pin the oracle** — every audit row records upstream SHA `780bf31f…` and package version 1.6.0; the audit
  result names the declared SHA.
- **Test concurrency cap** — `dart test -j 2` in every documented command.
- **No changelog entry** — this slice adds governance tooling, not a `packages/*` upstream source change; the
  `pi_agent/CHANGELOG.md` entry is added under `## [Unreleased]` only if `pi_agent` is versioned by this work.
- **No Zuraffa generation** — `zfa` is not applicable: the audit is hand-written governance over a hand-written
  port, not a Zuraffa application.

**Verdict**: PASS — no constitutional violations. No row in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/005-durable-parity-audit/
├── plan.md                     # This file
├── research.md                 # Phase 0 — decisions and rationale
├── data-model.md               # Phase 1 — audit types, upstream source, and contracts
├── quickstart.md               # Phase 1 — how to run and validate the audit
├── contracts/
│   ├── completeness.md         # Phase 1 — upstream export/asset completeness gate
│   ├── conformance.md          # Phase 1 — storage/backend/environment/platform conformance gate
│   ├── exclusions.md           # Phase 1 — exclusion and divergence discipline
│   └── purity.md               # Phase 1 — no-leakage and purity guard
└── checklists/
    └── requirements.md         # Spec quality checklist
```

### Source Code (repository root)

```text
scripts/
└── audit-durable-parity.mjs    # Phase 1 — governance-tooling entry (reads registry, runs checks, writes result)

pi_agent/
├── tool/
│   └── audit/                  # Phase 1 — Dart mirror of the audit tool (typed, testable)
│       ├── audit_runner.dart   #   orchestrates completeness + conformance + exclusions + purity
│       ├── completeness.dart   #   export/asset inventory diff vs registry
│       ├── conformance.dart    #   reads recorded conformance-suite results
│       ├── exclusions.dart     #   exclusion approval + follow-up-issue checks
│       └── purity.dart         #   forbidden-import / rename / second-loop scan
└── test/
    └── audit/                  # Phase 1 — perturbation tests (seed each failure, assert named cause)

coverage/
├── state.json                  # pi#10 — target/verified SHA state (consumed, not rewritten except by the gate)
├── registry/                   # pi#10 — behavior registry (consumed)
├── conformance/                # Phase 1 — recorded conformance-suite results (storage/env/platform)
└── audit/                      # Phase 1 — audit results (machine-readable + human report), per declared SHA
```

**Structure Decision**: The audit is governance tooling, not runtime. Its entry lives under `scripts/` (alongside
the other governance scripts) with a typed Dart mirror under `pi_agent/tool/audit/` so it is testable and
reusable; its output lives under `coverage/audit/` beside the pi#10 ledger. The existing
`package:pi/durable.dart` and `package:pi/pi.dart` surfaces are untouched. The audit reads the upstream tree at
the target SHA through the local checkout (the same checkout the sync produces) and the pi#10 registry/manifest;
it does not re-derive the upstream inventory by hand.

## Phase 0 — Research

See [research.md](./research.md). Decisions that shape the build:

- **Oracle and grounding** — every audit rule is derived from a named pi#10 spec section or a named
  `packages/durable` file at the target SHA. The upstream `packages/durable/docs/spec.md` is normative for the
  durable runtime; the pi#10 `data-model.md` is normative for the registry, manifest, and state shapes. Rejected:
  inventing a second manifest or auditing from the README.
- **Build on pi#10, do not re-derive it** — the registry, the generated manifest, and the SHA-state contract are
  consumed as committed. This slice adds only the audit gate, the conformance-runner contract, the exclusion
  discipline, and the purity guard. Rejected: re-porting pi#10's generator or inventing a parallel state file.
- **Conformance suites run, they are not replaced** — the audit records and gates the upstream-derived storage,
  environment, and platform conformance suites; it does not reimplement them. A Dart-only suite is never a
  substitute (FR-017, FR-028). Rejected: asserting conformance from the port's own green tests.
- **Exclusions are issues, not notes** — every non-`verified` row carries an approved exclusion with a non-empty
  reason, a named owner, and an open, precise, dependency-ordered follow-up issue. Rejected: free-text divergence
  notes that no one owns.
- **Purity covers every surface** — the scan covers core, optional environments, extensions, recovery/replay, and
  the existing wrappers; "optional" and "recovery-only" are not exemptions (FR-026). Rejected: a purity check
  scoped to the default configuration.
- **Parity is global at one SHA** — only the audit passing at a single SHA advances `verified_upstream_sha`; no
  slice does, and the audit never declares parity from a slice's green rows, from transcript persistence, from
  export inventories, or from Dart-only tests (FR-028–FR-031). Rejected: per-slice parity claims.
- **Testing** — the audit is tested by perturbation: seed each failure class and assert the audit names the cause;
  remove the seed and assert the audit passes. Rejected: testing only the happy path.

## Phase 1 — Design

See [data-model.md](./data-model.md) for the audit types and their pi#10/upstream sources,
[contracts/completeness.md](./contracts/completeness.md), [contracts/conformance.md](./contracts/conformance.md),
[contracts/exclusions.md](./contracts/exclusions.md), [contracts/purity.md](./contracts/purity.md), and
[quickstart.md](./quickstart.md) for the validation procedure.

Key design points:

- **Type mapping** — the audit result is a tagged union (`pass` | `fail` with named causes) mirroring the pi#10
  release-evidence shape; an exclusion is a tagged union (`not_applicable` | `deferred` | `unverified`) with a
  non-empty reason, a named owner, and a tracking issue; a conformance-suite result is a tagged union
  (`passed` | `failed` | `not_applicable` with approved reason).
- **Completeness** — derive the export and asset inventories at the declared SHA from the local checkout (the
  same source pi#10's generator uses), diff each item against the registry, and fail on any item with no row and
  no approved `unmapped_rationales` entry.
- **Conformance gate** — read the recorded conformance-suite results under `coverage/conformance/`; fail on any
  suite that did not run, was skipped without an approved reason, or failed; mark a suite `not_applicable` only
  with an approved platform reason and ensure its dependent rows are not `verified`.
- **Exclusion discipline** — for every non-`verified` row, require an approved exclusion with a non-empty reason,
  a named owner, and an open tracking issue; for every remaining gap, require a precise follow-up issue stating
  the upstream behavior, coordinate, planned Dart coordinate, blocking reason, and dependency position.
- **Purity guard** — scan every surface for forbidden imports, renamed/invented types, and a second agent loop;
  record the surfaces scanned as passing evidence.
- **Evidence discipline** — reject a `verified` row whose only evidence is a Dart-only test, an export-inventory
  match, a source-file count, or a transcript-persistence demonstration; state the boundary in the human report.

## Complexity Tracking

No constitutional violations; the table is intentionally empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| _none_    | —          | —                                   |