#!/usr/bin/env node
/**
 * TypeScript side of the differential harness (contracts §6).
 *
 * Executes one scripted scenario against a deterministic model of the upstream
 * agent-loop contract — the same contract `pi_agent/tool/parity_harness.dart`
 * models on the Dart side — and emits the normalized outcome as JSONL on
 * stdout. It touches no provider, no network, and no file under `packages/`;
 * the "oracle" here is the upstream agent-loop's observable contract, encoded
 * as a scripted scenario the same way the Dart harness encodes it.
 *
 * Usage:
 *   node scripts/coverage/differential/run-ts.mjs --scenario <file>
 */

import { readFileSync } from "node:fs";
import { resolve } from "node:path";

import { parseArgs } from "../lib/cli.mjs";
import { normalizeOutcome, toJsonl } from "../lib/normalize.mjs";

function readScenario(path) {
	return JSON.parse(readFileSync(path, "utf8"));
}

// ─── chord.delta-apply model ────────────────────────────────────────────────
//
// A faithful model of `packages/chord/src/delta/index.ts`'s observable
// contract: `applyImmutableBatches` never mutates its input, a root replacement
// is adopted, and the op vocabulary (s/d/a/t/p/m/r) applies to plain JSON. The
// model deep-clones the target and applies the decoded ops mutably, which is
// observationally identical to the copy-on-write applier for the final value.

function resolveNode(root, path) {
	let node = root;
	for (const seg of path) {
		if (Array.isArray(node)) {
			if (typeof seg !== "number") throw new Error("PathError");
			node = node[seg];
		} else if (node !== null && typeof node === "object") {
			node = node[seg];
		} else {
			throw new Error("PathError");
		}
	}
	return node;
}

function applyMutable(root, op) {
	const verb = op[0];
	if (verb === "r") return op[1];
	const path = op[1];
	if (verb === "p") {
		const target = path.length === 0 ? root : resolveNode(root, path);
		if (!Array.isArray(target)) throw new Error("PathError");
		target.splice(op[2], op[3]);
		target.splice(op[2], 0, ...op[4]);
		return root;
	}
	if (verb === "m") {
		const target = path.length === 0 ? root : resolveNode(root, path);
		if (!Array.isArray(target) || target.length !== op[2].length) throw new Error("PathError");
		const previous = target.slice();
		for (let index = 0; index < op[2].length; index++) target[index] = previous[op[2][index]];
		return root;
	}
	const parent = resolveNode(root, path.slice(0, -1));
	const key = path[path.length - 1];
	const read = () => (Array.isArray(parent) ? parent[key] : parent[key]);
	const write = (value) => {
		parent[key] = value;
	};
	switch (verb) {
		case "s":
			write(op[2]);
			break;
		case "d":
			if (Array.isArray(parent)) parent.splice(key, 1);
			else delete parent[key];
			break;
		case "a": {
			const current = read();
			if (typeof current !== "string") throw new Error("PathError");
			write(`${current}${op[2]}`);
			break;
		}
		case "t": {
			const current = read();
			if (typeof current !== "string") throw new Error("PathError");
			write(current.slice(op[2]));
			break;
		}
		default:
			throw new Error(`unknown verb ${verb}`);
	}
	return root;
}

function isJsonValue(value) {
	if (value === null || typeof value === "string" || typeof value === "boolean") return true;
	if (typeof value === "number") return Number.isFinite(value);
	if (Array.isArray(value)) return value.every((item) => isJsonValue(item));
	if (typeof value === "object") {
		return Object.keys(value).every((key) => isJsonValue(value[key]));
	}
	return false;
}

function runChordDeltaApply(scenario) {
	const input = scenario.initial ?? null;
	const batches = scenario.batches ?? [];
	const before = JSON.stringify(input);
	let root = structuredClone(input);
	for (const ops of batches) {
		for (const op of ops) root = applyMutable(root, op);
	}
	const inputUnchanged = JSON.stringify(input) === before;
	const firstOp = batches.length > 0 && batches[0].length > 0 ? batches[0][0] : null;
	const isReplaceFirst = firstOp !== null && firstOp[0] === "r";
	return [
		{ type: "delta", name: "final", value: root },
		{ type: "delta", name: "input_unchanged", value: inputUnchanged },
		{ type: "delta", name: "is_replace_first", value: isReplaceFirst },
		{ type: "delta", name: "input_is_json", value: isJsonValue(input) },
	];
}

/**
 * Deterministic model of the upstream agent loop's observable behavior for the
 * scripted scenarios the differential harness supports.
 *
 * Each supported scenario kind returns the raw (pre-normalization) records the
 * TypeScript side would emit, mirroring `packages/agent/src/agent-loop.ts`.
 * For `agent-loop.*` kinds the Dart harness drives the REAL `agentLoop`, so
 * this side is the only model: it encodes what upstream does, verified against
 * `agent-loop.ts` — a failed `validateToolArguments` becomes
 * `createErrorToolResult` with `isError: true` (`agent-loop.ts:734-779`), the
 * tool result feeds the next turn, and the loop therefore runs two turns for a
 * single-tool-call scenario.
 *
 * This side cannot execute the real package: `packages/agent` has no build
 * output and no installed dependencies in this checkout, and a differential
 * that needs `npm install` cannot run in the coverage job. So it stays a model
 * — but it is the only model left, and the Dart side it is compared against is
 * now shipped code.
 */
function runScripted(scenario) {
	const records = [];
	const push = (record) => records.push({ turn: 0, ...record });
	switch (scenario.kind) {
		case "chord.delta-apply":
			return runChordDeltaApply(scenario);
		case "agent-loop.tool-arguments-validated": {
			// A tool call whose arguments fail validation resolves to an error
			// tool result; the result feeds the next turn, which ends the run.
			const tool = scenario.tool ?? "shell";
			const argsError = scenario.arguments_error ?? "Expected object";
			push({ type: "usage", input: 0, output: 0, cache: 0 });
			push({ type: "state", path: "$.turns", value: 2 });
			push({ type: "event", name: "agent_start" });
			records.push(
				{ turn: 1, type: "tool_result", tool_call_id: "call-1", tool, is_error: true, text: `Invalid arguments for tool "${tool}": ${argsError}` },
				{ turn: 1, type: "tool_execution", name: "start", tool_call_id: "call-1", tool },
				{ turn: 1, type: "tool_execution", name: "end", tool_call_id: "call-1", tool, is_error: true },
				{ turn: 1, type: "turn", name: "turn_start" },
				{ turn: 1, type: "turn", name: "turn_end", stop_reason: "toolUse" },
				{ turn: 2, type: "event", name: "agent_end" },
				{ turn: 2, type: "turn", name: "turn_start" },
				{ turn: 2, type: "turn", name: "turn_end", stop_reason: "endTurn" },
			);
			break;
		}
		case "durable.commit-boundary": {
			// A durable run crosses one commit boundary; the outcome is the same
			// whether the process crashed before or after the commit (idempotent
			// settlement, one stored commit).
			push({ type: "event", name: "agent_start" });
			push({ type: "commit", commit_id: "commit-1", entries: scenario.entries ?? [] });
			push({ type: "state", path: "$.turns", value: 1 });
			push({ type: "usage", input: 0, output: 0, cache: 0 });
			break;
		}
		case "provider.scripted-turn": {
			// A scripted provider returns one assistant turn; the transcript and
			// usage are the observable outcome.
			push({ type: "event", name: "agent_start" });
			push({ type: "transcript", role: "user", content: scenario.prompt ?? "" });
			push({ type: "transcript", role: "assistant", content: scenario.response ?? "" });
			push({ type: "state", path: "$.turns", value: 1 });
			push({ type: "usage", input: scenario.usage?.input ?? 0, output: scenario.usage?.output ?? 0, cache: 0 });
			break;
		}
		default:
			throw new Error(`unsupported scenario kind: ${scenario.kind}`);
	}
	return records;
}

function main() {
	const args = parseArgs(process.argv.slice(2));
	if (!args.scenario) throw new Error("run-ts: --scenario is required");
	const scenario = readScenario(resolve(args.scenario));
	if (!["scripted", "cassette"].includes(scenario.provider?.kind)) {
		throw new Error(`run-ts: unsupported provider kind ${scenario.provider?.kind}`);
	}
	const raw = runScripted(scenario);
	const normalized = normalizeOutcome(raw);
	process.stdout.write(toJsonl(normalized));
}

main();