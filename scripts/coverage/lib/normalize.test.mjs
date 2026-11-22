import assert from "node:assert/strict";
import test from "node:test";

import { diffOutcomes, normalizeIds, normalizeInterleaving, normalizeOutcome, normalizeTimestamps, toJsonl } from "./normalize.mjs";

test("normalizeTimestamps replaces timestamps by ordinal", () => {
	const out = normalizeTimestamps([
		{ type: "event", name: "a", timestamp: 100 },
		{ type: "event", name: "b", timestamp: 200 },
		{ type: "event", name: "c", timestamp: 100 },
	]);
	assert.deepEqual(out.map((r) => r.timestamp), [0, 1, 0]);
});

test("normalizeTimestamps leaves records without a timestamp alone", () => {
	const out = normalizeTimestamps([{ type: "event", name: "a" }]);
	assert.equal(out[0].timestamp, undefined);
});

test("normalizeIds replaces ids with role-based placeholders in first-seen order", () => {
	const out = normalizeIds([
		{ type: "event", name: "a", id: "x1" },
		{ type: "event", name: "b", id: "x2" },
		{ type: "event", name: "c", id: "x1" },
	]);
	assert.deepEqual(out.map((r) => r.id), ["<id-1>", "<id-2>", "<id-1>"]);
});

test("normalizeIds does not touch the control key 'turn'", () => {
	const out = normalizeIds([{ type: "event", name: "a", turn: 0 }]);
	assert.equal(out[0].turn, 0);
});

test("normalizeIds assigns separate counters per role", () => {
	const out = normalizeIds([
		{ type: "event", name: "a", id: "x", commit_id: "c1" },
		{ type: "event", name: "b", id: "y", tool_call_id: "t1" },
	]);
	assert.equal(out[0].id, "<id-1>");
	assert.equal(out[0].commit_id, "<commit-1>");
	assert.equal(out[1].tool_call_id, "<tool-call-1>");
});

test("normalizeInterleaving sorts events within a turn by name", () => {
	const out = normalizeInterleaving([
		{ turn: 0, type: "event", name: "b" },
		{ turn: 0, type: "event", name: "a" },
		{ turn: 1, type: "event", name: "d" },
	]);
	assert.deepEqual(out.map((r) => r.name), ["a", "b", "d"]);
});

test("normalizeOutcome assigns sequential seq numbers", () => {
	const out = normalizeOutcome([{ type: "event", name: "a" }, { type: "event", name: "b" }]);
	assert.deepEqual(out.map((r) => r.seq), [1, 2]);
});

test("toJsonl emits one compact object per line", () => {
	const out = toJsonl([{ a: 1, b: 2 }]);
	assert.equal(out, '{"a":1,"b":2}');
});

test("diffOutcomes reports equal outcomes", () => {
	const a = normalizeOutcome([{ type: "event", name: "x" }]);
	const b = normalizeOutcome([{ type: "event", name: "x" }]);
	assert.equal(diffOutcomes(a, b).equal, true);
});

test("diffOutcomes reports a divergence with the index", () => {
	const a = normalizeOutcome([{ type: "event", name: "x" }]);
	const b = normalizeOutcome([{ type: "event", name: "y" }]);
	const result = diffOutcomes(a, b);
	assert.equal(result.equal, false);
	assert.equal(result.differences.length, 1);
	assert.equal(result.differences[0].index, 0);
});

test("diffOutcomes reports a length mismatch", () => {
	const a = normalizeOutcome([{ type: "event", name: "x" }]);
	const b = normalizeOutcome([]);
	const result = diffOutcomes(a, b);
	assert.equal(result.equal, false);
	assert.equal(result.differences[0].right, null);
});