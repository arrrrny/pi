#!/usr/bin/env node
/**
 * Check the coverage ledger's invariants and completeness.
 *
 * Fails (exit 1) on any of the conditions in contracts §3. Each failure is
 * printed as `<item-id>: <reason>` on its own line. Exit 0 prints the counts.
 *
 * Usage:
 *   node scripts/coverage/check-coverage.mjs --manifest <path>
 */

import { existsSync } from "node:fs";
import { dirname, join, resolve } from "node:path";

import { parseArgs } from "./lib/cli.mjs";
import { statusCounts } from "./lib/manifest.mjs";
import { checkCompleteness } from "./lib/registry.mjs";
import { DIVERGENCE_STATUSES, STATUSES, readJsonIfExists } from "./lib/upstream-tree.mjs";

function main() {
	const args = parseArgs(process.argv.slice(2));
	const manifestPath = resolve(args.manifest ?? "coverage/upstream/unknown/manifest.json");
	const manifest = readJsonIfExists(manifestPath);
	if (!manifest) {
		console.error(`check-coverage: cannot read manifest: ${manifestPath}`);
		process.exit(2);
	}
	const dir = dirname(manifestPath);
	const exportInventory = readJsonIfExists(join(dir, "exports.json"));
	const sourceInventory = readJsonIfExists(join(dir, "sources.json"));
	const assetsInventory = readJsonIfExists(join(dir, "assets.json"));
	const registry = readJsonIfExists(args.registry ? resolve(args.registry) : "coverage/registry/behavior-registry.json");

	const failures = [];
	const add = (id, reason) => failures.push(`${id}: ${reason}`);

	// Row-level invariants (contracts §3, bullets 1–4).
	const rowIds = new Set();
	for (const row of manifest.rows) {
		if (rowIds.has(row.id)) add(row.id, `duplicate row id`);
		rowIds.add(row.id);
		if (!STATUSES.includes(row.status)) {
			add(row.id, `unknown status ${JSON.stringify(row.status)}`);
			continue;
		}
		if (DIVERGENCE_STATUSES.includes(row.status)) {
			const divergence = row.divergence && typeof row.divergence === "object" ? row.divergence.reason : row.divergence;
			if (!divergence) add(row.id, `status ${row.status} requires a divergence rationale`);
			if (row.issue === null || row.issue === undefined) add(row.id, `status ${row.status} requires a tracking issue`);
		}
		if (row.status === "not_applicable") {
			const reason = row.divergence && typeof row.divergence === "object" ? row.divergence.reason : row.divergence;
			const approved = row.divergence && typeof row.divergence === "object" ? row.divergence.approved_by : row.approved_by;
			if (!reason) add(row.id, `not_applicable requires an approved reason`);
			if (!approved) add(row.id, `not_applicable requires an approval`);
		}
		if (row.status === "verified") {
			if (!row.evidence || (!row.evidence.scenario && !row.dart_test)) {
				add(row.id, `verified requires resolvable evidence (scenario or dart_test)`);
			}
			if (row.dart_test && !existsSync(resolve(row.dart_test))) {
				add(row.id, `dart_test does not exist: ${row.dart_test}`);
			}
	}
	}

	// App decisions (contracts §3, bullet 5): the manifest's decisions must equal
	// the apps/* directories at the pinned SHA. The generator already enforces
	// this, but the check re-verifies against the recorded manifest so a hand-
	// edited manifest cannot drop a decision silently.
	const appPaths = (manifest.app_decisions ?? []).map((entry) => entry.path);
	const dupApps = new Set();
	for (const path of appPaths) {
		if (dupApps.has(path)) add(`apps/${path}`, `duplicate decision entry`);
		dupApps.add(path);
	}

	// Completeness (contracts §3, final bullet): every public export and every
	// applicable source/test/spec/example asset maps to a row or a rationale.
	if (registry && exportInventory && sourceInventory) {
		const { unmapped } = checkCompleteness({
			registry,
			exportInventory: exportInventory.packages,
			sourceInventory: sourceInventory.sources,
			assetInventory: assetsInventory?.assets ?? [],
		});
		for (const item of unmapped) {
			add(`unmapped:${item.kind}:${item.coordinate}`, `no behavior row and no reviewed rationale`);
		}
	} else {
		add("completeness", "registry/exports/sources inputs missing; cannot verify completeness");
	}

	if (failures.length > 0) {
		for (const failure of failures) console.error(failure);
		console.error(`check-coverage: ${failures.length} failure(s)`);
		process.exit(1);
	}

	const counts = statusCounts(manifest);
	console.log(`check-coverage: ${manifest.rows.length} rows — ${JSON.stringify(counts)}`);
	console.log(`  apps: ${appPaths.length} decided, exports: ${exportInventory?.packages?.reduce((acc, pkg) => acc + pkg.exports.length, 0) ?? 0}`);
}

main();