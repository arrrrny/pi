// A program running in a pseudo-terminal of a pi-env daemon.
//
// Port of `packages/env/src/terminal.ts` at the pinned upstream SHA.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'connection.dart';

/// Input larger than this goes to the daemon in several writes.
const int _writeChunk = 1024 * 1024;

/// Options for [openTerminal].
class TerminalOptions {
  /// Options with the required [cwd], [cols], [rows] and [onData], and optional
  /// [argv], [env] and [inheritEnv].
  TerminalOptions({
    required this.cwd,
    required this.cols,
    required this.rows,
    required this.onData,
    this.argv,
    this.env,
    this.inheritEnv,
  });

  /// Working directory of the program; it must exist.
  final String cwd;

  /// Program and arguments. Default: the user's shell as a login shell.
  final List<String>? argv;

  /// Added to the daemon's environment, or the whole environment with
  /// [inheritEnv] false. Set `TERM` here.
  final Map<String, String>? env;

  /// Whether to inherit the daemon's environment.
  final bool? inheritEnv;

  /// The terminal's width in cells.
  final int cols;

  /// The terminal's height in cells.
  final int rows;

  /// The terminal's raw output, in order.
  final void Function(Uint8List bytes) onData;
}

/// The foreground job of a terminal: its process group id, and its leader's
/// name if the system tells.
class TerminalForeground {
  /// A foreground job with [pid] and optional [name].
  const TerminalForeground(this.pid, [this.name]);

  /// The foreground process group id.
  final int pid;

  /// The leader's process name, when known.
  final String? name;
}

/// A program running in a pseudo-terminal of a pi-env daemon. It ends when the
/// program exits, [close] kills it, or the connection is lost.
class RemoteTerminal {
  /// A terminal handle with the given [pid], [exited] future and [abort].
  RemoteTerminal(
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

  /// Send input; once the terminal has ended, input is dropped.
  void write(Object data) {
    final bytes = data is String
        ? Uint8List.fromList(utf8.encode(data))
        : data as Uint8List;
    for (var offset = 0; offset < bytes.length; offset += _writeChunk) {
      _request(
          'ptyWrite',
          <String, dynamic>{},
          Uint8List.sublistView(
              bytes,
              offset,
              offset + _writeChunk < bytes.length
                  ? offset + _writeChunk
                  : bytes.length));
    }
  }

  /// Change the size; the program receives `SIGWINCH`.
  void resize(int cols, int rows) =>
      _request('ptyResize', <String, dynamic>{'cols': cols, 'rows': rows});

  /// Kill the program and everything in its session.
  void close() => _abort.abort();

  /// The job in the terminal's foreground when it is not the program itself.
  Future<TerminalForeground?> foreground() async {
    final reply = await _connection.request('ptyForeground',
        <String, dynamic>{'target': _id}, RequestOptions(session: _session));
    final foreground = reply.json['foreground'];
    if (foreground == null) return null;
    final map = foreground as Map;
    final name = map['name'];
    return TerminalForeground(
      map['pid'] as int,
      name is String && name.isNotEmpty ? name : null,
    );
  }

  void _request(String op, Map<String, dynamic> json, [Uint8List? payload]) {
    _connection
        .request(op, <String, dynamic>{...json, 'target': _id},
            RequestOptions(payload: payload, session: _session))
        .catchError((_) => Reply(<String, dynamic>{}, Uint8List(0), _session));
  }
}

/// Start a program in a new pseudo-terminal of the daemon behind [connection].
Future<RemoteTerminal> openTerminal(
    Connection connection, TerminalOptions options) async {
  final abort = AbortSignal();
  final started = Completer<RemoteTerminal>();
  late final Future<int> exited;
  int? requestId;
  int? requestSession;
  exited = connection
      .request(
        'pty',
        <String, dynamic>{
          'cwd': options.cwd,
          if (options.argv != null) 'argv': options.argv,
          if (options.env != null) 'env': options.env,
          if (options.inheritEnv != null) 'inheritEnv': options.inheritEnv,
          'cols': options.cols,
          'rows': options.rows,
        },
        RequestOptions(
          signal: abort,
          onStart: (id, session) {
            requestId = id;
            requestSession = session;
          },
          onEvent: (json, payload) {
            if (json['kind'] == 'output') {
              options.onData(payload);
            } else if (json['kind'] == 'started' &&
                requestId != null &&
                requestSession != null) {
              if (!started.isCompleted) {
                started.complete(RemoteTerminal(
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
