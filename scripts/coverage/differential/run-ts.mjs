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