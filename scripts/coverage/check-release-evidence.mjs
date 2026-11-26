#!/usr/bin/env node
/**
 * Full-parity release gate — parity-labeled release only (contracts §4).
 *
 * Runs ONLY for an explicitly parity-labeled release (the release workflow, or
 * `workflow_dispatch` with an explicit parity-release input). Ordinary push /
 * pull-request coverage runs MUST NOT run this; they run `check-coverage.mjs`
 * instead, which is intentionally red while known rows are unported.
 *
 * Reads `coverage/state.json` and the manifest for `verified_upstream_sha`
 * (and the target's, for the gap). Fails (exit 1) when any of:
 *   - `verified_upstream_sha` is null;
 *   - `verified_upstream_sha` is not an ancestor of `target_upstream_sha`;
 *   - target != verified and unresolved changes exist between them;
 *   - any applicable row is not verified;
 *   - any exclusion is not approved, or any known divergence remains.
 *
 * On success, prints the release-evidence object (including the exact verified
 * SHA) and exits 0. `--json` emits the object only.
 *
 * Usage:
 *   node scripts/coverage/check-release-evidence.mjs [--json]
 */

import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { resolve } from "node:path";

import { parseArgs } from "./lib/cli.mjs";
import { readJsonIfExists } from "./lib/upstream-tree.mjs";

const ROOT = resolve(fileURLToPath(new URL("..", import.meta.url)), "..", "..");

const VALID_DECISIONS = ["port", "adapt", "not_applicable"];

/**
 * PI-PAR-009 (arrrrny/pi#47): the adaptation-decision gate.
 *
 * "Full parity" must never be claimed while a TUI behavior row or an upstream
 * apps/* target lacks an evidence-backed adaptation decision. This reads the
 * human-reviewed `coverage/adaptation-decisions.json` (one entry per TUI row
 * and per app) plus the manifest's own `app_decisions`, and returns a failure
 * string for every surface that is undecided, malformed, or unapproved.
 *
 * A TUI decision is evidence-backed when it names a `decision`
 * (port|adapt|not_applicable), an `owner`, and either a `destination` package
 * (port/adapt) or a non-empty `evidence` reason (not_applicable). An app is
 * decided when its manifest entry carries an approved decision.
 */
export function checkAdaptationDecisions(manifest) {
	const failures = [];
	const adaptation = readJsonIfExists("coverage/adaptation-decisions.json");
	const decisions = Array.isArray(adaptation?.decisions) ? adaptation.decisions : null;
	if (!decisions) {
		failures.push("adaptation-decisions: coverage/adaptation-decisions.json is missing or has no decisions array");
	} else {
		const seen = new Set();
		for (const entry of decisions) {
			const coordinate = entry?.coordinate ?? "(unknown)";
			if (seen.has(coordinate)) failures.push(`adaptation-decisions: duplicate entry for ${coordinate}`);
			seen.add(coordinate);
			if (!VALID_DECISIONS.includes(entry?.decision)) {
				failures.push(`adaptation-decisions: ${coordinate} has no port/adapt/not_applicable decision`);
				continue;
			}
			if (!entry.owner) failures.push(`adaptation-decisions: ${coordinate} has no owner`);
			if (entry.decision === "not_applicable") {
				if (!entry.evidence) failures.push(`adaptation-decisions: ${coordinate} not_applicable requires an evidence reason`);
			} else if (!entry.destination) {
				failures.push(`adaptation-decisions: ${coordinate} ${entry.decision} requires a destination package`);
			}
		}
		// Every TUI behavior row in the manifest must carry a decision entry,
		// and every TUI decision must map back to a live row: renaming or
		// removing a row must not leave an orphan decision that passes silently.
		if (manifest) {
			const tuiRowIds = new Set(
				manifest.rows.filter((row) => row.area === "tui").map((row) => row.id),
			);
			for (const row of manifest.rows) {
				if (row.area === "tui" && !seen.has(row.id)) {
					failures.push(`adaptation-decisions: tui row ${row.id} has no recorded decision`);
				}
			}
			for (const entry of decisions) {
				if (entry?.area === "tui" && !tuiRowIds.has(entry?.coordinate)) {
					failures.push(`adaptation-decisions: tui decision ${entry?.coordinate ?? "(unknown)"} has no matching manifest row`);
				}
			}
		}
	}

	// Apps: every apps/* target in the manifest must carry an approved decision.
	// Completeness of app_decisions itself is the generator's job at the pinned
	// SHA (it reconfirms the apps/* set), so an empty or partial list is accepted
	// here by design — this gate only validates the entries it is given.
	if (manifest) {
		for (const app of manifest.app_decisions ?? []) {
			if (!VALID_DECISIONS.includes(app?.decision)) {
				failures.push(`adaptation-decisions: app ${app?.path ?? "(unknown)"} has no port/adapt/not_applicable decision`);
				continue;
			}
			if (app.decision !== "port" && !app.reason) {
				failures.push(`adaptation-decisions: app ${app.path} ${app.decision} requires a reason`);
			}
			if (app.decision === "not_applicable" && !app.approved_by) {
				failures.push(`adaptation-decisions: app ${app.path} not_applicable requires an approval`);
			}
		}
	}

	return failures;
}

function isAncestor(ancestor, descendant) {
	if (ancestor === descendant) return true;
	try {
		execFileSync("git", ["-C", ROOT, "merge-base", "--is-ancestor", ancestor, descendant], { stdio: "ignore" });
		return true;
	} catch {
		return false;
	}
}

function buildEvidence() {
	const state = readJsonIfExists("coverage/state.json");
	const targetSha = state?.target_upstream_sha ?? null;
	const verifiedSha = state?.verified_upstream_sha ?? null;
	const manifestPath = verifiedSha ? `coverage/upstream/${verifiedSha}/manifest.json` : null;
	const manifest = manifestPath ? readJsonIfExists(manifestPath) : null;

	const failures = [];
	if (!state) {
		failures.push("coverage/state.json is missing");
	}
	if (verifiedSha === null || verifiedSha === undefined) {
		failures.push("verified_upstream_sha is null: no complete parity baseline exists");
	}
	if (state && verifiedSha && targetSha) {
		if (!isAncestor(verifiedSha, targetSha)) {
			failures.push(`verified_upstream_sha ${verifiedSha} is not an ancestor of target_upstream_sha ${targetSha}`);
		}
		if (verifiedSha !== targetSha) {
			failures.push(
				`target_upstream_sha ${targetSha} is ahead of verified_upstream_sha ${verifiedSha}; unresolved upstream changes remain`,
			);
		}
	}

	let rowsTotal = 0;
	let rowsVerified = 0;
	let rowsNotApplicableApproved = 0;
	if (manifest) {
		rowsTotal = manifest.rows.length;
		for (const row of manifest.rows) {
			if (row.status === "verified") rowsVerified += 1;
			if (row.status === "not_applicable") {
				const approved = row.divergence && typeof row.divergence === "object" ? row.divergence.approved_by : row.approved_by;
				if (approved) rowsNotApplicableApproved += 1;
				else failures.push(`exclusion ${row.id} is not approved`);
			}
			if (row.status === "unported" || row.status === "in_progress" || row.status === "implemented_unverified") {
				failures.push(`row ${row.id} is ${row.status}; global full parity requires every applicable row verified`);
			}
			if (row.status === "verified" && (!row.evidence || (!row.evidence.scenario && !row.dart_test))) {
				failures.push(`verified row ${row.id} has no resolvable evidence`);
			}
		}
	} else if (verifiedSha) {
		failures.push(`no manifest at coverage/upstream/${verifiedSha}/manifest.json for the verified sha`);
	}

	// PI-PAR-009 (arrrrny/pi#47): no full-parity claim while a TUI row or an
	// apps/* target lacks an evidence-backed adaptation decision.
	failures.push(...checkAdaptationDecisions(manifest));

	const resolved = failures.length === 0;
	return {
		schema_version: 1,
		verified_upstream_sha: verifiedSha ?? null,
		target_upstream_sha: targetSha,
		resolved,
		rows_total: rowsTotal,
		rows_verified: rowsVerified,
		rows_not_applicable_approved: rowsNotApplicableApproved,
		failures,
	};
}

function main() {
	const args = parseArgs(process.argv.slice(2));
	const evidence = buildEvidence();
	if (args.json) {
		console.log(JSON.stringify(evidence, null, 2));
	} else {
		console.log(`verified_upstream_sha: ${evidence.verified_upstream_sha ?? "null"}`);
		console.log(`target_upstream_sha:   ${evidence.target_upstream_sha ?? "null"}`);
		console.log(`rows: ${evidence.rows_verified}/${evidence.rows_total} verified, ${evidence.rows_not_applicable_approved} approved exclusions`);
		if (evidence.resolved) {
			console.log(`parity claim verified at ${evidence.verified_upstream_sha}`);
		} else {
			for (const failure of evidence.failures) console.error(`  ${failure}`);
			console.error(`release evidence: ${evidence.failures.length} failure(s)`);
		}
	}
	process.exit(evidence.resolved ? 0 : 1);
}

main();