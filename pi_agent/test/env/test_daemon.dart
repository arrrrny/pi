// A minimal pi-env daemon for the remote env tests.
//
// Run as: dart test/env/test_daemon.dart serve --token <hex>

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:pi/src/durable/env/line_scan.dart';

const int request = 1;
const int result = 2;
const int error = 3;
const int event = 4;
const int cancel = 5;
const int ping = 6;
const int maxFrame = 16 * 1024 * 1024;

class _Handle {
  _Handle(this.id, this.session);

  final int id;
  final int session;
  late final Process process;
  bool closed = false;
}

class _FileHandle {
  _FileHandle(this.id, this.session, this.path, this.file, this.info);

  final int id;
  final int session;
  final String path;
  final RandomAccessFile file;
  final Map<String, dynamic> info;
}

class _DirHandle {
  _DirHandle(this.id, this.session, this.path, this.entries);

  final int id;
  final int session;
  final String path;
  final List<FileSystemEntity> entries;
  int offset = 0;
}

class _Watcher {
  _Watcher(this.id, this.targets);

  final int id;
  final List<Map<String, dynamic>> targets;
  bool cancelled = false;
}

final Map<int, _Handle> _handles = <int, _Handle>{};
final Map<int, _FileHandle> _files = <int, _FileHandle>{};
final Map<int, _DirHandle> _dirs = <int, _DirHandle>{};
final Map<int, RandomAccessFile> _writeHandles = <int, RandomAccessFile>{};
final Map<int, _Watcher> _watchers = <int, _Watcher>{};
final Set<int> _cancelled = <int>{};
final IOSink _out = stdout;
int _nextHandle = 1;
bool _oldDaemon = false;
bool _slowOpen = false;

void _writeFrame(int type, int id, Map<String, dynamic> json,
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
  _out.add(frame);
}

void _sendResult(int id, Map<String, dynamic> json, [Uint8List? payload]) =>
    _writeFrame(result, id, json, payload);

void _sendError(int id, Map<String, dynamic> json) =>
    _writeFrame(error, id, json);

void _sendEvent(int id, Map<String, dynamic> json, [Uint8List? payload]) =>
    _writeFrame(event, id, json, payload);

Map<String, dynamic> _info(String path) {
  final type = FileSystemEntity.typeSync(path, followLinks: false);
  if (type == FileSystemEntityType.notFound) {
    throw const FileSystemException('not found', '', OSError('', 2));
  }
  final stat = File(path).statSync();
  final milliseconds = stat.modified.millisecondsSinceEpoch;
  return <String, dynamic>{
    'name': p.basename(path),
    'kind': switch (type) {
      FileSystemEntityType.file => 'file',
      FileSystemEntityType.directory => 'directory',
      FileSystemEntityType.link => 'symlink',
      _ => 'other',
    },
    'size': stat.size,
    'mtimeSec': milliseconds ~/ 1000,
    'mtimeNsec': (milliseconds % 1000) * 1000000,
    'dev': 0,
    'ino': 0,
  };
}

String _errorCode(FileSystemException error) {
  final code = error.osError?.errorCode;
  return switch (code) {
    2 => 'ENOENT',
    13 => 'EACCES',
    17 => 'EEXIST',
    20 => 'ENOTDIR',
    21 => 'EISDIR',
    22 => 'EINVAL',
    28 => 'ENOSPC',
    _ => 'EIO',
  };
}

void _sendFileError(int id, Object error, [String? path]) {
  if (error is FileSystemException) {
    _sendError(id, <String, dynamic>{
      'code': _errorCode(error),
      'message': error.message,
      if (path != null) 'path': path,
    });
    return;
  }
  _sendError(id, <String, dynamic>{'code': 'EIO', 'message': '$error'});
}

Future<void> _guard(int id, Future<void> Function() run) async {
  try {
    await run();
  } catch (error) {
    _sendFileError(id, error);
  }
}

Future<void> _startProgram(
    _Handle handle, Map<String, dynamic> req, bool pty) async {
  final argv = (req['argv'] as List<dynamic>? ?? <dynamic>['/bin/sh'])
      .map((entry) => entry as String)
      .toList();
  final process = await Process.start(
    argv.first,
    argv.sublist(1),
    workingDirectory: req['cwd'] as String?,
    environment: (req['env'] as Map?)?.cast<String, String>(),
    includeParentEnvironment: req['inheritEnv'] != false,
    mode: ProcessStartMode.normal,
  );
  handle.process = process;
  _handles[handle.id] = handle;
  process.stdout.listen((data) {
    _sendEvent(handle.id, <String, dynamic>{'kind': 'output'},
        Uint8List.fromList(data));
  });
  process.stderr.listen((data) {
    _sendEvent(
      handle.id,
      <String, dynamic>{
        'kind': 'output',
        if (!pty) 'stream': 'stderr',
      },
      Uint8List.fromList(data),
    );
  });
  _sendEvent(
      handle.id, <String, dynamic>{'kind': 'started', 'pid': process.pid});
  final exitCode = await process.exitCode;
  await Future<void>.delayed(const Duration(milliseconds: 50));
  if (!_handles.containsKey(handle.id)) return;
  _handles.remove(handle.id);
  _sendResult(handle.id, <String, dynamic>{'exitCode': exitCode});
}

Future<void> _exec(int id, Map<String, dynamic> req) async {
  final command = req['command'] as String?;
  final argv = command != null
      ? <String>['/bin/sh', '-c', command]
      : (req['argv'] as List).cast<String>();
  final process = await Process.start(
    argv.first,
    argv.sublist(1),
    workingDirectory: req['cwd'] as String?,
    environment: (req['env'] as Map?)?.cast<String, String>(),
    includeParentEnvironment: req['inheritEnv'] != false,
    mode: ProcessStartMode.normal,
  );
  final handle = _Handle(id, 0);
  _handles[id] = handle;
  var timedOut = false;
  final timeoutMs = req['timeoutMs'] as num?;
  final timer = timeoutMs == null
      ? null
      : Timer(Duration(microseconds: (timeoutMs * 1000).round()), () {
          timedOut = true;
          if (!handle.closed) process.kill(ProcessSignal.sigkill);
        });
  process.stdout.listen((data) {
    _sendEvent(id, <String, dynamic>{'kind': 'output', 'stream': 'stdout'},
        Uint8List.fromList(data));
  });
  process.stderr.listen((data) {
    _sendEvent(id, <String, dynamic>{'kind': 'output', 'stream': 'stderr'},
        Uint8List.fromList(data));
  });
  final exitCode = await process.exitCode;
  timer?.cancel();
  await Future<void>.delayed(const Duration(milliseconds: 50));
  _handles.remove(id);
  if (timedOut) {
    _sendError(id, <String, dynamic>{'code': 'timeout', 'message': 'timeout'});
  } else if (handle.closed) {
    _sendError(id, <String, dynamic>{'code': 'aborted', 'message': 'aborted'});
  } else {
    _sendResult(id, <String, dynamic>{'exitCode': exitCode});
  }
}

Map<String, String> _snapshot(List<Map<String, dynamic>> targets) {
  final snapshot = <String, String>{};
  void visit(String path, bool recursive, Map<String, dynamic>? exclude) {
    final entity = FileSystemEntity.typeSync(path, followLinks: false);
    if (entity == FileSystemEntityType.notFound) return;
    if (entity == FileSystemEntityType.file) {
      final stat = FileStat.statSync(path);
      snapshot[path] = '${stat.size}:${stat.modified.millisecondsSinceEpoch}';
      return;
    }
    if (entity != FileSystemEntityType.directory) return;
    final entries = Directory(path).listSync(followLinks: false);
    for (final entry in entries) {
      final name = p.basename(entry.path);
      if (name == '.git') continue;
      if (exclude?['hidden'] == true && name.startsWith('.')) continue;
      final names =
          (exclude?['names'] as List?)?.cast<String>() ?? const <String>[];
      if (names.contains(name)) continue;
      final type = FileSystemEntity.typeSync(entry.path, followLinks: false);
      if (type == FileSystemEntityType.file) {
        final stat = FileStat.statSync(entry.path);
        snapshot[entry.path] =
            '${stat.size}:${stat.modified.millisecondsSinceEpoch}';
      } else if (recursive && type == FileSystemEntityType.directory) {
        snapshot[entry.path] = 'directory';
        visit(entry.path, true, exclude);
      }
    }
  }

  for (final target in targets) {
    visit(
        target['path'] as String,
        target['recursive'] == true,
        target['exclude'] is Map
            ? Map<String, dynamic>.from(target['exclude'] as Map)
            : null);
  }
  return snapshot;
}

Future<void> _watch(int id, Map<String, dynamic> req) async {
  final targets = (req['targets'] as List)
      .map((target) => Map<String, dynamic>.from(target as Map))
      .toList();
  final watcher = _Watcher(id, targets);
  _watchers[id] = watcher;
  var previous = _snapshot(targets);
  _sendEvent(id, <String, dynamic>{'kind': 'ready', 'mode': 'native'});
  final interval = (req['pollIntervalMs'] as num?)?.toInt() ?? 100;
  while (!watcher.cancelled) {
    await Future<void>.delayed(Duration(milliseconds: interval));
    if (watcher.cancelled) break;
    final current = _snapshot(targets);
    final paths = <String>{
      for (final entry in current.entries)
        if (previous[entry.key] != entry.value) entry.key,
      for (final entry in previous.entries)
        if (current[entry.key] != entry.value) entry.key,
    }.toList();
    if (paths.isNotEmpty) {
      _sendEvent(id, <String, dynamic>{'kind': 'change', 'paths': paths});
    }
    previous = current;
  }
  _watchers.remove(id);
  _sendResult(id, <String, dynamic>{});
}

Future<void> _listFiles(int id, Map<String, dynamic> req) async {
  final root = req['path'] as String;
  final hidden = req['hidden'] != false;
  final exclude =
      ((req['exclude'] as List?)?.cast<String>() ?? const <String>[]).toSet();
  final maxEntries = (req['maxEntries'] as num?)?.toInt() ?? 50000;
  final maxBytes = (req['maxBytes'] as num?)?.toInt() ?? 4 * 1024 * 1024;
  final timeoutMs = (req['timeoutMs'] as num?)?.toInt() ?? 10000;
  final deadline = DateTime.now().add(Duration(milliseconds: timeoutMs));
  final payload = BytesBuilder(copy: false);
  var count = 0;
  var truncated = false;
  void add(String path, int kind) {
    final record = <int>[kind, ...utf8.encode(p.relative(path, from: root)), 0];
    if (count >= maxEntries || payload.length + record.length > maxBytes) {
      truncated = true;
      return;
    }
    payload.add(record);
    count++;
  }

  void visit(String path) {
    if (truncated ||
        _cancelled.contains(id) ||
        DateTime.now().isAfter(deadline)) {
      truncated = truncated ||
          _cancelled.contains(id) ||
          DateTime.now().isAfter(deadline);
      return;
    }
    final type = FileSystemEntity.typeSync(path, followLinks: false);
    if (type == FileSystemEntityType.file) {
      add(path, 102);
    } else if (type == FileSystemEntityType.directory) {
      if (path != root) add(path, 100);
      final entries = Directory(path).listSync(followLinks: false);
      entries.sort((a, b) => utf8
          .encode(p.basename(a.path))
          .join()
          .compareTo(utf8.encode(p.basename(b.path)).join()));
      for (final entry in entries) {
        if (truncated || _cancelled.contains(id)) return;
        final name = p.basename(entry.path);
        if (name == '.git' ||
            exclude.contains(name) ||
            (!hidden && name.startsWith('.'))) {
          continue;
        }
        visit(entry.path);
      }
    } else if (type == FileSystemEntityType.link) {
      add(path, 108);
    }
  }

  final rootType = FileSystemEntity.typeSync(root, followLinks: false);
  if (rootType == FileSystemEntityType.notFound) {
    _sendError(id, <String, dynamic>{
      'code': 'ENOENT',
      'message': 'not found',
      'path': root
    });
    return;
  }
  if (rootType != FileSystemEntityType.directory) {
    _sendError(id, <String, dynamic>{
      'code': 'ENOTDIR',
      'message': 'not a directory',
      'path': root
    });
    return;
  }
  visit(root);
  final wasCancelled = _cancelled.remove(id);
  if (wasCancelled) {
    _sendError(id, <String, dynamic>{'code': 'aborted', 'message': 'aborted'});
    return;
  }
  _sendResult(id, <String, dynamic>{'count': count, 'truncated': truncated},
      payload.takeBytes());
}

Future<void> _dispatch(
    int type, int id, Map<String, dynamic> json, Uint8List payload) async {
  if (type == ping) return;
  if (type != request) return;
  final op = json['op'] as String?;
  switch (op) {
    case 'hello':
      _sendResult(id, <String, dynamic>{
        'protocol': 1,
        'version': 'test',
        'os': Platform.isLinux
            ? 'linux'
            : Platform.isMacOS
                ? 'macos'
                : 'windows',
        'arch': Platform.version.contains('arm64') ? 'aarch64' : 'x86_64',
        'home': Platform.environment['HOME'] ?? '/',
        'tmpdir': Directory.systemTemp.path,
        'separator': Platform.pathSeparator,
        'cwd': Directory.current.path,
        'driveCwds': <String, dynamic>{},
        'pid': pid,
        'features': _oldDaemon ? <String>[] : <String>['listFiles', 'process'],
      });
    case 'lstat':
      await _guard(id, () async {
        _sendResult(id, _info(json['path'] as String));
      });
    case 'realpath':
      await _guard(id, () async {
        final path = File(json['path'] as String).resolveSymbolicLinksSync();
        _sendResult(id, <String, dynamic>{'path': path});
      });
    case 'write':
      await _guard(id, () async {
        final path = json['path'] as String;
        if (json['parents'] != false) {
          Directory(p.dirname(path)).createSync(recursive: true);
        }
        final file = File(path).openSync(
            mode: json['append'] == true ? FileMode.append : FileMode.write);
        file.writeFromSync(payload);
        file.flushSync();
        if (json['keep'] == true) {
          final handle = _nextHandle++;
          _writeHandles[handle] = file;
          _sendResult(id, <String, dynamic>{'handle': handle});
        } else {
          file.closeSync();
          _sendResult(id, <String, dynamic>{});
        }
      });
    case 'writeChunk':
      await _guard(id, () async {
        final file = _writeHandles[json['handle'] as int];
        if (file == null) {
          throw const FileSystemException('bad handle', '', OSError('', 9));
        }
        file.writeFromSync(payload);
        file.flushSync();
        _sendResult(id, <String, dynamic>{});
      });
    case 'truncate':
      await _guard(id, () async {
        final file =
            File(json['path'] as String).openSync(mode: FileMode.append);
        file.truncateSync(json['size'] as int);
        file.closeSync();
        _sendResult(id, <String, dynamic>{});
      });
    case 'fsync':
      await _guard(id, () async {
        final file =
            File(json['path'] as String).openSync(mode: FileMode.append);
        file.flushSync();
        file.closeSync();
        _sendResult(id, <String, dynamic>{});
      });
    case 'rename':
      await _guard(id, () async {
        File(json['path'] as String).renameSync(json['to'] as String);
        _sendResult(id, <String, dynamic>{});
      });
    case 'mkdir':
      await _guard(id, () async {
        Directory(json['path'] as String)
            .createSync(recursive: json['recursive'] == true);
        _sendResult(id, <String, dynamic>{});
      });
    case 'rm':
      await _guard(id, () async {
        final path = json['path'] as String;
        final type = FileSystemEntity.typeSync(path, followLinks: false);
        if (type == FileSystemEntityType.notFound && json['force'] == true) {
          _sendResult(id, <String, dynamic>{});
          return;
        }
        if (type == FileSystemEntityType.directory) {
          Directory(path).deleteSync(recursive: json['recursive'] == true);
        } else if (type == FileSystemEntityType.link) {
          Link(path).deleteSync();
        } else {
          File(path).deleteSync();
        }
        _sendResult(id, <String, dynamic>{});
      });
    case 'mkdtemp':
      await _guard(id, () async {
        final prefix = json['path'] as String;
        final random = Random.secure();
        late final Directory dir;
        while (true) {
          final suffix = List<int>.generate(6, (_) => random.nextInt(36))
              .map((value) => value.toRadixString(36))
              .join();
          final candidate = Directory('$prefix$suffix');
          if (!candidate.existsSync()) {
            candidate.createSync();
            dir = candidate;
            break;
          }
        }
        _sendResult(id, <String, dynamic>{'path': dir.path});
      });
    case 'open':
      await _guard(id, () async {
        if (_slowOpen) {
          await Future<void>.delayed(const Duration(milliseconds: 200));
        }
        final path = json['path'] as String;
        if (json['noFollow'] == true && Link(path).existsSync()) {
          _sendError(id,
              <String, dynamic>{'code': 'SYMLINK', 'message': 'symbolic link'});
          return;
        }
        final info = _info(path);
        if (json['mode'] != 'read' && info['kind'] != 'file') {
          _sendError(id, <String, dynamic>{
            'code': info['kind'] == 'directory' ? 'EISDIR' : 'NOT_REGULAR',
            'message': 'not a regular file',
          });
          return;
        }
        final file = File(path).openSync(mode: FileMode.read);
        final handle = _nextHandle++;
        _files[handle] = _FileHandle(handle, 0, path, file, info);
        _sendResult(id, <String, dynamic>{
          'handle': handle,
          if (json['mode'] == 'read') 'stat': info else 'info': info,
        });
      });
    case 'pread':
      await _guard(id, () async {
        final handle = _files[json['handle'] as int];
        if (handle == null) {
          throw const FileSystemException('bad handle', '', OSError('', 9));
        }
        final offset = json['offset'] as int?;
        if (offset != null) handle.file.setPositionSync(offset);
        final bytes = handle.file.readSync(json['length'] as int);
        _sendResult(id, <String, dynamic>{}, Uint8List.fromList(bytes));
      });
    case 'fstat':
      await _guard(id, () async {
        final handle = _files[json['handle'] as int];
        if (handle == null) {
          throw const FileSystemException('bad handle', '', OSError('', 9));
        }
        _sendResult(id, handle.info);
      });
    case 'scanLines':
      await _guard(id, () async {
        final handle = _files[json['handle'] as int];
        if (handle == null) {
          throw const FileSystemException('bad handle', '', OSError('', 9));
        }
        final position = handle.file.positionSync();
        handle.file.setPositionSync(0);
        final bytes = handle.file.readSync(handle.file.lengthSync());
        handle.file.setPositionSync(position);
        final startLine = json['startLine'] as int;
        final endLine = json['endLine'] as int?;
        final scanner = endLine == null
            ? LineScanner(startLine)
            : LineScanner(startLine, endLine);
        scanner.push(bytes);
        final scan = scanner.finish();
        _sendResult(id, <String, dynamic>{
          'newlines': scan.newlines,
          'start': scan.start,
          'end': scan.end,
          'firstLineEnd': scan.firstLineEnd,
          'lastLineStart': scan.lastLineStart,
          'selectedBytes': scan.selectedBytes,
          'firstLineBytes': scan.firstLineBytes,
        });
      });
    case 'opendir':
      await _guard(id, () async {
        final path = json['path'] as String;
        final entries = Directory(path).listSync(followLinks: false);
        final handle = _nextHandle++;
        _dirs[handle] = _DirHandle(handle, 0, path, entries);
        _sendResult(id, <String, dynamic>{'handle': handle});
      });
    case 'readdir':
      await _guard(id, () async {
        final handle = _dirs[json['handle'] as int];
        if (handle == null) {
          throw const FileSystemException('bad handle', '', OSError('', 9));
        }
        final max = json['max'] as int;
        final end = min(handle.offset + max, handle.entries.length);
        final entries = <Map<String, dynamic>>[];
        for (final entity in handle.entries.sublist(handle.offset, end)) {
          try {
            entries.add(<String, dynamic>{
              'name': p.basename(entity.path),
              'info': _info(entity.path),
            });
          } catch (error) {
            entries.add(<String, dynamic>{
              'name': p.basename(entity.path),
              'error': <String, dynamic>{'code': 'ENOENT', 'message': '$error'},
            });
          }
        }
        handle.offset = end;
        _sendResult(id, <String, dynamic>{
          'entries': entries,
          'done': end == handle.entries.length
        });
      });
    case 'close':
      await _guard(id, () async {
        final handle = json['handle'] as int;
        final file = _files.remove(handle);
        file?.file.closeSync();
        _dirs.remove(handle);
        final write = _writeHandles.remove(handle);
        write?.closeSync();
        _sendResult(id, <String, dynamic>{});
      });
    case 'listFiles':
      await _listFiles(id, json);
    case 'exec':
      await _exec(id, json);
    case 'watch':
      await _watch(id, json);
    case 'process':
      final handle = _Handle(id, json['session'] as int? ?? 0);
      await _startProgram(handle, json, false);
    case 'pty':
      final handle = _Handle(id, json['session'] as int? ?? 0);
      await _startProgram(handle, json, true);
    case 'processWrite':
      final handle = _handles[json['target'] as int];
      if (handle != null && !handle.closed) handle.process.stdin.add(payload);
      _sendResult(id, <String, dynamic>{});
    case 'processCloseStdin':
      final handle = _handles[json['target'] as int];
      if (handle != null && !handle.closed) {
        handle.closed = true;
        await handle.process.stdin.close();
      }
      _sendResult(id, <String, dynamic>{});
    case 'ptyWrite':
      final handle = _handles[json['target'] as int];
      if (handle != null && !handle.closed) handle.process.stdin.add(payload);
      _sendResult(id, <String, dynamic>{});
    case 'ptyResize':
      _sendResult(id, <String, dynamic>{});
    case 'ptyForeground':
      if (!_handles.containsKey(json['target'] as int)) {
        _sendError(id, <String, dynamic>{'code': 'EBADF', 'message': 'ended'});
      } else {
        _sendResult(id, <String, dynamic>{'foreground': null});
      }
    default:
      _sendError(id, <String, dynamic>{
        'code': 'unknown',
        'message': 'unsupported op $op'
      });
  }
}

void _cancel(int id, Map<String, dynamic> json) {
  final watcher = _watchers[id];
  if (watcher != null) {
    watcher.cancelled = true;
    return;
  }
  _cancelled.add(id);
  final handle = _handles[id];
  if (handle == null) return;
  handle.closed = true;
  handle.process.kill(ProcessSignal.sigkill);
  if (json['mode'] != 'kill') {
    _handles.remove(id);
    _sendError(id, <String, dynamic>{'code': 'aborted', 'message': 'aborted'});
  }
}

Future<void> main(List<String> args) async {
  _oldDaemon = args.contains('--old');
  _slowOpen = args.contains('--slow-open');
  final tokenIndex = args.indexOf('--token');
  final token = tokenIndex >= 0 && tokenIndex + 1 < args.length
      ? args[tokenIndex + 1]
      : 'test';
  _out.writeln('PI-ENV $token');
  await _out.flush();
  final buffer = <int>[];
  var reading = true;
  stdin.listen((chunk) {
    buffer.addAll(chunk);
    while (reading && buffer.length >= 4) {
      final bytes = Uint8List.fromList(buffer);
      final length = ByteData.view(bytes.buffer).getUint32(0);
      if (length < 9 || length > maxFrame) {
        reading = false;
        exit(1);
      }
      if (buffer.length < 4 + length) return;
      final frame = Uint8List.fromList(buffer.sublist(0, 4 + length));
      buffer.removeRange(0, 4 + length);
      final view = ByteData.view(frame.buffer);
      final type = frame[4];
      final id = view.getUint32(5);
      final jsonLength = view.getUint32(9);
      final decoded =
          jsonDecode(utf8.decode(frame.sublist(13, 13 + jsonLength)));
      final json = Map<String, dynamic>.from(decoded as Map);
      if (type == cancel) {
        _cancel(id, json);
      } else {
        unawaited(_dispatch(
            type, id, json, Uint8List.sublistView(frame, 13 + jsonLength)));
      }
    }
  }, onDone: () {
    reading = false;
    exit(0);
  });
  await Future<void>.delayed(const Duration(days: 1));
}
