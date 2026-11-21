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
