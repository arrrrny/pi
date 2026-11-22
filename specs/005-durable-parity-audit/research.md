# Phase 0 Research: Durable pi Behavioral Parity Audit

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)
**Oracle**: `earendil-works/pi` at `780bf31fcaeb252fa9b68df3964c735eae75bde3` (`@earendil-works/pi-durable` 1.6.0)
**Governance oracle**: [`specs/002-upstream-coverage-governance`](../002-upstream-coverage-governance) (the pi#10
ledger, registry, and release gate)

Every decision below is anchored in a named pi#10 specification section or a named `packages/durable` file at the
target SHA. Where this document and those artifacts disagree, they win and this document is corrected.

## D1 — Grounding rule: pi#10 shapes + upstream inventory, not a second manifest

**Decision**: The audit consumes the pi#10 shapes it finds in
[`specs/002-upstream-coverage-governance/data-model.md`](../002-upstream-coverage-governance/data-model.md):
`coverage/state.json` (target/verified SHA), `coverage/registry/behavior-registry.json` (the human-reviewed
registry), the generated manifest, and the release-evidence check. It adds only the audit-specific shapes in
[this feature's `data-model.md`](./data-model.md) — the audit result, the audit report, the completeness/
conformance/exclusion/purity/evidence sections. The audit never re-derives the upstream export/asset inventory by
hand; it reads the upstream tree at the declared SHA through the same local checkout the sync produces (the same
source pi#10's generator uses).

**Rationale**: A second manifest is exactly what pi#10 exists to prevent. The audit's value is that it is the
single gate that reads the one ledger; a parallel ledger would let the two drift and make "all rows are
`verified`" meaningless. The governance spec (002, FR-010a) is explicit that the registry is the human-reviewed
input and the manifest is generated from it; the audit is the gate that runs at parity time over that pair.

**Alternatives considered**: (a) Re-derive the upstream inventory in the audit — rejected: the pi#10 generator
already does this; duplicating it would drift. (b) Invent a parallel state file — rejected: pi#10's
`coverage/state.json` is the one state contract.

## D2 — Scope boundary: audit, not a third runtime

**Decision**: In scope: the global parity-audit gate (FR-001–FR-007), the upstream export/asset completeness gate
(FR-008–FR-012), the conformance-suite gate (FR-013–FR-017), the exclusion/divergence discipline (FR-018–FR-022),
the purity/no-leakage guard across every surface (FR-023–FR-027), the evidence-discipline rules (FR-028–FR-031),
and the non-duplication rules (FR-032–FR-036). Out of scope: porting any durable behavior (pi#11 and pi#12 own
that); re-implementing the pi#10 registry, manifest, or release gate (the audit consumes them); advancing
`verified_upstream_sha` by declaration (only the audit passing at one SHA does); inventing implementation work
already owned by pi#11/pi#12 (the audit files or names precise follow-up issues).

**Rationale**: The issue is explicit: "Specify and plan the durable-pi behavioral parity umbrella as a final
coverage audit over pi#11 and pi#12, not as a third duplicate runtime implementation." A slice that ported
behavior would be a third runtime; a slice that re-implemented the ledger would be a second manifest. The audit
is the falsifiability layer only.

**Alternatives considered**: (a) Merge the audit into pi#12 — rejected: pi#12 is a runtime slice that correctly
refuses to advance global parity; the audit is the global gate that must be able to fail any slice, including
pi#12. (b) Make the audit a one-time script with no gate — rejected: pi#8 is an epic, not a one-time task; the
audit must run continuously and advance `verified_upstream_sha` only on a complete pass.

## D3 — Conformance suites run, they are not replaced

**Decision**: The audit records and gates the upstream-derived conformance suites — storage (memory, JSONL,
SQLite, including read-only opens, atomic commit receipts, and failure semantics), environment, and any platform
adapter the port claims to support (e.g. the durable code-mode sandbox seam when a real Wasm driver exists). A
Dart-only suite is never a substitute (FR-017, FR-028). A suite the port cannot run because it lacks a platform
adapter is `not_applicable` only with an approved platform reason, and every row that depended on it is not
`verified` (FR-015).

**Rationale**: The architecture plan (§6.4) is explicit that "a passing Dart-only suite is not sufficient
evidence of parity." The pi#10 spec (FR-021) requires the conformance suites to be ported before new backends are
added. The audit is where those two rules become a gate.

**Alternatives considered**: (a) Trust the port's green tests — rejected: that is exactly the false-parity posture
pi#8 exists to end. (b) Run the conformance suites inside the audit and block on their exit code — rejected as the
only mechanism: the suites need their adapters (Node for the upstream storage/env suites), so the audit records
their results and gates on them; a missing result fails the audit.

## D4 — Exclusions are issues, not notes

**Decision**: Every non-`verified` row carries exactly one exclusion (`not_applicable` / `deferred` /
`unverified`) with a non-empty reason, a named owner, and — for `deferred` and `unverified` — an open tracking
issue that states the upstream behavior, upstream coordinate, planned Dart coordinate, blocking reason, and
dependency-order position (FR-018–FR-022). A free-text note is not a gap; an issue is.

**Rationale**: The "strict upstream port only" rule is only as strong as the audit's ability to catch a quiet gap.
An exclusion with a vague reason is how a gap becomes permanent. The audit converts every "we didn't do that" into
an explicit, owned, dependency-ordered issue, which is what makes the epic closeable — or provably not yet
closeable.

**Alternatives considered**: (a) Allow free-text divergence notes — rejected: no one owns them and they never
close. (b) Require an issue for `not_applicable` too — rejected: a platform/scope reason with a named owner is
sufficient for `not_applicable`; `deferred` and `unverified` need an open issue because they represent work that
will be done.

## D5 — Purity covers every surface, including optional and recovery paths

**Decision**: The purity scan covers the entire Dart implementation tree — core, optional environments (the pi#11
`env` port and any platform adapter), extension registries/hooks/wrappers, recovery/replay paths (generation
recovery, tool replay, nested-call reattach, code-mode journal, abort cascade), and the existing
`package:pi/pi.dart` surface. "Optional" and "only on recovery" are not exemptions; an import in either fails
exactly as a core-path import would (FR-026).

**Rationale**: A leak through an optional environment or a recovery path is still a leak, and the architecture
plan (§5.2, §7.3) makes "Zuraffa extends pi through upstream seams, not by editing pi" the load-bearing rule.
The audit is the continuous enforcement of that rule, not a one-time check.

**Alternatives considered**: (a) Scan only the default configuration — rejected: that is where leakage hides.
(b) Scan only `pi_agent/lib` — rejected: the existing `package:pi/pi.dart` surface is also in scope, and an
optional environment outside `lib/src/durable/` is still a surface.

## D6 — Parity is global at one SHA; only a passing audit advances it

**Decision**: Full parity is every applicable durable row `verified`, every exclusion approved, every applicable
conformance suite passed, every upstream export/asset mapped, the purity guard passed, and no known divergence —
all at one declared SHA (FR-002). Only the audit passing at that SHA advances `verified_upstream_sha` to it
(FR-004). No slice advances it; the audit never declares parity from a slice's green rows, from transcript
persistence, from export inventories, or from Dart-only tests (FR-028–FR-031). `target_upstream_sha` continues to
advance on sync independently of the audit.

**Rationale**: This is the pi#10 spec's core invariant (FR-011–FR-015) made executable. A slice that marked its
own rows `verified` and stopped is not at full parity; the audit is the only thing that can say "at SHA X, every
applicable durable row is verified and no divergence remains."

**Alternatives considered**: (a) Let each slice advance `verified_upstream_sha` when its rows are green —
rejected: that is exactly the per-slice parity claim pi#10 forbids. (b) Advance `verified_upstream_sha` on every
sync — rejected: that would claim parity with an unverified newer upstream commit.

## D7 — Testing the audit by perturbation

**Decision**: The audit is tested by perturbation: seed each failure class (a missing row, an unmapped export, an
unmapped asset, a skipped conformance suite, a failed conformance suite, an unapproved exclusion, a closed tracking
issue, a purity violation, a renamed type, a second agent loop, a `verified` row with only a Dart test, a
`verified` row with only an export-inventory match) and assert the audit fails and names the cause; remove the
seed and assert the audit passes. The happy path alone is not a test.

**Rationale**: A gate that has never been seen to fail is not known to work. The perturbation suite is what makes
the audit's `pass` trustworthy; it is the same discipline pi#10 applies to the completeness check ("add an
unmapped export and confirm the check fails").

**Alternatives considered**: (a) Test only the happy path — rejected: a gate must be shown to fail on the
conditions it guards. (b) Depend on a live upstream clone at CI time — rejected: the audit reads the local
checkout at the declared SHA; the perturbation tests use synthetic upstream trees.