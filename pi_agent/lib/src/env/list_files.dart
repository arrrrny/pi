import 'dart:convert';

import '../chord/context.dart';
import '../durable/env/index.dart';
import 'connection.dart';
import 'errors.dart';
import 'signal.dart';

const _fileKind = 102;
const _directoryKind = 100;
const _symlinkKind = 108;

bool _safeNonNegative(int value) => value >= 0 && value <= 9007199254740991;

/// Lists an absolute [path] through the daemon's `listFiles` operation.
Future<Result<FileListing, FileError>> listFilesOver(
  Connection connection,
  String path,
  ListFilesOptions? options,
  Context context,
) async {
  for (final (value, name) in <(int?, String)>[
    (options?.maxEntries, 'maxEntries'),
    (options?.maxBytes, 'maxBytes'),
    (options?.timeoutMs, 'timeoutMs'),
  ]) {
    if (value != null && !_safeNonNegative(value)) {
      return Err(FileError(
        FileErrorCode.invalid,
        '$name must be a non-negative safe integer',
        path: path,
      ));
    }
  }
  final aborted = abortResult<FileListing>(context.signal, path);
  if (aborted != null) return aborted;
  try {
    final info = await infoWithSignal(connection, context.signal);
    if (!info.features.contains('listFiles')) {
      return Err(FileError(
        FileErrorCode.notSupported,
        'The pi-env daemon does not list files; update it',
        path: path,
      ));
    }
    final reply = await requestWithSignal(
      connection,
      'listFiles',
      <String, dynamic>{
        'path': path,
        if (options?.hidden != null) 'hidden': options!.hidden,
        if (options?.gitignore != null) 'gitignore': options!.gitignore,
        if (options?.exclude != null) 'exclude': options!.exclude,
        if (options?.maxEntries != null) 'maxEntries': options!.maxEntries,
        if (options?.maxBytes != null) 'maxBytes': options!.maxBytes,
        if (options?.timeoutMs != null) 'timeoutMs': options!.timeoutMs,
      },
      signal: context.signal,
    );
    final afterAbort = abortResult<FileListing>(context.signal, path);
    if (afterAbort != null) return afterAbort;
    final entries = <FileListEntry>[];
    final bytes = reply.payload;
    var start = 0;
    while (start < bytes.length) {
      final end = bytes.indexOf(0, start);
      if (end == -1) break;
      final kind = switch (bytes[start]) {
        _fileKind => FileKind.file,
        _directoryKind => FileKind.directory,
        _symlinkKind => FileKind.symlink,
        _ => null,
      };
      if (kind != null) {
        entries.add(FileListEntry(
          path:
              utf8.decode(bytes.sublist(start + 1, end), allowMalformed: true),
          kind: kind,
        ));
      }
      start = end + 1;
    }
    return Ok(FileListing(
      entries: entries,
      truncated: reply.json['truncated'] == true,
    ));
  } catch (error) {
    return Err(toFileError(error, path));
  }
}
