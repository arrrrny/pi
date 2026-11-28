// ignore_for_file: constant_identifier_names

/// The Chord context: cancellation and the telemetry carrier.
///
/// Port of `packages/chord/src/context/index.ts` at upstream
/// `780bf31fcaeb252fa9b68df3964c735eae75bde3`, as far as the durable
/// foundation uses it.
library;

import 'dart:async';

import '../telemetry/noop.dart';
import '../telemetry/types.dart';

/// A propagation carrier: string attributes handed to a telemetry adapter.
typedef TelemetryCarrier = Map<String, String>;

/// The cancellation signal a [Context] carries.
///
/// Upstream is an `AbortSignal`; the port models the part the foundation uses:
/// whether the call was cancelled, and why.
class AbortSignal {
  /// A signal that has not been aborted.
  AbortSignal();

  /// A signal aborted by the first of [signals] to abort.
  factory AbortSignal.any(List<AbortSignal> signals) = _CombinedAbortSignal;

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

class _CombinedAbortSignal extends AbortSignal {
  _CombinedAbortSignal(List<AbortSignal> signals) {
    for (final signal in signals) {
      final remove = signal.onAbort(() => abort(signal.reason));
      if (_aborted) {
        remove();
        break;
      }
      _removers.add(remove);
    }
  }

  final List<void Function()> _removers = [];

  @override
  void abort([Object? reason]) {
    for (final remove in _removers) {
      remove();
    }
    _removers.clear();
    super.abort(reason);
  }
}

/// A typed key for one invocation-scoped value.
final class ContextKey<T> {
  /// Creates a key described by [description].
  ContextKey(this.description) : token = Object();

  /// Human-readable key description.
  final String description;

  /// Identity of this key; two keys with the same description stay distinct.
  final Object token;
}

/// Creates a typed context key.
ContextKey<T> createContextKey<T>(String description) =>
    ContextKey<T>(description);

final _telemetryContextKey = ContextKey<TelemetrySpan>('chord.telemetry');

/// Carries cancellation and a [TelemetryCarrier] through one call chain.
class Context {
  /// A context over [signal], [carrier], and typed invocation values.
  const Context({
    this.signal,
    this.carrier,
    Map<Object, Object?> values = const <Object, Object?>{},
  }) : _values = values;

  /// Cancellation of this context; absent means "never cancels".
  final AbortSignal? signal;

  /// Upstream-compatible name for [signal].
  AbortSignal? get abortSignal => signal;

  /// Propagation attributes for a telemetry adapter.
  final TelemetryCarrier? carrier;

  final Map<Object, Object?> _values;

  /// The typed value carried by [key], or null when absent.
  T? value<T>(ContextKey<T> key) => _values[key.token] as T?;

  /// The active telemetry span, or the shared no-op span.
  TelemetrySpan get telemetry =>
      value(_telemetryContextKey) ?? noopTelemetryContext;

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

  /// This context with [carrier] installed, keeping its cancellation and values.
  Context withCarrier(TelemetryCarrier carrier) =>
      Context(signal: signal, carrier: carrier, values: _values);

  /// This context with [signal] installed, keeping its carrier and values.
  Context withSignal(AbortSignal signal) =>
      Context(signal: signal, carrier: carrier, values: _values);
}

/// Derives [context] with one typed value added or replaced.
Context withContextValue<T>(
  ContextKey<T> key,
  T value,
  Context context,
) =>
    Context(
      signal: context.signal,
      carrier: context.carrier,
      values: <Object, Object?>{...context._values, key.token: value},
    );

/// Derives [context] with [telemetry] as its active span.
Context withTelemetry<T extends TelemetrySpan>(T telemetry, Context context) =>
    withContextValue(_telemetryContextKey, telemetry, context);

/// Runs [callback] in a child span of [context]'s telemetry.
Future<T> traceIn<T>(
  SpanOptions options,
  FutureOr<T> Function(Context context) callback,
  Context context,
) =>
    context.telemetry.startSpan(
      options,
      (span) => callback(withTelemetry(span, context)),
    );

/// Derives a context cancelled by either its parent signal or [signal].
Context withAbortSignal(AbortSignal signal, Context context) {
  final parent = context.signal;
  final combined =
      parent == null ? signal : AbortSignal.any(<AbortSignal>[parent, signal]);
  return Context(
      signal: combined, carrier: context.carrier, values: context._values);
}

/// Derives a context that retains values and telemetry but ignores cancellation.
Context withoutAbortSignal(Context context) =>
    Context(carrier: context.carrier, values: context._values);

/// Derives an independently cancellable child context.
({Context context, void Function([Object? reason]) cancel}) withCancel(
  Context context,
) {
  final controller = AbortSignal();
  return (
    context: withAbortSignal(controller, context),
    cancel: ([Object? reason]) => controller.abort(reason),
  );
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
const Context BACKGROUND_CONTEXT = Context.background;

/// The context for detached work that never cancels.
const Context TODO_CONTEXT = Context();

/// Backward-compatible name for [BACKGROUND_CONTEXT].
const Context backgroundContext = BACKGROUND_CONTEXT;

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
