// Provider session identity: a stable provider-facing id per conversation.
//
// Port of `packages/durable/src/harness/provider.ts` and the `uuidv7` generator
// it uses (`packages/ai/src/utils/uuid.ts`) at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`. `ProviderState` and `uuidv7` are
// ported faithfully. The `defineDoc` wiring (`ProviderDoc`,
// `ensureProviderSessionId`) depends on `documents.dart` and the `TaskRuntime`
// seam, which the pi#11 foundation slice did not land; it is left to the layer
// that ports documents, and `verified_upstream_sha` is not advanced for it
// (coverage row `durable.provider.identity` stays `in_progress`).
library;

import 'dart:math';

/// Stable provider-facing identity of one conversation. Port of upstream
/// `ProviderState`.
class ProviderState {
  /// A provider identity.
  const ProviderState(this.sessionId);

  /// The provider session id.
  final String sessionId;

  /// This state as strict JSON.
  Map<String, Object?> toJson() => <String, Object?>{'sessionId': sessionId};

  /// A state decoded from [json].
  factory ProviderState.fromJson(Map<String, Object?> json) =>
      ProviderState(json['sessionId']! as String);
}

const int _maxUuidV7Timestamp = 0xffffffffffff;
final BigInt _maxSequence = (BigInt.one << 41) - BigInt.one;

int _lastOrdinaryTimestamp = -1;
BigInt? _sequence;
final Random _random = Random();

/// The next ordinary timestamp: never below the last one issued.
int _nextTimestamp(int requested) => max(requested, _lastOrdinaryTimestamp);

/// Generate a time-ordered UUIDv7. A supplied timestamp is preserved for
/// follower ids. Port of upstream `uuidv7`.
String uuidv7([int? timestampMs]) {
  final requestedTimestamp =
      timestampMs ?? DateTime.now().millisecondsSinceEpoch;
  if (requestedTimestamp < 0 || requestedTimestamp > _maxUuidV7Timestamp) {
    throw RangeError(
      'UUIDv7 timestamp must be an integer between 0 and $_maxUuidV7Timestamp',
    );
  }

  final effectiveTimestamp = timestampMs ?? _nextTimestamp(requestedTimestamp);
  if (timestampMs == null) _lastOrdinaryTimestamp = effectiveTimestamp;

  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  if (_sequence == null) {
    _sequence = (BigInt.from(bytes[1]) << 32) |
        (BigInt.from(bytes[2]) << 24) |
        (BigInt.from(bytes[3]) << 16) |
        (BigInt.from(bytes[4]) << 8) |
        BigInt.from(bytes[5]);
  } else {
    if (_sequence == _maxSequence) {
      throw RangeError('UUIDv7 generator sequence exhausted');
    }
    _sequence = _sequence! + BigInt.one;
  }
  final sequence = _sequence!;

  final timestamp = BigInt.from(effectiveTimestamp);
  for (var index = 5; index >= 0; index--) {
    bytes[index] =
        ((timestamp >> ((5 - index) * 8)) & BigInt.from(0xff)).toInt();
  }
  bytes[6] = 0x70 | ((sequence >> 37) & BigInt.from(0x0f)).toInt();
  bytes[7] = ((sequence >> 29) & BigInt.from(0xff)).toInt();
  bytes[8] = 0x80 | ((sequence >> 23) & BigInt.from(0x3f)).toInt();
  bytes[9] = ((sequence >> 15) & BigInt.from(0xff)).toInt();
  bytes[10] = ((sequence >> 7) & BigInt.from(0xff)).toInt();
  bytes[11] =
      ((sequence & BigInt.from(0x7f)) << 1).toInt() | (bytes[11] & 0x01);

  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
  final h = hex.join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}
