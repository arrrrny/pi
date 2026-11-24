// Crash and reopen evidence (spec FR-038, SC-002).
//
// A torn commit is modelled at the storage boundary, which is where durability
// is decided: a log line that was only partly written, and a batch a backend
// refused. Both must leave the reopened state a complete prefix of the log, and
// a refusal must never publish a receipt.

import 'dart:convert';

import 'package:pi/durable.dart';
import 'package:test/test.dart';

void main() {
  group('JSONL crash/reopen', () {
    test('a torn trailing line is discarded and the prefix stays readable',
        () async {
      final files = InMemoryFileSystem();
      final storage =
          await JsonlStorage(files: files, path: 'log.jsonl').open();
      await commitWrites(
          storage,
          <StorageWrite>[
            ConversationWrite(const ConversationRecord(id: rootConversationId)),
          ],
          backgroundContext);
      await commitWrites(
          storage,
          <StorageWrite>[
            EntryWrite(EntryRecord(
              id: idFromNumber<EntryKind>(10),
              conversationId: rootConversationId,
              kind: 'pi.user',
              data: <String, Object?>{'text': 'kept'},
            )),
          ],
          backgroundContext);

      // The process dies mid-write: the next line is incomplete.
      final intact = await files.read('log.jsonl');
      await files.write(
          'log.jsonl', '${intact!}{"seq": 3, "writes": [{"type": "ent');

      final reopened =
          await JsonlStorage(files: files, path: 'log.jsonl').open();
      final entry =
          await reopened.entry(idFromNumber<EntryKind>(10), backgroundContext);
      expect(entry, isNotNull);
      expect(entry!.entry.data, <String, Object?>{'text': 'kept'});
      expect(
          await reopened.entry(idFromNumber<EntryKind>(11), backgroundContext),
          isNull);

      // The reopened log keeps accepting commits and its ID space does not restart.
      final nextId = await reopened.mintId<EntryKind>();
      expect(nextId.value, greaterThan(10));
    });

    test('a refused batch writes no log line and publishes no receipt',
        () async {
      final files = InMemoryFileSystem();
      final storage =
          await JsonlStorage(files: files, path: 'log.jsonl').open();
      await commitWrites(
          storage,
          <StorageWrite>[
            ConversationWrite(const ConversationRecord(id: rootConversationId)),
          ],
          backgroundContext);
      final before = await files.read('log.jsonl');
      final receipts = <int>[];

      final result = await storage.commit(
        <List<StorageWrite>>[
          <StorageWrite>[
            ConversationWrite(const ConversationRecord(id: rootConversationId)),
          ],
        ],
        (index, seq) => receipts.add(index),
        backgroundContext,
      );

      expect(result.stored, 0);
      expect(result, isA<CommitRefused>());
      expect(receipts, isEmpty);
      expect(await files.read('log.jsonl'), before);
    });

    test('running work resumes from its last committed checkpoint', () async {
      final files = InMemoryFileSystem();
      final storage =
          await JsonlStorage(files: files, path: 'log.jsonl').open();
      await commitWrites(
          storage,
          <StorageWrite>[
            ConversationWrite(const ConversationRecord(id: rootConversationId)),
            TaskWrite(TaskRecord<Object?, Object?, Object?>(
              id: idFromNumber<TaskKind>(7),
              conversationId: rootConversationId,
              kind: 'test.resume',
              version: 1,
              input: <String, Object?>{'prompt': 'go'},
              state: TaskRunning<Object?, Object?>(
                  <String, Object?>{'phase': 'second', 'cursor': 41}),
            )),
          ],
          backgroundContext);

      final reopened =
          await JsonlStorage(files: files, path: 'log.jsonl').open();
      final task =
          await reopened.task(idFromNumber<TaskKind>(7), backgroundContext);
      expect(task, isNotNull);
      expect(task!.state, isA<TaskRunning<Object?, Object?>>());
      final checkpoint = (task.state as TaskRunning<Object?, Object?>)
          .checkpoint as Map<String, Object?>;
      expect(checkpoint['phase'], 'second');
      expect(checkpoint['cursor'], 41);
    });
  });

  group('SQLite reopen', () {
    test('reopening the same executor replays every committed write', () async {
      final executor = InMemorySqliteExecutor();
      final storage = await SqliteStorage(executor: executor).open();
      await commitWrites(
          storage,
          <StorageWrite>[
            ConversationWrite(const ConversationRecord(id: rootConversationId)),
            EntryWrite(EntryRecord(
              id: idFromNumber<EntryKind>(3),
              conversationId: rootConversationId,
              kind: 'pi.assistant',
            )),
          ],
          backgroundContext);
      await storage.close(backgroundContext);

      final reopened = await SqliteStorage(executor: executor).open();
      expect(
          (await reopened.conversation(rootConversationId, backgroundContext))!
              .id,
          rootConversationId);
      expect(
          (await reopened.entry(idFromNumber<EntryKind>(3), backgroundContext))!
              .entry
              .kind,
          'pi.assistant');
    });

    test('a store migrated by a newer schema version is refused', () async {
      final executor = InMemorySqliteExecutor();
      await executor.execute('PRAGMA user_version = ?',
          <Object?>[SqliteStorage.schemaVersion + 1]);
      await expectLater(
        SqliteStorage(executor: executor).open(),
        throwsA(predicate((error) => '$error'.contains('newer than'))),
      );
    });

    test('a refused batch writes no row and publishes no receipt', () async {
      final executor = InMemorySqliteExecutor();
      final storage = await SqliteStorage(executor: executor).open();
      await commitWrites(
          storage,
          <StorageWrite>[
            ConversationWrite(const ConversationRecord(id: rootConversationId)),
          ],
          backgroundContext);
      final rowsBefore =
          (await executor.select('SELECT * FROM commits', const <Object?>[]))
              .length;
      final receipts = <int>[];

      final result = await storage.commit(
        <List<StorageWrite>>[
          <StorageWrite>[
            ConversationWrite(const ConversationRecord(id: rootConversationId)),
          ],
        ],
        (index, seq) => receipts.add(index),
        backgroundContext,
      );

      expect(result.stored, 0);
      expect(receipts, isEmpty);
      expect(
          (await executor.select('SELECT * FROM commits', const <Object?>[]))
              .length,
          rowsBefore);
    });
  });

  group('JSONL log format', () {
    test('each committed batch is one line with its own seq', () async {
      final files = InMemoryFileSystem();
      final storage =
          await JsonlStorage(files: files, path: 'log.jsonl').open();
      await storage.commit(
        <List<StorageWrite>>[
          <StorageWrite>[
            ConversationWrite(const ConversationRecord(id: rootConversationId))
          ],
          <StorageWrite>[
            EntryWrite(EntryRecord(
              id: idFromNumber<EntryKind>(5),
              conversationId: rootConversationId,
              kind: 'pi.system',
            )),
          ],
        ],
        (index, seq) {},
        backgroundContext,
      );
      final lines = (await files.read('log.jsonl'))!.trim().split('\n');
      expect(lines, hasLength(2));
      final seqs = <int>[
        for (final line in lines)
          (jsonDecode(line) as Map<String, Object?>)['seq']! as int,
      ];
      expect(seqs[1], greaterThan(seqs[0]));
    });
  });
}
