import 'dart:async';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:pi/src/sse_parser.dart';

void main() {
  group('parseSSE', () {
    Stream<List<int>> toByteStream(String input) {
      final controller = StreamController<List<int>>();
      controller.add(utf8.encode(input));
      controller.close();
      return controller.stream;
    }

    Stream<List<int>> toChunkedStream(List<String> chunks) {
      final controller = StreamController<List<int>>();
      for (final c in chunks) {
        controller.add(utf8.encode(c));
      }
      controller.close();
      return controller.stream;
    }

    test('parses single event with data field', () async {
      final events = await parseSSE(toByteStream('data: hello\n\n')).toList();
      expect(events, hasLength(1));
      expect(events[0]['data'], 'hello');
    });

    test('parses event with event type', () async {
      final events = await parseSSE(
        toByteStream('event: message\ndata: hello\n\n'),
      ).toList();
      expect(events, hasLength(1));
      expect(events[0]['event'], 'message');
      expect(events[0]['data'], 'hello');
    });

    test('parses event with id field', () async {
      final events = await parseSSE(
        toByteStream('id: 42\ndata: hello\n\n'),
      ).toList();
      expect(events, hasLength(1));
      expect(events[0]['id'], '42');
      expect(events[0]['data'], 'hello');
    });

    test('parses event with retry field', () async {
      final events = await parseSSE(
        toByteStream('retry: 5000\ndata: hello\n\n'),
      ).toList();
      expect(events, hasLength(1));
      expect(events[0]['retry'], '5000');
    });

    test('coalesces multi-line data fields', () async {
      final events = await parseSSE(
        toByteStream('data: line1\ndata: line2\ndata: line3\n\n'),
      ).toList();
      expect(events, hasLength(1));
      expect(events[0]['data'], 'line1\nline2\nline3');
    });

    test('handles data field without space after colon', () async {
      final events = await parseSSE(
        toByteStream('data:no-space\n\n'),
      ).toList();
      expect(events, hasLength(1));
      expect(events[0]['data'], 'no-space');
    });

    test('ignores comment lines', () async {
      final events = await parseSSE(
        toByteStream(': this is a comment\ndata: visible\n\n'),
      ).toList();
      expect(events, hasLength(1));
      expect(events[0]['data'], 'visible');
    });

    test('parses multiple events', () async {
      final events = await parseSSE(
        toByteStream('data: first\n\ndata: second\n\n'),
      ).toList();
      expect(events, hasLength(2));
      expect(events[0]['data'], 'first');
      expect(events[1]['data'], 'second');
    });

    test('emits buffered data on stream close without trailing newline',
        () async {
      final events = await parseSSE(
        toByteStream('data: unfinished'),
      ).toList();
      expect(events, hasLength(1));
      expect(events[0]['data'], 'unfinished');
    });

    test('handles chunked input across event boundaries', () async {
      final events = await parseSSE(
        toChunkedStream(['data: par', 't1\n\nda', 'ta: part2\n\n']),
      ).toList();
      expect(events, hasLength(2));
      expect(events[0]['data'], 'part1');
      expect(events[1]['data'], 'part2');
    });

    test('skips [DONE] sentinel', () async {
      final input = 'data: {"content":"hi"}\n\ndata: [DONE]\n\n';
      final events = await parseSSE(toByteStream(input)).toList();
      expect(events, hasLength(2));
      expect(events[0]['data'], '{"content":"hi"}');
      expect(events[1]['data'], '[DONE]');
    });

    test('handles empty stream', () async {
      final events = await parseSSE(toByteStream('')).toList();
      expect(events, isEmpty);
    });

    test('handles blank lines without data', () async {
      final events = await parseSSE(toByteStream('\n\n\n')).toList();
      expect(events, isEmpty);
    });

    test('handles JSON data payload', () async {
      final json = '{"choices":[{"delta":{"content":"Hi"}}]}';
      final events = await parseSSE(toByteStream('data: $json\n\n')).toList();
      expect(events, hasLength(1));
      final decoded = jsonDecode(events[0]['data']!);
      expect(decoded, isA<Map<String, dynamic>>());
    });
  });

  // Ports the agent-area behavioral guarantee of upstream #12451 (da7e26cc8,
  // "read large streamed lines and events in linear time"), whose agent slice
  // changed `streamProxy` to split only the newly decoded chunk instead of
  // rescanning the whole accumulated buffer on every chunk. The Dart port has
  // no `streamProxy`; its streaming path reads SSE lines through `LineSplitter`,
  // which already appends only the new text and reads the pending line once, so
  // these lock the linear-time guarantee in rather than change production code.
  group('parseSSE large streamed lines (upstream #12451)', () {
    Stream<List<int>> toByteChunkedStream(String input, int chunkSize) {
      final bytes = utf8.encode(input);
      final controller = StreamController<List<int>>();
      for (var i = 0; i < bytes.length; i += chunkSize) {
        final end =
            (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        controller.add(bytes.sublist(i, end));
      }
      controller.close();
      return controller.stream;
    }

    test('reassembles a 1 MiB data line delivered in 4 KiB chunks', () async {
      final payload = 'x' * (1024 * 1024);
      final events =
          await parseSSE(toByteChunkedStream('data: $payload\n\n', 4096))
              .toList();
      expect(events, hasLength(1));
      expect(events[0]['data'], payload);
    });

    test('yields the same event for every chunk size', () async {
      final payload = jsonEncode({
        'choices': [
          {
            'delta': {'content': 'y' * 200000}
          }
        ]
      });
      final line = 'data: $payload\n\n';
      for (final size in [1, 7, 4096, 65536, line.length]) {
        final events = await parseSSE(toByteChunkedStream(line, size)).toList();
        expect(events, hasLength(1), reason: 'chunk size $size');
        expect(events[0]['data'], payload, reason: 'chunk size $size');
      }
    });

    test('reads a large streamed line in linear, not quadratic, time',
        () async {
      // A pre-#12451 reader that rescanned the whole pending buffer per chunk
      // copies about (size / chunk) * size characters: 2 MiB in 256 B chunks is
      // ~16 GB of copying and takes seconds. The linear LineSplitter finishes
      // far under the bound. The limit is generous so a shared host cannot flake
      // it, while a reintroduced quadratic rescan still blows past it.
      final payload = 'z' * (2 * 1024 * 1024);
      final sw = Stopwatch()..start();
      final events =
          await parseSSE(toByteChunkedStream('data: $payload\n\n', 256))
              .toList();
      sw.stop();
      expect(events, hasLength(1));
      expect(events[0]['data'], payload);
      expect(sw.elapsedMilliseconds, lessThan(10000),
          reason: 'large line parse took ${sw.elapsedMilliseconds}ms');
    });
  });
}
