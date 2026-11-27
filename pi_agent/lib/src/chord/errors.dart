/// Chord's error type, its codes and reasons, and its wire form; and the error a
/// plugin throws for its callers.
///
/// Port of `packages/chord/src/data/errors.ts` at upstream
/// `780bf31fcaeb252fa9b68df3964c735eae75bde3`.
library;

import 'json.dart';

/// Version of the error table below on links; adding or moving a code or reason
/// bumps it.
// The ported name matches the upstream export and the coverage registry.
// ignore: constant_identifier_names
const int PROTOCOL_VERSION = 1;

/// Every code with the reasons it may carry. `invalid` requires a reason; every
/// other code may omit it.
// The ported name matches the upstream export and the coverage registry.
// ignore: constant_identifier_names
const Map<String, List<String>> CHORD_ERROR_REASONS = <String, List<String>>{
  'invalid': <String>[
    'args',
    'params',
    'member',
    'host_address',
    'reentrant',
    'read_after_bulk',
    'cycle'
  ],
  'contract_mismatch': <String>['updating'],
  'forbidden': <String>['revoked'],
  'gone': <String>[],
  'not_ready': <String>[],
  'released': <String>['ended', 'closed', 'settled', 'version', 'discarded'],
  'too_large': <String>['part'],
  'unavailable': <String>[
    'locked',
    'park_timeout',
    'busy',
    'storage_failed',
    'undeclared',
    'version',
    'reload_cycle',
  ],
  'aborted': <String>[],
};

/// A Chord failure: a [code], an optional [reason] allowed for it, a [message],
/// and JSON [details]. Narrowing on [code] narrows [reason].
///
/// Upstream is a class intersected with a per-code tagged object so a wrong
/// code/reason pairing fails to type; Dart cannot express that, so the pairing
/// is a decided invariant the [chordErrorFromJson] boundary checks.
class ChordError extends Error {
  /// A failure with the given [code], optional [reason] and [details].
  ChordError({
    required this.code,
    required this.message,
    this.reason,
    this.details,
  });

  /// The failure code.
  final String code;

  /// The reason, allowed for [code]; `null` when the code carries none.
  final String? reason;

  /// A human-readable message; never a stack or a cause.
  final String message;

  /// JSON details carried by reference.
  final JsonValue details;

  /// The error's name.
  String get name => 'ChordError';

  /// The wire form; stack and cause never cross a link.
  Map<String, Object?> toJSON() => <String, Object?>{
        'code': code,
        if (reason != null) 'reason': reason,
        'message': message,
        if (details != null) 'details': details,
      };
}

/// Whether [error] is a [ChordError], optionally with the given [code].
bool isChordError(Object? error, [String? code]) =>
    error is ChordError && (code == null || error.code == code);

/// An error a plugin throws for its callers: its own [code], a [message] and
/// JSON [details]. Only these cross a link; a consumer rethrows it.
class PluginError extends Error {
  /// A plugin error with the given [code], [message] and optional [details].
  PluginError(this.code, this.message, [this.details]);

  /// The plugin's own code.
  final String code;

  /// The error's name.
  String get name => 'PluginError';

  /// The error message.
  final String message;

  /// JSON details.
  final JsonValue details;
}

/// An `invalid` error with the given [reason]: a plugin throws it for arguments
/// or params it refuses.
ChordError invalid(String reason, String message, [JsonValue details]) =>
    ChordError(
        code: 'invalid', reason: reason, message: message, details: details);

/// A `forbidden` error without a reason: what a plugin or an `authorize` throws
/// for a principal it refuses.
ChordError forbidden(String message, [JsonValue details]) =>
    ChordError(code: 'forbidden', message: message, details: details);

/// [error] itself when it is a [ChordError], otherwise an `unavailable` error
/// naming [label], with [error]'s message appended.
ChordError asChordError(Object? error, String label) {
  if (error is ChordError) return error;
  final message = error is Error ? error.toString() : error.toString();
  return ChordError(code: 'unavailable', message: '$label: $message');
}

/// Rebuilds a [ChordError] from a link. Checks the envelope only: a known code,
/// a reason allowed for it (required for `invalid`), a string message, no other
/// keys. [details] is kept by reference.
ChordError chordErrorFromJson(Object? raw) {
  // Trust boundary: `raw` is fresh JSON from the link decoder.
  if (raw is! Map) throw const ChordErrorEnvelopeException('not an object');
  for (final key in raw.keys) {
    if (key is! String || !_envelopeKeys.contains(key)) {
      throw ChordErrorEnvelopeException('unknown key "$key"');
    }
  }
  final code = raw['code'];
  if (code is! String || !CHORD_ERROR_REASONS.containsKey(code)) {
    throw const ChordErrorEnvelopeException('unknown code');
  }
  final reasons = CHORD_ERROR_REASONS[code]!;
  final reason = raw['reason'];
  if (reason == null) {
    if (code == 'invalid') {
      throw const ChordErrorEnvelopeException('reason not allowed for invalid');
    }
  } else if (reason is! String || !reasons.contains(reason)) {
    throw ChordErrorEnvelopeException('reason not allowed for $code');
  }
  final message = raw['message'];
  if (message is! String) {
    throw const ChordErrorEnvelopeException('message is not a string');
  }
  return ChordError(
    code: code,
    reason: reason as String?,
    message: message,
    details: raw['details'] as JsonValue,
  );
}

const Set<String> _envelopeKeys = <String>{
  'code',
  'reason',
  'message',
  'details'
};

/// Thrown by [chordErrorFromJson] for a malformed wire envelope.
class ChordErrorEnvelopeException implements Exception {
  /// The envelope problem.
  const ChordErrorEnvelopeException(this.message);

  /// The problem, without the `Invalid ChordError JSON: ` prefix.
  final String message;

  @override
  String toString() => 'Invalid ChordError JSON: $message';
}
