// The Chord context: cancellation and the propagation carrier.

import 'dart:async';

import 'package:pi/durable.dart';
import 'package:pi/telemetry.dart';
import 'package:test/test.dart';

void main() {
  group('Context', () {
    test('the background context never cancels and carries nothing', () {
      expect(backgroundContext.aborted, isFalse);
      expect(backgroundContext.abortReason, isNull);
      expect(backgroundContext.carrier, isNull);
      backgroundContext.throwIfAborted();
    });

    test('throwIfAborted carries the abort reason', () {
      final signal = AbortSignal()..abort('operator cancelled');
      final context =
          Context(signal: signal).withCarrier(<String, String>{'trace': 'abc'});
      expect(context.aborted, isTrue);
      expect(context.abortReason, 'operator cancelled');
      expect(context.carrier, <String, String>{'trace': 'abc'});
      expect(() => context.throwIfAborted(), throwsA(isA<AbortException>()));
    });

    test(
      'awaitWithContext rejects as soon as its context is cancelled',
      () async {
        final signal = AbortSignal();
        final never = Completer<int>();
        final pending = awaitWithContext(never.future, Context(signal: signal));
        signal.abort('stop');
        await expectLater(pending, throwsA(isA<AbortException>()));
      },
    );

    test(
      'awaitWithContext passes through a resolved value and a failure',
      () async {
        expect(
          await awaitWithContext(Future<int>.value(7), backgroundContext),
          7,
        );
        await expectLater(
          awaitWithContext(
            Future<int>.error(StateError('boom')),
            backgroundContext,
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('a context already aborted fails before awaiting anything', () async {
      final signal = AbortSignal()..abort('early');
      await expectLater(
        awaitWithContext(Future<int>.value(1), Context(signal: signal)),
        throwsA(isA<AbortException>()),
      );
    });

    test('abort is idempotent and its listeners run once', () {
      final signal = AbortSignal();
      var calls = 0;
      signal.onAbort(() => calls++);
      signal.abort('first');
      signal.abort('second');
      expect(calls, 1);
      expect(signal.reason, 'first');
    });

    test('withSignal and withCarrier keep the other half', () {
      final signal = AbortSignal();
      final base = const Context(carrier: <String, String>{'a': 'b'});
      final withSignal = base.withSignal(signal);
      expect(withSignal.carrier, <String, String>{'a': 'b'});
      expect(withSignal.signal, same(signal));
      expect(base.withCarrier(<String, String>{'c': 'd'}).signal, isNull);
    });
  });

  // pi#62: port the remaining upstream context API as one vertical slice.
  group('upstream context values and cancellation', () {
    test('typed keys derive immutable values without losing the parent', () {
      final request = createContextKey<String>('request');
      final attempt = createContextKey<int>('attempt');
      final signal = AbortSignal();
      final base = const Context(carrier: <String, String>{'trace': 'abc'});
      final rooted = withAbortSignal(signal, base);
      final derived = withContextValue(request, 'r1', rooted);
      final nested = withContextValue(attempt, 7, derived);

      expect(nested.value(request), 'r1');
      expect(nested.value(attempt), 7);
      expect(nested.value(createContextKey<String>('missing')), isNull);
      expect(nested.signal, same(signal));
      expect(nested.carrier, base.carrier);
      expect(rooted.value(request), isNull);
      expect(BACKGROUND_CONTEXT, same(backgroundContext));
      expect(TODO_CONTEXT.aborted, isFalse);
    });

    test('combined cancellation follows either signal and can be removed', () {
      final parent = AbortSignal();
      final child = AbortSignal();
      final context = withAbortSignal(
        child,
        withAbortSignal(parent, backgroundContext),
      );
      child.abort('child stopped');
      expect(context.aborted, isTrue);
      expect(context.abortReason, 'child stopped');
      expect(withoutAbortSignal(context).aborted, isFalse);
      expect(withoutAbortSignal(context).carrier, context.carrier);

      final independent = withCancel(backgroundContext);
      independent.cancel('local only');
      expect(independent.context.aborted, isTrue);
      expect(independent.context.abortReason, 'local only');
      expect(context.abortReason, 'child stopped');
    });

    test(
      'telemetry derivation and traceIn keep cancellation and values',
      () async {
        final memory = InMemoryTelemetryContext();
        final signal = AbortSignal();
        final request = createContextKey<String>('request');
        final result = await memory.startSpan(
          const SpanOptions(name: 'root'),
          (root) {
            final context = withTelemetry(
              root,
              withContextValue(
                request,
                'r1',
                withAbortSignal(signal, backgroundContext),
              ),
            );
            expect(context.telemetry, same(root));
            return traceIn(const SpanOptions(name: 'operation'), (child) {
              expect(child.value(request), 'r1');
              expect(child.abortSignal, same(signal));
              expect(child.telemetry, isNot(same(root)));
              return 42;
            }, context);
          },
        );
        expect(result, 42);
        expect(memory.getSpans().map((span) => span.name), [
          'root',
          'operation',
        ]);
      },
    );
  });
}
