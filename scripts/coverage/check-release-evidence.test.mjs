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