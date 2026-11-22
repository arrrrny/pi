# Contract: Extensions, Sections, Hooks, and Configuration

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md)
**Upstream**: `packages/durable/src/harness/registry.ts`, `registry-reader.ts`, `define.ts`, `types.ts`; spec §7.1–§7.2

## Extension and builders (spec §7.1)

```dart
class Extension<Tool extends ToolRegistration> {
  final String name;
  final List<Tool>? tools;
  final List<PromptSection<Tool>>? sections;
  final List<HookRegistration>? hooks;
  final List<Wrap<Tool>>? wraps;
  final List<AnyTask>? tasks;
}

Extension<Tool> defineExtension<Tool>(Extension<Tool> extension);
PromptSection<Tool> section<Tool>(String key, Render render, {bool tag = true});
HookRegistration hook<K extends AnyTask>(K task, Partial<HooksOf<K>> handlers);
Wrap<Tool> wrapTool<Tool>(Tool tool, Tool Function(Tool) wrapper);
Wrap<Tool> wrapSection<Tool>(String key, PromptSection<Tool> Function(PromptSection<Tool>) wrapper);
```

## Registry (spec §7.1)

```dart
abstract interface class Registry<Tool> implements RegistryReader<Tool> {
  void install(Extension<Tool> extension);     // replace-in-place by name, publish at once
  void uninstall(Extension extension);         // remove by name; a later install appends
}

abstract interface class RegistryReader<Tool> {
  RegistrySnapshot<Tool> snapshot();
  void Function() subscribe(void Function() listener);   // sync after every publication
}

abstract interface class RegistrySnapshot<Tool> {
  List<Extension<Tool>> installed();
  Extension<Tool>? extension(String name);
  List<({Extension<Tool> extension, Tool tool})> tools();
  List<({Extension<Tool> extension, PromptSection<Tool> section})> sections();
  List<AnyTask> tasks();
  AnyTask? task(String name);
}

Registry<Tool> createRegistry<Tool>();
```

Rules:

- The built-in tasks (§8) are always present and are not an extension.
- Tool names and section keys are unique within one extension; across extensions they may repeat. Section keys match
  `^[a-z][a-z0-9_-]*$`; the key `instructions` is reserved.
- Task names are unique across the built-in tasks and every installed extension. `install()` validates the registry
  as it would be after the replacement and throws without publishing when invalid.
- Publication is synchronous, invokes no extension callback, and notifies subscribers. There is no batch: an extension
  is the unit of reload.
- Extensions, tools, and task definitions are immutable; wrappers are pure.

## Resolution (spec §7.1)

A conversation's `Agent` is resolved from its stored `pi.agent`, a registry snapshot, and the resolved settings:

```text
extensions  base = settings.extensions ?? every installed extension; in that order
            array: exactly these, in array order; {add, remove}: base, then add appended, minus remove
            duplicates keep their first position; names not installed are skipped
tools       selected extensions' tools in extension order; a later same-name tool replaces an earlier one in place
            then every selected extension's tool wrappers, in extension order, then in each extension's order
            then the `tools` filter (array keeps exactly these names in order; {remove} drops these names)
            then the `modelTools` filter over model-callable tools; `callable` = tools-callable
sections    selected extensions' sections, same-key replacement in place, then their section wrappers,
            then `instructions` when set
hooks       selected extensions' hooks for the task's name, in extension order
model       stored, else none: the request fails no_model
thinking    stored, else "off"
cwd         stored, else undefined
compaction  stored, else undefined; readers resolve the policy from it and the settings
```

- A wrapper that throws or returns a tool/section with a different name drops its target for that resolution
  (`tool_unavailable`); the failure is reported through `onReport`.
- `settings.extensions` holding an old extension object resolves to the installed extension of that name.
- The Harness takes one snapshot per phase-handler invocation; different phases may observe different registry states.

## Hooks (spec §7.2)

| hook | composition | ordinary throw |
|---|---|---|
| `beforeRequest` | replacement chain | report, continue |
| `beforeProviderRequest` | replacement chain | report, continue |
| `afterResponse` | all observers | report, continue |
| `onYield` | first result wins: a continuation or tasks | report, continue |
| `beforeTool` | argument replacement chain; first block or sleep wins | block tool with error text |
| `afterTool` | result replacement chain | report, continue |
| `afterTools` | all run; requested tasks concatenated in extension order | report, continue |
| `afterRun` | all observers; requested tasks concatenated in extension order | report, continue |
| `beforeCompact` | first decision wins | report, continue |

- `runtime.hooks.each(name, invoke)` calls `invoke` with every handler under `name` among the phase's resolved hooks,
  in extension order, off the line. An ordinary throw is reported through `onReport` and `each` continues; once the
  invocation is signalled the error propagates.
- Hooks are typed by the task token but dispatch matches the task's name, so they survive a reload of their task.
- Hooks use task memos for durable first-writer-wins decisions; hook memos and the task's own memos share one
  namespace.
- Only `beforeTool` parks its task (the tool task's `call` phase reruns whole on every wake); generation/compaction
  hooks sit in the middle of their phases and never park the generation.

## Per-conversation configuration and reload (spec §7.1)

- `conversation.configure({extensions: {add: [...]}})` changes one conversation's stored `pi.agent` in a commit.
- A registry install or settings change makes no commit, so no view changes. A conversation on the default selection
  changes on its next preparation (its next system delta).
- A UI showing resolved tools or model resolves again through `Conversation.agent()`.
- A call parked at its gates is woken (with no wake) on a registry publication while it sleeps, when its sleep
  commits under a since-replaced snapshot, and at the first scheduling pass after open; a past `until` takes the
  deadline path.