import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const script = fileURLToPath(new URL("./check-release-evidence.mjs", import.meta.url));

async function run(t, args) {
	const root = await mkdtemp(join(tmpdir(), "pi-cov-gate-"));
	t.after(() => rm(root, { recursive: true, force: true }));
	return { root, result: spawnSync(process.execPath, [script, ...args], { cwd: root, encoding: "utf8" }) };
}

test("fails when verified_upstream_sha is null", async (t) => {
	const { root } = await run(t, []);
	mkdirSync(join(root, "coverage"), { recursive: true });
	writeFileSync(join(root, "coverage", "state.json"), JSON.stringify({
		target_upstream_sha: "a".repeat(40),
		verified_upstream_sha: null,
	}));
	const result = spawnSync(process.execPath, [script], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 1);
	assert.match(result.stderr, /verified_upstream_sha is null/);
});

test("emits the release-evidence object with --json", async (t) => {
	const { root } = await run(t, []);
	mkdirSync(join(root, "coverage"), { recursive: true });
	writeFileSync(join(root, "coverage", "state.json"), JSON.stringify({
		target_upstream_sha: "a".repeat(40),
		verified_upstream_sha: null,
	}));
	const result = spawnSync(process.execPath, [script, "--json"], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 1);
	const evidence = JSON.parse(result.stdout);
	assert.equal(evidence.resolved, false);
	assert.equal(evidence.verified_upstream_sha, null);
	assert.ok(evidence.failures.length >= 1);
});

test("fails when target is ahead of verified", async (t) => {
	const { root } = await run(t, []);
	mkdirSync(join(root, "coverage"), { recursive: true });
	writeFileSync(join(root, "coverage", "state.json"), JSON.stringify({
		target_upstream_sha: "b".repeat(40),
		verified_upstream_sha: "a".repeat(40),
	}));
	const result = spawnSync(process.execPath, [script, "--json"], { cwd: root, encoding: "utf8" });
	const evidence = JSON.parse(result.stdout);
	assert.equal(evidence.resolved, false);
	assert.ok(evidence.failures.some((f) => /ahead of verified/.test(f)));
});

// PI-PAR-009 (arrrrny/pi#47): no full-parity claim while a TUI or app row lacks
// an evidence-backed adaptation decision. The gate reads the adaptation-decision
// artifact and fails parity when any TUI row or apps/* target is undecided.

function writeAdaptationDecisions(root, decisions) {
	mkdirSync(join(root, "coverage"), { recursive: true });
	writeFileSync(join(root, "coverage", "adaptation-decisions.json"), JSON.stringify(decisions));
}

function writeManifest(root, manifest) {
	const dir = join(root, "coverage", "upstream", "a".repeat(40));
	mkdirSync(dir, { recursive: true });
	writeFileSync(join(dir, "manifest.json"), JSON.stringify(manifest));
}

test("fails parity when a TUI row has no evidence-backed decision", async (t) => {
	const { root } = await run(t, []);
	mkdirSync(join(root, "coverage"), { recursive: true });
	writeFileSync(join(root, "coverage", "state.json"), JSON.stringify({
		target_upstream_sha: "a".repeat(40),
		verified_upstream_sha: "a".repeat(40),
	}));
	writeManifest(root, {
		schema_version: 1,
		generator: { name: "pi-coverage", version: "0.1.0", typescript: "x", registry_version: "r" },
		upstream: { repo: "earendil-works/pi", sha: "a".repeat(40), packages: {} },
		packages: [],
		app_decisions: [],
		rows: [],
	});
	writeAdaptationDecisions(root, {
		schema_version: 1,
		decisions: [
			{ area: "tui", coordinate: "tui.packages-tui-src-index.ts.Box.api", decision: "adapt", owner: "arrrrny", destination: "zuraffa_tui", evidence: "packages/tui/src/components/box.ts" },
			{ area: "tui", coordinate: "tui.packages-tui-test-text.test.ts.internal.test", decision: null, owner: null, destination: null, evidence: null },
		],
	});
	const result = spawnSync(process.execPath, [script, "--json"], { cwd: root, encoding: "utf8" });
	const evidence = JSON.parse(result.stdout);
	assert.equal(evidence.resolved, false);
	assert.ok(evidence.failures.some((f) => /tui.packages-tui-test-text/.test(f) && /decision/.test(f)));
});

test("fails parity when an apps/* target has no approved decision", async (t) => {
	const { root } = await run(t, []);
	mkdirSync(join(root, "coverage"), { recursive: true });
	writeFileSync(join(root, "coverage", "state.json"), JSON.stringify({
		target_upstream_sha: "a".repeat(40),
		verified_upstream_sha: "a".repeat(40),
	}));
	writeManifest(root, {
		schema_version: 1,
		generator: { name: "pi-coverage", version: "0.1.0", typescript: "x", registry_version: "r" },
		upstream: { repo: "earendil-works/pi", sha: "a".repeat(40), packages: {} },
		packages: [],
		app_decisions: [
			{ path: "apps/p2", decision: "not_applicable", reason: "r", approved_by: "arrrrny" },
			{ path: "apps/p3", decision: null, reason: null, approved_by: null },
		],
		rows: [],
	});
	const result = spawnSync(process.execPath, [script, "--json"], { cwd: root, encoding: "utf8" });
	const evidence = JSON.parse(result.stdout);
	assert.equal(evidence.resolved, false);
	assert.ok(evidence.failures.some((f) => /apps\/p3/.test(f)));
});

test("passes the adaptation-decision gate when every TUI row and app is decided with evidence", async (t) => {
	const { root } = await run(t, []);
	mkdirSync(join(root, "coverage"), { recursive: true });
	writeFileSync(join(root, "coverage", "state.json"), JSON.stringify({
		target_upstream_sha: "a".repeat(40),
		verified_upstream_sha: "a".repeat(40),
	}));
	writeManifest(root, {
		schema_version: 1,
		generator: { name: "pi-coverage", version: "0.1.0", typescript: "x", registry_version: "r" },
		upstream: { repo: "earendil-works/pi", sha: "a".repeat(40), packages: {} },
		packages: [],
		app_decisions: [
			{ path: "apps/p2", decision: "not_applicable", reason: "product app", approved_by: "arrrrny" },
		],
		rows: [],
	});
	writeAdaptationDecisions(root, {
		schema_version: 1,
		decisions: [
			{ area: "tui", coordinate: "tui.packages-tui-src-index.ts.Box.api", decision: "adapt", owner: "arrrrny", destination: "zuraffa_tui", evidence: "packages/tui/src/components/box.ts" },
			{ area: "tui", coordinate: "tui.packages-tui-test-text.test.ts.internal.test", decision: "not_applicable", owner: "arrrrny", destination: null, evidence: "upstream test has no Dart surface; covered by the zuraffa_tui component suite" },
		],
	});
	const result = spawnSync(process.execPath, [script, "--json"], { cwd: root, encoding: "utf8" });
	const evidence = JSON.parse(result.stdout);
	assert.ok(!evidence.failures.some((f) => /decision/.test(f)), JSON.stringify(evidence.failures));
});