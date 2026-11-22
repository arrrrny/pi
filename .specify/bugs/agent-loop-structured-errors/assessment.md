# Bug Assessment: surface agent-loop failures as structured terminal errors

- **Slug**: agent-loop-structured-errors
- **Created**: 2026-11-22
- **Source**: https://github.com/arrrrny/pi/issues/5
- **Verdict**: valid
- **Severity**: high (no `severity:*` label on the issue; assessed here)

## Report (verbatim or summarized)

Dart-port parity defect. Unexpected agent-loop failures can disappear without
an error event or a structured assistant error message. In `pi_agent`, the
stream-body wrapper `_streamFromAsync` catches every error from the asynchronous
loop body and discards it (`catch (_) {}` at `agent_loop.dart:656-660`). The
high-level `Agent._run` catch at `agent.dart:372-380` stores only
`state.errorMessage` and emits `AgentEnd` — but the stream-level swallow means
`await for` in `_run` never sees the exception, so even that catch never
fires for loop-body failures. The `StopReason` enum also lacks upstream's
`error` and `aborted` values, and `AssistantMessage` has no `errorMessage`
field.

Full text: https://github.com/arrrrny/pi/issues/5

The issue cites Dart commit `1d62d46d9b3ba09c22a2f38fc94e46693ea1cc03` and
upstream commit `780bf31fcaeb252fa9b68df3964c735eae75bde3`. Both commits are
reachable from the current tree. The line numbers in the report match the
current source at `HEAD` (`a14c81d99`).

**Depends on**: arrrrny/pi#6 (`provider-failure-error-outcomes`, assessed
`valid` in this tree). That bug covers provider/network failures encoded as
`StopReason.refused` + text content in `llm_client.dart`. This bug covers the
loop-level structured error path: even after #6 is fixed, `_streamFromAsync`
still swallows errors that escape the loop body, and the `Agent._run` catch
still lacks the structured message/turn/agent-end event sequence that upstream
emits. #6 fixes *what* `streamLLM` produces; this bug fixes *how the loop
surfaces* a failure that reaches it.

## Symptom

When an unexpected error escapes the agent loop body (e.g. a throw from a
transform context, a tool-execution internal error, or a stream function that
throws rather than returning a stream), the error is silently discarded by
`_streamFromAsync`'s `catch (_) {}`. No `AgentEnd` with an error message is
emitted, no structured assistant message with `stopReason: "error"` (or
`"aborted"`) and `errorMessage` is added to the transcript, and
`state.errorMessage` remains `null`. The caller receives a normal-looking
completion with no indication that anything failed.

Upstream converts a run failure into an assistant message with empty text,
`stopReason: "error"` (or `"aborted"` if the run was aborted), and
`errorMessage`, then emits `message_start` → `message_end` → `turn_end` →
`agent_end` so the failure is observable through both the event stream and the
final agent state. Dart currently loses that outcome.

## Reproduction

1. Construct an `Agent` whose default stream path (`turnLoop` →
   `_streamFromAsync`) throws inside the loop body — for example, a
   `transformContext` that throws, or a custom `LoopStreamFn` that throws
   after being wrapped by `turnLoop`.
2. Call `agent.prompt('...')` and await it.
3. Observe: `agent.state.errorMessage` is `null`, no `MessageEnd` carrying a
   structured error assistant message is emitted, and the event sequence
   ends with a bare `AgentEnd` (or no `AgentEnd` at all if the throw happens
   before the loop's `emit(AgentEnd(...))`).

The existing test at `pi_agent/test/agent_test.dart:436-442` injects
`streamFn: (ctx, config) => Stream.error(Exception('boom'))` directly on the
`Agent`. That bypasses `_streamFromAsync` entirely (the direct `streamFn` is
called as-is at `agent.dart:362-363`, not through `turnLoop`), so the error
propagates to `Agent._run`'s catch and the test passes. The bug is that the
**default path** (when no `streamFn` is set, or when `loopStreamFn` is used
via `_defaultStreamFn`) wraps everything in `_streamFromAsync`, which
swallows the error before it can reach `_run`'s catch.

## Suspected Code Paths

- `pi_agent/lib/src/agent_loop.dart:647-663` — `_streamFromAsync`: wraps the
  loop body in `Future.microtask` with `catch (_) {}` that discards all
  errors. This is the primary swallow point. The comment says "the loop
  already emitted an error message" but the loop has no such path for
  non-tool-call errors — `_runLoop` only emits error tool *results*, not
  error assistant messages.
- `pi_agent/lib/src/agent.dart:344-380` — `Agent._run`: the `await for`
  loop at 365-369 consumes the stream from `_defaultStreamFn` (which uses
  `turnLoop` → `_streamFromAsync`). When `_streamFromAsync` swallows the
  error, `await for` completes normally, the catch at 372-380 never fires,
  and only a bare `AgentEnd` is emitted at 371. Even when the catch *does*
  fire (direct `streamFn` path), it only sets `state.errorMessage` and emits
  `AgentEnd` — it does not emit `MessageStart`/`MessageEnd`/`TurnEnd` with a
  structured error assistant message, unlike upstream's `handleRunFailure`.
- `pi_agent/lib/src/types.dart:38-53` — `StopReason` enum: missing `error`
  and `aborted` values (has `endTurn, maxTokens, toolUse, stopSequence,
  refused`). Upstream `packages/ai/src/types.ts:499` defines
  `StopReason = "pending" | "stop" | "length" | "toolUse" | "error" | "aborted" | "deferred"`.
- `pi_agent/lib/src/types.dart:226-253` — `AssistantMessage` class: no
  `errorMessage` field. Upstream `packages/ai/src/types.ts:420` defines
  `readonly errorMessage?: string` on `AssistantMessage`.
- `packages/agent/src/agent.ts:517-558` (upstream reference) —
  `runWithLifecycle` + `handleRunFailure`: catches errors from the executor,
  builds an assistant message with `stopReason: aborted ? "aborted" : "error"`
  and `errorMessage`, then emits `message_start` → `message_end` →
  `turn_end` → `agent_end`.
- `packages/agent/src/agent.ts:604-607` (upstream reference) —
  `processEvents`: on `turn_end`, copies `errorMessage` from the assistant
  message into `state.errorMessage`.
- `packages/agent/test/agent.test.ts:331-360` (upstream reference) — the
  "emits full lifecycle events for thrown run failures" test: verifies the
  event sequence, `stopReason === "error"`, `errorMessage`, and
  `state.errorMessage` after a thrown `streamFn`.
- `packages/agent/test/agent.test.ts:435-471` (upstream reference) — abort
  signal propagation to subscribers.

## Root Cause Hypothesis

The Dart port implemented `_streamFromAsync` as a "fire and forget" wrapper
that closes the stream controller in a `finally` block and discards any error
with `catch (_) {}`. The intent was to prevent unhandled exceptions from
escaping the microtask, but the effect is that errors from the loop body
(LLM stream, transform context, tool execution internals) never reach the
caller. The `Agent._run` catch was written as a backstop, but it cannot fire
for errors swallowed upstream. The `StopReason` and `AssistantMessage` types
were ported without the `error`/`aborted` values and `errorMessage` field
that upstream uses to encode structured terminal failures.

**Confidence: high.** The code paths are directly readable, the issue's line
references match the current tree, and the upstream reference is clear.

## Proposed Remediation

**Preferred**: Port upstream's structured error handling in two parts:

1. **Stop swallowing stream-body errors in `_streamFromAsync`.** Replace
   `catch (_) {}` with either (a) re-throwing after closing the controller
   (so `Agent._run`'s `await for` sees the error), or (b) emitting a
   structured error event sequence before closing. Option (a) is simpler and
   matches the existing `Agent._run` catch structure; option (b) is closer to
   upstream's `handleRunFailure` but requires the loop to know how to build
   an error assistant message. The minimal fix is (a): re-throw after
   closing the controller so `Agent._run`'s catch fires.

2. **Port `handleRunFailure` semantics into `Agent._run`'s catch.** Instead
   of only setting `state.errorMessage` and emitting `AgentEnd`, build an
   `AssistantMessage` with:
   - `content: [TextBlock('')]` (empty text)
   - `stopReason: StopReason.aborted` (if `abortSignal.isCompleted`) or
     `StopReason.error` (new enum value)
   - `errorMessage: e.toString()` (new field on `AssistantMessage`)
   Then emit `MessageStart` → `MessageEnd` → `TurnEnd` → `AgentEnd` with that
   message, matching upstream's event sequence at `agent.ts:554-557`.

3. **Add `StopReason.error` and `StopReason.aborted`** to
   `pi_agent/lib/src/types.dart:38-53`.

4. **Add `errorMessage` field to `AssistantMessage`** at
   `pi_agent/lib/src/types.dart:226-253`, and update `Agent._handleEvent`
   (agent.dart:383-399) to copy it into `state.errorMessage` on
   `MessageEnd` or `TurnEnd` (matching upstream's `processEvents` at
   agent.ts:604-607).

**Files likely to change**:
- `pi_agent/lib/src/agent_loop.dart` — `_streamFromAsync` (lines 647-663):
  stop swallowing, re-throw or emit structured error.
- `pi_agent/lib/src/agent.dart` — `_run` catch (lines 372-380): build
  structured error assistant message and emit the full event sequence;
  `_handleEvent` (lines 383-399): handle `errorMessage` from assistant
  messages.
- `pi_agent/lib/src/types.dart` — `StopReason` enum (lines 38-53): add
  `error`, `aborted`; `AssistantMessage` class (lines 226-253): add
  `errorMessage` field.
- `pi_agent/test/agent_test.dart` — replace/augment the error-handling
  tests (lines 435-452) with structured-error tests that verify the full
  event sequence, `stopReason`, and `errorMessage`.
- `pi_agent/test/agent_loop_test.dart` — add tests for throwing stream
  functions and throwing listeners (per the issue's "Required port
  coverage").

**Tests to add or update**:
- Throwing stream function through the **default** path (not direct
  `streamFn`): verify `state.errorMessage` is set, a `MessageEnd` with a
  structured error assistant message is emitted, and the event sequence
  includes `TurnEnd` + `AgentEnd`.
- Throwing listener: verify the error is observable (matching upstream's
  "throws on listener" test if present).
- Abort differentiation: verify `stopReason === StopReason.aborted` when
  the abort signal is completed, vs `StopReason.error` otherwise.
- `StopReason` round-trip in `session_storage.dart:456` (which iterates
  `StopReason.values`): verify new values serialize/deserialize correctly.

## Risks & Considerations

- **Breaking change**: adding `errorMessage` to `AssistantMessage` and new
  `StopReason` values is additive, not breaking — existing code that
  doesn't use them continues to work. But `StopReason` serialization in
  `session_storage.dart` must handle the new values.
- **Double emission risk**: if `_streamFromAsync` both emits a structured
  error *and* re-throws, `Agent._run`'s catch could emit a second set of
  error events. The remediation must choose one path: either the loop emits
  the structured error (option b) and `_run`'s catch becomes a no-op for
  already-handled errors, or `_streamFromAsync` re-throws (option a) and
  `_run`'s catch builds the structured message. Option (a) is simpler and
  avoids double emission.
- **Interaction with #6**: #6 changes what `streamLLM` produces for
  provider failures (structured error outcome instead of text +
  `refused`). This bug changes how the loop surfaces errors that reach it.
  They are complementary: #6 fixes the *source*, this bug fixes the *sink*.
  The dependency is correct — #6 should land first so that the common
  provider-failure case produces a proper error stream that the loop can
  relay, and this bug then covers the remaining cases where the loop body
  itself throws.
- **Existing test at agent_test.dart:436-442** uses a direct `streamFn`
  that bypasses `_streamFromAsync`. It should be kept (it tests the direct
  path) but supplemented with a test that exercises the default path.

## Open Questions

- None. The issue's evidence is precise, the code paths are confirmed, and
  the upstream reference is clear.