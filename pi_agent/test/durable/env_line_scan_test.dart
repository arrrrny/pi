// Env byte-scanning: streaming UTF-8 decode and bounded-memory line scanning.
// Differential port of `packages/durable/test/env-line-scan.test.ts` at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`. The oracle is Dart's own
// whole-input `utf8` decode (the WHATWG `TextDecoder` equivalent): a chunked
// scan must agree with decoding and splitting the whole file at once.

import 'dart:convert';

import 'package:pi/durable.dart';
import 'package:test/test.dart';

/// A small deterministic generator, so a failing seed is reproducible.
class _Rng {
  int _state;
  _Rng(int seed) : _state = seed & 0x7fffffff;

  int next() {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state;
  }

  double nextDouble() => next() / 2147483648.0;
}

// Newlines, ASCII, a byte-order mark, valid multi-byte sequences, and bytes that
// form invalid or truncated sequences.
const List<List<int>> _pieces = <List<int>>[
  <int>[0x0a],
  <int>[0x0a],
  <int>[0x61],
  <int>[0x62, 0x63],
  <int>[0xef, 0xbb, 0xbf],
  <int>[0xc3, 0xa9],
  <int>[0xe2, 0x82, 0xac],
  <int>[0xf0, 0x9f, 0x98, 0x80],
  <int>[0xe2, 0x82],
  <int>[0xff],
  <int>[0x80],
  <int>[0xf0, 0x9f],
  <int>[0x0d, 0x0a],
];

List<int> _randomFile(_Rng next) {
  final bytes = <int>[];
  final pieces = (next.nextDouble() * 60).floor();
  for (var index = 0; index < pieces; index++) {
    bytes.addAll(_pieces[(next.nextDouble() * _pieces.length).floor()]);
  }
  return bytes;
}

/// Decodes the whole input, dropping a leading byte-order mark (default
/// `TextDecoder` behaviour, `ignoreBOM: false`, which `utf8.decode` already
/// applies).
String _decodeWhole(List<int> bytes) =>
    utf8.decode(bytes, allowMalformed: true);

/// Decodes `file[from, to)` with `ignoreBOM: from > 0`: a leading mark is
/// stripped only when `from` is 0. `utf8.decode` always strips a leading mark,
/// so re-add it when an interior range starts with one.
String _decodeRange(List<int> file, int from, int to) {
  final sub = file.sublist(from, to);
  final text = utf8.decode(sub, allowMalformed: true);
  if (from > 0 &&
      sub.length >= 3 &&
      sub[0] == 0xef &&
      sub[1] == 0xbb &&
      sub[2] == 0xbf) {
    return '\ufeff$text';
  }
  return text;
}

int _utf8(String text) => utf8.encode(text).length;

/// `Array.prototype.slice(start, end)`: `end` absent means to the end, and
/// out-of-range indices clamp rather than throw.
List<String> _slice(List<String> list, int start, [int? end]) {
  final s = start > list.length ? list.length : start;
  final rawEnd = end ?? list.length;
  final e = rawEnd > list.length ? list.length : rawEnd;
  if (s >= e) return <String>[];
  return list.sublist(s, e);
}

/// `bytes.subarray(offset, offset + size)`: the end clamps to the length.
List<int> _subarray(List<int> bytes, int start, int end) =>
    bytes.sublist(start, end > bytes.length ? bytes.length : end);

void main() {
  group('StreamDecoder', () {
    // Node's streaming TextDecoder with BOM handling dropped this U+FEFF, which
    // follows an invalid sequence.
    test('keeps a U+FEFF that does not start the stream', () {
      final bytes = <int>[0xe2, 0x82, 0xef, 0xbb, 0xbf, 0x61];
      final decoder = StreamDecoder();
      final buffer = StringBuffer();
      for (final byte in bytes) {
        buffer.write(decoder.decode(<int>[byte]));
      }
      buffer.write(decoder.decode());
      expect(buffer.toString(), _decodeWhole(bytes));
      expect(buffer.toString(), '\ufffd\ufeffa');
    });

    test('decodes any chunking like decoding the whole stream', () {
      for (var seed = 1; seed <= 5000; seed++) {
        final next = _Rng(seed);
        final bytes = _randomFile(next);
        final decoder = StreamDecoder();
        final buffer = StringBuffer();
        for (var offset = 0; offset < bytes.length;) {
          final size = 1 + (next.nextDouble() * 7).floor();
          buffer.write(decoder.decode(_subarray(bytes, offset, offset + size)));
          offset += size;
        }
        buffer.write(decoder.decode());
        expect(buffer.toString(), _decodeWhole(bytes), reason: 'seed $seed');
      }
    });
  });

  group('LineScanner', () {
    test('agrees with decoding and splitting the whole file', () {
      for (var seed = 1; seed <= 5000; seed++) {
        final next = _Rng(seed);
        final file = _randomFile(next);
        final lines = _decodeWhole(file).split('\n');
        final startLine = (next.nextDouble() * (lines.length + 2)).floor();
        final endLine = next.nextDouble() < 0.3
            ? null
            : startLine + 1 + (next.nextDouble() * (lines.length + 1)).floor();
        final scanner = LineScanner(startLine, endLine ?? LineScanner.infinity);
        for (var offset = 0; offset < file.length;) {
          final size = 1 + (next.nextDouble() * 7).floor();
          scanner.push(_subarray(file, offset, offset + size));
          offset += size;
        }
        final scan = scanner.finish();
        final message = 'seed $seed';
        expect(scan.newlines, lines.length - 1, reason: message);
        final selected = _slice(lines, startLine, endLine);
        expect(_decodeRange(file, scan.start, scan.end), selected.join('\n'),
            reason: message);
        expect(scan.selectedBytes, _utf8(selected.join('\n')), reason: message);
        if (startLine < lines.length) {
          expect(_decodeRange(file, scan.start, scan.firstLineEnd),
              lines[startLine],
              reason: message);
          expect(scan.firstLineBytes, _utf8(lines[startLine]), reason: message);
          final lastLine = (endLine ?? lines.length) < lines.length
              ? (endLine ?? lines.length)
              : lines.length;
          final last = lastLine - 1;
          final lastEnd = last + 1 < lines.length
              ? file.indexOf(0x0a, scan.lastLineStart)
              : file.length;
          expect(_decodeRange(file, scan.lastLineStart, lastEnd), lines[last],
              reason: message);
        } else {
          expect(scan.start, file.length, reason: message);
          expect(scan.end, file.length, reason: message);
          expect(scan.selectedBytes, 0, reason: message);
        }
      }
    });

    test('rejects empty or invalid ranges', () {
      expect(() => LineScanner(2, 2), throwsRangeError);
      expect(() => LineScanner(-1), throwsRangeError);
    });
  });
}
