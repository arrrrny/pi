# Quickstart: Upstream Coverage Governance

How to generate the ledger, read it, run the differential harness, and gate a release. Commands run from the
repository root. Nothing here requires a paid provider, a network call, or a Flutter device.

## 1. Generate the ledger for a pinned SHA

```bash
# 1. Get the upstream tree at the pinned SHA (the sync does this in CI)
git clone https://github.com/earendil-works/pi.git /tmp/pi-upstream
git -C /tmp/pi-upstream checkout <full-sha>

# 2. Record the apps/* decisions for this SHA (one entry per apps/* target)
#    coverage/upstream/<sha>/app-decisions.json  — see data-model.md

# 3. Generate
node scripts/coverage/generate-coverage-manifest.mjs \
  --upstream /tmp/pi-upstream --sha <full-sha> \
  --out coverage/upstream/<sha>

# 4. Render the human report
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

## 5. Advance the verified SHA

Only after the slice's rows pass:

```bash
# coverage/state.json
{ "target_upstream_sha": "<sha>", "verified_upstream_sha": "<sha>",
  "verified_by": "pi#<slice>" }
```

Then regenerate the manifest and re-run `check-coverage.mjs` and `check-release-evidence.mjs`.

## 6. Gate a parity-labeled release

```bash
node scripts/coverage/check-release-evidence.mjs --json
```

Exit 0 means the release may call itself a parity claim at the printed `verified_upstream_sha`. Any other
exit code is a release blocker, and the `failures` array names each one (target ahead of verified, an
unproven row, an unapproved exclusion, a verified SHA not reachable from the target).

## 7. Purity check

```bash
node scripts/coverage/check-purity.mjs
```

Fails if anything under `pi_agent/lib` imports `zuraffa`, `zuraffa_agent`, a browser package, or
product-domain code. This is the architecture rule from §4 of the plan, made mechanical.

## 8. What the daily sync does for you

After the daily upstream merge, the sync groups changed files by all 12 package areas, files one `dart-port`
issue per affected area (with `Depends on:` lines), and advances `target_upstream_sha` in
`coverage/state.json`. It does **not** advance `verified_upstream_sha`; that only moves when a slice passes.

The gap between the two SHAs is the honest statement of where the port stands. Read it in the report header,
or:

```bash
node scripts/coverage/check-release-evidence.mjs
# → target <sha> is ahead of verified <sha>; N package areas unresolved
```

## 9. Common tasks

| I want to… | Do this |
| --- | --- |
| See what is not ported | `report.md` → "Not verified" section |
| Know why a row is excluded | That row's `divergence.reason` + `issue` in `manifest.json` |
| Add a new upstream package area | Extend the pinned area list in `check-coverage.mjs` (deliberate, with the npm name) |
| Add a new differential scenario | Drop a JSON in `coverage/differential/scenarios/`, reference the row ids, generate a golden |
| Prove the harness works | Perturb the Dart behavior; `run-scenario.mjs` must exit 1 |
| Check the boundary | `check-purity.mjs` |