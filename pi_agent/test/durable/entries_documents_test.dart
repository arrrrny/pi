// Entry kinds and typed document definitions.

import 'package:pi/durable.dart';
import 'package:test/test.dart';

void main() {
  group('entry kinds', () {
    test('the six built-in kinds carry upstream kind names', () {
      expect(<String>[
        for (final entry in builtinEntries) entry.kind
      ], <String>[
        'pi.user',
        'pi.assistant',
        'pi.system',
        'pi.tool-result',
        'pi.reset',
        'pi.compaction',
      ]);
    });

    test('defineEntry refuses an empty kind', () {
      expect(() => defineEntry<Object?>(''), throwsA(isA<ArgumentError>()));
    });

    test('a typed kind guards an entry by kind', () {
      final record = EntryRecord(
          id: idFromNumber<EntryKind>(1),
          conversationId: rootConversationId,
          kind: 'pi.user');
      expect(userEntry.matches(record), isTrue);
      expect(assistantEntry.matches(record), isFalse);
      expect(userEntry.matches(null), isFalse);
    });

    test('an entry record round-trips through its JSON form', () {
      final record = EntryRecord(
        id: idFromNumber<EntryKind>(4),
        conversationId: rootConversationId,
        kind: 'pi.compaction',
        data: <String, Object?>{'reason': 'overflow'},
        head: idFromNumber<EntryKind>(2),
        byTaskId: idFromNumber<TaskKind>(9),
        edits: <ContextEdit>[ContextOmit(idFromNumber<EntryKind>(3))],
      );
      final round = EntryRecord.fromJson(record.toJson());
      expect(round.toJson(), record.toJson());
      expect((round.edits!.single as ContextOmit).target.value, 3);
    });
  });

  group('document definitions', () {
    DocSpec<JsonObject> spec({int version = 1}) => DocSpec<JsonObject>(
          kind: 'test.settings',
          version: version,
          initial: () => <String, Object?>{'count': 0},
          checkpointWhen: (value, ops, info) => info.deltasSinceBase >= 2,
        );

    test('a session definition exposes kind, version and initial value', () {
      final token = defineSessionDoc<JsonObject>(spec());
      expect(token.definition.kind, 'test.settings');
      expect(token.definition.version, 1);
      expect(token.definition.initial(), <String, Object?>{'count': 0});
      expect(
          semanticsOf(token.definition.semantics), (history: null, fork: null));
    });

    test('conversation definitions declare their history and fork policy', () {
      final latest = defineLatestConversationDoc<JsonObject>(spec(),
          fork: ForkPolicy.initial);
      expect(semanticsOf(latest.definition.semantics),
          (history: 'latest', fork: ForkPolicy.initial));
      final rewindable = defineRewindableConversationDoc<JsonObject>(spec());
      expect(semanticsOf(rewindable.definition.semantics),
          (history: 'rewindable', fork: ForkPolicy.asOf));
    });

    test('a task definition is current-only', () {
      final token = defineTaskDoc<JsonObject>(spec());
      expect(
          semanticsOf(token.definition.semantics), (history: null, fork: null));
    });

    test('a family seeds its members', () {
      final token = defineSessionDocFamily<JsonObject, String>(
        spec(),
        (seed) => <String, Object?>{'seed': seed},
      );
      expect(
          token.definition.initialFor('abc'), <String, Object?>{'seed': 'abc'});
    });

    test('definitions validate their kind and version', () {
      expect(() => defineSessionDoc<JsonObject>(spec(version: 0)),
          throwsA(isA<ArgumentError>()));
      expect(
        () => defineSessionDoc<JsonObject>(DocSpec<JsonObject>(
          kind: '',
          version: 1,
          initial: () => <String, Object?>{},
          checkpointWhen: (value, ops, info) => false,
        )),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('the checkpoint predicate sees the deltas since the newest base', () {
      final token = defineSessionDoc<JsonObject>(spec());
      const ops = <Op>[];
      expect(
          token.definition.checkpointWhen(<String, Object?>{}, ops,
              const CheckpointInfo(deltasSinceBase: 0)),
          isFalse);
      expect(
          token.definition.checkpointWhen(<String, Object?>{}, ops,
              const CheckpointInfo(deltasSinceBase: 2)),
          isTrue);
    });
  });
}
