/// The Chord context: cancellation and the telemetry carrier.
///
/// Port of `packages/chord/src/context/index.ts` at upstream
/// `780bf31fcaeb252fa9b68df3964c735eae75bde3`, as far as the durable
/// foundation uses it.
library;

import 'dart:async';

/// A propagation carrier: string attributes handed to a telemetry adapter.
typedef TelemetryCarrier = Map<String, String>;

/// The cancellation signal a [Context] carries.
///
/// Upstream is an `AbortSignal`; the port models the part the foundation uses:
/// whether the call was cancelled, and why.
class AbortSignal {
  /// A signal that has not been aborted.
  AbortSignal();

  bool _aborted = false;
  Object? _reason;
  final List<void Function()> _listeners = <void Function()>[];

  /// Whether the signal is aborted.
  bool get aborted => _aborted;

  /// Why the signal was aborted; absent while it is not.
  Object? get reason => _reason;

  /// Abort the signal. Idempotent: the first reason wins and listeners run once.
  void abort([Object? reason]) {
    if (_aborted) return;
    _aborted = true;
    _reason = reason;
    final listeners = List<void Function()>.of(_listeners);
    _listeners.clear();
    for (final listener in listeners) {
      listener();
    }
  }

  /// Register [listener] for the abort; returns how to remove it.
  void Function() onAbort(void Function() listener) {
    if (_aborted) {
      listener();
      return () {};
    }
    _listeners.add(listener);
    return () {
      _listeners.remove(listener);
    };
  }
}

/// Carries cancellation and a [TelemetryCarrier] through one call chain.
class Context {
  /// A context over [signal] and [carrier].
  /// A context over [signal] and [carrier].
  /// A context over [signal] and [carrier].
  const Context({this.signal, this.carrier});

  /// Cancellation of this context; absent means "never cancels".
  final AbortSignal? signal;

  /// Propagation attributes for a telemetry adapter.
  final TelemetryCarrier? carrier;

  /// Whether this context was cancelled.
  bool get aborted => signal?.aborted ?? false;

  /// The cancellation reason; absent while not cancelled.
  Object? get abortReason => signal?.reason;

  /// A context that never cancels and carries nothing.
  static const Context background = Context();

  /// Throw the abort reason when this context was cancelled.
  void throwIfAborted() {
    final signal = this.signal;
    if (signal == null || !signal.aborted) return;
    throw AbortException(signal.reason);
  }

  /// This context with [carrier] installed, keeping its cancellation.
  Context withCarrier(TelemetryCarrier carrier) =>
      Context(signal: signal, carrier: carrier);

  /// This context with [signal] installed, keeping its carrier.
  Context withSignal(AbortSignal signal) =>
      Context(signal: signal, carrier: carrier);
}

/// Thrown when a call observes that its context was cancelled.
class AbortException implements Exception {
  /// Why the call was cancelled.
  const AbortException(this.reason);

  /// The cancellation reason, when the aborter gave one.
  final Object? reason;

  @override
  String toString() => 'AbortException(${reason ?? 'aborted'})';
}

/// The context a background call runs under: never cancelled, no carrier.
const Context backgroundContext = Context.background;

/// Await [future], failing with an [AbortException] as soon as [context] is
/// cancelled.
///
/// Cancelling the caller's context only cancels that call; it does not cancel
/// work already admitted elsewhere.
Future<T> awaitWithContext<T>(Future<T> future, Context context) {
  final signal = context.signal;
  if (signal == null) return future;
  if (signal.aborted) {
    return Future<T>.error(AbortException(signal.reason));
  }
  final completer = Completer<T>();
  void complete(FutureOr<T> Function() action,
      [Object? error, StackTrace? stackTrace]) {
    if (completer.isCompleted) return;
    if (error != null) {
      completer.completeError(error, stackTrace);
    } else {
      try {
        completer.complete(action());
      } catch (throwError, throwStack) {
        completer.completeError(throwError, throwStack);
      }
    }
  }

  final remove = signal
      .onAbort(() => complete(() => null as T, AbortException(signal.reason)));
  future.then(
    (value) {
      remove();
      complete(() => value);
    },
    onError: (Object error, StackTrace stackTrace) {
      remove();
      complete(() => null as T, error, stackTrace);
    },
  );
  return completer.future;
}
