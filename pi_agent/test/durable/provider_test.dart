// Provider session identity: a stable provider-facing id per conversation.
//
// Port of `packages/durable/src/harness/provider.ts` and the `uuidv7` generator
// it uses (`packages/ai/src/utils/uuid.ts`) at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`. The `defineDoc` wiring
// (`ProviderDoc`, `ensureProviderSessionId`) depends on `documents.dart` and the
// `TaskRuntime` seam, which the pi#11 foundation did not land; this file ports
// the testable core (`ProviderState`, `uuidv7`) and leaves the document wiring
// to that layer (coverage row `durable.provider.identity` stays `in_progress`).

import 'package:pi/durable.dart';
import 'package:test/test.dart';

void main() {
  group('uuidv7', () {
    test('is a version-7 UUID in canonical form', () {
      final id = uuidv7();
      expect(
          id,
          matches(
            RegExp(
                r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'),
          ));
    });

    test('is time-ordered across calls', () {
      final first = uuidv7(1000);
      final second = uuidv7(1000);
      final third = uuidv7(2000);
      // Same timestamp: sequence increases, so lexical order still holds.
      expect(first.compareTo(second), lessThanOrEqualTo(0));
      expect(second.compareTo(third), lessThan(0));
    });

    test('rejects an out-of-range timestamp', () {
      expect(() => uuidv7(-1), throwsA(isA<RangeError>()));
      expect(() => uuidv7(0xffffffffffff + 1), throwsA(isA<RangeError>()));
    });

    test('preserves a supplied timestamp for follower ids', () {
      final id = uuidv7(0x0102030405);
      // The first 12 hex digits (8+4) encode the 48-bit timestamp.
      expect(id.substring(0, 13).replaceAll('-', ''), '000102030405');
    });
  });

  group('ProviderState', () {
    test('round-trips through JSON', () {
      const state = ProviderState('session-123');
      expect(state.toJson(), <String, Object?>{'sessionId': 'session-123'});
      expect(
          ProviderState.fromJson(<String, Object?>{'sessionId': 'session-123'})
              .sessionId,
          'session-123');
    });
  });
}
