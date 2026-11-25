/// In-memory telemetry recorder.
///
/// Port of upstream `packages/telemetry/src/memory.ts`:
/// `InMemoryTelemetryContext` records spans and measurements in process memory
/// and reads them back through the [TelemetryStore] contract. Times are
/// wall-clock milliseconds at microsecond resolution from [telemetryNow].
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'metrics.dart';
import 'noop.dart';
import 'types.dart';

/// A recorded event on a span, before settlement.
class RecordedTelemetryEvent {
  /// Creates a recorded event.
  const RecordedTelemetryEvent({required this.name, required this.attributes});

  /// The event's name.
  final String name;

  /// The event's attributes.
  final SpanAttributes attributes;
}

/// A recorded link on a span, before settlement.
class RecordedTelemetryLink {
  /// Creates a recorded link.
  const RecordedTelemetryLink({required this.context, required this.attributes});

  /// The linked span's context carrier.
  final TelemetryCarrier context;

  /// The link's attributes.
  final SpanAttributes attributes;
}

/// A recorded span snapshot, before settlement is reflected.
class RecordedTelemetrySpan {
  /// Creates a recorded span snapshot.
  const RecordedTelemetrySpan({
    required this.id,
    required this.parentId,
    required this.context,
    required this.parentContext,
    required this.links,
    required this.name,
    required this.attributes,
    required this.events,
    required this.status,
    required this.settled,
    this.endSequence,
  });

  /// The span's local id.
  final int id;

  /// The local parent id, or null for roots and external parents.
  final int? parentId;

  /// The span's context carrier.
  final TelemetryCarrier context;

  /// The parent's context carrier, or null.
  final TelemetryCarrier? parentContext;

  /// Links recorded on the span.
  final List<RecordedTelemetryLink> links;

  /// The span's name.
  final String name;

  /// The span's attributes.
  final SpanAttributes attributes;

  /// Events recorded on the span.
  final List<RecordedTelemetryEvent> events;

  /// The span's status.
  final SpanStatus status;

  /// Whether the span has settled.
  final bool settled;

  /// The settlement order, set once settled.
  final int? endSequence;
}

/// A recorded measurement, before aggregation.
class RecordedTelemetryMeasurement {
  /// Creates a recorded measurement.
  const RecordedTelemetryMeasurement({
    required this.kind,
    required this.name,
    this.description,
    this.unit,
    this.boundaries,
    required this.value,
    required this.attributes,
    required this.context,
  });

  /// The instrument kind.
  final MetricKind kind;

  /// The metric name.
  final String name;

  /// The metric description, if declared.
  final String? description;

  /// The metric unit, if declared.
  final String? unit;

  /// Histogram bucket boundaries, if declared.
  final List<num>? boundaries;

  /// The recorded value.
  final num value;

  /// The measurement's attributes.
  final SpanAttributes attributes;

  /// The context carrier the measurement was associated with, or null.
  final TelemetryCarrier? context;
}

final class _MutableEvent {
  _MutableEvent(this.name, this.timeMs, this.attributes);
  String name;
  num timeMs;
  SpanAttributes attributes;
}

final class _MutableSpan {
  _MutableSpan({
    required this.startedMs,
    required this.clock,
    required this.id,
    required this.parentId,
    required this.context,
    required this.parentContext,
    required this.links,
    required this.name,
    required this.attributes,
    required this.events,
    required this.status,
    required this.explicitStatus,
    required this.settled,
  });

  num startedMs;
  num clock;
  num? endedMs;
  final int id;
  final int? parentId;
  TelemetryCarrier context;
  TelemetryCarrier? parentContext;
  List<RecordedTelemetryLink> links;
  String name;
  SpanAttributes attributes;
  List<_MutableEvent> events;
  SpanStatus status;
  bool explicitStatus;
  bool settled;
  int? endSequence;
}

final class _InMemoryParent {
  _InMemoryParent(this.context, this.localId, this.span);
  final TelemetryCarrier context;
  final int? localId;
  final _MutableSpan? span;
}

final class _Measurement {
  _Measurement(this.intervalMs, this.measurement);
  final num intervalMs;
  final RecordedTelemetryMeasurement measurement;
}

String _carrierId(TelemetryCarrier carrier) =>
    '${carrier['pi-memory-scope']}:${carrier['pi-memory-span']}';

final math.Random _rng = math.Random();

num _nowClock() => DateTime.now().millisecondsSinceEpoch;

/// Now as milliseconds since the epoch, rounded to the microsecond.
///
/// Mirrors upstream `telemetryNow`: wall-clock milliseconds at microsecond
/// resolution. Every adapter stamps span starts with it so their times agree.
num telemetryNow() {
  final ms = DateTime.now().millisecondsSinceEpoch;
  return (ms * 1000).round() / 1000;
}

SpanAttributes _copyAttributes(SpanAttributes? attributes) {
  final result = <String, AttributeValue?>{};
  if (attributes == null) return result;
  attributes.forEach((name, value) {
    if (value == null) return;
    result[name] = value is List ? [...value] : value;
  });
  return result;
}

RecordedTelemetryLink? _copyLink(TelemetryContext context, SpanLink link,
    Expando<TelemetryCarrier> carriers) {
  final carrier = carriers[link.context];
  if (carrier == null) return null;
  return RecordedTelemetryLink(
    context: Map<String, String>.of(carrier),
    attributes: _copyAttributes(link.attributes),
  );
}

SpanStatus _copyStatus(SpanStatus status) {
  if (!status.isError) return const SpanStatus.ok();
  final e = status.error;
  return e == null
      ? const SpanStatus.error()
      : SpanStatus.error(error: SpanError(name: e.name, message: e.message));
}

/// Backend-neutral reference recorder that keeps spans and measurements in
/// process memory. Create a fresh instance to isolate tests or scopes.
class InMemoryTelemetryContext
    implements TelemetryContext, TelemetryPropagation, TelemetryMetrics, TelemetryStore {
  /// Creates an empty in-memory recorder with a fresh scope.
  InMemoryTelemetryContext() : _scope = _newScope();

  static String _newScope() {
    final r = _rng;
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return hex;
  }

  final String _scope;
  final List<_MutableSpan> _spans = [];
  final List<_Measurement> _measurements = [];
  int _nextSpanId = 1;
  int _nextEndSequence = 1;
  final Expando<TelemetryCarrier> _carriers = Expando<TelemetryCarrier>();

  @override
  TelemetryMetrics get metrics => this;
  @override
  TelemetryPropagation get propagation => this;

  _MutableSpan _createSpan(_InMemoryParent? parent, SpanOptions options) {
    final attributes = _copyAttributes(options.attributes);
    final links = <RecordedTelemetryLink>[];
    for (final link in options.links ?? const <SpanLink>[]) {
      final copy = _copyLink(this, link, _carriers);
      if (copy != null) links.add(copy);
    }
    final id = _nextSpanId++;
    final traceId = parent?.context['pi-memory-trace'] ?? '$_scope:$id';
    return _MutableSpan(
      startedMs: telemetryNow(),
      clock: _nowClock(),
      id: id,
      parentId: parent?.localId,
      context: {
        'pi-memory-scope': _scope,
        'pi-memory-span': '$id',
        'pi-memory-trace': traceId,
      },
      parentContext: parent == null ? null : Map<String, String>.of(parent.context),
      links: links,
      name: options.name,
      attributes: attributes,
      events: [],
      status: const SpanStatus.ok(),
      explicitStatus: false,
      settled: false,
    );
  }

  Future<T> _startInertSpan<T>(
      SpanOptions options, FutureOr<T> Function(TelemetrySpan span) callback) {
    return noopTelemetryContext.startSpan(options, (span) {
      final inert = _InertSpan(this);
      return callback(inert);
    });
  }

  Future<T> _startSpan<T>(_InMemoryParent? parent, SpanOptions options,
      FutureOr<T> Function(TelemetrySpan span) callback) async {
    if (parent?.span?.settled ?? false) {
      return _startInertSpan(options, callback);
    }
    final recorded = _createSpan(parent, options);
    _spans.add(recorded);
    final span = _MemorySpan(this, recorded);
    _carriers[span] = recorded.context;
    try {
      return await callback(span);
    } catch (error) {
      if (!recorded.explicitStatus) {
        recorded.status = error is Error
            ? SpanStatus.error(
                error: SpanError(
                    name: 'Error', message: error.toString()))
            : const SpanStatus.error();
      }
      rethrow;
    } finally {
      recorded.settled = true;
      recorded.endedMs =
          ((recorded.startedMs + (_nowClock() - recorded.clock)) * 1000).round() / 1000;
      recorded.endSequence = _nextEndSequence++;
    }
  }

  @override
  Future<T> startSpan<T>(SpanOptions options,
      FutureOr<T> Function(TelemetrySpan span) callback) =>
      _startSpan<T>(null, options, callback);

  @override
  TelemetryCarrier? inject(TelemetryContext context) {
    final carrier = _carriers[context];
    return carrier == null ? null : Map<String, String>.of(carrier);
  }

  @override
  TelemetryContext extract(TelemetryCarrier? carrier) {
    final scope = carrier?['pi-memory-scope'];
    final span = carrier?['pi-memory-span'];
    final traceId = carrier?['pi-memory-trace'];
    if (scope == null || span == null || traceId == null) return this;
    final context = {
      'pi-memory-scope': scope,
      'pi-memory-span': span,
      'pi-memory-trace': traceId,
    };
    final localId = scope == _scope ? int.tryParse(span) : null;
    final parent = _ExtractedContext(this, context, localId);
    _carriers[parent] = context;
    return parent;
  }

  void _record(num value, MetricKind kind, String name,
      InstrumentOptions? options, SpanAttributes? attributes,
      [TelemetryContext? context]) {
    final carrier = context == null ? null : _carriers[context];
    final description = options?.description;
    final unit = options?.unit;
    final boundaries =
        kind == MetricKind.histogram && options is HistogramOptions && options.boundaries != null
            ? [...options.boundaries!]
            : null;
    _measurements.add(_Measurement(
      (DateTime.now().millisecondsSinceEpoch ~/ 10000) * 10000,
      RecordedTelemetryMeasurement(
        kind: kind,
        name: name,
        description: description,
        unit: unit,
        boundaries: boundaries,
        value: value,
        attributes: _copyAttributes(attributes),
        context: carrier == null ? null : Map<String, String>.of(carrier),
      ),
    ));
  }

  @override
  TelemetryCounter counter(String name, [InstrumentOptions? options]) =>
      _Counter(this, MetricKind.counter, name, options);

  @override
  TelemetryUpDownCounter upDownCounter(String name, [InstrumentOptions? options]) =>
      _Counter(this, MetricKind.upDownCounter, name, options);

  @override
  TelemetryHistogram histogram(String name, [HistogramOptions? options]) =>
      _Histogram(this, name, options);

  List<StoredSpan> _storedSpans() {
    final result = <StoredSpan>[];
    for (final span in _spans) {
      if (!span.settled) continue;
      final ended = span.endedMs;
      if (ended == null) continue;
      result.add(StoredSpan(
        id: _carrierId(span.context),
        traceId: span.context['pi-memory-trace']!,
        parentId: span.parentContext == null ? null : _carrierId(span.parentContext!),
        name: span.name,
        startedMs: span.startedMs,
        endedMs: ended,
        attributes: _copyAttributes(span.attributes),
        events: [
          for (final e in span.events)
            StoredEvent(
                name: e.name, timeMs: e.timeMs, attributes: _copyAttributes(e.attributes)),
        ],
        links: [
          for (final l in span.links)
            StoredLink(
              traceId: l.context['pi-memory-trace']!,
              spanId: _carrierId(l.context),
              attributes: _copyAttributes(l.attributes),
            ),
        ],
        status: _copyStatus(span.status),
      ));
    }
    result.sort((a, b) {
      final byStart = a.startedMs.compareTo(b.startedMs);
      if (byStart != 0) return byStart;
      return a.id.compareTo(b.id);
    });
    return result;
  }

  @override
  Future<StoredTrace?> getTrace(String traceId) async {
    final spans = _storedSpans().where((s) => s.traceId == traceId).toList();
    return spans.isEmpty ? null : StoredTrace(traceId: traceId, spans: spans);
  }

  @override
  Future<({List<StoredTrace> traces, String? cursor})> findTraces(
      [TraceQuery query = const TraceQuery()]) async {
    final limit = query.limit ?? 20;
    List<Object>? after;
    if (query.cursor != null) {
      final decoded = jsonDecode(query.cursor!) as List<Object?>;
      after = [decoded[0]! , decoded[1]!];
    }
    final grouped = <String, StoredTrace>{};
    for (final span in _storedSpans()) {
      grouped.putIfAbsent(span.traceId, () => StoredTrace(traceId: span.traceId, spans: []));
      grouped[span.traceId]!.spans.add(span);
    }
    final matches = grouped.values.where((trace) {
      final first = trace.spans.first;
      if (query.name != null && first.name != query.name) return false;
      if (query.startMin != null && first.startedMs < query.startMin!) return false;
      if (query.startMax != null && first.startedMs > query.startMax!) return false;
      if (after != null) {
        final a = after[0] as num;
        final b = after[1] as String;
        if (!(first.startedMs < a || (first.startedMs == a && trace.traceId.compareTo(b) > 0))) {
          return false;
        }
      }
      if (query.errors == true && !trace.spans.any((s) => s.status.isError)) return false;
      final attrs = query.attributes;
      if (attrs != null) {
        final ok = trace.spans.any((span) => attrs.entries.every(
            (e) => _attrEquals(span.attributes[e.key], e.value)));
        if (!ok) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final byStart = b.spans.first.startedMs.compareTo(a.spans.first.startedMs);
        if (byStart != 0) return byStart;
        return a.traceId.compareTo(b.traceId);
      });
    final page = matches.take(limit).toList();
    String? cursor;
    if (matches.length > limit && page.isNotEmpty) {
      final last = page.last;
      cursor = jsonEncode([last.spans.first.startedMs, last.traceId]);
    }
    return (traces: page, cursor: cursor);
  }

  @override
  Future<List<StoredMetric>> findMetrics(MetricQuery query) async {
    return _measurements
        .where((m) =>
            m.measurement.name == query.name &&
            (query.startMin == null || m.intervalMs >= query.startMin!) &&
            (query.startMax == null || m.intervalMs <= query.startMax!) &&
            (query.attributes == null ||
                query.attributes!.entries.every((e) =>
                    _attrEquals(m.measurement.attributes[e.key], e.value))))
        .map((m) => StoredMetric(
              intervalMs: m.intervalMs,
              name: m.measurement.name,
              kind: m.measurement.kind,
              unit: m.measurement.unit,
              attributes: _copyAttributes(m.measurement.attributes),
              count: 1,
              sum: m.measurement.value,
              min: m.measurement.value,
              max: m.measurement.value,
            ))
        .toList();
  }

  /// Returns detached measurements in recording order, without aggregation.
  List<RecordedTelemetryMeasurement> getMetrics() => [
        for (final m in _measurements)
          RecordedTelemetryMeasurement(
            kind: m.measurement.kind,
            name: m.measurement.name,
            description: m.measurement.description,
            unit: m.measurement.unit,
            boundaries: m.measurement.boundaries == null
                ? null
                : [...m.measurement.boundaries!],
            value: m.measurement.value,
            attributes: _copyAttributes(m.measurement.attributes),
            context: m.measurement.context == null
                ? null
                : Map<String, String>.of(m.measurement.context!),
          ),
      ];

  /// Returns detached snapshots in span-start order.
  List<RecordedTelemetrySpan> getSpans() => [
        for (final span in _spans)
          RecordedTelemetrySpan(
            id: span.id,
            parentId: span.parentId,
            context: Map<String, String>.of(span.context),
            parentContext: span.parentContext == null
                ? null
                : Map<String, String>.of(span.parentContext!),
            links: [
              for (final l in span.links)
                RecordedTelemetryLink(
                    context: Map<String, String>.of(l.context),
                    attributes: _copyAttributes(l.attributes)),
            ],
            name: span.name,
            attributes: _copyAttributes(span.attributes),
            events: [
              for (final e in span.events)
                RecordedTelemetryEvent(
                    name: e.name, attributes: _copyAttributes(e.attributes)),
            ],
            status: _copyStatus(span.status),
            settled: span.settled,
            endSequence: span.endSequence,
          ),
      ];
}

bool _attrEquals(AttributeValue? a, Object b) {
  if (a is List) {
    return b is List && _listEquals(a, b);
  }
  return a == b;
}

bool _listEquals(List<Object?> a, List<Object?> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

final class _Counter implements TelemetryCounter, TelemetryUpDownCounter {
  _Counter(this._ctx, this._kind, this._name, this._options);
  final InMemoryTelemetryContext _ctx;
  final MetricKind _kind;
  final String _name;
  final InstrumentOptions? _options;
  @override
  void add(num value, [SpanAttributes? attributes]) =>
      _ctx._record(value, _kind, _name, _options, attributes);
}

final class _Histogram implements TelemetryHistogram {
  _Histogram(this._ctx, this._name, this._options);
  final InMemoryTelemetryContext _ctx;
  final String _name;
  final HistogramOptions? _options;
  @override
  void record(num value, [SpanAttributes? attributes, TelemetryContext? context]) =>
      _ctx._record(value, MetricKind.histogram, _name, _options, attributes, context);
}

final class _MemorySpan implements TelemetrySpan {
  _MemorySpan(this._ctx, this._span);
  final InMemoryTelemetryContext _ctx;
  final _MutableSpan _span;

  @override
  TelemetryMetrics? get metrics => _ctx.metrics;
  @override
  TelemetryPropagation? get propagation => _ctx.propagation;

  @override
  Future<T> startSpan<T>(SpanOptions options,
          FutureOr<T> Function(TelemetrySpan span) callback) =>
      _ctx._startSpan<T>(_InMemoryParent(_span.context, _span.id, _span), options, callback);

  @override
  void addLink(SpanLink link) {
    if (_span.settled) return;
    final copy = _copyLink(this, link, _ctx._carriers);
    if (copy != null) _span.links.add(copy);
  }

  @override
  void addEvent(String name, [SpanAttributes? attributes]) {
    if (_span.settled) return;
    _span.events.add(_MutableEvent(
      name,
      (_nowClock() - _span.clock),
      _copyAttributes(attributes),
    ));
  }

  @override
  void setAttributes(SpanAttributes attributes) {
    if (_span.settled) return;
    _span.attributes = {..._span.attributes, ..._copyAttributes(attributes)};
  }

  @override
  void setStatus(SpanStatus status) {
    if (_span.settled) return;
    _span.status = _copyStatus(status);
    _span.explicitStatus = true;
  }
}

final class _InertSpan implements TelemetrySpan {
  _InertSpan(this._ctx);
  final InMemoryTelemetryContext _ctx;
  @override
  TelemetryMetrics? get metrics => _ctx.metrics;
  @override
  TelemetryPropagation? get propagation => _ctx.propagation;
  @override
  Future<T> startSpan<T>(SpanOptions options,
          FutureOr<T> Function(TelemetrySpan span) callback) =>
      _ctx._startInertSpan<T>(options, callback);
  @override
  void addLink(SpanLink link) {}
  @override
  void addEvent(String name, [SpanAttributes? attributes]) {}
  @override
  void setAttributes(SpanAttributes attributes) {}
  @override
  void setStatus(SpanStatus status) {}
}

final class _ExtractedContext implements TelemetryContext {
  _ExtractedContext(this._ctx, this._context, this._localId);
  final InMemoryTelemetryContext _ctx;
  final TelemetryCarrier _context;
  final int? _localId;
  @override
  TelemetryMetrics? get metrics => _ctx.metrics;
  @override
  TelemetryPropagation? get propagation => _ctx.propagation;
  @override
  Future<T> startSpan<T>(SpanOptions options,
          FutureOr<T> Function(TelemetrySpan span) callback) =>
      _ctx._startSpan<T>(_InMemoryParent(_context, _localId, null), options, callback);
}