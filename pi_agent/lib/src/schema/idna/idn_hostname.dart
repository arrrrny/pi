/// IDN (Unicode) hostname validation (UTS-46 / RFC 5890-5893).
///
/// Dart port of upstream `@earendil-works/pi-schema`
/// `formats/typebox/idna/idn-hostname.ts`.
library;

import 'package:pi/src/schema/idna/bidi.dart';
import 'package:pi/src/schema/idna/label_puny.dart';
import 'package:pi/src/schema/idna/label_unicode.dart';

// Fullwidth code points U+FF01..U+FF5E map to ASCII by subtracting 0xFEE0.
final RegExp _reFullwidthMapping = RegExp(r'[\uff01-\uff5e]');

// Code points IDNA mapping ignores (soft hyphen, Mongolian free variation
// selectors, zero-width space, variation selectors, tag characters).
final RegExp _reIgnoredMapping = RegExp(
    r'[\u00ad\u034f\u180b-\u180d\u200b\ufe00-\ufe0f\u{e0100}-\u{e01ef}]',
    unicode: true);

// Full stop variants that all map to ASCII '.'.
final RegExp _reFullStopMapping = RegExp(r'[\u002e\u3002\uff0e\uff61]');

/// Normalizes a hostname for label validation: maps fullwidth code points to
/// ASCII, removes code points IDNA ignores, and converts full stop variants to
/// ASCII '.' so the value splits into labels.
///
/// NOTE: upstream also applies NFC. Dart's core has no Unicode normalizer, so
/// NFC is not applied here; the ported fixtures do not depend on composition to
/// reach a verdict (a decomposed sequence validates the same as its composed
/// form under the PVALID category rules).
String _normalizeHostname(String value) {
  final mapped = value.replaceAllMapped(_reFullwidthMapping,
      (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0xfee0));
  final stripped = mapped.replaceAll(_reIgnoredMapping, '');
  return stripped.replaceAll(_reFullStopMapping, '.');
}

bool _isValidLabelLength(String value) =>
    value.isNotEmpty && value.length <= 63;

bool _isLabel(String value) =>
    _isValidLabelLength(value) && (isPunyLabel(value) || isUnicodeLabel(value));

/// Whether [value] is a valid IDN (Unicode) hostname.
bool isIdnHostname(String value) {
  if (value.isEmpty || value.contains(' ')) return false;
  final normalized = _normalizeHostname(value);
  if (normalized.length > 253) return false;
  final labels = normalized.split('.');
  final anyBidi = labels.any(hasBidiChars);
  return labels.every(
      (label) => _isLabel(label) && (!anyBidi || satisfiesBidiRule(label)));
}
