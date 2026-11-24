import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const script = fileURLToPath(new URL("./check-coverage.mjs", import.meta.url));

async function run(t, args) {
	const root = await mkdtemp(join(tmpdir(), "pi-cov-check-"));
	t.after(() => rm(root, { recursive: true, force: true }));
	return { root, result: spawnSync(process.execPath, [script, ...args], { cwd: root, encoding: "utf8" }) };
}

function writeManifest(root, manifest) {
	mkdirSync(root, { recursive: true });
	writeFileSync(join(root, "manifest.json"), JSON.stringify(manifest));
	writeFileSync(join(root, "exports.json"), JSON.stringify({ schema_version: 1, packages: [] }));
	writeFileSync(join(root, "sources.json"), JSON.stringify({ schema_version: 1, sources: [] }));
	writeFileSync(join(root, "assets.json"), JSON.stringify({ schema_version: 1, assets: [] }));
}

function manifestWith(rows) {
	return {
		schema_version: 1,
		generator: { name: "pi-coverage", version: "0.1.0", typescript: "x", registry_version: "r" },
		upstream: { repo: "earendil-works/pi", sha: "a".repeat(40), packages: {} },
		packages: [],
		app_decisions: [],
		rows,
	};
}

function row(overrides = {}) {
	return {
		id: "agent.packages-agent-src-agent-loop.ts.agentloop.validation",
		area: "agent",
		upstream_path: "packages/agent/src/agent-loop.ts",
		export: "agentLoop",
		internal: false,
		behavior_kind: "validation",
		normative_refs: {},
		dart_entrypoint: "package:pi/agent.dart",
		dart_impl: "pi_agent/lib/src/agent_loop.dart",
		dart_test: null,
		platforms: [],
		adapter_requirements: [],
		status: "unported",
		evidence: null,
		divergence: { reason: "r", approved_by: null },
		issue: "#1",
		...overrides,
	};
}

test("passes a fully-verified row with evidence", async (t) => {
	const { root } = await run(t, ["--manifest", "manifest.json"]);
	writeManifest(root, manifestWith([row({ status: "verified", evidence: { scenario: "x" }, divergence: null })]));
	// A minimal registry so the completeness check has its human-reviewed input.
	const registry = {
		schema_version: 1,
		registry_version: "r",
		reviewed_base_sha: "a".repeat(40),
		areas: ["agent"],
		behaviors: [],
		unmapped_rationales: [],
	};
	writeFileSync(join(root, "registry.json"), JSON.stringify(registry));
	const rerun = spawnSync(process.execPath, [script, "--manifest", join(root, "manifest.json"), "--registry", join(root, "registry.json")], { cwd: root, encoding: "utf8" });
	assert.equal(rerun.status, 0, rerun.stderr);
});

test("fails an unported row without a divergence", async (t) => {
	const { root } = await run(t, ["--manifest", "manifest.json"]);
	writeManifest(root, manifestWith([row({ divergence: null, issue: "#1" })]));
	const result = spawnSync(process.execPath, [script, "--manifest", join(root, "manifest.json")], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 1);
	assert.match(result.stderr, /requires a divergence rationale/);
});

test("fails an unported row without an issue", async (t) => {
	const { root } = await run(t, ["--manifest", "manifest.json"]);
	writeManifest(root, manifestWith([row({ issue: null })]));
	const result = spawnSync(process.execPath, [script, "--manifest", join(root, "manifest.json")], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 1);
	assert.match(result.stderr, /requires a tracking issue/);
});

test("fails a verified row with no resolvable evidence", async (t) => {
	const { root } = await run(t, ["--manifest", "manifest.json"]);
	writeManifest(root, manifestWith([row({ status: "verified", evidence: null, divergence: null })]));
	const result = spawnSync(process.execPath, [script, "--manifest", join(root, "manifest.json")], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 1);
	assert.match(result.stderr, /verified requires resolvable evidence/);
});

test("fails a not_applicable row without an approval", async (t) => {
	const { root } = await run(t, ["--manifest", "manifest.json"]);
	writeManifest(root, manifestWith([row({ status: "not_applicable", divergence: { reason: "r", approved_by: null } })]));
	const result = spawnSync(process.execPath, [script, "--manifest", join(root, "manifest.json")], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 1);
	assert.match(result.stderr, /not_applicable requires an approval/);
});

test("exits 2 when the manifest is missing", async (t) => {
	const { result } = await run(t, ["--manifest", "missing.json"]);
	assert.equal(result.status, 2);
});