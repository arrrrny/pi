# Bug Assessment: dart-port preserve malformed tool-call argumentsError instead of silent empty arguments

- **Slug**: malformed-toolcall-arguments
- **Created**: 2026-11-22
- **Source**: https://github.com/arrrrny/pi/issues/4
- **Verdict**: valid
- **Severity**: high
- **URL Trust Policy**: `github.com` (host: `github.com`) — `allowlisted`; fetched via `gh issue view` (no redirect following).

## Report (verbatim or summarized)

Dart-port parity defect: malformed tool-call JSON is silently decoded as an empty argument map, losing upstream's `argumentsError` diagnostic and allowing the call to continue without the parse failure being visible.

Actual:
- `pi_agent/lib/src/llm_client.dart:251-258` (`_decodeArguments`) returns `{}` when the argument buffer is malformed JSON **or** is valid JSON that is not an object (scalar/array/null root). The `catch (_)` swallows the parse error and the `decoded is Map<String, dynamic> ? decoded : {}` ternary discards non-object roots — neither path leaves a diagnostic behind.
- `pi_agent/lib/src/types.dart:178-194` (`ToolCallBlock`) carries `id`, `name`, `arguments` only — there is no `argumentsError` field, so downstream code cannot distinguish "model sent malformed args" from "model sent a legitimately empty object".

Expected (upstream behavior):
- `packages/ai/src/utils/json-parse.ts:106-120` (`parseToolCallArguments`) returns `arguments: {}` **plus** `argumentsError` on failure. The error string is `` `${message}\n\nReceived arguments:\n${json}` `` and is only set for malformed/non-object input; empty/whitespace text yields `{arguments: {}}` with no error. It also runs `parseJsonWithRepair` first, so a repairable escape is fixed rather than rejected.
- `packages/ai/src/utils/streaming-json.ts:452-500` (`ToolCallArgumentsStream`) keeps partial streaming arguments (via a `StreamingJsonParser`) separate from the final text; `finish()` at `:485-487` does **one** full `parseToolCallArguments` pass on the complete text, so partial snapshots never leak into the final `arguments`.
- `packages/ai/src/utils/validation.ts:54-57` (`validateToolArguments`) checks `toolCall.argumentsError` first and **throws** `Invalid arguments for tool "<name>": <argumentsError>` before any schema validation or execution — the fail-closed behavior.

Upstream also uses `{}` as the placeholder; the missing diagnostic, the missing repair attempt, and the missing fail-closed gate are the Dart-port gaps.

Evidence reviewed at Dart commit `1d62d46d9b3ba09c22a2f38fc94e46693ea1cc03` and upstream commit `780bf31fcaeb252fa9b68df3964c735eae75bde3`. Independently re-verified against the current checkout on 2026-11-22 (all cited line numbers confirmed accurate).

## Symptom

When the model emits tool-call arguments that are not a valid JSON object (malformed JSON, a scalar root like `42`, an array root like `[1,2]`, or a truncated buffer), the Dart agent silently substitutes `arguments = {}` and then **executes the tool with empty arguments**. No diagnostic is recorded, no validation fails, and the parse error is invisible to the caller, to the transcript, and to the model — so a malformed call runs as if the model had sent a valid empty object.

## Reproduction

1. Stream a tool call whose `function.arguments` deltas do not concatenate to a valid JSON object (e.g. `{"p` truncated at finish, or `not json`, or `[1,2]`).
2. Observe `pi_agent/lib/src/llm_client.dart:105` builds the `ToolCallBlock` with `arguments: _decodeArguments(tcb.argumentsBuffer)`.
3. `_decodeArguments` (`:251-258`) returns `{}` — no error, no marker.
4. In the agent loop, `_prepareToolCall` (`pi_agent/lib/src/agent_loop.dart:448-492`) reads `toolCall.arguments` (now `{}`), runs `prepareArguments` / `beforeToolCall`, and returns `_Prepared.ok` with empty args.
5. `_executeTool` runs the tool with `{}`. A tool whose schema marks its parameters required should reject `{}` — but the loop never calls the schema validator, so execution proceeds anyway.

Expected: steps 3–5 must not reach execution with silently-empty args; the call must fail closed with a diagnostic that names the parse problem and the received text.

## Suspected Code Paths

- `pi_agent/lib/src/llm_client.dart:251-258` — `_decodeArguments`: the single point where malformed and non-object roots collapse to `{}` with no diagnostic. This is the parse-layer gap.
- `pi_agent/lib/src/llm_client.dart:99-109` — the call site that wraps `_decodeArguments` into `ToolCallBlock(...)`; no `argumentsError` is threaded through.
- `pi_agent/lib/src/types.dart:178-194` — `ToolCallBlock`: missing the upstream `argumentsError?: string` field that `packages/ai/src/types.ts:466` declares.
- `pi_agent/lib/src/agent_loop.dart:424-492` — `_prepareToolCall`: resolves the tool and runs `prepareArguments` / `beforeToolCall` but never checks an `argumentsError` and never calls `validateParameters`. This is the fail-closed gap.
- `pi_agent/lib/src/agent_loop.dart:188-191` — the only fail-closed path today is `_failTruncatedToolCalls`, and it triggers solely on `stopReason == StopReason.maxTokens`. A malformed-arguments call that streams to `endTurn` / `toolUse` bypasses it.
- `pi_agent/lib/src/tools.dart:63-76` — `validateParameters` exists and is unit-tested (`pi_agent/test/tools_test.dart:82+`) but is **never called from the agent loop** (`grep -rn validateParameters pi_agent/lib/` returns only its own definition). The validator is dead code in the execution path.
- `pi_agent/test/llm_client_test.dart:117-171` — the only tool-call argument test covers the happy path (a valid object split across deltas). No test covers malformed JSON, scalar/array roots, truncated buffers, or repair behavior.

## Root Cause Hypothesis

The Dart port implemented the streaming accumulator (`_ToolCallBuffer` + `_accumulateToolCall` at `llm_client.dart:232-249`) but stopped short of porting the three upstream pieces that turn raw argument text into a fail-closed result:

1. **No `argumentsError` diagnostic.** `_decodeArguments` is a bare `try/catch` that returns `{}` on any failure, mirroring neither the "empty text → `{}` with no error" distinction nor the "malformed → `{}` + `argumentsError`" distinction that `parseToolCallArguments` makes (`json-parse.ts:106-120`). There is no repair pass (`parseJsonWithRepair`) and no "must be a JSON object" rejection.
2. **No `argumentsError` on `ToolCallBlock`.** The Dart `ToolCallBlock` (`types.dart:178-194`) was ported before upstream added the field (`types.ts:466`), so the diagnostic has nowhere to live even if the parser produced one.
3. **No fail-closed validation gate.** Upstream `validateToolArguments` (`validation.ts:54-57`) throws on `argumentsError` first; the Dart `_prepareToolCall` has no equivalent check, and the existing `validateParameters` schema validator is not wired into the loop at all. So even the partial protection a schema check would give (rejecting `{}` for a tool with required params) is absent.

Confidence: **high** — every cited line was read directly in the current checkout; the absence of `argumentsError` across `pi_agent/lib/` and the absence of any `validateParameters` caller in `pi_agent/lib/` were both confirmed by repository-wide grep.

## Proposed Remediation

**Preferred** (minimal, port-faithful, fail-closed):

1. **Add `argumentsError` to the Dart `ToolCallBlock`.** In `pi_agent/lib/src/types.dart:178-194`, add a nullable `final String? argumentsError;` field with a doc comment mirroring `packages/ai/src/types.ts:462-466`. Keep `arguments` as the placeholder `{}` when set (upstream parity — `arguments` is not nullable). Make the constructor parameter optional (`this.argumentsError`) so existing call sites compile unchanged.

2. **Port `parseToolCallArguments` into Dart (with repair).** Add a `parseToolCallArguments(String? text)` helper (in `llm_client.dart` next to `_decodeArguments`, or a small new `pi_agent/lib/src/json_parse.dart` to mirror the upstream module boundary) that:
   - Returns `{arguments: {}}` (no error) when `text` is null/empty/whitespace — matches `json-parse.ts:107`.
   - Attempts a Dart equivalent of `parseJsonWithRepair` first (port `repairJson` from `json-parse.ts:1-96`, or at minimum attempt `jsonDecode` and on `FormatException` fall through to the error branch — the repair pass is the upstream behavior, so porting it preserves the "repair valid escapes" case the upstream test at `json-parse.test.ts:26-31` covers).
   - Rejects non-object roots: if the decoded value is not a `Map<String, dynamic>`, treat it as failure with message `"Tool arguments must be a JSON object"` — matches `json-parse.ts:110-112` and the upstream test at `json-parse.test.ts:51-55`.
   - On any failure, returns `arguments: {}` **and** `argumentsError` set to `` `${message}\n\nReceived arguments:\n${text}` `` — matches `json-parse.ts:114-118`.

3. **Thread `argumentsError` into the `ToolCallBlock`.** Replace the `_decodeArguments(tcb.argumentsBuffer)` call at `llm_client.dart:105` with a call to the new `parseToolCallArguments`, and pass both `arguments:` and `argumentsError:` into `ToolCallBlock`. Delete `_decodeArguments` (it becomes the failure branch of the new helper) so there is one parse path.

4. **Add the fail-closed gate for `argumentsError` in `_prepareToolCall`.** In `pi_agent/lib/src/agent_loop.dart:448-492`, before reading `toolCall.arguments` for `prepareArguments`, check `toolCall.argumentsError`: if non-null, return `_Prepared.immediate(_errorResult('Invalid arguments for tool "${toolCall.name}": ${toolCall.argumentsError}'))` — the Dart equivalent of the `argumentsError`-only branch of `validation.ts:54-57`. This gate must run **before** `prepareArguments` and `beforeToolCall` so a malformed call never reaches the tool's own arg-prep or the user's hook.

5. **Persist `argumentsError` through session serialization/resume.** Extend the `ToolCallBlock` JSON mapping in `pi_agent/lib/src/session_storage.dart:410-433` so the diagnostic round-trips:
   - In `_contentBlockToJson` (the `ToolCallBlock` pattern at `:410`), add `'argumentsError': argumentsError` (omit or emit `null` when unset).
   - In `_contentBlockFromJson` (the `'toolCall'` case at `:425-432`), read `json['argumentsError'] as String?` and pass it to the `ToolCallBlock` constructor.

   Without this, a tool call that failed parse in run N loses its diagnostic when the session is resumed, and a resumed run could re-enter `_prepareToolCall` with `argumentsError == null` and the placeholder `{}` — silently re-introducing the fail-open path the gate just closed. This is the persistence requirement: `argumentsError` MUST survive serialization/resume when tool calls are persisted.

**Out of scope (belongs to dependent pi#3, not pi#4)**: wiring the schema validator `validateParameters` into `_prepareToolCall` (the former step 5) and any argument coercion/ordering work. That is pi#3's deliverable (`packages/agent/src/agent-loop.ts:708-778` + `packages/ai/src/utils/validation.ts:54-68` — the schema half of `validateToolArguments`), and pi#3 already declares `Depends on: arrrrny/pi#4` for exactly this reason: pi#4 lands the `argumentsError` diagnostic + fail-closed gate first, and pi#3 layers schema validation on top. Porting `validateParameters` here would overlap pi#3's diff and invert the declared dependency. pi#4's fail-closed guarantee is therefore: **malformed / non-object / truncated argument text never reaches `prepareArguments` or execution**, enforced by the `argumentsError` gate alone. A wrong-but-parseable object (e.g. `{"path": 123}` for a `string` param) still executes under pi#4 and is rejected under pi#3 — that is the agreed split.

**Alternatives considered and rejected**:
- **Minimal-only without persistence (steps 1–4, skip 5).** Fixes the live parse gap but leaves `argumentsError` dropped on resume, so a resumed session can silently lose the diagnostic and re-enter the fail-open path. Rejected — persistence is required, not optional, because the defect class (silent `{}` on malformed input) re-appears on resume.
- **Full upstream port (steps 1–5 + port `ToolCallArgumentsStream`).** Port `streaming-json.ts:452-500` as a Dart `ToolCallArgumentsStream` so partial snapshots are kept separate from final args at the provider/stream layer, not just at the final-parse point. Trade-off: largest diff; the Dart `llm_client.dart` already buffers raw argument text in `_ToolCallBuffer.argumentsBuffer` and only parses once at the end (`:99-109`), so the "partials separate from final" property already holds structurally — the `ToolCallArgumentsStream` abstraction would be parity-for-parity's-sake, not a behavior fix. Rejected for pi#4; revisit only if a streaming-partials bug surfaces.
- **Wiring `validateParameters` in pi#4 (former step 5).** Rejected — overlaps pi#3's scope and violates the declared `Depends on: arrrrny/pi#4` direction. See the out-of-scope note above.

**Files likely to change**:
- `pi_agent/lib/src/types.dart` (add `argumentsError` to `ToolCallBlock`).
- `pi_agent/lib/src/llm_client.dart` (replace `_decodeArguments` with `parseToolCallArguments`; thread `argumentsError` into `ToolCallBlock`).
- `pi_agent/lib/src/json_parse.dart` (new; if the repair + parse helper is factored out to mirror upstream's module boundary — optional).
- `pi_agent/lib/src/agent_loop.dart` (fail-closed gate for `argumentsError` in `_prepareToolCall`; no `validateParameters` wiring — that is pi#3).
- `pi_agent/lib/src/session_storage.dart` (round-trip `argumentsError` in `_contentBlockToJson` / `_contentBlockFromJson`).
- `pi_agent/test/llm_client_test.dart` (malformed/non-object/truncated/repair argument tests).
- `pi_agent/test/agent_loop_test.dart` (fail-closed: a malformed call must not reach tool execution).
- `pi_agent/test/session_storage_test.dart` (or existing session round-trip test: `argumentsError` survives serialize/deserialize).

**Tests to add or update** (mirroring the upstream `packages/ai/test/json-parse.test.ts:25-55` cases):
1. **Empty text → `{}` no error.** `parseToolCallArguments('')` and `parseToolCallArguments(null)` yield `arguments: {}`, `argumentsError: null` — `json-parse.test.ts:32-34`.
2. **Repair valid escapes.** Input with an invalid `\u`/`\url`-style escape that `parseJsonWithRepair` fixes yields the repaired object, no error — `json-parse.test.ts:26-31`.
3. **Malformed JSON → `{}` + `argumentsError` with received text.** Input like `{"path":` truncated at finish yields `arguments: {}` and `argumentsError` ending with the raw input — `json-parse.test.ts:36-42`.
4. **Non-object root (array) rejected.** `[1,2]` yields `arguments: {}` and `argumentsError` containing `"Tool arguments must be a JSON object"` plus the received text — `json-parse.test.ts:51-55`.
5. **Scalar root rejected.** `42` / `"x"` / `true` / `null` each yield `arguments: {}` + `argumentsError` (same non-object branch).
6. **Fail-closed in the loop.** Construct an agent loop with a tool whose streamed arguments are malformed; assert the tool's `execute` is **never called**, `prepareArguments` is **never invoked**, `beforeToolCall` is **never invoked**, and the tool result is an error naming the parse problem — the core regression test.
7. **`argumentsError` survives session resume.** Serialize a session containing a `ToolCallBlock` with `argumentsError` set, deserialize it, and assert the round-tripped block carries the same `argumentsError`; then drive the resumed loop and assert the fail-closed gate still triggers (the tool does not execute). This is the persistence regression test.
8. **Characterization of existing `prepareArguments` implementations (verification, not a question).** Audit every tool that supplies a `prepareArguments` callback and add a characterization test asserting that, post-fix, `prepareArguments` is **not** invoked for a malformed-arguments call (the gate short-circuits before it). Any tool whose characterization test shows it depended on receiving `{}` for malformed input is a signal to audit that tool's contract — but the fix does not change `prepareArguments` itself, only the order of the gate in front of it.
9. **Truncated-call streaming (optional, parity with `streaming-json.test.ts`).** Only if the `ToolCallArgumentsStream` port is later done (currently rejected for pi#4): assert partial snapshots do not leak into the final `arguments`.

## Risks & Considerations

- **`argumentsError` is additive, not breaking** — `ToolCallBlock`'s new field is nullable and optional in the constructor; existing call sites and tests compile unchanged. No migration needed.
- **Behavioral change for any caller relying on the (incorrect) silent-`{}`-and-execute behavior** — a tool that today runs with `{}` on malformed input will now receive an error result. That is the defect being fixed; the blast radius is "tools whose arguments the model malformed", which is exactly the population that should not have executed.
- **Repair pass changes which inputs are accepted** — porting `parseJsonWithRepair` means some inputs that `jsonDecode` would reject today (invalid escapes) will now parse successfully, matching upstream. This is upstream parity, not a regression, but it is a behavior change worth noting in the changelog.
- **Session serialization must carry `argumentsError` (persistence is required, not optional).** `session_storage.dart:410-433` currently serializes `arguments` but has no slot for the diagnostic. If pi#4 adds the field to `ToolCallBlock` without extending the JSON mapping, a session saved after a malformed call and resumed later would deserialize the `ToolCallBlock` with `argumentsError == null`, and `_prepareToolCall` would see a "clean" call with placeholder `{}` — silently re-opening the fail-open path the gate just closed. The fix therefore includes the `session_storage.dart` round-trip (step 5). This is additive (a new optional JSON key); old sessions without the key deserialize to `null`, which is the safe default (no diagnostic, so no false fail-closed).
- **Schema validation/coercion is pi#3's risk, not pi#4's.** Wiring `validateParameters` is explicitly out of pi#4's scope (see "Out of scope" in Proposed Remediation). pi#3 owns the risk that a stricter validator rejects previously-working calls; pi#4 only ensures malformed input never reaches `prepareArguments` or execution, via the `argumentsError` gate. Keeping the two changes separate means each can be reverted independently.
- **Severity is high, not critical** — no data loss, no crash; but the agent silently takes wrong actions (tools run with empty args) on malformed model output, which in an agentic loop can produce misleading tool results the model then reasons over. The fail-open nature is the aggravating factor.

## Resolved Scope Decisions

The four open questions are resolved by the scope boundaries set for this assessment: **pi#4** = parse repair + `argumentsError` diagnostic + fail-closed gate on `argumentsError` + session persistence; **pi#3** = schema validation/coercion (`Depends on: arrrrny/pi#4`).

- **Repair pass (`parseJsonWithRepair`) — PORT IT in pi#4.** Upstream-faithful, and the issue's "upstream-equivalent tests for repair behavior" requires it. The jsonDecode-only alternative leaves a known divergence from `json-parse.ts:1-96` and fails the repair test case. Decision: port `repairJson` as part of step 2.

- **Schema validator (`validateParameters` wiring) — DEFER to pi#3; do not ship in pi#4.** Schema validation/coercion is pi#3's deliverable (`packages/agent/src/agent-loop.ts:708-778` + `packages/ai/src/utils/validation.ts:54-68`, the schema half of `validateToolArguments`), and pi#3 already declares `Depends on: arrrrny/pi#4` for exactly this reason. Shipping `validateParameters` here would overlap pi#3's diff and invert the declared dependency direction. pi#4's fail-closed guarantee is scoped to the `argumentsError` gate: malformed / non-object / truncated argument text never reaches `prepareArguments` or execution. A wrong-but-parseable object still executes under pi#4 and is rejected under pi#3 — that is the agreed split.

- **`argumentsError` persistence — REQUIRED in pi#4.** `argumentsError` MUST survive Dart session serialization/resume when tool calls are persisted. Without the `session_storage.dart` round-trip (step 5), a resumed run deserializes a `ToolCallBlock` with `argumentsError == null` and placeholder `{}`, silently re-introducing the fail-open path. Persistence is therefore part of the fix, not a follow-up. The added JSON key is optional, so old sessions deserialize to `null` (the safe default).

- **Existing `prepareArguments` implementations — audit as part of fix verification, not a blocking question.** Audit every tool that supplies a `prepareArguments` callback and add characterization coverage (test 8) asserting `prepareArguments` is not invoked for a malformed-arguments call after the fix. The fix does not change `prepareArguments` itself, only the gate order in front of it; a tool whose characterization test shows it depended on receiving `{}` for malformed input is a signal to audit that tool's contract during verification, not an unresolved design question.