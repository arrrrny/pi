import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:pi/execution_env.dart'
    hide FileError, FileErrorCode, FileInfo, FileKind;
import 'package:pi/src/durable/env/index.dart' show FileError, FileErrorCode;

/// Path to the in-repo test daemon that speaks the pi-env wire protocol over
/// stdio, so the remote env surface is exercised without the Rust daemon.
final String _daemonScript =
    '${io.Directory.current.path}/test/env/test_daemon.dart';

final String? _daemonOverride = io.Platform.environment['PI_ENV_DAEMON'];

List<String> _daemonCommand() => _daemonOverride != null
    ? <String>[_daemonOverride!]
    : <String>[io.Platform.resolvedExecutable, _daemonScript];

void main() {
  group('nodePlatform', () {
    test('maps Rust os/arch names to Node names', () {
      expect(nodePlatform('macos', 'aarch64'),
          {'platform': 'darwin', 'arch': 'arm64'});
      expect(nodePlatform('windows', 'x86_64'),
          {'platform': 'win32', 'arch': 'x64'});
      expect(
          nodePlatform('linux', 'x86'), {'platform': 'linux', 'arch': 'ia32'});
    });

    test('keeps unknown names', () {
      expect(nodePlatform('plan9', 'riscv'),
          {'platform': 'plan9', 'arch': 'riscv'});
    });
  });

  group('RemoteError', () {
    test('reads code, message and path from fields', () {
      final error = RemoteError(<String, dynamic>{
        'code': 'ENOENT',
        'message': 'missing',
        'path': '/x',
      });
      expect(error.code, 'ENOENT');
      expect(error.message, 'missing');
      expect(error.path, '/x');
    });

    test('defaults code to unknown', () {
      final error = RemoteError(<String, dynamic>{'message': 'boom'});
      expect(error.code, 'unknown');
    });

    test('isConnectionLost is true only for a lost error', () {
      final lost =
          RemoteError(<String, dynamic>{'code': 'unknown', 'lost': true});
      final refused = RemoteError(<String, dynamic>{'code': 'ENOENT'});
      expect(isConnectionLost(lost), isTrue);
      expect(isConnectionLost(refused), isFalse);
      expect(isConnectionLost('not an error'), isFalse);
    });
  });

  group('toFileError', () {
    test('maps a RemoteError code to a FileError code', () {
      final mapped = toFileError(
        RemoteError(
            <String, dynamic>{'code': 'ENOENT', 'message': 'no', 'path': '/p'}),
      );
      expect(mapped.code.name, 'notFound');
      expect(mapped.path, '/p');
    });

    test('passes an existing FileError through', () {
      final original = FileError(FileErrorCode.invalid, 'bad');
      expect(toFileError(original), same(original));
    });
  });

  group('Connection / openProcess', () {
    late Connection connection;

    setUp(() {
      connection = Connection(command: _daemonCommand());
    });

    tearDown(() async {
      connection.close();
    });

    test('info reports the daemon protocol and features', () async {
      final info = await connection.info();
      expect(info.protocol, 1);
      expect(info.features, contains('process'));
    });

    test('openProcess runs a program and streams stdout', () async {
      final out = <int>[];
      final process = await openProcess(
        connection,
        ProcessOptions(
          cwd: io.Directory.systemTemp.path,
          argv: <String>['cat'],
          onStdout: out.addAll,
        ),
      );
      process.write('hello');
      process.closeStdin();
      final exitCode = await process.exited;
      expect(exitCode, 0);
      expect(utf8.decode(out), 'hello');
    });

    test('openProcess reports a non-zero exit code', () async {
      final process = await openProcess(
        connection,
        ProcessOptions(
          cwd: io.Directory.systemTemp.path,
          argv: <String>['sh', '-c', 'exit 3'],
          onStdout: (_) {},
        ),
      );
      expect(await process.exited, 3);
    });

    test('close kills the program and settles exited as aborted', () async {
      final process = await openProcess(
        connection,
        ProcessOptions(
          cwd: io.Directory.systemTemp.path,
          argv: <String>['cat'],
          onStdout: (_) {},
        ),
      );
      process.close();
      await expectLater(process.exited, throwsA(isA<RemoteError>()));
    });
  });

  group('Connection / openTerminal', () {
    late Connection connection;

    setUp(() {
      connection = Connection(command: _daemonCommand());
    });

    tearDown(() async {
      connection.close();
    });

    test('openTerminal runs a program and streams raw output', () async {
      final data = <int>[];
      final terminal = await openTerminal(
        connection,
        TerminalOptions(
          cwd: io.Directory.systemTemp.path,
          argv: <String>['sh', '-c', 'printf hi; exit 0'],
          cols: 80,
          rows: 24,
          onData: data.addAll,
        ),
      );
      expect(await terminal.exited, 0);
      expect(utf8.decode(data), contains('hi'));
    });

    test('resize and write do not throw', () async {
      final terminal = await openTerminal(
        connection,
        TerminalOptions(
          cwd: io.Directory.systemTemp.path,
          argv: <String>['cat'],
          cols: 80,
          rows: 24,
          onData: (_) {},
        ),
      );
      terminal.write('x');
      terminal.resize(120, 40);
      terminal.close();
      await expectLater(terminal.exited, throwsA(isA<RemoteError>()));
    });
  });

  group('frame codec', () {
    test('round-trips a frame with a payload', () {
      final bytes = encodeFrame(REQUEST, 7, <String, dynamic>{'op': 'ping'},
          Uint8List.fromList(<int>[1, 2, 3]));
      final frame = decodeFrame(bytes);
      expect(frame.type, REQUEST);
      expect(frame.id, 7);
      expect(frame.json['op'], 'ping');
      expect(frame.payload, isNotNull);
      expect(List<int>.from(frame.payload!), <int>[1, 2, 3]);
    });

    // Regression: the encoder and decoder must agree on UTF-8. A non-ASCII
    // byte in a path/env/argv/error corrupts or throws against the real
    // daemon when the encoder truncates UTF-16 code units to bytes.
    test('round-trips a frame with non-ASCII JSON', () {
      final bytes = encodeFrame(REQUEST, 9, <String, dynamic>{
        'op': 'process',
        'cwd': '/tmp/日本語',
        'argv': <String>['echo', 'héllo', '🌍'],
      });
      final frame = decodeFrame(bytes);
      expect(frame.json['cwd'], '/tmp/日本語');
      expect(frame.json['argv'], <String>['echo', 'héllo', '🌍']);
    });
  });
}
