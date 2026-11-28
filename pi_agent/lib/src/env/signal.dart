import 'dart:typed_data';

import '../chord/context.dart';
import 'connection.dart' as wire;

/// Bridges a Durable abort signal to the daemon transport's signal.
class RequestSignal {
  /// Creates a bridge that follows [source].
  RequestSignal(this.source) {
    final source = this.source;
    if (source == null) return;
    if (source.aborted) {
      controller.abort();
    } else {
      _remove = source.onAbort(controller.abort);
    }
  }

  /// The caller's signal, when present.
  final AbortSignal? source;

  /// The signal understood by [wire.Connection].
  final wire.AbortSignal controller = wire.AbortSignal();
  void Function()? _remove;

  /// Aborts both the transport request and its source bridge.
  void abort() => controller.abort();

  /// Removes the listener attached to [source].
  void dispose() {
    _remove?.call();
    _remove = null;
  }
}

/// Calls [wire.Connection.info] with a Durable abort signal.
Future<wire.RemoteInfo> infoWithSignal(
  wire.Connection connection,
  AbortSignal? signal,
) async {
  final request = RequestSignal(signal);
  try {
    return await connection.info(request.controller);
  } finally {
    request.dispose();
  }
}

/// Calls [wire.Connection.request] with a Durable abort signal.
Future<wire.Reply> requestWithSignal(
  wire.Connection connection,
  String op,
  Map<String, dynamic> json, {
  AbortSignal? signal,
  Uint8List? payload,
  void Function(Map<String, dynamic>, Uint8List)? onEvent,
  void Function(int, int)? onStart,
  int? session,
}) async {
  final request = RequestSignal(signal);
  try {
    return await connection.request(
      op,
      json,
      wire.RequestOptions(
        payload: payload,
        signal: request.controller,
        onEvent: onEvent,
        onStart: onStart,
        session: session,
      ),
    );
  } finally {
    request.dispose();
  }
}
