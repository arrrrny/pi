import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../chord/context.dart';
import '../durable/env/index.dart';
import 'connection.dart' hide AbortSignal;
import 'errors.dart';
import 'list_files.dart';
import 'signal.dart';
import 'watch.dart';

const _maxTimeoutMs = 2147483647;
const _readChunk = 256 * 1024;
const _readDepth = 8;
const _writeChunk = 512 * 1024;
const _writeDepth = 8;
const _readFileChunk = 512 * 1024;
const _readFileUnknownChunk = 64 * 1024;
const _readFileMax = 2147483647;
const _lineChunk = 64 * 1024;
const _maxSafeInteger = 9007199254740991;

extension _ResultValue<T, E> on Result<T, E> {
  T get value => switch (this) {
        Ok<T, E>(:final value) => value,
        Err<T, E>(:final error) => throw error as Object,
      };

  E get error => switch (this) {
        Ok<T, E>() => throw StateError('expected an error result'),
        Err<T, E>(:final error) => error,
      };
}

/// Construction options for [RemoteExecutionEnv].
class RemoteExecutionEnvOptions {
  /// Creates options for a remote filesystem and shell.
  const RemoteExecutionEnvOptions({
    required this.connection,
    required this.id,
    required this.cwd,
    this.shellPath,
    this.shellEnv,
    this.watch,
  });

  /// The daemon connection owned by the caller.
  final Connection connection;

  /// The stable filesystem namespace identifier.
  final String id;

  /// The remote working directory.
  final String cwd;

  /// Optional shell used for string commands.
  final String? shellPath;

  /// Variables added to commands that inherit the daemon environment.
  final Map<String, String>? shellEnv;

  /// Default daemon watcher options.
  final RemoteWatchOptions? watch;
}

class _RemoteFileInfo {
  const _RemoteFileInfo({
    required this.name,
    required this.kind,
    required this.size,
    required this.mtimeSec,
    required this.mtimeNsec,
  });

  factory _RemoteFileInfo.fromJson(Map<String, dynamic> json) =>
      _RemoteFileInfo(
        name: json['name'] as String? ?? '',
        kind: switch (json['kind']) {
          'file' => FileKind.file,
          'directory' => FileKind.directory,
          'symlink' => FileKind.symlink,
          _ => null,
        },
        size: _integer(json['size']),
        mtimeSec: _integer(json['mtimeSec']),
        mtimeNsec: _integer(json['mtimeNsec']),
      );

  final String name;
  final FileKind? kind;
  final int size;
  final int mtimeSec;
  final int mtimeNsec;
}

class _RemoteDirEntry {
  const _RemoteDirEntry({
    required this.name,
    this.raw,
    this.info,
    this.error,
  });

  factory _RemoteDirEntry.fromJson(Map<String, dynamic> json) =>
      _RemoteDirEntry(
        name: json['name'] as String? ?? '',
        raw: json['raw'] is List ? (json['raw'] as List).cast<int>() : null,
        info: json['info'] is Map
            ? _RemoteFileInfo.fromJson(
                Map<String, dynamic>.from(json['info'] as Map),
              )
            : null,
        error: json['error'] is Map
            ? Map<String, dynamic>.from(json['error'] as Map)
            : null,
      );

  final String name;
  final List<int>? raw;
  final _RemoteFileInfo? info;
  final Map<String, dynamic>? error;
}

class _ReadRange {
  const _ReadRange(this.chunks, this.total);

  final List<Uint8List> chunks;
  final int total;
}

enum _AbortCheck {
  before,
  both,
}

/// Returns the remote operating system's path rules.
Future<p.Context> remotePath(Connection connection,
    [AbortSignal? signal]) async {
  final info = await infoWithSignal(connection, signal);
  return nodePlatform(info.os, info.arch)['platform'] == 'win32'
      ? p.windows
      : p.posix;
}

Result<FileInfo, FileError> _toInfo(
  String path,
  _RemoteFileInfo remote,
  p.Context paths,
) {
  final kind = remote.kind;
  if (kind == null) {
    return Err(FileError(
      FileErrorCode.invalid,
      'Unsupported file type',
      path: path,
    ));
  }
  return Ok(FileInfo(
    name: paths.basename(path),
    path: path,
    kind: kind,
    size: remote.size,
    mtimeMs: remote.mtimeSec * 1000 + remote.mtimeNsec / 1e6,
  ));
}

Uint8List _concat(List<Uint8List> chunks, int total) {
  if (chunks.length == 1) return chunks.first;
  final bytes = Uint8List(total);
  var offset = 0;
  for (final chunk in chunks) {
    bytes.setRange(offset, offset + chunk.length, chunk);
    offset += chunk.length;
  }
  return bytes;
}

Future<_ReadRange?> _readRange(
  Future<Uint8List> Function(int offset, int length) read,
  int offset,
  int length,
  int chunk,
  bool Function() aborted,
) async {
  final chunks = <Uint8List>[];
  final inFlight = <(int, Future<Uint8List>)>[];
  var total = 0;
  var next = offset;
  while (total < length) {
    while (inFlight.length < _readDepth && next < offset + length) {
      final size = min(offset + length - next, chunk);
      final bytes = read(next, size);
      unawaited(bytes.catchError((_) => Uint8List(0)));
      inFlight.add((size, bytes));
      next += size;
    }
    final (size, bytes) = inFlight.removeAt(0);
    final data = await bytes;
    if (aborted()) return null;
    if (data.isEmpty) break;
    chunks.add(data);
    total += data.length;
    if (data.length < size) {
      inFlight.clear();
      next = offset + total;
    }
  }
  return _ReadRange(chunks, total);
}

class _Handle {
  _Handle(this.env, this.id, this.session, this.path);

  final RemoteExecutionEnv env;
  final int id;
  final int session;
  final String path;

  Future<Reply> request(
    String op, [
    Map<String, dynamic> json = const <String, dynamic>{},
    RequestOptions? options,
  ]) {
    return requestWithSignal(
      env.connection,
      op,
      <String, dynamic>{...json, 'handle': id},
      payload: options?.payload,
      signal: null,
      session: session,
    );
  }

  Future<Uint8List> pread(int? offset, int length) async {
    final reply = await request('pread', <String, dynamic>{
      if (offset != null) 'offset': offset,
      'length': length,
    });
    return reply.payload;
  }

  Future<void> close() async {
    try {
      await request('close');
    } catch (_) {
      // Handles are already invalid after a lost daemon session.
    }
  }
}

class _RemoteBinaryReader implements BinaryReader {
  _RemoteBinaryReader(this._handle);

  final _Handle _handle;
  bool _closed = false;

  Result<T, FileError>? _closedResult<T>() => _closed
      ? Err(FileError(
          FileErrorCode.invalid,
          'Binary reader is closed',
          path: _handle.path,
        ))
      : null;

  @override
  Future<Result<FileInfo, FileError>> info(Context context) async {
    final early = abortResult<FileInfo>(context.signal, _handle.path) ??
        _closedResult<FileInfo>();
    if (early != null) return early;
    try {
      final reply = await _handle.request('fstat');
      final paths = await remotePath(_handle.env.connection, context.signal);
      return _toInfo(
        _handle.path,
        _RemoteFileInfo.fromJson(reply.json),
        paths,
      );
    } catch (error) {
      return Err(toFileError(error, _handle.path));
    }
  }

  @override
  Future<Result<List<int>, FileError>> read(
    int offset,
    int length,
    Context context,
  ) async {
    final early = abortResult<List<int>>(context.signal, _handle.path) ??
        _closedResult<List<int>>();
    if (early != null) return early;
    if (!_safeNonNegative(offset) || !_safeNonNegative(length)) {
      return Err(FileError(
        FileErrorCode.invalid,
        'Offset and length must be non-negative safe integers',
        path: _handle.path,
      ));
    }
    try {
      final read = await _readRange(
        (at, size) => _handle.pread(at, size),
        offset,
        length,
        _readChunk,
        () => context.aborted,
      );
      if (read == null) {
        return Err(FileError(
          FileErrorCode.aborted,
          'aborted',
          path: _handle.path,
        ));
      }
      return Ok(_concat(read.chunks, read.total));
    } catch (error) {
      return Err(toFileError(error, _handle.path));
    }
  }

  @override
  Future<Result<LineScan, FileError>> scanLines(
    Map<String, int> options,
    Context context,
  ) async {
    final early = abortResult<LineScan>(context.signal, _handle.path) ??
        _closedResult<LineScan>();
    if (early != null) return early;
    final startLine = options['startLine'] ?? -1;
    final endLine = options['endLine'];
    if (!_safeNonNegative(startLine) ||
        (endLine != null &&
            (!_safeNonNegative(endLine) || endLine <= startLine))) {
      return Err(FileError(
        FileErrorCode.invalid,
        'Invalid line range',
        path: _handle.path,
      ));
    }
    try {
      final reply = await requestWithSignal(
        _handle.env.connection,
        'scanLines',
        <String, dynamic>{
          'handle': _handle.id,
          'startLine': startLine,
          if (endLine != null) 'endLine': endLine,
        },
        signal: context.signal,
        session: _handle.session,
      );
      return Ok(LineScan(
        newlines: _integer(reply.json['newlines']),
        start: _integer(reply.json['start']),
        end: _integer(reply.json['end']),
        firstLineEnd: _integer(reply.json['firstLineEnd']),
        lastLineStart: _integer(reply.json['lastLineStart']),
        selectedBytes: _integer(reply.json['selectedBytes']),
        firstLineBytes: _integer(reply.json['firstLineBytes']),
      ));
    } catch (error) {
      return Err(toFileError(error, _handle.path));
    }
  }

  @override
  Future<void> close(Context context) async {
    if (_closed) return;
    _closed = true;
    await _handle.close();
  }
}

class _RemoteDirReader implements DirReader {
  _RemoteDirReader(this._handle);

  final _Handle _handle;
  bool _done = false;
  bool _closed = false;

  @override
  Future<Result<DirPage, FileError>> next(
    int maxEntries,
    Context context,
  ) async {
    final path = _handle.path;
    final aborted = abortResult<DirPage>(context.signal, path);
    if (aborted != null) return aborted;
    if (_closed) {
      return Err(FileError(
        FileErrorCode.invalid,
        'Directory reader is closed',
        path: path,
      ));
    }
    if (!_safePositive(maxEntries)) {
      return Err(FileError(
        FileErrorCode.invalid,
        'maxEntries must be a positive safe integer',
        path: path,
      ));
    }
    final entries = <FileInfo>[];
    try {
      final paths = await remotePath(_handle.env.connection, context.signal);
      while (!_done && entries.length < maxEntries) {
        final reply = await _handle.request(
          'readdir',
          <String, dynamic>{'max': maxEntries - entries.length},
        );
        final loopAbort = abortResult<DirPage>(context.signal, path);
        if (loopAbort != null) return loopAbort;
        final wireEntries = (reply.json['entries'] as List)
            .map((entry) => _RemoteDirEntry.fromJson(
                  Map<String, dynamic>.from(entry as Map),
                ))
            .toList();
        for (final entry in wireEntries) {
          final entryPath = paths.absolute(path, entry.name);
          final error = entry.error;
          if (error != null) {
            if (error['code'] == 'ENOENT') continue;
            return Err(toFileError(RemoteError(error), entryPath));
          }
          final info = entry.info;
          if (info == null) continue;
          final converted = _toInfo(entryPath, info, paths);
          if (converted.ok) entries.add(converted.value);
        }
        _done = reply.json['done'] == true;
      }
      return Ok(DirPage(entries: entries, done: _done));
    } catch (error) {
      return Err(toFileError(error, path));
    }
  }

  @override
  Future<void> close(Context context) async {
    if (_closed) return;
    _closed = true;
    await _handle.close();
  }
}

class _RemoteTextLineReader implements TextLineReader {
  _RemoteTextLineReader(this._handle);

  final _Handle _handle;
  final StreamDecoder _decoder = StreamDecoder();
  int _offset = 0;
  String _buffered = '';
  bool _ended = false;
  bool _closed = false;

  @override
  Future<Result<TextLine?, FileError>> readLine(Context context) async {
    final path = _handle.path;
    final aborted = abortResult<TextLine?>(context.signal, path);
    if (aborted != null) return aborted;
    if (_closed) {
      return Err(FileError(
        FileErrorCode.invalid,
        'Text line reader is closed',
        path: path,
      ));
    }
    try {
      var newline = _buffered.indexOf('\n');
      while (newline == -1 && !_ended) {
        final bytes = await _handle.pread(_offset, _lineChunk);
        final afterReadAbort = abortResult<TextLine?>(context.signal, path);
        if (afterReadAbort != null) return afterReadAbort;
        _offset += bytes.length;
        _ended = bytes.isEmpty;
        final text = _ended ? _decoder.decode() : _decoder.decode(bytes);
        final found = text.indexOf('\n');
        if (found != -1) newline = _buffered.length + found;
        _buffered += text;
      }
      if (newline != -1) {
        final text = _buffered.substring(0, newline);
        _buffered = _buffered.substring(newline + 1);
        return Ok(TextLine(text: text, terminated: true));
      }
      if (_buffered.isEmpty) return const Ok<TextLine?, FileError>(null);
      final text = _buffered;
      _buffered = '';
      return Ok(TextLine(text: text, terminated: false));
    } catch (error) {
      return Err(toFileError(error, path));
    }
  }

  @override
  Future<void> close(Context context) async {
    if (_closed) return;
    _closed = true;
    _buffered = '';
    await _handle.close();
  }
}

/// A Durable execution environment backed by a pi-env daemon.
class RemoteExecutionEnv implements ExecutionEnv {
  /// Creates an environment over [connection] with remote [cwd].
  RemoteExecutionEnv({
    required this.connection,
    required this.id,
    required this.cwd,
    String? shellPath,
    Map<String, String>? shellEnv,
    RemoteWatchOptions? watch,
  })  : _shellPath = shellPath,
        _shellEnv = shellEnv,
        _watchOptions = watch ?? const RemoteWatchOptions();

  /// The stable filesystem namespace identifier.
  @override
  final String id;

  /// The remote working directory.
  @override
  String cwd;

  /// The daemon connection owned by the caller.
  final Connection connection;
  final String? _shellPath;
  final Map<String, String>? _shellEnv;
  final RemoteWatchOptions _watchOptions;
  final Map<int, int> _running = <int, int>{};

  Future<String> _resolve(String path, AbortSignal? signal) async {
    final info = await infoWithSignal(connection, signal);
    final windows = nodePlatform(info.os, info.arch)['platform'] == 'win32';
    final paths = windows ? p.windows : p.posix;
    var normalized = path;
    if (normalized == '~') {
      normalized = info.home;
    } else if (normalized.startsWith('~/') ||
        (windows && normalized.startsWith('~\\'))) {
      normalized = paths.join(info.home, normalized.substring(2));
    } else if (normalized.startsWith('file://')) {
      try {
        normalized = paths.fromUri(Uri.parse(normalized));
      } catch (_) {
        // Node keeps malformed file URLs as ordinary paths.
      }
    }
    if (paths.isAbsolute(normalized)) return paths.normalize(normalized);
    if (windows) {
      final drive =
          RegExp(r'^([a-zA-Z]:)(?![\\/])').firstMatch(normalized)?.group(1);
      if (drive != null &&
          cwd.length >= 2 &&
          drive.toLowerCase() != cwd.substring(0, 2).toLowerCase()) {
        var base = info.driveCwds[drive.toUpperCase()] ?? info.cwd;
        if (base.length >= 3 &&
            base.substring(0, 2).toLowerCase() != drive.toLowerCase() &&
            base[2] == '\\') {
          base = '$drive\\';
        }
        return p.windows.normalize(p.windows.absolute(base, normalized));
      }
    }
    return paths.normalize(paths.absolute(cwd, normalized));
  }

  Future<Result<T, FileError>> _fileOp<T>(
    String path,
    Context context,
    Future<T> Function(String resolved) run, [
    _AbortCheck check = _AbortCheck.before,
  ]) async {
    late final String resolved;
    try {
      resolved = await _resolve(path, context.signal);
    } catch (error) {
      return Err(toFileError(error, path));
    }
    final aborted = abortResult<T>(context.signal, resolved);
    if (aborted != null) return aborted;
    try {
      final value = await run(resolved);
      if (check == _AbortCheck.both) {
        final after = abortResult<T>(context.signal, resolved);
        if (after != null) return after;
      }
      return Ok(value);
    } catch (error) {
      return Err(toFileError(error, resolved));
    }
  }

  Future<Reply> _open(String resolved, Map<String, dynamic> json) async {
    final reply = await connection.request(
      'open',
      <String, dynamic>{'path': resolved, ...json},
    );
    return reply;
  }

  @override
  Future<Result<String, FileError>> absolutePath(
    String path,
    Context context,
  ) async {
    try {
      return Ok(await _resolve(path, context.signal));
    } catch (error) {
      return Err(toFileError(error, path));
    }
  }

  @override
  Future<Result<String, FileError>> joinPath(
    List<String> parts,
    Context context,
  ) async {
    try {
      final paths = await remotePath(connection, context.signal);
      return Ok(paths.joinAll(parts));
    } catch (error) {
      return Err(toFileError(error));
    }
  }

  Future<Result<Object, FileError>> _readFile(
    String path,
    bool encoding,
    Context context,
  ) {
    return _fileOp(path, context, (resolved) async {
      final reply = await _open(resolved, <String, dynamic>{'mode': 'read'});
      final handle = _Handle(
        this,
        _integer(reply.json['handle']),
        reply.session,
        resolved,
      );
      try {
        final statError = reply.json['statError'];
        if (statError != null) {
          throw RemoteError(Map<String, dynamic>.from(statError as Map));
        }
        final aborted = abortResult<Object>(context.signal, resolved);
        if (aborted != null) throw aborted.error;
        final stat = _RemoteFileInfo.fromJson(
          Map<String, dynamic>.from(reply.json['stat'] as Map),
        );
        final size = stat.kind == FileKind.file ? stat.size : 0;
        if (size > _readFileMax) {
          throw FileError(
            FileErrorCode.unknown,
            'File size ($size) is greater than 2 GiB',
            path: resolved,
          );
        }
        Uint8List bytes;
        if (size == 0) {
          final chunks = <Uint8List>[];
          var total = 0;
          while (true) {
            final current = abortResult<Object>(context.signal, resolved);
            if (current != null) throw current.error;
            final chunk = await handle.pread(null, _readFileUnknownChunk);
            if (chunk.isEmpty) break;
            total += chunk.length;
            chunks.add(chunk);
          }
          bytes = _concat(chunks, total);
        } else if (size <= _readFileChunk) {
          bytes = await handle.pread(0, size);
        } else {
          final read = await _readRange(
            (at, length) => handle.pread(at, length),
            0,
            size,
            _readFileChunk,
            () => context.aborted,
          );
          if (read == null) {
            throw FileError(
              FileErrorCode.aborted,
              'The operation was aborted',
              path: resolved,
            );
          }
          bytes = _concat(read.chunks, read.total);
        }
        if (!encoding) return bytes;
        final decoder = RangeDecoder();
        return decoder.decode(bytes) + decoder.decode();
      } finally {
        await handle.close();
      }
    });
  }

  @override
  Future<Result<String, FileError>> readTextFile(
    String path,
    Context context,
  ) async {
    final result = await _readFile(path, true, context);
    return result.ok ? Ok(result.value as String) : Err(result.error);
  }

  @override
  Future<Result<List<int>, FileError>> readBinaryFile(
    String path,
    Context context,
  ) async {
    final result = await _readFile(path, false, context);
    return result.ok ? Ok(result.value as List<int>) : Err(result.error);
  }

  @override
  Future<Result<BinaryReader, FileError>> openBinaryReader(
    String path,
    Map<String, bool>? options,
    Context context,
  ) async {
    final opened = await _fileOp(path, context, (resolved) async {
      final reply = await _open(resolved, <String, dynamic>{
        'noFollow': options?['noFollow'] == true,
      });
      return _Handle(
          this, _integer(reply.json['handle']), reply.session, resolved);
    });
    if (!opened.ok) return Err(opened.error);
    final handle = opened.value;
    final aborted = abortResult<BinaryReader>(context.signal, handle.path);
    if (aborted != null) {
      await handle.close();
      return aborted;
    }
    return Ok(_RemoteBinaryReader(handle));
  }

  @override
  Future<Result<TextLineReader, FileError>> openTextLineReader(
    String path,
    Context context,
  ) async {
    final opened = await _fileOp(path, context, (resolved) async {
      final reply = await _open(resolved, <String, dynamic>{'mode': 'read'});
      return _Handle(
          this, _integer(reply.json['handle']), reply.session, resolved);
    });
    if (!opened.ok) return Err(opened.error);
    final handle = opened.value;
    final aborted = abortResult<TextLineReader>(context.signal, handle.path);
    if (aborted != null) {
      await handle.close();
      return aborted;
    }
    return Ok(_RemoteTextLineReader(handle));
  }

  @override
  Future<Result<List<String>, FileError>> readTextLines(
    String path,
    Map<String, int>? options,
    Context context,
  ) async {
    final maxLines = options?['maxLines'];
    if (maxLines != null && maxLines <= 0) {
      return const Ok<List<String>, FileError>(<String>[]);
    }
    final opened = await openTextLineReader(path, context);
    if (!opened.ok) return Err(opened.error);
    final reader = opened.value;
    final lines = <String>[];
    try {
      while (maxLines == null || lines.length < maxLines) {
        final line = await reader.readLine(context);
        if (!line.ok) return Err(line.error);
        final value = line.value;
        if (value == null) break;
        lines.add(value.text);
      }
      return Ok(lines);
    } finally {
      await reader.close(context);
    }
  }

  Future<Result<void, FileError>> _write(
    String path,
    Object content,
    bool append,
    Context context,
  ) {
    final bytes = content is String
        ? Uint8List.fromList(utf8.encode(content))
        : content is Uint8List
            ? content
            : Uint8List.fromList(content as List<int>);
    final signal = append ? null : context.signal;
    return _fileOp(path, context, (resolved) async {
      final first =
          Uint8List.sublistView(bytes, 0, min(_writeChunk, bytes.length));
      final keep = bytes.length > _writeChunk;
      final reply = await connection.request(
        'write',
        <String, dynamic>{'path': resolved, 'append': append, 'keep': keep},
        RequestOptions(payload: first),
      );
      if (!keep) return;
      final handle = _Handle(
        this,
        _integer(reply.json['handle']),
        reply.session,
        resolved,
      );
      final inFlight = <Future<Reply>>[];
      try {
        for (var offset = _writeChunk;
            offset < bytes.length;
            offset += _writeChunk) {
          if (signal?.aborted == true) {
            await _settleAll(inFlight);
            throw FileError(
              FileErrorCode.aborted,
              'The operation was aborted',
              path: resolved,
            );
          }
          final written = handle.request(
            'writeChunk',
            const <String, dynamic>{},
            RequestOptions(
              payload: Uint8List.sublistView(
                bytes,
                offset,
                min(offset + _writeChunk, bytes.length),
              ),
            ),
          );
          unawaited(written.catchError((_) => Reply(
                const <String, dynamic>{},
                Uint8List(0),
                handle.session,
              )));
          inFlight.add(written);
          if (inFlight.length >= _writeDepth) await inFlight.removeAt(0);
        }
        for (final written in inFlight) {
          await written;
        }
      } finally {
        await _settleAll(inFlight);
        await handle.close();
      }
    }, append ? _AbortCheck.both : _AbortCheck.before);
  }

  @override
  Future<Result<void, FileError>> writeFile(
    String path,
    Object content,
    Context context,
  ) =>
      _write(path, content, false, context);

  @override
  Future<Result<void, FileError>> appendFile(
    String path,
    Object content,
    Context context,
  ) =>
      _write(path, content, true, context);

  @override
  Future<Result<void, FileError>> truncateFile(
    String path,
    int size,
    Context context,
  ) {
    return _fileOp(path, context, (resolved) async {
      if (!_safeNonNegative(size)) {
        throw FileError(
          FileErrorCode.invalid,
          'File size must be a non-negative safe integer',
          path: resolved,
        );
      }
      await connection.request('truncate', <String, dynamic>{
        'path': resolved,
        'size': size,
      });
    }, _AbortCheck.both);
  }

  @override
  Future<Result<void, FileError>> flushFile(
    String path,
    Context context,
  ) {
    return _fileOp(path, context, (resolved) async {
      await connection.request('fsync', <String, dynamic>{'path': resolved});
    }, _AbortCheck.both);
  }

  @override
  Future<Result<void, FileError>> renameFile(
    String sourcePath,
    String destinationPath,
    Context context,
  ) async {
    late final String source;
    late final String destination;
    try {
      source = await _resolve(sourcePath, context.signal);
      destination = await _resolve(destinationPath, context.signal);
    } catch (error) {
      return Err(toFileError(error, sourcePath));
    }
    final aborted = abortResult<void>(context.signal, destination);
    if (aborted != null) return aborted;
    try {
      await connection.request('rename', <String, dynamic>{
        'path': source,
        'to': destination,
      });
      return const Ok<void, FileError>(null);
    } catch (error) {
      return Err(toFileError(error, source));
    }
  }

  @override
  Future<Result<FileInfo, FileError>> fileInfo(
    String path,
    Context context,
  ) async {
    final result = await _fileOp(path, context, (resolved) async {
      final reply = await connection
          .request('lstat', <String, dynamic>{'path': resolved});
      final paths = await remotePath(connection, context.signal);
      return _toInfo(resolved, _RemoteFileInfo.fromJson(reply.json), paths);
    });
    return result.ok ? result.value : Err(result.error);
  }

  @override
  Future<Result<List<FileInfo>, FileError>> listDir(
    String path,
    Context context,
  ) {
    return _fileOp(path, context, (resolved) async {
      final reply = await connection
          .request('opendir', <String, dynamic>{'path': resolved});
      final handle = _Handle(
        this,
        _integer(reply.json['handle']),
        reply.session,
        resolved,
      );
      final entries = <_RemoteDirEntry>[];
      try {
        var done = false;
        while (!done) {
          final page =
              await handle.request('readdir', <String, dynamic>{'max': 1000});
          entries.addAll((page.json['entries'] as List).map((entry) =>
              _RemoteDirEntry.fromJson(
                  Map<String, dynamic>.from(entry as Map))));
          done = page.json['done'] == true;
        }
      } finally {
        await handle.close();
      }
      final paths = await remotePath(connection, context.signal);
      if (paths.style == p.Style.posix) {
        entries.sort((a, b) => _compareBytes(
            a.raw ?? utf8.encode(a.name), b.raw ?? utf8.encode(b.name)));
      }
      final infos = <FileInfo>[];
      for (final entry in entries) {
        final aborted = abortResult<FileInfo>(context.signal, resolved);
        if (aborted != null) throw aborted.error;
        final entryPath = paths.absolute(resolved, entry.name);
        final error = entry.error;
        if (error != null) {
          if (error['code'] == 'ENOENT') continue;
          throw toFileError(RemoteError(error), entryPath);
        }
        final info = entry.info;
        if (info == null) continue;
        final converted = _toInfo(entryPath, info, paths);
        if (converted.ok) infos.add(converted.value);
      }
      return infos;
    });
  }

  @override
  Future<Result<FileListing, FileError>> listFiles(
    String path,
    ListFilesOptions? options,
    Context context,
  ) async {
    try {
      final resolved = await _resolve(path, context.signal);
      return await listFilesOver(connection, resolved, options, context);
    } catch (error) {
      return Err(toFileError(error, path));
    }
  }

  @override
  Future<Result<DirReader, FileError>> openDirReader(
    String path,
    Context context,
  ) async {
    final opened = await _fileOp(path, context, (resolved) async {
      final reply = await connection
          .request('opendir', <String, dynamic>{'path': resolved});
      return _Handle(
          this, _integer(reply.json['handle']), reply.session, resolved);
    });
    if (!opened.ok) return Err(opened.error);
    final handle = opened.value;
    final aborted = abortResult<DirReader>(context.signal, handle.path);
    if (aborted != null) {
      await handle.close();
      return aborted;
    }
    return Ok(_RemoteDirReader(handle));
  }

  @override
  Future<Result<String, FileError>> canonicalPath(
    String path,
    Context context,
  ) {
    return _fileOp(path, context, (resolved) async {
      final reply = await connection
          .request('realpath', <String, dynamic>{'path': resolved});
      return reply.json['path'] as String;
    });
  }

  @override
  Future<Result<bool, FileError>> exists(
    String path,
    Context context,
  ) async {
    final result = await fileInfo(path, context);
    if (result.ok) return const Ok<bool, FileError>(true);
    if (result.error.code == FileErrorCode.notFound) {
      return const Ok<bool, FileError>(false);
    }
    return Err(result.error);
  }

  @override
  Future<Result<void, FileError>> createDir(
    String path,
    Map<String, bool>? options,
    Context context,
  ) {
    return _fileOp(path, context, (resolved) async {
      await connection.request('mkdir', <String, dynamic>{
        'path': resolved,
        'recursive': options?['recursive'] ?? true,
      });
    });
  }

  @override
  Future<Result<void, FileError>> remove(
    String path,
    Map<String, bool>? options,
    Context context,
  ) {
    return _fileOp(path, context, (resolved) async {
      await connection.request('rm', <String, dynamic>{
        'path': resolved,
        'recursive': options?['recursive'] ?? false,
        'force': options?['force'] ?? false,
      });
    });
  }

  @override
  Future<Result<String, FileError>> createTempDir(
    String? prefix,
    Context context,
  ) async {
    final aborted = abortResult<String>(context.signal);
    if (aborted != null) return aborted;
    try {
      final info = await infoWithSignal(connection, context.signal);
      final paths = await remotePath(connection, context.signal);
      final reply = await connection.request('mkdtemp', <String, dynamic>{
        'path': paths.join(info.tmpdir, prefix ?? 'tmp-'),
      });
      return Ok(reply.json['path'] as String);
    } catch (error) {
      return Err(toFileError(error));
    }
  }

  @override
  Future<Result<String, FileError>> createTempFile(
    Map<String, String>? options,
    Context context,
  ) async {
    final dir = await createTempDir('tmp-', context);
    if (!dir.ok) return Err(dir.error);
    var filePath = '';
    try {
      final paths = await remotePath(connection, context.signal);
      filePath = paths.join(
        dir.value,
        '${options?['prefix'] ?? ''}${_randomUuid()}${options?['suffix'] ?? ''}',
      );
      await connection.request(
        'write',
        <String, dynamic>{'path': filePath, 'append': false, 'parents': false},
        RequestOptions(payload: Uint8List(0)),
      );
      return Ok(filePath);
    } catch (error) {
      return Err(toFileError(error, filePath));
    }
  }

  @override
  Future<Result<FileWatcher, FileError>> watch(
    List<WatchTarget> targets,
    void Function(FileChange) onChange,
    Context context,
  ) async {
    final aborted = abortResult<FileWatcher>(context.signal);
    if (aborted != null) return aborted;
    try {
      final resolved =
          await Future.wait(targets.map((target) async => WatchTarget(
                path: await _resolve(target.path, context.signal),
                recursive: target.recursive,
                exclude: target.exclude,
              )));
      final afterResolve = abortResult<FileWatcher>(context.signal);
      if (afterResolve != null) return afterResolve;
      final watcher = await RemoteWatcher.open(
        connection,
        resolved,
        onChange,
        _watchOptions,
      );
      final afterOpen = abortResult<FileWatcher>(context.signal);
      if (afterOpen != null) {
        await watcher.stop(context);
        return afterOpen;
      }
      return Ok(watcher);
    } catch (error) {
      return Err(toFileError(error));
    }
  }

  @override
  Future<Result<ShellExecResult, ExecutionError>> exec(
    Object command,
    ShellExecOptions? options,
    Context context,
  ) async {
    final signal = context.signal;
    if (signal?.aborted == true) {
      return Err(ExecutionError(ExecutionErrorCode.aborted, 'aborted'));
    }
    final timeout = options?.timeout;
    if (timeout != null) {
      if (!timeout.isFinite || timeout <= 0) {
        return Err(ExecutionError(
          ExecutionErrorCode.timeout,
          'Invalid timeout: must be a finite number of seconds',
        ));
      }
      if (timeout * 1000 > _maxTimeoutMs) {
        return Err(ExecutionError(
          ExecutionErrorCode.timeout,
          'Invalid timeout: maximum is ${_maxTimeoutMs / 1000} seconds',
        ));
      }
    }
    final inheritEnv = options?.inheritEnv ?? true;
    final env = <String, String>{};
    if (inheritEnv) _addEnvironment(env, _shellEnv);
    _addEnvironment(env, options?.env);
    final spill = options?.spill;
    final window = options?.window;
    ExecutionError? callbackError;
    var timedOut = false;
    var settled = false;
    int? running;
    final request = RequestSignal(signal);
    final resolveSignal = AbortSignal();
    final removeResolveAbort = request.controller.onAbort(resolveSignal.abort);
    Timer? timer;
    ExecutionError stopError() => timedOut
        ? ExecutionError(ExecutionErrorCode.timeout, 'timeout:$timeout')
        : ExecutionError(ExecutionErrorCode.aborted, 'aborted');
    if (timeout != null) {
      timer = Timer(
        Duration(microseconds: (timeout * 1000000).round()),
        () {
          if (request.controller.aborted) return;
          timedOut = true;
          request.abort();
        },
      );
    }
    try {
      late final String cwd;
      try {
        cwd = options?.cwd != null
            ? await _resolve(options!.cwd!, resolveSignal)
            : this.cwd;
      } catch (error) {
        if (request.controller.aborted) return Err(stopError());
        return Err(ExecutionError(
          ExecutionErrorCode.unknown,
          _message(error),
        ));
      }
      if (request.controller.aborted) return Err(stopError());
      final reply = await connection.request(
        'exec',
        <String, dynamic>{
          if (command is String)
            'command': command
          else
            'argv': (command as List).cast<String>(),
          'cwd': cwd,
          'env': env,
          'inheritEnv': inheritEnv,
          if (_shellPath != null) 'shellPath': _shellPath,
          if (timeout != null) 'timeoutMs': timeout * 1000,
          if (spill != null)
            'spill': <String, dynamic>{
              'afterBytes': spill.afterBytes,
              'afterLines': spill.afterLines,
            },
          if (window != null)
            'window': <String, dynamic>{
              'maxBytes': window.maxBytes,
              'maxLines': window.maxLines,
              'minIntervalMs': window.minIntervalMs,
              'bytesPerSecond': window.bytesPerSecond,
            },
        },
        RequestOptions(
          signal: request.controller,
          onStart: (requestId, session) {
            running = requestId;
            _running[requestId] = session;
          },
          onEvent: (event, payload) {
            if (settled || callbackError != null || event['kind'] != 'output') {
              return;
            }
            final text = _decodeOutput(payload);
            if (text.isEmpty || options?.onOutput == null) return;
            final skipped = event['skipped'];
            final info = ShellOutputInfo(
              stream: event['stream'] == 'stderr' ? 'stderr' : 'stdout',
              skipped: skipped is Map
                  ? ShellOutputSkip(
                      bytes: _integer(skipped['bytes']),
                      newlines: _integer(skipped['newlines']),
                      endsWithNewline: skipped['endsWithNewline'] == true,
                    )
                  : null,
            );
            try {
              options!.onOutput!(text, context, info);
            } catch (error) {
              final cause = error is Error ? error : StateError('$error');
              callbackError = ExecutionError(
                ExecutionErrorCode.callbackError,
                _message(cause),
                cause: cause,
              );
              request.abort();
            }
          },
        ),
      );
      if (callbackError != null) return Err(callbackError!);
      return Ok(ShellExecResult(
        exitCode: _integer(reply.json['exitCode']),
        spillPath: reply.json['spillPath'] as String?,
      ));
    } catch (error) {
      if (callbackError != null) return Err(callbackError!);
      if (error is! RemoteError) {
        return Err(ExecutionError(
          ExecutionErrorCode.unknown,
          _message(error),
        ));
      }
      final code = switch (error.code) {
        'timeout' => ExecutionErrorCode.timeout,
        'aborted' =>
          timedOut ? ExecutionErrorCode.timeout : ExecutionErrorCode.aborted,
        'shell_unavailable' => ExecutionErrorCode.shellUnavailable,
        'spawn_error' => ExecutionErrorCode.spawnError,
        _ => ExecutionErrorCode.unknown,
      };
      final message = switch (code) {
        ExecutionErrorCode.timeout => 'timeout:$timeout',
        ExecutionErrorCode.aborted => 'aborted',
        _ => error.message,
      };
      return Err(ExecutionError(
        code,
        message,
        cause: error,
        spillPath: error.fields['spillPath'] as String?,
      ));
    } finally {
      settled = true;
      timer?.cancel();
      removeResolveAbort();
      request.dispose();
      if (running != null) _running.remove(running);
    }
  }

  @override
  Future<void> cleanup(Context context) async {
    for (final entry in _running.entries.toList()) {
      connection.kill(entry.key, entry.value);
    }
    _running.clear();
  }
}

bool _safeNonNegative(int value) => value >= 0 && value <= _maxSafeInteger;

bool _safePositive(int value) => _safeNonNegative(value) && value > 0;

int _integer(Object? value) => switch (value) {
      int value => value,
      num value => value.toInt(),
      String value => int.parse(value),
      _ => 0,
    };

int _compareBytes(List<int> a, List<int> b) {
  for (var index = 0; index < min(a.length, b.length); index++) {
    final difference = a[index] - b[index];
    if (difference != 0) return difference;
  }
  return a.length - b.length;
}

Future<void> _settleAll(List<Future<Reply>> futures) async {
  for (final future in futures) {
    try {
      await future;
    } catch (_) {
      // The first failure is reported by the sequential await above.
    }
  }
}

void _addEnvironment(Map<String, String> target, Map<String, String>? values) {
  if (values == null) return;
  for (final entry in values.entries) {
    target[_wellFormed(entry.key)] = _wellFormed(entry.value);
  }
}

String _wellFormed(String value) => String.fromCharCodes(value.runes
    .map((rune) => rune >= 0xd800 && rune <= 0xdfff ? 0xfffd : rune));

String _decodeOutput(Uint8List bytes) {
  final decoder = RangeDecoder();
  return decoder.decode(bytes) + decoder.decode();
}

String _message(Object error) {
  if (error is RemoteError) return error.message;
  if (error is StateError) return error.message;
  return error.toString();
}

String _randomUuid() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex =
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
