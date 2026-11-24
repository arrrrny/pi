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
 * TypeScript side would emit: events, transcripts, state, commits, errors, and
 * usage. The Dart harness mirrors this switch case for case.
 *
 * NOTE: This is a scripted model, not the real upstream `agentLoop`. Driving
 * the real package with a deterministic provider would exercise shipped code
 * rather than a parallel switch — that is the sounder design for the future.
 * The current approach catches divergence between the two harness switches
 * but not a real parity regression in `packages/agent/src/agent-loop.ts`.
 */
function runScripted(scenario) {
	const records = [];
	const push = (record) => records.push({ turn: 0, ...record });
	switch (scenario.kind) {
		case "agent-loop.tool-arguments-validated": {
			// A tool call whose arguments fail validation produces an error event
			// and no tool result; the loop surfaces the validation error.
			push({ type: "event", name: "agent_start" });
			push({ type: "event", name: "tool_call", tool_call_id: "call-1", tool: scenario.tool ?? "shell", arguments: scenario.arguments ?? {} });
			push({ type: "error", code: "argumentsError", message: "tool arguments failed validation" });
			push({ type: "state", path: "$.turns", value: 1 });
			push({ type: "usage", input: 0, output: 0, cache: 0 });
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