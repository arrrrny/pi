# Bug Issue: surface agent-loop failures as structured terminal errors

- **Slug**: agent-loop-structured-errors
- **Fetched**: 2026-11-22T11:03:37Z
- **Issue**: 5
- **URL**: https://github.com/arrrrny/pi/issues/5
- **State**: open
- **Severity**: high (inferred from gh-triage engine; no `severity:*` label present on the issue)
- **Author**: arrrrny
- **Labels**: bug, dart-port, pkg:agent

## Body

## Dart-port parity defect

Unexpected agent-loop failures can disappear without an error event or a structured assistant error message.

### Actual

`pi_agent/lib/src/agent_loop.dart:647-660` catches every error from the asynchronous stream body and discards it (`catch (_) {}`). The high-level `Agent._run` catch at `pi_agent/lib/src/agent.dart:344-380` stores only `state.errorMessage` and emits `AgentEnd`; the stream-level swallow can prevent even that path from observing the failure. The current `StopReason` model also lacks upstream's `error` and `aborted` values.

### Expected (upstream behavior)

`packages/agent/src/agent.ts:517-558` converts a run failure into an assistant message with empty text, `stopReason: "error"` (or `"aborted"`), and `errorMessage`, then emits the message, turn, and agent-end events. `processEvents` copies the failure into agent state at `packages/agent/src/agent.ts:604-607`.

Upstream does not merely throw every failure to the caller; it preserves a structured, observable terminal outcome. Dart currently loses that outcome.

### Required port coverage

- Port structured assistant error semantics (`error`, `aborted`, `errorMessage`) before layering more behavior onto the loop.
- Do not silently swallow stream-body failures.
- Preserve the upstream event sequence and final agent-state error.
- Add tests using throwing stream functions and throwing listeners, including abort differentiation.

Evidence reviewed at Dart commit `1d62d46d9b3ba09c22a2f38fc94e46693ea1cc03` and upstream commit `780bf31fcaeb252fa9b68df3964c735eae75bde3`.


## Dependencies

Depends on: arrrrny/pi#6

## Comments

None.