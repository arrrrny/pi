/// ASCII LDH label validation (RFC 5891 §4.2.3.1).
///
/// Dart port of upstream `@earendil-works/pi-schema`
/// `formats/typebox/idna/label/ascii.ts`.
library;

import 'package:pi/src/schema/idna/pattern.dart';

/// Whether [value] is a valid ASCII LDH label.
bool isAsciiLabel(String value) =>
    reRuleHyphenPlacement.hasMatch(value) &&
    reRuleNotReservedAce.hasMatch(value) &&
    reAsciiLdh.hasMatch(value);
