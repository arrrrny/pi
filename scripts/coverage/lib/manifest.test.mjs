import assert from "node:assert/strict";
import test from "node:test";

import { canonicalJson, manifestHash, serializeManifest, statusCounts } from "./manifest.mjs";

function manifest() {
	return {
		schema_version: 1,
		generator: { name: "pi-coverage", version: "0.1.0", typescript: "20.19.2", registry_version: "2026-11-22" },
		upstream: { repo: "earendil-works/pi", sha: "780bf31fcaeb252fa9b68df3964c735eae75bde3", packages: {} },
		packages: [{ area: "agent", npm_name: "@earendil-works/pi-agent-core", version: "1.6.0", entrypoints: ["src/index.ts"], export_count: 2, behavior_count: 2 }],
		app_decisions: [],
		rows: [
			{ id: "agent.b.a.api", area: "agent", status: "verified", evidence: { scenario: "x" } },
			{ id: "agent.b.b.api", area: "agent", status: "unported", divergence: { reason: "r" }, issue: "#1" },
			{ id: "agent.b.c.api", area: "agent", status: "not_applicable", divergence: { reason: "r", approved_by: "arrrrny" } },
		],
	};
}

test("canonicalJson sorts object keys", () => {
	assert.equal(canonicalJson({ b: 1, a: 2 }), '{"a":2,"b":1}');
});

test("canonicalJson preserves array order", () => {
	assert.equal(canonicalJson([3, 1, 2]), "[3,1,2]");
});

test("canonicalJson handles nested structures", () => {
	assert.equal(canonicalJson({ z: { b: 1, a: 2 }, a: [1, 2] }), '{"a":[1,2],"z":{"a":2,"b":1}}');
});

test("serializeManifest emits canonical JSON plus a trailing newline", () => {
	const out = serializeManifest(manifest());
	assert.ok(out.endsWith("\n"));
	assert.ok(out.includes('"a":2') === false); // sanity: no stray content
});

test("manifestHash is stable for the same content", () => {
	assert.equal(manifestHash(manifest()), manifestHash(manifest()));
});

test("manifestHash changes when a row changes", () => {
	const before = manifestHash(manifest());
	const m = manifest();
	m.rows[0].status = "unported";
	assert.notEqual(before, manifestHash(m));
});

test("manifestHash ignores the generator's node version string", () => {
	const a = manifest();
	const b = manifest();
	a.generator.typescript = "20.19.2";
	b.generator.typescript = "22.19.0";
	assert.equal(manifestHash(a), manifestHash(b));
});

test("statusCounts tallies each status", () => {
	const counts = statusCounts(manifest());
	assert.equal(counts.verified, 1);
	assert.equal(counts.unported, 1);
	assert.equal(counts.not_applicable, 1);
});