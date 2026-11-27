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

/// The error's message without a Dart runtime type prefix: the upstream
/// `error.message` this port cannot read off the base [Error] (Dart's [Error]
/// has no `message`). The message-bearing errors are unwrapped; anything else
/// falls back to `toString()`, as upstream does for a non-`Error` value.
String chordErrorMessage(Object? error) {
  if (error is StateError) return error.message;
  if (error is ArgumentError) {
    final message = error.message;
    return message is String ? message : error.toString();
  }
  if (error is FormatException) return error.message;
  return error.toString();
}

/// Distinguishes an omitted [details] from an explicit `null` at the
/// [ChordError] boundary, where both would otherwise read as `null`.
const Object _unsetDetails = Object();

/// A Chord failure: a [code], an optional [reason] allowed for it, a [message],
/// and JSON [details]. Narrowing on [code] narrows [reason].
///
/// Upstream is a class intersected with a per-code tagged object so a wrong
/// code/reason pairing fails to type; Dart cannot express that, so the pairing
/// is a decided invariant the [chordErrorFromJson] boundary checks.
class ChordError extends Error {
  /// A failure with the given [code], optional [reason] and [details]. An
  /// omitted [details] and an explicit `null` [details] differ on the wire and
  /// are kept apart; [cause] is the wrapped error and never crosses a link.
  ChordError({
    required this.code,
    required this.message,
    this.reason,
    Object? details = _unsetDetails,
    this.cause,
  })  : _hasDetails = !identical(details, _unsetDetails),
        details = details;

  /// The failure code.
  final String code;

  /// The reason, allowed for [code]; `null` when the code carries none.
  final String? reason;

  /// A human-readable message; never a stack or a cause.
  final String message;

  /// JSON details carried by reference; `null` when the code carries none.
  final JsonValue details;

  /// The wrapped error, for a failure built from another; never serialized.
  final Object? cause;

  final bool _hasDetails;

  /// The error's name.
  String get name => 'ChordError';

  /// The wire form; stack and cause never cross a link.
  Map<String, Object?> toJSON() => <String, Object?>{
        'code': code,
        if (reason != null) 'reason': reason,
        'message': message,
        if (_hasDetails) 'details': details,
      };

  @override
  String toString() => '$name: $message';
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

  @override
  String toString() => '$name: $message';
}

/// An `invalid` error with the given [reason]: a plugin throws it for arguments
/// or params it refuses.
ChordError invalid(String reason, String message,
        [Object? details = _unsetDetails]) =>
    ChordError(
        code: 'invalid', reason: reason, message: message, details: details);

/// A `forbidden` error without a reason: what a plugin or an `authorize` throws
/// for a principal it refuses.
ChordError forbidden(String message, [Object? details = _unsetDetails]) =>
    ChordError(code: 'forbidden', message: message, details: details);

/// [error] itself when it is a [ChordError], otherwise an `unavailable` error
/// naming [label], with [error]'s message appended and [error] kept as cause.
ChordError asChordError(Object? error, String label) {
  if (error is ChordError) return error;
  final message = chordErrorMessage(error);
  return ChordError(
      code: 'unavailable', message: '$label: $message', cause: error);
}

/// Distinguishes an omitted `reason` key from an explicit JSON `null` reason.
const Object _unsetReason = Object();

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
  // An omitted reason and an explicit JSON null differ: `invalid` requires a
  // reason, and a present reason must be one allowed for the code (so a null is
  // rejected), matching the upstream `reason === undefined` check.
  final reason = raw.containsKey('reason') ? raw['reason'] : _unsetReason;
  if (identical(reason, _unsetReason)) {
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
    reason: identical(reason, _unsetReason) ? null : reason as String?,
    message: message,
    details: raw.containsKey('details')
        ? raw['details'] as JsonValue
        : _unsetDetails,
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
