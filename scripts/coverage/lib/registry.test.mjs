import assert from "node:assert/strict";
import test from "node:test";

import { rowId, validateRegistry, checkCompleteness } from "./registry.mjs";

const BASE = "780bf31fcaeb252fa9b68df3964c735eae75bde3";

function registry(overrides = {}) {
	return {
		schema_version: 1,
		registry_version: "2026-11-22",
		reviewed_base_sha: BASE,
		areas: ["schema", "telemetry", "chord", "ai", "agent", "durable", "codemode", "env", "mcp", "coding-agent", "tui", "evals"],
		behaviors: [
			{
				id: "agent.packages-agent-src-agent-loop.ts.agentLoop.validation",
				area: "agent",
				upstream_path: "packages/agent/src/agent-loop.ts",
				export: "agentLoop",
				internal: false,
				behavior_kind: "validation",
				description: "Tool arguments are validated before the loop dispatches a call.",
				normative_refs: { readme: "packages/agent/README.md", spec: null, test: "packages/agent/test/agent-loop.test.ts", example: null },
				platforms: ["vm"],
				adapter_requirements: [],
				dart_entrypoint: "package:pi/agent.dart",
				dart_impl: "pi_agent/lib/src/agent_loop.dart",
				dart_test: "pi_agent/test/agent_loop_test.dart",
				status: "verified",
				evidence: { kind: "differential", scenario: "tool-arguments-invalid", normalization_version: 1 },
				divergence: null,
				issue: null,
			},
		],
		unmapped_rationales: [],
		...overrides,
	};
}

test("rowId builds the stable identity tuple", () => {
	const id = rowId({ area: "agent", upstream_path: "packages/agent/src/agent-loop.ts", export: "agentLoop", behavior_kind: "validation" });
	assert.equal(id, "agent.packages-agent-src-agent-loop.ts.agentLoop.validation");
});

test("rowId preserves export case so case-distinct exports do not collide", () => {
	// packages/chord/src/delta/index.ts exports both a `Decoder` type and a
	// `decoder` value; case-folding the export slug would merge their ids.
	const upper = rowId({ area: "chord", upstream_path: "packages/chord/src/delta/index.ts", export: "Decoder", behavior_kind: "api" });
	const lower = rowId({ area: "chord", upstream_path: "packages/chord/src/delta/index.ts", export: "decoder", behavior_kind: "api" });
	assert.notEqual(upper, lower);
	assert.ok(upper.endsWith(".Decoder.api"));
	assert.ok(lower.endsWith(".decoder.api"));
});

test("rowId uses an internal marker for null exports", () => {
	const id = rowId({ area: "agent", upstream_path: "packages/agent/src/agent-loop.ts", export: null, behavior_kind: "internal" });
	assert.ok(id.endsWith(".internal.internal"));
});

test("validateRegistry accepts a well-formed registry", () => {
	const { errors } = validateRegistry(registry());
	assert.equal(errors.length, 0);
});

test("validateRegistry rejects an unknown area", () => {
	const { errors } = validateRegistry(registry({ areas: ["schema", "nonexistent"] }));
	assert.ok(errors.some((error) => /unknown area/.test(error)));
});

test("validateRegistry rejects a duplicate row id", () => {
	const reg = registry();
	reg.behaviors.push({ ...reg.behaviors[0] });
	const { errors } = validateRegistry(reg);
	assert.ok(errors.some((error) => /duplicate id/.test(error)));
});

test("validateRegistry rejects a non-40-char reviewed_base_sha", () => {
	const { errors } = validateRegistry(registry({ reviewed_base_sha: "abc123" }));
	assert.ok(errors.some((error) => /reviewed_base_sha must be a full 40-char sha/.test(error)));
});

test("validateRegistry rejects an id that does not match its identity tuple", () => {
	const reg = registry();
	reg.behaviors[0].id = "agent.wrong.id.validation";
	const { errors } = validateRegistry(reg);
	assert.ok(errors.some((error) => /does not match its identity tuple/.test(error)));
});

test("checkCompleteness reports an unmapped public export", () => {
	const reg = registry();
	const { unmapped } = checkCompleteness({
		registry: reg,
		exportInventory: [{ area: "agent", exports: [{ name: "agentLoop", source: "packages/agent/src/agent-loop.ts", entry: true }, { name: "missingExport", source: "packages/agent/src/agent-loop.ts", entry: true }] }],
		sourceInventory: [],
		assetInventory: [],
	});
	assert.ok(unmapped.some((item) => item.kind === "export" && item.coordinate.includes("missingExport")));
	assert.equal(unmapped.some((item) => item.coordinate.includes("agentLoop")), false);
});

test("checkCompleteness accepts a rationalized export", () => {
	const reg = registry();
	reg.unmapped_rationales = [{ kind: "export", coordinate: "missingExport@packages/agent/src/agent-loop.ts", reason: "internal", approved_by: "arrrrny" }];
	const { unmapped } = checkCompleteness({
		registry: reg,
		exportInventory: [{ area: "agent", exports: [{ name: "missingExport", source: "packages/agent/src/agent-loop.ts", entry: true }] }],
		sourceInventory: [],
		assetInventory: [],
	});
	assert.equal(unmapped.length, 0);
});

test("checkCompleteness covers a test asset through a row's normative_refs", () => {
	const reg = registry();
	const { unmapped } = checkCompleteness({
		registry: reg,
		exportInventory: [],
		sourceInventory: [],
		assetInventory: [{ area: "agent", kind: "test", path: "packages/agent/test/agent-loop.test.ts" }],
	});
	assert.equal(unmapped.length, 0);
});

test("checkCompleteness reports an unmapped test asset", () => {
	const reg = registry();
	const { unmapped } = checkCompleteness({
		registry: reg,
		exportInventory: [],
		sourceInventory: [],
		assetInventory: [{ area: "agent", kind: "test", path: "packages/agent/test/other.test.ts" }],
	});
	assert.ok(unmapped.some((item) => item.kind === "test" && item.coordinate === "packages/agent/test/other.test.ts"));
});