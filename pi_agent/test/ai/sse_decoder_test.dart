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
      // Ports the linear-time guarantee of upstream #12451: a pre-#12451 reader
      // rescanned the whole pending buffer per chunk, so its cost grew with
      // (size / chunk) * size — quadratic in the line size — while this decoder
      // scans only the newly decoded text and grows linearly.
      //
      // The guard is a RATIO, not a wall-clock bound (pi#67): decode two sizes
      // at a fixed chunk size and bound how much the time grows. Linear scaling
      // makes the time ratio track the size ratio (here 8x); a quadratic rescan
      // makes it track the square (64x). A ratio is dimensionless, so a slow or
      // contended host scales both runs together and cannot flake it — the old
      // absolute `elapsed < 10s` bound failed at 12.2s under load while the
      // decoder was untouched. The threshold sits between the linear 8x and the
      // quadratic 64x with headroom on both sides.
      const chunk = 256;
      const smallSize = 128 * 1024; // 512 chunks
      const largeSize = 1024 * 1024; // 4096 chunks, 8x the data

      // Best of three: a GC pause or a scheduling hiccup inflates one sample,
      // and the minimum is the cleanest estimate of the work itself.
      int bestMillis(int size) {
        final bytes = utf8.encode('data: ${'z' * size}\n\n');
        var best = -1;
        for (var run = 0; run < 3; run++) {
          final sw = Stopwatch()..start();
          final events = _decode(bytes, chunk);
          sw.stop();
          expect(events, hasLength(1));
          expect(events.single.data, hasLength(size));
          final ms = sw.elapsedMilliseconds;
          if (best < 0 || ms < best) best = ms;
        }
        return best;
      }

      bestMillis(32 * 1024); // warm up so first-call setup is not counted
      final small = bestMillis(smallSize);
      final large = bestMillis(largeSize);
      expect(large, lessThan(small * 24 + 100),
          reason: 'decode scaled to ${large}ms from ${small}ms for 8x the line '
              'size — super-linear (quadratic) rescan suspected');
    });
  });
}
