// Identity builders that type an extension, a tool, a prompt section, a hook
// registration, a hook-requested task, and a tool/section wrapper.
//
// Port of `packages/durable/src/harness/define.ts` at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`.
library;

import '../../chord/json.dart';
import 'types.dart';

/// The reserved section key holding the agent's instructions.
///
/// Port of upstream `INSTRUCTIONS_KEY` (`agent.ts`).
const String instructionsKey = 'instructions';

/// Identity function that types an extension.
Extension<Tool> defineExtension<Tool extends ToolRegistration>({
  required String name,
  List<Tool>? tools,
  List<PromptSection<Tool>>? sections,
  List<HookRegistration>? hooks,
  List<Wrap<Tool>>? wraps,
  List<AnyTask>? tasks,
}) =>
    Extension<Tool>(
      name: name,
      tools: tools,
      sections: sections,
      hooks: hooks,
      wraps: wraps,
      tasks: tasks,
    );

/// Identity function that types a tool.
ToolRegistration defineTool<
        TParameters extends Object,
        TDetails extends JsonValue,
        C extends JsonValue>(ToolRegistration tool) =>
    tool;

/// A prompt section; tagged unless [tag] is false.
PromptSection<Tool> section<Tool extends ToolRegistration>(
  String key,
  String? Function(PromptInput<Tool> input, Object? context) render, {
  bool? tag,
}) =>
    PromptSection<Tool>(key: key, render: render, tag: tag);

/// Hook handlers for tasks with [task]'s name.
HookRegistration hook<K extends AnyTask>(
        K task, Map<String, Object?> handlers) =>
    HookRegistration(task: task.definition.name, handlers: handlers);

/// A task a hook asks for, its input typed by the task.
HookTask hookTask<I extends JsonValue, S extends Object, R>(
  Task<I, S, R> task,
  I input,
) =>
    HookTask(task: task.definition.asAny, input: input);

/// Wrap the tool named like [tool] wherever the wrapping extension is selected.
Wrap<Tool> wrapTool<Tool extends ToolRegistration>(
        Tool tool, Tool Function(Tool inner) wrapper) =>
    ToolWrap<Tool>(tool.name, wrapper);

/// Wrap the section [key] wherever the wrapping extension is selected.
Wrap<Tool> wrapSection<Tool extends ToolRegistration>(String key,
        PromptSection<Tool> Function(PromptSection<Tool> inner) wrapper) =>
    SectionWrap<Tool>(key, wrapper);

/// Define an executable task. Register it in the registry so a Harness can run
/// tasks of its kind.
///
/// Port of upstream `defineTask` (`tasks.ts`).
Task<I, S, R> defineTask<I, S, R>({
  required String name,
  required int version,
  required S Function(I input) initial,
  required Map<String, PhaseHandler<I, S, R>> phases,
  required Future<void> Function(RunningTask<I, S, R> task,
          TaskRuntime<I, S, R> runtime, Object? context)
      abort,
}) =>
    Task<I, S, R>(TaskDefinition<I, S, R>(
      name: name,
      version: version,
      initial: initial,
      phases: phases,
      abort: abort,
    ));
