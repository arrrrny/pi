# Feature Specification: Durable pi Behavioral Parity Audit

**Feature Branch**: `005-durable-parity-audit`
**Created**: 2026-11-22
**Status**: Draft
**Input**: GitHub issue [`arrrrny/pi#8`](https://github.com/arrrrny/pi/issues/8) — "dart-port: achieve behavioral parity with upstream pi-durable", the final coverage-audit umbrella over [`arrrrny/pi#11`](https://github.com/arrrrny/pi/issues/11) (durable storage/task foundations) and [`arrrrny/pi#12`](https://github.com/arrrrny/pi/issues/12) (durable agent runtime)
**Normative reference**: [pi, Zuraffa Agent, and BrowserAgent Architecture Plan](https://github.com/arrrrny/zuraffa_browser/blob/master/handoffs/2026-11-22-pi-zuraffa-browser-agent-architecture-plan.md), §2.1, §6 (Workstream A — full pi upstream parity), §6.6 (slices 6–7)
**Upstream oracle**: `earendil-works/pi` at commit `780bf31fcaeb252fa9b68df3964c735eae75bde3` (`@earendil-works/pi-durable` 1.6.0 and every other `packages/*` area it covers)
**Depends on**: arrrrny/pi#12

## Why This Exists

The two prior durable slices build the runtime; neither of them, and nothing else, is allowed to declare full parity.
`003-durable-storage-task-foundations` (pi#11) ported the substrate — schema, telemetry, chord, env, the Session's
atomic commits, typed documents and conversations, the task runtime, and the storage backends under one conformance
suite. `004-durable-agent-runtime-parity` (pi#12) ported the durable agent — generation, tool calls, submissions,
inboxes, extensions, signals, parks, nested calls, approvals, subagents, ownership/abort, compaction, views, usage,
provider identity, and durable code mode. Both slices correctly refuse to advance `verified_upstream_sha` and to
imply full parity: each marks only its own rows and links every remaining gap to its tracking issue.

What is missing is the **audit that proves those two slices, together, actually cover the durable runtime** — and that
continues to prove it as upstream moves. Without an explicit, executable audit, three things go wrong. First, the
coverage ledger can silently drift: a new public export or source asset lands upstream and no behavior row claims it,
so a hole in the port is invisible. Second, the storage, environment, and backend conformance suites can be skipped
without anyone noticing, so a backend that passes its own Dart tests but fails the upstream conformance contract is
treated as done. Third, exclusions and divergences can accumulate without an explicit, reviewed rationale, so the
"strict upstream port only" rule quietly erodes into "mostly a port" and full parity becomes an untestable claim.

This feature is **not a third runtime implementation**. It ports no durable behavior. It defines the **global
parity-audit gate** that (a) proves every applicable durable behavior row in the pi#10 ledger is mapped — every
upstream `packages/durable` public export and every applicable upstream source/test/spec/example asset either maps to
a row or carries an explicit reviewed rationale; (b) proves every storage/backend/platform conformance suite passes
against the Dart implementation; (c) requires an explicit, reviewed exclusion rationale for every behavior the port
does not implement or does not differentially test; and (d) turns every remaining gap into a precise, dependency-
ordered follow-up issue — not a free-text note — so the umbrella epic can be closed honestly or left open with a
falsifiable finish line.

The audit is the **falsifiability layer** of pi#8. It is the only thing that can advance `verified_upstream_sha`,
and it advances that value only when, at one declared SHA, every applicable durable row is `verified`, every
exclusion is approved, every conformance suite passes, and no known divergence remains. Anything short of that
complete condition leaves `verified_upstream_sha` unchanged or `null`, even while `target_upstream_sha` continues to
advance on each upstream sync. The audit also runs the purity and no-leakage guard continuously, and explicitly
declines to treat transcript persistence, export inventories, or Dart-only tests as parity evidence.

## User Scenarios & Testing

### User Story 1 - Global Parity-Audit Gate at One Declared SHA (Priority: P1)

A maintainer wants to know whether, at a single declared upstream SHA, the Dart port is in full behavioral parity with
`@earendil-works/pi-durable` 1.6.0 and every other package area this epic covers. The audit reads the pi#10
coverage ledger and the registry it was generated from, the upstream source/test/spec/example inventories at the
declared SHA, the Dart implementation tree, and the conformance-suite run records, and produces a single machine-
readable audit result. The result is `pass` only when, at that one SHA: every applicable durable behavior row is
`verified`; every non-`verified` row has an explicit approved exclusion or a divergence-with-tracking-issue; every
upstream `packages/durable` public export and every applicable source/test/spec/example asset maps to a row or carries
an explicit reviewed rationale; every storage, backend, environment, and platform conformance suite ran and passed;
the purity/no-leakage guard passed; and no known divergence remains. Otherwise the result is `fail` with the exact
cause set — a non-`verified` row without an approved exclusion, an unmapped upstream asset, a conformance suite that
did not pass, an unapproved exclusion, a purity violation, or a remaining divergence — each named. `pass` is the only
thing that may advance `verified_upstream_sha` to the declared SHA; `fail` leaves `verified_upstream_sha` unchanged
or `null`.

**Why this priority**: This is the entire point of the umbrella epic. Everything else — the conformance runner, the
gap-filing, the purity guard — is in service of producing this one falsifiable verdict. A partial runtime without a
global gate is exactly the false-parity posture the governance spec (002) was written to prevent.

**Independent Test**: At a SHA where pi#11 and pi#12 have marked their rows `verified` but a single applicable row
is `in_progress` with no approved exclusion, run the audit and assert it fails, naming that row. Add an upstream
public export with no behavior row and no reviewed rationale and assert the audit fails, naming the unmapped export.
Add an unmapped upstream source asset and assert the audit fails, naming the asset. Mark every applicable row
`verified` with every exclusion approved and every conformance suite passing and assert the audit passes and would
advance `verified_upstream_sha` to the declared SHA.

**Acceptance Scenarios**:

1. **Given** pi#11 and pi#12 have marked their rows `verified` at SHA `S` but one applicable durable row is still
   `in_progress` without an approved exclusion, **When** the audit runs at `S`, **Then** it fails, names that row,
   and leaves `verified_upstream_sha` unchanged or `null`.
2. **Given** a new public export landed upstream at `S` with no behavior row and no reviewed rationale, **When** the
   audit runs, **Then** it fails and names the unmapped export and its upstream path.
3. **Given** an upstream `packages/durable` source, test, spec, or example asset at `S` that no row claims and that
   carries no reviewed rationale, **When** the audit runs, **Then** it fails and names the unmapped asset.
4. **Given** every applicable durable row `verified` at `S`, every exclusion approved, every conformance suite
   passing, the purity guard passing, and no known divergence, **When** the audit runs, **Then** it passes, names `S`
   as the new `verified_upstream_sha`, and may advance that value.
5. **Given** `verified_upstream_sha` is `null` and the audit fails, **When** the human report is rendered, **Then**
   it states that no verified baseline exists and lists every row, export, asset, suite, exclusion, and divergence
   that must be resolved to reach one.
6. **Given** the target SHA advanced on sync to `S+1` while `verified_upstream_sha` remains at `S` (or `null`),
   **When** the audit runs at `S`, **Then** it evaluates parity at `S` only and states that the target is ahead; it
   never implies parity at `S+1`.
7. **Given** an ordinary push or pull-request coverage run, **When** it executes, **Then** it runs the audit in its
   full `fail`-with-causes mode (intentionally red while rows are unported) but does NOT advance
   `verified_upstream_sha`; only a parity-labeled release run may advance it, per the pi#10 release gate.

---

### User Story 2 - Upstream Asset Completeness: Every Export and Applicable Asset Maps (Priority: P1)

A maintainer wants the audit to prove that nothing upstream escaped the ledger. The audit derives, at the declared
SHA, the public-export inventory of `packages/durable` (and any other package area the epic covers) and the source,
test, spec, and example asset inventory, and checks each one against the registry: every public export maps to at
least one behavior row or carries an explicit reviewed rationale; every applicable upstream source/test/spec/example
asset maps to at least one row or carries an explicit reviewed rationale. An unmapped item — a new export, a new
source file, a new test, a new example — fails the audit and is named with its upstream path and declaration kind.
An asset the registry explicitly marks `not_applicable` with an approved scope/platform reason is not a failure; an
asset with no decision at all is.

**Why this priority**: This is how a slice silently falls behind upstream. The pi#10 generator already diffs the
export inventory; the audit is the gate that runs that diff at parity time and refuses to pass when the ledger has
no home for a new upstream thing. Without it, "all rows are `verified`" can be true while a brand-new upstream
behavior is unported and invisible.

**Independent Test**: Add a synthetic new export to the upstream tree at the declared SHA and assert the audit fails
with the export name; add a matching behavior row and assert it passes. Add a synthetic new upstream source file with
no row and assert the audit fails with the file path; add the row and assert it passes. Mark an asset
`not_applicable` with an approved reason and assert the audit passes; mark it with no reason and assert the audit
fails.

**Acceptance Scenarios**:

1. **Given** a public export at the declared SHA with no behavior row and no reviewed rationale, **When** the audit
   runs, **Then** it fails and names the export and its declaration kind.
2. **Given** an applicable upstream source, test, spec, or example asset at the declared SHA with no behavior row
   and no reviewed rationale, **When** the audit runs, **Then** it fails and names the asset path.
3. **Given** an upstream asset the registry marks `not_applicable` with an approved scope or platform reason,
   **When** the audit runs, **Then** it passes for that asset and reports the approval.
4. **Given** an upstream asset with no registry decision at all, **When** the audit runs, **Then** it fails and
   names the undecided asset.
5. **Given** a re-run of the audit on an unchanged SHA and an unchanged registry, **When** it produces its result,
   **Then** the result is byte-identical (deterministic ordering, no timestamps in the audit body).

---

### User Story 3 - Conformance-Suite Gate: Storage, Backend, Platform, Environment (Priority: P1)

A maintainer wants the audit to prove that the Dart port actually passes the upstream conformance suites — not just
the port's own Dart tests. The audit runs, or reads the recorded results of, the upstream-derived storage
conformance suite (memory, JSONL, SQLite, including read-only opens, atomic commit receipts, and failure semantics),
the environment conformance suite, and any platform adapter the port claims to support (e.g. the durable code-mode
sandbox seam, when a real Wasm driver exists). A conformance suite that did not run, was skipped without an approved
reason, or failed fails the audit. The audit does not accept a Dart-only test suite as a substitute: a behavior that
has a conformance suite upstream must be proven against that suite, and a row that cannot be (because the port has no
platform adapter for it yet) must say so explicitly, carry an approved platform/scope rationale, and not be
`verified`.

**Why this priority**: The conformance suites are the upstream contract for storage, environment, and platform
behavior. A port that passes its own tests but skips the conformance suite can be green locally and wrong against
upstream. The audit is the only thing that ties the two together and refuses to call it parity.

**Independent Test**: Disable the JSONL conformance suite in the Dart run and assert the audit fails, naming the
missing suite. Re-enable it and assert the audit passes for that suite. Run a conformance suite that fails on a
seeded defect and assert the audit fails, naming the failing assertion. Mark a suite `not_applicable` with an
approved platform reason (no adapter yet) and assert the audit passes for that suite and the corresponding rows are
not `verified`.

**Acceptance Scenarios**:

1. **Given** the storage conformance suite (memory/JSONL/SQLite, read-only, commit receipts, failure semantics),
   **When** it ran and passed, **Then** the audit records the suite as passing.
2. **Given** a storage, environment, or platform conformance suite that did not run, was skipped without an approved
   reason, or failed, **When** the audit runs, **Then** it fails and names the suite and the reason.
3. **Given** a conformance suite the port cannot run because it lacks a platform adapter, **When** the suite is
   marked `not_applicable` with an approved platform reason, **Then** the audit passes for that suite and every row
   that depended on it is not `verified`.
4. **Given** a conformance suite that passes, **When** the corresponding row is checked, **Then** the row may be
   `verified` only if its differential evidence also passed; a conformance pass alone does not make a row
   `verified` for behavior the differential harness also covers.

---

### User Story 4 - Exclusion and Divergence Discipline (Priority: P1)

A maintainer wants every behavior the port does not implement, does not differentially test, or implements but has
not verified to carry an explicit, reviewed, machine-checkable rationale and a tracking issue — not a free-text note
in a row. An exclusion is one of: `not_applicable` (approved platform/scope reason), `deferred` (approved scope
reason + tracking issue), or `unverified` (implemented but no passing evidence yet + tracking issue). An exclusion is
approved only when its reason is non-empty, its owner is named, and — for `deferred` and `unverified` — its tracking
issue exists and is open. An unapproved exclusion, or a non-`verified` row with no exclusion at all, fails the audit.
Every remaining gap has a precise follow-up issue: the issue states the exact upstream behavior, the upstream
coordinate, the planned Dart coordinate, the blocking reason, and its position in the dependency order, so the
umbrella epic's finish line is falsifiable rather than "someday".

**Why this priority**: The "strict upstream port only" rule is only as strong as the audit's ability to catch a
quiet gap. An exclusion with a vague reason is how a gap becomes permanent. The audit converts every "we didn't do
that" into an explicit, owned, dependency-ordered issue, which is what makes the epic closeable — or provably not
yet closeable.

**Independent Test**: Remove a row's divergence rationale and tracking issue and assert the audit fails, naming the
row. Add an exclusion with an empty reason and assert the audit fails. Add a `deferred` exclusion whose tracking
issue is closed and assert the audit fails. Add a `deferred` exclusion with an open tracking issue that names the
upstream behavior, coordinate, Dart coordinate, and dependency position and assert the audit passes for that row.

**Acceptance Scenarios**:

1. **Given** a non-`verified` row with no divergence rationale and no tracking issue, **When** the audit runs,
   **Then** it fails and names the row.
2. **Given** an exclusion with an empty or vague reason, an unnamed owner, or a missing/closed tracking issue,
   **When** the audit runs, **Then** it fails and names the exclusion.
3. **Given** a `deferred` or `unverified` exclusion with an open tracking issue that states the upstream behavior,
   upstream coordinate, planned Dart coordinate, blocking reason, and dependency-order position, **When** the audit
   runs, **Then** it passes for that row and reports the exclusion as approved.
4. **Given** a row marked `not_applicable` without an approved scope or platform reason, **When** the audit runs,
   **Then** it fails and names the row.
5. **Given** the audit's gap report, **When** a maintainer reads it, **Then** every remaining gap is a precise
   follow-up issue (not a note), dependency-ordered, and linked to its owner slice.

---

### User Story 5 - No-Leakage and Purity Guard, Including Optional Environments and Extension Surfaces (Priority: P1)

A maintainer wants the audit to prove the Dart port remained a strict pi port: no Zuraffa entities, no browser
concepts, no MCP policy, no product-domain code, no renamed or invented runtime model, no second agent loop — and no
leakage through optional environments or extension/recovery surfaces. The audit scans the entire Dart implementation
tree, including the optional-environment seam (the pi#11 `env` port and any platform adapter), every extension
registry/hook/wrapper surface, every recovery and replay path (generation recovery, tool replay, nested-call
reattach, code-mode journal, abort cascade), and the existing `package:pi/pi.dart` surface, and asserts zero imports
of `zuraffa`, `zuraffa_agent`, a browser package, or product-domain code, and zero renamed/invented runtime types
or second agent loop. A leak in any of these surfaces — even an optional environment not in the default config, even
an extension hook that only fires on a non-default path — fails the audit and is named with file and import. The
guard does not weaken for optional or recovery surfaces: "optional" and "only on recovery" are exactly where
leakage hides.

**Why this priority**: The port's value is that it is a faithful port. A leak through an optional environment or a
recovery path is still a leak, and the architecture plan (§5.2, §7.3) makes "Zuraffa extends pi through upstream
seams, not by editing pi" the load-bearing rule. The audit is the continuous enforcement of that rule, not a
one-time check.

**Independent Test**: Add an import of `zuraffa` under an optional-environment file and assert the audit fails,
naming the file. Add an import of a browser package under a recovery path and assert the audit fails. Add a renamed
runtime type (a new name for an upstream concept) and assert the audit fails. Remove the import and the rename and
assert the audit passes. Mount an extension hook that would leak a product type on a non-default path and assert
the audit still fails.

**Acceptance Scenarios**:

1. **Given** the Dart implementation tree, **When** the purity scan runs across every surface (core, optional
   environments, extensions, recovery/replay, existing wrappers), **Then** zero imports of `zuraffa`,
   `zuraffa_agent`, browser packages, or product-domain code are found.
2. **Given** a renamed or invented runtime type (a new name for an upstream concept), **When** the no-rename scan
   runs, **Then** it fails and names the type and the upstream concept it renames.
3. **Given** a second agent loop or a parallel runtime model, **When** the no-second-loop scan runs, **Then** it
   fails and names the loop or model.
4. **Given** an optional environment or a recovery-only code path that imports a forbidden package, **When** the
   purity scan runs, **Then** it fails exactly as a core-path import would.
5. **Given** a clean tree, **When** the audit passes, **Then** the purity result is recorded as passing evidence for
   the parity gate and names the surfaces it scanned.

---

### User Story 6 - Audit Does Not Declare Parity from Transcript Persistence, Export Inventories, or Dart-Only Tests (Priority: P1)

A maintainer wants the audit to be honest about what is not evidence. The audit explicitly does NOT treat the
existence of a Dart `Conversation` that persists transcripts as durable-pi parity; it does not treat a complete
public-export inventory or a source-file count as parity; and it does not treat a green Dart-only test suite as
parity. These are necessary-at-most, never sufficient. The audit states this boundary in its own output, so a
reader of the human report cannot mistake "the Dart harness persists a transcript" or "the export inventory matches"
for "we are at full parity". A row that is `verified` only because a Dart test is green, without the upstream-
derived differential evidence the pi#10 schema requires, is rejected.

**Why this priority**: The original issue is explicit that transcript persistence is not parity, that export
inventories are not parity, and that a passing Dart-only suite is not sufficient. The audit is the mechanism that
enforces those statements as a gate rather than a hope. Without it, the next slice can quietly re-introduce the
exact posture pi#8 exists to end.

**Independent Test**: Mark a row `verified` whose only evidence is a green Dart test with no upstream-derived
differential reference and assert the audit fails, naming the row. Mark a row `verified` whose evidence is an export
inventory match and assert the audit fails. Remove the differential reference from an otherwise-passing row and
assert the audit fails.

**Acceptance Scenarios**:

1. **Given** a row marked `verified` whose only evidence is a green Dart-only test with no upstream-derived
   differential reference, **When** the audit runs, **Then** it fails and names the row.
2. **Given** a row marked `verified` whose only evidence is an export-inventory match or a source-file count,
   **When** the audit runs, **Then** it fails and names the row.
3. **Given** a Dart `Conversation` that persists transcripts but no differential evidence, **When** the audit
   runs, **Then** it does not count that as a `verified` row and states that transcript persistence is not parity.
4. **Given** the audit's human report, **When** a maintainer reads it, **Then** it states explicitly that
   transcript persistence, export inventories, and Dart-only suites are not parity evidence, and lists the
   rows that would be falsely claimed as parity under that mistake.

---

### Edge Cases

- **Upstream deleted a package area entirely.** The audit's completeness check treats the deleted area as
  `not_applicable` with an approved "upstream removed" rationale; an area with no registry decision fails.
- **A row was `verified` at an earlier SHA but its Dart test no longer exists or is skipped.** The audit fails,
  naming the row; a `verified` row must point to a present, passing Dart test and a present upstream-derived
  differential reference at the declared SHA.
- **A previously verified row regresses after `verified_upstream_sha` advanced.** The audit at the new SHA fails,
  naming the regressed row; `verified_upstream_sha` is not advanced to the new SHA until the regression is resolved.
- **A conformance suite is `not_applicable` on one platform but applicable on another.** The audit treats the
  platform scope per the registry's platform key; an `not_applicable` on one platform does not excuse the suite on
  another.
- **A provider cassette is missing for a new provider behavior.** The row is not `verified`; it carries an
  `unverified` exclusion with an open tracking issue naming the missing cassette.
- **The audit is run at a SHA that does not exist locally (shallow clone, force-push).** The audit fails with
  "upstream SHA not resolvable" rather than guessing; the sync's existing conflict behavior is unchanged.
- **The target SHA advanced on sync but the audit is asked to verify the older SHA.** The audit evaluates parity at
  the declared SHA only and states that the target is ahead; it never implies parity at the newer SHA.
- **An optional environment is disabled by default but its code is shipped.** The purity scan still covers it;
  "optional" is not an exemption.
- **A recovery path is rarely taken but is reachable.** The purity scan still covers it; "recovery-only" is not an
  exemption.
- **A nested call or code-mode replay reattaches across a crash.** The differential evidence for the parent row
  must include the reattach scenario; the audit does not count a row `verified` if the reattach evidence is
  missing.
- **An extension hook fires only on a non-default configuration.** The purity scan and the differential evidence
  must cover the non-default path; the audit does not count the hook row `verified` on the default path alone.

## Requirements

### Functional Requirements

#### Global Parity-Audit Gate

- **FR-001**: The system MUST provide an audit that, at one declared upstream SHA, produces a single machine-
  readable result (`pass` or `fail`) plus a human-readable report, from the pi#10 coverage ledger and registry, the
  upstream source/test/spec/example and export inventories at the declared SHA, the Dart implementation tree, and
  the recorded conformance-suite results.
- **FR-002**: The audit MUST pass only when, at the declared SHA: every applicable durable behavior row is
  `verified`; every non-`verified` row has an approved exclusion or an open tracking issue; every applicable
  upstream public export and source/test/spec/example asset maps to a row or carries an approved rationale; every
  applicable storage, backend, environment, and platform conformance suite ran and passed; the purity/no-leakage
  guard passed; and no known divergence remains.
- **FR-003**: The audit MUST fail, and name every cause, when: any applicable row is not `verified` without an
  approved exclusion; any upstream export or applicable asset is unmapped and carries no approved rationale; any
  applicable conformance suite did not run, was skipped without approval, or failed; any exclusion is unapproved
  (empty/vague reason, unnamed owner, or missing/closed tracking issue); any purity violation exists; or any
  divergence remains.
- **FR-004**: `verified_upstream_sha` MUST advance to the declared SHA only when the audit passes at that SHA;
  otherwise it stays unchanged or `null`. `target_upstream_sha` continues to advance on sync independently of the
  audit and MUST NOT be held back by a failing audit.
- **FR-005**: The full-parity audit gate (the run that may advance `verified_upstream_sha`) MUST run only for an
  explicitly parity-labeled release (the release workflow, or `workflow_dispatch` with an explicit parity-release
  input), per the pi#10 release gate. Ordinary push and pull-request coverage runs MUST run the audit in its full
  `fail`-with-causes mode (intentionally red while rows are unported) but MUST NOT advance `verified_upstream_sha`.
- **FR-006**: The audit MUST be deterministic: a re-run on an unchanged declared SHA and an unchanged registry
  produces a byte-identical machine-readable result (stable ordering, no timestamps in the audit body).
- **FR-007**: The audit MUST evaluate parity at the declared SHA only and MUST NOT imply parity at the (possibly
  ahead) target SHA; when the target is ahead, the report states the gap.

#### Upstream Asset Completeness

- **FR-008**: The audit MUST derive, at the declared SHA, the public-export inventory and the source/test/spec/
  example asset inventory of `packages/durable` (and any other package area the epic covers) and check each item
  against the registry.
- **FR-009**: Every public export MUST map to at least one behavior row or carry an explicit approved rationale; an
  unmapped export MUST fail the audit and be named with its declaration kind and upstream path.
- **FR-010**: Every applicable upstream source, test, spec, or example asset MUST map to at least one behavior row
  or carry an explicit approved rationale; an unmapped asset MUST fail the audit and be named with its upstream
  path.
- **FR-011**: An upstream asset the registry marks `not_applicable` with an approved scope or platform reason is
  not a failure; an asset with no registry decision at all is a failure and is named as undecided.
- **FR-012**: The completeness check MUST treat a package area upstream deleted entirely as `not_applicable` with
  an approved "upstream removed" rationale; an area with no decision is a failure.

#### Conformance-Suite Gate

- **FR-013**: The audit MUST require, and record the results of, the upstream-derived storage conformance suite
  (memory, JSONL, SQLite — including read-only opens, atomic commit receipts, and failure semantics), the
  environment conformance suite, and any platform adapter the port claims to support (e.g. the durable code-mode
  sandbox seam when a real Wasm driver exists).
- **FR-014**: A conformance suite that did not run, was skipped without an approved reason, or failed MUST fail the
  audit, naming the suite and the reason.
- **FR-015**: A conformance suite the port cannot run because it lacks a platform adapter MUST be marked
  `not_applicable` with an approved platform reason; every row that depended on that suite MUST NOT be `verified`.
- **FR-016**: A conformance-suite pass alone MUST NOT make a row `verified` for behavior the differential harness
  also covers; the row's `verified` status requires its upstream-derived differential evidence per the pi#10
  schema.
- **FR-017**: The audit MUST NOT accept a Dart-only test suite as a substitute for an applicable upstream
  conformance suite or upstream-derived differential evidence.

#### Exclusion and Divergence Discipline

- **FR-018**: Every non-`verified` row MUST carry exactly one exclusion kind: `not_applicable` (approved
  platform/scope reason), `deferred` (approved scope reason + open tracking issue), or `unverified` (implemented
  but no passing evidence yet + open tracking issue).
- **FR-019**: An exclusion MUST be approved only when its reason is non-empty, its owner is named, and — for
  `deferred` and `unverified` — its tracking issue exists and is open.
- **FR-020**: A non-`verified` row with no exclusion, an unapproved exclusion, or a closed tracking issue MUST fail
  the audit, naming the row.
- **FR-021**: Every remaining gap MUST have a precise follow-up issue that states: the exact upstream behavior, the
  upstream coordinate (SHA + path), the planned Dart coordinate, the blocking reason, and its position in the
  dependency order. A free-text note is not a gap; an issue is.
- **FR-022**: The audit's gap report MUST list every remaining gap as a dependency-ordered, owned follow-up issue,
  so the umbrella epic's finish line is falsifiable.

#### No-Leakage and Purity Guard

- **FR-023**: The audit MUST scan the entire Dart implementation tree — core, optional environments, extension
  registries/hooks/wrappers, recovery/replay paths (generation recovery, tool replay, nested-call reattach,
  code-mode journal, abort cascade), and the existing `package:pi/pi.dart` surface — for imports of `zuraffa`,
  `zuraffa_agent`, browser packages, or product-domain code, and MUST fail on any such import, naming file and
  import.
- **FR-024**: The audit MUST scan for renamed or invented runtime types (a new name for an upstream concept) and
  MUST fail on any, naming the type and the upstream concept it renames.
- **FR-025**: The audit MUST scan for a second agent loop or a parallel runtime model and MUST fail on any, naming
  the loop or model.
- **FR-026**: The purity guard MUST NOT weaken for optional environments or recovery-only paths; "optional" and
  "only on recovery" are not exemptions, and an import in either fails exactly as a core-path import would.
- **FR-027**: A clean-tree purity result MUST be recorded as passing evidence for the parity gate and MUST name
  the surfaces it scanned.

#### Evidence Discipline

- **FR-028**: The audit MUST reject a row marked `verified` whose only evidence is a green Dart-only test with no
  upstream-derived differential reference.
- **FR-029**: The audit MUST reject a row marked `verified` whose only evidence is an export-inventory match, a
  source-file count, or a transcript-persistence demonstration.
- **FR-030**: The audit's human report MUST state explicitly that transcript persistence, export inventories, and
  Dart-only suites are not parity evidence, and MUST list any rows that would be falsely claimed as parity under
  that mistake.
- **FR-031**: The audit MUST NOT treat a Dart `Conversation` that persists transcripts as a `verified` durable
  behavior row absent the upstream-derived differential evidence the pi#10 schema requires.

#### Scope and Non-Duplication

- **FR-032**: This feature MUST NOT port durable behavior. It defines the audit gate, the conformance runner
  contract, the gap-filing discipline, and the purity guard. It consumes the pi#10 ledger, registry, and release
  gate, and the pi#11 and pi#12 row sets; it does not re-implement any of them.
- **FR-033**: This feature MUST NOT advance `verified_upstream_sha` by declaring parity; only the audit passing at
  a single SHA advances it, per FR-002 and FR-004.
- **FR-034**: This feature MUST preserve the `Depends on: arrrrny/pi#12` declaration verbatim and MUST NOT add a
  Zuraffa wrapper, a browser integration, an MCP policy, or any product integration.
- **FR-035**: This feature MUST NOT invent implementation work already owned by pi#11 or pi#12; where it identifies
  a gap, it files or names the precise follow-up issue per FR-021, leaving implementation to that issue's owner.
- **FR-036**: This feature MUST NOT declare parity from transcript persistence, export inventories, or Dart-only
  tests, per FR-028–FR-031.

### Key Entities

- **Audit Result**: The machine-readable `pass`/`fail` verdict for one declared upstream SHA, with the named cause
  set on failure and the would-be new `verified_upstream_sha` on pass.
- **Audit Report**: The human-readable rendering of the audit result: the verdict, the verified SHA, the failing
  causes (if any), the conformance-suite results, the approved exclusions, the remaining gaps as dependency-ordered
  issues, and the explicit "not parity evidence" boundary.
- **Behavior Row**: One durable behavior's pi#10 ledger record (upstream coordinate, export or internal marker,
  normative reference, Dart coordinate, tests, status, divergence, tracking issue). Owned by pi#11/pi#12; the audit
  reads it, does not write it.
- **Coverage Ledger**: The pi#10 generated manifest the audit reads; it carries the row set, the export/source
  inventories, and the app decisions.
- **Upstream Export Inventory**: The compiler-derived set of public exports at the declared SHA, per package; the
  unit the completeness check diffs against the registry.
- **Upstream Asset Inventory**: The set of applicable source, test, spec, and example files at the declared SHA,
  per package; the unit the completeness check diffs against the registry.
- **Conformance-Suite Result**: The recorded pass/fail (or `not_applicable` with approved reason) of one
  upstream-derived conformance suite (storage memory/JSONL/SQLite, environment, platform adapter).
- **Exclusion**: A non-`verified` row's approved reason it is not `verified`: `not_applicable`, `deferred`, or
  `unverified`, each with a non-empty reason, a named owner, and (for `deferred`/`unverified`) an open tracking
  issue.
- **Follow-up Issue**: A precise, dependency-ordered GitHub issue for one remaining gap, stating the upstream
  behavior, coordinate, planned Dart coordinate, blocking reason, and dependency position.
- **Purity Guard Result**: The named set of surfaces the audit scanned (core, optional env, extensions,
  recovery/replay, existing wrappers) and the pass/fail of each, recorded as parity evidence.
- **Verified Upstream SHA**: The upstream commit at which the audit passed globally (every applicable row verified,
  every exclusion approved, every conformance suite passed, no known divergence); `null` until the first such pass.
- **Target Upstream SHA**: The upstream commit the port aims to match; advanced by sync, independent of the audit.

## Success Criteria

### Measurable Outcomes

- **SC-001**: The audit passes at a SHA if and only if every applicable durable row is `verified`, every exclusion
  is approved, every applicable conformance suite passed, every upstream export and applicable asset maps to a row
  or approved rationale, the purity guard passed across every surface, and no divergence remains; otherwise it
  fails and names every cause.
- **SC-002**: `verified_upstream_sha` advances to the declared SHA only on a passing audit at that SHA and stays
  unchanged or `null` on any failure; `target_upstream_sha` is never held back by a failing audit.
- **SC-003**: An upstream public export or applicable source/test/spec/example asset with no behavior row and no
  approved rationale fails the audit and is named with its declaration kind and upstream path.
- **SC-004**: A storage, backend, environment, or platform conformance suite that did not run, was skipped without
  approval, or failed fails the audit and is named; a suite the port cannot run is `not_applicable` only with an
  approved platform reason, and its dependent rows are not `verified`.
- **SC-005**: A non-`verified` row with no exclusion, an unapproved exclusion, or a closed tracking issue fails the
  audit and is named; a `deferred`/`unverified` exclusion with an open, precise, dependency-ordered follow-up
  issue passes.
- **SC-006**: A scan of the entire Dart implementation tree across core, optional environments, extensions,
  recovery/replay, and existing wrappers finds zero imports of `zuraffa`, `zuraffa_agent`, browser packages, or
  product-domain code, zero renamed/invented runtime types, and zero second agent loop; the guard does not weaken
  for optional or recovery-only paths.
- **SC-007**: The audit rejects a row whose only evidence is a green Dart-only test, an export-inventory match, a
  source-file count, or a transcript-persistence demonstration, and its human report states that these are not
  parity evidence.
- **SC-008**: A re-run of the audit on an unchanged declared SHA and registry produces a byte-identical machine-
  readable result.
- **SC-009**: The audit evaluates parity at the declared SHA only and never implies parity at the (possibly ahead)
  target SHA; when the target is ahead, the report states the gap.
- **SC-010**: Every remaining gap in the audit's report is a precise, dependency-ordered follow-up issue with a
  non-empty upstream behavior, coordinate, planned Dart coordinate, blocking reason, and dependency position;
  zero free-text-only gaps.

## Assumptions

- **Depends on**: arrrrny/pi#12 — preserved verbatim. pi#12 (and its foundation pi#11) own the row sets, the
  ledger, and the runtime the audit reads; this feature adds no behavior and no runtime. Where pi#10's generator
  and release gate are unbuilt at the time this slice runs, the audit consumes the registry shape pi#10's spec
  defines (`coverage/registry/behavior-registry.json` per
  `specs/002-upstream-coverage-governance/data-model.md`) and states that dependency explicitly rather than
  inventing a second manifest format.
- **Target SHA**: `780bf31fcaeb252fa9b68df3964c735eae75bde3`, the upstream commit every durable package
  (`durable`, and the `agent`/`ai`/`codemode`/`schema`/`telemetry`/`chord`/`env` areas it covers) is read at. Those
  package trees are byte-identical between that commit and this checkout's `HEAD`, so the audit reads the target
  SHA's content.
- **Normative reference wins**: the architecture plan linked in the header is normative; where this spec and that
  plan disagree, the plan wins and this spec is corrected.
- **Strict upstream port only**: this feature ports no durable behavior. It is an audit, a conformance-runner
  contract, a gap-filing discipline, and a purity guard. No Zuraffa entities, no browser concepts, no MCP policy,
  no renamed runtime model, no second agent loop, no speculative convenience API. `zfa` is not applicable: this
  is a hand-written audit over a hand-written port, not a Zuraffa application.
- **Scope boundary**: this feature defines the global parity-audit gate, the conformance-suite runner contract, the
  exclusion/divergence discipline, the purity/no-leakage guard (including optional environments and extension/
  recovery surfaces), and the evidence-discipline rules. It consumes the pi#10 ledger/registry/release gate and the
  pi#11/pi#12 row sets; it does not re-implement any of them and does not port durable behavior.
- **No duplicate runtime**: this feature is the umbrella's falsifiability layer, not a third runtime. It adds no
  `pi_agent/lib/src/durable/**` runtime code beyond the audit tooling itself; the runtime remains pi#11 + pi#12.
- **Audit advances global parity, never a slice**: only the audit passing at one SHA advances
  `verified_upstream_sha`; no slice advances it, and this feature is the only thing that may.
- **Conformance evidence is mandatory**: the audit does not accept a Dart-only test suite as a substitute for an
  applicable upstream conformance suite or upstream-derived differential evidence; a row that cannot be
  differentially tested says so explicitly, carries an approved `unverified` exclusion with an open tracking issue,
  and is not `verified`.
- **Optional and recovery surfaces are in scope**: the purity guard and the evidence discipline cover optional
  environments, extension registries/hooks/wrappers, and recovery/replay paths exactly as core paths; "optional"
  and "only on recovery" are not exemptions.
- **Parity is global at one SHA**: full parity is every applicable durable row verified, every exclusion approved,
  every applicable conformance suite passed, every upstream export/asset mapped, the purity guard passed, and no
  known divergence — all at one declared SHA. A slice's verification is not global parity, and this feature never
  declares parity from a slice's green rows alone.
- **Forward-only artifacts-only commits**: automation stages `specs/005-durable-parity-audit/` only; never
  `git add -A`, never force-push, never rewrite shared history.