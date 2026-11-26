/// Codemode source format: JavaScript, optionally preceded by one options line.
///
/// ```js
/// // @options: {"max_output_tokens": 2000, "timeout_ms": 30000}
/// const text = await tools.read({ path: "package.json" });
/// text(JSON.parse(text).name);
/// ```
library;

import 'dart:convert';

/// Prefix that introduces the optional first-line options directive.
const String codeModeOptionsPrefix = '// @options:';

const String _supportedFieldsText = '`max_output_tokens` and `timeout_ms`';

/// Largest delay `setTimeout` supports, which bounds `timeout_ms`.
const int _maxTimeoutMs = 2147483647;

/// Lark grammar for providers with grammar-constrained tool input. It only
/// fixes the shape of the options line; the options JSON and the code are
/// checked by [parseCodemodeSource].
const String codeModeSourceGrammar = r'''
start: options_source | plain_source
options_source: OPTIONS_LINE NEWLINE SOURCE
plain_source: SOURCE

OPTIONS_LINE: /[ \t]*\/\/ @options:[^\r\n]*/
NEWLINE: /\r?\n/
SOURCE: /[\s\S]+/
''';

/// Options parsed from a leading `// @options:` line.
class CodemodeSourceOptions {
  /// Token budget for the script's output.
  final int? maxOutputTokens;

  /// Hard deadline for the whole script in milliseconds, including tool calls.
  final int? timeoutMs;

  /// Creates a codemode options value with optional [maxOutputTokens] and
  /// [timeoutMs] budgets.
  const CodemodeSourceOptions({this.maxOutputTokens, this.timeoutMs});

  @override
  bool operator ==(Object other) =>
      other is CodemodeSourceOptions &&
      other.maxOutputTokens == maxOutputTokens &&
      other.timeoutMs == timeoutMs;

  @override
  int get hashCode => Object.hash(maxOutputTokens, timeoutMs);

  @override
  String toString() =>
      'CodemodeSourceOptions(maxOutputTokens: $maxOutputTokens, timeoutMs: $timeoutMs)';
}

/// The result of [parseCodemodeSource].
class ParsedCodemodeSource {
  /// The script with the options line replaced by an empty line, so line
  /// numbers are unchanged.
  final String code;

  /// The parsed options.
  final CodemodeSourceOptions options;

  /// Creates a parsed result from [code] and [options].
  const ParsedCodemodeSource({required this.code, required this.options});

  @override
  bool operator ==(Object other) =>
      other is ParsedCodemodeSource &&
      other.code == code &&
      other.options == options;

  @override
  int get hashCode => Object.hash(code, options);

  @override
  String toString() => 'ParsedCodemodeSource(code: $code, options: $options)';
}

/// Error thrown for invalid codemode source or options.
class CodemodeSourceError implements Exception {
  /// The human-readable failure message.
  final String message;

  /// Creates an error carrying [message].
  CodemodeSourceError(this.message);

  @override
  String toString() => 'CodemodeSourceError: $message';
}

// Largest exactly-representable integer in the JS `Number.isSafeInteger` sense.
const int _maxSafeInteger = 9007199254740991;

CodemodeSourceOptions _parseOptions(String directive) {
  if (directive.isEmpty) {
    throw CodemodeSourceError(
        '@options must be a JSON object with supported fields $_supportedFieldsText');
  }
  Object? value;
  try {
    value = jsonDecode(directive);
  } catch (error) {
    // Match upstream, which appends `error.message` (not `String(error)`).
    // Interpolating the whole exception leaks the Dart runtime type and a
    // runtime-specific message; use the message alone for a stable detail.
    final detail = error is FormatException ? error.message : error.toString();
    throw CodemodeSourceError(
        '@options must be valid JSON with supported fields $_supportedFieldsText: $detail');
  }
  if (value is! Map<String, Object?>) {
    throw CodemodeSourceError(
        '@options must be a JSON object with supported fields $_supportedFieldsText');
  }
  for (final key in value.keys) {
    if (key != 'max_output_tokens' && key != 'timeout_ms') {
      throw CodemodeSourceError(
          '@options only supports $_supportedFieldsText; got `$key`');
    }
  }
  final maxOutputTokens = value['max_output_tokens'];
  final timeoutMs = value['timeout_ms'];
  int? parsedMaxOutputTokens;
  int? parsedTimeoutMs;
  if (maxOutputTokens != null) {
    if (maxOutputTokens is! int ||
        maxOutputTokens < 0 ||
        maxOutputTokens > _maxSafeInteger) {
      throw CodemodeSourceError(
          '@options field `max_output_tokens` must be a non-negative safe integer');
    }
    parsedMaxOutputTokens = maxOutputTokens;
  }
  if (timeoutMs != null) {
    if (timeoutMs is! int || timeoutMs == 0 || timeoutMs > _maxTimeoutMs) {
      throw CodemodeSourceError(
          '@options field `timeout_ms` must be a positive integer up to $_maxTimeoutMs');
    }
    parsedTimeoutMs = timeoutMs;
  }
  return CodemodeSourceOptions(
      maxOutputTokens: parsedMaxOutputTokens, timeoutMs: parsedTimeoutMs);
}

/// Split an optional first-line `// @options: {...}` from the script.
///
/// Throws [CodemodeSourceError] for empty input, invalid options, and an
/// options line that is not the first line, which would otherwise be ignored
/// without notice.
ParsedCodemodeSource parseCodemodeSource(String input) {
  if (input.trim().isEmpty) {
    throw CodemodeSourceError(
        'Expected JavaScript source text (non-empty). Provide JS only, optionally with a first line `// @options: {"max_output_tokens": 1000}`.');
  }
  final lines = input.split('\n');
  for (var index = 0; index < lines.length; index++) {
    if (index > 0 &&
        lines[index].trimLeft().startsWith(codeModeOptionsPrefix)) {
      throw CodemodeSourceError(
          'The $codeModeOptionsPrefix line must be the first line of the input; found one on line ${index + 1}');
    }
  }
  final newline = input.indexOf('\n');
  final firstLine = lines[0].replaceAll(RegExp(r'\r$'), '');
  final trimmed = firstLine.trimLeft();
  if (!trimmed.startsWith(codeModeOptionsPrefix)) {
    return ParsedCodemodeSource(
        code: input, options: const CodemodeSourceOptions());
  }
  final code = newline == -1 ? '' : input.substring(newline);
  if (code.trim().isEmpty) {
    throw CodemodeSourceError(
        'The @options line must be followed by JavaScript source on subsequent lines');
  }
  return ParsedCodemodeSource(
      code: code,
      options: _parseOptions(
          trimmed.substring(codeModeOptionsPrefix.length).trim()));
}
