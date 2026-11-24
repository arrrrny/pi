import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const script = fileURLToPath(new URL("./generate-coverage-report.mjs", import.meta.url));

function manifest() {
	return {
		schema_version: 1,
		generator: { name: "pi-coverage", version: "0.1.0", typescript: "20.19.2", registry_version: "2026-11-22" },
		upstream: { repo: "earendil-works/pi", sha: "a".repeat(40), packages: {} },
		packages: [
			{ area: "agent", npm_name: "@earendil-works/pi-agent-core", version: "1.6.0", entrypoints: [], export_count: 2, behavior_count: 2 },
		],
		app_decisions: [{ path: "apps/p2", decision: "not_applicable", reason: "product", approved_by: "arrrrny" }],
		rows: [
			{ id: "agent.a", area: "agent", behavior_kind: "validation", upstream_path: "packages/agent/src/a.ts", export: "a", dart_impl: "pi_agent/lib/src/a.dart", status: "verified", evidence: { scenario: "x" }, divergence: null, issue: null },
			{ id: "agent.b", area: "agent", behavior_kind: "validation", upstream_path: "packages/agent/src/b.ts", export: "b", dart_impl: null, status: "unported", evidence: null, divergence: { reason: "not started" }, issue: "#1" },
			{ id: "agent.c", area: "agent", behavior_kind: "validation", upstream_path: "packages/agent/src/c.ts", export: "c", dart_impl: null, status: "not_applicable", evidence: null, divergence: { reason: "out of scope", approved_by: "arrrrny" }, issue: null },
		],
	};
}

test("renders a report with per-package status and not-verified section", async (t) => {
	const root = await mkdtemp(join(tmpdir(), "pi-cov-report-"));
	t.after(() => rm(root, { recursive: true, force: true }));
	mkdirSync(root, { recursive: true });
	writeFileSync(join(root, "manifest.json"), JSON.stringify(manifest()));
	const result = spawnSync(process.execPath, [script, "--manifest", join(root, "manifest.json")], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 0, result.stderr);
	const report = readFileSync(join(root, "report.md"), "utf8");
	assert.match(report, /# Upstream coverage report/);
	assert.match(report, /## Per-package status/);
	assert.match(report, /## Not verified/);
	assert.match(report, /agent\.b/);
	assert.match(report, /not started/);
	assert.match(report, /#1/);
	assert.match(report, /## Approved exclusions/);
	assert.match(report, /out of scope/);
});

test("exits 2 when the manifest is missing", async (t) => {
	const root = await mkdtemp(join(tmpdir(), "pi-cov-report-"));
	t.after(() => rm(root, { recursive: true, force: true }));
	const result = spawnSync(process.execPath, [script, "--manifest", join(root, "missing.json")], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 2);
});