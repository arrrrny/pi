/// Unicode property patterns for IDNA/UTS-46 label validation.
///
/// Dart port of upstream `@earendil-works/pi-schema`
/// `formats/typebox/idna/pattern/pattern.ts`. Each `RegExp` mirrors one
/// upstream pattern; the `unicode: true` flag is Dart's equivalent of the
/// JavaScript `u` flag, required for `\p{...}` property escapes.
library;

// -------------------------------------------------------------------
// Validation Rules
// -------------------------------------------------------------------

/// A label must not start or end with a hyphen (RFC 5891 §4.2.3.2).
final RegExp reRuleHyphenPlacement = RegExp(r'^(?!-).*(?<!-)$');

/// A label must not carry the reserved ACE prefix in positions 3-4 (`..--`).
final RegExp reRuleNotReservedAce = RegExp(r'^(?!..--)');

/// An ASCII label body: LDH (letters, digits, hyphen) only.
final RegExp reAsciiLdh = RegExp(r'^[a-zA-Z0-9-]*$');

// -------------------------------------------------------------------
// ASCII & Encoding
// -------------------------------------------------------------------

/// Whether a string is entirely ASCII.
final RegExp reAscii = RegExp(r'^\p{ASCII}*$', unicode: true);

/// Matches any non-ASCII code point.
final RegExp reNonAscii = RegExp(r'[^\p{ASCII}]', unicode: true);

// -------------------------------------------------------------------
// Numbers & Digits
// -------------------------------------------------------------------

/// An ASCII digit `0-9`.
final RegExp reAsciiDigit = RegExp(r'[0-9]');

/// An Arabic-Indic digit (U+0660..U+0669).
final RegExp reArabicIndicDigit = RegExp(r'[\u{0660}-\u{0669}]', unicode: true);

/// An Extended Arabic-Indic digit (U+06F0..U+06F9).
final RegExp reExtArabicIndicDigit =
    RegExp(r'[\u{06f0}-\u{06f9}]', unicode: true);

// -------------------------------------------------------------------
// General Categories
// -------------------------------------------------------------------

/// A nonspacing mark (`Mn`).
final RegExp reMarkNonspacing = RegExp(r'\p{Mn}', unicode: true);

/// A spacing combining mark (`Mc`).
final RegExp reMarkSpacingCombining = RegExp(r'\p{Mc}', unicode: true);

/// An enclosing mark (`Me`).
final RegExp reMarkEnclosing = RegExp(r'\p{Me}', unicode: true);

/// Any combining mark (`Mn`, `Mc`, `Me`).
final RegExp reCombiningMark = RegExp(r'[\p{Mn}\p{Mc}\p{Me}]', unicode: true);

/// A letter (`L`).
final RegExp reLetter = RegExp(r'\p{L}', unicode: true);

/// A decimal number (`Nd`).
final RegExp reNumberDecimal = RegExp(r'\p{Nd}', unicode: true);

// -------------------------------------------------------------------
// Scripts
// -------------------------------------------------------------------

/// A Greek-script character.
final RegExp reScriptGreek = RegExp(r'\p{Script=Greek}', unicode: true);

/// A Hebrew-script character.
final RegExp reScriptHebrew = RegExp(r'\p{Script=Hebrew}', unicode: true);

/// A Japanese-script character (Hiragana, Katakana, or Han).
final RegExp reScriptJapanese = RegExp(
    r'[\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Han}]',
    unicode: true);

/// An Arabic-family letter (Arabic, Syriac, Thaana, or Mandaic).
final RegExp reScriptArabicLetter = RegExp(
    r'[\p{Script=Arabic}\p{Script=Syriac}\p{Script=Thaana}\p{Script=Mandaic}]',
    unicode: true);

// -------------------------------------------------------------------
// RFC Specifications & Context Exceptions
// -------------------------------------------------------------------

/// A virama (combining mark that joins consonants) across Indic scripts.
final RegExp reVirama = RegExp(
    r'[\u{094d}\u{09cd}\u{0a4d}\u{0acd}\u{0b4d}\u{0bcd}\u{0c4d}\u{0ccd}\u{0d3b}\u{0d3c}\u{0d4d}\u{0dca}\u{1b44}\u{1baa}\u{1bab}\u{a9c0}\u{11046}\u{1107f}\u{110b9}\u{11133}\u{11134}\u{111c0}\u{11235}\u{1134d}\u{11442}\u{114c2}\u{115bf}\u{1163f}\u{116b6}\u{11c3f}\u{11d44}\u{11d45}]',
    unicode: true);

/// Code points RFC 5892 lists as DISALLOWED exceptions.
final RegExp reRfc5892Disallowed = RegExp(
    r'[\u{0640}\u{07fa}\u{302e}\u{302f}\u{3031}\u{3032}\u{3033}\u{3034}\u{3035}\u{303b}]',
    unicode: true);

/// Code points that are PVALID only under a CONTEXTO/CONTEXTJ rule.
final RegExp reContextexceptions = RegExp(
    r'[\u{00b7}\u{0375}\u{05f3}\u{05f4}\u{200c}\u{200d}\u{30fb}]',
    unicode: true);

/// Code points that are PVALID by explicit exception.
final RegExp rePvalidExceptions = RegExp(
    r'[\u{00df}\u{03c2}\u{06fd}\u{06fe}\u{0f0b}\u{3007}]',
    unicode: true);

// -------------------------------------------------------------------
// Composite Patterns
// -------------------------------------------------------------------

/// A European number: an ASCII or Extended Arabic-Indic digit.
final RegExp reEuropeanNumber =
    RegExp(r'[0-9\u{06f0}-\u{06f9}]', unicode: true);

/// The set of general categories permitted in a U-label (RFC 5892 PVALID).
final RegExp rePermittedCategory = RegExp(
    r'[\p{L}\u{002d}\u{002b}\u{002e}\u{002c}\u{003a}\u{002f}\p{Nd}\p{Mn}\p{Mc}'
    r'\u{00b7}\u{0375}\u{05f3}\u{05f4}\u{200c}\u{200d}\u{30fb}'
    r'\u{00df}\u{03c2}\u{06fd}\u{06fe}\u{0f0b}\u{3007}]',
    unicode: true);
