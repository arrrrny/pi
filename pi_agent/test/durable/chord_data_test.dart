// Chord data: the error type and its wire form, and the failure causes an
// object or a dependent carries.
//
// Port of `packages/chord/test/data/errors.test.ts` and
// `packages/chord/test/data/failure.test.ts` at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`.

import 'package:pi/durable.dart';
import 'package:test/test.dart';

void main() {
  group('ChordError', () {
    test('round-trips through JSON without stack or cause', () {
      final error = ChordError(
        code: 'invalid',
        reason: 'args',
        message: 'args/text: bad',
        details: <String, Object?>{'path': '/text'},
      );
      final json = error.toJSON();
      expect(json, <String, Object?>{
        'code': 'invalid',
        'reason': 'args',
        'message': 'args/text: bad',
        'details': <String, Object?>{'path': '/text'},
      });
      final back = chordErrorFromJson(json);
      expect(back, isA<ChordError>());
      expect(back.toJSON(), json);
      expect(
        ChordError(code: 'gone', message: 'm').toJSON(),
        <String, Object?>{'code': 'gone', 'message': 'm'},
      );
    });

    test('keeps details by reference', () {
      final details = <String, Object?>{
        'large': <Object?>[1, 2, 3]
      };
      expect(
          chordErrorFromJson(<String, Object?>{
            'code': 'gone',
            'message': 'm',
            'details': details,
          }).details,
          same(details));
    });

    test('chordErrorFromJson refuses a malformed envelope', () {
      void refuses(Object? raw, String problem) {
        expect(
          () => chordErrorFromJson(raw),
          throwsA(isA<ChordErrorEnvelopeException>().having((e) => e.toString(),
              'toString', 'Invalid ChordError JSON: $problem')),
        );
      }

      refuses('x', 'not an object');
      refuses(null, 'not an object');
      refuses(<Object?>[], 'not an object');
      refuses(<String, Object?>{'code': 'gone', 'message': 'm', 'stack': 's'},
          'unknown key "stack"');
      refuses(
          <String, Object?>{'code': 'teapot', 'message': 'm'}, 'unknown code');
      refuses(<String, Object?>{'code': 'toString', 'message': 'm'},
          'unknown code');
      refuses(<String, Object?>{'code': 1, 'message': 'm'}, 'unknown code');
      refuses(<String, Object?>{'code': 'invalid', 'message': 'm'},
          'reason not allowed for invalid');
      refuses(
          <String, Object?>{'code': 'gone', 'reason': 'args', 'message': 'm'},
          'reason not allowed for gone');
      refuses(<String, Object?>{
        'code': 'unavailable',
        'reason': 'part',
        'message': 'm'
      }, 'reason not allowed for unavailable');
      refuses(<String, Object?>{'code': 'gone', 'message': 1},
          'message is not a string');
    });
  });

  group('protocol table', () {
    test('is pinned together with PROTOCOL_VERSION', () {
      const pinned = <String, Object?>{
        'version': 1,
        'reasons': <String, Object?>{
          'invalid': <String>[
            'args',
            'params',
            'member',
            'host_address',
            'reentrant',
            'read_after_bulk',
            'cycle',
          ],
          'contract_mismatch': <String>['updating'],
          'forbidden': <String>['revoked'],
          'gone': <String>[],
          'not_ready': <String>[],
          'released': <String>[
            'ended',
            'closed',
            'settled',
            'version',
            'discarded'
          ],
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
        },
      };
      final actual = <String, Object?>{
        'version': PROTOCOL_VERSION,
        'reasons': CHORD_ERROR_REASONS,
      };
      expect(actual, pinned);
    });
  });

  group('helpers', () {
    test('isChordError checks the class and optionally the code', () {
      final error = invalid('member', 'no method');
      expect(isChordError(error), isTrue);
      expect(isChordError(error, 'invalid'), isTrue);
      expect(isChordError(error, 'gone'), isFalse);
      expect(isChordError(StateError('x')), isFalse);
      expect(
        isChordError(<String, Object?>{
          'code': 'invalid',
          'reason': 'member',
          'message': 'm',
        }),
        isFalse,
      );
    });

    test('invalid builds an invalid error with its reason and details', () {
      final error = invalid(
          'params', 'params/a: missing', <String, Object?>{'path': '/a'});
      expect(error.toJSON(), <String, Object?>{
        'code': 'invalid',
        'reason': 'params',
        'message': 'params/a: missing',
        'details': <String, Object?>{'path': '/a'},
      });
      expect(error.code, 'invalid');
    });

    test(
        'asChordError keeps a ChordError and wraps anything else as unavailable',
        () {
      final chord = invalid('cycle', 'c');
      expect(asChordError(chord, 'open'), same(chord));
      final foreign = TypeError();
      final wrapped = asChordError(foreign, 'open notes');
      expect(wrapped.code, 'unavailable');
      expect(wrapped.message, startsWith('open notes:'));
      expect(asChordError('text', 'open').message, 'open: text');
    });
  });

  group('PluginError', () {
    test("carries a plugin's code, message and JSON details", () {
      final error =
          PluginError('quota', 'too many', <String, Object?>{'limit': 3});
      expect(error, isA<Error>());
      expect(error.code, 'quota');
      expect(error.message, 'too many');
      expect(error.details, <String, Object?>{'limit': 3});
      expect(PluginError('c', 'm').details, isNull);
    });
  });

  group('failure causes', () {
    test('a value thrown by an open is transient unless marked broken', () {
      final error = StateError('network down');
      final transient = openFailure(error, 'open notes');
      expect(transient.kind, 'transient');
      expect(transient.error.toJSON(), <String, Object?>{
        'code': 'unavailable',
        'message': 'open notes: ${error.toString()}',
      });
    });

    test(
        "broken() marks an open's failure as broken; its message is the cause's",
        () {
      final marked = broken(StateError('bad config'));
      expect(marked.message, 'Bad state: bad config');
      final cause = openFailure(marked, 'open notes');
      expect(cause.kind, 'broken');
      expect(cause.error.message, 'open notes: Bad state: bad config');
    });

    test('the kind comes from the stage, never from the error code', () {
      final chord = invalid('host_address', 'wrong host');
      expect(openFailure(chord, 'open').error, same(chord));
      expect(openFailure(broken(chord), 'open').kind, 'broken');
    });
  });

  group("a dependent's waiting cause", () {
    final root = ChordError(
      code: 'unavailable',
      message: 'app.catalog is not served here',
    );

    test('names the nearest blocker and the root cause', () {
      final cause = waitingFor('app.chat(S1)', root);
      expect(cause.kind, 'waiting');
      expect(cause.error.toJSON(), <String, Object?>{
        'code': 'unavailable',
        'message': 'waiting for app.chat(S1): app.catalog is not served here',
      });
      final chain = waitingFor('app.panel', cause.error);
      expect(chain.error.message,
          'waiting for app.panel: app.catalog is not served here');
    });

    test(
        'reaches a fixed point when a ring of waiting attempts passes its causes round',
        () {
      var b = waitingFor('X',
              ChordError(code: 'unavailable', message: 'X is not served here'))
          .error;
      var rounds = 0;
      for (; rounds < 10; rounds++) {
        final next = waitingFor('A', waitingFor('B', b).error).error;
        if (next.message == b.message) break;
        b = next;
      }
      expect(rounds, lessThanOrEqualTo(1));
      expect(b.message, 'waiting for A: X is not served here');
    });

    test(
        'keeps the root cause within 500 characters: a long label is clipped first',
        () {
      final original = ChordError(
          code: 'unavailable', message: 'ORIGINAL: missing provider');
      final message =
          waitingFor('sol.item(${'x' * 600})', original).error.message;
      expect(message.length, lessThanOrEqualTo(500));
      expect(message, contains(original.message));
      expect(message.startsWith('waiting for sol.item(xxx'), isTrue);
    });

    test('keeps a long chain root cause, never repeated ellipses', () {
      final original = ChordError(
          code: 'unavailable', message: 'ORIGINAL: missing provider');
      var error = original;
      for (var i = 0; i < 2000; i++) {
        error = waitingFor('level-$i', error).error;
      }
      expect(
          error.message, 'waiting for level-1999: ORIGINAL: missing provider');
    });

    test('clips a long root past its share, and both when both are long', () {
      final long = ChordError(code: 'unavailable', message: 'y' * 600);
      final short = waitingFor('app.a', long).error.message;
      expect(short.length, 500);
      expect(short.startsWith('waiting for app.a: yyy'), isTrue);
      final both = waitingFor('z' * 600, long).error.message;
      expect(both.length, 500);
      expect(both.endsWith('y\u2026'), isTrue);
    });

    test('is compared by value: kind, code, reason and message', () {
      expect(sameCause(waitingFor('a', root), waitingFor('a', root)), isTrue);
      expect(sameCause(waitingFor('a', root), waitingFor('b', root)), isFalse);
      expect(
        sameCause(
          FailureCause.broken(root),
          FailureCause.transient(root),
        ),
        isFalse,
      );
      final other = ChordError(
        code: 'unavailable',
        reason: 'undeclared',
        message: 'app.catalog is not served here',
      );
      expect(
        sameCause(FailureCause.waiting(root), FailureCause.waiting(other)),
        isFalse,
      );
    });
  });
}
