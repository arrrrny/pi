# Feature Specification: Upstream Coverage Governance

**Feature Branch**: `002-upstream-coverage-governance`
**Created**: 2026-11-22
**Status**: Draft
**Input**: GitHub issue [`arrrrny/pi#10`](https://github.com/arrrrny/pi/issues/10) — "dart-port: build full upstream coverage governance"
**Normative reference**: [pi, Zuraffa Agent, and BrowserAgent Architecture Plan](https://github.com/arrrrny/zuraffa_browser/blob/master/handoffs/2026-11-22-pi-zuraffa-browser-agent-architecture-plan.md), §6 (Workstream A — full pi upstream parity)
**Depends on**: none

## Why This Exists

The Dart port under `pi_agent/` is a deliberately slim port: one OpenAI-compatible provider, a subset of
`packages/agent`, and a Dart-native harness that models — rather than ports — durable behavior. The daily
upstream sync reinforces that posture by treating `packages/agent` and `packages/ai` as the only actionable
changes and every other upstream package as "context". Neither the current suite nor the sync can support a
truthful full-parity claim, because nothing states what "full" means, against which upstream commit it is
measured, or what evidence proves a behavior landed.

This feature does not port upstream behavior. It builds the **governance layer** that makes parity claims
falsifiable: a pinned-SHA, machine-readable coverage ledger; a differential harness that runs the same
scripted scenarios against TypeScript and Dart; target-versus-verified SHA governance that gates release
claims; and a coverage-aware sync policy that files per-package porting work with explicit dependencies.
The upstream packages remain the oracle; the Dart implementation moves underneath the ledger one vertical
slice at a time.

## User Scenarios & Testing

### User Story 1 - Machine-Readable Coverage Ledger at a Pinned Upstream SHA (Priority: P1)

A maintainer wants to know, for any given upstream commit, exactly which upstream behaviors are covered by
the Dart port, which are not, and what evidence exists for each. A generated JSON manifest enumerates every
upstream package and public export, and every row carries: the upstream SHA and package version, the source
path and behavior kind, the normative reference (README, spec, test, or example), the Dart entrypoint and
implementation path, the upstream-derived test and the Dart test, supported platforms and adapter
requirements, the verification status, and — for anything not fully ported — a divergence rationale plus a
tracking issue. A companion generated report renders the same ledger for humans. Line counts and file counts
are never used as parity evidence.

**Why this priority**: Every other story depends on this one. Without a shared, pinned inventory there is no
way to say what is covered, so no parity claim can be true or false. It is the foundation the sync, the
differential harness, and the release gate all read.

**Independent Test**: Generate the manifest for a pinned upstream SHA and assert it lists all 12 upstream
package areas plus every upstream `apps/*` entry with an explicit port/adapt/not-applicable decision; assert
every row resolves to a real upstream path at that SHA and to a real or explicitly absent Dart path; assert
every non-`verified` row carries a divergence rationale and an issue reference.

**Acceptance Scenarios**:

1. **Given** a pinned upstream SHA, **When** the manifest is generated, **Then** it inventories `schema`,
   `telemetry`, `chord`, `ai`, `agent`, `durable`, `codemode`, `env`, `mcp`, `coding-agent`, `tui`, and
   `evals`, and each row names its upstream package, source path, public export, and behavior kind.
2. **Given** the same pinned SHA, **When** the manifest is generated, **Then** every upstream `apps/*`
   target receives exactly one of `port`, `adapt`, or `not_applicable`, each with an approved reason.
3. **Given** a row with status `unported`, `in_progress`, or `implemented_unverified`, **When** the human
   report is rendered, **Then** the row shows its missing evidence and its tracking issue, not a checkmark.
4. **Given** the upstream tree changed since the last generation, **When** the export inventory is
   compared, **Then** added, removed, and renamed public exports are reported per package.
5. **Given** the generated artifacts, **When** the generator is re-run unchanged, **Then** the output is
   byte-identical (deterministic ordering, no timestamps in the ledger).

---

### User Story 2 - Target vs Verified SHA Governance and Release Gate (Priority: P1)

A maintainer advances the porting target by syncing upstream, but only claims parity for a SHA they have
actually verified. The system keeps two values — `target_upstream_sha` and `verified_upstream_sha` — and a
generated report shows exactly what lies between them. A parity-labeled release fails when unresolved
changes exist between the two, or when any applicable row is not `verified`, or when any exclusion is not
approved.

**Why this priority**: This is the anti-false-claim mechanism. It converts "we are a Dart port of pi" into
"we match upstream at SHA X, and here is what we have not verified at SHA Y".

**Independent Test**: Point the target at a newer SHA than verified, run the release-evidence check, and
confirm it fails and names every unresolved package/behavior. Mark every applicable row `verified` with an
approved exclusion set and confirm the same check passes and names the exact verified SHA.

**Acceptance Scenarios**:

1. **Given** a `target_upstream_sha` newer than `verified_upstream_sha`, **When** release evidence is
   generated, **Then** the run fails and the report lists each package area and behavior between the two SHAs.
2. **Given** all applicable rows `verified` and every exclusion approved, **When** release evidence is
   generated, **Then** the run succeeds and states the exact `verified_upstream_sha` it verified against.
3. **Given** an unresolved behavioral divergence, **When** release evidence is generated, **Then** the run
   fails even if every other row is green.
4. **Given** release documentation, **When** it states a parity claim, **Then** it names the exact verified
   upstream SHA and never implies parity with a newer upstream commit.
5. **Given** a slice completes, **When** its rows move to `verified`, **Then** `verified_upstream_sha`
   advances only to a SHA at which every applicable row passes.

---

### User Story 3 - Differential Harness Against the TypeScript Oracle (Priority: P1)

A maintainer wants objective evidence that the Dart port behaves like the TypeScript implementation, not
just that Dart tests are green. A differential harness runs the same scripted scenario against both
implementations and compares normalized outcomes: event streams, transcripts, task state, stored commits,
errors, and usage. Scenarios are driven by scripted providers, virtual clocks, storage operations, signals,
and crash points, so no paid live provider is ever a test dependency. Sanitized provider HTTP cassettes
supply request/response and streaming parity. A Dart-only green suite is treated as necessary but not
sufficient.

**Why this priority**: Behavioral parity is the claim; differential evidence is the only credible proof. It
also produces the upstream-derived test evidence that a ledger row needs to become `verified`.

**Independent Test**: Run one scenario (e.g. tool-call failure or a durable commit boundary) against both
implementations and assert the normalized outcomes are identical; then perturb the Dart behavior and assert
the harness reports a divergence.

**Acceptance Scenarios**:

1. **Given** a scripted scenario and a virtual clock, **When** it runs on both implementations, **Then** the
   normalized event stream, transcript, and final state are equal.
2. **Given** a scenario that crosses a durable commit boundary, **When** the process is crashed before and
   after the commit, **Then** replay policy, idempotency, settlement, retry, and restart-limit behavior match
   the TypeScript outcome.
3. **Given** a sanitized provider cassette, **When** both implementations consume it, **Then** request
   shape, streaming deltas, and error mapping normalize to the same golden.
4. **Given** a scenario where the Dart side diverges, **When** the harness runs, **Then** it reports the
   divergence with the row it belongs to, and that row is not `verified`.
5. **Given** the harness, **When** it runs, **Then** no live paid provider call is made (cassettes and
   scripted providers only).

---

### User Story 4 - Coverage-Aware Daily Upstream Sync (Priority: P2)

The daily sync merges upstream TypeScript unchanged, then groups **every** changed source, test, export,
asset, migration, and manifest file by all 12 package areas — not just `agent` and `ai` — and opens or
updates one actionable `dart-port` issue per affected package or vertical slice. Each issue carries explicit
`Depends on: owner/repo#n` declarations where a slice depends on earlier work. The "OpenAI-only provider"
and "other packages are informational" assumptions are removed.

**Why this priority**: Without this, the ledger decays the day after it is generated: upstream moves and the
Dart side silently falls behind. It is the mechanism that turns a snapshot into a maintained invariant.

**Independent Test**: Simulate a sync diff touching a `chord` test, an `ai` export, and a `tui` asset; assert
three per-package porting entries are produced with correct classification and that the OpenAI-only language
is gone from the workflow.

**Acceptance Scenarios**:

1. **Given** an upstream sync that changed files across several package areas, **When** the sync runs,
   **Then** changes are grouped by all 12 package areas and each affected area is reported.
2. **Given** a changed file that is a test, export, asset, migration, or manifest (not just source), **When**
   the sync runs, **Then** it is classified and included in the affected area's porting work.
3. **Given** a package area with new work that depends on another issue, **When** the issue is opened,
   **Then** it carries `Depends on: owner/repo#n` lines.
4. **Given** the sync workflow, **When** it is inspected, **Then** the "OpenAI-compatible-only" and
   "other packages are informational" assumptions are absent, and every changed area is actionable.
5. **Given** an existing open porting issue for an area, **When** a later sync touches that area again,
   **Then** the issue is updated rather than duplicated.

---

### User Story 5 - Explicit Decisions for Upstream Applications (Priority: P2)

Upstream ships applications alongside packages. The maintainer wants each upstream `apps/*` target to carry
an explicit `port`, `adapt`, or `not_applicable` decision with an approved reason, so application-shaped
behavior is never silently omitted from the parity story.

**Why this priority**: Applications are where "full coverage" most easily hides a gap; an explicit decision
forces the conversation instead of leaving a blank.

**Independent Test**: Generate the manifest and assert every `apps/*` entry has exactly one decision and a
reason, and that adding a new upstream app directory without a decision fails the check.

**Acceptance Scenarios**:

1. **Given** upstream `apps/*`, **When** the manifest is generated, **Then** each target has exactly one
   decision (`port`, `adapt`, `not_applicable`) with an approved reason.
2. **Given** a new upstream app directory with no decision, **When** the check runs, **Then** it fails and
   names the undecided target.
3. **Given** a `not_applicable` decision, **When** the human report is rendered, **Then** the reason is
   shown and the decision is visibly approved.

---

### User Story 6 - Leakage and Purity Guard (Priority: P3)

The Dart port must remain a pure port: no implementation imports `zuraffa`, `zuraffa_agent`, a browser
package, or product-domain code. The parity tooling checks this continuously and reports it as a first-class
ledger result, so the boundary stated in the architecture plan is enforced rather than aspirational.

**Why this priority**: It is cheap, mechanical, and protects the architecture that makes the port reusable.
It is a guardrail, so it follows the parity mechanisms it protects.

**Independent Test**: Add an import of a forbidden package under `pi_agent/lib` and assert the check fails
and names the offending file; remove it and assert the check passes.

**Acceptance Scenarios**:

1. **Given** the Dart implementation, **When** the purity check runs, **Then** any import of `zuraffa`,
   `zuraffa_agent`, a browser package, or product-domain code is reported with file and import.
2. **Given** a clean tree, **When** the parity report is generated, **Then** the purity result is recorded as
   passing evidence for the release gate.

---

### Edge Cases

- What happens when the pinned upstream SHA does not exist locally or upstream (shallow clone, force-push)?
- How does the ledger handle a file renamed upstream (export moved) versus deleted?
- What happens when a row is marked `verified` but its Dart test no longer exists or is skipped?
- How does the system handle a package area that upstream removed entirely?
- What happens when an exclusion is approved for one platform but the behavior is applicable on another?
- How does the sync handle a merge conflict (existing behavior: abort, file `sync` issue, fail)?
- What happens when the verified SHA advances but a previously verified row regresses?
- How does the harness handle nondeterministic upstream ordering (events that may legitimately interleave)?
- What happens when a provider cassette is missing for a new provider behavior?
- How does the system treat an `apps/*` target that upstream deletes?

## Requirements

### Functional Requirements

#### Coverage Ledger

- **FR-001**: The system MUST maintain a machine-readable coverage manifest pinned to a single upstream SHA
  and package versions, generated deterministically from the upstream tree.
- **FR-002**: The manifest MUST inventory every upstream package area: `schema`, `telemetry`, `chord`, `ai`,
  `agent`, `durable`, `codemode`, `env`, `mcp`, `coding-agent`, `tui`, and `evals`.
- **FR-003**: Every row MUST carry: upstream SHA and package version, upstream package, source path, public
  export, behavior kind, normative reference (README/spec/test/example), Dart entrypoint, Dart implementation
  path, upstream-derived test, Dart test, supported platforms, and adapter requirements.
- **FR-004**: Every row MUST carry exactly one status: `unported`, `in_progress`, `implemented_unverified`,
  `verified`, or `not_applicable`.
- **FR-005**: Every row that is not `verified` MUST carry a divergence rationale and a tracking issue.
- **FR-006**: Every `not_applicable` row MUST carry an approved platform or scope reason.
- **FR-007**: The system MUST NOT use line counts or file counts as parity evidence.
- **FR-008**: A row is `verified` ONLY when its upstream-derived test evidence passes against the Dart
  implementation at the declared upstream SHA.
- **FR-009**: The manifest MUST be accompanied by a generated human-readable report derived from it.
- **FR-010**: The generator MUST compare public export inventories and JSON schemas per package and report
  added, removed, and renamed exports so upstream additions cannot disappear unnoticed.

#### SHA Governance and Release Gate

- **FR-011**: The system MUST maintain distinct `target_upstream_sha` and `verified_upstream_sha` values.
- **FR-012**: Advancing the target on sync MUST NOT advance the verified SHA; the verified SHA advances only
  after all affected rows pass.
- **FR-013**: The release-evidence check MUST fail when unresolved changes exist between the target and
  verified SHAs, naming every affected package area and behavior.
- **FR-014**: The release-evidence check MUST fail when any applicable row is not `verified` or any
  exclusion is not approved.
- **FR-015**: A parity-labeled release MUST state the exact verified upstream SHA and MUST NOT imply parity
  with an unverified newer upstream commit.

#### Differential and Conformance Verification

- **FR-016**: The system MUST provide a differential harness that runs identical scenarios against the
  TypeScript upstream and the Dart port and compares normalized outcomes.
- **FR-017**: The compared dimensions MUST include event streams, transcripts, task state, stored commits,
  errors, and usage.
- **FR-018**: Scenarios MUST be driven by scripted providers, virtual clocks, storage operations, signals,
  and crash points — never by paid live providers.
- **FR-019**: The harness MUST support sanitised provider HTTP cassettes for request/response and streaming
  parity.
- **FR-020**: The harness MUST crash durable work before and after commit boundaries and verify replay
  policy, idempotency, settlement, retry, and restart-limit behavior.
- **FR-021**: The harness MUST port storage and environment conformance suites before new backends are
  added.
- **FR-022**: A Dart-only green suite MUST NOT be treated as sufficient evidence of parity.

#### Sync Policy

- **FR-023**: The daily sync MUST continue merging upstream TypeScript unchanged and MUST NOT fork-patch
  upstream behavior.
- **FR-024**: The sync MUST group every changed source, test, export, asset, migration, and manifest file by
  all 12 package areas.
- **FR-025**: The sync MUST open or update one actionable `dart-port` issue per affected package or vertical
  slice, each carrying explicit `Depends on: owner/repo#n` declarations where applicable.
- **FR-026**: The sync MUST preserve existing conflict behavior (abort, file a `sync` issue, fail the job)
  and MUST NOT auto-resolve in favour of upstream.
- **FR-027**: The "OpenAI-compatible-only provider" and "other packages are informational" assumptions MUST
  be removed from the sync policy and any documentation that states them.

#### Upstream Applications

- **FR-028**: Every upstream `apps/*` target MUST receive exactly one of `port`, `adapt`, or
  `not_applicable`, with an approved reason; silent omission is not permitted.
- **FR-029**: An undecided upstream application MUST fail the coverage check and name the target.

#### Purity

- **FR-030**: The Dart implementation MUST NOT import `zuraffa`, `zuraffa_agent`, a browser package, or
  product-domain code, and the check MUST run as part of the parity gate.

### Key Entities

- **Upstream Package**: One of the 12 upstream package areas, identified by name and package version at the
  pinned SHA; owns a set of public exports and behaviors.
- **Public Export**: A named entry point an upstream package exposes, with its source path, declaration kind,
  and (optionally) JSON schema; the unit the export inventory diff compares.
- **Behavior Row**: The atomic ledger record. Carries the upstream coordinate (SHA, package, source path,
  export), the normative reference, the Dart coordinate (entrypoint, implementation, tests), platform
  requirements, verification status, divergence rationale, and tracking issue.
- **Coverage Manifest**: The generated, deterministic, machine-readable set of behavior rows for a pinned
  SHA, plus its export inventory and app decisions.
- **Coverage Report**: The generated human-readable rendering of the manifest, grouped by package and status.
- **Target Upstream SHA**: The upstream commit the port aims to match; advanced by sync.
- **Verified Upstream SHA**: The upstream commit at which every applicable row is `verified`; advanced only
  after evidence passes.
- **Divergence Record**: The rationale plus issue for a row that is not fully ported, not applicable, or
  intentionally deferred.
- **Differential Scenario**: A language-neutral scripted case (scripted provider, virtual clock, storage ops,
  signals, crash points) with a normalization contract and a golden outcome.
- **Golden Fixture**: A sanitized, normalized expected outcome shared by both implementations.
- **Porting Issue**: A `dart-port`-labeled GitHub issue for one package area or vertical slice, carrying
  `Depends on:` declarations.
- **Parity Release Evidence**: The release-gate artifact stating the verified SHA, the passing rows, and the
  approved exclusions; its presence is required for any parity-labeled release.

## Success Criteria

### Measurable Outcomes

- **SC-001**: The generated manifest inventories all 12 upstream package areas and every upstream `apps/*`
  target with an explicit decision; zero silent omissions.
- **SC-002**: Re-running the generator on an unchanged pinned SHA produces a byte-identical manifest (no
  diff).
- **SC-003**: Every non-`verified` row has a non-empty divergence rationale and a resolvable issue
  reference; zero rows violate this.
- **SC-004**: The release-evidence check exits non-zero whenever the target SHA is ahead of the verified SHA
  or any applicable row is not `verified`, and names each cause.
- **SC-005**: The differential harness runs each scripted scenario against both implementations with no live
  provider call, and a deliberately perturbed Dart behavior is reported as a divergence.
- **SC-006**: The daily sync groups changes by all 12 package areas (not 3) and files one porting issue per
  affected area with `Depends on:` lines where applicable.
- **SC-007**: A scan of `pi_agent/lib` finds zero imports of `zuraffa`, `zuraffa_agent`, browser packages, or
  product-domain code.
- **SC-008**: The string "OpenAI-compatible-only" and the "other packages are informational" policy no
  longer appear in the sync workflow or its documentation.

## Assumptions

- **Depends on**: none. This is an independent governance task; it does not block the already-filed
  correctness defects (`pi#2`–`pi#7`) or the metadata chore (`pi#9`), and no later slice depends on it except
  `pi#11` (durable storage/task foundation), which lists `pi#10`.
- The normative architecture is the architecture plan linked in the header; where this spec and that plan
  disagree, the plan wins and this spec must be corrected.
- The upstream repository is `earendil-works/pi` at `main`; the pinned SHA is recorded, not implied by a
  branch name.
- The ledger is generated from a local checkout of the pinned upstream tree; no network calls are required to
  regenerate it.
- The Dart port lives under `pi_agent/` and remains one package (`package:pi`) with focused entry libraries;
  this feature governs coverage and does not reorganize the package layout.
- This feature delivers governance tooling, reports, and policy only. It does not port upstream behavior;
  porting proceeds through the per-package `dart-port` issues it files.
- Full parity is a property of an explicit slice at an explicit SHA, not of the whole upstream monorepo; the
  manifest makes the boundary of each claim visible.
- Upstream `apps/*` decisions (`port` / `adapt` / `not_applicable`) require maintainer approval; the tool
  surfaces them, the human decides them.
- Exclusions are approved per platform/scope; an approval on one platform does not imply another.
- The daily sync continues to run on GitHub Actions and keeps its existing conflict handling; this feature
  extends its grouping and issue-filing, not its merge semantics.
- Differential testing is best-effort "wherever practical" per the architecture plan; rows that cannot be
  differentially tested must say so explicitly and carry a rationale, and are not `verified` on that basis.