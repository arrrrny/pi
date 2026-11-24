## [Unreleased]

### Changed

- The exported `compact()` now generates its summary through the model instead of returning a placeholder: it delegates to the same canonical summarization path as `Conversation.compact()`, accepting an optional `loopStreamFn` (defaulting to `streamLLM`) and threading `previousSummary`, `customInstructions` and `abortSignal`. Prompts mirror upstream (`<conversation>` / `<previous-summary>` tags, initial vs update instructions, system prompt), and `CompactionResult` carries the summarizing response's `usage`. Responses that failed at the provider, were aborted, hit the token cap, attempted a tool call, or produced empty text now throw instead of being persisted as a summary, as does a call with nothing before the cut point. An optional `getApiKey` callback resolves the credential before the default `streamLLM` path sends it, matching `Conversation.compact()`. ([#7](https://github.com/arrrrny/pi/issues/7))
- `summarizeMessages`'s `instructions` parameter is renamed to `customInstructions` to match the lower `summarizeMessagesWithUsage` layer and its append-as-additional-focus semantics (it was never a replacement). No in-repo caller passed it, but external callers of the exported symbol must rename the argument. ([#7](https://github.com/arrrrny/pi/issues/7))

### Fixed

- Steering and follow-up queue modes now affect draining: `one-at-a-time` injects only the oldest queued message per drain, `all` injects every queued message. Both modes are now a single shared `QueueMode` (replacing the Dart-only `SteeringMode`/`FollowUpMode`), backed by a `PendingMessageQueue` ported from upstream; `Agent` gained `peekQueuedMessages()` and mode getters. ([#2](https://github.com/arrrrny/pi/issues/2))
- Tool calls whose argument text is malformed JSON or is not a JSON object now carry `argumentsError` instead of being silently decoded as `{}`: the diagnostic names the parse problem and the received text, survives JSONL session reload, and fails the call closed before `prepareArguments`, `beforeToolCall` or execution. Invalid string escapes are repaired rather than rejected, matching upstream `parseToolCallArguments` ([#4](https://github.com/arrrrny/pi/issues/4)).
- Tool arguments are now coerced and validated against the tool's JSON Schema between argument preparation and the `beforeToolCall` hook, matching upstream `validateToolArguments`: a schema-invalid call becomes an error tool result and never reaches the hook or `AgentTool.execute`, and a coercible call (`"42"` for an integer, a single value for an array, `null` for an omitted optional property) reaches both with the coerced arguments. The recorded tool call keeps the model's raw arguments ([#3](https://github.com/arrrrny/pi/issues/3)).

## 0.2.0

- Real agent loop: multi-turn tool execution (parallel and sequential), steering/follow-up injection, abort, before/after tool hooks, and max-tokens truncated-call safety — wired to the default path (previously a stub).
- Slim OpenAI-compatible streaming client: a single `/chat/completions` client with `Model.baseUrl` for any compatible endpoint; removed Anthropic and all per-provider adapters.
- Durable harness: `Conversation` with `create`/`resume`/`fork`, write-ahead persistence, and JSONL round-trip of full message content (text, images, tool calls, tool results, usage).
- Subagents: `subagentTool` delegates a task to a child agent and returns its answer as a tool result.
- Context compaction: LLM-based `summarizeMessages`, compaction-aware `Session.buildContext`, and `Conversation.compact()`.
- Durable in-flight resume: `Conversation.hasPendingTurn` and `resumeInterruptedTurn()` recover a turn interrupted by a crash.
- Fixed JSONL session storage losing message content on reload.
- Fixed duplicate `MessageUpdate` events emitted on trailing/empty SSE chunks.

## 0.1.0

- Initial release.
- Agent class with streaming event emission.
- Tool execution with parallel and sequential modes.
- Before/after tool call hooks.
- Steering and follow-up message queues.
- LLM provider integration (OpenAI-compatible and Anthropic).
- Skill loading from SKILL.md files with YAML frontmatter.
- Prompt template loading with argument substitution.
- Session persistence with tree-of-entries and branching.
- In-memory and JSONL session storage.
- Context compaction with automated summarization.
- Execution environment abstraction with local Dart VM implementation.
