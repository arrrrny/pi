// The portable environment capability surface: a fallible `Result`, the file
// and execution error taxonomy, and the abstract contracts an environment
// implements (filesystem, shell, watching, directory and binary readers).
//
// Port of `packages/durable/src/env/index.ts` at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`. The interfaces carry no runtime
// behaviour of their own; the Node concrete implementations (`node.ts`,
// `node-watch.ts`) are not portable and are tracked `not_applicable`, so only
// the contracts and the `Result`/error helpers are ported here. The streaming
// decode and line-scan surface is re-exported from the slice that landed first.
library;

import 'dart:convert';

import '../../chord/context.dart';
import 'line_scan.dart';

export 'decode.dart';
export 'line_scan.dart';

/// Result of a fallible operation. Expected failures are returned instead of
/// thrown: an [Ok] carries a value, an [Err] carries an error.
sealed class Result<TValue, TError> {
  const Result();

  /// Whether this is a success ([Ok]).
  bool get ok;
}

/// A successful [Result] carrying [value].
final class Ok<TValue, TError> extends Result<TValue, TError> {
  /// An [Ok] holding [value].
  const Ok(this.value);

  /// The success value.
  final TValue value;

  @override
  bool get ok => true;
}

/// A failed [Result] carrying [error].
final class Err<TValue, TError> extends Result<TValue, TError> {
  /// An [Err] holding [error].
  const Err(this.error);

  /// The failure error.
  final TError error;

  @override
  bool get ok => false;
}

/// A successful [Result] holding [value].
Result<TValue, TError> ok<TValue, TError>(TValue value) =>
    Ok<TValue, TError>(value);

/// A failed [Result] holding [error].
Result<TValue, TError> err<TValue, TError>(TError error) =>
    Err<TValue, TError>(error);

/// The value of a successful [result], or rethrows its error when it failed.
TValue getOrThrow<TValue, TError>(Result<TValue, TError> result) {
  return switch (result) {
    Ok<TValue, TError>(:final value) => value,
    Err<TValue, TError>(:final error) => throw error as Object,
  };
}

/// The value of a successful [result], or null when it failed.
TValue? getOrUndefined<TValue extends Object, TError>(
    Result<TValue, TError> result) {
  return switch (result) {
    Ok<TValue, TError>(:final value) => value,
    Err<TValue, TError>() => null,
  };
}

/// Wraps an arbitrary thrown value into an [Error], never throwing itself.
///
/// An [Error] passes through; a string becomes its message; anything else is
/// JSON-encoded, falling back to its `toString` when it does not encode.
Error toError(Object? error) {
  if (error is Error) return error;
  if (error is String) return _MessageError(error);
  try {
    return _MessageError(jsonEncode(error));
  } catch (_) {
    return _MessageError('$error');
  }
}

/// An [Error] that carries a plain message, the port of a constructed JS
/// `Error`.
class _MessageError extends Error {
  final String message;

  _MessageError(this.message);

  @override
  String toString() => message;
}

/// The kind of a filesystem entry.
enum FileKind {
  /// A regular file.
  file,

  /// A directory.
  directory,

  /// A symbolic link, listed as such and not followed.
  symlink,
}

/// Why a filesystem operation failed.
enum FileErrorCode {
  /// The operation was aborted.
  aborted,

  /// The path does not exist.
  notFound,

  /// The operation lacks permission.
  permissionDenied,

  /// A non-directory was used where a directory was required.
  notDirectory,

  /// A directory was used where a non-directory was required.
  isDirectory,

  /// The path or argument was invalid.
  invalid,

  /// The environment cannot perform the operation.
  notSupported,

  /// An unclassified failure.
  unknown,
}

/// A filesystem operation's failure, returned rather than thrown.
class FileError extends Error {
  /// A failure with [code], [message], an optional [path] and [cause].
  FileError(this.code, this.message, {this.path, this.cause});

  /// Why the operation failed.
  final FileErrorCode code;

  /// A human-readable description.
  final String message;

  /// The path the operation targeted, when it had one.
  final String? path;

  /// The underlying error, when one caused this.
  final Error? cause;

  @override
  String toString() => 'FileError(${code.name}): $message';
}

/// Why a command execution failed.
enum ExecutionErrorCode {
  /// The execution was aborted.
  aborted,

  /// The execution exceeded its timeout.
  timeout,

  /// The environment has no shell.
  shellUnavailable,

  /// The process could not be spawned.
  spawnError,

  /// An output callback threw.
  callbackError,

  /// An unclassified failure.
  unknown,
}

/// A command execution's failure, returned rather than thrown.
class ExecutionError extends Error {
  /// A failure with [code], [message], an optional [cause] and [spillPath].
  ExecutionError(this.code, this.message, {this.cause, this.spillPath});

  /// Why the execution failed.
  final ExecutionErrorCode code;

  /// A human-readable description.
  final String message;

  /// The underlying error, when one caused this.
  final Error? cause;

  /// Spill file of a command that timed out or was aborted after its output
  /// crossed the spill thresholds.
  final String? spillPath;

  @override
  String toString() => 'ExecutionError(${code.name}): $message';
}

/// Metadata of one filesystem entry.
class FileInfo {
  /// Metadata for an entry with the given fields.
  const FileInfo({
    required this.name,
    required this.path,
    required this.kind,
    required this.size,
    required this.mtimeMs,
  });

  /// The entry's name.
  final String name;

  /// The entry's path.
  final String path;

  /// The entry's kind.
  final FileKind kind;

  /// The entry's size in bytes.
  final int size;

  /// The entry's modification time in milliseconds since the epoch.
  final num mtimeMs;
}

/// One line of text and whether it was newline-terminated.
class TextLine {
  /// A line with [text] and whether it was [terminated] by a newline.
  const TextLine({required this.text, required this.terminated});

  /// The line's text, without its terminator.
  final String text;

  /// Whether the line ended with a newline.
  final bool terminated;
}

/// Reads a file one line at a time.
abstract class TextLineReader {
  /// The next line, or null at end of file.
  Future<Result<TextLine?, FileError>> readLine(Context context);

  /// Releases the reader. Idempotent.
  Future<void> close(Context context);
}

/// Positional reads from one opened regular file; all calls see the same file
/// even if its path is renamed.
abstract class BinaryReader {
  /// Metadata of the opened file, not of whatever its path names now.
  Future<Result<FileInfo, FileError>> info(Context context);

  /// Up to [length] bytes at [offset]; fewer only at end of file.
  Future<Result<List<int>, FileError>> read(
      int offset, int length, Context context);

  /// One pass that locates lines `[startLine, endLine)` (`endLine` absent: to
  /// the end), 0-based, decoding sizes as whole-input UTF-8 decode would.
  Future<Result<LineScan, FileError>> scanLines(
      Map<String, int> options, Context context);

  /// Releases the reader. Idempotent.
  Future<void> close(Context context);
}

/// A file or directory to watch. It may be missing; creating it is a change.
class WatchTarget {
  /// A target at [path], optionally [recursive] with [exclude].
  const WatchTarget({
    required this.path,
    this.recursive,
    this.exclude,
  });

  /// The path to watch.
  final String path;

  /// Watch everything below a directory, not only its entries. Symbolic links
  /// below it are not followed.
  final bool? recursive;

  /// Entries below [path] that are neither watched nor reported.
  final WatchExclude? exclude;
}

/// Names excluded from a [WatchTarget]'s coverage.
class WatchExclude {
  /// An exclusion of [hidden] dot-names and the listed [names].
  const WatchExclude({this.hidden, this.names});

  /// Whether names starting with `.` are excluded.
  final bool? hidden;

  /// Specific names to exclude.
  final List<String>? names;
}

/// What changed, tagged by its subtype: paths, overflow, or failed.
sealed class FileChange {
  const FileChange();
}

/// Something at or below each path may have changed. Calls may be spurious; a
/// change is never missed while the watcher is healthy.
final class FileChangePaths extends FileChange {
  /// A change at or below [paths].
  const FileChangePaths(this.paths);

  /// The paths that may have changed.
  final List<String> paths;
}

/// Coverage was uncertain for a while; rescan everything that is watched.
final class FileChangeOverflow extends FileChange {
  /// A coverage overflow; rescan everything watched.
  const FileChangeOverflow();
}

/// The watcher stopped with [error]; no calls follow.
final class FileChangeFailed extends FileChange {
  /// A watcher that stopped with [error].
  const FileChangeFailed(this.error);

  /// The error that stopped the watcher.
  final FileError error;
}

/// A subscription to file changes.
abstract class FileWatcher {
  /// `native` reports within about two seconds; `polling` compares snapshots.
  String get mode;

  /// Stops watching; no callback starts after this resolves. Idempotent.
  Future<void> stop(Context context);
}

/// Pages of one directory's entries.
abstract class DirReader {
  /// Up to [maxEntries] entries in file-system order, continuing where the
  /// previous call stopped; the page's `done` marks the end.
  Future<Result<DirPage, FileError>> next(int maxEntries, Context context);

  /// Releases the reader. Idempotent.
  Future<void> close(Context context);
}

/// One page of a [DirReader].
class DirPage {
  /// A page of [entries] with whether it is the last ([done]).
  const DirPage({required this.entries, required this.done});

  /// The page's entries.
  final List<FileInfo> entries;

  /// Whether this is the last page.
  final bool done;
}

/// What `FileSystem.listFiles` lists.
class ListFilesOptions {
  /// Listing bounds: [hidden], [gitignore], [exclude], and the limits.
  const ListFilesOptions({
    this.hidden,
    this.gitignore,
    this.exclude,
    this.maxEntries,
    this.maxBytes,
    this.timeoutMs,
  });

  /// Include names starting with `.`; default true.
  final bool? hidden;

  /// Skip what git ignores inside a work tree; default true.
  final bool? gitignore;

  /// Names of entries to skip with everything below them.
  final List<String>? exclude;

  /// Most entries to list.
  final int? maxEntries;

  /// Most bytes of the listing.
  final int? maxBytes;

  /// Time after which the listing stops, in milliseconds.
  final int? timeoutMs;
}

/// One entry of a [FileListing].
class FileListEntry {
  /// An entry at [path] of [kind].
  const FileListEntry({required this.path, required this.kind});

  /// Relative to the listed directory, with `/` separators on every system.
  final String path;

  /// The entry's kind; a symbolic link is listed as such and not followed.
  final FileKind kind;
}

/// The files below a directory, with whether a bound ended it early.
class FileListing {
  /// A listing of [entries] with whether it was [truncated].
  const FileListing({required this.entries, required this.truncated});

  /// Depth first, parents before their entries, siblings in byte order.
  final List<FileListEntry> entries;

  /// Whether a bound in [ListFilesOptions] ended the listing early.
  final bool truncated;
}

/// Portable filesystem capability. Operations return failures rather than
/// throwing.
abstract class FileSystem {
  /// The file namespace: equal ids see the same files at the same paths.
  String get id;

  /// The current working directory.
  String get cwd;

  /// Sets the current working directory.
  set cwd(String value);

  /// The absolute form of [path].
  Future<Result<String, FileError>> absolutePath(String path, Context context);

  /// Joins [parts] into one path.
  Future<Result<String, FileError>> joinPath(
      List<String> parts, Context context);

  /// The file's text.
  Future<Result<String, FileError>> readTextFile(String path, Context context);

  /// Opens [path] for line-by-line reading.
  Future<Result<TextLineReader, FileError>> openTextLineReader(
      String path, Context context);

  /// The file's lines, bounded by `maxLines` when given.
  Future<Result<List<String>, FileError>> readTextLines(
      String path, Map<String, int>? options, Context context);

  /// The file's bytes.
  Future<Result<List<int>, FileError>> readBinaryFile(
      String path, Context context);

  /// Opens [path] for bounded positional reads; `noFollow` refuses a final
  /// symbolic-link component.
  Future<Result<BinaryReader, FileError>> openBinaryReader(
      String path, Map<String, bool>? options, Context context);

  /// Writes [content] (text or bytes) to [path], replacing it.
  Future<Result<void, FileError>> writeFile(
      String path, Object content, Context context);

  /// Appends [content] (text or bytes) to [path].
  Future<Result<void, FileError>> appendFile(
      String path, Object content, Context context);

  /// Truncates or extends [path] to exactly [size] bytes.
  Future<Result<void, FileError>> truncateFile(
      String path, int size, Context context);

  /// Flushes [path]'s contents and retrieval metadata.
  Future<Result<void, FileError>> flushFile(String path, Context context);

  /// Renames [sourcePath] to [destinationPath].
  Future<Result<void, FileError>> renameFile(
      String sourcePath, String destinationPath, Context context);

  /// [path]'s metadata.
  Future<Result<FileInfo, FileError>> fileInfo(String path, Context context);

  /// The entries of directory [path].
  Future<Result<List<FileInfo>, FileError>> listDir(
      String path, Context context);

  /// The files, directories and links below [path], at any depth.
  Future<Result<FileListing, FileError>> listFiles(
      String path, ListFilesOptions? options, Context context);

  /// Opens [path] for paged directory reading.
  Future<Result<DirReader, FileError>> openDirReader(
      String path, Context context);

  /// Reports changes to [targets] through [onChange].
  Future<Result<FileWatcher, FileError>> watch(List<WatchTarget> targets,
      void Function(FileChange change) onChange, Context context);

  /// The canonical form of [path].
  Future<Result<String, FileError>> canonicalPath(String path, Context context);

  /// Whether [path] exists.
  Future<Result<bool, FileError>> exists(String path, Context context);

  /// Creates directory [path]; `recursive` creates parents.
  Future<Result<void, FileError>> createDir(
      String path, Map<String, bool>? options, Context context);

  /// Removes [path]; `recursive` and `force` widen what it removes.
  Future<Result<void, FileError>> remove(
      String path, Map<String, bool>? options, Context context);

  /// Creates a temporary directory with [prefix] and returns its path.
  Future<Result<String, FileError>> createTempDir(
      String? prefix, Context context);

  /// Creates a temporary file and returns its path; `prefix`/`suffix` shape its
  /// name.
  Future<Result<String, FileError>> createTempFile(
      Map<String, String>? options, Context context);

  /// Releases every resource the environment holds.
  Future<void> cleanup(Context context);
}

/// Spill the complete output to a temporary file once it exceeds either
/// threshold.
class ShellSpillOptions {
  /// Spill thresholds of [afterBytes] and [afterLines].
  const ShellSpillOptions({required this.afterBytes, required this.afterLines});

  /// Spill once the output exceeds this many bytes.
  final int afterBytes;

  /// Spill once the output exceeds this many complete or partial lines.
  final int afterLines;
}

/// The result of a command that ran to completion.
class ShellExecResult {
  /// A result with [exitCode] and an optional [spillPath].
  const ShellExecResult({required this.exitCode, this.spillPath});

  /// The command's exit code.
  final int exitCode;

  /// Temporary file holding the complete raw output, when the spill thresholds
  /// were exceeded.
  final String? spillPath;
}

/// The tail of the combined output a caller keeps, and how often it samples it.
class ShellOutputWindow {
  /// A window keeping [maxBytes]/[maxLines], sampled per [minIntervalMs].
  const ShellOutputWindow({
    required this.maxBytes,
    required this.maxLines,
    required this.minIntervalMs,
    required this.bytesPerSecond,
  });

  /// UTF-8 bytes of decoded text kept at the end of the output.
  final int maxBytes;

  /// Lines kept at the end of the output.
  final int maxLines;

  /// Minimum pause between the caller's samples, in milliseconds.
  final int minIntervalMs;

  /// Each sample also pauses the caller in proportion to its size at this rate.
  final int bytesPerSecond;
}

/// Output an environment omitted, measured on the decoded text.
class ShellOutputSkip {
  /// Omitted output of [bytes] and [newlines].
  const ShellOutputSkip({
    required this.bytes,
    required this.newlines,
    required this.endsWithNewline,
  });

  /// UTF-8 byte length of the omitted text.
  final int bytes;

  /// Newlines (U+000A) in the omitted text.
  final int newlines;

  /// Whether the omitted text ends with a newline.
  final bool endsWithNewline;
}

/// Which stream a chunk came from, and any output omitted before it.
class ShellOutputInfo {
  /// Info for a [stream] chunk with optional [skipped] output.
  ShellOutputInfo({required this.stream, this.skipped});

  /// The stream the chunk came from: `stdout` or `stderr`.
  final String stream;

  /// Output omitted immediately before this chunk, only with a window.
  final ShellOutputSkip? skipped;
}

/// Options for one [Shell.exec] call.
class ShellExecOptions {
  /// Options for one execution: [cwd], [env], [timeout], [onOutput], and more.
  ShellExecOptions({
    this.cwd,
    this.env,
    this.inheritEnv,
    this.timeout,
    this.onOutput,
    this.spill,
    this.window,
  });

  /// The working directory for the command.
  final String? cwd;

  /// Environment variables for the command.
  final Map<String, String>? env;

  /// Whether the command inherits the environment's variables.
  final bool? inheritEnv;

  /// The command's timeout in seconds.
  final num? timeout;

  /// Every decoded chunk of stdout and stderr as it arrives, in arrival order.
  final void Function(String text, Context context, ShellOutputInfo info)?
      onOutput;

  /// Spill thresholds for the complete output.
  final ShellSpillOptions? spill;

  /// The tail of the output the caller keeps.
  final ShellOutputWindow? window;
}

/// Runs commands in the environment.
abstract class Shell {
  /// Runs a command. A [String] runs through the shell; a [List] of strings
  /// runs `command[0]` directly with the rest as arguments. Aborting the
  /// context or a timeout kills only this command's processes.
  Future<Result<ShellExecResult, ExecutionError>> exec(
      Object command, ShellExecOptions? options, Context context);

  /// Kills every command this environment still runs; for its owner's
  /// shutdown, never for one request.
  Future<void> cleanup(Context context);
}

/// An environment that is both a [FileSystem] and a [Shell].
abstract class ExecutionEnv implements FileSystem, Shell {}
