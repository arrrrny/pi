/// Bidi rule helpers (RFC 5893) for IDNA label validation.
///
/// Dart port of upstream `@earendil-works/pi-schema`
/// `formats/typebox/idna/format/bidi.ts`.
library;

import 'package:pi/src/schema/idna/pattern.dart';
import 'package:pi/src/schema/idna/puny.dart';

// Allowed Bidi classes per direction (RFC 5893).
final RegExp _rtlAllowed = RegExp(r'^(R|AL|AN|EN|ES|CS|ET|ON|BN|NSM)$');
final RegExp _ltrAllowed = RegExp(r'^(L|EN|ES|CS|ET|ON|BN|NSM)$');
final RegExp _rtlClasses = RegExp(r'^(R|AL|AN)$');

/// Whether [value] is an RTL label per RFC 5893 §1.4 (decoding an ACE label
/// first when it is one).
bool hasBidiChars(String value) {
  if (isAcePrefixed(value)) {
    try {
      return hasRightToLeftCharacters(decode(value.substring(4).toLowerCase()));
    } on FormatException {
      return false;
    }
  }
  return hasRightToLeftCharacters(value);
}

String _bidiClass(int codePoint) {
  final char = String.fromCharCodes([codePoint]);
  if (reEuropeanNumber.hasMatch(char)) return 'EN';
  if (reArabicIndicDigit.hasMatch(char)) return 'AN';
  if (reMarkNonspacing.hasMatch(char)) return 'NSM';
  if (reScriptHebrew.hasMatch(char)) return 'R';
  if (reScriptArabicLetter.hasMatch(char)) return 'AL';
  if (reLetter.hasMatch(char)) return 'L';
  return 'ON';
}

/// Whether [value] contains at least one R, AL, or AN character (RFC 5893
/// §1.4), i.e. whether it is an RTL label.
bool hasRightToLeftCharacters(String value) {
  for (final ch in value.runes) {
    if (_rtlClasses.hasMatch(_bidiClass(ch))) return true;
  }
  return false;
}

/// Whether [value] satisfies the Bidi Rule (RFC 5893).
bool satisfiesBidiRule(String value) {
  var isRtl = false;
  var allowed = _ltrAllowed;
  var sawEn = false;
  var sawAn = false;
  var isFirst = true;
  for (final ch in value.runes) {
    final bidiClass = _bidiClass(ch);
    if (isFirst) {
      // 1. The first character must be L, R, or AL.
      if (bidiClass != 'L' && bidiClass != 'R' && bidiClass != 'AL') {
        return false;
      }
      isRtl = bidiClass == 'R' || bidiClass == 'AL';
      allowed = isRtl ? _rtlAllowed : _ltrAllowed;
      isFirst = false;
    }
    // 2 / 5. Only characters in the allowed set for this direction may appear.
    if (!allowed.hasMatch(bidiClass)) return false;
    if (bidiClass == 'EN') {
      sawEn = true;
    } else if (bidiClass == 'AN') {
      sawAn = true;
    }
  }
  // An RTL label must not mix EN and AN.
  if (isRtl && sawEn && sawAn) return false;
  return true;
}
