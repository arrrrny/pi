/**
 * Normalization rules for the differential harness.
 *
 * Both the TypeScript side and the Dart side emit the same normalized JSONL
 * outcome; this module is the language-neutral contract that says how raw
 * events, transcripts, state, commits, errors, and usage are reduced to a
 * canonical form that can be compared byte-for-byte (FR-016, FR-017).
 *
 * The rules are versioned by `normalization_version`; a mismatch between a
 * golden's version and a scenario's version is reported as a version mismatch,
 * never as a behavioral divergence (contracts §9).
 */

/** Bump only when a normalization rule changes; goldens record their version. */
export const NORMALIZATION_VERSION = 1;

/** Replace a timestamp by its ordinal within the stream (first seen = 0). */
export function normalizeTimestamps(records) {
	const order = new Map();
	let next = 0;
	for (const record of records) {
		if (record.timestamp !== undefined && record.timestamp !== null) {
			const key = String(record.timestamp);
			if (!order.has(key)) order.set(key, next++);
		}
	}
	return records.map((record) => {
		if (record.timestamp === undefined || record.timestamp === null) return { ...record };
		const { timestamp, ...rest } = record;
		return { ...rest, timestamp: order.get(String(timestamp)) };
	});
}

/**
 * Replace generated IDs with role-based placeholders assigned in first-seen
 * order: `<commit-1>`, `<tool-call-1>`, `<turn-1>`. Free-form content is left
 * untouched; only values under `id` / `commit_id` / `tool_call_id` / `turn_id`
 * keys are rewritten.
 */
export function normalizeIds(records) {
	const counters = new Map();
	const seen = new Map();
	// `turn` is a control key for interleaving, not an ID field; it must survive
	// normalization so both sides can group by it.
	const roleFor = (key) => {
		if (key === "commit_id" || key === "commit") return "commit";
		if (key === "tool_call_id" || key === "toolCallId") return "tool-call";
		return "id";
	};
	return records.map((record) => {
		const out = { ...record };
		for (const key of Object.keys(out)) {
			if (out[key] === null || out[key] === undefined) continue;
			if (key === "id" || key === "commit_id" || key === "tool_call_id" || key === "commit" || key === "toolCallId") {
				const role = roleFor(key);
				const value = String(out[key]);
				if (!seen.has(value)) {
					const count = (counters.get(role) ?? 0) + 1;
					counters.set(role, count);
					seen.set(value, `<${role}-${count}>`);
				}
				out[key] = seen.get(value);
			}
		}
		return out;
	});
}

/**
 * Sort freely interleavable events inside one turn by `(name, canonical-json)`;
 * events across turns keep their order (data-model.md normalization rules).
 * A record carries a `turn` index; records without one are never reordered.
 */
export function normalizeInterleaving(records) {
	const byTurn = new Map();
	const order = [];
	for (const record of records) {
		const turn = record.turn ?? null;
		if (turn === null) {
			order.push({ turn: null, record });
			continue;
		}
		if (!byTurn.has(turn)) {
			byTurn.set(turn, []);
			order.push({ turn, records: byTurn.get(turn) });
		}
		byTurn.get(turn).push(record);
	}
	const out = [];
	for (const entry of order) {
		if (entry.turn === null) {
			out.push(entry.record);
		} else {
			const sorted = [...entry.records].sort((a, b) => {
				const nameDelta = String(a.name ?? "").localeCompare(String(b.name ?? ""));
				if (nameDelta !== 0) return nameDelta;
				return canonicalStringify(a).localeCompare(canonicalStringify(b));
			});
			out.push(...sorted);
		}
	}
	return out;
}

/** Canonical stringify: sorted object keys, compact separators. */
export function canonicalStringify(value) {
	if (value === null || typeof value !== "object") return JSON.stringify(value);
	if (Array.isArray(value)) return `[${value.map(canonicalStringify).join(",")}]`;
	const keys = Object.keys(value).sort();
	return `{${keys.map((key) => `${JSON.stringify(key)}:${canonicalStringify(value[key])}`).join(",")}}`;
}

/** Reduce an absolute path to a repo-relative one. */
export function normalizePath(path) {
	if (typeof path !== "string") return path;
	const marker = "/pi/";
	const index = path.indexOf(marker);
	if (index >= 0) return path.slice(index + marker.length);
	return path;
}

/**
 * Normalize a raw event stream into the canonical JSONL form. Each record is
 * emitted with a `seq` (1-based), a `type`, and its normalized payload; keys
 * are sorted so the output is byte-stable.
 */
export function normalizeOutcome(rawRecords) {
	let records = normalizeTimestamps(rawRecords);
	records = normalizeIds(records);
	records = normalizeInterleaving(records);
	return records.map((record, index) => {
		const normalized = { ...record };
		normalized.seq = index + 1;
		for (const key of Object.keys(normalized)) {
			if (typeof normalized[key] === "string" && normalized[key].startsWith("/")) {
				normalized[key] = normalizePath(normalized[key]);
			}
		}
		return normalized;
	});
}

/** Serialize normalized records as canonical JSONL (one compact object per line). */
export function toJsonl(records) {
	return records.map((record) => canonicalStringify(record)).join("\n");
}

/**
 * Diff two normalized outcomes (as arrays of records). Returns
 * `{ equal, differences: [{ index, left, right }] }`.
 */
export function diffOutcomes(left, right) {
	const differences = [];
	const length = Math.max(left.length, right.length);
	for (let index = 0; index < length; index += 1) {
		const leftRecord = left[index];
		const rightRecord = right[index];
		if (canonicalStringify(leftRecord) !== canonicalStringify(rightRecord)) {
			differences.push({ index, left: leftRecord ?? null, right: rightRecord ?? null });
		}
	}
	return { equal: differences.length === 0, differences };
}