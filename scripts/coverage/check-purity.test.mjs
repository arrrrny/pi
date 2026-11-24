import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const script = fileURLToPath(new URL("./check-purity.mjs", import.meta.url));

async function run(t, args) {
	const root = await mkdtemp(join(tmpdir(), "pi-cov-purity-"));
	t.after(() => rm(root, { recursive: true, force: true }));
	return { root, result: spawnSync(process.execPath, [script, ...args], { cwd: root, encoding: "utf8" }) };
}

test("passes a clean Dart tree", async (t) => {
	const { root } = await run(t, []);
	mkdirSync(join(root, "lib"), { recursive: true });
	writeFileSync(join(root, "lib", "clean.dart"), "import 'dart:io';\nvoid main() {}\n");
	const result = spawnSync(process.execPath, [script, "--root", join(root, "lib")], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 0, result.stderr);
});

test("fails a forbidden zuraffa import", async (t) => {
	const { root } = await run(t, []);
	mkdirSync(join(root, "lib"), { recursive: true });
	writeFileSync(join(root, "lib", "bad.dart"), "import 'package:zuraffa/zuraffa.dart';\n");
	const result = spawnSync(process.execPath, [script, "--root", join(root, "lib")], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 1);
	assert.match(result.stderr, /forbidden import package:zuraffa/);
});

test("fails a forbidden zuraffa_agent import", async (t) => {
	const { root } = await run(t, []);
	mkdirSync(join(root, "lib"), { recursive: true });
	writeFileSync(join(root, "lib", "bad.dart"), "import 'package:zuraffa_agent/agent.dart';\n");
	const result = spawnSync(process.execPath, [script, "--root", join(root, "lib")], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 1);
	assert.match(result.stderr, /forbidden import package:zuraffa_agent/);
});

test("fails a forbidden browser import", async (t) => {
	const { root } = await run(t, []);
	mkdirSync(join(root, "lib"), { recursive: true });
	writeFileSync(join(root, "lib", "bad.dart"), "import 'package:zuraffa_browser/browser.dart';\n");
	const result = spawnSync(process.execPath, [script, "--root", join(root, "lib")], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 1);
	assert.match(result.stderr, /forbidden import package:zuraffa_browser/);
});

test("passes a relative import", async (t) => {
	const { root } = await run(t, []);
	mkdirSync(join(root, "lib", "src"), { recursive: true });
	writeFileSync(join(root, "lib", "main.dart"), "import 'src/helper.dart';\n");
	writeFileSync(join(root, "lib", "src", "helper.dart"), "void helper() {}\n");
	const result = spawnSync(process.execPath, [script, "--root", join(root, "lib")], { cwd: root, encoding: "utf8" });
	assert.equal(result.status, 0, result.stderr);
});