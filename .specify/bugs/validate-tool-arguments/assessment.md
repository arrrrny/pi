# Bug Assessment: dart-port: validate tool arguments before hooks and execution

- **Slug**: validate-tool-arguments
- **Created**: 2026-11-22
- **Source**: https://github.com/arrrrny/pi/issues/3
- **Verdict**: valid
- **Severity**: high

## Report (verbatim or summarized)

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

## Symptom

The Dart agent loop accepts tool-call arguments without validating them against the tool's JSON Schema. A call with missing required fields, wrong types, or uncoercible values flows through `_prepareToolCall` and reaches `AgentTool.execute` instead of being rejected as an error tool result. Upstream rejects such calls before the `beforeToolCall` hook runs and before any execution.

## Reproduction

1. Define an `AgentTool` with a schema that has a required field (e.g. `{'type': 'object', 'properties': {'value': {'type': 'string'}}, 'required': ['value']}`).
2. Script an assistant turn that emits a `ToolCallBlock` with `arguments: {}` (missing the required `value`).
3. Run the agent loop.
4. Observe: the tool's `execute` is called with `{}`, no validation error is produced. Upstream would return an error tool result with "Validation failed for tool ..." and never call `execute`.

## Suspected Code Paths

- `pi_agent/lib/src/agent_loop.dart:448-454` — `_prepareToolCall` applies `prepareArguments` but then proceeds directly to `beforeToolCall` without calling `validateParameters`.
- `pi_agent/lib/src/tools.dart:67-76` — `validateParameters` exists and is fully tested in `pi_agent/test/tools_test.dart:82-240`, but is never called by the agent loop. It is an orphaned function.
- `pi_agent/lib/src/agent_loop.dart:485-489` — `_Prepared.ok` is returned with the prepared (but unvalidated) args, which flow to `_executeTool` and ultimately `prepared.tool.execute`.
- `pi_agent/lib/src/types.dart:178-194` — `ToolCallBlock` has no `argumentsError` field. This is the dependency (issue #4): without it, the validation step cannot detect malformed JSON that was silently decoded as `{}`.
- `packages/agent/src/agent-loop.ts:736` — upstream calls `validateToolArguments(tool, preparedToolCall)` at this exact point in `prepareToolCall`, after `prepareToolCallArguments` and before `beforeToolCall`.
- `packages/ai/src/utils/validation.ts:54-68` — upstream `validateToolArguments` checks `argumentsError`, coerces via pi-schema's `parse()`, formats errors, and throws.

## Root Cause Hypothesis

The Dart port implemented `validateParameters` as a standalone function with tests, but never wired it into the `_prepareToolCall` pipeline. The upstream `prepareToolCall` function has a three-step sequence: (1) `prepareToolCallArguments`, (2) `validateToolArguments`, (3) `beforeToolCall` hook. The Dart port has steps (1) and (3) but omits step (2). Additionally, the Dart `validateParameters` function only validates — it does not coerce (e.g. `"42"` to `42` for a number field), which upstream's `validateToolArguments` does via pi-schema's `compile(schema, {coerce: true})`. Confidence: high.

## Proposed Remediation

**Preferred**: Wire `validateParameters` into `_prepareToolCall` between the `prepareArguments` call and the `beforeToolCall` hook. On validation failure, return `_Prepared.immediate(_errorResult(formattedMessage))` — the same pattern used for unknown tools and blocked calls. The validated/coerced args must be passed to the hook and stored in `_PreparedTool.args` so execution uses them.

Two sub-parts:

1. **Validation wiring** (this issue's core): Insert a call to `validateParameters(tool.parameters, args)` after the `prepareArguments` block (line 454) and before the `beforeToolCall` block (line 456). On non-null error list, format the errors into a message string and return `_Prepared.immediate(_errorResult(message))`.

2. **Coercion** (requires a Dart port of pi-schema's `coerce: true` or a Dart-native coercion layer): Upstream coerces types before validating (e.g. `"42"` -> `42`, `true` -> `1`). The current `validateParameters` checks types but does not coerce. A minimal approach: after validation passes, coerce the args map in-place for known type mismatches (string-to-number, string-to-boolean, single-value-to-array). A fuller approach mirrors pi-schema's `compile` with `coerce: true`, which is a larger port. The assessment recommends starting with the validation wiring (part 1) as the primary fix and treating coercion as a follow-up within the same issue, since the issue title says "validate tool arguments" and the required coverage mentions coercion.

**Dependency on #4**: The `argumentsError` field on `ToolCallBlock` and the fail-closed `_decodeArguments` behavior are prerequisites for full parity. Without them, a malformed JSON argument buffer silently becomes `{}`, and validation of `{}` may pass for a tool with no required fields. This issue's validation step should also check for `argumentsError` once #4 lands (the upstream `validateToolArguments` does this at validation.ts:55-57). Until #4 is resolved, the validation wiring in this issue is still correct and necessary for schema-invalid (but well-formed JSON) arguments.

**Alternatives**:
- Port pi-schema's full `compile` with coercion as a Dart package. Higher effort, maximum parity, but blocks on a larger port.
- Use a Dart JSON Schema validation package (e.g. `json_schema` from pub.dev) with coercion support. Introduces a dependency; needs evaluation against the existing `validateParameters` test suite.

**Files likely to change**:
- `pi_agent/lib/src/agent_loop.dart` — wire `validateParameters` into `_prepareToolCall`
- `pi_agent/lib/src/tools.dart` — optionally add coercion to `validateParameters` or a new `coerceAndValidate` function
- `pi_agent/test/agent_loop_test.dart` — add differential tests for validation failures, coercion, hook ordering

**Tests to add or update**:
- Missing required field produces error result, tool body not executed
- Wrong type produces error result, tool body not executed
- Coercion: string `"42"` coerced to int `42` for a number field, tool receives coerced value
- Coercion: single value wrapped in array for an array field
- Unknown tool produces error result (existing behavior — verify it still works after the change)
- `beforeToolCall` hook receives validated/coerced args, not raw args
- `beforeToolCall` hook can override args after validation (upstream does NOT revalidate overridden args — see agent-loop.test.ts:581-640)
- Validation failure means `beforeToolCall` is never called (upstream: validation is before the hook)
- Sequential and parallel modes both validate
- `prepareArguments` output is validated (upstream: `prepareToolCallArguments` runs before `validateToolArguments`)

## Risks & Considerations

- **Breaking change for tools with loose schemas**: Tools that currently receive unvalidated args may start rejecting calls that previously "worked" by coincidence. This is the correct behavior (upstream does it) but could surface latent bugs in tool implementations.
- **Coercion scope**: Full pi-schema coercion is complex (nullable unions, anyOf, oneOf, $ref resolution). A partial coercion may produce different results from upstream for edge cases. The assessment recommends starting with the validation wiring and common coercion cases, then expanding.
- **Performance**: Validation on every tool call adds overhead. Upstream caches compiled validators in a WeakMap. The Dart side should do the same if a compile step is added.
- **Dependency on #4**: Full parity requires #4 (argumentsError on ToolCallBlock). This issue can proceed independently for schema validation of well-formed JSON, but the "malformed JSON produces error" case depends on #4.

## Open Questions

- Should coercion be a full pi-schema port or a minimal Dart-native layer? The issue's "Required port coverage" says "coercion" but the scope of a full pi-schema Dart port is significant. Recommend: wire validation first, add common coercion cases, file a follow-up for full pi-schema parity if needed.
- Should `validateParameters` be renamed or replaced to signal it now includes coercion? Current name is accurate for validation-only; a `coerceAndValidate` name would be clearer if coercion is added.