# Quickstart: Upstream Coverage Governance

How to generate the ledger, read it, run the differential harness, and gate a release. Commands run from the
repository root. Nothing here requires a paid provider, a network call, or a Flutter device.

## 1. Author the behavior registry, then generate the ledger

The behavior registry is the human-reviewed input that declares which behaviors exist; the generator resolves
it against compiler-derived inventories. Public-export enumeration alone cannot construct the ledger.

```bash
# 1. Get the upstream tree at the pinned SHA (the sync does this in CI)
git clone https://github.com/earendil-works/pi.git /tmp/pi-upstream
git -C /tmp/pi-upstream checkout <full-sha>

# 2. Maintain the versioned, human-reviewed registry: one entry per behavior.
#    coverage/registry/behavior-registry.json  — see data-model.md.
#    Every public export and every applicable upstream source/test/spec/example asset
#    must map to a behavior row or carry an explicit reviewed rationale.

# 3. Record the apps/* decisions for this SHA (one entry per apps/* target)
#    coverage/upstream/<sha>/app-decisions.json  — see data-model.md

# 4. Generate (registry + inventories -> manifest + exports/sources/assets inventories)
node scripts/coverage/generate-coverage-manifest.mjs \
  --upstream /tmp/pi-upstream --sha <full-sha> \
  --registry coverage/registry/behavior-registry.json \
  --out coverage/upstream/<sha>

# 5. Render the human report
node scripts/coverage/generate-coverage-report.mjs \
  --manifest coverage/upstream/<sha>/manifest.json
```

Open `coverage/upstream/<sha>/report.md`. Start with the "Not verified" section: every row there names the
missing evidence and the issue that owns it.

## 2. Check the ledger

```bash
node scripts/coverage/check-coverage.mjs --manifest coverage/upstream/<sha>/manifest.json
```

Any failure prints `<row-id>: <reason>`. Fix the row (add evidence, add a rationale and issue, or record an
approved decision) rather than the checker.

## 3. Add or update an app decision

```bash
# coverage/upstream/<sha>/app-decisions.json
{ "path": "apps/p2", "decision": "not_applicable",
  "reason": "…", "approved_by": "arrrrny" }
```

`decision` is one of `port`, `adapt`, `not_applicable`. `not_applicable` needs both a reason and an
approver. A new `apps/*` directory fails the check until it has an entry.

## 4. Run one differential scenario

```bash
node scripts/coverage/differential/run-scenario.mjs \
  --scenario coverage/differential/scenarios/tool-arguments-invalid.json \
  --sha <sha>
```

- Exit 0 → the normalized outcomes match; the result lands in
  `coverage/differential/results/<sha>/tool-arguments-invalid.json` and the named row may move to `verified`.
- Exit 1 → divergence; the diff is printed. The row stays unproven.
- Exit 2 → the scenario could not run (harness error, non-scripted provider). Not a pass.

The same scenario runs against the TypeScript implementation and against the Dart port via
`pi_agent/tool/parity_harness.dart`. To prove the harness can fail, perturb a Dart behavior and re-run: the
divergence must be reported against the row id in the scenario.

## 5. Mark a slice's rows, and advance the verified SHA only at global full parity

A vertical slice marks only its own rows `verified` (by binding passing evidence in the registry and
re-generating). That does **not** advance `verified_upstream_sha` and does not imply full parity.

`verified_upstream_sha` advances only when **full parity holds globally at one SHA**: every applicable row is
`verified`, every exclusion is approved, and no known divergence remains. It may stay `null` until that first
complete baseline exists. `target_upstream_sha` still advances on every sync.

```bash
# coverage/state.json — only when the global condition above holds at one SHA
{ "target_upstream_sha": "<sha>", "verified_upstream_sha": "<sha>",
  "verified_by": "pi#<slice-that-completed-global-parity>" }
```

Then regenerate the manifest and re-run `check-coverage.mjs`. The parity gate itself (`check-release-
evidence.mjs`) runs only in the release workflow — see §6.

## 6. Gate a parity-labeled release (release workflow or explicit dispatch only)

```bash
node scripts/coverage/check-release-evidence.mjs --json
```

This is the full-parity gate. It runs **only** for an explicitly parity-labeled release (the release
workflow, or `workflow_dispatch` with an explicit parity-release input) — never on an ordinary push or
pull-request coverage run, which is intentionally red while known rows are unported.

Exit 0 means the release may call itself a parity claim at the printed `verified_upstream_sha`. Any other
exit code is a release blocker, and the `failures` array names each one (`verified_upstream_sha` is `null`,
target ahead of verified, an unproven row, an unapproved exclusion, a verified SHA not reachable from the
target).

## 7. Purity check

```bash
node scripts/coverage/check-purity.mjs
```

Fails if anything under `pi_agent/lib` imports `zuraffa`, `zuraffa_agent`, a browser package, or
product-domain code. This is the architecture rule from §4 of the plan, made mechanical.

## 8. What the daily sync does for you

After the daily upstream merge, the sync groups changed files by all 12 package areas, files one `dart-port`
issue per affected area (with `Depends on:` lines), and advances `target_upstream_sha` in
`coverage/state.json`. It does **not** advance `verified_upstream_sha`; that moves only at global full parity
(see §5).

The gap between the two SHAs is the honest statement of where the port stands. The report header states it,
and `check-release-evidence.mjs` (parity-labeled release only) prints it:

```bash
node scripts/coverage/check-release-evidence.mjs
# → target <sha> is ahead of verified <sha>; N package areas unresolved
```

## 9. Common tasks

| I want to… | Do this |
| --- | --- |
| See what is not ported | `report.md` → "Not verified" section |
| Know why a row is excluded | That row's `divergence.reason` + `issue` in `manifest.json` |
| Add or change a behavior | Edit `coverage/registry/behavior-registry.json`; an unmapped export/asset fails `check-coverage.mjs` |
| Add a new upstream package area | Extend the pinned area list in `check-coverage.mjs` (deliberate, with the npm name) |
| Add a new differential scenario | Drop a JSON in `coverage/differential/scenarios/`, reference the row ids, generate a golden |
| Prove the harness works | Perturb the Dart behavior; `run-scenario.mjs` must exit 1 |
| Check the boundary | `check-purity.mjs` |