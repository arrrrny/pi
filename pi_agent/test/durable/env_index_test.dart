// Env capability surface: the fallible `Result`, the file/execution error
// taxonomy, and the environment contracts (filesystem, shell, readers).
//
// Differential port of `packages/durable/src/env/index.ts` at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`. The oracle is the upstream
// TypeScript semantics: `ok`/`err` build the discriminated union, `getOrThrow`
// returns the value or rethrows the error, `getOrUndefined` maps a failure to
// `undefined`, `toError` wraps a non-`Error` value, and the error classes carry
// their `code`/`path`/`spillPath`. The interfaces have no runtime behaviour of
// their own; a single fake `ExecutionEnv` proves the contracts are satisfiable
// and that `ExecutionEnv` is exactly `FileSystem & Shell`.

import 'package:pi/durable.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('ok builds a success carrying its value', () {
      final Result<int, String> result = ok<int, String>(7);
      expect(result.ok, isTrue);
      expect(result, isA<Ok<int, String>>());
      expect(getOrThrow(result), 7);
      expect(getOrUndefined(result), 7);
    });

    test('err builds a failure carrying its error', () {
      final Result<int, String> result = err<int, String>('boom');
      expect(result.ok, isFalse);
      expect(result, isA<Err<int, String>>());
      expect(getOrUndefined(result), isNull);
    });

    test('getOrThrow rethrows the failure error', () {
      final Result<int, String> result = err<int, String>('boom');
      expect(() => getOrThrow(result), throwsA('boom'));
    });

    test('getOrThrow rethrows a non-Error failure value as thrown', () {
      final Result<int, Object> result = err<int, Object>(42);
      Object? caught;
      try {
        getOrThrow(result);
      } on Object catch (error) {
        caught = error;
      }
      expect(caught, 42);
    });

    test('getOrUndefined keeps a falsy-but-present value', () {
      final Result<int, String> result = ok<int, String>(0);
      expect(getOrUndefined(result), 0);
    });
  });

  group('toError', () {
    test('an Error passes through unchanged', () {
      final error = StateError('already');
      expect(toError(error), same(error));
    });

    test('a string becomes its message', () {
      expect(toError('nope').toString(), 'nope');
    });

    test('a non-Error value is JSON-encoded', () {
      expect(toError(<String, int>{'a': 1}).toString(), '{"a":1}');
    });

    test('a value that does not encode falls back to toString', () {
      final error = toError(const _Unencodable());
      expect(error.toString(), 'unencodable');
    });
  });

  group('FileError', () {
    test('carries code, message and path', () {
      final error = FileError(FileErrorCode.notFound, 'missing', path: '/x/y');
      expect(error.code, FileErrorCode.notFound);
      expect(error.message, 'missing');
      expect(error.path, '/x/y');
      expect(error.toString(), 'FileError(notFound): missing');
    });

    test('is an Error and keeps its cause', () {
      final cause = StateError('root');
      final error = FileError(FileErrorCode.invalid, 'bad', cause: cause);
      expect(error, isA<Error>());
      expect(error.cause, same(cause));
    });
  });

  group('ExecutionError', () {
    test('carries code, message and spill path', () {
      final error =
          ExecutionError(ExecutionErrorCode.timeout, 'killed', spillPath: '/s');
      expect(error.code, ExecutionErrorCode.timeout);
      expect(error.message, 'killed');
      expect(error.spillPath, '/s');
      expect(error.toString(), 'ExecutionError(timeout): killed');
    });
  });

  group('data types', () {
    test('FileInfo, TextLine and list types hold their fields', () {
      const info = FileInfo(
          name: 'a', path: '/a', kind: FileKind.file, size: 3, mtimeMs: 9);
      expect(info.kind, FileKind.file);
      expect(info.size, 3);
      const line = TextLine(text: 'hi', terminated: true);
      expect(line.text, 'hi');
      expect(line.terminated, isTrue);
      const entry = FileListEntry(path: 'a/b', kind: FileKind.directory);
      expect(entry.kind, FileKind.directory);
      const listing =
          FileListing(entries: <FileListEntry>[entry], truncated: true);
      expect(listing.entries.single.path, 'a/b');
      expect(listing.truncated, isTrue);
    });

    test('FileChange variants are a tagged union', () {
      final changes = <FileChange>[
        FileChangePaths(<String>['/a']),
        FileChangeOverflow(),
        FileChangeFailed(FileError(FileErrorCode.aborted, 'stop')),
      ];
      final kinds = changes
          .map((change) => switch (change) {
                FileChangePaths() => 'paths',
                FileChangeOverflow() => 'overflow',
                FileChangeFailed() => 'failed',
              })
          .toList();
      expect(kinds, <String>['paths', 'overflow', 'failed']);
    });

    test('shell option and result types hold their fields', () {
      const spill = ShellSpillOptions(afterBytes: 10, afterLines: 2);
      expect(spill.afterLines, 2);
      const skip =
          ShellOutputSkip(bytes: 5, newlines: 1, endsWithNewline: true);
      final info = ShellOutputInfo(stream: 'stdout', skipped: skip);
      expect(info.stream, 'stdout');
      expect(info.skipped?.endsWithNewline, isTrue);
      const result = ShellExecResult(exitCode: 0, spillPath: '/tmp/s');
      expect(result.exitCode, 0);
      expect(result.spillPath, '/tmp/s');
    });
  });

  group('ExecutionEnv contract', () {
    test('a fake environment satisfies FileSystem and Shell', () async {
      final ExecutionEnv env = _FakeEnv();
      env.cwd = '/work';
      expect(env.id, 'fake');
      expect(env.cwd, '/work');
      expect((await env.exists('/x', backgroundContext)).ok, isTrue);
      final exec = await env.exec('echo hi', null, backgroundContext);
      expect(getOrThrow(exec).exitCode, 0);
    });
  });
}

/// A value whose JSON encoding throws, to exercise `toError`'s fallback.
class _Unencodable {
  const _Unencodable();

  @override
  String toString() => 'unencodable';

  Object toJson() => throw StateError('no json');
}

/// A minimal environment proving the `ExecutionEnv` (= `FileSystem` + `Shell`)
/// contract is implementable; every method returns an `ok` result.
class _FakeEnv implements ExecutionEnv {
  @override
  String id = 'fake';

  @override
  String cwd = '/';

  Result<T, FileError> _ok<T>(T value) => ok<T, FileError>(value);

  @override
  Future<Result<String, FileError>> absolutePath(
          String path, Context context) async =>
      _ok(path);

  @override
  Future<Result<String, FileError>> joinPath(
          List<String> parts, Context context) async =>
      _ok(parts.join('/'));

  @override
  Future<Result<String, FileError>> readTextFile(
          String path, Context context) async =>
      _ok('');

  @override
  Future<Result<TextLineReader, FileError>> openTextLineReader(
          String path, Context context) async =>
      throw UnimplementedError('not exercised');

  @override
  Future<Result<List<String>, FileError>> readTextLines(
          String path, Map<String, int>? options, Context context) async =>
      _ok(<String>[]);

  @override
  Future<Result<List<int>, FileError>> readBinaryFile(
          String path, Context context) async =>
      _ok(<int>[]);

  @override
  Future<Result<BinaryReader, FileError>> openBinaryReader(
          String path, Map<String, bool>? options, Context context) async =>
      throw UnimplementedError('not exercised');

  @override
  Future<Result<void, FileError>> writeFile(
          String path, Object content, Context context) async =>
      _ok(null);

  @override
  Future<Result<void, FileError>> appendFile(
          String path, Object content, Context context) async =>
      _ok(null);

  @override
  Future<Result<void, FileError>> truncateFile(
          String path, int size, Context context) async =>
      _ok(null);

  @override
  Future<Result<void, FileError>> flushFile(
          String path, Context context) async =>
      _ok(null);

  @override
  Future<Result<void, FileError>> renameFile(
          String sourcePath, String destinationPath, Context context) async =>
      _ok(null);

  @override
  Future<Result<FileInfo, FileError>> fileInfo(
          String path, Context context) async =>
      _ok(const FileInfo(
          name: '', path: '', kind: FileKind.file, size: 0, mtimeMs: 0));

  @override
  Future<Result<List<FileInfo>, FileError>> listDir(
          String path, Context context) async =>
      _ok(<FileInfo>[]);

  @override
  Future<Result<FileListing, FileError>> listFiles(
          String path, ListFilesOptions? options, Context context) async =>
      _ok(const FileListing(entries: <FileListEntry>[], truncated: false));

  @override
  Future<Result<DirReader, FileError>> openDirReader(
          String path, Context context) async =>
      throw UnimplementedError('not exercised');

  @override
  Future<Result<FileWatcher, FileError>> watch(List<WatchTarget> targets,
          void Function(FileChange change) onChange, Context context) async =>
      throw UnimplementedError('not exercised');

  @override
  Future<Result<String, FileError>> canonicalPath(
          String path, Context context) async =>
      _ok(path);

  @override
  Future<Result<bool, FileError>> exists(String path, Context context) async =>
      _ok(true);

  @override
  Future<Result<void, FileError>> createDir(
          String path, Map<String, bool>? options, Context context) async =>
      _ok(null);

  @override
  Future<Result<void, FileError>> remove(
          String path, Map<String, bool>? options, Context context) async =>
      _ok(null);

  @override
  Future<Result<String, FileError>> createTempDir(
          String? prefix, Context context) async =>
      _ok('/tmp/x');

  @override
  Future<Result<String, FileError>> createTempFile(
          Map<String, String>? options, Context context) async =>
      _ok('/tmp/x');

  @override
  Future<void> cleanup(Context context) async {}

  @override
  Future<Result<ShellExecResult, ExecutionError>> exec(
          Object command, ShellExecOptions? options, Context context) async =>
      ok<ShellExecResult, ExecutionError>(const ShellExecResult(exitCode: 0));
}
