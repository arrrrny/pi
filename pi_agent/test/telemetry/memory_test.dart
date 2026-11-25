/// Differential parity tests for InMemoryTelemetryContext.
///
/// Scenarios mirror the upstream TypeScript
/// `packages/telemetry/test/{telemetry,metrics,store,propagation}.test.ts`
/// in-process cases: span nesting, error status, metric recording with context
/// association, propagation inject/extract, detached snapshots, and store
/// queries.
library;

import 'package:pi/telemetry.dart';
import 'package:test/test.dart';

void main() {
  group('spans', () {
    test('records parent/child spans and settles them', () async {
      final telemetry = InMemoryTelemetryContext();
      final result = await telemetry.startSpan(SpanOptions(name: 'operation'),
          (operation) async {
        return operation.startSpan(SpanOptions(name: 'request'),
            (request) async {
          request.setAttributes({'response': 'cached'});
          request.addEvent('checkpoint', {'phase': 'tools'});
          return 42;
        });
      });
      expect(result, 42);
      final spans = telemetry.getSpans();
      final operation = spans.firstWhere((s) => s.name == 'operation');
      final request = spans.firstWhere((s) => s.name == 'request');
      expect(operation.parentId, isNull);
      expect(request.parentId, operation.id);
      expect(operation.settled, isTrue);
      expect(request.settled, isTrue);
      // The child settles before its parent, so it has the lower end sequence.
      expect(request.endSequence, lessThan(operation.endSequence!));
    });

    test('records an error status when the callback throws', () async {
      final telemetry = InMemoryTelemetryContext();
      await expectLater(
        telemetry.startSpan(SpanOptions(name: 'boom'), (span) {
          throw StateError('kaboom');
        }),
        throwsA(isA<StateError>()),
      );
      final span = telemetry.getSpans().single;
      expect(span.status.isError, isTrue);
      expect(span.status.error?.name, 'Error');
      expect(span.status.error?.message, contains('kaboom'));
    });

    test('an explicit status is not overwritten by a thrown error', () async {
      final telemetry = InMemoryTelemetryContext();
      await expectLater(
        telemetry.startSpan(SpanOptions(name: 'explicit'), (span) {
          span.setStatus(const SpanStatus.ok());
          throw StateError('ignored');
        }),
        throwsA(isA<StateError>()),
      );
      expect(telemetry.getSpans().single.status.isError, isFalse);
    });
  });

  group('metrics', () {
    test('records counter, up/down counter and histogram with context',
        () async {
      final adapter = InMemoryTelemetryContext();
      adapter.metrics!
          .counter('network.bytes',
              const InstrumentOptions(description: 'Encoded bytes', unit: 'By'))
          .add(128, {'direction': 'out'});
      adapter.metrics!.upDownCounter('network.active').add(1);
      adapter.metrics!.upDownCounter('network.active').add(-1);
      TelemetrySpan? requestSpan;
      await adapter.startSpan(SpanOptions(name: 'request'), (span) {
        requestSpan = span;
        adapter.metrics!
            .histogram('call.duration',
                const HistogramOptions(unit: 'ms', boundaries: [1, 10, 100]))
            .record(12, {'method': 'read'}, span);
        adapter.metrics!.histogram('call.duration').record(13);
        return null;
      });
      final measurements = adapter.getMetrics();
      expect(measurements[0].kind, MetricKind.counter);
      expect(measurements[0].name, 'network.bytes');
      expect(measurements[0].description, 'Encoded bytes');
      expect(measurements[0].unit, 'By');
      expect(measurements[0].value, 128);
      expect(measurements[0].attributes['direction'], 'out');
      expect(measurements[3].kind, MetricKind.histogram);
      expect(measurements[3].boundaries, [1, 10, 100]);
      expect(measurements[3].context, isNotNull);
      expect(measurements[4].context, isNull);
      expect(requestSpan, isNotNull);
    });
  });

  group('propagation', () {
    test('extracts a parent from an injected carrier and detaches snapshots',
        () async {
      final telemetry = InMemoryTelemetryContext();
      TelemetrySpan? target;
      await telemetry.startSpan(SpanOptions(name: 'target'), (span) {
        target = span;
      });
      final original = telemetry.inject(target!);
      expect(original, isNotNull);
      final injected = telemetry.inject(target!)!;
      injected['pi-memory-span'] = '999';
      expect(telemetry.inject(target!), original);

      final parent = telemetry.extract(original);
      await parent.startSpan(SpanOptions(name: 'child'), (span) async {
        span.addLink(SpanLink(context: target!));
      });
      final spans = telemetry.getSpans();
      final child = spans.firstWhere((s) => s.name == 'child');
      expect(child.parentContext, original);
      // Same-recorder extraction keeps the local parent id.
      expect(child.parentId, isNotNull);
    });

    test('extract of an unknown carrier falls back to the root recorder',
        () async {
      final telemetry = InMemoryTelemetryContext();
      final root = telemetry.extract({
        'pi-memory-scope': 'x',
        'pi-memory-span': '1',
        'pi-memory-trace': 'y'
      });
      await root.startSpan(SpanOptions(name: 'r'), (span) async {});
      expect(telemetry.getSpans().single.parentId, isNull);
    });
  });

  group('store', () {
    test('findTraces and getTrace return settled spans grouped by trace',
        () async {
      final telemetry = InMemoryTelemetryContext();
      await telemetry.startSpan(SpanOptions(name: 'root'), (span) async {
        await span.startSpan(SpanOptions(name: 'child'), (c) async {});
      });
      final page = await telemetry.findTraces();
      expect(page.traces, hasLength(1));
      expect(page.traces.single.spans, hasLength(2));
      final traceId = page.traces.single.traceId;
      final trace = await telemetry.getTrace(traceId);
      expect(trace, isNotNull);
      expect(trace!.spans, hasLength(2));
      expect(await telemetry.getTrace('missing'), isNull);
    });

    test('findMetrics returns count-one rows filtered by name', () async {
      final telemetry = InMemoryTelemetryContext();
      telemetry.metrics!.counter('hits').add(1);
      telemetry.metrics!.counter('hits').add(2);
      final rows = await telemetry.findMetrics(const MetricQuery(name: 'hits'));
      expect(rows, hasLength(2));
      expect(rows.map((r) => r.sum).toList(), [1, 2]);
      expect(rows.every((r) => r.count == 1), isTrue);
      expect(await telemetry.findMetrics(const MetricQuery(name: 'other')),
          isEmpty);
    });
  });

  group('noop', () {
    test('noop context runs the callback and retains nothing', () async {
      final result = await noopTelemetryContext
          .startSpan(SpanOptions(name: 'x'), (span) async {
        span.addEvent('e');
        span.setAttributes({'a': 1});
        return 7;
      });
      expect(result, 7);
      expect(noopTelemetryPropagation.inject(noopTelemetryContext), isNull);
      expect(
          identical(
              noopTelemetryPropagation.extract(null), noopTelemetryContext),
          isTrue);
    });
  });
}
