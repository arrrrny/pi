import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:pi/execution_env.dart' as env;
import 'package:pi/src/chord/context.dart';
import 'package:pi/src/durable/env/index.dart' as durable;
import 'package:test/test.dart';

final String? _daemonOverride = io.Platform.environment['PI_ENV_DAEMON'];

List<String> _daemonCommand([List<String> extra = const <String>[]]) =>
    _daemonOverride != null
        ? <String>[_daemonOverride!, ...extra]
        : <String>[
            io.Platform.resolvedExecutable,
            '${io.Directory.current.path}/test/env/test_daemon.dart',
            ...extra,
          ];

extension _ResultValue<T, E> on durable.Result<T, E> {
  T get value => durable.getOrThrow(this);
  E get error => switch (this) {
        durable.Ok<T, E>() => throw StateError('expected an error result'),
        durable.Err<T, E>(:final error) => error,
      };
}

void main() {
  late io.Directory root;
  late env.Connection connection;
  late env.RemoteExecutionEnv remote;

  setUp(() async {
    root = await io.Directory.systemTemp.createTemp('pi-env-dart-');
    connection = env.Connection(command: _daemonCommand());
    remote = env.RemoteExecutionEnv(
      connection: connection,
      id: 'pi-env:test',
      cwd: root.path,
    );
  });

  tearDown(() async {
    connection.close();
    if (await root.exists()) await root.delete(recursive: true);
  });

  group('RemoteExecutionEnv filesystem (#85)', () {
    test('resolves paths and round-trips text and binary files', () async {
      expect((await remote.absolutePath('.', Context.background)).value,
          root.path);
      expect(
        (await remote.joinPath(<String>['a', 'b'], Context.background)).value,
        'a/b',
      );

      await remote.writeFile('a.txt', 'hello', Context.background);
      await remote.appendFile('a.txt', ' world', Context.background);
      expect(
        (await remote.readTextFile('a.txt', Context.background)).value,
        'hello world',
      );

      final bytes = Uint8List.fromList(<int>[0, 1, 2, 255]);
      await remote.writeFile('a.bin', bytes, Context.background);
      expect(
        (await remote.readBinaryFile('a.bin', Context.background)).value,
        bytes,
      );
      await remote.writeFile('list.bin', <int>[9, 8, 7], Context.background);
      expect(
        (await remote.readBinaryFile('list.bin', Context.background)).value,
        <int>[9, 8, 7],
      );

      final info = (await remote.fileInfo('a.txt', Context.background)).value;
      expect(info.name, 'a.txt');
      expect(info.kind, durable.FileKind.file);
      expect(info.size, 11);
      expect(
          (await remote.exists('missing', Context.background)).value, isFalse);
    });

    test('preserves aborted file errors when a context is cancelled', () async {
      await remote.writeFile('abort.txt', 'x', Context.background);
      final slowConnection = env.Connection(
        command: _daemonCommand(<String>['--slow-open']),
      );
      addTearDown(slowConnection.close);
      final slow = env.RemoteExecutionEnv(
        connection: slowConnection,
        id: 'pi-env:slow',
        cwd: root.path,
      );
      final signal = AbortSignal();
      Timer(const Duration(milliseconds: 100), signal.abort);
      final result = await slow.readTextFile(
        'abort.txt',
        Context(signal: signal),
      );
      expect(result.error.code, durable.FileErrorCode.aborted);
    },
        skip: _daemonOverride != null
            ? 'requires the fake daemon slow-open mode'
            : false);

    test('writes and reads transfers larger than one protocol chunk', () async {
      final content = Uint8List.fromList(List<int>.generate(
        3500017,
        (index) => (index * 7919) % 251,
      ));
      await remote.writeFile('big.bin', content, Context.background);
      await remote.appendFile('big.bin', content, Context.background);
      final read =
          (await remote.readBinaryFile('big.bin', Context.background)).value;
      expect(read, hasLength(content.length * 2));
      expect(read.sublist(0, content.length), content);
      expect(read.sublist(content.length), content);
      final reader = (await remote.openBinaryReader(
        'big.bin',
        null,
        Context.background,
      ))
          .value;
      final range =
          (await reader.read(1000003, 2000000, Context.background)).value;
      expect(range, read.sublist(1000003, 3000003));
      await reader.close(Context.background);
    });

    test('lists directories and reads pages, lines, and binary ranges',
        () async {
      await remote.createDir('nested', null, Context.background);
      await remote.writeFile(
          'nested/a.txt', 'one\ntwo\nthree', Context.background);
      await remote.writeFile('nested/b.txt', 'b', Context.background);

      final entries =
          (await remote.listDir('nested', Context.background)).value;
      expect(entries.map((entry) => entry.name), <String>['a.txt', 'b.txt']);

      final dirReader =
          (await remote.openDirReader('nested', Context.background)).value;
      final first = (await dirReader.next(1, Context.background)).value;
      final second = (await dirReader.next(10, Context.background)).value;
      expect(first.entries.single.name, anyOf('a.txt', 'b.txt'));
      expect(first.done, isFalse);
      expect(second.entries.single.name, anyOf('a.txt', 'b.txt'));
      expect(second.entries.single.name, isNot(first.entries.single.name));
      expect(second.done, isTrue);
      await dirReader.close(Context.background);

      final lineReader =
          (await remote.openTextLineReader('nested/a.txt', Context.background))
              .value;
      expect(
        ((await lineReader.readLine(Context.background)).value
                as durable.TextLine)
            .text,
        'one',
      );
      await lineReader.close(Context.background);
      expect(
        (await remote.readTextLines(
          'nested/a.txt',
          <String, int>{'maxLines': 2},
          Context.background,
        ))
            .value,
        <String>['one', 'two'],
      );

      final binaryReader = (await remote.openBinaryReader(
        'nested/a.txt',
        null,
        Context.background,
      ))
          .value;
      expect(
        utf8.decode((await binaryReader.read(4, 3, Context.background)).value),
        'two',
      );
      final scan = (await binaryReader.scanLines(
        <String, int>{'startLine': 1, 'endLine': 2},
        Context.background,
      ))
          .value;
      expect(scan.newlines, 2);
      expect(scan.start, 4);
      expect(scan.end, 7);
      expect(scan.firstLineEnd, 7);
      expect(scan.lastLineStart, 4);
      expect(scan.selectedBytes, 3);
      expect(scan.firstLineBytes, 3);
      await binaryReader.close(Context.background);
    });

    test('renames, truncates, removes, and creates temporary files', () async {
      await remote.writeFile('before.txt', 'abcdef', Context.background);
      await remote.renameFile('before.txt', 'after.txt', Context.background);
      await remote.truncateFile('after.txt', 3, Context.background);
      expect(
        (await remote.readTextFile('after.txt', Context.background)).value,
        'abc',
      );
      expect(
        (await remote.canonicalPath('after.txt', Context.background)).value,
        io.File('${root.path}/after.txt').resolveSymbolicLinksSync(),
      );
      await remote.remove('after.txt', null, Context.background);
      expect((await remote.exists('after.txt', Context.background)).value,
          isFalse);

      final temp = (await remote.createTempFile(
        <String, String>{'prefix': 'pi-', 'suffix': '.txt'},
        Context.background,
      ))
          .value;
      expect(temp, startsWith('${io.Directory.systemTemp.path}/'));
      expect((await remote.exists(temp, Context.background)).value, isTrue);
    });

    test('lists a bounded tree without following excluded directories',
        () async {
      await remote.createDir('nested', null, Context.background);
      await remote.writeFile('nested/file.txt', 'x', Context.background);
      await remote.writeFile('.hidden', 'x', Context.background);
      await remote.createDir('skip', null, Context.background);
      await remote.writeFile('skip/file.txt', 'x', Context.background);

      final listing = (await remote.listFiles(
        '.',
        durable.ListFilesOptions(hidden: false, exclude: <String>['skip']),
        Context.background,
      ))
          .value;
      expect(
        listing.entries.map((entry) => entry.path),
        containsAll(<String>['nested', 'nested/file.txt']),
      );
      expect(
        listing.entries.map((entry) => entry.path),
        isNot(contains('.hidden')),
      );
      expect(
        listing.entries.map((entry) => entry.path),
        isNot(contains('skip')),
      );

      final bounded = (await remote.listFiles(
        '.',
        const durable.ListFilesOptions(maxEntries: 1),
        Context.background,
      ))
          .value;
      expect(bounded.entries, hasLength(1));
      expect(bounded.truncated, isTrue);

      final invalid = await remote.listFiles(
        '.',
        const durable.ListFilesOptions(maxEntries: -1),
        Context.background,
      );
      expect(invalid.error.code, durable.FileErrorCode.invalid);
    });

    test('reports listFiles as unsupported by an older daemon', () async {
      final oldConnection = env.Connection(
        command: _daemonCommand(<String>['--old']),
      );
      addTearDown(oldConnection.close);
      final old = env.RemoteExecutionEnv(
        connection: oldConnection,
        id: 'pi-env:old',
        cwd: root.path,
      );
      final result = await old.listFiles('.', null, Context.background);
      expect(result.error.code, durable.FileErrorCode.notSupported);
    },
        skip: _daemonOverride != null
            ? 'requires the fake daemon old-feature mode'
            : false);
  });

  group('RemoteExecutionEnv commands (#85)', () {
    test('runs shell and argv commands with decoded output', () async {
      final output = <String>[];
      final result = await remote.exec(
        'printf hello',
        durable.ShellExecOptions(
          onOutput: (text, context, info) {
            expect(info.stream, 'stdout');
            output.add(text);
          },
        ),
        Context.background,
      );
      expect(result.value.exitCode, 0);
      expect(output.join(), 'hello');

      final argv = await remote.exec(
        <String>['sh', '-c', 'exit 7'],
        null,
        Context.background,
      );
      expect(argv.value.exitCode, 7);

      final bomOutput = <String>[];
      final bom = await remote.exec(
        <String>['sh', '-c', r"printf '\357\273\277hello'"],
        durable.ShellExecOptions(
          onOutput: (text, context, info) => bomOutput.add(text),
        ),
        Context.background,
      );
      expect(bom.value.exitCode, 0);
      expect(bomOutput.join(), _daemonOverride == null ? '\ufeffhello' : 'hello');
    });

    test('times out and aborts commands', () async {
      final timedOut = await remote.exec(
        <String>['sleep', '5'],
        durable.ShellExecOptions(timeout: 0.05),
        Context.background,
      );
      expect(timedOut.error.code, durable.ExecutionErrorCode.timeout);

      final signal = AbortSignal();
      final running = remote.exec(
        <String>['sleep', '5'],
        null,
        Context(signal: signal),
      );
      signal.abort();
      final aborted = await running;
      expect(aborted.error.code, durable.ExecutionErrorCode.aborted);
    });
  });

  group('RemoteWatcher (#85)', () {
    test('reports ready, changes, and stops idempotently', () async {
      final changed = Completer<void>();
      final watcherResult = await remote.watch(
        <durable.WatchTarget>[const durable.WatchTarget(path: '.')],
        (change) {
          if (change is durable.FileChangePaths && !changed.isCompleted) {
            changed.complete();
          }
        },
        Context.background,
      );
      final watcher = watcherResult.value;
      // The fake daemon reports ready before watch() returns.
      expect(watcher.mode, 'native');
      await remote.writeFile('watched.txt', 'x', Context.background);
      await changed.future.timeout(const Duration(seconds: 3));
      await watcher.stop(Context.background);
      await watcher.stop(Context.background);
    });

    test('reconnects after a lost daemon and reports overflow', () async {
      final overflow = Completer<void>();
      final changed = Completer<void>();
      final watcher = (await remote.watch(
        <durable.WatchTarget>[const durable.WatchTarget(path: '.')],
        (change) {
          if (change is durable.FileChangeOverflow && !overflow.isCompleted) {
            overflow.complete();
          }
          if (change is durable.FileChangePaths &&
              overflow.isCompleted &&
              !changed.isCompleted) {
            changed.complete();
          }
        },
        Context.background,
      ))
          .value;
      final info = await connection.info();
      final killed =
          await io.Process.run('/bin/kill', <String>['-9', '${info.pid}']);
      expect(killed.exitCode, 0);
      await overflow.future.timeout(const Duration(seconds: 5));
      await remote.writeFile('after-reconnect.txt', 'x', Context.background);
      await changed.future.timeout(const Duration(seconds: 5));
      await watcher.stop(Context.background);
    });
  });
}
