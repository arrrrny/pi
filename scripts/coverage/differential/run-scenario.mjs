#!/usr/bin/env node
/**
 * Differential scenario runner (contracts §6).
 *
 * Runs one language-neutral scenario against the TypeScript implementation and
 * the Dart harness, normalizes both outputs with the scenario's
 * `normalization_version`, diffs them, and writes a result to
 * `coverage/differential/results/<sha>/<name>.json`.
 *
 * Exit 0 on match; exit 1 on divergence (the diff is printed); exit 2 on a
 * harness failure — a scenario that could not run is not a pass. It never
 * performs a live provider call: a scenario whose `provider.kind` is neither
 * `scripted` nor `cassette` (or that names a non-sanitized endpoint) is
 * rejected with exit 2 (FR-018).
 *
 * Usage:
 *   node scripts/coverage/differential/run-scenario.mjs --scenario <file> --sha <sha>
 */

import { execFileSync } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { parseArgs } from "../lib/cli.mjs";
import { diffOutcomes, normalizeOutcome, toJsonl, NORMALIZATION_VERSION } from "../lib/normalize.mjs";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..", "..");

function run(command, args, { allowFail = false } = {}) {
	try {
		return { ok: true, stdout: execFileSync(command, args, { cwd: ROOT, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] }) };
	} catch (error) {
		if (allowFail) return { ok: false, stdout: error.stdout ?? "", stderr: error.stderr ?? "", status: error.status };
		throw error;
	}
}

function parseJsonl(stdout) {
	return stdout
		.split(/\r?\n/)
		.filter((line) => line.trim().length > 0)
		.map((line) => JSON.parse(line));
}

function main() {
	const args = parseArgs(process.argv.slice(2));
	const scenarioPath = resolve(args.scenario);
	const sha = args.sha;
	let scenario;
	try {
		scenario = JSON.parse(execFileSync("node", ["-e", `process.stdout.write(require('fs').readFileSync(${JSON.stringify(scenarioPath)}, 'utf8'))`], { encoding: "utf8" }));
	} catch (error) {
		console.error(`run-scenario: cannot read scenario ${scenarioPath}: ${error.message}`);
		process.exit(2);
	}

	if (!["scripted", "cassette"].includes(scenario.provider?.kind)) {
		console.error(`run-scenario: scenario provider.kind must be scripted or cassette, got ${JSON.stringify(scenario.provider?.kind)}`);
		process.exit(2);
	}
	if (scenario.provider.kind === "cassette" && !scenario.provider.cassette) {
		console.error("run-scenario: cassette scenario must name a sanitized fixture path");
		process.exit(2);
	}

	const ts = run("node", [join("scripts", "coverage", "differential", "run-ts.mjs"), "--scenario", scenarioPath], { allowFail: true });
	if (!ts.ok) {
		console.error("run-scenario: TypeScript side failed (exit " + ts.status + ")");
		if (ts.stderr) console.error(ts.stderr);
		process.exit(2);
	}

	const dart = run(
		"dart",
		["run", join("pi_agent", "tool", "parity_harness.dart"), "--scenario", scenarioPath],
		{ allowFail: true },
	);
	if (!dart.ok) {
		console.error("run-scenario: Dart harness failed (exit " + dart.status + ")");
		if (dart.stderr) console.error(dart.stderr);
		process.exit(2);
	}

	const version = scenario.normalization_version ?? NORMALIZATION_VERSION;
	if (version !== NORMALIZATION_VERSION) {
		console.error(`run-scenario: scenario normalization_version ${version} != harness ${NORMALIZATION_VERSION}`);
		process.exit(2);
	}

	const left = parseJsonl(ts.stdout);
	const right = parseJsonl(dart.stdout);
	const normalizedLeft = normalizeOutcome(left);
	const normalizedRight = normalizeOutcome(right);
	const { equal, differences } = diffOutcomes(normalizedLeft, normalizedRight);

	const result = {
		schema_version: 1,
		name: scenario.name,
		sha: sha ?? null,
		normalization_version: version,
		equal,
		row_ids: scenario.row_ids ?? [],
		left: normalizedLeft,
		right: normalizedRight,
		differences,
	};
	const outDir = join("coverage", "differential", "results", sha ?? "unknown");
	mkdirSync(resolve(outDir), { recursive: true });
	const outPath = join(outDir, `${scenario.name}.json`);
	writeFileSync(resolve(outPath), `${JSON.stringify(result, null, 2)}\n`);

	if (!equal) {
		console.error(`run-scenario: divergence in ${scenario.name} (${differences.length} difference(s))`);
		for (const diff of differences) {
			console.error(`  seq ${diff.index + 1}:`);
			console.error(`    ts:   ${diff.left ? toJsonl([diff.left]) : "<missing>"}`);
			console.error(`    dart: ${diff.right ? toJsonl([diff.right]) : "<missing>"}`);
		}
		process.exit(1);
	}
	console.log(`run-scenario: ${scenario.name} matches (${normalizedLeft.length} normalized records)`);
}

main();