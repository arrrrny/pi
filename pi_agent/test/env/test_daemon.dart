// A minimal pi-env daemon for the remote env tests.
//
// It speaks the version-1 wire protocol (packages/env/docs/protocol.md) over
// stdin/stdout so the Dart `Connection`, `openProcess` and `openTerminal` can
// be exercised without the Rust daemon binary. It implements only the
// operations the tests drive: `hello`, `process`, `pty`, the per-handle
// `processWrite`/`processCloseStdin`/`ptyWrite`/`ptyResize`/`ptyForeground`
// messages, `cancel` and `ping`.
//
// Run as: dart test/env/test_daemon.dart serve --token <hex>

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const int request = 1;
const int result = 2;
const int error = 3;
const int event = 4;
const int cancel = 5;
const int ping = 6;

const int maxFrame = 16 * 1024 * 1024;

/// One running program opened by a `process` or `pty` request.
class _Handle {
  _Handle(this.id, this.session);

  final int id;
  final int session;
  late final Process process;
  bool closed = false;
}

final Map<int, _Handle> _handles = <int, _Handle>{};
final IOSink _out = stdout;

void _writeFrame(int type, int id, Map<String, dynamic> json,
    [Uint8List? payload]) {
  final body = Uint8List.fromList(jsonEncode(json).codeUnits);
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
  _out.add(frame);
}

void _sendResult(int id, Map<String, dynamic> json) =>
    _writeFrame(result, id, json);

void _sendError(int id, Map<String, dynamic> json) =>
    _writeFrame(error, id, json);

void _sendEvent(int id, Map<String, dynamic> json, [Uint8List? payload]) =>
    _writeFrame(event, id, json, payload);

Future<void> _startProgram(
    _Handle handle, Map<String, dynamic> req, bool pty) async {
  final argv = (req['argv'] as List<dynamic>? ?? <dynamic>['/bin/sh'])
      .map((e) => e as String)
      .toList();
  final cwd = req['cwd'] as String?;
  // The real daemon allocates a pseudo-terminal; a plain pipe carries the same
  // raw bytes for the test's purposes. cols/rows are accepted but unused here.
  final process = await Process.start(
    argv.first,
    argv.sublist(1),
    workingDirectory: cwd,
    mode: ProcessStartMode.normal,
  );
  handle.process = process;
  _handles[handle.id] = handle;

  process.stdout.listen((data) {
    _sendEvent(handle.id, <String, dynamic>{'kind': 'output'},
        Uint8List.fromList(data));
  });
  process.stderr.listen((data) {
    if (pty) {
      _sendEvent(handle.id, <String, dynamic>{'kind': 'output'},
          Uint8List.fromList(data));
    } else {
      _sendEvent(
          handle.id,
          <String, dynamic>{'kind': 'output', 'stream': 'stderr'},
          Uint8List.fromList(data));
    }
  });

  _sendEvent(
      handle.id, <String, dynamic>{'kind': 'started', 'pid': process.pid});

  final exitCode = await process.exitCode;
  // Collect a beat, then finish — mirrors the daemon's drain window.
  await Future<void>.delayed(const Duration(milliseconds: 50));
  if (!_handles.containsKey(handle.id)) return;
  _handles.remove(handle.id);
  _sendResult(handle.id, <String, dynamic>{'exitCode': exitCode});
}

Future<void> _dispatch(
    int type, int id, Map<String, dynamic> json, Uint8List payload) async {
  switch (type) {
    case ping:
      return;
    case request:
      break;
    default:
      return;
  }

  final op = json['op'] as String?;
  switch (op) {
    case 'hello':
      _sendResult(id, <String, dynamic>{
        'protocol': 1,
        'version': 'test',
        'os': 'linux',
        'arch': 'x86_64',
        'home': '/root',
        'tmpdir': '/tmp',
        'separator': '/',
        'cwd': '/',
        'driveCwds': <String, dynamic>{},
        'pid': pid,
        'features': <String>['listFiles', 'process'],
      });
      return;
    case 'process':
      final handle = _Handle(id, json['session'] as int? ?? 0);
      await _startProgram(handle, json, false);
      return;
    case 'pty':
      final handle = _Handle(id, json['session'] as int? ?? 0);
      await _startProgram(handle, json, true);
      return;
    case 'processWrite':
      final target = json['target'] as int;
      final handle = _handles[target];
      if (handle != null && !handle.closed) {
        handle.process.stdin.add(payload);
      }
      _sendResult(id, <String, dynamic>{});
      return;
    case 'processCloseStdin':
      final target = json['target'] as int;
      final handle = _handles[target];
      if (handle != null && !handle.closed) {
        handle.closed = true;
        handle.process.stdin.close();
      }
      _sendResult(id, <String, dynamic>{});
      return;
    case 'ptyWrite':
      final target = json['target'] as int;
      final handle = _handles[target];
      if (handle != null && !handle.closed) {
        handle.process.stdin.add(payload);
      }
      _sendResult(id, <String, dynamic>{});
      return;
    case 'ptyResize':
      _sendResult(id, <String, dynamic>{});
      return;
    case 'ptyForeground':
      final target = json['target'] as int;
      if (!_handles.containsKey(target)) {
        _sendError(id, <String, dynamic>{'code': 'EBADF', 'message': 'ended'});
        return;
      }
      _sendResult(id, <String, dynamic>{'foreground': null});
      return;
    case 'cancel':
      for (final handle in _handles.values.toList()) {
        if (handle.id == id) {
          handle.closed = true;
          handle.process.kill();
        }
      }
      return;
    default:
      _sendError(id, <String, dynamic>{
        'code': 'unknown',
        'message': 'unsupported op $op',
      });
  }
}

Future<void> main(List<String> args) async {
  final token = args.length >= 3 && args[1] == '--token' ? args[2] : 'test';
  // The sync line the client discards everything before.
  _out.writeln('PI-ENV $token');
  await _out.flush();

  final buffer = <int>[];
  var reading = true;
  stdin.listen((chunk) {
    buffer.addAll(chunk);
    while (reading && buffer.length >= 4) {
      final bytes = Uint8List.fromList(buffer);
      final view = ByteData.view(bytes.buffer, bytes.offsetInBytes);
      final length = view.getUint32(0);
      if (length < 9 || length > maxFrame) {
        reading = false;
        exit(1);
      }
      if (buffer.length < 4 + length) return;
      final frameBytes = Uint8List.fromList(buffer.sublist(0, 4 + length));
      buffer.removeRange(0, 4 + length);
      final fview = ByteData.view(frameBytes.buffer);
      final type = fview.getUint8(4);
      final id = fview.getUint32(5);
      final jsonLength = fview.getUint32(9);
      final jsonBytes = frameBytes.sublist(13, 13 + jsonLength);
      final payload = frameBytes.sublist(13 + jsonLength);
      Map<String, dynamic> json;
      try {
        final decoded = jsonDecode(utf8.decode(jsonBytes));
        json = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map);
      } catch (_) {
        _sendError(
            id, <String, dynamic>{'code': 'EINVAL', 'message': 'bad json'});
        continue;
      }
      unawaited(_dispatch(type, id, json, Uint8List.fromList(payload)));
    }
  }, onDone: () {
    reading = false;
    exit(0);
  });

  await Future<void>.delayed(const Duration(days: 1));
}
