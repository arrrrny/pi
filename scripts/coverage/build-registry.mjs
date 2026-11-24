#!/usr/bin/env node
/**
 * Derive the checked-in behavior registry from the pinned upstream tree.
 *
 * The registry is the human-reviewed input that declares which behaviors
 * exist. For every public export, every internal source file, and every
 * upstream test/spec/example asset, this script emits a scaffold row (or a
 * reviewed rationale, for items that map to no behavior) so that
 * `check-coverage.mjs` can only fail on the human-review fields — the missing
 * issue, the missing divergence, the missing verified evidence — which is the
 * signal the ledger exists to produce.
 *
 * The output is committed as `coverage/registry/behavior-registry.json` and is
 * the input the generator resolves against the pinned tree. It is deterministic
 * (same upstream tree + same sha -> same registry), so the review is stable.
 *
 * Usage:
 *   node scripts/coverage/build-registry.mjs \
 *     --upstream <path-to-upstream-checkout> --sha <full-sha> \
 *     --out coverage/registry/behavior-registry.json
 */

import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { parseArgs } from "./lib/cli.mjs";
import { rowId } from "./lib/registry.mjs";
import {
	AREA_ORDER,
	areaDirectory,
	buildExportInventory,
	buildSourceInventory,
	listPackageAreas,
} from "./lib/upstream-tree.mjs";

function headSha(upstream) {
	return execFileSync("git", ["-C", upstream, "rev-parse", "HEAD"], { encoding: "utf8" }).trim();
}

/** Map a package area to the Dart library that is its intended destination. */
const DART_ENTRYPOINT = {
	schema: "package:pi/types.dart",
	telemetry: "package:pi/types.dart",
	chord: "package:pi/harness.dart",
	ai: "package:pi/llm_client.dart",
	agent: "package:pi/agent.dart",
	durable: "package:pi/session.dart",
	codemode: "package:pi/tools.dart",
	env: "package:pi/execution_env.dart",
	mcp: "package:pi/tools.dart",
	"coding-agent": "package:pi/agent.dart",
	tui: null,
	evals: null,
};

const DART_IMPL = {
	schema: "pi_agent/lib/src/types.dart",
	telemetry: "pi_agent/lib/src/types.dart",
	chord: "pi_agent/lib/src/harness.dart",
	ai: "pi_agent/lib/src/llm_client.dart",
	agent: "pi_agent/lib/src/agent.dart",
	durable: "pi_agent/lib/src/session.dart",
	codemode: "pi_agent/lib/src/tools.dart",
	env: "pi_agent/lib/src/execution_env.dart",
	mcp: "pi_agent/lib/src/tools.dart",
	"coding-agent": "pi_agent/lib/src/agent.dart",
	tui: null,
	evals: null,
};

/** The one behavior that is verified today (the differential scenario). */
const VERIFIED = {
	id: rowId({ area: "agent", upstream_path: "packages/agent/src/agent-loop.ts", export: "agentLoop", behavior_kind: "validation" }),
	area: "agent",
	upstream_path: "packages/agent/src/agent-loop.ts",
	export: "agentLoop",
	internal: false,
	behavior_kind: "validation",
	status: "verified",
	evidence: { kind: "differential", scenario: "tool-arguments-invalid", golden: "coverage/differential/goldens/tool-arguments-invalid.json", normalization_version: 1 },
	dart_entrypoint: "package:pi/agent.dart",
	dart_impl: "pi_agent/lib/src/agent_loop.dart",
	dart_test: "pi_agent/test/agent_loop_test.dart",
	normative_refs: { readme: "packages/agent/README.md", spec: null, test: "packages/agent/test/agent-loop.test.ts", example: null },
	divergence: null,
	issue: null,
};

function main() {
	const args = parseArgs(process.argv.slice(2));
	const upstream = resolve(args.upstream ?? ".");
	const sha = args.sha ?? headSha(upstream);
	const outPath = resolve(args.out ?? "coverage/registry/behavior-registry.json");

	if (!/^[0-9a-f]{40}$/.test(sha ?? "")) {
		console.error("build-registry: --sha must be a full 40-char sha");
		process.exit(2);
	}
	if (!existsSync(upstream)) {
		console.error(`build-registry: upstream checkout not found: ${upstream}`);
		process.exit(2);
	}
	const actual = headSha(upstream);
	if (actual !== sha) {
		console.error(`build-registry: upstream HEAD ${actual} is not the pinned sha ${sha}`);
		process.exit(2);
	}

	const exportInventory = buildExportInventory(upstream);
	const { sources, assets } = buildSourceInventory(upstream);
	const areas = listPackageAreas(upstream).filter((area) => AREA_ORDER.includes(area));

	const behaviors = [];
	const unmapped_rationales = [];
	const seenExports = new Set();
	const seenIds = new Set();
	const mappedSources = new Set();
	const mappedAssets = new Set();

	const scaffold = (row) => ({
		description: `${row.behavior_kind} behavior in ${row.upstream_path} (scaffolded; needs human review).`,
		normative_refs: { readme: `${areaDirectory(row.area)}/README.md`, spec: null, test: null, example: null },
		platforms: ["vm"],
		adapter_requirements: [],
		dart_entrypoint: DART_ENTRYPOINT[row.area] ?? null,
		dart_impl: DART_IMPL[row.area] ?? null,
		dart_test: null,
		status: "unported",
		evidence: null,
		divergence: { reason: "Scaffolded by build-registry; not yet assessed for parity.", approved_by: null },
		issue: null,
		...row,
	});

	// Push a scaffold row, skipping a duplicate id (a symbol declared in one
	// file and re-exported from another resolves to the same identity tuple).
	const push = (row) => {
		if (seenIds.has(row.id)) return;
		seenIds.add(row.id);
		behaviors.push(row);
	};

	// 1. Public exports (entry-point surface). Dedup by (area, export name):
	//    the same symbol re-exported from src/index.ts and a built dist path is
	//    one export, not two.
	for (const pkg of exportInventory) {
		if (!AREA_ORDER.includes(pkg.area)) continue;
		for (const exp of pkg.exports) {
			if (exp.entry === false) continue;
			const key = `${pkg.area}:${exp.name}`;
			if (seenExports.has(key)) continue;
			seenExports.add(key);
			if (VERIFIED.area === pkg.area && VERIFIED.export === exp.name) {
				push(VERIFIED);
				mappedSources.add(VERIFIED.upstream_path);
				if (VERIFIED.normative_refs.test) mappedAssets.add(VERIFIED.normative_refs.test);
				continue;
			}
			push(
				scaffold({
					id: rowId({ area: pkg.area, upstream_path: exp.source, export: exp.name, behavior_kind: "api" }),
					area: pkg.area,
					upstream_path: exp.source,
					export: exp.name,
					internal: false,
					behavior_kind: "api",
				}),
			);
			mappedSources.add(exp.source);
		}
	}

	// 2. Internal source files (no public export). Each is a source entry that
	//    the public-export inventory cannot reach; a scaffold internal row
	//    covers it so completeness is honest about the internal surface.
	for (const source of sources) {
		if (!AREA_ORDER.includes(source.area)) continue;
		if (source.exported) continue;
		if (behaviors.some((b) => b.upstream_path === source.path && b.internal === true)) continue;
		mappedSources.add(source.path);
		push(
			scaffold({
				id: rowId({ area: source.area, upstream_path: source.path, export: null, behavior_kind: "internal" }),
				area: source.area,
				upstream_path: source.path,
				export: null,
				internal: true,
				behavior_kind: "internal",
			}),
		);
	}

	// 3. Upstream test/spec/example assets. Each maps to a scaffold row so the
	//    completeness check is satisfied; the row is the evidence the future
	//    verified behavior will bind to.
	for (const asset of assets) {
		if (!AREA_ORDER.includes(asset.area)) continue;
		if (behaviors.some((b) => b.upstream_path === asset.path)) continue;
		mappedAssets.add(asset.path);
		push(
			scaffold({
				id: rowId({ area: asset.area, upstream_path: asset.path, export: null, behavior_kind: asset.kind }),
				area: asset.area,
				upstream_path: asset.path,
				export: null,
				internal: false,
				behavior_kind: asset.kind,
			}),
		);
	}

	// Sort deterministically by (area order, id) for a stable, reviewable file.
	behaviors.sort((a, b) => {
		const areaDelta = AREA_ORDER.indexOf(a.area) - AREA_ORDER.indexOf(b.area);
		return areaDelta !== 0 ? areaDelta : a.id.localeCompare(b.id);
	});

	const registry = {
		schema_version: 1,
		registry_version: sha.slice(0, 12),
		reviewed_base_sha: sha,
		areas: AREA_ORDER,
		behaviors,
		unmapped_rationales,
	};

	mkdirSync(dirname(outPath), { recursive: true });
	writeFileSync(outPath, `${JSON.stringify(registry, null, 2)}\n`);
	const byArea = {};
	for (const b of behaviors) byArea[b.area] = (byArea[b.area] ?? 0) + 1;
	console.log(`derived registry at ${outPath}`);
	console.log(`  areas: ${areas.length}, behaviors: ${behaviors.length}`);
	console.log(`  per area: ${JSON.stringify(byArea)}`);
	console.log(`  mapped sources: ${mappedSources.size}/${sources.length}, assets: ${mappedAssets.size}/${assets.length}`);
}

main();