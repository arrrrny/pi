import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:pi/src/sse_parser.dart';

void main() {
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

  group('parseSSE', () {
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

  // Parity with the MCP Streamable HTTP transport's consumeSseStream
  // (packages/mcp/src/transports/streamable-http.ts); ported from upstream
  // #12451 (arrrrny/pi#33).
  group('consumeSseStream parity', () {
    test('parses chunked CRLF events, comments, IDs, and multiline data',
        () async {
      final events = await parseSSE(toChunkedStream([
        ': keepalive\r\nid: 7\r\ndata: {"one":\r\n',
        'data: 1}\r\n\r\n',
      ])).toList();
      expect(events, [
        {'id': '7', 'data': '{"one":\n1}'},
      ]);
    });

    test(
        'recognizes CR, LF, and CRLF line endings, including CRLF split '
        'across chunks', () async {
      Future<List<Map<String, String>>> parse(List<String> chunks) =>
          parseSSE(toChunkedStream(chunks)).toList();
      const expected = [
        {'id': '1', 'data': 'a\nb'},
        {'data': 'c'},
      ];
      for (final separator in ['\n', '\r\n', '\r']) {
        final text = ['id: 1', 'data: a', 'data: b', '', 'data: c', '', '']
            .join(separator);
        expect(await parse([text]), expected);
        // One character per chunk splits every CRLF between chunks.
        expect(await parse(text.split('')), expected);
      }
      expect(await parse(['id: 1\rdata: a\r\ndata: b\n\r', '\ndata: c\r\r']),
          expected);
    });

    // Regression test for upstream #12224: a large event split across many
    // chunks is measured and scanned once, not rescanned per chunk.
    test('reads a large event split across many chunks in linear time',
        () async {
      const chunkSize = 256;
      const dataSize = 2 * 1024 * 1024;
      final text = 'data: ${'x' * dataSize}\n\n';
      final chunks = <String>[];
      for (var i = 0; i < text.length; i += chunkSize) {
        chunks.add(text.substring(i, math.min(i + chunkSize, text.length)));
      }
      final watch = Stopwatch()..start();
      final events = await parseSSE(toChunkedStream(chunks)).toList();
      watch.stop();
      expect(events, hasLength(1));
      expect(events[0]['data'], 'x' * dataSize);
      // A reintroduced quadratic rescan copies ~4 GiB for this input and
      // cannot finish anywhere near this bound; the linear scanner does.
      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
    });

    test(
        'rejects a line that exceeds the limit before its line ending '
        'arrives', () async {
      var sent = 0;
      Stream<List<int>> endlessLine() async* {
        yield utf8.encode('data: ');
        while (true) {
          sent++;
          yield utf8.encode('x' * 16);
        }
      }

      Object? error;
      try {
        await parseSSE(endlessLine(), maxEventBytes: 256).toList();
      } catch (caught) {
        error = caught;
      }
      expect(error, isA<StateError>());
      expect((error as StateError).message, 'MCP SSE event exceeds 256 bytes');
      expect(sent, lessThan(100));
    });

    test(
        'rejects an event whose joined data lines exceed the limit before '
        'it dispatches', () async {
      Object? error;
      try {
        await parseSSE(
          toChunkedStream(
              ['data: 0123456789abcdef\ndata: 0123456789abcdef\n\n']),
          maxEventBytes: 24,
        ).toList();
      } catch (caught) {
        error = caught;
      }
      expect(error, isA<StateError>());
      expect((error as StateError).message, 'MCP SSE event exceeds 24 bytes');
    });
  });

  // Large-line reassembly through `parseSSE`, whose `LineSplitter` already
  // appends only the new text and reads the pending line once. The linear-time
  // guarantee of upstream #12451 is guarded where that change actually landed:
  // `SseDecoder` (see `test/ai/sse_decoder_test.dart`), not here — asserting it
  // on `LineSplitter` would only lock a property of the Dart SDK.
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
  });
}
