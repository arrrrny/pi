# Quickstart: Durable pi Behavioral Parity Audit

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)
**Oracle**: `earendil-works/pi` at `780bf31fcaeb252fa9b68df3964c735eae75bde3` (`@earendil-works/pi-durable` 1.6.0)
**Governance oracle**: [`specs/002-upstream-coverage-governance`](../002-upstream-coverage-governance)

This quickstart shows how to run the audit and read its result. It assumes the pi#10 governance tooling
(`coverage/registry/behavior-registry.json`, the generated manifest, `coverage/state.json`) and the pi#11/pi#12
row sets exist. Where pi#10's generator is unbuilt, the audit consumes the registry shape pi#10's spec defines
and states that dependency explicitly.

## What the audit is

The audit is the final coverage-audit umbrella over pi#11 (durable storage/task foundations) and pi#12 (durable
agent runtime). It is **not** a third runtime. At one declared upstream SHA it proves:

1. every applicable durable behavior row in the pi#10 ledger is `verified`;
2. every upstream `packages/durable` public export and every applicable source/test/spec/example asset maps to a
   row or carries an approved rationale;
3. every storage/backend/environment/platform conformance suite ran and passed (or is `not_applicable` with an
   approved platform reason);
4. every exclusion is approved with a precise, dependency-ordered follow-up issue;
5. the purity/no-leakage guard passed across every surface (core, optional environments, extensions,
   recovery/replay, existing wrappers);
6. no known divergence remains.

Only a passing audit at a single SHA may advance `verified_upstream_sha`. Otherwise it stays unchanged or `null`,
even while `target_upstream_sha` continues to advance on each upstream sync.

## Prerequisites

- The pi#10 registry and manifest exist under `coverage/` (or the audit states the pi#10 dependency and consumes
  the registry shape pi#10's spec defines).
- The upstream tree at the declared SHA is available in the local checkout (the same checkout the daily sync
  produces).
- The recorded conformance-suite results exist under `coverage/conformance/` (storage.memory / storage.jsonl /
  storage.sqlite / env.node / platform.* as applicable).
- Dart SDK ^3.0.0 (the `pi_agent` constraint).

## Run the audit

From the repository root:

```sh
# Full audit at the declared SHA (writes coverage/audit/<sha>/result.json + report.md)
node scripts/audit-durable-parity.mjs --sha 780bf31fcaeb252fa9b68df3964c735eae75bde3

# Dart mirror (typed, testable)
dart run pi_agent/tool/audit/audit_runner.dart --sha 780bf31fcaeb252fa9b68df3964c735eae75bde3

# Incremental audit (single package area)
node scripts/audit-durable-parity.mjs --sha 780bf31fcaeb252fa9b68df3964c735eae75bde3 --area durable

# Parity-labeled release run (the only run that may advance verified_upstream_sha)
node scripts/audit-durable-parity.mjs --sha 780bf31fcaeb252fa9b68df3964c735eae75bde3 --parity-release
```

The audit writes `coverage/audit/<declared-sha>/result.json` (machine-readable) and `report.md`
(human-readable). It never mutates `coverage/state.json` directly; the parity-release run advances
`verified_upstream_sha` only on a `pass` at the declared SHA, per the pi#10 release gate.

## Read the result

The machine-readable result has a single `verdict` (`pass` or `fail`) and a named `causes` set on failure. The
human report states:

- the verdict and the declared SHA;
- the would-be new `verified_upstream_sha` on pass, or the named cause set on fail;
- the conformance-suite results (passed / failed / not_applicable with approved reason);
- the approved exclusions and the remaining gaps as dependency-ordered follow-up issues;
- the surfaces the purity guard scanned and the pass/fail of each;
- the explicit "not parity evidence" boundary (transcript persistence, export inventories, and Dart-only suites
  are not parity evidence).

A `pass` at SHA `S` means: at `S`, every applicable durable row is `verified`, every exclusion is approved, every
applicable conformance suite passed, every upstream export/asset maps to a row or approved rationale, the purity
guard passed, and no divergence remains. That is the only condition under which `verified_upstream_sha` may
advance to `S`.

A `fail` means at least one of those did not hold; the `causes` set names every cause, and `verified_upstream_sha`
stays unchanged or `null`.

## The "not parity evidence" boundary

The audit explicitly does NOT treat the following as parity evidence, and its report says so:

- a Dart `Conversation` that persists transcripts (transcript persistence is not durable-pi parity);
- a complete public-export inventory or a source-file count (an inventory is not a behavior);
- a green Dart-only test suite (necessary at most, never sufficient).

A row marked `verified` whose only evidence is one of these is rejected by the evidence sub-gate and the audit
fails, naming the row. This is the rule that prevents the next slice from quietly re-introducing the posture pi#8
exists to end.

## Test the audit by perturbation

The audit is tested by perturbation — seed each failure class and assert the audit names the cause, then remove
the seed and assert the audit passes:

```sh
# From pi_agent/, with the audit tool's perturbation suite (dart test -j 2 per the fleet cap)
cd pi_agent && dart test -j 2 test/audit/
```

The perturbation suite seeds, among others: a missing row, an unmapped export, an unmapped asset, a skipped
conformance suite, a failed conformance suite, an unapproved exclusion, a closed tracking issue, a purity
violation, a renamed type, a second agent loop, a `verified` row with only a Dart test, and a `verified` row with
only an export-inventory match. Each seed must fail the audit and be named; removing it must pass.

## What this feature does not do

- It does not port durable behavior (pi#11 and pi#12 do).
- It does not re-implement the pi#10 registry, manifest, or release gate (it consumes them).
- It does not advance `verified_upstream_sha` by declaring parity (only the audit passing at one SHA does).
- It does not invent implementation work already owned by pi#11/pi#12 (it files or names precise follow-up
  issues).
- It does not declare parity from transcript persistence, export inventories, or Dart-only tests.
- It does not add a Zuraffa wrapper, a browser integration, an MCP policy, or any product integration.