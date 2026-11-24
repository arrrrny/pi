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