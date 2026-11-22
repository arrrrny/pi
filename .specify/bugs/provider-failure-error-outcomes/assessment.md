# Bug Assessment: dart-port: map provider failures to error outcomes, not assistant text

- **Slug**: provider-failure-error-outcomes
- **Created**: 2026-11-22
- **Source**: https://github.com/arrrrny/pi/issues/6
- **Verdict**: valid
- **Severity**: medium (no `severity:*` label on the issue; assessed here)

## Report (verbatim or summarized)

Dart-port parity defect. In `pi_agent`, provider and network failures are encoded
as ordinary assistant text (`TextBlock('LLM error: …')`) carrying
`StopReason.refused`, instead of upstream's structured provider-error outcome
(`stopReason: "error" | "aborted"` + an `errorMessage` field + a distinct stream
error event). This makes a transport/provider failure look like model-authored
content and conflates it with a genuine model refusal.

Full text: https://github.com/arrrrny/pi/issues/6

The issue cites Dart commit `1d62d46d9b3ba09c22a2f38fc94e46693ea1cc03` and
upstream commit `780bf31fcaeb252fa9b68df3964c735eae75bde3`. Both commits exist
in this repository. The Dart commit is an ancestor of `HEAD` and **no commit has
touched `pi_agent/` since it** (`git log 1d62d46..HEAD -- pi_agent` is empty), so
the Dart code at `HEAD` is byte-for-byte what the reporter reviewed. The
assessment below is therefore still accurate against the current tree; nothing has
moved under it.

## Symptom

When a provider returns a non-200 response (e.g. 401/403/500) or the request
fails at the transport layer (connection reset, DNS, TLS), `pi_agent`:

- appends the failure to the assistant transcript as model **text**
  (`TextBlock('LLM error: <status> - <body>')` / `TextBlock('LLM error: <e>')`), and
- tags it `StopReason.refused`.

A caller, a UI, or telemetry therefore cannot tell a provider outage apart from the
model choosing to refuse. `AgentState.errorMessage` — the field that exists to carry
this — is never populated on this path. Expected: a structured error outcome
(`stopReason: error`/`aborted`, populated `errorMessage`, error stream event) that
terminates the run without rendering the failure as if the model wrote it.

## Reproduction

1. Point `pi_agent` at an OpenAI-compatible endpoint that returns a non-200
   (e.g. `GET`/`POST /chat/completions` → 401 with a body), via
   `Model.baseUrl`.
2. Run a turn (`Agent.prompt` / `agentLoop`).
3. Observe the assistant message: `message.text` contains `"LLM error: 401 - …"`
   and `message.stopReason == StopReason.refused`. `agent.state.errorMessage` is
   `null`.

(Transport failure: same, with `TextBlock('LLM error: <exception>')` — point
`baseUrl` at a closed port or a host that resets the connection.)

The existing Dart test already demonstrates the current behavior as "expected":
`pi_agent/test/llm_client_test.dart:173-193` ("surfaces non-200 as a refused
message") asserts `msg.stopReason == StopReason.refused` and
`msg.text` contains `'401'`.

## Suspected Code Paths

Dart (the defect):

- `pi_agent/lib/src/llm_client.dart:46-57` — non-200 branch: reads the error body
  and `yield MessageEnd(AssistantMessage(content:[TextBlock('LLM error: <status> - <body>')], stopReason: StopReason.refused))`, then `return`. (Issue cites `:46-56`; the branch is 46-57.)
- `pi_agent/lib/src/llm_client.dart:121-127` — catch-all: `yield MessageEnd(AssistantMessage(content:[TextBlock('LLM error: $e')], stopReason: StopReason.refused))` for any other request failure (transport exceptions, etc.).
- `pi_agent/lib/src/llm_client.dart:91-93` — per-chunk `catch (_) { continue; }` silently swallows malformed SSE frames.
- `pi_agent/lib/src/llm_client.dart:111-118` — final `MessageEnd` uses `stopReason ?? StopReason.endTurn`, so a stream that ends without a finish reason is reported as a normal `endTurn`.
- `pi_agent/lib/src/llm_client.dart:119-120` — `on http.RequestAbortedException {}` yields nothing (abort via `client.close()`).
- `pi_agent/lib/src/llm_client.dart:96` — `if (aborted) return;` yields nothing on caller abort.
- `pi_agent/lib/src/types.dart:38-53` — `StopReason` enum is `{ endTurn, maxTokens, toolUse, stopSequence, refused }`. There is **no `error` and no `aborted`** variant, so the client has nothing to encode an error outcome with.
- `pi_agent/lib/src/types.dart:226-253` — `AssistantMessage` has no `errorMessage` field. (`AgentState.errorMessage` does exist at `types.dart:476`, but see below.)
- `pi_agent/lib/src/agent_loop.dart:178-182` — terminates the run on `assistant.stopReason == StopReason.refused || (abortSignal?.isCompleted ?? false)`. Because every provider/transport failure is `refused`, this is the only thing stopping the loop — i.e. it terminates by accident of the mislabel, not by a modeled error outcome. The condition does not mention error/aborted.
- `pi_agent/lib/src/agent.dart:344-381` — `_run()` sets `_state.errorMessage = e.toString()` **only** in the `catch` at line 373, i.e. only when the event stream throws. `streamLLM` never throws on provider failure (it yields a `MessageEnd`), so `AgentState.errorMessage` stays `null` for every non-200/transport failure. Abort (line 366) just `break`s and also leaves `errorMessage` null.

Upstream (the intended behavior this should match):

- `packages/ai/src/types.ts:499` — `StopReason = "pending" | "stop" | "length" | "toolUse" | "error" | "aborted" | "deferred"` (error/aborted are first-class).
- `packages/ai/src/types.ts:595-626` — `AssistantMessage` carries `stopReason: StopReason` (609) and `errorMessage?: string` (611).
- `packages/ai/src/types.ts:404-407` — the documented contract: *"Error termination must produce an AssistantMessage with stopReason `"error"` or `"aborted"` and `errorMessage`, emitted via the stream protocol."*
- `packages/ai/src/types.ts:844-849` — stream event union: normal completion is `{ type: "done"; reason: "stop"|"length"|"toolUse"|"deferred"; message }`; failure is a **distinct** `{ type: "error"; reason: "aborted"|"error"; error: AssistantMessage }`.
- `packages/ai/src/api/openai-completions.ts:677-713` — the catch path: `output.stopReason = options?.signal?.aborted ? "aborted" : "error"; output.errorMessage = formatProviderError(normalizeProviderError(error)); … stream.push({ type: "error", reason: output.stopReason, error: output }); stream.end();`. Lines 681-692 also turn `aborted`/`error`/`pending`/missing-finish-reason into a thrown error that lands in this catch.
- `packages/agent/src/agent-loop.ts:250-265` — `if (message.stopReason === "error" || message.stopReason === "aborted") { … emit turn_end; emit agent_end; return; }` — terminates on either outcome, with **no** tool execution and **no** further LLM call.

Upstream test evidence (both packages):

- `packages/ai/test/provider-error-body-regression.test.ts:140-147` — a 403-with-body through `openai-completions` yields `stopReason === "error"` and `errorMessage` containing both `"403"` and `"blocked by gateway WAF"` (and explicitly *not* just `"403 status code (no body)"`). This is the "preserve HTTP status/body diagnostics in `errorMessage`" requirement.
- `packages/ai/test/abort.test.ts`, `packages/ai/test/mistral-http-transport.test.ts`, `packages/ai/test/openai-completions-raw-stop-reason.test.ts`, `packages/ai/test/openai-responses-terminal-event.test.ts` — additional error/abort/terminal-event coverage in the AI layer.
- `packages/agent/test/agent.test.ts:344-360` — provider `"exploded"` → `lastMessage.stopReason === "error"`, `lastMessage.errorMessage === "provider exploded"`, `agent.state.errorMessage === "provider exploded"`, with the exact terminal event ordering `… message_end, turn_end, agent_end` and no tool events.
- `packages/agent/test/agent.test.ts:1071-1107` — `it.each(["error","aborted"])` parametrized coverage.
- `packages/agent/test/agent-loop.test.ts:1285-1338` — `it.each(["error","aborted"])`: ordering `["finishTurn","turn_end"]`, `providerCalls === 1`, `followUpPolls === 0` (hard exit, no follow-up turn).
- `packages/agent/test/e2e.test.ts:126-128` — aborted run: `lastMessage.stopReason === "aborted"`, `agent.state.errorMessage === lastMessage.errorMessage`.
- `packages/agent/test/proxy.test.ts:115-116` — proxy failure → `stopReason === "error"`, `errorMessage` contains `"Connection closed by proxy server"`.

## Root Cause Hypothesis

The Dart port modeled the *happy path* and the *stop reasons the model itself
produces* (`endTurn`/`maxTokens`/`toolUse`/`stopSequence`/`refused`) but never
ported the provider-error outcome. Concretely: `StopReason` (types.dart:38-53) has
no `error`/`aborted` member and `AssistantMessage` (types.dart:226-253) has no
`errorMessage` field, so `streamLLM` had no structured way to report a failure and
fell back to the only tool it had — text content plus the nearest existing reason,
`refused` (llm_client.dart:46-57, 121-127). The agent loop then "works" only because
it happens to stop on `refused` (agent_loop.dart:178). `AgentState.errorMessage`
exists (types.dart:476) and is wired only to the thrown-exception catch
(agent.dart:373), which the non-throwing provider-failure path never reaches.

**Confidence: high.** The mislabel, the missing enum/field, and the dead
`errorMessage` are all directly visible in source, and the upstream contract,
implementation, and tests that the port diverges from are unambiguous.

## Distinguishing upstream design from missing port coverage

This is a **missing port**, not a deliberate upstream design choice and not an
upstream bug:

- Upstream *by design* separates outcomes: `StopReason` carries `"error"` and
  `"aborted"` (types.ts:499), `AssistantMessage` carries `errorMessage`
  (types.ts:611), the stream protocol emits a distinct `{ type: "error" }` event
  (types.ts:849), and the loop hard-exits on either (agent-loop.ts:254-265). The
  contract is written down (types.ts:404-407) and pinned by tests in **both**
  packages (listed above).
- The Dart side has the *scaffolding* for the design but not the design:
  `AgentState.errorMessage` exists yet is unreachable from the failure path, and the
  one Dart test that touches non-200 (`llm_client_test.dart:173-193`) **asserts the
  conflation as correct** (`StopReason.refused` + text containing `'401'`). That is
  the signature of an incomplete port whose tests were written to match the port's
  behavior, not upstream's.
- Net: the divergence is entirely on the Dart side. Upstream is the reference; the
  fix is to bring `pi_agent` up to the upstream error model. There is nothing to
  change in `packages/ai` or `packages/agent`.

## Proposed Remediation

**Preferred (mirror upstream; minimal but complete):**

1. `pi_agent/lib/src/types.dart`
   - Add `error` and `aborted` to the `StopReason` enum (keep existing members).
   - Add `final String? errorMessage;` to `AssistantMessage` and a constructor
     parameter. (`AgentState.errorMessage` already exists.)
2. `pi_agent/lib/src/llm_client.dart`
   - Non-200 branch (46-57): instead of `TextBlock('LLM error: …') + refused`,
     emit `MessageEnd(AssistantMessage(content: const [], stopReason: StopReason.error, errorMessage: '<status> - <body>'))`. Keep the HTTP status and body in `errorMessage`, not in model text.
   - Catch-all (121-127): `stopReason: StopReason.error`, `errorMessage: '$e'`, empty content. Keep `on http.RequestAbortedException` (119-120) and the `aborted` early-return (96) mapping to `StopReason.aborted` (emit a terminal `MessageEnd` with `stopReason: aborted`, `errorMessage: 'Request aborted'`) so aborts are a distinct outcome rather than "no message".
   - Streams that end without a finish reason (currently defaulted to `endTurn` at 115) and malformed SSE (swallowed at 91-93): at minimum stop reporting a finish-reason-less, tool-capable provider as a clean `endTurn` — treat "ended without finish_reason" as `StopReason.error` with an explanatory `errorMessage`, matching openai-completions.ts:690-692. (This is the one sub-item that can be deferred if a smaller diff is wanted; see Alternatives.)
   - Leave `_parseStopReason` (261-267) mapping `content_filter → refused`; that is a genuine model refusal and must stay `refused`, distinct from `error`.
3. `pi_agent/lib/src/agent_loop.dart`
   - Line 178: terminate on `stopReason` ∈ {`refused`, `error`, `aborted`} (keep the `abortSignal?.isCompleted` check). Because error/aborted messages carry empty content, no tool call can execute after them — same guarantee as the current refused path, now for the right reason.
4. `pi_agent/lib/src/agent.dart`
   - In `_run()`, after the loop, set `_state.errorMessage` from the terminal `AssistantMessage.errorMessage` when present (so `Agent.state.errorMessage` matches upstream agent.test.ts:359 / e2e.test.ts:128). Keep the existing catch-path assignment.
5. `pi_agent/test/*` (see below).
6. `pi_agent/CHANGELOG.md` — `### Fixed` entry under `## [Unreleased]`.

**Alternatives:**

- *Smaller diff:* do only items 1–4 for the non-200 + transport-exception branches (and the `errorMessage` field), update the one existing test, and defer the "missing finish_reason / malformed SSE → error" strictness to a follow-up. Trade-off: smaller and faster, but a provider that ends a stream without a finish reason is still reported as a clean `endTurn`, and malformed SSE is still silently skipped — both of which the issue's required coverage list calls out.
- *Rejected — boolean/flag instead of enum members:* adding an `isError` flag without `StopReason.error`/`aborted` would avoid touching the enum, but it would not match the upstream model the issue asks to port, and it would lose the error/aborted/refused three-way distinction that the upstream tests (`it.each(["error","aborted"])`) are written against.

**Files likely to change:**

- `pi_agent/lib/src/types.dart`
- `pi_agent/lib/src/llm_client.dart`
- `pi_agent/lib/src/agent_loop.dart`
- `pi_agent/lib/src/agent.dart`
- `pi_agent/test/llm_client_test.dart`
- `pi_agent/test/agent_loop_test.dart`
- `pi_agent/test/agent_test.dart`
- `pi_agent/CHANGELOG.md`

**Tests to add or update:**

- `pi_agent/test/llm_client_test.dart:173-193` — rewrite "surfaces non-200 as a refused message" → "surfaces non-200 as an error outcome": assert `stopReason == StopReason.error`, `errorMessage` contains the status (`'401'`) and the body, and content carries **no** model `TextBlock` with the error.
- New: transport exception (e.g. a `streamFn`/server that errors) → `stopReason == StopReason.error`, `errorMessage` non-empty.
- New: stream ending without a finish reason → `StopReason.error` with an explanatory `errorMessage` (not `endTurn`).
- New: caller abort mid-stream → `StopReason.aborted`.
- `pi_agent/test/agent_loop_test.dart` — new test mirroring upstream agent-loop.test.ts:1285-1338: a `MessageEnd` with `stopReason: error` (and `aborted`) yields `turn_end` then `agent_end`, exactly one provider call, no tool execution, no follow-up turn.
- `pi_agent/test/agent_test.dart` — new test mirroring upstream agent.test.ts:357-359: a provider error (non-throwing, via `streamFn` returning a `MessageEnd` with `stopReason: error`/`errorMessage`) sets `agent.state.errorMessage`; keep the existing thrown-exception test (436-442) as the catch-path case.

## Risks & Considerations

- **Transcript shape changes.** Moving the diagnostic out of `TextBlock` into `errorMessage` means `message.text` is empty on provider failure. Any consumer that rendered/read the `"LLM error: …"` text (including the current test at llm_client_test.dart:192) must read `errorMessage` instead. This is the intended correction, but it is a user-visible change to the transcript.
- **Enum addition is additive and low-risk for compilation.** The only `switch` over `StopReason` in `pi_agent/lib` is `_parseStopReason` (llm_client.dart:261-267), which has a `_` default; `session_storage.dart:454-460` deserializes by iterating `StopReason.values` by name, so new members round-trip without change. Still sweep for any exhaustive `switch` outside `lib` (examples, harness) before merging — the analyzer will flag a non-exhaustive switch if one exists.
- **No API/DB migration.** `errorMessage`/`StopReason` serialize by name; old sessions deserialize fine (new names simply won't appear in old data).
- **No security/performance impact.** This is observability and correctness of error handling.
- **Behavior preserved where it matters:** the run still terminates on provider failure and no tool call executes after one — the fix makes that termination *modeled* rather than incidental.

## Scope decisions (resolved, defaults chosen)

- **Finish-reason-less streams / malformed SSE.** The preferred remediation treats
  a stream that ends without a finish reason, and malformed SSE, as
  `StopReason.error` with an explanatory `errorMessage` (full upstream parity,
  openai-completions.ts:690-692), because the issue's required-coverage list names
  both. A reviewer who wants the smallest possible diff may defer only this sub-item
  to a follow-up and keep the change to the non-200 + transport-exception branches;
  that trade-off is recorded under Proposed Remediation → Alternatives.
- **Abort shape.** The abort path emits a terminal `MessageEnd{stopReason:
  StopReason.aborted, errorMessage: 'Request aborted'}`, matching upstream's
  structured `"aborted"` message (agent.test.ts:444, e2e.test.ts:126-128), rather
  than staying message-less and letting the loop synthesize an empty `endTurn`.