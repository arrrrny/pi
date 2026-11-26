// The application-owned registry of extensions: install/replace/uninstall by
// name, synchronous publication, and the built-in tasks every registry holds.
//
// Port of `packages/durable/src/harness/registry.ts` at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`. The built-in generation/tool/
// compaction task bodies are later slices; their names and versions are fixed
// here so the registry always holds them and name collisions are rejected.
library;

import 'package:pi/src/durable/harness/define.dart';
import 'package:pi/src/durable/harness/types.dart';

/// The built-in task names every registry holds, in order.
///
/// Port of upstream `BUILTIN_TASKS` (`[GenerationTask, ToolTask, CompactionTask]`).
/// The task bodies are ported by a later slice; the registry pins their names.
const List<String> builtinTaskNames = <String>[
  'pi.generation',
  'pi.tool',
  'pi.compaction',
];

final RegExp _sectionKey = RegExp(r'^[a-z][a-z0-9_-]*$');

/// Immutable published registry state.
///
/// Port of upstream `RegistryState`.
class _RegistryState<Tool extends ToolRegistration>
    implements RegistrySnapshot<Tool> {
  _RegistryState(List<Extension<Tool>> extensions)
      : _extensions = List<Extension<Tool>>.unmodifiable(extensions),
        _byName =
            Map<String, Extension<Tool>>.unmodifiable(<String, Extension<Tool>>{
          for (final extension in extensions) extension.name: extension,
        }) {
    final tasks = <String, AnyTask>{};
    for (final name in builtinTaskNames) {
      tasks[name] = _builtinTask(name);
    }
    for (final extension in extensions) {
      for (final task in extension.tasks ?? const <AnyTask>[]) {
        final name = task.definition.name;
        if (tasks.containsKey(name)) {
          throw StateError(
              'Task $name of extension ${extension.name} is already installed');
        }
        tasks[name] = task;
      }
    }
    _tasks = Map<String, AnyTask>.unmodifiable(tasks);
  }

  final List<Extension<Tool>> _extensions;
  final Map<String, Extension<Tool>> _byName;
  late final Map<String, AnyTask> _tasks;

  @override
  List<Extension<Tool>> installed() => _extensions;

  @override
  Extension<Tool>? extension(String name) => _byName[name];

  @override
  List<({Extension<Tool> extension, Tool tool})> tools() =>
      <({Extension<Tool> extension, Tool tool})>[
        for (final extension in _extensions)
          for (final tool in extension.tools ?? <Tool>[])
            (extension: extension, tool: tool),
      ];

  @override
  List<({Extension<Tool> extension, PromptSection<Tool> section})> sections() =>
      <({Extension<Tool> extension, PromptSection<Tool> section})>[
        for (final extension in _extensions)
          for (final section in extension.sections ?? <PromptSection<Tool>>[])
            (extension: extension, section: section),
      ];

  @override
  List<AnyTask> tasks() => _tasks.values.toList();

  @override
  AnyTask? task(String name) => _tasks[name];
}

/// A registry implementation.
///
/// Port of upstream `RegistryImpl`.
class _RegistryImpl<Tool extends ToolRegistration> implements Registry<Tool> {
  _RegistryState<Tool> _current = _RegistryState<Tool>(<Extension<Tool>>[]);
  final Set<void Function()> _listeners = <void Function()>{};

  @override
  RegistrySnapshot<Tool> snapshot() => _current;

  @override
  void Function() subscribe(void Function() listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  @override
  void install(Extension<Tool> extension) {
    _validateExtension(extension);
    final current = _current.installed();
    final index =
        current.indexWhere((installed) => installed.name == extension.name);
    final next = index < 0
        ? <Extension<Tool>>[...current, extension]
        : <Extension<Tool>>[
            for (var at = 0; at < current.length; at++)
              if (at == index) extension else current[at],
          ];
    _publish(next);
  }

  @override
  void uninstall(Extension<ToolRegistration> extension) {
    final current = _current.installed();
    if (!current.any((installed) => installed.name == extension.name)) return;
    _publish(current
        .where((installed) => installed.name != extension.name)
        .toList());
  }

  /// Build and validate the next state, which throws on a task name collision,
  /// then publish it synchronously.
  void _publish(List<Extension<Tool>> extensions) {
    _current = _RegistryState<Tool>(extensions);
    for (final listener in <void Function()>[..._listeners]) {
      listener();
    }
  }
}

/// Unique tool names and section keys within one extension; valid, unreserved
/// section keys.
///
/// Port of upstream `validateExtension`.
void _validateExtension(Extension<ToolRegistration> extension) {
  final tools = <String>{};
  for (final tool in extension.tools ?? const <ToolRegistration>[]) {
    if (!tools.add(tool.name)) {
      throw StateError(
          'Extension ${extension.name} has two tools named ${tool.name}');
    }
  }
  final sections = <String>{};
  for (final section
      in extension.sections ?? const <PromptSection<ToolRegistration>>[]) {
    final key = section.key;
    if (!_sectionKey.hasMatch(key)) {
      throw ArgumentError('Section key $key must match ${_sectionKey.pattern}');
    }
    if (key == instructionsKey) {
      throw StateError(
          'Section key $key is reserved for the agent\'s instructions');
    }
    if (!sections.add(key)) {
      throw StateError(
          'Extension ${extension.name} has two sections with key $key');
    }
  }
}

/// A placeholder built-in task definition.
///
/// The generation/tool/compaction task bodies are later slices; the registry
/// needs their names and versions to reserve them and reject collisions.
AnyTask _builtinTask(String name) => defineTask<Object?, Object?, Object?>(
      name: name,
      version: 1,
      initial: (input) => <String, Object?>{'phase': name},
      phases: <String, PhaseHandler<Object?, Object?, Object?>>{},
      abort: (task, runtime, context) async {},
    ).definition.asAny;

/// Create an application-owned registry holding only the built-in tasks.
///
/// Port of upstream `createRegistry`.
Registry<Tool> createRegistry<Tool extends ToolRegistration>() =>
    _RegistryImpl<Tool>();
