// Error mapping between the daemon's wire errors and the portable env taxonomy.
//
// Port of `packages/env/src/errors.ts` at the pinned upstream SHA.
library;

import '../durable/env/index.dart' show FileError, FileErrorCode;
import 'connection.dart' show AbortSignal, RemoteError;

/// A [FileError] for an aborted operation over [path], or null when [signal]
/// is absent or not aborted.
FileError? abortResult(Object? signal, [String? path]) {
  if (signal is AbortSignal && signal.aborted) {
    return FileError(FileErrorCode.aborted, 'aborted', path: path);
  }
  return null;
}

/// Maps a thrown value to a [FileError], passing an existing [FileError]
/// through unchanged.
FileError toFileError(Object? error, [String? fallbackPath]) {
  if (error is FileError) return error;
  if (error is! RemoteError) {
    final cause = error is Error ? error : _wrap(error);
    return FileError(FileErrorCode.unknown, cause.toString(),
        path: fallbackPath, cause: cause);
  }
  final path = error.path ?? fallbackPath;
  final code = switch (error.code) {
    'aborted' => FileErrorCode.aborted,
    'ENOENT' => FileErrorCode.notFound,
    'EACCES' || 'EPERM' => FileErrorCode.permissionDenied,
    'ENOTDIR' => FileErrorCode.notDirectory,
    'EISDIR' => FileErrorCode.isDirectory,
    'EINVAL' || 'SYMLINK' || 'NOT_REGULAR' => FileErrorCode.invalid,
    _ => FileErrorCode.unknown,
  };
  return FileError(code, error.message, path: path, cause: error);
}

Error _wrap(Object? error) =>
    error is Error ? error : StateError(error?.toString() ?? 'unknown error');
