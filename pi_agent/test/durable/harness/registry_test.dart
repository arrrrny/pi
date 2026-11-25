// Registry and extension builders: install/replace/uninstall by name, the
// built-in tasks every registry holds, and the define* identity builders.
// Port of `packages/durable/src/harness/registry.ts` and `define.ts` at
// upstream `780bf31fcaeb252fa9b68df3964c735eae75bde3`, derived case by case
// from `packages/durable/test/harness-registry.test.ts`.

import 'package:pi/durable.dart';
import 'package:test/test.dart';

/// A minimal tool registration for the registry tests: a name and a
/// description, the only fields the registry reads.
ToolRegistration _tool(String name, {String? description}) => ToolRegistration(
      name: name,
      description: description ?? '$name tool',
      parameters: null,
      execute: (args, api, context) async =>
          const ToolExecutionResult(output: <Object?>[]),
    );

/// A minimal custom task definition registered by an extension.
AnyTask _task(String name, {int version = 1}) =>
    defineTask<Object?, Object?, Object?>(
      name: name,
      version: version,
      initial: (input) => const <String, Object?>{'phase': 'run'},
      phases: <String, PhaseHandler<Object?, Object?, Object?>>{
        'run': (task, runtime, context) async => <String, Object?>{'ok': true},
      },
      abort: (task, runtime, context) async {},
    ).definition.asAny;

List<String> _names(List<Extension<ToolRegistration>> extensions) =>
    extensions.map((extension) => extension.name).toList();

void main() {
  group('registry', () {
    test('installs, replaces in place, and uninstalls extensions by name', () {
      final registry = createRegistry<ToolRegistration>();
      final listener = <String>[];
      registry.subscribe(() =>
          listener.add(_names(registry.snapshot().installed()).join(',')));
      final a = defineExtension<ToolRegistration>(
          name: 'a', tools: [_tool('read', description: 'Read files')]);
      final b = defineExtension<ToolRegistration>(
          name: 'b', tools: [_tool('read'), _tool('bash')]);
      registry.install(a);
      registry.install(b);
      final before = registry.snapshot();
      // A new object with an installed name replaces it at its position.
      final a2 =
          defineExtension<ToolRegistration>(name: 'a', tools: [_tool('grep')]);
      registry.install(a2);
      expect(_names(registry.snapshot().installed()), <String>['a', 'b']);
      expect(identical(registry.snapshot().extension('a'), a2), isTrue);
      expect(
        registry
            .snapshot()
            .tools()
            .map((each) => '${each.tool.name}@${each.extension.name}')
            .toList(),
        <String>['grep@a', 'read@b', 'bash@b'],
      );
      // Old snapshots stay as they were.
      expect(identical(before.extension('a'), a), isTrue);
      expect(before.tools().first.tool.description, 'Read files');
      // Uninstall matches the name, whichever object; a later install appends.
      registry.uninstall(a);
      registry.uninstall(a);
      expect(_names(registry.snapshot().installed()), <String>['b']);
      registry.install(a);
      expect(_names(registry.snapshot().installed()), <String>['b', 'a']);
      expect(listener, <String>['a', 'a,b', 'a,b', 'b', 'b,a']);
    });

    test(
        'validates the registry as it would be after an install and publishes nothing when invalid',
        () {
      final registry = createRegistry<ToolRegistration>();
      registry
          .install(defineExtension(name: 'tasks', tasks: [_task('app.index')]));
      var published = 0;
      registry.subscribe(() => published++);
      final before = registry.snapshot();
      final invalid =
          <({Extension<ToolRegistration> extension, String message})>[
        (
          extension:
              defineExtension(name: 'x', tools: [_tool('read'), _tool('read')]),
          message: 'two tools named read',
        ),
        (
          extension: defineExtension(name: 'x', sections: [
            section('a', (input, ctx) => '1'),
            section('a', (input, ctx) => '2'),
          ]),
          message: 'two sections',
        ),
        (
          extension: defineExtension(
              name: 'x', sections: [section('Bad Key', (input, ctx) => '')]),
          message: 'must match',
        ),
        (
          extension: defineExtension(
              name: 'x',
              sections: [section('instructions', (input, ctx) => '')]),
          message: 'reserved',
        ),
        (
          extension:
              defineExtension(name: 'x', tasks: [_task('pi.generation')]),
          message: 'already installed',
        ),
        (
          extension: defineExtension(name: 'x', tasks: [_task('app.index')]),
          message: 'already installed',
        ),
      ];
      for (final entry in invalid) {
        expect(() => registry.install(entry.extension), throwsA(anything));
      }
      expect(identical(registry.snapshot(), before), isTrue);
      expect(published, 0);
      // Replacing the extension that holds a task name is valid: the check
      // runs on the state after replacement.
      registry.install(defineExtension(
          name: 'tasks', tasks: [_task('app.index', version: 2)]));
      expect(registry.snapshot().task('app.index')?.definition.version, 2);
    });

    test('always holds the built-in tasks, which are not an extension', () {
      final registry = createRegistry<ToolRegistration>();
      expect(registry.snapshot().installed(), isEmpty);
      expect(
          registry
              .snapshot()
              .tasks()
              .map((task) => task.definition.name)
              .toList(),
          <String>['pi.generation', 'pi.tool', 'pi.compaction']);
      final custom = _task('app.custom');
      registry.install(defineExtension(name: 'custom', tasks: [custom]));
      expect(
          registry
              .snapshot()
              .tasks()
              .map((task) => task.definition.name)
              .toList(),
          <String>['pi.generation', 'pi.tool', 'pi.compaction', 'app.custom']);
      expect(identical(registry.snapshot().task('app.custom'), custom), isTrue);
      registry.uninstall(defineExtension(name: 'custom'));
      expect(registry.snapshot().task('app.custom'), isNull);
    });
  });

  group('define', () {
    test('section tags unless tag is false', () {
      final tagged = section('preamble', (input, ctx) => 'You code.');
      final untagged =
          section('preamble', (input, ctx) => 'You code.', tag: false);
      expect(tagged.key, 'preamble');
      expect(tagged.tag, isNull);
      expect(untagged.tag, isFalse);
    });

    test('hook matches a task by its name', () {
      final registration = hook(_task('app.index'), <String, Object?>{});
      expect(registration.task, 'app.index');
    });

    test('wrapTool and wrapSection build their tagged wrappers', () {
      final toolWrap = wrapTool(_tool('bash'), (inner) => inner);
      final sectionWrap =
          wrapSection<ToolRegistration>('cwd', (inner) => inner);
      expect(toolWrap.kind, 'tool');
      expect((toolWrap as ToolWrap<ToolRegistration>).tool, 'bash');
      expect(sectionWrap.kind, 'section');
      expect((sectionWrap as SectionWrap<ToolRegistration>).section, 'cwd');
    });
  });
}
