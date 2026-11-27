// A client connection to a pi-env daemon, and the wire-protocol frame codec.
//
// Port of `packages/env/src/connection.ts` at the pinned upstream SHA. The
// client starts the daemon (`serve --token <hex>`) lazily on the first request,
// speaks the version-1 frame protocol over the process's stdin/stdout, and
// starts a fresh daemon after the connection is lost. A request in flight when
// the connection is lost fails with code `unknown` and `lost: true`.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';

/// The request frame type: client to daemon, `json.op` names the operation.
// ignore: constant_identifier_names
const int REQUEST = 1;

/// The result frame type: a request succeeded.
// ignore: constant_identifier_names
const int RESULT = 2;

/// The error frame type: a request failed.
// ignore: constant_identifier_names
const int ERROR = 3;

/// The event frame type: progress of a running request.
// ignore: constant_identifier_names
const int EVENT = 4;

/// The cancel frame type: cancel a request.
// ignore: constant_identifier_names
const int CANCEL = 5;

/// The ping frame type: liveness.
// ignore: constant_identifier_names
const int PING = 6;

/// The largest frame the protocol allows (16 MiB).
const int maxFrame = 16 * 1024 * 1024;

const int _pingIntervalMs = 5000;
const int _silenceLimitMs = 30000;
const int _startTimeoutMs = 60000;
const int _abortGraceMs = 1000;

/// A decoded wire frame: its [type], request [id], JSON object and raw
/// [payload] bytes (empty when the frame carries none).
class Frame {
  /// A frame with the given fields.
  const Frame(this.type, this.id, this.json, this.payload);

  /// The frame type (one of the `*` constants).
  final int type;

  /// The request id, or 0 for frames that belong to no request.
  final int id;

  /// The JSON object carried by the frame.
  final Map<String, dynamic> json;

  /// The raw payload bytes after the JSON, empty when none.
  final Uint8List? payload;
}

/// Encodes one frame with [type], [id], JSON [json] and optional [payload].
Uint8List encodeFrame(int type, int id, Map<String, dynamic> json,
    [Uint8List? payload]) {
  final body = Uint8List.fromList(utf8.encode(jsonEncode(json)));
  final payloadBytes = payload ?? Uint8List(0);
  final length = 9 + body.length + payloadBytes.length;
  final frame = Uint8List(4 + length);
  final view = ByteData.view(frame.buffer);
  view.setUint32(0, length);
  view.setUint8(4, type);
  view.setUint32(5, id);
  view.setUint32(9, body.length);
  frame.setRange(13, 13 + body.length, body);
  frame.setRange(
      13 + body.length, 13 + body.length + payloadBytes.length, payloadBytes);
  return frame;
}

/// Decodes the first frame in [bytes], returning it and the number of bytes it
/// occupies. Throws [FormatException] on a malformed header or JSON body.
Frame decodeFrame(Uint8List bytes) {
  if (bytes.length < 4) {
    throw const FormatException('frame too short');
  }
  final view = ByteData.view(bytes.buffer, bytes.offsetInBytes);
  final length = view.getUint32(0);
  if (length < 9 || length > maxFrame) {
    throw const FormatException('frame length out of range');
  }
  if (4 + length > bytes.length) {
    throw const FormatException('frame truncated');
  }
  final type = view.getUint8(4);
  final id = view.getUint32(5);
  final jsonLength = view.getUint32(9);
  if (9 + jsonLength > length) {
    throw const FormatException('JSON length out of range');
  }
  final jsonBytes = bytes.sublist(13, 13 + jsonLength);
  final decoded = jsonDecode(utf8.decode(jsonBytes));
  final json = decoded is Map<String, dynamic>
      ? decoded
      : Map<String, dynamic>.from(decoded as Map);
  final payload =
      Uint8List.fromList(bytes.sublist(13 + jsonLength, 4 + length));
  return Frame(type, id, json, payload);
}

/// A failure reported by the daemon, with its Node-style code.
class RemoteError extends Error {
  /// An error built from the daemon's error fields.
  RemoteError(Map<String, dynamic> fields)
      : code = fields['code'] is String ? fields['code'] as String : 'unknown',
        message = fields['message'] is String
            ? fields['message'] as String
            : 'Remote operation failed',
        path = fields['path'] is String ? fields['path'] as String : null,
        fields = fields;

  /// A Node-style error code (`ENOENT`, `aborted`, ...).
  final String code;

  /// A human-readable message.
  final String message;

  /// The path the operation targeted, when the daemon reported one.
  final String? path;

  /// The full error fields from the daemon.
  final Map<String, dynamic> fields;

  @override
  String toString() => 'RemoteError($code): $message';
}

/// Whether [error] means the connection was lost, not that the daemon refused
/// the request.
bool isConnectionLost(Object? error) =>
    error is RemoteError && error.fields['lost'] == true;

/// Node's names for the daemon's system and architecture, which `hello`
/// reports in Rust's spelling.
Map<String, String> nodePlatform(String os, String arch) {
  const platforms = <String, String>{'windows': 'win32', 'macos': 'darwin'};
  const archs = <String, String>{
    'x86_64': 'x64',
    'aarch64': 'arm64',
    'x86': 'ia32'
  };
  return <String, String>{
    'platform': platforms[os] ?? os,
    'arch': archs[arch] ?? arch,
  };
}

/// What `hello` reports about the remote machine.
class RemoteInfo {
  /// Info built from the daemon's `hello` reply.
  RemoteInfo(this.fields)
      : protocol = fields['protocol'] as int? ?? 0,
        version = fields['version'] as String? ?? '',
        os = fields['os'] as String? ?? '',
        arch = fields['arch'] as String? ?? '',
        home = fields['home'] as String? ?? '',
        separator = fields['separator'] as String? ?? '/',
        cwd = fields['cwd'] as String? ?? '',
        pid = fields['pid'] as int? ?? 0,
        features = fields['features'] is List
            ? (fields['features'] as List).cast<String>()
            : const <String>[];

  /// The raw `hello` fields.
  final Map<String, dynamic> fields;

  /// The protocol version the daemon speaks.
  final int protocol;

  /// The daemon's package version.
  final String version;

  /// The remote OS in Rust's spelling (`linux`, `macos`, ...).
  final String os;

  /// The remote architecture in Rust's spelling (`x86_64`, `aarch64`, ...).
  final String arch;

  /// The remote home directory.
  final String home;

  /// The remote path separator.
  final String separator;

  /// The daemon's working directory.
  final String cwd;

  /// The daemon's process id.
  final int pid;

  /// Operations added to protocol 1 that this daemon supports.
  final List<String> features;
}

/// A request's progress and result callbacks.
class RequestOptions {
  /// Options with optional [payload], [signal], [onEvent], [onStart] and
  /// [session].
  RequestOptions({
    this.payload,
    this.signal,
    this.onEvent,
    this.onStart,
    this.session,
  });

  /// A raw payload sent with the request.
  final Uint8List? payload;

  /// Aborts the request; see [Connection.request].
  final AbortSignal? signal;

  /// Progress events of a running request.
  final void Function(Map<String, dynamic> json, Uint8List payload)? onEvent;

  /// Receives the request's id and the daemon session that will answer.
  final void Function(int id, int session)? onStart;

  /// The daemon session that must answer, for requests on handles it opened.
  final int? session;
}

/// The daemon's reply to a request.
class Reply {
  /// A reply with [json], [payload] and the answering [session].
  const Reply(this.json, this.payload, this.session);

  /// The reply's JSON object.
  final Map<String, dynamic> json;

  /// The reply's raw payload bytes.
  final Uint8List payload;

  /// The daemon session that answered.
  final int session;
}

/// A minimal abort signal: a one-shot flag with a completion future.
class AbortSignal {
  /// A signal that is not aborted.
  AbortSignal();

  /// Whether [abort] has been called.
  bool get aborted => _aborted;
  bool _aborted = false;

  final List<void Function()> _listeners = <void Function()>[];

  /// Aborts the signal, notifying every listener once.
  void abort() {
    if (_aborted) return;
    _aborted = true;
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
    _listeners.clear();
  }

  void _addListener(void Function() listener) {
    if (_aborted) {
      listener();
      return;
    }
    _listeners.add(listener);
  }

  void _removeListener(void Function() listener) {
    _listeners.remove(listener);
  }
}

/// A command that starts the daemon, or a function computing it at each start.
typedef DaemonCommand = Object Function();

class _Pending {
  _Pending(this.resolve, this.reject, this.onEvent);

  final void Function(Reply) resolve;
  final void Function(Object) reject;
  final void Function(Map<String, dynamic>, Uint8List)? onEvent;
}

class _Session {
  _Session(this.id, this.process, this.token);

  final int id;
  final io.Process process;
  final String token;
  final Map<int, _Pending> pending = <int, _Pending>{};
  final List<Uint8List> chunks = <Uint8List>[];
  int buffered = 0;
  bool synced = false;
  int lastSeen = DateTime.now().millisecondsSinceEpoch;
  Timer? timer;
  bool live = true;

  Uint8List peek(int length) {
    if (chunks.isEmpty || chunks.first.length < length) {
      final all = Uint8List(buffered);
      var offset = 0;
      for (final chunk in chunks) {
        all.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }
      chunks
        ..clear()
        ..add(all);
    }
    return Uint8List.sublistView(chunks.first, 0, length);
  }

  void consume(int length) {
    buffered -= length;
    while (length > 0) {
      final first = chunks.first;
      if (first.length <= length) {
        chunks.removeAt(0);
        length -= first.length;
      } else {
        chunks[0] = Uint8List.sublistView(first, length);
        length = 0;
      }
    }
  }
}

/// One connection to a pi-env daemon: started lazily on the first request and
/// started again after it is lost.
class Connection {
  /// A connection that starts the daemon with [command] (a command list or a
  /// function returning one), reporting diagnostics to [onLog].
  Connection({required Object command, this.onLog}) : _command = command;

  final Object _command;

  /// Receives the daemon's and the transport's diagnostic output.
  final void Function(String text)? onLog;

  _Session? _session;
  Future<RemoteInfo>? _ready;
  int _sessions = 0;
  int _nextId = 1;
  bool _closed = false;

  /// Connect if needed and return what the daemon reported about its machine.
  Future<RemoteInfo> info([AbortSignal? signal]) async {
    final ready = await _untilAborted(_connect(), signal);
    return ready;
  }

  /// Connect if needed and return the live session's id.
  Future<int> session() async => (await _connectSession()).id;

  /// Send a request and await its reply. A [RequestOptions.signal] aborts the
  /// request; [RequestOptions.session] pins it to the session that opened a
  /// handle.
  Future<Reply> request(String op, Map<String, dynamic> json,
      [RequestOptions? options]) async {
    options ??= RequestOptions();
    if (options.session != null) {
      final current = _session;
      if (current == null || current.id != options.session || !current.live) {
        throw _lost('pi-env connection lost');
      }
      return _send(current, op, json, options);
    }
    final session =
        await _untilAbortedSession(_connectSession(), options.signal);
    return _send(session, op, json, options);
  }

  /// Stop the daemon; it kills everything it started.
  void close() {
    _closed = true;
    final session = _session;
    if (session != null) _teardown(session, _closedError());
  }

  /// Kill one running request without aborting it.
  void kill(int id, int session) {
    final current = _session;
    if (current != null && current.id == session && current.live) {
      _write(
          current, encodeFrame(CANCEL, id, <String, dynamic>{'mode': 'kill'}));
    }
  }

  Future<_Session> _connectSession() async {
    await _connect();
    return _session!;
  }

  Future<RemoteInfo> _connect() async {
    if (_closed) throw _closedError();
    if (_ready == null) {
      final ready = _start();
      _ready = ready;
      ready.catchError((Object error, StackTrace st) {
        if (identical(_ready, ready)) _ready = null;
        return RemoteInfo(<String, dynamic>{});
      });
    }
    return _ready!;
  }

  Future<Reply> _send(_Session session, String op, Map<String, dynamic> json,
      RequestOptions options) {
    if (!session.live) {
      return Future<Reply>.error(_lost('pi-env connection lost'));
    }
    final id = _nextId++;
    final completer = Completer<Reply>();
    Timer? grace;
    void onAbort() {
      _write(session, encodeFrame(CANCEL, id, <String, dynamic>{}));
      grace = Timer(const Duration(milliseconds: _abortGraceMs), () {
        final pending = session.pending[id];
        if (pending == null) return;
        session.pending.remove(id);
        if (!completer.isCompleted) {
          completer.completeError(RemoteError(<String, dynamic>{
            'code': 'aborted',
            'message': 'aborted',
          }));
        }
      });
    }

    final pending = _Pending(
      (value) {
        grace?.cancel();
        options.signal?._removeListener(onAbort);
        if (!completer.isCompleted) completer.complete(value);
      },
      (error) {
        grace?.cancel();
        options.signal?._removeListener(onAbort);
        if (!completer.isCompleted) completer.completeError(error);
      },
      options.onEvent,
    );
    session.pending[id] = pending;
    options.signal?._addListener(onAbort);
    options.onStart?.call(id, session.id);
    _write(
        session,
        encodeFrame(REQUEST, id, <String, dynamic>{...json, 'op': op},
            options.payload));
    if (options.signal?.aborted ?? false) onAbort();
    return completer.future;
  }

  void _write(_Session session, Uint8List data) {
    if (session.live) session.process.stdin.add(data);
  }

  Future<RemoteInfo> _start() async {
    List<String> command;
    try {
      final option = _command;
      if (option is List<String>) {
        command = option;
      } else if (option is DaemonCommand) {
        final resolved = await (option() as FutureOr<Object>);
        command = List<String>.from(resolved as List);
      } else if (option is List) {
        command = option.cast<String>();
      } else {
        throw RemoteError(<String, dynamic>{
          'code': 'spawn_error',
          'message': 'Invalid daemon command',
        });
      }
    } catch (error) {
      final message = error is RemoteError ? error.message : '$error';
      throw RemoteError(<String, dynamic>{
        'code': 'spawn_error',
        'message': message,
        'lost': true
      });
    }
    if (_closed) throw _closedError();
    if (command.isEmpty) {
      throw RemoteError(<String, dynamic>{
        'code': 'spawn_error',
        'message': 'No daemon command',
      });
    }
    final token = _randomToken();
    final io.Process process;
    try {
      process = await io.Process.start(command.first,
          <String>[...command.sublist(1), 'serve', '--token', token]);
    } catch (error) {
      throw RemoteError(<String, dynamic>{
        'code': 'spawn_error',
        'message': '$error',
        'lost': true,
      });
    }
    final session = _Session(++_sessions, process, token);
    _session = session;
    var ready = false;
    Timer? startTimer;
    final failed = Completer<Never>();
    startTimer = Timer(const Duration(milliseconds: _startTimeoutMs), () {
      if (!failed.isCompleted) {
        failed.completeError(
            _lost('pi-env did not answer within ${_startTimeoutMs ~/ 1000} s'));
      }
    });
    process.exitCode.then((code) {
      if (!failed.isCompleted && !ready) {
        failed.completeError(
            _lost('pi-env exited with code $code before it was ready'));
      }
    });
    failed.future.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    process.stdout
        .listen((chunk) => _onData(session, Uint8List.fromList(chunk)));
    process.stderr.transform(utf8.decoder).listen((text) => onLog?.call(text));
    process.exitCode.then((code) {
      if (ready) _teardown(session, _lost('pi-env connection lost'));
    });
    session.timer =
        Timer.periodic(const Duration(milliseconds: _pingIntervalMs), (_) {
      _write(session, encodeFrame(PING, 0, <String, dynamic>{}));
      if (DateTime.now().millisecondsSinceEpoch - session.lastSeen >
          _silenceLimitMs) {
        _teardown(session, _lost('pi-env connection timed out'));
      }
    });
    try {
      final reply = await _race<Reply>([
        _send(session, 'hello', <String, dynamic>{'protocol': 1},
            RequestOptions()),
        failed.future.then<Reply>((_) => throw _lost('start failed')),
      ]);
      if (reply.json['protocol'] != 1) {
        throw _lost('Unsupported protocol ${reply.json['protocol']}');
      }
      ready = true;
      return RemoteInfo(reply.json);
    } catch (error) {
      final failure = error is RemoteError ? error : _lost('$error');
      _teardown(session, failure);
      throw failure;
    } finally {
      startTimer.cancel();
    }
  }

  /// Completes with the first future in [futures] to complete, mirroring the
  /// `Promise.race` the upstream uses to time out the daemon start.
  static Future<T> _race<T>(List<Future<T>> futures) {
    final completer = Completer<T>();
    for (final future in futures) {
      future.then(
        (value) {
          if (!completer.isCompleted) completer.complete(value);
        },
        onError: (Object error, StackTrace st) {
          if (!completer.isCompleted) completer.completeError(error, st);
        },
      );
    }
    return completer.future;
  }

  void _teardown(_Session session, Object error) {
    if (!session.live) return;
    session.live = false;
    session.timer?.cancel();
    if (identical(_session, session)) {
      _session = null;
      _ready = null;
    }
    session.process.stdin.close();
    session.process.kill();
    final pending = session.pending.values.toList();
    session.pending.clear();
    for (final request in pending) {
      request.reject(error);
    }
  }

  void _onData(_Session session, Uint8List chunk) {
    if (!session.live) return;
    session.lastSeen = DateTime.now().millisecondsSinceEpoch;
    session.chunks.add(chunk);
    session.buffered += chunk.length;
    if (!session.synced) {
      final marker = Uint8List.fromList('PI-ENV ${session.token}\n'.codeUnits);
      final all = session.peek(session.buffered);
      final index = _indexOf(all, marker);
      if (index == -1) {
        if (session.buffered > 1024 * 1024) {
          session.consume(session.buffered - marker.length);
        }
        return;
      }
      session.consume(index + marker.length);
      session.synced = true;
    }
    while (session.live && session.buffered >= 4) {
      final header = session.peek(4);
      final length =
          ByteData.view(header.buffer, header.offsetInBytes).getUint32(0);
      if (length < 9 || length > maxFrame) {
        _teardown(session, _lost('Corrupt frame from pi-env'));
        return;
      }
      if (session.buffered < 4 + length) return;
      final body = session.peek(4 + length);
      final bodyView = ByteData.view(body.buffer, body.offsetInBytes);
      final type = body[4];
      final id = bodyView.getUint32(5);
      final jsonLength = bodyView.getUint32(9);
      Map<String, dynamic> json;
      try {
        if (13 + jsonLength > 4 + length) {
          throw const FormatException('out of range');
        }
        final parsed =
            jsonDecode(utf8.decode(body.sublist(13, 13 + jsonLength)));
        json = parsed is Map<String, dynamic>
            ? parsed
            : Map<String, dynamic>.from(parsed as Map);
      } catch (_) {
        _teardown(session, _lost('Corrupt frame from pi-env'));
        return;
      }
      final payload = Uint8List.fromList(body.sublist(13 + jsonLength));
      session.consume(4 + length);
      _dispatch(session, type, id, json, payload);
    }
  }

  void _dispatch(_Session session, int type, int id, Map<String, dynamic> json,
      Uint8List payload) {
    final pending = session.pending[id];
    if (type == EVENT) {
      pending?.onEvent?.call(json, payload);
      return;
    }
    if (type != RESULT && type != ERROR) return;
    if (pending == null) return;
    session.pending.remove(id);
    if (type == RESULT) {
      pending.resolve(Reply(json, payload, session.id));
    } else {
      pending.reject(RemoteError(json));
    }
  }

  static int _indexOf(Uint8List haystack, Uint8List needle) {
    if (needle.isEmpty) return 0;
    final last = haystack.length - needle.length;
    for (var i = 0; i <= last; i++) {
      var match = true;
      for (var j = 0; j < needle.length; j++) {
        if (haystack[i + j] != needle[j]) {
          match = false;
          break;
        }
      }
      if (match) return i;
    }
    return -1;
  }

  static String _randomToken() {
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      buffer.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}

RemoteError _lost(String message) => RemoteError(
    <String, dynamic>{'code': 'unknown', 'message': message, 'lost': true});

RemoteError _closedError() => RemoteError(
    <String, dynamic>{'code': 'unknown', 'message': 'Connection closed'});

Future<T> _untilAborted<T>(Future<T> promise, AbortSignal? signal) {
  if (signal == null) return promise;
  if (signal.aborted) {
    return Future<T>.error(RemoteError(
        <String, dynamic>{'code': 'aborted', 'message': 'aborted'}));
  }
  final completer = Completer<T>();
  void onAbort() {
    if (!completer.isCompleted) {
      completer.completeError(RemoteError(
          <String, dynamic>{'code': 'aborted', 'message': 'aborted'}));
    }
  }

  signal._addListener(onAbort);
  promise.then(completer.complete, onError: completer.completeError);
  return completer.future.whenComplete(() => signal._removeListener(onAbort));
}

Future<_Session> _untilAbortedSession(
    Future<_Session> promise, AbortSignal? signal) async {
  final session = await _untilAborted<_Session>(promise, signal);
  return session;
}
