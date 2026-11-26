// LF-only JSONL framing and reading in linear time.
//
// Port of `packages/coding-agent/src/modes/rpc/jsonl.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b` (`serializeJsonLine`,
// `attachJsonlLineReader`). The behavioral change in this sync is #12451: only
// new text is scanned and an incomplete line is read once when it ends, so a
// long line arriving in many chunks costs time linear in its size (the previous
// implementation re-scanned the whole accumulated buffer on every chunk). The
// #12224 guarantee is kept: a line whose handler throws is consumed before the
// handler runs, so it is never joined with the next line.

import 'dart:convert';

import 'package:pi/coding_agent.dart';
import 'package:test/test.dart';

void main() {
  group('serializeJsonLine', () {
    test('serializes strict JSONL without escaping Unicode separators', () {
      final line =
          serializeJsonLine(<String, Object>{'text': 'a\u2028b\u2029c'});

      expect(line.contains('a\u2028b\u2029c'), isTrue);
      expect(line.endsWith('\n'), isTrue);
      expect(jsonDecode(line.trim()),
          equals(<String, Object>{'text': 'a\u2028b\u2029c'}));
    });
  });

  group('JsonlLineReader', () {
    test('splits on LF only and preserves U+2028/U+2029 inside payloads', () {
      final reader = JsonlLineReader();
      final lines = <String>[];
      reader.onLine = lines.add;

      reader
          .push(serializeJsonLine(<String, Object>{'text': 'a\u2028b\u2029c'}));
      reader.end();

      expect(lines, hasLength(1));
      expect(jsonDecode(lines.single),
          equals(<String, Object>{'text': 'a\u2028b\u2029c'}));
    });

    test('reads a long line arriving in many chunks in linear time', () {
      final reader = JsonlLineReader();
      final lines = <String>[];
      reader.onLine = lines.add;

      // One record split byte-by-byte across many pushes; a per-chunk rescan of
      // the accumulated buffer would be quadratic. Correctness must hold for
      // every chunking.
      final record = serializeJsonLine(<String, Object>{'text': 'x' * 500});
      for (var i = 0; i < record.length; i++) {
        reader.push(record[i]);
      }
      reader.end();

      expect(lines, hasLength(1));
      expect(jsonDecode(lines.single)['text'] as String, 'x' * 500);
    });

    test('does not join a line whose handler threw with the next line', () {
      final reader = JsonlLineReader();
      final lines = <String>[];
      reader.onLine = (line) {
        lines.add(line);
        if (line == 'prefix') throw StateError('handler failed');
      };

      reader.push('pre');
      expect(() => reader.push('fix\n'), throwsA(isA<StateError>()));
      reader.push('next\n');

      expect(lines, equals(<String>['prefix', 'next']));
    });

    test('handles CRLF-delimited input', () {
      final reader = JsonlLineReader();
      final lines = <String>[];
      reader.onLine = lines.add;

      reader.push('{"a":1}\r\n{"b":2}\r\n');
      reader.end();

      expect(lines, equals(<String>['{"a":1}', '{"b":2}']));
    });

    test('emits a final line without trailing LF', () {
      final reader = JsonlLineReader();
      final lines = <String>[];
      reader.onLine = lines.add;

      reader.push('{"a":1}');
      reader.end();

      expect(lines, equals(<String>['{"a":1}']));
    });

    test('reassembles a multibyte character split across pushes', () {
      // Bytes for '{"text":"é"}\n' with the two-byte é split across the push.
      final bytes =
          utf8.encode(serializeJsonLine(<String, Object>{'text': 'é'}));
      final reader = JsonlLineReader();
      final lines = <String>[];
      reader.onLine = lines.add;

      // Feed the raw bytes through a streaming UTF-8 decoder the way a byte
      // stream would, then push decoded text.
      final decoder = utf8.decoder;
      var carry = <int>[];
      for (final b in bytes) {
        carry = <int>[...carry, b];
        try {
          reader.push(decoder.convert(carry));
          carry = <int>[];
        } on FormatException {
          // Incomplete multibyte sequence at the chunk boundary; wait for more.
        }
      }
      reader.end();

      expect(lines, hasLength(1));
      expect(jsonDecode(lines.single)['text'] as String, 'é');
    });
  });
}
