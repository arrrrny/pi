import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const scenario = fileURLToPath(
	new URL("../../../coverage/differential/scenarios/tool-arguments-invalid.json", import.meta.url),
);
const script = fileURLToPath(new URL("./run-scenario.mjs", import.meta.url));
const REPO_ROOT = fileURLToPath(new URL("../../../", import.meta.url));

/**
 * Runs the scenario end to end: the TypeScript model, the Dart harness driving
 * the real `agentLoop`, the diff, and the result write.
 *
 * This is the guard that a normalization change cannot silently leave the
 * runner referencing a variable it no longer defines — that shipped once and
 * the runner crashed with `ReferenceError` while the committed result still
 * claimed a match.
 */
test("run-scenario runs both sides and reports a match", async () => {
	const root = await mkdtemp(join(tmpdir(), "pi-differential-"));
	try {
		const result = spawnSync(
			process.execPath,
			[script, "--scenario", scenario, "--sha", "e".repeat(40)],
			{ cwd: REPO_ROOT, encoding: "utf8" },
		);

		assert.equal(
			result.status,
			0,
			`run-scenario exited ${result.status}\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}`,
		);
		assert.doesNotMatch(result.stderr, /ReferenceError/);
		assert.match(result.stdout, /matches \(\d+ normalized records\)/);
	} finally {
		await rm(root, { recursive: true, force: true });
		await rm(join(REPO_ROOT, "coverage", "differential", "results", "e".repeat(40)), {
			recursive: true,
			force: true,
		});
	}
});
