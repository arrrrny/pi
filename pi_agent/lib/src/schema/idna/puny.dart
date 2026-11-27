/// Punycode codec (RFC 3492) for IDNA A-label handling.
///
/// Dart port of upstream `@earendil-works/pi-schema`
/// `formats/typebox/idna/format/puny.ts`. [decode] reverses an `xn--` payload
/// for validation; [encode] computes the A-label length the 63-octet limit
/// (RFC 5891 §4.2.4) applies to.
library;

import 'package:pi/src/schema/idna/pattern.dart';

const int _base = 36;
const int _tMin = 1;
const int _tMax = 26;
const int _skew = 38;
const int _damp = 700;
const int _initialBias = 72;
const int _initialN = 128;

/// Whether [value] carries the `xn--` ACE prefix (case-insensitive).
bool isAcePrefixed(String value) => value.toLowerCase().startsWith('xn--');

int _adapt(int delta, int numPoints, bool firstTime) {
  delta = firstTime ? delta ~/ _damp : delta >> 1;
  delta += delta ~/ numPoints;
  var k = 0;
  while (delta > ((_base - _tMin) * _tMax) >> 1) {
    delta = delta ~/ (_base - _tMin);
    k += _base;
  }
  return k + (((_base - _tMin + 1) * delta) ~/ (delta + _skew));
}

/// Decodes a punycode payload (the part after `xn--`) to its Unicode form.
///
/// Throws [FormatException] on a malformed payload, mirroring the upstream
/// `throw null` control flow.
String decode(String value) {
  final output = <int>[];
  var n = _initialN;
  var i = 0;
  var bias = _initialBias;
  final delimIdx = value.lastIndexOf('-');
  if (delimIdx > 0) {
    for (var j = 0; j < delimIdx; j++) {
      final cp = value.codeUnitAt(j);
      if (cp >= 128) throw FormatException('non-basic before delimiter');
      output.add(cp);
    }
  }
  var inIdx = delimIdx < 0 ? 0 : delimIdx + 1;
  while (inIdx < value.length) {
    final oldi = i;
    var w = 1;
    var k = _base;
    while (true) {
      if (inIdx >= value.length) {
        throw FormatException('unexpected end of input');
      }
      final ch = value.codeUnitAt(inIdx++);
      int digit;
      if (ch >= 0x61 && ch <= 0x7a) {
        digit = ch - 0x61; // a-z => 0-25
      } else if (ch >= 0x30 && ch <= 0x39) {
        digit = ch - 0x30 + 26; // 0-9 => 26-35
      } else {
        throw FormatException('bad digit character');
      }
      i += digit * w;
      final t = k <= bias ? _tMin : (k >= bias + _tMax ? _tMax : k - bias);
      if (digit < t) break;
      w *= _base - t;
      k += _base;
    }
    final outLen = output.length + 1;
    bias = _adapt(i - oldi, outLen, oldi == 0);
    n += i ~/ outLen;
    i %= outLen;
    output.insert(i, n);
    i++;
  }
  return String.fromCharCodes(output);
}

String _digitToChar(int digit) => digit < 26
    ? String.fromCharCode(digit + 0x61)
    : String.fromCharCode(digit - 26 + 0x30);

/// Encodes a Unicode string to its punycode payload (the part after `xn--`).
String encode(String input) {
  final basic = input.replaceAll(reNonAscii, '');
  final basicLength = basic.length;
  final result = <String>[if (basicLength > 0) basic, if (basicLength > 0) '-'];
  final codePoints = input.runes.toList();
  var n = _initialN;
  var delta = 0;
  var bias = _initialBias;
  var handledCPCount = basicLength;
  while (handledCPCount < codePoints.length) {
    var m = 0x7fffffff;
    for (final cp in codePoints) {
      if (cp >= n && cp < m) m = cp;
    }
    delta += (m - n) * (handledCPCount + 1);
    n = m;
    for (final cp in codePoints) {
      if (cp < n) delta++;
      if (cp == n) {
        var q = delta;
        for (var k = _base;; k += _base) {
          final t = k <= bias ? _tMin : (k >= bias + _tMax ? _tMax : k - bias);
          if (q < t) break;
          final digit = t + ((q - t) % (_base - t));
          result.add(_digitToChar(digit));
          q = (q - t) ~/ (_base - t);
        }
        result.add(_digitToChar(q));
        bias = _adapt(delta, handledCPCount + 1, handledCPCount == basicLength);
        delta = 0;
        handledCPCount++;
      }
    }
    delta++;
    n++;
  }
  return result.join();
}
