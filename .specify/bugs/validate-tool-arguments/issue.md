# Bug Issue: dart-port: validate tool arguments before hooks and execution

- **Slug**: validate-tool-arguments
- **Fetched**: 2026-11-22
- **Issue**: 3
- **URL**: https://github.com/arrrrny/pi/issues/3
- **State**: open
- **Severity**: unknown
- **Author**: arrrrny
- **Labels**: bug, dart-port, pkg:agent, pkg:ai

## Body

## Dart-port parity defect

The Dart agent loop prepares and executes tool calls without applying upstream's `validateToolArguments` step.

### Actual

`pi_agent/lib/src/agent_loop.dart:424-493` resolves the tool, prepares arguments, and runs `beforeToolCall`, but never validates/coerces the arguments against the tool's JSON Schema. Invalid arguments can therefore reach `AgentTool.execute`.

### Expected (upstream behavior)

`packages/agent/src/agent-loop.ts:708-778` calls `validateToolArguments(tool, preparedToolCall)` before the hook and execution. Validation failures become an error tool result and the tool body is not executed. `packages/ai/src/utils/validation.ts:54-68` performs coercion, schema validation, and formatted errors.

### Required port coverage

- Port argument preparation followed by validation/coercion in the same order as upstream.
- A malformed or schema-invalid call must produce an error result and **zero executions** of the requested tool.
- Preserve the validated/coerced arguments for hooks and execution, as upstream does.
- Add differential tests for missing required fields, wrong types, coercion, unknown tools, and hook ordering.

Evidence reviewed at Dart commit `1d62d46d9b3ba09c22a2f38fc94e46693ea1cc03` and upstream commit `780bf31fcaeb252fa9b68df3964c735eae75bde3`. This is a Dart-port gap, not an upstream TypeScript defect.


## Dependencies

Depends on: arrrrny/pi#4

## Comments

None.