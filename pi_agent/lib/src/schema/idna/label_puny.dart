/// ACE (`xn--`) punycode label validation (RFC 5890 §2.3.2.1).
///
/// Dart port of upstream `@earendil-works/pi-schema`
/// `formats/typebox/idna/label/puny.ts`.
library;

import 'package:pi/src/schema/idna/label_unicode.dart';
import 'package:pi/src/schema/idna/pattern.dart';
import 'package:pi/src/schema/idna/puny.dart';

/// Whether [value] is a valid ACE (punycode) label.
bool isPunyLabel(String value) {
  if (!isAcePrefixed(value)) return false;
  try {
    final body = value.substring(4).toLowerCase();
    // A payload that is only a hyphen, or starts with the delimiter (like
    // "-9uc"), has 0 basic ASCII characters preceding it and is malformed.
    if (body.lastIndexOf('-') == 0) return false;
    final decoded = decode(body);
    // RFC 5890 §2.3.2.1: a U-label must contain at least one non-ASCII char.
    if (!reNonAscii.hasMatch(decoded)) return false;
    return isUnicodeLabel(decoded);
  } on FormatException {
    return false;
  }
}
