// Streaming server-sent-event decoding in linear time.
//
// Port of `packages/ai/src/utils/sse.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b` (`SseDecoder`, `ServerSentEvent`).
// The behavioral change in this sync is #12451: only new text is scanned and an
// incomplete line is read once when it ends, so a large event arriving in many
// chunks costs time linear in its size. Bytes are decoded through a streaming
// UTF-8 converter so a multibyte character split across chunks is reassembled,
// matching the upstream `TextDecoder({stream:true})` behavior.

import 'dart:convert';

import 'package:pi/ai.dart';
import 'package:test/test.dart';

List<ServerSentEvent> _decode(List<int> bytes, int chunkSize) {
  final decoder = SseDecoder();
  final events = <ServerSentEvent>[];
  for (var i = 0; i < bytes.length; i += chunkSize) {
    final end = (i + chunkSize) < bytes.length ? i + chunkSize : bytes.length;
    events.addAll(decoder.push(bytes.sublist(i, end)));
  }
  events.addAll(decoder.end());
  return events;
}

void main() {
  group('SseDecoder', () {
    test('gives the same events for every chunking and line ending', () {
      for (final separator in <String>['\n', '\r\n', '\r']) {
        final text = [
          ': keepalive',
          'event: delta',
          'data: {"a":',
          'data:  "é"}',
          '',
          'data: tail',
        ].join(separator);
        final bytes = utf8.encode(text);
        for (var chunkSize = 1; chunkSize <= bytes.length; chunkSize++) {
          expect(
            _decode(bytes, chunkSize),
            <ServerSentEvent>[
              ServerSentEvent(
                event: 'delta',
                data: '{"a":\n "é"}',
                raw: const <String>[
                  ': keepalive',
                  'event: delta',
                  'data: {"a":',
                  'data:  "é"}',
                ],
              ),
              const ServerSentEvent(
                  event: null, data: 'tail', raw: <String>['data: tail']),
            ],
          );
        }
      }
    });

    test('does not end an event at a CRLF split across chunks', () {
      final decoder = SseDecoder();
      expect(decoder.push(utf8.encode('data: a\r')), isEmpty);
      expect(decoder.push(utf8.encode('\ndata: b\r\n\r\n')), <ServerSentEvent>[
        const ServerSentEvent(
            event: null, data: 'a\nb', raw: <String>['data: a', 'data: b']),
      ]);
    });

    test('does not carry an empty event name into the next event', () {
      final decoder = SseDecoder();
      expect(
          decoder.push(utf8.encode('event:\n\ndata: x\n\n')), <ServerSentEvent>[
        const ServerSentEvent(event: null, data: 'x', raw: <String>['data: x']),
      ]);
    });

    test('drops comment lines of events without data', () {
      final decoder = SseDecoder();
      expect(
          decoder.push(utf8.encode(': ping\n\ndata: x\n\n')), <ServerSentEvent>[
        const ServerSentEvent(event: null, data: 'x', raw: <String>['data: x']),
      ]);
    });
  });

  // Ports the linear-time guarantee of upstream #12451 (da7e26cc8, "read large
  // streamed lines and events in linear time") onto the component that change
  // actually touched: `SseDecoder` re-scanned the accumulated buffer per chunk
  // before #12451, and now scans only the newly decoded text. Driving push/end
  // directly means a reintroduced quadratic rescan fails here, rather than on
  // `parseSSE`/`LineSplitter`, which is linear regardless of this port.
  group('SseDecoder large streamed lines (upstream #12451)', () {
    test('reassembles a 1 MiB data line delivered in 4 KiB chunks', () {
      final payload = 'x' * (1024 * 1024);
      final events = _decode(utf8.encode('data: $payload\n\n'), 4096);
      expect(events, hasLength(1));
      expect(events.single.data, payload);
    });

    test('reads a large streamed line in linear, not quadratic, time', () {
      // A pre-#12451 reader that rescanned the whole pending buffer per chunk
      // copies about (size / chunk) * size characters: 2 MiB in 256 B chunks is
      // ~16 GB of copying and takes seconds. The linear decoder finishes far
      // under the bound. The limit is generous so a shared host cannot flake
      // it, while a reintroduced quadratic rescan still blows past it.
      final payload = 'z' * (2 * 1024 * 1024);
      final bytes = utf8.encode('data: $payload\n\n');
      final sw = Stopwatch()..start();
      final events = _decode(bytes, 256);
      sw.stop();
      expect(events, hasLength(1));
      expect(events.single.data, payload);
      expect(sw.elapsedMilliseconds, lessThan(10000),
          reason: 'large line decode took ${sw.elapsedMilliseconds}ms');
    });
  });
}
