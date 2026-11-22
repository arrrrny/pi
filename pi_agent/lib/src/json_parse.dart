/// Port of upstream `packages/ai/src/utils/json-parse.ts`.
///
/// Turns the model's complete tool-call argument text into an argument map,
/// reporting — never swallowing — a parse failure so tool validation can fail
/// closed and report the problem back to the model.
library;

import 'dart:convert';

/// Characters that are valid JSON escapes after a backslash.
const Set<String> _validJsonEscapes = {
  '"',
  r'\',
  '/',
  'b',
  'f',
  'n',
  'r',
  't',
};

/// Whether [char] is a raw U+0000–U+001F control character.
bool _isControlCharacter(String char) {
  final codePoint = char.codeUnitAt(0);
  return codePoint <= 0x1f;
}

/// Renders [char] as the JSON escape sequence that represents it.
String _escapeControlCharacter(String char) => switch (char) {
      '\b' => r'\b',
      '\f' => r'\f',
      '\n' => r'\n',
      '\r' => r'\r',
      '\t' => r'\t',
      _ => '\\u${char.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}',
    };

/// Repairs malformed JSON string literals by escaping raw control characters
/// inside strings and doubling backslashes before invalid escape characters.
String repairJson(String json) {
  final repaired = StringBuffer();
  var inString = false;

  for (var index = 0; index < json.length; index++) {
    final char = json[index];

    if (!inString) {
      repaired.write(char);
      if (char == '"') inString = true;
      continue;
    }

    if (char == '"') {
      repaired.write(char);
      inString = false;
      continue;
    }

    if (char == r'\') {
      final nextChar = index + 1 < json.length ? json[index + 1] : null;
      if (nextChar == null) {
        repaired.write(r'\\');
        continue;
      }

      if (nextChar == 'u') {
        final unicodeDigits = index + 6 <= json.length
            ? json.substring(index + 2, index + 6)
            : '';
        if (RegExp(r'^[0-9a-fA-F]{4}$').hasMatch(unicodeDigits)) {
          repaired.write('\\u$unicodeDigits');
          index += 5;
          continue;
        }
      }

      if (_validJsonEscapes.contains(nextChar)) {
        repaired.write('\\$nextChar');
        index += 1;
        continue;
      }

      repaired.write(r'\\');
      continue;
    }

    repaired.write(
        _isControlCharacter(char) ? _escapeControlCharacter(char) : char);
  }

  return repaired.toString();
}

/// Decodes [json], retrying once against [repairJson] when the first parse fails.
T parseJsonWithRepair<T>(String json) {
  try {
    return jsonDecode(json) as T;
  } on FormatException {
    final repairedJson = repairJson(json);
    if (repairedJson == json) rethrow;
    return jsonDecode(repairedJson) as T;
  }
}

/// The outcome of parsing a finished tool call's argument text.
///
/// [arguments] is always a usable map — an empty one when parsing failed — and
/// [argumentsError] carries the diagnostic when it did, including the text the
/// model sent. An empty or whitespace-only buffer is a legitimately argument-less
/// call, so it reports no error.
class ParsedToolArguments {
  /// The decoded arguments, or an empty map when [argumentsError] is set.
  final Map<String, dynamic> arguments;

  /// The parse failure and the received text, or null when parsing succeeded.
  final String? argumentsError;

  /// Creates a parsed tool-arguments result.
  const ParsedToolArguments({required this.arguments, this.argumentsError});
}

/// Parses the model's complete argument text of a finished tool call.
///
/// Unlike a streaming parser, this never keeps a partially parsed prefix: once
/// the call is finished, text that is not a valid JSON object means the model
/// sent malformed arguments, and the failure is reported rather than replaced by
/// a silent empty map.
ParsedToolArguments parseToolCallArguments(String? json) {
  if (json == null || json.trim().isEmpty) {
    return const ParsedToolArguments(arguments: <String, dynamic>{});
  }
  try {
    final parsed = parseJsonWithRepair<dynamic>(json);
    if (parsed is! Map<String, dynamic>) {
      throw const FormatException('Tool arguments must be a JSON object');
    }
    return ParsedToolArguments(arguments: parsed);
  } catch (error) {
    return ParsedToolArguments(
      arguments: const <String, dynamic>{},
      argumentsError: '${_messageOf(error)}\n\nReceived arguments:\n$json',
    );
  }
}

/// The human-readable message of [error], without the type prefix Dart adds.
String _messageOf(Object error) =>
    error is FormatException ? error.message : error.toString();
