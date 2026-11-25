#!/usr/bin/env node
/**
 * TypeScript side of the differential harness (contracts §6).
 *
 * Executes one scripted scenario against a deterministic model of the upstream
 * contract — the same contract `pi_agent/tool/parity_harness.dart` models on
 * the Dart side — and emits the normalized outcome as JSONL on stdout. It
 * touches no provider, no network, and no file under `packages/`; the
 * "oracle" here is the upstream observable contract, encoded as a scripted
 * scenario the same way the Dart harness encodes it.
 *
 * Usage:
 *   node scripts/coverage/differential/run-ts.mjs --scenario <file>
 */

import { readFileSync } from "node:fs";
import { resolve } from "node:path";

import { parseArgs } from "../lib/cli.mjs";
import { normalizeOutcome, toJsonl, normalizeGeneratedToolCallIds } from "../lib/normalize.mjs";

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

const RESERVED_SEGMENTS = new Set(["__proto__", "constructor", "prototype"]);

/** Mirror of upstream `assertSafePath` — a write through a reserved segment fails. */
function assertSafePath(path) {
	for (const seg of path) {
		if (typeof seg === "string") {
			if (RESERVED_SEGMENTS.has(seg)) throw new Error(`unsafe path segment: ${seg}`);
		} else if (!Number.isInteger(seg) || seg < 0) {
			throw new Error(`unsafe path segment: ${String(seg)}`);
		}
	}
}

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
	assertSafePath(path);
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
			// Mirror shipped `OpTruncate`: a length at or past the end keeps the
			// whole string (`slice` alone would return "" and diverge on this edge).
			write(op[2] >= current.length ? current : current.slice(op[2]));
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
	// The model applies ops mutably (mirrors shipped `apply`); the immutable path
	// produces the same final value, so both records are emitted and compared.
	let root = structuredClone(input);
	for (const ops of batches) {
		for (const op of ops) root = applyMutable(root, op);
	}
	const mutableRoot = root;
	const inputUnchanged = JSON.stringify(input) === before;
	const firstOp = batches.length > 0 && batches[0].length > 0 ? batches[0][0] : null;
	const isReplaceFirst = firstOp !== null && firstOp[0] === "r";

	const reservedOps = scenario.reserved_segment_ops ?? [];
	let reservedError = "no error";
	if (reservedOps.length > 0) {
		try {
			let r = {};
			for (const op of reservedOps) r = applyMutable(r, op);
		} catch (error) {
			const message = String(error?.message ?? error);
			reservedError = message.startsWith("unsafe path segment:")
				? `UnsafePathError: ${message.slice("unsafe path segment: ".length)}`
				: message;
		}
	}
	return [
		{ type: "delta", name: "final", value: root },
		{ type: "delta", name: "mutable_final", value: mutableRoot },
		{ type: "delta", name: "input_unchanged", value: inputUnchanged },
		{ type: "delta", name: "is_replace_first", value: isReplaceFirst },
		{ type: "delta", name: "input_is_json", value: isJsonValue(input) },
		{ type: "error", name: "reserved_segment", value: reservedError },
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
			if (scenario.kind.startsWith("provider-stream.")) return runProviderStream(scenario);
			if (scenario.kind === "provider-error-body") return runProviderErrorBody(scenario);
			if (scenario.kind === "provider-retry-transient") return runProviderRetry(scenario);
			if (scenario.kind === "provider.session-identity") return runProviderIdentity(scenario);
			throw new Error(`unsupported scenario kind: ${scenario.kind}`);
	}
	return records;
}

// ---------------------------------------------------------------------------
// Provider streaming surface (`packages/ai/src/api/*`), parity slice PI-PAR-003
// (arrrrny/pi#41). The models below encode the streaming contracts of the
// upstream provider APIs — the SSE/chunk loops of anthropic-messages,
// openai-completions, google-generative-ai, and mistral-conversations — the
// same contracts the Dart parsers in `pi_agent/lib/src/ai/*_stream.dart`
// implement. Both sides consume the same sanitized cassette and emit the same
// canonical event records; the diff is the parity evidence.
// ---------------------------------------------------------------------------

const ANTHROPIC_MESSAGE_EVENTS = new Set([
	"message_start",
	"message_delta",
	"message_stop",
	"content_block_start",
	"content_block_delta",
	"content_block_stop",
]);

/** Decode a raw SSE cassette into `{event, data, raw}` events, mirroring
 * `packages/ai/src/utils/sse.ts` for the well-formed frames a cassette
 * carries (LF line endings, `event:`/`data:` fields, blank-line dispatch). */
function decodeSse(text) {
	const events = [];
	let event = null;
	let data = [];
	let raw = [];
	const flush = () => {
		if (!event && data.length === 0) {
			event = null;
			raw = [];
			return;
		}
		events.push({ event, data: data.join("\n"), raw: [...raw] });
		event = null;
		data = [];
		raw = [];
	};
	for (const line of text.split("\n")) {
		if (line === "") {
			flush();
			continue;
		}
		raw.push(line);
		if (line.startsWith(":")) continue;
		const colon = line.indexOf(":");
		const field = colon === -1 ? line : line.slice(0, colon);
		let value = colon === -1 ? "" : line.slice(colon + 1);
		if (value.startsWith(" ")) value = value.slice(1);
		if (field === "event") event = value;
		else if (field === "data") data.push(value);
	}
	flush();
	return events;
}

function readCassette(scenario) {
	const path = resolve(scenario.provider.cassette);
	return readFileSync(path, "utf8");
}

const num = (value) => (typeof value === "number" ? value : 0);

/** Canonical message JSON, the shape the Dart port's `toJson` renders. */
function canonicalMessage(message) {
	return {
		role: "assistant",
		content: message.content.map(canonicalBlock),
		stopReason: message.stopReason,
		usage: canonicalUsage(message.usage),
		...(message.rawStopReason !== undefined ? { rawStopReason: message.rawStopReason } : {}),
		...(message.errorMessage !== undefined ? { errorMessage: message.errorMessage } : {}),
		...(message.responseId !== undefined ? { responseId: message.responseId } : {}),
		...(message.responseModel !== undefined ? { responseModel: message.responseModel } : {}),
	};
}

function canonicalUsage(usage) {
	return {
		input: usage.input,
		output: usage.output,
		cacheRead: usage.cacheRead,
		cacheWrite: usage.cacheWrite,
		...(usage.cacheWrite1h ? { cacheWrite1h: usage.cacheWrite1h } : {}),
		...(usage.reasoning ? { reasoning: usage.reasoning } : {}),
		totalTokens: usage.totalTokens,
	};
}

function canonicalBlock(block) {
	if (block.type === "text") return { type: "text", text: block.text };
	if (block.type === "thinking") {
		return {
			type: "thinking",
			thinking: block.redacted ? "[Reasoning redacted]" : block.thinking,
			// An unset signature is absent from the canonical form on both
			// sides (Google leaves it undefined until a thought signature is
			// retained; Anthropic starts it empty).
			...(block.thinkingSignature ? { thinkingSignature: block.thinkingSignature } : {}),
			...(block.redacted ? { redacted: true } : {}),
		};
	}
	return {
		id: block.id,
		name: block.name,
		...(block.argumentsError !== undefined ? { argumentsError: block.argumentsError } : {}),
		arguments: block.argumentsError === undefined ? block.arguments : {},
	};
}

/** One streamed provider contract run: parse, normalize the outcome, and
 * let a failure become the canonical terminal `error` event plus message. */
function providerStreamOutcome(events, message, finish) {
	const pushed = events;
	try {
		finish();
		pushed.push({ type: "done", reason: message.stopReason });
	} catch (error) {
		message.stopReason = "error";
		message.errorMessage = String(error.message);
		pushed.push({ type: "error", reason: "error", errorMessage: String(error.message) });
	}
	return [...pushed, { type: "message", ...canonicalMessage(message) }];
}

function runAnthropicStream(sseEvents, requestedModelId) {
	const message = {
		content: [],
		stopReason: "pending",
		usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, totalTokens: 0 },
	};
	const events = [];
	const openBlocks = new Map();
	let sawStart = false;
	let sawEnd = false;
	return providerStreamOutcome(events, message, () => {
		for (const sse of sseEvents) {
			if (sse.event === "error") throw new Error(sse.data);
			if (!ANTHROPIC_MESSAGE_EVENTS.has(sse.event ?? "")) continue;
			let event;
			try {
				event = JSON.parse(sse.data);
			} catch (error) {
				throw new Error(
					`Could not parse Anthropic SSE event ${sse.event}: ${error.message}; data=${sse.data}; raw=${sse.raw.join("\\n")}`,
				);
			}
			switch (event.type) {
				case "message_start":
					sawStart = true;
					message.responseId = event.message.id;
					if (
						typeof event.message.model === "string" &&
						event.message.model.length > 0 &&
						message.responseModel === undefined &&
						event.message.model !== requestedModelId
					) {
						message.responseModel = event.message.model;
					}
					if (event.message.usage) {
						message.usage.input = num(event.message.usage.input_tokens);
						message.usage.output = num(event.message.usage.output_tokens);
						message.usage.cacheRead = num(event.message.usage.cache_read_input_tokens);
						message.usage.cacheWrite = num(event.message.usage.cache_creation_input_tokens);
						const cacheCreation = event.message.usage.cache_creation;
						if (cacheCreation) {
							message.usage.cacheWrite1h = num(cacheCreation.ephemeral_1h_input_tokens);
						}
						message.usage.totalTokens =
							message.usage.input + message.usage.output + message.usage.cacheRead + message.usage.cacheWrite;
					}
					events.push({ type: "start" });
					break;
				case "content_block_start": {
					const block = event.content_block;
					const index = event.index ?? 0;
					if (block.type === "fallback") {
						if (message.content.length > 0) {
							throw new Error("Anthropic performed an unsupported mid-output model fallback");
						}
						break;
					}
					if (block.type === "text") {
						message.content.push({ type: "text", text: block.text ?? "" });
						openBlocks.set(index, message.content.length - 1);
						events.push({ type: "text_start", contentIndex: message.content.length - 1 });
					} else if (block.type === "thinking") {
						message.content.push({
							type: "thinking",
							thinking: block.thinking ?? "",
							thinkingSignature: block.signature ?? "",
						});
						openBlocks.set(index, message.content.length - 1);
						events.push({ type: "thinking_start", contentIndex: message.content.length - 1 });
					} else if (block.type === "redacted_thinking") {
						message.content.push({
							type: "thinking",
							thinking: "[Reasoning redacted]",
							thinkingSignature: block.data ?? "",
							redacted: true,
						});
						openBlocks.set(index, message.content.length - 1);
						events.push({ type: "thinking_start", contentIndex: message.content.length - 1 });
					} else if (block.type === "tool_use") {
						message.content.push({
							type: "toolCall",
							id: block.id,
							name: block.name,
							arguments: block.input ?? {},
						});
						openBlocks.set(index, { contentIndex: message.content.length - 1, text: "" });
						events.push({ type: "toolcall_start", contentIndex: message.content.length - 1 });
					}
					break;
				}
				case "content_block_delta": {
					const open = openBlocks.get(event.index ?? 0);
					if (open === undefined) break;
					const delta = event.delta;
					const contentIndex = typeof open === "number" ? open : open.contentIndex;
					const block = message.content[contentIndex];
					if (delta.type === "text_delta" && block.type === "text") {
						block.text += delta.text;
						events.push({ type: "text_delta", contentIndex, delta: delta.text });
					} else if (delta.type === "thinking_delta" && block.type === "thinking") {
						block.thinking += delta.thinking;
						events.push({ type: "thinking_delta", contentIndex, delta: delta.thinking });
					} else if (delta.type === "input_json_delta" && block.type === "toolCall" && typeof open === "object") {
						open.text += delta.partial_json;
						try {
							block.arguments = JSON.parse(open.text);
						} catch {
							// Partial JSON never becomes the final arguments; the
							// authoritative parse happens at block stop.
						}
						events.push({ type: "toolcall_delta", contentIndex, delta: delta.partial_json });
					} else if (delta.type === "signature_delta" && block.type === "thinking") {
						block.thinkingSignature = (block.thinkingSignature || "") + delta.signature;
					}
					break;
				}
				case "content_block_stop": {
					const open = openBlocks.get(event.index ?? 0);
					openBlocks.delete(event.index ?? 0);
					if (open === undefined) break;
					const contentIndex = typeof open === "number" ? open : open.contentIndex;
					const block = message.content[contentIndex];
					if (block.type === "text") {
						events.push({ type: "text_end", contentIndex, content: block.text });
					} else if (block.type === "thinking") {
						events.push({ type: "thinking_end", contentIndex, content: block.thinking });
					} else if (block.type === "toolCall") {
						const finished = finishToolCallArguments(typeof open === "object" ? open.text : "");
						block.arguments = finished.arguments;
						if (finished.argumentsError !== undefined) block.argumentsError = finished.argumentsError;
						events.push({ type: "toolcall_end", contentIndex, toolCall: canonicalBlock(block) });
					}
					break;
				}
				case "message_delta": {
					const delta = event.delta;
					if (delta.stop_reason) {
						message.rawStopReason = delta.stop_reason;
						const mapped = mapAnthropicStopReason(delta.stop_reason, event.stop_details);
						message.stopReason = mapped.stopReason;
						if (mapped.errorMessage) message.errorMessage = mapped.errorMessage;
					}
					const usage = event.usage;
					if (usage) {
						if (usage.input_tokens != null) message.usage.input = num(usage.input_tokens);
						if (usage.output_tokens != null) message.usage.output = num(usage.output_tokens);
						if (usage.cache_read_input_tokens != null) message.usage.cacheRead = num(usage.cache_read_input_tokens);
						if (usage.cache_creation_input_tokens != null) {
							message.usage.cacheWrite = num(usage.cache_creation_input_tokens);
						}
						if (usage.cache_creation?.ephemeral_1h_input_tokens != null) {
							message.usage.cacheWrite1h = num(usage.cache_creation.ephemeral_1h_input_tokens);
						}
						const thinkingTokens = usage.output_tokens_details?.thinking_tokens;
						if (thinkingTokens != null) message.usage.reasoning = num(thinkingTokens);
					}
					message.usage.totalTokens =
						message.usage.input + message.usage.output + message.usage.cacheRead + message.usage.cacheWrite;
					break;
				}
				case "message_stop":
					sawEnd = true;
					break;
				default:
					break;
			}
		}
		if (sawStart && !sawEnd) throw new Error("Anthropic stream ended before message_stop");
		if (message.stopReason === "pending") throw new Error("Anthropic stream ended without a stop reason");
		if (message.stopReason === "aborted" || message.stopReason === "error") {
			throw new Error(message.errorMessage || "An unknown error occurred");
		}
	});
}

function mapAnthropicStopReason(reason, stopDetails) {
	switch (reason) {
		case "end_turn":
			return { stopReason: "stop" };
		case "max_tokens":
			return { stopReason: "length" };
		case "tool_use":
			return { stopReason: "toolUse" };
		case "refusal":
			return { stopReason: "error", errorMessage: stopDetails?.explanation || "The model refused to complete the request" };
		case "pause_turn":
			return { stopReason: "stop" };
		case "stop_sequence":
			return { stopReason: "stop" };
		case "sensitive":
			return { stopReason: "error", errorMessage: "Provider stopped with: sensitive" };
		default:
			throw new Error(`Unhandled stop reason: ${reason}`);
	}
}

/**
 * The authoritative parse of a finished tool call's argument text, mirroring
 * `parseToolCallArguments` (packages/ai/src/utils/json-parse.ts): a
 * malformed object is reported on the block, never silently emptied.
 */
function finishToolCallArguments(text) {
	if (text == null || text.trim() === "") return { arguments: {} };
	try {
		const parsed = JSON.parse(text);
		if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
			throw new Error("Tool arguments must be a JSON object");
		}
		return { arguments: parsed };
	} catch (error) {
		return {
			arguments: {},
			argumentsError: `${error.message}\n\nReceived arguments:\n${text}`,
		};
	}
}

function mapOpenAiStopReason(reason) {
	if (reason === null) return { stopReason: "stop" };
	switch (reason) {
		case "stop":
		case "end":
			return { stopReason: "stop" };
		case "length":
			return { stopReason: "length" };
		case "function_call":
		case "tool_calls":
			return { stopReason: "toolUse" };
		case "content_filter":
			return { stopReason: "error", errorMessage: "Provider finish_reason: content_filter" };
		case "network_error":
			return { stopReason: "error", errorMessage: "Provider finish_reason: network_error" };
		default:
			return { stopReason: "error", errorMessage: `Provider finish_reason: ${reason}` };
	}
}

function parseChunkUsage(rawUsage) {
	const promptTokens = rawUsage.prompt_tokens || 0;
	const cacheReadTokens =
		rawUsage.prompt_tokens_details?.cached_tokens ?? rawUsage.prompt_cache_hit_tokens ?? rawUsage.cached_tokens ?? 0;
	const cacheWriteTokens = rawUsage.prompt_tokens_details?.cache_write_tokens || 0;
	const input = Math.max(0, promptTokens - cacheReadTokens - cacheWriteTokens);
	const outputTokens = rawUsage.completion_tokens || 0;
	return {
		input,
		output: outputTokens,
		cacheRead: cacheReadTokens,
		cacheWrite: cacheWriteTokens,
		reasoning:
			(rawUsage.completion_tokens_details?.reasoning_tokens || 0) || (rawUsage.reasoning_tokens || 0) || undefined,
		totalTokens: input + outputTokens + cacheReadTokens + cacheWriteTokens,
	};
}

function runOpenAiStream(chunks, requestedModelId) {
	const message = {
		content: [],
		stopReason: "pending",
		usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, totalTokens: 0 },
	};
	const events = [];
	const toolStates = new Map(); // contentIndex -> { streamIndex, text }
	const byStreamIndex = new Map();
	const byId = new Map();
	let textBlock = null;
	let thinkingBlock = null;
	let hasFinishReason = false;
	return providerStreamOutcome(events, message, () => {
		for (const chunk of chunks) {
			if (chunk.id && !message.responseId) message.responseId = chunk.id;
			if (
				typeof chunk.model === "string" &&
				chunk.model.length > 0 &&
				message.responseModel === undefined &&
				chunk.model !== requestedModelId
			) {
				message.responseModel = chunk.model;
			}
			if (chunk.usage) message.usage = parseChunkUsage(chunk.usage);

			const choice = Array.isArray(chunk.choices) ? chunk.choices[0] : undefined;
			if (!choice) continue;
			if (!chunk.usage && choice.usage) message.usage = parseChunkUsage(choice.usage);

			if (choice.finish_reason) {
				message.rawStopReason = choice.finish_reason;
				const mapped = mapOpenAiStopReason(choice.finish_reason);
				message.stopReason = mapped.stopReason;
				if (mapped.errorMessage) message.errorMessage = mapped.errorMessage;
				hasFinishReason = true;
			}

			const delta = choice.delta;
			if (!delta) continue;

			const reasoningFields = ["reasoning_content", "reasoning", "reasoning_text"];
			let foundReasoningField = null;
			for (const field of reasoningFields) {
				const value = delta[field];
				if (typeof value === "string" && value.length > 0) {
					foundReasoningField = field;
					break;
				}
			}
			if (foundReasoningField) {
				const thinkingDelta = delta[foundReasoningField];
				if (!thinkingBlock) {
					thinkingBlock = { type: "thinking", thinking: "", thinkingSignature: foundReasoningField };
					message.content.push(thinkingBlock);
					events.push({ type: "thinking_start", contentIndex: message.content.length - 1 });
				}
				thinkingBlock.thinking += thinkingDelta;
				events.push({ type: "thinking_delta", contentIndex: message.content.length - 1, delta: thinkingDelta });
			}

			if (delta.content !== null && delta.content !== undefined && delta.content.length > 0) {
				if (!textBlock) {
					textBlock = { type: "text", text: "" };
					message.content.push(textBlock);
					events.push({ type: "text_start", contentIndex: message.content.length - 1 });
				}
				textBlock.text += delta.content;
				events.push({ type: "text_delta", contentIndex: message.content.length - 1, delta: delta.content });
			}

			if (delta.tool_calls) {
				for (const toolCall of delta.tool_calls) {
					const streamIndex = typeof toolCall.index === "number" ? toolCall.index : undefined;
					const function_ = toolCall.function ?? {};
					const name = function_.name ?? "";
					let contentIndex =
						streamIndex !== undefined ? byStreamIndex.get(streamIndex) : undefined;
					contentIndex ??= toolCall.id ? byId.get(toolCall.id) : undefined;
					let state;
					if (contentIndex === undefined) {
						const block = {
							type: "toolCall",
							id: toolCall.id || "",
							name,
							arguments: {},
						};
						message.content.push(block);
						contentIndex = message.content.length - 1;
						state = { streamIndex, text: "" };
						toolStates.set(contentIndex, state);
						if (streamIndex !== undefined) byStreamIndex.set(streamIndex, contentIndex);
						if (toolCall.id) byId.set(toolCall.id, contentIndex);
						events.push({ type: "toolcall_start", contentIndex });
					} else {
						state = toolStates.get(contentIndex);
						if (streamIndex !== undefined && state.streamIndex === undefined) {
							state.streamIndex = streamIndex;
							byStreamIndex.set(streamIndex, contentIndex);
						}
					}
					const block = message.content[contentIndex];
					if (toolCall.id && !block.id) {
						block.id = toolCall.id;
						byId.set(toolCall.id, contentIndex);
					}
					if (!block.name && name) block.name = name;
					let deltaText = "";
					if (typeof function_.arguments === "string") {
						deltaText = function_.arguments;
						state.text += deltaText;
						try {
							block.arguments = JSON.parse(state.text);
						} catch {
							// Partial JSON never becomes the final arguments.
						}
					}
					events.push({ type: "toolcall_delta", contentIndex, delta: deltaText });
				}
			}
		}
		for (let contentIndex = 0; contentIndex < message.content.length; contentIndex++) {
			const block = message.content[contentIndex];
			if (block.type === "text") {
				events.push({ type: "text_end", contentIndex, content: block.text });
			} else if (block.type === "thinking") {
				events.push({ type: "thinking_end", contentIndex, content: block.thinking });
			} else if (block.type === "toolCall") {
				const state = toolStates.get(contentIndex);
				const finished = finishToolCallArguments(state?.text ?? "");
				block.arguments = finished.arguments;
				if (finished.argumentsError !== undefined) block.argumentsError = finished.argumentsError;
				events.push({ type: "toolcall_end", contentIndex, toolCall: canonicalBlock(block) });
			}
		}
		if (message.stopReason === "aborted") throw new Error("Request was aborted");
		if (!hasFinishReason) {
			message.stopReason = message.content.some((b) => b.type === "toolCall") ? "toolUse" : "stop";
		}
		if (message.stopReason === "error") {
			throw new Error(message.errorMessage || "Provider returned an error stop reason");
		}
		if (message.stopReason === "pending") throw new Error("Stream ended without finish_reason");
	});
}

function mapGoogleStopReason(reason) {
	switch (reason) {
		case "STOP":
			return { stopReason: "stop" };
		case "MAX_TOKENS":
		case "CONTINUATION":
			return { stopReason: "length" };
		case "BLOCKLIST":
		case "PROHIBITED_CONTENT":
		case "SPII":
		case "SAFETY":
		case "IMAGE_SAFETY":
		case "IMAGE_PROHIBITED_CONTENT":
		case "IMAGE_RECITATION":
		case "IMAGE_OTHER":
		case "RECITATION":
		case "FINISH_REASON_UNSPECIFIED":
		case "OTHER":
		case "LANGUAGE":
		case "MALFORMED_FUNCTION_CALL":
		case "UNEXPECTED_TOOL_CALL":
		case "TOO_MANY_TOOL_CALLS":
		case "NO_IMAGE":
		case "MISSING_THOUGHT_SIGNATURE":
		case "MALFORMED_RESPONSE":
		case "ESCALATION":
		case "PUP_LIMITED_DISABLED":
		case "MODEL_ARMOR":
			return { stopReason: "error" };
		default:
			return { stopReason: "error", errorMessage: `Provider stopped with: ${reason}` };
	}
}

function formatGooglePromptBlockError(providerName, feedback) {
	const details = [`${providerName} prompt blocked: ${feedback.blockReason ?? "unknown reason"}`];
	if (feedback.blockReasonMessage) details.push(feedback.blockReasonMessage);
	if (feedback.safetyRatings?.length) {
		for (const rating of feedback.safetyRatings) {
			if (!rating.category) continue;
			details.push(rating.probability ? `${rating.category} (${rating.probability})` : rating.category);
		}
	}
	return details.join(" ");
}

function runGoogleStream(chunks, requestedModelId) {
	const message = {
		content: [],
		stopReason: "pending",
		usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, totalTokens: 0 },
	};
	const events = [];
	let currentBlock = null;
	let receivedChunkCount = 0;
	let promptBlockError;
	let toolCallCounter = 0;
	return providerStreamOutcome(events, message, () => {
		for (const chunk of chunks) {
			receivedChunkCount++;
			if (chunk.promptFeedback?.blockReason) {
				promptBlockError ??= formatGooglePromptBlockError("Google", chunk.promptFeedback);
			}
			if (chunk.responseId && !message.responseId) message.responseId = chunk.responseId;
			if (
				typeof chunk.modelVersion === "string" &&
				chunk.modelVersion.length > 0 &&
				message.responseModel === undefined &&
				chunk.modelVersion !== requestedModelId
			) {
				message.responseModel = chunk.modelVersion;
			}
			const candidate = chunk.candidates?.[0];
			if (candidate?.content?.parts) {
				for (const part of candidate.content.parts) {
					if (part.text !== undefined) {
						const isThinking = part.thought === true;
						if (!currentBlock || (isThinking && currentBlock.type !== "thinking") || (!isThinking && currentBlock.type !== "text")) {
							if (currentBlock) {
								const contentIndex = message.content.length - 1;
								if (currentBlock.type === "text") {
									events.push({ type: "text_end", contentIndex, content: currentBlock.text });
								} else {
									events.push({ type: "thinking_end", contentIndex, content: currentBlock.thinking });
								}
							}
							if (isThinking) {
								currentBlock = { type: "thinking", thinking: "", thinkingSignature: undefined };
								message.content.push(currentBlock);
								events.push({ type: "thinking_start", contentIndex: message.content.length - 1 });
							} else {
								currentBlock = { type: "text", text: "" };
								message.content.push(currentBlock);
								events.push({ type: "text_start", contentIndex: message.content.length - 1 });
							}
						}
						const blockIndex = message.content.length - 1;
						if (currentBlock.type === "thinking") {
							currentBlock.thinking += part.text;
							if (currentBlock.thinkingSignature === undefined && part.thoughtSignature) {
								currentBlock.thinkingSignature = part.thoughtSignature;
							}
							events.push({ type: "thinking_delta", contentIndex: blockIndex, delta: part.text });
						} else {
							currentBlock.text += part.text;
							events.push({ type: "text_delta", contentIndex: blockIndex, delta: part.text });
						}
					}

					if (part.functionCall) {
						if (currentBlock) {
							const contentIndex = message.content.length - 1;
							if (currentBlock.type === "text") {
								events.push({ type: "text_end", contentIndex, content: currentBlock.text });
							} else {
								events.push({ type: "thinking_end", contentIndex, content: currentBlock.thinking });
							}
							currentBlock = null;
						}
						const providedId = part.functionCall.id;
						const needsNewId = !providedId || message.content.some((b) => b.type === "toolCall" && b.id === providedId);
						const name = part.functionCall.name || "";
						const toolCallId = needsNewId ? `${name}_${Date.now()}_${++toolCallCounter}` : providedId;
						const toolCall = {
							type: "toolCall",
							id: toolCallId,
							name,
							arguments: part.functionCall.args ?? {},
						};
						message.content.push(toolCall);
						const contentIndex = message.content.length - 1;
						events.push({ type: "toolcall_start", contentIndex });
						events.push({ type: "toolcall_delta", contentIndex, delta: JSON.stringify(toolCall.arguments) });
						events.push({ type: "toolcall_end", contentIndex, toolCall: canonicalBlock(toolCall) });
					}
				}
			}

			if (candidate?.finishReason) {
				message.rawStopReason = candidate.finishReason;
				const mapped = mapGoogleStopReason(candidate.finishReason);
				message.stopReason = mapped.stopReason;
				if (mapped.errorMessage) message.errorMessage = mapped.errorMessage;
				if (message.content.some((b) => b.type === "toolCall") && message.stopReason === "stop") {
					message.stopReason = "toolUse";
				}
			}

			if (chunk.usageMetadata) {
				const cached = num(chunk.usageMetadata.cachedContentTokenCount);
				const thoughts = num(chunk.usageMetadata.thoughtsTokenCount);
				message.usage = {
					input: num(chunk.usageMetadata.promptTokenCount) - cached,
					output: num(chunk.usageMetadata.candidatesTokenCount) + thoughts,
					cacheRead: cached,
					cacheWrite: 0,
					reasoning: thoughts || undefined,
					totalTokens: num(chunk.usageMetadata.totalTokenCount),
				};
			}
		}
		if (currentBlock) {
			const contentIndex = message.content.length - 1;
			if (currentBlock.type === "text") {
				events.push({ type: "text_end", contentIndex, content: currentBlock.text });
			} else {
				events.push({ type: "thinking_end", contentIndex, content: currentBlock.thinking });
			}
		}
		if (message.stopReason === "pending") {
			if (promptBlockError) throw new Error(promptBlockError);
			const chunkLabel = receivedChunkCount === 1 ? "chunk" : "chunks";
			throw new Error(
				`Google stream ended without a finish reason after receiving ${receivedChunkCount} ${chunkLabel}`,
			);
		}
		if (message.stopReason === "aborted" || message.stopReason === "error") {
			throw new Error(
				message.rawStopReason ? `Provider stopped with: ${message.rawStopReason}` : "An unknown error occurred",
			);
		}
	});
}

function mapMistralStopReason(reason) {
	if (reason === null) return { stopReason: "stop" };
	switch (reason) {
		case "stop":
			return { stopReason: "stop" };
		case "length":
		case "model_length":
			return { stopReason: "length" };
		case "tool_calls":
			return { stopReason: "toolUse" };
		default:
			return { stopReason: "error", errorMessage: `Provider stopped with: ${reason}` };
	}
}

function runMistralStream(chunks) {
	const message = {
		content: [],
		stopReason: "pending",
		usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, totalTokens: 0 },
	};
	const events = [];
	let currentBlock = null;
	const toolCallsByKey = new Map();
	const finishCurrentBlock = () => {
		if (!currentBlock) return;
		const contentIndex = message.content.length - 1;
		if (currentBlock.type === "text") {
			events.push({ type: "text_end", contentIndex, content: currentBlock.text });
		} else {
			events.push({ type: "thinking_end", contentIndex, content: currentBlock.thinking });
		}
		currentBlock = null;
	};
	const applyTextDelta = (textDelta) => {
		if (!textDelta) return;
		if (!currentBlock || currentBlock.type !== "text") {
			finishCurrentBlock();
			currentBlock = { type: "text", text: "" };
			message.content.push(currentBlock);
			events.push({ type: "text_start", contentIndex: message.content.length - 1 });
		}
		currentBlock.text += textDelta;
		events.push({ type: "text_delta", contentIndex: message.content.length - 1, delta: textDelta });
	};
	const applyThinkingDelta = (thinkingDelta) => {
		if (!thinkingDelta) return;
		if (!currentBlock || currentBlock.type !== "thinking") {
			finishCurrentBlock();
			currentBlock = { type: "thinking", thinking: "" };
			message.content.push(currentBlock);
			events.push({ type: "thinking_start", contentIndex: message.content.length - 1 });
		}
		currentBlock.thinking += thinkingDelta;
		events.push({ type: "thinking_delta", contentIndex: message.content.length - 1, delta: thinkingDelta });
	};
	return providerStreamOutcome(events, message, () => {
		for (const chunk of chunks) {
			if (chunk.id && !message.responseId) message.responseId = chunk.id;

			if (chunk.usage) {
				const promptTokens = chunk.usage.prompt_tokens || 0;
				const rawCached =
					chunk.usage.promptTokensDetails?.cachedTokens ??
					chunk.usage.prompt_tokens_details?.cached_tokens ??
					chunk.usage.numCachedTokens ??
					chunk.usage.num_cached_tokens ??
					0;
				const cachedPromptTokens = Math.min(
					promptTokens,
					Math.max(0, typeof rawCached === "number" && Number.isFinite(rawCached) ? rawCached : 0),
				);
				message.usage.input = Math.max(0, promptTokens - cachedPromptTokens);
				message.usage.output = chunk.usage.completion_tokens || 0;
				message.usage.cacheRead = cachedPromptTokens;
				message.usage.cacheWrite = 0;
				message.usage.totalTokens =
					chunk.usage.total_tokens ||
					message.usage.input + message.usage.output + message.usage.cacheRead + message.usage.cacheWrite;
			}

			const choice = chunk.choices[0];
			if (!choice) continue;

			if (choice.finish_reason) {
				message.rawStopReason = choice.finish_reason;
				const mapped = mapMistralStopReason(choice.finish_reason);
				message.stopReason = mapped.stopReason;
				if (mapped.errorMessage) message.errorMessage = mapped.errorMessage;
			}

			const delta = choice.delta ?? {};
			const content = delta.content;

			if (content !== null && content !== undefined) {
				const contentItems = typeof content === "string" ? [content] : content;
				for (const item of contentItems) {
					if (typeof item === "string") {
						applyTextDelta(item);
						continue;
					}
					if (item.type === "thinking") {
						const deltaText = (item.thinking ?? [])
							.map((part) => part.text ?? "")
							.filter((text) => text.length > 0)
							.join("");
						applyThinkingDelta(deltaText);
						continue;
					}
					if (item.type === "text") {
						applyTextDelta(item.text ?? "");
					}
				}
			}

			const toolCalls = delta.tool_calls || [];
			for (const toolCall of toolCalls) {
				if (currentBlock) finishCurrentBlock();
				const callId =
					toolCall.id && toolCall.id !== "null"
						? toolCall.id
						: `toolcall:${toolCall.index ?? 0}`;
				const key = toolCall.index ?? callId;
				let open = toolCallsByKey.get(key);
				if (!open) {
					message.content.push({ type: "toolCall", id: callId, name: toolCall.function.name, arguments: {} });
					open = { contentIndex: message.content.length - 1, text: "" };
					toolCallsByKey.set(key, open);
					events.push({ type: "toolcall_start", contentIndex: open.contentIndex });
				}
				const argsDelta =
					typeof toolCall.function.arguments === "string"
						? toolCall.function.arguments
						: JSON.stringify(toolCall.function.arguments || {});
				open.text += argsDelta;
				try {
					message.content[open.contentIndex].arguments = JSON.parse(open.text);
				} catch {
					// Partial JSON never becomes the final arguments.
				}
				events.push({ type: "toolcall_delta", contentIndex: open.contentIndex, delta: argsDelta });
			}
		}
		finishCurrentBlock();
		for (const open of toolCallsByKey.values()) {
			const block = message.content[open.contentIndex];
			const finished = finishToolCallArguments(open.text);
			block.arguments = finished.arguments;
			if (finished.argumentsError !== undefined) block.argumentsError = finished.argumentsError;
			events.push({ type: "toolcall_end", contentIndex: open.contentIndex, toolCall: canonicalBlock(block) });
		}
		if (message.stopReason === "pending") throw new Error("Mistral stream ended without a finish reason");
		if (message.stopReason === "aborted" || message.stopReason === "error") {
			throw new Error(message.errorMessage || "An unknown error occurred");
		}
	});
}

function runProviderStream(scenario) {
	const kind = scenario.kind;
	if (kind.startsWith("provider-stream.anthropic")) {
		return runAnthropicStream(decodeSse(readCassette(scenario)), scenario.requested_model_id);
	}
	// The chunk-based providers ride data-only SSE frames; the cassette holds
	// one JSON payload per `data:` line, with the `[DONE]` sentinel filtered.
	const chunks = decodeSse(readCassette(scenario))
		.filter((sse) => sse.data !== "[DONE]")
		.map((sse) => JSON.parse(sse.data));
	if (kind.startsWith("provider-stream.openai")) {
		return runOpenAiStream(chunks, scenario.requested_model_id);
	}
	if (kind.startsWith("provider-stream.google")) {
		return runGoogleStream(chunks, scenario.requested_model_id);
	}
	if (kind.startsWith("provider-stream.mistral")) {
		return runMistralStream(chunks);
	}
	throw new Error(`unsupported provider-stream kind: ${kind}`);
}

// ---------------------------------------------------------------------------
// Provider error / retry / identity utilities (packages/ai/src/utils/*).
// ---------------------------------------------------------------------------

const MAX_PROVIDER_ERROR_BODY_CHARS = 4000;

function normalizeProviderError(error) {
	if (error === null || typeof error !== "object") {
		return { message: safeJsonStringify(error), messageCarriesBody: false };
	}
	const status = extractStatus(error);
	const body = extractBody(error);
	const messageText = typeof error.message === "string" && error.message.length > 0 ? error.message : safeJsonStringify(error);
	const messageCarriesBody = body === undefined || messageText.includes(body);
	return { status, body, message: messageText, messageCarriesBody };
}

function extractStatus(error) {
	if (typeof error.statusCode === "number") return error.statusCode;
	if (typeof error.status === "number") return error.status;
	if (typeof error.$metadata?.httpStatusCode === "number") return error.$metadata.httpStatusCode;
	if (typeof error.$response?.statusCode === "number") return error.$response.statusCode;
	return undefined;
}

function extractBody(error) {
	const bodyText = pickBodyText(error);
	if (bodyText === undefined) return undefined;
	const trimmed = bodyText.trim();
	if (trimmed.length === 0) return undefined;
	return truncateErrorText(trimmed, MAX_PROVIDER_ERROR_BODY_CHARS);
}

function pickBodyText(error) {
	if (typeof error.body === "string") return error.body;
	if (isPlainNonEmptyObject(error.error)) return safeJsonStringify(error.error);
	const responseBody = error.$response?.body;
	if (typeof responseBody === "string") return responseBody;
	if (isPlainNonEmptyObject(responseBody)) return safeJsonStringify(responseBody);
	return undefined;
}

function isPlainNonEmptyObject(value) {
	if (typeof value !== "object" || value === null) return false;
	return Object.keys(value).length > 0;
}

function formatProviderError(norm, prefix) {
	if (norm.messageCarriesBody || norm.status === undefined || norm.body === undefined) {
		return prefix !== undefined && norm.status !== undefined
			? `${prefix} (${norm.status}): ${norm.message}`
			: norm.message;
	}
	return prefix !== undefined ? `${prefix} (${norm.status}): ${norm.body}` : `${norm.status}: ${norm.body}`;
}

function truncateErrorText(text, maxChars) {
	if (text.length <= maxChars) return text;
	return `${text.slice(0, maxChars)}... [truncated ${text.length - maxChars} chars]`;
}

function safeJsonStringify(value) {
	try {
		const serialized = JSON.stringify(value);
		return serialized === undefined ? String(value) : serialized;
	} catch {
		return String(value);
	}
}

function runProviderErrorBody(scenario) {
	const records = [];
	for (const entry of scenario.errors ?? []) {
		const norm = normalizeProviderError(entry.error);
		const display = formatProviderError(norm, entry.prefix);
		records.push({
			type: "provider_error",
			status: norm.status ?? null,
			body: norm.body ?? null,
			messageCarriesBody: norm.messageCarriesBody,
			display,
		});
	}
	return records;
}

function retryDelayMs(policy, attempt) {
	const delay = policy.baseDelayMs * 2 ** Math.max(0, attempt - 1);
	const safeDelay = Number.isSafeInteger(delay) ? delay : Number.MAX_SAFE_INTEGER;
	return Math.min(safeDelay, policy.maxAgentDelayMs ?? 60_000);
}

function isRetryableAssistantError(message) {
	if (message.stopReason !== "error" || !message.errorMessage) return false;
	const errorMessage = message.errorMessage;
	if (NON_RETRYABLE_PROVIDER_LIMIT_ERROR_PATTERN.test(errorMessage)) return false;
	return RETRYABLE_PROVIDER_ERROR_PATTERN.test(errorMessage);
}

const buildProviderErrorPattern = (patterns) => new RegExp(patterns.join("|"), "i");

const NON_RETRYABLE_PROVIDER_LIMIT_ERROR_PATTERN = buildProviderErrorPattern([
	"GoUsageLimitError",
	"FreeUsageLimitError",
	"Monthly usage limit reached",
	"available balance",
	"insufficient_quota",
	"out of budget",
	"quota exceeded",
	"billing",
	"subscription_sharing_usage_limit_exceeded",
	"subscription_sharing_workplace_individual_usage_limit_exceeded",
	'"code"\\s*:\\s*"?1308(?![0-9])',
]);

const RETRYABLE_PROVIDER_ERROR_PATTERN = buildProviderErrorPattern([
	"overloaded",
	"server_busy",
	"servers are currently busy",
	"currently experiencing high demand",
	"model is at capacity",
	"admission ceiling",
	"rate.?limit",
	"too many requests",
	"rate increased too quickly",
	"(?<![a-z0-9])(?:429|500|502|503|504|520|524|525)(?![a-z0-9])",
	"service.?(?:is.?)?(?:temporarily.?)?unavailable",
	"provider.?(?:is.?)?temporarily.?unavailable",
	"server.?error",
	"internal.?error",
	"provider.?returned.?(?:an.?)?error",
	'"type"\\s*:\\s*"api_error"',
	"exceeded request buffer limit while retrying upstream",
	"unable to forward upstream",
	"upstream.?request.?failed",
	"upstream_stream_read_error",
	"stream was interrupted",
	"http/?2 stream failed",
	"network.?error",
	"connection.?error",
	"connection.?refused",
	"connection.?lost",
	"connection.?closed",
	"other side closed",
	"fetch failed",
	"request to \\S+ failed, reason:",
	"getaddrinfo",
	"(?<![a-z0-9_])(?:ECONNRESET|ECONNABORTED|ECONNREFUSED|ETIMEDOUT|EPIPE)(?![a-z0-9_])",
	"connection reset by peer",
	"ENOTFOUND",
	"EAI_AGAIN",
	"upstream.?connect",
	"reset before headers",
	"socket hang up",
	"socket connection was closed",
	"timed? out",
	"timeout",
	"terminated",
	"websocket.?closed",
	"websocket.?error",
	"websocket.?connection.?limit.?reached",
	"ended without",
	"stream ended before message_stop",
	"stream ended before a terminal response event",
	"http2 request did not get a response",
	"provider finish_reason: error",
	"provider stopped with: error",
	"returned an empty response",
	"stopped before completing the response",
	"stream disconnected before completion",
	"cut short after the reply had begun",
	"ended the response before it was complete",
	"connection to the provider was reset",
	"reported a failure while generating the response",
	"pending stream has been canceled",
	"retry delay",
	"you can retry your request",
	"try your request again",
	"please retry your request",
	"repeat the request later",
	"ResourceExhausted",
	"subscription_sharing_usage_unavailable",
	"subscription_sharing_user_unavailable",
]);

function runProviderRetry(scenario) {
	const policy = scenario.policy;
	const responses = scenario.responses ?? [];
	const maxAttempts = policy?.enabled ? policy.maxRetries : 0;
	const records = [];
	let attempt = 0;
	let calls = 0;
	let lastRetry;
	for (;;) {
		const response = responses[Math.min(calls, responses.length - 1)];
		calls++;
		records.push({ type: "produce", call: calls, stopReason: response.stopReason, errorMessage: response.errorMessage ?? null });
		if (response.stopReason === "aborted") {
			if (lastRetry) records.push({ type: "retry_finished", success: false, attempt: lastRetry.attempt });
			return records;
		}
		if (response.stopReason !== "error") {
			if (lastRetry) records.push({ type: "retry_finished", success: true, attempt: lastRetry.attempt });
			return records;
		}
		if (attempt >= maxAttempts || !isRetryableAssistantError(response)) {
			if (lastRetry) {
				records.push({
					type: "retry_finished",
					success: false,
					attempt: lastRetry.attempt,
					finalError: response.errorMessage ?? null,
				});
			}
			return records;
		}
		attempt++;
		lastRetry = { attempt, errorMessage: response.errorMessage || "Unknown error" };
		const delayMs = retryDelayMs(policy, attempt);
		records.push({
			type: "retry_scheduled",
			attempt,
			maxAttempts,
			delayMs,
			errorMessage: lastRetry.errorMessage,
		});
	}
}

// identity.ts ----------------------------------------------------------------

const PI_AI_VERSION = "1.6.0";
const PI_ATTRIBUTION = { name: "pi", url: "https://pi.dev", categories: ["cli-agent"] };

function formatUserAgent(identity, runtime) {
	const mode = identity?.userAgent ?? "detailed";
	if (typeof mode === "object") return mode.custom;
	if (mode === "short") return "pi";
	const product = `pi/${identity?.version ?? PI_AI_VERSION}`;
	const runtimeDescription = runtime?.runtime ?? undefined;
	if (!runtimeDescription) return `${product} (browser)`;
	return `${product} (${runtime.platform}; ${runtimeDescription}; ${runtime.arch})`;
}

function matchesHost(baseUrl, expectedHost) {
	try {
		return new URL(baseUrl).hostname === expectedHost;
	} catch {
		return false;
	}
}

function isOpenRouter(target) {
	return target.provider === "openrouter" || target.baseUrl.includes("openrouter.ai");
}

function isNvidiaNim(target) {
	return target.provider === "nvidia" || matchesHost(target.baseUrl, "integrate.api.nvidia.com");
}

function isOpenCode(target) {
	return (
		target.provider === "opencode" || target.provider === "opencode-go" || matchesHost(target.baseUrl, "opencode.ai")
	);
}

function getAttributionHeaders(target, identity) {
	const attribution = identity?.attribution;
	if (!attribution) return {};
	const { name, url, categories } = attribution;
	if (isOpenRouter(target)) {
		return {
			"HTTP-Referer": url,
			"X-OpenRouter-Title": name,
			...(categories === undefined || categories.length === 0
				? {}
				: { "X-OpenRouter-Categories": categories.join(",") }),
		};
	}
	if (isNvidiaNim(target)) return { "X-BILLING-INVOKE-ORIGIN": name.charAt(0).toUpperCase() + name.slice(1) };
	if (isOpenCode(target)) return { "x-opencode-client": name };
	return {};
}

function getOpenCodeSessionHeaders(target, sessionId) {
	return sessionId && isOpenCode(target) ? { "x-opencode-session": sessionId } : undefined;
}

function runProviderIdentity(scenario) {
	const records = [];
	for (const entry of scenario.requests ?? []) {
		const identity = entry.identity
			? {
					userAgent: entry.identity.user_agent,
					attribution: entry.identity.attribution,
					version: entry.identity.version,
				}
			: undefined;
		const userAgent = formatUserAgent(identity, entry.runtime);
		const target = {
			provider: entry.target.provider,
			baseUrl: entry.target.base_url,
		};
		const attribution = getAttributionHeaders(target, identity);
		const session = getOpenCodeSessionHeaders(target, entry.session_id);
		records.push({
			type: "request_identity",
			userAgent,
			attribution: Object.keys(attribution).length > 0 ? attribution : null,
			session: session ?? null,
		});
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
	const normalized = normalizeOutcome(normalizeGeneratedToolCallIds(raw));
	process.stdout.write(toJsonl(normalized));
}

main();
