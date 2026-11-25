/// No-op telemetry context, metrics and propagation.
///
/// Port of upstream `packages/telemetry/src/noop.ts`: shared instances whose
/// methods never inspect or retain their inputs.
library;

import 'dart:async';

import 'types.dart';
import 'metrics.dart';

final _noopCounter = _NoopCounter();
final _noopUpDownCounter = _NoopUpDownCounter();
final _noopHistogram = _NoopHistogram();

final class _NoopCounter implements TelemetryCounter {
  @override
  void add(num value, [SpanAttributes? attributes]) {}
}

final class _NoopUpDownCounter implements TelemetryUpDownCounter {
  @override
  void add(num value, [SpanAttributes? attributes]) {}
}

final class _NoopHistogram implements TelemetryHistogram {
  @override
  void record(num value, [SpanAttributes? attributes, TelemetryContext? context]) {}
}

/// Shared metrics whose instruments never retain metadata or measurements.
final TelemetryMetrics noopTelemetryMetrics = _NoopMetrics();

final class _NoopMetrics implements TelemetryMetrics {
  @override
  TelemetryCounter counter(String name, [InstrumentOptions? options]) =>
      _noopCounter;
  @override
  TelemetryUpDownCounter upDownCounter(String name, [InstrumentOptions? options]) =>
      _noopUpDownCounter;
  @override
  TelemetryHistogram histogram(String name, [HistogramOptions? options]) =>
      _noopHistogram;
}

/// Shared propagation that neither inspects nor retains its inputs.
final TelemetryPropagation noopTelemetryPropagation = _NoopPropagation();

final class _NoopPropagation implements TelemetryPropagation {
  @override
  TelemetryCarrier? inject(TelemetryContext context) => null;
  @override
  TelemetryContext extract(TelemetryCarrier? carrier) => noopTelemetryContext;
}

/// Shared telemetry context used when an application does not provide one.
final TelemetrySpan noopTelemetryContext = _NoopSpan();

final class _NoopSpan implements TelemetrySpan {
  @override
  TelemetryMetrics? get metrics => noopTelemetryMetrics;
  @override
  TelemetryPropagation? get propagation => noopTelemetryPropagation;
  @override
  Future<T> startSpan<T>(
    SpanOptions options,
    FutureOr<T> Function(TelemetrySpan span) callback,
  ) =>
      Future<T>.sync(() => callback(noopTelemetryContext));
  @override
  void addLink(SpanLink link) {}
  @override
  void addEvent(String name, [SpanAttributes? attributes]) {}
  @override
  void setAttributes(SpanAttributes attributes) {}
  @override
  void setStatus(SpanStatus status) {}
}