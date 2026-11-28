// A program running with plain pipes in a pi-env daemon.
//
// Port of `packages/env/src/process.ts` at the pinned upstream SHA.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'connection.dart';

/// Input larger than this goes to the daemon in several writes.
const int _writeChunk = 1024 * 1024;

/// Options for [openProcess].
class ProcessOptions {
  /// Options with the required [cwd], [argv] and [onStdout], and optional
  /// [env], [inheritEnv] and [onStderr].
  ProcessOptions({
    required this.cwd,
    required this.argv,
    required this.onStdout,
    this.env,
    this.inheritEnv,
    this.onStderr,
  });

  /// Working directory of the program; it must exist.
  final String cwd;

  /// Program and arguments, run directly without a shell.
  final List<String> argv;

  /// Added to the daemon's environment, or the whole environment with
  /// [inheritEnv] false.
  final Map<String, String>? env;

  /// Whether to inherit the daemon's environment.
  final bool? inheritEnv;

  /// The program's stdout, raw bytes in order.
  final void Function(Uint8List bytes) onStdout;

  /// The program's stderr, raw bytes in order.
  final void Function(Uint8List bytes)? onStderr;
}

/// A program running with plain pipes in a pi-env daemon. It ends when the
/// program exits, [close] kills it, or the connection is lost.
class RemoteProcess {
  /// A process handle with the given [pid], [exited] future and [abort].
  RemoteProcess(
    this._connection,
    this._id,
    this._session,
    this.pid,
    this.exited,
    this._abort,
  );

  final Connection _connection;
  final int _id;
  final int _session;
  final AbortSignal _abort;

  /// The program's process id.
  final int pid;

  /// The exit code; completes with the daemon's error, code `aborted` after
  /// [close].
  final Future<int> exited;

  /// Write to the program's stdin, in order.
  void write(Object data) {
    final bytes = data is String
        ? Uint8List.fromList(utf8.encode(data))
        : data as Uint8List;
    for (var offset = 0; offset < bytes.length; offset += _writeChunk) {
      _request(
          'processWrite',
          Uint8List.sublistView(
              bytes,
              offset,
              offset + _writeChunk < bytes.length
                  ? offset + _writeChunk
                  : bytes.length));
    }
  }

  /// Close the program's stdin after the input written before it.
  void closeStdin() => _request('processCloseStdin');

  /// Kill the program and its process group.
  void close() => _abort.abort();

  void _request(String op, [Uint8List? payload]) {
    _connection
        .request(op, <String, dynamic>{'target': _id},
            RequestOptions(payload: payload, session: _session))
        .catchError((_) => Reply(<String, dynamic>{}, Uint8List(0), _session));
  }
}

/// Start a program with plain pipes in the daemon behind [connection].
Future<RemoteProcess> openProcess(
    Connection connection, ProcessOptions options) async {
  final info = await connection.info();
  if (!info.features.contains('process')) {
    throw RemoteError(<String, dynamic>{
      'code': 'not_supported',
      'message': 'The pi-env daemon cannot run processes; update it',
    });
  }
  final abort = AbortSignal();
  final started = Completer<RemoteProcess>();
  late final Future<int> exited;
  int? requestId;
  int? requestSession;
  exited = connection
      .request(
        'process',
        <String, dynamic>{
          'cwd': options.cwd,
          'argv': options.argv,
          if (options.env != null) 'env': options.env,
          if (options.inheritEnv != null) 'inheritEnv': options.inheritEnv,
        },
        RequestOptions(
          signal: abort,
          onStart: (id, session) {
            requestId = id;
            requestSession = session;
          },
          onEvent: (json, payload) {
            if (json['kind'] == 'output') {
              if (json['stream'] == 'stderr') {
                options.onStderr?.call(payload);
              } else {
                options.onStdout(payload);
              }
            } else if (json['kind'] == 'started' &&
                requestId != null &&
                requestSession != null) {
              if (!started.isCompleted) {
                started.complete(RemoteProcess(
                  connection,
                  requestId!,
                  requestSession!,
                  json['pid'] is int
                      ? json['pid'] as int
                      : int.parse('${json['pid']}'),
                  exited,
                  abort,
                ));
              }
            }
          },
        ),
      )
      .then((reply) {
        final code = reply.json['exitCode'];
        return code is num ? code.toInt() : int.parse('$code');
      });
  exited.catchError((Object error, StackTrace st) {
    if (!started.isCompleted) started.completeError(error, st);
    return 0;
  });
  return started.future;
}
