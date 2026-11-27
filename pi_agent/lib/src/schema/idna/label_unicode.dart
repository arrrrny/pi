/// Unicode (U-label) validation (RFC 5890 §2.3.2.1, RFC 5891 §4.2.3.2).
///
/// Dart port of upstream `@earendil-works/pi-schema`
/// `formats/typebox/idna/label/unicode.ts`.
library;

import 'package:pi/src/schema/idna/bidi.dart';
import 'package:pi/src/schema/idna/pattern.dart';
import 'package:pi/src/schema/idna/puny.dart';

/// Whether the punycode-encoded (A-label) form of [value] exceeds 63 octets.
///
/// Only a label with non-ASCII characters needs the check; a pure-ASCII label
/// is used as-is, so its encoded length is irrelevant.
bool _exceedsMaxALabelLength(String value) =>
    reNonAscii.hasMatch(value) && encode(value).length + 4 > 63;

/// Whether [chars] breaks the hyphen rules (RFC 5891 §4.2.3.2): a leading or
/// trailing hyphen, or `--` in the 3rd/4th code point positions.
bool _hasInvalidHyphens(List<String> chars) {
  if (chars.first == '-' || chars.last == '-') return true;
  return chars.length > 2 && chars.sublist(2).join().startsWith('--');
}

/// Whether [value] is a valid U-label (a Unicode IDNA label).
bool isUnicodeLabel(String value) {
  // RFC 5890 §2.3.2.1: maximum length.
  if (_exceedsMaxALabelLength(value)) return false;
  // RFC 5893: Bidi Rule (applies whenever this label itself is RTL).
  if (hasRightToLeftCharacters(value) && !satisfiesBidiRule(value)) {
    return false;
  }
  final chars = value.runes.map((c) => String.fromCharCodes([c])).toList();
  final codePoints = value.runes.toList();
  final length = codePoints.length;
  // RFC 5891 §4.2.3.2: hyphen rules.
  if (_hasInvalidHyphens(chars)) return false;
  // RFC 5891 §4.2.3.2: must not begin with a combining mark.
  if (reCombiningMark.hasMatch(chars.first)) return false;
  var hasJapanese = false;
  for (var i = 0; i < length; i++) {
    final codePoint = codePoints[i];
    final char = chars[i];
    // 1. DISALLOWED exceptions.
    if (reRfc5892Disallowed.hasMatch(char)) return false;
    // 1b. General category (PVALID) enforcement.
    if (!rePermittedCategory.hasMatch(char)) return false;
    // 2. Collect flags.
    if (reScriptJapanese.hasMatch(char)) hasJapanese = true;
    // 3. CONTEXTO / CONTEXTJ neighbor rules.
    final prev = i > 0 ? codePoints[i - 1] : null;
    final next = i + 1 < length ? codePoints[i + 1] : null;
    switch (codePoint) {
      case 0x00b7: // MIDDLE DOT (Catalan)
        if (prev != 0x006c || next != 0x006c) return false;
      case 0x0375: // Greek KERAIA
        if (next == null || !reScriptGreek.hasMatch(chars[i + 1])) {
          return false;
        }
      case 0x05f3:
      case 0x05f4: // Hebrew GERESH
        if (prev == null || !reScriptHebrew.hasMatch(chars[i - 1])) {
          return false;
        }
      case 0x200c: // ZWNJ - RFC 5892 Appendix A.1
        // Full validation needs a joining-type table; reject when preceded by
        // ASCII (which can never satisfy the Virama or cursive-joining rules).
        if (prev == null ||
            (prev < 0x0080 && !reVirama.hasMatch(chars[i - 1]))) {
          return false;
        }
      case 0x200d: // ZWJ: RFC 5892 Appendix A.2
        if (prev == null || !reVirama.hasMatch(chars[i - 1])) return false;
      default:
        break; // 0x30fb (KATAKANA MIDDLE DOT) is checked after the loop.
    }
  }
  // RFC 5892 Appendix A.7: a Katakana middle dot requires a Japanese char.
  if (value.contains('\u30fb') && !hasJapanese) return false;
  return true;
}
