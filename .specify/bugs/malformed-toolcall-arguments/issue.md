# Bug Issue: dart-port preserve malformed tool-call argumentsError instead of silent empty arguments

- **Slug**: malformed-toolcall-arguments
- **Fetched**: 2026-11-22
- **Issue**: 4
- **URL**: https://github.com/arrrrny/pi/issues/4
- **State**: open
- **Severity**: unknown
- **Author**: [fetched via gh]
- **Labels**: bug, dart-port, pkg:agent, pkg:ai

## Body

## Dart-port parity defect

Malformed tool-call JSON is silently decoded as an empty argument map, losing upstream's `argumentsError` diagnostic and allowing the call to continue without the parse failure being visible.

### Actual

`pi_agent/lib/src/llm_client.dart:251-258` returns `{}` when argument JSON is malformed or is not an object. `ToolCallBlock` has no equivalent of upstream's `argumentsError` field, so downstream validation cannot distinguish malformed input from a legitimately empty object.

### Expected (upstream behavior)

- `packages/ai/src/utils/json-parse.ts:98-120` returns `arguments: {}` **plus `argumentsError`** containing the parse problem and received text.
- `packages/ai/src/utils/streaming-json.ts:447-500` keeps partial streaming arguments separate and performs one full parse at completion.
- `packages/ai/src/utils/validation.ts:54-57` turns `argumentsError` into a validation failure before execution.

Upstream also uses `{}` as the placeholder; the missing diagnostic and fail-closed behavior are the Dart-port gaps.

### Required port coverage

- Port `argumentsError` and final full-parse semantics, including the received arguments diagnostic.
- Keep partial streaming snapshots separate from final arguments.
- Ensure malformed JSON, scalar/array roots, and truncated calls never execute a tool.
- Add upstream-equivalent tests for streaming partials, repair behavior, malformed JSON, and non-object roots.

Evidence reviewed at Dart commit `1d62d46d9b3ba09c22a2f38fc94e46693ea1cc03` and upstream commit `780bf31fcaeb252fa9b68df3964c735eae75bde3`.

## Comments

None.