/// Core telemetry contracts ported from `@earendil-works/pi-telemetry`.
///
/// Backend-neutral types for spans, traces, metrics and propagation. The
/// runtime surface mirrors the upstream `packages/telemetry/src/index.ts`
/// interfaces; the TypeScript type-level schema inference has no Dart runtime
/// equivalent and is represented by plain data classes.
library;

import 'dart:async';

import 'metrics.dart';

/// A single attribute value carried on a span, event, link or measurement.
///
/// Mirrors the upstream `AttributeValue`: a scalar or a homogeneous list of
/// scalars. `null` represents an absent attribute.
typedef AttributeValue = Object;

/// Span attributes: a map of name to [AttributeValue] (or null for absent).
typedef SpanAttributes = Map<String, AttributeValue?>;

/// Opaque, JSON-serializable adapter-owned propagation data.
typedef TelemetryCarrier = Map<String, String>;

/// The status recorded on a settled span.
///
/// Tagged union mirroring upstream `SpanStatus`: either [SpanStatus.ok] or
/// [SpanStatus.error] with an optional [SpanError].
sealed class SpanStatus {
  const SpanStatus();

  /// A successful span status.
  const factory SpanStatus.ok() = _OkStatus;

  /// An error span status, optionally carrying the error's [name]/[message].
  const factory SpanStatus.error({SpanError? error}) = _ErrorStatus;

  /// Whether this status represents an error.
  bool get isError => this is _ErrorStatus;

  /// The error details, or null for an ok status or an error without details.
  SpanError? get error => switch (this) {
        _ErrorStatus(error: final e) => e,
        _OkStatus() => null,
      };
}

final class _OkStatus extends SpanStatus {
  const _OkStatus() : super();
}

final class _ErrorStatus extends SpanStatus {
  /// The error details attached to this status, if any.
  @override
  final SpanError? error;
  const _ErrorStatus({this.error}) : super();
}

/// The name and message of an error recorded on a span.
class SpanError {
  /// Creates an error with the given [name] and [message].
  const SpanError({required this.name, required this.message});

  /// The error's type name (for example `Error`).
  final String name;

  /// The error's human-readable message.
  final String message;
}

/// A link from one span to another span, possibly in another trace.
class SpanLink {
  /// Creates a link to [context] with optional [attributes].
  const SpanLink({required this.context, this.attributes});

  /// The linked span's context carrier.
  final TelemetryContext context;

  /// Attributes describing the link.
  final SpanAttributes? attributes;
}

/// Options for starting a span.
class SpanOptions {
  /// Creates options for a span named [name].
  const SpanOptions({required this.name, this.attributes, this.links});

  /// The span's name.
  final String name;

  /// Attributes set at span start.
  final SpanAttributes? attributes;

  /// Links to other spans established at start.
  final List<SpanLink>? links;
}

/// A settled span snapshot, independent of the recording adapter.
///
/// Mirrors upstream `StoredSpan`. Times are milliseconds at microsecond
/// resolution; event times are relative to span start.
class StoredSpan {
  /// Creates a stored span snapshot.
  const StoredSpan({
    required this.id,
    required this.traceId,
    this.parentId,
    required this.name,
    required this.startedMs,
    required this.endedMs,
    required this.attributes,
    required this.events,
    required this.links,
    required this.status,
  });

  /// The span's globally unique id within its store.
  final String id;

  /// The trace this span belongs to.
  final String traceId;

  /// The parent span's id, absent for roots.
  final String? parentId;

  /// The span's name.
  final String name;

  /// Wall-clock milliseconds since the epoch at span start.
  final num startedMs;

  /// Wall-clock milliseconds since the epoch at span end.
  final num endedMs;

  /// Attributes recorded on the span.
  final SpanAttributes attributes;

  /// Events recorded on the span.
  final List<StoredEvent> events;

  /// Links recorded on the span.
  final List<StoredLink> links;

  /// The span's settled status.
  final SpanStatus status;
}

/// An event recorded on a span, with a time relative to span start.
class StoredEvent {
  /// Creates a stored event.
  const StoredEvent({
    required this.name,
    required this.timeMs,
    required this.attributes,
  });

  /// The event's name.
  final String name;

  /// Milliseconds from span start to the event, at microsecond resolution.
  final num timeMs;

  /// Attributes recorded on the event.
  final SpanAttributes attributes;
}

/// A link as stored on a settled span, resolved to trace/span ids.
class StoredLink {
  /// Creates a stored link.
  const StoredLink({
    required this.traceId,
    required this.spanId,
    this.attributes,
  });

  /// The linked span's trace id.
  final String traceId;

  /// The linked span's id.
  final String spanId;

  /// Attributes describing the link.
  final SpanAttributes? attributes;
}

/// A trace: a set of spans sharing a trace id.
class StoredTrace {
  /// Creates a stored trace.
  const StoredTrace({required this.traceId, required this.spans});

  /// The trace's id.
  final String traceId;

  /// The trace's spans, in start order.
  final List<StoredSpan> spans;
}

/// A query for stored traces.
class TraceQuery {
  /// Creates a trace query. All fields are optional filters.
  const TraceQuery({
    this.name,
    this.attributes,
    this.errors,
    this.startMin,
    this.startMax,
    this.limit,
    this.cursor,
  });

  /// Match traces whose earliest span has this name.
  final String? name;

  /// Match traces with a span whose attributes equal all entries.
  final Map<String, Object>? attributes;

  /// Match traces containing at least one error span.
  final bool? errors;

  /// Inclusive lower bound on the earliest span's start time.
  final num? startMin;

  /// Inclusive upper bound on the earliest span's start time.
  final num? startMax;

  /// Positive page size; defaults to 20.
  final int? limit;

  /// Opaque continuation token from a previous page.
  final String? cursor;
}

/// A query for stored metrics.
class MetricQuery {
  /// Creates a metric query filtered by [name] and optional bounds.
  const MetricQuery({
    required this.name,
    this.startMin,
    this.startMax,
    this.attributes,
  });

  /// The metric name to match.
  final String name;

  /// Inclusive lower bound on interval start time.
  final num? startMin;

  /// Inclusive upper bound on interval start time.
  final num? startMax;

  /// Match measurements whose attributes equal all entries.
  final Map<String, Object>? attributes;
}

/// A stored metric: a count-one measurement row.
///
/// Mirrors upstream `StoredMetric`.
class StoredMetric {
  /// Creates a stored metric row.
  const StoredMetric({
    required this.intervalMs,
    required this.name,
    required this.kind,
    this.unit,
    required this.attributes,
    required this.count,
    required this.sum,
    required this.min,
    required this.max,
  });

  /// The interval start time, in milliseconds since the epoch.
  final num intervalMs;

  /// The metric's name.
  final String name;

  /// The instrument kind that produced this row.
  final MetricKind kind;

  /// The metric's unit, if declared.
  final String? unit;

  /// Attributes recorded on the measurement.
  final SpanAttributes attributes;

  /// The number of measurements aggregated (always 1 for a raw row).
  final int count;

  /// The sum of measurements (the value for a count-one row).
  final num sum;

  /// The minimum measurement (the value for a count-one row).
  final num min;

  /// The maximum measurement (the value for a count-one row).
  final num max;
}

/// The kind of a metric instrument.
enum MetricKind {
  /// A monotonically increasing counter.
  counter,

  /// A counter that may go up or down.
  upDownCounter,

  /// A distribution recorder.
  histogram,
}

/// Read settled traces and metrics without depending on a storage backend.
abstract interface class TelemetryStore {
  /// Finds traces matching [query], returning a page and optional cursor.
  Future<({List<StoredTrace> traces, String? cursor})> findTraces(
      [TraceQuery query = const TraceQuery()]);

  /// Gets a single trace by [traceId], or null if absent.
  Future<StoredTrace?> getTrace(String traceId);

  /// Finds raw metric rows matching [query].
  Future<List<StoredMetric>> findMetrics(MetricQuery query);
}

/// Adapter contract for trusted typed inputs.
///
/// Malformed input behavior is unspecified, matching upstream.
abstract interface class TelemetryContext {
  /// The metrics capability available on this context and its children.
  TelemetryMetrics? get metrics;

  /// The propagation capability available on this context and its children.
  TelemetryPropagation? get propagation;

  /// Starts a span named by [options], invoking [callback] with the span.
  Future<T> startSpan<T>(
    SpanOptions options,
    FutureOr<T> Function(TelemetrySpan span) callback,
  );
}

/// A span that is also a context, with mutation methods.
///
/// Mirrors upstream `TelemetrySpan extends TelemetryContext`.
abstract interface class TelemetrySpan implements TelemetryContext {
  /// Adds a link to another span.
  void addLink(SpanLink link);

  /// Records an event with optional [attributes].
  void addEvent(String name, [SpanAttributes? attributes]);

  /// Merges [attributes] into the span's attributes.
  void setAttributes(SpanAttributes attributes);

  /// Sets the span's status.
  void setStatus(SpanStatus status);
}

/// Optional transport capability implemented by a telemetry adapter.
abstract interface class TelemetryPropagation {
  /// Injects the context's carrier, or null if it has none.
  TelemetryCarrier? inject(TelemetryContext context);

  /// Extracts a context from a carrier; absent/unknown carriers use the root.
  TelemetryContext extract(TelemetryCarrier? carrier);
}