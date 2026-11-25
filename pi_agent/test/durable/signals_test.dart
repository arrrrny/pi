// Signals: typed JSON values delivered to a live task, kept in its memos until
// a wake uses them. Port of `packages/durable/src/signals.ts` at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`.

import 'package:pi/durable.dart';
import 'package:test/test.dart';

/// A signal whose value is an object `{ text: string }`, the test's `Answer`.
SignalToken<Object?> answerToken() => defineSignal<Object?>(
      name: 'test.answer',
      version: 1,
      schema: JsonSchema.object(<String, JsonSchema>{
        'text': JsonSchema.string,
      }),
    );

TaskRecord<Object?, Object?, Object?> _record({
  required TaskState<Object?, Object?> state,
  bool abortRequested = false,
  Map<String, Object?>? memos,
}) =>
    TaskRecord<Object?, Object?, Object?>(
      id: idFromNumber<TaskKind>(7),
      conversationId: rootConversationId,
      kind: 'test.ask',
      version: 1,
      input: null,
      state: state,
      abortRequested: abortRequested,
      memos: memos,
    );

/// A trivial checkpoint: a sleeping task's durable state is opaque here.
Object? _checkpoint() => <String, Object?>{'phase': 'answered'};

TaskSleeping<Object?, Object?> _sleeping({
  int? until,
  List<SignalKey<Object?>>? signals,
}) =>
    TaskSleeping<Object?, Object?>(
      _checkpoint(),
      until: until,
      signals: signals == null
          ? null
          : <SignalName>[
              for (final key in signals)
                SignalName(signalMemoName(key.signal, key.key)),
            ],
    );

void main() {
  group('defineSignal', () {
    test('builds a token and a typed key', () {
      final token = answerToken();
      expect(token.name, 'test.answer');
      expect(token.version, 1);
      final key = token.key('k1');
      expect(key.signal, 'test.answer');
      expect(key.key, 'k1');
    });

    test('refuses an empty name or a name with a slash', () {
      expect(
        () => defineSignal(
          name: '',
          version: 1,
          schema: JsonSchema.any,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => defineSignal(
          name: 'a/b',
          version: 1,
          schema: JsonSchema.any,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('refuses a version that is not a positive integer', () {
      expect(
        () => defineSignal(name: 's', version: 0, schema: JsonSchema.any),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('refuses an empty key', () {
      final token = answerToken();
      expect(() => token.key(''), throwsA(isA<ArgumentError>()));
    });
  });

  group('deliverSignal', () {
    test('not_found when there is no record', () {
      final token = answerToken();
      final out = deliverSignal<Object?>(
        null,
        token,
        'k1',
        <String, Object?>{'text': 'hi'},
        0,
      );
      expect(out.result, SignalResult.notFound);
      expect(out.record, isNull);
    });

    test('closed when the task is terminal', () {
      final token = answerToken();
      final out = deliverSignal<Object?>(
        _record(
            state: const TaskTerminal<Object?, Object?>(
          TaskCompleted<Object?>(null),
        )),
        token,
        'k1',
        <String, Object?>{'text': 'hi'},
        0,
      );
      expect(out.result, SignalResult.closed);
    });

    test('closed when the task is completing', () {
      final token = answerToken();
      final out = deliverSignal<Object?>(
        _record(
            state: const TaskCompleting<Object?, Object?>(
          TaskCompleted<Object?>(null),
        )),
        token,
        'k1',
        <String, Object?>{'text': 'hi'},
        0,
      );
      expect(out.result, SignalResult.closed);
    });

    test('closed when abort was requested', () {
      final token = answerToken();
      final out = deliverSignal<Object?>(
        _record(
          state: const TaskPending<Object?, Object?>(null),
          abortRequested: true,
        ),
        token,
        'k1',
        <String, Object?>{'text': 'hi'},
        0,
      );
      expect(out.result, SignalResult.closed);
    });

    test('invalid when the value does not match the schema', () {
      final token = answerToken();
      final out = deliverSignal<Object?>(
        _record(state: const TaskPending<Object?, Object?>(null)),
        token,
        'k1',
        <String, Object?>{'text': 3},
        0,
      );
      expect(out.result, SignalResult.invalid);
    });

    test('invalid for an empty key', () {
      final token = answerToken();
      final out = deliverSignal<Object?>(
        _record(state: const TaskPending<Object?, Object?>(null)),
        token,
        '',
        <String, Object?>{'text': 'hi'},
        0,
      );
      expect(out.result, SignalResult.invalid);
    });

    test('delivered stores the value under the signal memo', () {
      final token = answerToken();
      final out = deliverSignal<Object?>(
        _record(state: const TaskPending<Object?, Object?>(null)),
        token,
        'k1',
        <String, Object?>{'text': 'hi'},
        0,
      );
      expect(out.result, SignalResult.delivered);
      final memo = out.record!.memos!['pi.signal.test.answer/k1']!;
      expect((memo as Map<String, Object?>)['version'], 1);
      expect(((memo)['value'] as Map<String, Object?>),
          <String, Object?>{'text': 'hi'});
    });

    test('duplicate when the key already holds a value', () {
      final token = answerToken();
      final first = deliverSignal<Object?>(
        _record(state: const TaskPending<Object?, Object?>(null)),
        token,
        'k1',
        <String, Object?>{'text': 'hi'},
        0,
      );
      final second = deliverSignal<Object?>(
        first.record,
        token,
        'k1',
        <String, Object?>{'text': 'again'},
        0,
      );
      expect(second.result, SignalResult.duplicate);
    });

    test('closed when the key already expired', () {
      final token = answerToken();
      final record = _record(
        state: const TaskPending<Object?, Object?>(null),
        memos: <String, Object?>{
          'pi.signal.test.answer/k1': <String, Object?>{'expired': true},
        },
      );
      final out = deliverSignal<Object?>(
        record,
        token,
        'k1',
        <String, Object?>{'text': 'hi'},
        0,
      );
      expect(out.result, SignalResult.closed);
    });

    test('closed past the deadline marks the key expired', () {
      final token = answerToken();
      final key = token.key('k1');
      final out = deliverSignal<Object?>(
        _record(
            state: _sleeping(until: 10, signals: <SignalKey<Object?>>[key])),
        token,
        'k1',
        <String, Object?>{'text': 'hi'},
        20,
      );
      expect(out.result, SignalResult.closed);
      final memo = out.record!.memos!['pi.signal.test.answer/k1']!;
      expect((memo as Map<String, Object?>)['expired'], true);
    });
  });

  group('readSignal', () {
    test('undefined when nothing was delivered', () {
      final token = answerToken();
      expect(readSignal<Object?>(null, token, 'k1'), isNull);
    });

    test('value when the stored version matches', () {
      final token = answerToken();
      final record = _record(
        state: const TaskPending<Object?, Object?>(null),
        memos: <String, Object?>{
          'pi.signal.test.answer/k1': <String, Object?>{
            'version': 1,
            'value': <String, Object?>{'text': 'hi'},
          },
        },
      );
      final state = readSignal<Object?>(record.memos, token, 'k1');
      expect(state!.kind, SignalStateKind.value);
      expect((state as SignalValue<Object?>).value,
          <String, Object?>{'text': 'hi'});
    });

    test('expired when the key expired', () {
      final token = answerToken();
      final record = _record(
        state: const TaskPending<Object?, Object?>(null),
        memos: <String, Object?>{
          'pi.signal.test.answer/k1': <String, Object?>{'expired': true},
        },
      );
      final state = readSignal<Object?>(record.memos, token, 'k1');
      expect(state!.kind, SignalStateKind.expired);
    });

    test('throws for a stored version newer than the token', () {
      final token = answerToken();
      final record = _record(
        state: const TaskPending<Object?, Object?>(null),
        memos: <String, Object?>{
          'pi.signal.test.answer/k1': <String, Object?>{
            'version': 2,
            'value': <String, Object?>{'text': 'hi'},
          },
        },
      );
      expect(() => readSignal<Object?>(record.memos, token, 'k1'),
          throwsA(isA<StateError>()));
    });

    test('throws for an older version with no migration', () {
      final token = answerToken();
      final record = _record(
        state: const TaskPending<Object?, Object?>(null),
        memos: <String, Object?>{
          'pi.signal.test.answer/k1': <String, Object?>{
            'version': 0,
            'value': <String, Object?>{'text': 'hi'},
          },
        },
      );
      expect(() => readSignal<Object?>(record.memos, token, 'k1'),
          throwsA(isA<StateError>()));
    });
  });

  group('sleep helpers', () {
    test('checkSleep throws for a sleep with neither until nor signals', () {
      expect(
        () => checkSleep(_sleeping(), null, 7, const <SignalKey<Object?>>[]),
        throwsA(isA<StateError>()),
      );
    });

    test('checkSleep throws when a listed key already woke a wait', () {
      final token = answerToken();
      final key = token.key('k1');
      final memos = <String, Object?>{
        'pi.signal.test.answer/k1': <String, Object?>{
          'version': 1,
          'value': <String, Object?>{'text': 'hi'},
          'consumed': true,
        },
      };
      expect(
        () => checkSleep(_sleeping(signals: <SignalKey<Object?>>[key]), memos,
            7, <SignalKey<Object?>>[key]),
        throwsA(isA<StateError>()),
      );
    });

    test('sleepDue is true at the deadline', () {
      expect(
          sleepDue(
              _sleeping(until: 10), null, 10, const <SignalKey<Object?>>[]),
          isTrue);
      expect(
          sleepDue(_sleeping(until: 10), null, 9, const <SignalKey<Object?>>[]),
          isFalse);
    });

    test('sleepDue is true when a listed key holds a value', () {
      final token = answerToken();
      final key = token.key('k1');
      final memos = <String, Object?>{
        'pi.signal.test.answer/k1': <String, Object?>{
          'version': 1,
          'value': <String, Object?>{'text': 'hi'},
        },
      };
      expect(
        sleepDue(_sleeping(until: 100, signals: <SignalKey<Object?>>[key]),
            memos, 0, <SignalKey<Object?>>[key]),
        isTrue,
      );
    });

    test('sleepWake consumes the first ready key', () {
      final token = answerToken();
      final key = token.key('k1');
      final memos = <String, Object?>{
        'pi.signal.test.answer/k1': <String, Object?>{
          'version': 1,
          'value': <String, Object?>{'text': 'hi'},
        },
      };
      final out = sleepWake(
        _sleeping(until: 100, signals: <SignalKey<Object?>>[key]),
        memos,
        0,
        <SignalKey<Object?>>[key],
      )!;
      expect(out.wake, isA<WakeSignal>());
      expect((out.wake as WakeSignal).signal, 'test.answer');
      expect((out.wake as WakeSignal).key, 'k1');
      final consumed =
          out.memos['pi.signal.test.answer/k1']! as Map<String, Object?>;
      expect(consumed['consumed'], true);
    });

    test('sleepWake at the deadline with no listed signals wakes by time', () {
      final out = sleepWake(
          _sleeping(until: 10), null, 10, const <SignalKey<Object?>>[])!;
      expect(out.wake, isA<WakeTime>());
    });

    test('sleepWake at the deadline marks unfilled keys expired', () {
      final token = answerToken();
      final key = token.key('k1');
      final out = sleepWake(
        _sleeping(until: 10, signals: <SignalKey<Object?>>[key]),
        null,
        10,
        <SignalKey<Object?>>[key],
      )!;
      expect(out.wake, isA<WakeExpired>());
      final expired =
          out.memos['pi.signal.test.answer/k1']! as Map<String, Object?>;
      expect(expired['expired'], true);
    });

    test('sleepWake is undefined before the deadline', () {
      final token = answerToken();
      final key = token.key('k1');
      expect(
        sleepWake(_sleeping(until: 100, signals: <SignalKey<Object?>>[key]),
            null, 0, <SignalKey<Object?>>[key]),
        isNull,
      );
    });
  });

  group('SubmissionSettled', () {
    test('is a built-in signal named pi.submission-settled', () {
      expect(SubmissionSettled.name, 'pi.submission-settled');
      expect(SubmissionSettled.version, 1);
    });
  });
}
