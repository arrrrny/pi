// Chord primitives: strict JSON, branded IDs, the op vocabulary's immutable
// application, and the draft that records it.

import 'package:pi/durable.dart';
import 'package:test/test.dart';

void main() {
  group('strict JSON', () {
    test('copies a value into an alias-free tree', () {
      final source = <String, Object?>{
        'list': <Object?>[1, 2],
        'nested': <String, Object?>{'ok': true},
      };
      final copy = copyJson(source)! as Map<String, Object?>;
      (source['list']! as List<Object?>).add(3);
      expect(copy['list'], <Object?>[1, 2]);
      expect(identical(copy, source), isFalse);
    });

    test('rejects a non-finite number', () {
      expect(() => copyJson(<String, Object?>{'n': double.nan}),
          throwsA(isA<TypeError>()));
      expect(() => copyJson(<String, Object?>{'n': double.infinity}),
          throwsA(isA<TypeError>()));
    });

    test('rejects a cycle', () {
      final cycle = <String, Object?>{};
      cycle['self'] = cycle;
      expect(() => copyJson(cycle), throwsA(isA<TypeError>()));
    });

    test('isJsonValue accepts strict JSON and rejects the rest', () {
      expect(
          isJsonValue(<String, Object?>{
            'a': <Object?>[1, 'two', null, true]
          }),
          isTrue);
      expect(isJsonValue(<String, Object?>{'a': double.nan}), isFalse);
      expect(isJsonValue(<Object?>[]), isTrue);
      expect(isJsonValue(DateTime(2026)), isFalse);
    });
  });

  group('branded IDs', () {
    test('one numeric namespace: two kinds with one number are the same ID',
        () {
      expect(idFromNumber<EntryKind>(7), idFromNumber<TaskKind>(7));
      expect(idFromNumber<EntryKind>(7), isNot(idFromNumber<EntryKind>(8)));
    });

    test('Seq is an Id over the sequence kind', () {
      expect(seqFromNumber(3).value, 3);
      expect(seqFromNumber(3), seqFromNumber(3));
    });
  });

  group('delta application', () {
    final initial = <String, Object?>{
      'count': 1,
      'items': <Object?>['a', 'b'],
      'nested': <String, Object?>{
        'deep': <String, Object?>{'value': 1}
      },
    };

    Object? applied(List<Op> ops) => applyImmutable(copyJson(initial), ops);

    test('set writes a nested path without touching the input', () {
      final before = copyJson(initial);
      final result = applied(<Op>[
        OpSet(<Seg>['nested', 'deep', 'value'], 2)
      ])! as Map<String, Object?>;
      expect(
          ((result['nested']! as Map<String, Object?>)['deep']!
              as Map<String, Object?>)['value'],
          2);
      expect(initial, before);
    });

    test('delete removes an object key and an array element', () {
      final result = applied(<Op>[
        OpDelete(<Seg>['count']),
        OpDelete(<Seg>['items', 0]),
      ])! as Map<String, Object?>;
      expect(result.containsKey('count'), isFalse);
      expect(result['items'], <Object?>['b']);
    });

    // Upstream: `{text: "hello world"}` with `["t", ["text"], 6]` is `{text: "world"}`.
    test('append adds to the tail and truncate drops the head', () {
      final result = applied(<Op>[
        OpSet(<Seg>['text'], 'hello world'),
        OpAppend(<Seg>['text'], '!'),
        OpTruncate(<Seg>['text'], 6),
      ])! as Map<String, Object?>;
      expect(result['text'], 'world!');
    });

    test('append to an absent or non-string value fails with PathError', () {
      expect(
          () => applied(<Op>[
                OpAppend(<Seg>['absent'], 'x')
              ]),
          throwsA(isA<PathError>()));
      expect(
          () => applied(<Op>[
                OpAppend(<Seg>['count'], 'x')
              ]),
          throwsA(isA<PathError>()));
    });

    test('insert splices an array', () {
      final result = applied(<Op>[
        OpInsert(<Seg>['items'], 1, 0, <Object?>['x'])
      ])! as Map<String, Object?>;
      expect(result['items'], <Object?>['a', 'x', 'b']);
      final replaced = applied(<Op>[
        OpInsert(<Seg>['items'], 0, 1, <Object?>['y'])
      ])! as Map<String, Object?>;
      expect(replaced['items'], <Object?>['y', 'b']);
    });

    test('move reorders an array by permutation', () {
      final result = applied(<Op>[
        OpMove(<Seg>['items'], <int>[1, 0])
      ])! as Map<String, Object?>;
      expect(result['items'], <Object?>['b', 'a']);
    });

    test('replace swaps the whole value', () {
      final result = applied(<Op>[
        OpReplace(<String, Object?>{'fresh': true})
      ]);
      expect(result, <String, Object?>{'fresh': true});
    });

    test('batches fold in order', () {
      final result = applyImmutableBatches(copyJson(initial), <List<Op>>[
        <Op>[
          OpSet(<Seg>['count'], 2)
        ],
        <Op>[
          OpSet(<Seg>['count'], 3)
        ],
      ])! as Map<String, Object?>;
      expect(result['count'], 3);
    });

    test('an out-of-range array index fails with PathError', () {
      expect(
          () => applied(<Op>[
                OpSet(<Seg>['items', 5], 'x')
              ]),
          throwsA(isA<PathError>()));
    });
  });

  group('draft', () {
    test('records the ops it applied and keeps the initial value', () {
      final draft =
          Draft<JsonObject>(<String, Object?>{'count': 1, 'label': 'pending'});
      draft.set(<Seg>['count'], 2);
      draft.append(<Seg>['label'], 'x');
      expect(draft.value['count'], 2);
      expect(draft.initialValue,
          <String, Object?>{'count': 1, 'label': 'pending'});
      expect(draft.ops, hasLength(2));
      expect(draft.ops.first, isA<OpSet>());
      expect(
          applyImmutable(
              copyJson(<String, Object?>{'count': 1, 'label': 'pending'}),
              draft.ops),
          draft.value);
    });
  });
}
