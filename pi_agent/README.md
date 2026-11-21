# pi_agent

A Dart port of pi's agent core and durable harness: a faithful agent loop (tools,
streaming, hooks, steering, abort) plus a durable conversation layer (persist,
resume, fork, compaction, subagents) with a deliberately slim, OpenAI-compatible
LLM client.

## Features

- **Agent Loop**: start/continue conversations, multi-turn tool execution (parallel or sequential), steering & follow-up messages, abort, before/after tool hooks
- **Streaming Events**: typed lifecycle events (turn/message streaming, tool execution)
- **Tool Execution**: typed parameter schemas, parallel or sequential modes, truncated-call safety
- **Session Persistence**: tree-of-entries storage (in-memory or JSONL) with branching/forks
- **Durable Harness**: a `Conversation` persists the transcript as it runs — survive restarts, resume interrupted turns, and fork
- **Subagents**: delegate a task to a child agent and fold its answer back into the parent
- **Context Compaction**: summarize older turns via the LLM to stay within the context window
- **Skills & Prompt Templates**: load SKILL.md behaviors and parameterized `.md` prompts
- **LLM Provider**: a single, slim OpenAI-compatible streaming client (point `baseUrl` at OpenAI or any compatible server)

## Installation

```yaml
dependencies:
  pi: ^0.1.0
```

## Quick Start

```dart
import 'dart:io';
import 'package:pi/pi.dart';

void main() async {
  final agent = Agent(
    model: Model(
      provider: 'openai',
      modelId: 'gpt-4o',
      contextWindow: 128000,
    ),
    systemPrompt: 'You are a helpful assistant.',
    getApiKey: (provider) async => Platform.environment['OPENAI_API_KEY'],
  );

  agent.subscribe((event) {
    switch (event) {
      case MessageUpdate(message: final msg):
        if (msg is AssistantMessage) {
          for (final block in msg.content) {
            if (block is TextBlock) stdout.write(block.text);
          }
        }
      case AgentEnd():
        print('\nDone.');
      default:
        break;
    }
  });

  await agent.prompt('Hello!');
}
```

## Durable conversations

A `Conversation` pairs an agent with storage so the transcript is persisted as it
runs. Reopen it later (or after a crash) and it rebuilds the agent's context.

```dart
import 'package:pi/pi.dart';

final storage = JsonlSessionStorage('session.jsonl');

// First run.
final convo = await Conversation.create(
  storage,
  model: Model(provider: 'openai', modelId: 'gpt-4o', contextWindow: 128000),
  systemPrompt: 'You are helpful.',
  getApiKey: (p) async => apiKey,
);
await convo.prompt('Plan a two-week trip to Japan.');

// Later, in a new process: resume and continue with full context.
final resumed = await Conversation.resume(
  JsonlSessionStorage('session.jsonl'),
  systemPrompt: 'You are helpful.',
  getApiKey: (p) async => apiKey,
);
if (resumed.hasPendingTurn) {
  await resumed.resumeInterruptedTurn(); // finish a turn interrupted by a crash
}
await resumed.prompt('Now book the flights.');
```

Use `MemoryStorage` (via `InMemorySessionStorage`) for transient sessions, and
`Conversation.fork(entryId)` to branch.

## Subagents

Delegate a task to a child agent and return its answer as a tool result:

```dart
final task = subagentTool(
  name: 'task',
  description: 'Delegate a focused sub-task to a subagent.',
  childFactory: () => Agent(
    model: model,
    systemPrompt: 'You are a focused subagent.',
    loopStreamFn: streamLLM, // or your own
    getApiKey: (p) async => apiKey,
  ),
);

final agent = Agent(model: model, tools: [task], /* ... */);
```

## Compaction

`Conversation.compact()` summarizes older turns with the LLM and reseeds the
agent with the compacted context when it grows past the model's window.

## License

BSD 3-Clause. See [LICENSE](LICENSE).
