// Generic async event stream.
//
// Port of `packages/ai/src/utils/event-stream.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b`: the FIFO event queue with
// async iteration and one final result, plus the assistant-message event
// stream that times the response it delivers.

import 'dart:async';

import 'provider_events.dart';

/// Generic event stream: [push] queues events for async iteration, a
/// complete event (per [isComplete]) resolves [result], and [end] closes the
/// stream. Events pushed before anyone listens stay queued; iteration
/// yields the backlog first, then awaits live pushes until the stream ends.
class EventStream<T, R> {
  final List<T> _queue = <T>[];
  final List<Completer<T?>> _waiters = <Completer<T?>>[];
  bool _done = false;
  final Completer<R> _finalResult = Completer<R>();
  final bool Function(T event) _isComplete;
  final R Function(T event) _extractResult;

  /// The EventStream.
  EventStream({
    required bool Function(T event) isComplete,
    required R Function(T event) extractResult,
  })  : _isComplete = isComplete,
        _extractResult = extractResult;

  /// Push one event; a complete event resolves [result]. Events pushed
  /// after [end] are dropped.
  void push(T event) {
    if (_done) return;
    if (_isComplete(event)) {
      _done = true;
      _finalResult.complete(_extractResult(event));
    }
    final waiter = _waiters.isEmpty ? null : _waiters.removeAt(0);
    if (waiter != null) {
      waiter.complete(event);
    } else {
      _queue.add(event);
    }
  }

  /// End the stream; no further events. A [result] not yet resolved is
  /// resolved with [finalResult].
  void end([R? finalResult]) {
    _done = true;
    if (finalResult != null && !_finalResult.isCompleted) {
      _finalResult.complete(finalResult);
    }
    for (final waiter in List<Completer<T?>>.from(_waiters)) {
      waiter.complete(null);
    }
    _waiters.clear();
  }

  /// Whether the stream has ended.
  bool get done => _done;

  /// The final result of the stream, resolved by the first complete event
  /// or by [end].
  Future<R> result() => _finalResult.future;

  /// Async iteration over the events: the pushed backlog first, then live
  /// pushes until [end].
  Stream<T> stream() async* {
    while (true) {
      if (_queue.isNotEmpty) {
        yield _queue.removeAt(0);
      } else if (_done) {
        return;
      } else {
        final waiter = Completer<T?>();
        _waiters.add(waiter);
        final value = await waiter.future;
        if (value == null || _done && _queue.isEmpty) {
          if (value != null) yield value;
          return;
        }
        yield value;
      }
    }
  }
}

/// One terminal assistant-message outcome an event stream can deliver: the
/// message from a `done` event, from an `error` event, or from the result
/// passed to [EventStream.end].
ProviderMessageState _extractMessage(ProviderStreamEnvelope event) =>
    event.message;

/// One event on an assistant-message event stream: a canonical stream event
/// plus the message snapshot at the moment it was pushed.
class ProviderStreamEnvelope {
  /// The event.
  final ProviderStreamEvent event;

  /// The message.
  final ProviderMessageState message;

  /// Creates a ProviderStreamEnvelope.
  ProviderStreamEnvelope(this.event, this.message);
}

/// Event stream of one assistant response. It also times the response: the
/// final message (`done` or `error` event, or the result passed to `end()`)
/// gets [ProviderMessageState.durationMs], measured with a monotonic clock
/// from the stream's creation, unless the message already has one. A stream
/// that forwards a response which started elsewhere leaves it untimed.
class AssistantMessageEventStream
    extends EventStream<ProviderStreamEnvelope, ProviderMessageState> {
  final Stopwatch _startedAt = Stopwatch()..start();

  /// The AssistantMessageEventStream.
  AssistantMessageEventStream()
      : super(
          isComplete: (event) =>
              event.event.type == 'done' || event.event.type == 'error',
          extractResult: _extractMessage,
        );

  @override
  void push(ProviderStreamEnvelope event) {
    if (event.event.type == 'done' || event.event.type == 'error') {
      _time(event.message);
    }
    super.push(event);
  }

  @override
  void end([ProviderMessageState? finalResult]) {
    if (finalResult != null) _time(finalResult);
    super.end(finalResult);
  }

  void _time(ProviderMessageState message) {
    if (done || message.durationMs != null) return;
    message.durationMs = _startedAt.elapsedMilliseconds;
  }
}

/// Factory for [AssistantMessageEventStream]
/// (`createAssistantMessageEventStream` upstream).
AssistantMessageEventStream createAssistantMessageEventStream() =>
    AssistantMessageEventStream();
