#!/usr/bin/env node
/**
 * Generate the coverage ledger for a pinned upstream SHA.
 *
 * Resolves the human-reviewed behavior registry against the pinned upstream
 * tree's compiler-derived inventories and writes, under `--out`:
 *   - manifest.json  (behavior rows + per-package inventory + app decisions)
 *   - exports.json   (public-export inventory; the export-diff source)
 *   - sources.json   (source-file inventory; the completeness source)
 *   - assets.json    (upstream test/spec/example references; completeness source)
 *
 * It never writes report.md (the reporter's job) or state.json, and it never
 * synthesizes a behavior from a filename (FR-010a). Exit 2 on a checkout that
 * is not at `--sha`, an unparseable package, an invalid registry, or an apps/*
 * target without a decision entry.
 *
 * Usage:
 *   node scripts/coverage/generate-coverage-manifest.mjs \
 *     --upstream <path-to-upstream-checkout> --sha <full-sha> \
 *     --registry coverage/registry/behavior-registry.json \
 *     --out coverage/upstream/<sha>
 */

import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { parseArgs } from "./lib/cli.mjs";
import { buildManifest, serializeManifest } from "./lib/manifest.mjs";
import { validateRegistry } from "./lib/registry.mjs";
import {
	APP_DECISIONS,
	areaDirectory,
	buildExportInventory,
	buildSourceInventory,
	listApps,
	readJsonIfExists,
} from "./lib/upstream-tree.mjs";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");

function headSha(upstream) {
	try {
		return execFileSync("git", ["-C", upstream, "rev-parse", "HEAD"], { encoding: "utf8" }).trim();
	} catch (error) {
		console.error(`--upstream ${upstream}: cannot resolve HEAD: ${error.message}`);
		return null;
	}
}

function main() {
	const args = parseArgs(process.argv.slice(2));
	const upstream = resolve(args.upstream ?? ".");
	const sha = args.sha;
	const registryPath = resolve(args.registry ?? "coverage/registry/behavior-registry.json");
	const outDir = resolve(args.out ?? join("coverage", "upstream", sha ?? "unknown"));

	if (!sha || !/^[0-9a-f]{40}$/.test(sha)) {
		console.error("generate-coverage-manifest: --sha must be a full 40-char sha");
		process.exit(2);
	}
	if (!existsSync(upstream)) {
		console.error(`generate-coverage-manifest: upstream checkout not found: ${upstream}`);
		process.exit(2);
	}
	const actual = headSha(upstream);
	if (actual !== sha) {
		console.error(`generate-coverage-manifest: upstream HEAD ${actual} is not the pinned sha ${sha}`);
		process.exit(2);
	}

	const registry = readJsonIfExists(registryPath);
	if (!registry) {
		console.error(`generate-coverage-manifest: cannot read registry: ${registryPath}`);
		process.exit(2);
	}
	const { errors, warnings } = validateRegistry(registry);
	for (const warning of warnings) console.error(`warning: ${warning}`);
	if (errors.length > 0) {
		console.error("generate-coverage-manifest: registry is invalid:");
		for (const error of errors) console.error(`  ${error}`);
		process.exit(2);
	}
	if (registry.reviewed_base_sha !== sha) {
		console.error(
			`warning: registry.reviewed_base_sha ${registry.reviewed_base_sha} differs from generated sha ${sha}; the registry review may be stale`,
		);
	}

	let exportInventory;
	let sourceInventory;
	try {
		exportInventory = buildExportInventory(upstream);
		sourceInventory = buildSourceInventory(upstream);
	} catch (error) {
		console.error(`generate-coverage-manifest: cannot inventory upstream tree: ${error.message}`);
		process.exit(2);
	}

	// App decisions: read the per-SHA file if present, else synthesize the
	// skeleton from the apps/ tree. A missing or invalid decision is a hard
	// error — silent omission is exactly what the ledger exists to prevent.
	const apps = listApps(upstream);
	const decisionPath = join(outDir, "app-decisions.json");
	let appDecisions = readJsonIfExists(decisionPath)?.decisions;
	if (!appDecisions) {
		console.error(
			`generate-coverage-manifest: no app-decisions.json at ${decisionPath}; expected one entry per apps/* target: ${apps.join(", ") || "(none)"}`,
		);
		process.exit(2);
	}
	const appPaths = new Set(appDecisions.map((entry) => entry.path));
	const missingApps = apps.filter((app) => !appPaths.has(app));
	const extraApps = [...appPaths].filter((path) => !apps.includes(path));
	if (missingApps.length > 0) {
		console.error(`generate-coverage-manifest: apps/* targets without a decision: ${missingApps.join(", ")}`);
		process.exit(2);
	}
	if (extraApps.length > 0) {
		console.error(`generate-coverage-manifest: decision entries that are not apps/* targets: ${extraApps.join(", ")}`);
		process.exit(2);
	}
	for (const entry of appDecisions) {
		if (!APP_DECISIONS.includes(entry.decision)) {
			console.error(`generate-coverage-manifest: app ${entry.path}: unknown decision ${entry.decision}`);
			process.exit(2);
		}
		if (entry.decision !== "port" && !entry.reason) {
			console.error(`generate-coverage-manifest: app ${entry.path}: ${entry.decision} requires a reason`);
			process.exit(2);
		}
		if (entry.decision === "not_applicable" && !entry.approved_by) {
			console.error(`generate-coverage-manifest: app ${entry.path}: not_applicable requires approved_by`);
			process.exit(2);
		}
	}

	const manifest = buildManifest({
		sha,
		registry,
		exportInventory,
		sourceInventory,
		appDecisions,
		typescriptVersion: process.versions.node,
	});

	// Write everything, creating the output directory and its parents.
	mkdirSync(outDir, { recursive: true });
	const json = (value) => `${JSON.stringify(value, null, 2)}\n`;
	writeFileSync(join(outDir, "manifest.json"), serializeManifest(manifest));
	writeFileSync(join(outDir, "exports.json"), json({ schema_version: 1, upstream: manifest.upstream, packages: exportInventory }));
	writeFileSync(join(outDir, "sources.json"), json({ schema_version: 1, upstream: manifest.upstream, sources: sourceInventory.sources }));
	writeFileSync(join(outDir, "assets.json"), json({ schema_version: 1, upstream: manifest.upstream, assets: sourceInventory.assets }));

	const counts = manifest.rows.reduce((acc, row) => {
		acc[row.status] = (acc[row.status] ?? 0) + 1;
		return acc;
	}, {});
	const totalExports = exportInventory.reduce((acc, pkg) => acc + pkg.exports.length, 0);
	console.log(`generated manifest for ${sha}`);
	console.log(`  packages: ${exportInventory.length}, exports: ${totalExports}, sources: ${sourceInventory.sources.length}, assets: ${sourceInventory.assets.length}`);
	console.log(`  rows: ${manifest.rows.length} ${JSON.stringify(counts)}`);
	console.log(`  apps: ${appDecisions.length} decided`);
}

main();