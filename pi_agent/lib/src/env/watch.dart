import 'dart:async';

import '../chord/context.dart' show Context;
import '../durable/env/index.dart';
import 'connection.dart';
import 'errors.dart';

/// How the daemon establishes file-watch coverage.
enum RemoteWatchMode {
  /// Native filesystem events trigger snapshot comparisons.
  native,

  /// Periodic snapshots detect changes.
  polling,
}

/// Options forwarded to the daemon's watcher.
class RemoteWatchOptions {
  /// Creates watcher options with optional mode and polling bounds.
  const RemoteWatchOptions({
    this.mode,
    this.pollIntervalMs,
    this.maxDirectories,
  });

  /// Forces a watch mode; otherwise the daemon chooses.
  final RemoteWatchMode? mode;

  /// Milliseconds between snapshots in polling mode.
  final int? pollIntervalMs;

  /// Maximum directories covered by one watcher.
  final int? maxDirectories;
}

const _overflow = FileChangeOverflow();
const _reconnectFirstMs = 1000;
const _reconnectMaxMs = 30000;

/// A daemon watcher that reconnects after a lost connection and reports overflow.
class RemoteWatcher implements FileWatcher {
  RemoteWatcher._(
    this._connection,
    this._targets,
    this._onChange,
    this._options,
  );

  final Connection _connection;
  final List<WatchTarget> _targets;
  final void Function(FileChange) _onChange;
  final RemoteWatchOptions _options;
  String _mode = 'native';
  bool _stopped = false;
  AbortSignal? _controller;
  Future<void>? _request;
  void Function()? _wake;

  /// Opens a watcher and resolves after the daemon establishes coverage.
  static Future<RemoteWatcher> open(
    Connection connection,
    List<WatchTarget> targets,
    void Function(FileChange) onChange, [
    RemoteWatchOptions options = const RemoteWatchOptions(),
  ]) async {
    final watcher = RemoteWatcher._(connection, targets, onChange, options);
    try {
      await watcher._start();
      return watcher;
    } catch (_) {
      watcher._stopped = true;
      watcher._controller?.abort();
      rethrow;
    }
  }

  @override
  String get mode => _mode;

  @override
  Future<void> stop(Context context) async {
    if (_stopped) return;
    _stopped = true;
    _wake?.call();
    _controller?.abort();
    await _request;
  }

  void _deliver(FileChange change) {
    if (_stopped) return;
    try {
      _onChange(change);
    } catch (_) {
      // A consumer callback cannot terminate the daemon watcher.
    }
  }

  Future<void> _start() {
    final ready = Completer<void>();
    final controller = AbortSignal();
    _controller = controller;
    final request = _connection.request(
      'watch',
      <String, dynamic>{
        'targets': _targets
            .map((target) => <String, dynamic>{
                  'path': target.path,
                  'recursive': target.recursive == true,
                  'exclude': <String, dynamic>{
                    'hidden': target.exclude?.hidden == true,
                    'names': <String>[...?target.exclude?.names],
                  },
                })
            .toList(),
        if (_options.mode != null) 'mode': _options.mode!.name,
        if (_options.pollIntervalMs != null)
          'pollIntervalMs': _options.pollIntervalMs,
        if (_options.maxDirectories != null)
          'maxDirectories': _options.maxDirectories,
      },
      RequestOptions(
        signal: controller,
        onEvent: (event, payload) {
          switch (event['kind']) {
            case 'ready':
              _mode = event['mode'] == 'polling' ? 'polling' : 'native';
              if (!ready.isCompleted) ready.complete();
            case 'change':
              if (event['mode'] == 'polling') _mode = 'polling';
              if (event['overflow'] == true) {
                _deliver(_overflow);
              } else {
                _deliver(FileChangePaths(
                  (event['paths'] as List).cast<String>(),
                ));
              }
            case 'error':
              final error = FileError(
                event['code'] == 'permission_denied'
                    ? FileErrorCode.permissionDenied
                    : FileErrorCode.invalid,
                '${event['message'] ?? 'watch failed'}',
              );
              _deliver(FileChangeFailed(error));
              _stopped = true;
              controller.abort();
              if (!ready.isCompleted) ready.completeError(error);
            default:
              break;
          }
        },
      ),
    );
    _request = request.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {
        if (!ready.isCompleted) {
          ready.completeError(error, stack);
          return;
        }
        if (_stopped) return;
        if (isConnectionLost(error)) {
          unawaited(_reconnect());
          return;
        }
        _deliver(FileChangeFailed(toFileError(error)));
        _stopped = true;
      },
    );
    return ready.future;
  }

  Future<void> _reconnect() async {
    var delay = _reconnectFirstMs;
    while (!_stopped) {
      await _wait(delay);
      if (_stopped) return;
      try {
        await _start();
        _deliver(_overflow);
        return;
      } catch (error) {
        if (isConnectionLost(error)) {
          delay = delay * 2 > _reconnectMaxMs ? _reconnectMaxMs : delay * 2;
          continue;
        }
        _deliver(FileChangeFailed(toFileError(error)));
        _stopped = true;
        return;
      }
    }
  }

  Future<void> _wait(int milliseconds) {
    final completer = Completer<void>();
    final timer = Timer(Duration(milliseconds: milliseconds), () {
      _wake = null;
      if (!completer.isCompleted) completer.complete();
    });
    _wake = () {
      timer.cancel();
      _wake = null;
      if (!completer.isCompleted) completer.complete();
    };
    return completer.future;
  }
}
