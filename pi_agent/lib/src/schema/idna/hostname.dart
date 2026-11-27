/// ASCII hostname validation (RFC 1034 / RFC 5891).
///
/// Dart port of upstream `@earendil-works/pi-schema`
/// `formats/typebox/idna/hostname.ts`.
library;

import 'package:pi/src/schema/idna/label_ascii.dart';
import 'package:pi/src/schema/idna/label_puny.dart';

bool _isValidLabelLength(String value) =>
    value.isNotEmpty && value.length <= 63;

bool _isLabel(String value) =>
    _isValidLabelLength(value) && (isPunyLabel(value) || isAsciiLabel(value));

/// Whether [value] is a valid hostname (dot-separated LDH / ACE labels).
bool isAsciiHostname(String value) {
  if (value.isEmpty || value.length > 253) return false;
  if (value.codeUnitAt(value.length - 1) == 46) return false; // trailing dot
  return value.split('.').every(_isLabel);
}
