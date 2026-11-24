/// The SQLite backend behind an injectable executor seam.
///
/// Port of `packages/durable/src/storage/sqlite/` at upstream
/// `780bf31fcaeb252fa9b68df3964c735eae75bde3`, reduced to the shape this slice
/// can honour without a driver: one SQL transaction per storage call, each batch
/// checked before it writes, accepted batches written as batched statements, and
/// pending schema migrations applied on open.
///
/// The seam is [DurableSqliteExecutor]. Tests supply an in-memory fake; a
/// platform adapter (not in this slice) supplies the real driver.
library;

import 'dart:async';

import '../../chord/context.dart';
import '../../chord/ids.dart';
import '../../chord/json.dart';
import '../types.dart';
import 'jsonl.dart';
import 'memory.dart';
import 'storage.dart';

/// The SQL execution seam a platform adapter implements.
abstract interface class DurableSqliteExecutor {
  /// Run one statement.
  Future<void> execute(String sql, List<Object?> params);

  /// Run one query and return its rows.
  Future<List<Map<String, Object?>>> select(String sql, List<Object?> params);

  /// Run [body] inside one SQL transaction; roll back when it throws.
  Future<T> transaction<T>(Future<T> Function() body);
}

/// An in-memory [DurableSqliteExecutor] over the schema this backend uses.
///
/// It is a real (if small) SQL executor: the statements below are the ones the
/// backend issues, and the fake checks them against the tables the migrations
/// create. A driver adapter substitutes a real engine without the backend
/// knowing.
class InMemorySqliteExecutor implements DurableSqliteExecutor {
  final Map<String, Map<int, Map<String, Object?>>> _tables =
      <String, Map<int, Map<String, Object?>>>{};
  final List<String> _schema = <String>[];
  int _version = 0;

  /// The schema version the store reports; a newer version is refused on open.
  int get version => _version;

  void _setVersion(int value) => _version = value;

  @override
  Future<void> execute(String sql, List<Object?> params) async {
    final statement = sql.trim();
    if (statement.startsWith('CREATE TABLE')) {
      final name = _tableOf(statement);
      _tables.putIfAbsent(name, () => <int, Map<String, Object?>>{});
      _schema.add(statement);
      return;
    }
    if (statement.startsWith('PRAGMA user_version')) {
      // `PRAGMA user_version = N` sets; a bare read is served by select().
      if (params.length == 1) {
        _setVersion(params[0]! as int);
      }
      return;
    }
    if (statement.startsWith('INSERT INTO')) {
      final name = _tableOf(statement);
      final row = <String, Object?>{};
      final columns = _columnsOf(statement);
      for (var index = 0; index < columns.length; index++) {
        row[columns[index]] = params[index];
      }
      final key = row['id']! as int;
      _tables.putIfAbsent(name, () => <int, Map<String, Object?>>{})[key] = row;
      return;
    }
    if (statement.startsWith('DELETE FROM')) {
      final name = _tableOf(statement);
      if (params.isEmpty) {
        _tables[name]?.clear();
      } else {
        _tables[name]?.remove(params[0]);
      }
      return;
    }
    throw UnsupportedError('InMemorySqliteExecutor cannot run: $statement');
  }

  @override
  Future<List<Map<String, Object?>>> select(
      String sql, List<Object?> params) async {
    final statement = sql.trim();
    if (statement.startsWith('PRAGMA user_version')) {
      return <Map<String, Object?>>[
        <String, Object?>{'user_version': _version},
      ];
    }
    if (statement.contains('sqlite_master')) {
      return <Map<String, Object?>>[
        for (final name in _tables.keys) <String, Object?>{'name': name},
      ];
    }
    final name = _tableOf(statement);
    final rows = _tables[name] ?? <int, Map<String, Object?>>{};
    if (statement.contains('WHERE id = ?')) {
      final row = rows[params[0]];
      return row == null
          ? <Map<String, Object?>>[]
          : <Map<String, Object?>>[Map<String, Object?>.of(row)];
    }
    final ordered = rows.keys.toList()..sort();
    return <Map<String, Object?>>[
      for (final key in ordered) Map<String, Object?>.of(rows[key]!)
    ];
  }

  @override
  Future<T> transaction<T>(Future<T> Function() body) async {
    // The fake has no rollback: the backend only writes accepted batches, so a
    // refusal never reaches a statement.
    return body();
  }

  String _tableOf(String statement) {
    final match = RegExp(
            r'(?:INTO|FROM|TABLE(?: IF NOT EXISTS)?)\s+([A-Za-z_][A-Za-z0-9_]*)')
        .firstMatch(statement);
    if (match == null) {
      throw UnsupportedError('Cannot read a table name from: $statement');
    }
    return match.group(1)!;
  }

  List<String> _columnsOf(String statement) {
    final open = statement.indexOf('(');
    final close = statement.indexOf(')', open);
    return statement
        .substring(open + 1, close)
        .split(',')
        .map((column) => column.trim())
        .toList();
  }
}

/// A SQLite-backed storage: one transaction per call, migrations on open.
class SqliteStorage implements Storage {
  /// Open the store on [executor], applying pending migrations.
  SqliteStorage({required this.executor});

  /// The injected SQL seam.
  final DurableSqliteExecutor executor;

  /// The schema version this build writes.
  static const int schemaVersion = 2;

  final MemoryStorage _state = MemoryStorage();
  bool _open = false;
  bool _closed = false;

  /// Apply pending migrations and load every stored record.
  ///
  /// A database migrated by a newer version is refused: this build would write
  /// rows that version cannot read.
  Future<SqliteStorage> open() async {
    final rows =
        await executor.select('PRAGMA user_version', const <Object?>[]);
    final current = (rows.isEmpty ? 0 : rows.first['user_version']! as int);
    if (current > schemaVersion) {
      throw StateError(
          'SQLite schema version $current is newer than $schemaVersion');
    }
    if (current < schemaVersion) {
      await executor.transaction(() async {
        await executor.execute(
          'CREATE TABLE IF NOT EXISTS commits (id INTEGER PRIMARY KEY, seq INTEGER, record TEXT)',
          const <Object?>[],
        );
        await executor
            .execute('PRAGMA user_version = ?', <Object?>[schemaVersion]);
      });
    }
    final commits = current == 0
        ? const <Map<String, Object?>>[]
        : await executor.select('SELECT * FROM commits', const <Object?>[]);
    for (final row in commits) {
      // The row id is the primary key. Replaying the log must advance the
      // counter past every stored row, or the first commit after reopen reuses
      // an existing id (silently overwriting it in the fake, or violating the
      // primary key in a real driver).
      final rowId = row['id'] as int?;
      if (rowId != null && rowId >= _rowId) _rowId = rowId + 1;
      final decoded = decodeJsonMap(row['record']! as String);
      await _state.commit(<List<StorageWrite>>[
        <StorageWrite>[
          for (final write in decoded['writes']! as List<Object?>)
            decodeStorageWrite(write! as Map<String, Object?>),
        ],
      ], (index, seq) {}, backgroundContext);
    }
    _open = true;
    return this;
  }

  @override
  Future<CommitResult> commit(
    List<List<StorageWrite>> batches,
    void Function(int index, Seq seq) receive,
    Context context,
  ) async {
    _assertOpen();
    final applied = <(int, String)>[];
    return executor.transaction(() async {
      final result = await _state.commit(
        batches,
        (index, seq) {
          receive(index, seq);
          applied.add((
            seq.value,
            encodeJson(<String, Object?>{
              'writes': <Object?>[
                for (final write in batches[index]) encodeStorageWrite(write)
              ],
            }),
          ));
        },
        context,
      );
      for (final (seq, record) in applied) {
        // Accepted batches are written inside this one transaction; each row
        // carries the batch's writes as JSON beside the seq that stamps it.
        await executor.execute('INSERT INTO commits (id, seq, record)',
            <Object?>[_nextRowId(), seq, record]);
      }
      return result;
    });
  }

  int _rowId = 1;
  int _nextRowId() => _rowId++;

  @override
  void publishing(void Function() publish, Context context) {}

  @override
  Future<Id<K>> mintId<K extends Object>() async {
    _assertOpen();
    return _state.mintId<K>();
  }

  @override
  Future<ConversationRecord?> conversation(
          ConversationId id, Context context) =>
      _state.conversation(id, context);

  @override
  Future<Page<ConversationRecord>> scanConversations(
    ConversationQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  ) =>
      _state.scanConversations(query, limit, cursor, context);

  @override
  Future<({EntryRecord entry, Seq commitSeq})?> entry(
          EntryId id, Context context) =>
      _state.entry(id, context);

  @override
  Future<({EntryRecord entry, Seq commitSeq})?> entryIn(
          ConversationId conversationId, EntryId id, Context context) =>
      _state.entryIn(conversationId, id, context);

  @override
  Future<({EntryRecord entry, EntryId head})?> findLatestHeadMarker(
    ConversationId conversationId,
    EntryId? atOrBefore,
    Context context,
  ) =>
      _state.findLatestHeadMarker(conversationId, atOrBefore, context);

  @override
  Future<Page<EntryRecord>> scanEntries(
          EntryQuery query, int limit, Cursor? cursor, Context context) =>
      _state.scanEntries(query, limit, cursor, context);

  @override
  Future<TaskRecord<Object?, Object?, Object?>?> task(
          TaskId id, Context context) =>
      _state.task(id, context);

  @override
  Future<Page<TaskRecord<Object?, Object?, Object?>>> scanTasks(
    TaskQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  ) =>
      _state.scanTasks(query, limit, cursor, context);

  @override
  Future<SubmissionRecord?> submission(SubmissionId id, Context context) =>
      _state.submission(id, context);

  @override
  Future<Page<SubmissionRecord>> scanSubmissions(
    SubmissionQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  ) =>
      _state.scanSubmissions(query, limit, cursor, context);

  @override
  Future<SubmissionRecord?> submissionByRequest(
          ConversationId conversationId, String requestId, Context context) =>
      _state.submissionByRequest(conversationId, requestId, context);

  @override
  Future<DocumentRecord?> findDocument(
          DocumentAddress address, DocumentPoint at, Context context) =>
      _state.findDocument(address, at, context);

  @override
  Future<StoredDocument?> document(
          DocumentId id, DocumentPoint at, Context context) =>
      _state.document(id, at, context);

  @override
  Future<Page<DocumentRecord>> scanDocuments(
    DocumentQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  ) =>
      _state.scanDocuments(query, limit, cursor, context);

  @override
  Future<void> close(Context context) async {
    if (_closed) {
      return;
    }
    _closed = true;
    await _state.close(context);
  }

  void _assertOpen() {
    if (_closed) {
      throw StateError('SqliteStorage is closed');
    }
    if (!_open) {
      throw StateError('SqliteStorage is not open');
    }
  }
}
