# Bug Issue: dart-port: map provider failures to error outcomes, not assistant text

- **Slug**: provider-failure-error-outcomes
- **Fetched**: 2026-11-22
- **Issue**: 6
- **URL**: https://github.com/arrrrny/pi/issues/6
- **State**: open
- **Severity**: unknown
- **Author**: arrrrny
- **Labels**: bug, dart-port, pkg:agent, pkg:ai

## Body

## Dart-port parity defect

Provider/network failures are encoded as ordinary assistant text with `StopReason.refused`, rather than upstream's structured provider-error outcome.

### Actual

`pi_agent/lib/src/llm_client.dart:46-56` maps non-200 responses to `TextBlock('LLM error: ...')` plus `StopReason.refused`; `:121-127` does the same for other request failures. This makes transport/provider failure look like model-authored content and conflates it with refusal.

### Expected (upstream behavior)

`packages/ai/src/api/openai-completions.ts:696-713` sets `stopReason` to `error` (or `aborted`), stores the diagnostic in `errorMessage`, and emits an error event. `packages/agent/src/agent-loop.ts:250-265` terminates the run on those outcomes instead of treating them as ordinary assistant output.

### Required port coverage

- Add the upstream error model rather than embedding failures in text content.
- Preserve HTTP status/body diagnostics in `errorMessage` without labeling them model output.
- Distinguish provider errors, refusals/content filters, and caller aborts.
- Verify terminal event ordering and that no tool call executes after a failed provider response.
- Add tests for non-200 responses, transport exceptions, malformed SSE, aborts, and streams ending without a finish reason.

Evidence reviewed at Dart commit `1d62d46d9b3ba09c22a2f38fc94e46693ea1cc03` and upstream commit `780bf31fcaeb252fa9b68df3964c735eae75bde3`.

## Comments

None.