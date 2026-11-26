// The harness vocabulary: extensions, prompt sections, wrappers, hook
// registrations, tool registrations, the task definition, and the registry
// snapshot/read/write interfaces.
//
// Port of `packages/durable/src/harness/types.ts` (the registry/extension
// vocabulary) and `packages/durable/src/tasks.ts` at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`. Only the parts the registry and
// define builders need are ported here; the generation/tool/compaction runtime
// is a later slice.
library;

// ─── Tasks ───────────────────────────────────────────────────────────────────

/// A phase handler: runs one phase of a task narrowed to its checkpoint.
typedef PhaseHandler<I, S, R> = Future<Object?> Function(
  RunningTask<I, S, R> task,
  TaskRuntime<I, S, R> runtime,
  Object? context,
);

/// The erased executable task definition stored in the registry.
///
/// Port of upstream `AnyTask`: the registry only reads `definition.name` and
/// `definition.version`, so the Dart port keeps those two and treats the rest
/// as opaque.
class AnyTask {
  /// A task definition erased to the fields the registry reads.
  const AnyTask({required this.definition});

  /// The erased definition.
  final AnyTaskDefinition definition;
}

/// The erased definition of an [AnyTask].
///
/// Port of the `AnyTask["definition"]` shape: `name` and `version` are read by
/// the registry; `initial`, `phases`, and `abort` are carried opaquely.
class AnyTaskDefinition {
  /// An erased task definition.
  const AnyTaskDefinition({
    required this.name,
    required this.version,
    required this.initial,
    required this.phases,
    required this.abort,
  });

  /// Registered task kind persisted in `TaskRecord.kind`.
  final String name;

  /// Definition version persisted with live input and checkpoints.
  final int version;

  /// First durable checkpoint for a newly created task.
  final Object? Function(Object? input) initial;

  /// Exhaustive phase map keyed by phase name.
  final Map<String, Object?> phases;

  /// Runs after an abort mark and commits a terminal outcome.
  final Object? Function(Object? task, Object? runtime, Object? context) abort;
}

/// A typed executable task definition.
///
/// Port of upstream `Task<I, S, R, H>`: a thin wrapper over [definition].
class Task<I, S, R> {
  /// A task definition.
  const Task(this.definition);

  /// The typed definition.
  final TaskDefinition<I, S, R> definition;
}

/// The typed definition behind a [Task].
///
/// Port of upstream `TaskDefinition`.
class TaskDefinition<I, S, R> {
  /// A typed task definition.
  const TaskDefinition({
    required this.name,
    required this.version,
    required this.initial,
    required this.phases,
    required this.abort,
  });

  /// Registered task kind persisted in `TaskRecord.kind`.
  final String name;

  /// Definition version persisted with live input and checkpoints.
  final int version;

  /// First durable checkpoint for a newly created task.
  final S Function(I input) initial;

  /// Exhaustive phase map keyed by phase name.
  final Map<String, PhaseHandler<I, S, R>> phases;

  /// Runs after an abort mark and commits a terminal outcome.
  final Future<void> Function(RunningTask<I, S, R> task,
      TaskRuntime<I, S, R> runtime, Object? context) abort;

  /// This definition erased to the registry's [AnyTask] shape.
  AnyTask get asAny => AnyTask(
          definition: AnyTaskDefinition(
        name: name,
        version: version,
        initial: (input) => initial(input as I),
        phases: <String, Object?>{...phases},
        abort: (task, runtime, context) => abort(
          task as RunningTask<I, S, R>,
          runtime as TaskRuntime<I, S, R>,
          context,
        ),
      ));
}

/// A task narrowed to a running invocation.
///
/// Port of upstream `RunningTask`; opaque to the registry slice.
class RunningTask<I, S, R> {
  /// A running task handle.
  const RunningTask();
}

/// The runtime a phase handler drives its task through.
///
/// Port of upstream `TaskRuntime`; opaque to the registry slice.
class TaskRuntime<I, S, R> {
  /// A task runtime handle.
  const TaskRuntime();
}

// ─── Tools and results ────────────────────────────────────────────────────────

/// How a tool's call is scheduled within a round.
enum ToolExecutionMode {
  /// Calls may run in parallel.
  parallel,

  /// Calls run one at a time.
  sequential,
}

/// An executable tool registered in a registry.
///
/// Port of upstream `ToolRegistration` (the fields the registry and define
/// builders read). `execute` is typed loosely here; the tool runtime is a
/// later slice.
class ToolRegistration {
  /// A tool registration.
  const ToolRegistration({
    required this.name,
    required this.description,
    required this.parameters,
    required this.execute,
    this.replay,
    this.executionMode,
  });

  /// The tool's unique name within its extension.
  final String name;

  /// One-line description shown to the model.
  final String description;

  /// The JSON schema the arguments are validated against.
  final Object? parameters;

  /// Runs the tool.
  final Future<ToolExecutionResult> Function(
      Object? args, Object? api, Object? context) execute;

  /// Whether an interrupted execution may rerun on recovery.
  final String? replay;

  /// Default execution mode for this tool's round.
  final ToolExecutionMode? executionMode;
}

/// The result of a tool call.
///
/// Port of upstream `ToolExecutionResult`.
class ToolExecutionResult {
  /// A tool execution result.
  const ToolExecutionResult({
    this.output,
    this.structuredOutput,
    this.isError,
    this.details,
  });

  /// The bounded output the model or caller receives.
  final Object? output;

  /// The structured output a program caller receives.
  final Object? structuredOutput;

  /// Whether the call failed.
  final bool? isError;

  /// Host-owned details, never sent to the model.
  final Object? details;
}

// ─── Prompt sections ──────────────────────────────────────────────────────────

/// Input to system prompt section rendering for one request preparation.
///
/// Port of upstream `PromptInput`; opaque to the registry slice.
class PromptInput<Tool extends ToolRegistration> {
  /// A prompt render input.
  const PromptInput();
}

/// One system prompt section; the agent's sections render in order.
///
/// Port of upstream `PromptSection`. `tag` is null when the upstream default
/// (true) applies, matching `section()`'s omission of the field.
class PromptSection<Tool extends ToolRegistration> {
  /// A prompt section.
  const PromptSection({
    required this.key,
    required this.render,
    this.tag,
  });

  /// The section key, matching `^[a-z][a-z0-9_-]*$`.
  final String key;

  /// Renders the section text for one preparation.
  final String? Function(PromptInput<Tool> input, Object? context) render;

  /// Whether to wrap the text as `<key>…</key>`; null uses the default (true).
  final bool? tag;
}

// ─── Hooks and wrappers ───────────────────────────────────────────────────────

/// Built by `hook()`; matches tasks by name.
///
/// Port of upstream `HookRegistration`.
class HookRegistration {
  /// A hook registration.
  const HookRegistration({required this.task, required this.handlers});

  /// The matched task's name.
  final String task;

  /// The hook handlers, keyed by hook name.
  final Map<String, Object?> handlers;
}

/// A task a hook asks for, its input typed by the task.
///
/// Port of upstream `HookTask`.
class HookTask {
  /// A hook-requested task.
  const HookTask({required this.task, required this.input});

  /// The requested task.
  final AnyTask task;

  /// The task's input.
  final Object? input;
}

/// Built by `wrapTool()` and `wrapSection()`; targets a tool name or section
/// key. Wrappers are pure.
///
/// Port of upstream `Wrap`, as a tagged union on [kind].
sealed class Wrap<Tool extends ToolRegistration> {
  /// The wrapper discriminator.
  const Wrap();

  /// The wrapper kind discriminator.
  String get kind;
}

/// A wrapper over a tool.
final class ToolWrap<Tool extends ToolRegistration> extends Wrap<Tool> {
  /// Wrap the tool named [tool].
  const ToolWrap(this.tool, this.wrap);

  /// The target tool's name.
  final String tool;

  /// The pure wrapper.
  final Tool Function(Tool inner) wrap;

  @override
  String get kind => 'tool';
}

/// A wrapper over a section.
final class SectionWrap<Tool extends ToolRegistration> extends Wrap<Tool> {
  /// Wrap the section [section].
  const SectionWrap(this.section, this.wrap);

  /// The target section's key.
  final String section;

  /// The pure wrapper.
  final PromptSection<Tool> Function(PromptSection<Tool> inner) wrap;

  @override
  String get kind => 'section';
}

// ─── Extensions ───────────────────────────────────────────────────────────────

/// A named bundle of code: tools, sections, hooks, wrappers, and tasks.
///
/// Port of upstream `Extension`. Immutable by convention.
class Extension<Tool extends ToolRegistration> {
  /// An extension.
  const Extension({
    required this.name,
    this.tools,
    this.sections,
    this.hooks,
    this.wraps,
    this.tasks,
  });

  /// The extension's unique name.
  final String name;

  /// The tools this extension contributes.
  final List<Tool>? tools;

  /// The prompt sections this extension contributes.
  final List<PromptSection<Tool>>? sections;

  /// The hook registrations this extension contributes.
  final List<HookRegistration>? hooks;

  /// The tool/section wrappers this extension applies where selected.
  final List<Wrap<Tool>>? wraps;

  /// The task definitions this extension resolves by name.
  final List<AnyTask>? tasks;
}

// ─── Registry ─────────────────────────────────────────────────────────────────

/// Immutable view of one published registry state.
///
/// Port of upstream `RegistrySnapshot`.
abstract interface class RegistrySnapshot<Tool extends ToolRegistration> {
  /// The installed extensions, in install order.
  List<Extension<Tool>> installed();

  /// The installed extension named [name], or null.
  Extension<Tool>? extension(String name);

  /// Every installed tool with its extension, in install order.
  List<({Extension<Tool> extension, Tool tool})> tools();

  /// Every installed section with its extension, in install order.
  List<({Extension<Tool> extension, PromptSection<Tool> section})> sections();

  /// Built-in and installed task definitions.
  List<AnyTask> tasks();

  /// The task definition named [name], or null.
  AnyTask? task(String name);
}

/// Read side of a registry consumed by a Harness.
///
/// Port of upstream `RegistryReader`.
abstract interface class RegistryReader<Tool extends ToolRegistration> {
  /// Immutable view of the whole current registry.
  RegistrySnapshot<Tool> snapshot();

  /// Called synchronously after every publication; returns an unsubscribe.
  void Function() subscribe(void Function() listener);
}

/// Application-owned registry of extensions.
///
/// Port of upstream `Registry`.
abstract interface class Registry<Tool extends ToolRegistration>
    implements RegistryReader<Tool> {
  /// Install [extension], or replace the installed extension of its name in
  /// place. Publishes at once.
  void install(Extension<Tool> extension);

  /// Remove the installed extension with [extension]'s name.
  void uninstall(Extension<ToolRegistration> extension);
}
