#!/usr/bin/env node
/**
 * Render the human-readable coverage report from a manifest.
 *
 * Pure function of `manifest.json` (no clock, no tree access). Writes
 * `report.md` beside the manifest. Sections: header (SHA, generator version),
 * per-package status table, a "Not verified" section (one entry per row with
 * its divergence and issue), and an "Approved exclusions" section.
 *
 * Usage:
 *   node scripts/coverage/generate-coverage-report.mjs \
 *     --manifest coverage/upstream/<sha>/manifest.json
 */

import { writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";

import { parseArgs } from "./lib/cli.mjs";
import { statusCounts } from "./lib/manifest.mjs";
import { readJsonIfExists } from "./lib/upstream-tree.mjs";

function render(manifest) {
	const counts = statusCounts(manifest);
	const lines = [];
	lines.push(`# Upstream coverage report`);
	lines.push("");
	lines.push(`- Upstream: \`${manifest.upstream.repo}\` at \`${manifest.upstream.sha}\``);
	lines.push(`- Generator: \`${manifest.generator.name}\` v${manifest.generator.version} (node ${manifest.generator.typescript})`);
	lines.push(`- Registry version: \`${manifest.generator.registry_version}\``);
	lines.push(
		`- Rows: ${manifest.rows.length} total — ` +
			["verified", "implemented_unverified", "in_progress", "unported", "not_applicable"]
				.map((status) => `${counts[status] ?? 0} ${status}`)
				.join(", "),
	);
	lines.push("");

	lines.push(`## Per-package status`);
	lines.push("");
	lines.push(`| Area | Package | Version | Exports | Behaviors | Verified | Unverified | Not applicable |`);
	lines.push(`| --- | --- | --- | --- | --- | --- | --- | --- |`);
	for (const pkg of manifest.packages) {
		const rows = manifest.rows.filter((row) => row.area === pkg.area);
		const verified = rows.filter((row) => row.status === "verified").length;
		const unverified = rows.filter((row) => ["unported", "in_progress", "implemented_unverified"].includes(row.status)).length;
		const na = rows.filter((row) => row.status === "not_applicable").length;
		lines.push(
			`| ${pkg.area} | \`${pkg.npm_name ?? "—"}\` | ${pkg.version ?? "—"} | ${pkg.export_count} | ${pkg.behavior_count} | ${verified} | ${unverified} | ${na} |`,
		);
	}
	lines.push("");

	lines.push(`## Apps`);
	lines.push("");
	if (manifest.app_decisions.length === 0) {
		lines.push(`_No upstream apps/* targets._`);
	} else {
		lines.push(`| Path | Decision | Reason | Approved by |`);
		lines.push(`| --- | --- | --- | --- |`);
		for (const entry of manifest.app_decisions) {
			lines.push(`| \`${entry.path}\` | ${entry.decision} | ${entry.reason ?? "—"} | ${entry.approved_by ?? "—"} |`);
		}
	}
	lines.push("");

	const notVerified = manifest.rows.filter((row) => ["unported", "in_progress", "implemented_unverified"].includes(row.status));
	lines.push(`## Not verified`);
	lines.push("");
	if (notVerified.length === 0) {
		lines.push(`_Every row is verified or an approved exclusion._`);
	} else {
		for (const row of notVerified) {
			const divergence = row.divergence && typeof row.divergence === "object" ? row.divergence.reason : row.divergence;
			lines.push(`### \`${row.id}\``);
			lines.push("");
			lines.push(`- Area: \`${row.area}\`, kind: \`${row.behavior_kind}\``);
			lines.push(`- Upstream: \`${row.upstream_path}\`${row.export ? ` → \`${row.export}\`` : ""}`);
			lines.push(`- Dart: ${row.dart_impl ? `\`${row.dart_impl}\`` : "_(none)_"}`);
			lines.push(`- Divergence: ${divergence ?? "_(missing)_"}`);
			lines.push(`- Issue: ${row.issue ? `\`#${row.issue}\`` : "_(missing)_"}`);
			lines.push("");
		}
	}

	const na = manifest.rows.filter((row) => row.status === "not_applicable");
	lines.push(`## Approved exclusions`);
	lines.push("");
	if (na.length === 0) {
		lines.push(`_None._`);
	} else {
		for (const row of na) {
			const reason = row.divergence && typeof row.divergence === "object" ? row.divergence.reason : row.divergence;
			lines.push(`- \`${row.id}\`: ${reason ?? "_(missing reason)_"}`);
		}
	}
	lines.push("");
	return lines.join("\n");
}

function main() {
	const args = parseArgs(process.argv.slice(2));
	const manifestPath = resolve(args.manifest ?? "coverage/upstream/unknown/manifest.json");
	const manifest = readJsonIfExists(manifestPath);
	if (!manifest) {
		console.error(`generate-coverage-report: cannot read manifest: ${manifestPath}`);
		process.exit(2);
	}
	const report = render(manifest);
	const outPath = join(dirname(manifestPath), "report.md");
	writeFileSync(outPath, report);
	console.log(`wrote ${outPath}`);
}

main();