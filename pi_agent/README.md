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

## Install the CLI (`pidart`)

The package ships exactly one executable, `pidart`, a thin command-line front
end over the agent loop. It is the only installed name — there is no `pi` or
`pid` alias, so it never shadows the native TypeScript `pi` command.

Install it hosted (once the package is published to pub.dev):

```sh
dart pub global activate pi
```

Upgrade to the latest published version:

```sh
dart pub global activate pi
```

Uninstall it:

```sh
dart pub global deactivate pi
```

`dart pub global activate` installs executables into the pub cache's `bin`
directory. Add it to your `PATH` so `pidart` is callable (the line differs per
shell; this is the common `~/.pub-cache/bin` location):

```sh
export PATH="$HOME/.pub-cache/bin:$PATH"
```

Run it from a source checkout without installing, via the same entrypoint:

```sh
dart run bin/pidart.dart --help      # from the package root (pi_agent/)
```

### Usage

```sh
pidart                 # interactive session, reads prompts from stdin
pidart <prompt...>     # one-shot: run a single prompt and print the reply
pidart --help, -h      # usage
pidart --version, -v   # version
```

Both the interactive and the one-shot form run through one argument parser and
one agent runtime. Configure the model through the environment:

| Variable | Meaning |
|----------|---------|
| `PI_MODEL` | Model to run, as `provider/model` (e.g. `openai/gpt-4o`) or a bare id |
| `PI_PROVIDER` | Provider when `PI_MODEL` is a bare id (default `openai`) |
| `PI_BASE_URL` | Override the OpenAI-compatible endpoint |
| `PI_CONTEXT_WINDOW` | Context window in tokens (default `128000`) |
| `PI_API_KEY`, `<PROVIDER>_API_KEY` | Provider API key |

A one-shot or interactive run with no `PI_MODEL` set exits non-zero with a
config error on stderr; `--help` and `--version` need no configuration.

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
