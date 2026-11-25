/// Differential parity tests for renderTrace.
///
/// The expected strings are copied verbatim from the upstream TypeScript
/// `packages/telemetry/test/render.test.ts` suite, so a passing run proves the
/// Dart port renders byte-identical output to the TypeScript oracle.
library;

import 'package:pi/telemetry.dart';
import 'package:test/test.dart';

StoredSpan _span(String id,
    {String? name,
    num? startedMs,
    num? endedMs,
    SpanStatus? status,
    List<StoredEvent>? events,
    List<StoredLink>? links,
    SpanAttributes? attributes,
    String? traceId,
    String? parentId}) {
  return StoredSpan(
    id: id,
    traceId: traceId ?? 'trace',
    parentId: parentId,
    name: name ?? id,
    startedMs: startedMs ?? 0,
    endedMs: endedMs ?? 10,
    attributes: attributes ?? {},
    events: events ?? [],
    links: links ?? [],
    status: status ?? const SpanStatus.ok(),
  );
}

void main() {
  group('renderTrace', () {
    test(
        'renders an unordered trace with attributes, durations, errors, events, and links',
        () {
      final root = _span('root', startedMs: 1000, endedMs: 1020, attributes: {
        'request': 'a b',
        'attempt': 2,
        'cached': false,
        'tags': ['a', 'b'],
        'sizes': [1, 2],
        'flags': [true, false],
      }, events: [
        const StoredEvent(
            name: 'checkpoint', timeMs: 2, attributes: {'phase': 'tools'}),
        const StoredEvent(name: 'tick', timeMs: 3.5, attributes: {}),
      ], links: [
        const StoredLink(
            traceId: 'remote-trace',
            spanId: 'remote',
            attributes: {'reason': 'steer'}),
        const StoredLink(traceId: 'other-trace', spanId: 'other'),
      ]);
      final first = _span('first',
          parentId: 'root',
          startedMs: 1005,
          endedMs: 1009.5,
          status: const SpanStatus.error(
              error: SpanError(name: 'Error', message: 'failed call')));
      final nested =
          _span('nested', parentId: 'first', startedMs: 1006, endedMs: 1007);
      final second = _span('second',
          parentId: 'root',
          startedMs: 1010,
          endedMs: 1012,
          status: const SpanStatus.error());
      final spans = [second, nested, first, root];
      expect(
          renderTrace(spans),
          [
            'root request="a b" attempt=2 cached=false tags=["a","b"] sizes=[1,2] flags=[true,false] (20ms)',
            '  · checkpoint phase="tools" (+2ms)',
            '  · tick (+3.5ms)',
            '  → link trace remote-trace span remote reason="steer"',
            '  → link trace other-trace span other',
            '  first (4.5ms) error Error: failed call',
            '    nested (1ms)',
            '  second (2ms) error',
          ].join('\n'));
    });

    test(
        'treats missing parents as roots and orders roots and children by start time',
        () {
      final later =
          _span('later', parentId: 'external', startedMs: 20, endedMs: 30);
      final child =
          _span('child', parentId: 'later', startedMs: 25, endedMs: 30);
      final earlier = _span('earlier',
          startedMs: 10,
          endedMs: 15,
          links: const [StoredLink(traceId: 'trace', spanId: 'later')]);
      expect(
          renderTrace([later, child, earlier]),
          [
            'earlier (5ms)',
            '  → link trace trace span later',
            'later (10ms)',
            '  child (5ms)'
          ].join('\n'));
    });

    test('prints cross-trace links without following them, including cycles',
        () {
      final server = _span('server:1',
          name: 'server',
          traceId: 'server-trace',
          links: const [
            StoredLink(traceId: 'worker-trace', spanId: 'worker:1')
          ]);
      final worker = _span('worker:1',
          name: 'worker',
          traceId: 'worker-trace',
          links: const [
            StoredLink(traceId: 'server-trace', spanId: 'server:1')
          ]);
      expect(
          renderTrace([server, worker]),
          [
            'server (10ms)',
            '  → link trace worker-trace span worker:1',
            'worker (10ms)',
            '  → link trace server-trace span server:1',
          ].join('\n'));
    });
  });
}
