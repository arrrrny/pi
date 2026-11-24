/// The JSONL file backend and its file-system capability.
///
/// Port of `packages/durable/src/storage/jsonl/` at upstream
/// `780bf31fcaeb252fa9b68df3964c735eae75bde3`. The backend depends on a
/// [FileSystem] capability, not on a process environment: the platform adapter
/// supplies the file operations and this slice supplies an in-memory one.
///
/// A commit appends one JSON line per batch to the log, so a crash mid-write
/// leaves a torn trailing line that reopen discards; the decoded view is then
/// rebuilt from the intact prefix. That is what makes "a partial commit is
/// never published" true for this backend without a journal.
library;

import 'dart:convert';

import '../../chord/context.dart';
import '../../chord/delta.dart';
import '../../chord/ids.dart';
import '../types.dart';
import 'memory.dart';
import 'storage.dart';

/// The file operations the JSONL backend needs.
abstract interface class FileSystem {
  /// The file's content, or null when it does not exist.
  Future<String?> read(String path);

  /// Replace the file's content.
  Future<void> write(String path, String content);

  /// Append [content] to the file, creating it when absent.
  Future<void> append(String path, String content);

  /// Remove the file when it exists.
  Future<void> remove(String path);
}

/// A [FileSystem] over the process's own files, for tests and hosts that have
/// one.
class InMemoryFileSystem implements FileSystem {
  final Map<String, StringBuffer> _files = <String, StringBuffer>{};

  /// Every path this file system currently holds.
  Iterable<String> get paths => _files.keys;

  @override
  Future<String?> read(String path) async => _files[path]?.toString();

  @override
  Future<void> write(String path, String content) async =>
      _files[path] = StringBuffer(content);

  @override
  Future<void> append(String path, String content) async =>
      (_files[path] ??= StringBuffer()).write(content);

  @override
  Future<void> remove(String path) async => _files.remove(path);
}

/// A JSONL-backed storage: one append-only log of commits, replayed on open.
class JsonlStorage implements Storage {
  /// Open the log at [path] through [files], replaying every intact commit.
  JsonlStorage({required FileSystem files, required this.path})
      : _files = files;

  final FileSystem _files;

  /// The log's path in [FileSystem].
  final String path;

  final MemoryStorage _state = MemoryStorage();
  int _nextSeq = 1;
  bool _open = false;
  bool _closed = false;

  /// Replay the log; a torn trailing line is discarded, which is the crash
  /// contract: the reopened state is a complete prefix of the log.
  Future<JsonlStorage> open() async {
    final content = await _files.read(path) ?? '';
    final lines = content.split('\n');
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (line.isEmpty) continue;
      final isLast = index == lines.length - 1 && !content.endsWith('\n');
      Map<String, Object?> record;
      try {
        record = jsonDecode(line) as Map<String, Object?>;
      } catch (_) {
        if (isLast) break;
        throw StateError('JSONL log $path is corrupt at line ${index + 1}');
      }
      await _replay(record);
    }
    _open = true;
    return this;
  }

  Future<void> _replay(Map<String, Object?> record) async {
    final writes = (record['writes']! as List<Object?>)
        .map((value) => decodeStorageWrite(value! as Map<String, Object?>))
        .toList();
    final seq = seqFromNumber(record['seq']! as int);
    await _state.commit(
        <List<StorageWrite>>[writes], (index, stored) {}, backgroundContext);
    if (seq.value >= _nextSeq) _nextSeq = seq.value + 1;
  }

  @override
  Future<CommitResult> commit(
    List<List<StorageWrite>> batches,
    void Function(int index, Seq seq) receive,
    Context context,
  ) async {
    _assertOpen();
    // One line per stored batch, each with the seq the receipt carried: the log
    // is the durability boundary, and a receipt is only ever given for a batch
    // whose line is out.
    final lines = <String>[];
    final result = await _state.commit(
      batches,
      (index, seq) {
        lines.add('${jsonEncode(<String, Object?>{
              'seq': seq.value,
              'writes': <Object?>[
                for (final write in batches[index]) encodeStorageWrite(write)
              ],
            })}\n');
        if (seq.value >= _nextSeq) _nextSeq = seq.value + 1;
        receive(index, seq);
      },
      context,
    );
    for (final line in lines) {
      await _files.append(path, line);
    }
    return result;
  }

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
    if (_closed) return;
    _closed = true;
    await _state.close(context);
  }

  void _assertOpen() {
    if (_closed) throw StateError('JsonlStorage is closed');
    if (!_open) throw StateError('JsonlStorage is not open');
  }
}

// ── wire encoding of a storage write ─────────────────────────────────────────

/// Encode [write] as strict JSON for the log.
Map<String, Object?> encodeStorageWrite(StorageWrite write) => switch (write) {
      ConversationWrite(:final value) => <String, Object?>{
          'type': 'conversation',
          'value': value.toJson()
        },
      EntryWrite(:final value) => <String, Object?>{
          'type': 'entry',
          'value': value.toJson()
        },
      TaskWrite(:final value) => <String, Object?>{
          'type': 'task',
          'value': value.toJson()
        },
      SubmissionWrite(:final value) => <String, Object?>{
          'type': 'submission',
          'value': value.toJson()
        },
      DocumentCreateWrite(:final record, :final content) => <String, Object?>{
          'type': 'document.create',
          'record': record.toJson(),
          'content': <String, Object?>{
            'kind': 'base',
            'version': content.version,
            'value': content.value
          },
        },
      DocumentCopyWrite(:final record, :final source) => <String, Object?>{
          'type': 'document.copy',
          'record': record.toJson(),
          'source': source.toJson(),
        },
      DocumentChangeWrite(:final id, :final content) => <String, Object?>{
          'type': 'document.change',
          'id': id.value,
          'content': encodeDocumentContent(content),
        },
      DocumentRetireWrite(:final id) => <String, Object?>{
          'type': 'document.retire',
          'id': id.value
        },
    };

/// Encode [content] as strict JSON.
Map<String, Object?> encodeDocumentContent(DocumentContent content) =>
    switch (content) {
      DocumentBase(:final version, :final value) => <String, Object?>{
          'kind': 'base',
          'version': version,
          'value': value,
        },
      DocumentDelta(:final version, :final ops) => <String, Object?>{
          'kind': 'delta',
          'version': version,
          'ops': <Object?>[for (final op in ops) encodeOp(op)],
        },
    };

/// Encode one Chord operation as its upstream tuple form.
List<Object?> encodeOp(Op op) => switch (op) {
      OpReplace(:final value) => <Object?>['r', value],
      OpSet(:final path, :final value) => <Object?>['s', path, value],
      OpDelete(:final path) => <Object?>['d', path],
      OpAppend(:final path, :final value) => <Object?>['a', path, value],
      OpTruncate(:final path, :final length) => <Object?>['t', path, length],
      OpInsert(:final path, :final start, :final deleteCount, :final items) =>
        <Object?>['p', path, start, deleteCount, items],
      OpMove(:final path, :final permutation) => <Object?>[
          'm',
          path,
          permutation
        ],
    };

/// Decode a storage write the log holds.
StorageWrite decodeStorageWrite(Map<String, Object?> json) =>
    switch (json['type']) {
      'conversation' => ConversationWrite(
          ConversationRecord.fromJson(json['value']! as Map<String, Object?>)),
      'entry' => EntryWrite(
          EntryRecord.fromJson(json['value']! as Map<String, Object?>)),
      'task' =>
        TaskWrite(decodeTaskRecord(json['value']! as Map<String, Object?>)),
      'submission' => SubmissionWrite(
          SubmissionRecord.fromJson(json['value']! as Map<String, Object?>)),
      'document.create' => DocumentCreateWrite(
          record:
              DocumentCreate.fromJson(json['record']! as Map<String, Object?>),
          content:
              decodeDocumentContent(json['content']! as Map<String, Object?>)
                  as DocumentBase,
        ),
      'document.copy' => DocumentCopyWrite(
          record:
              DocumentCreate.fromJson(json['record']! as Map<String, Object?>),
          source: DocumentCopySource.fromJson(
              json['source']! as Map<String, Object?>),
        ),
      'document.change' => DocumentChangeWrite(
          id: idFromNumber<DocumentKindId>(json['id']! as int),
          content:
              decodeDocumentContent(json['content']! as Map<String, Object?>),
        ),
      'document.retire' =>
        DocumentRetireWrite(idFromNumber<DocumentKindId>(json['id']! as int)),
      final type => throw ArgumentError('Unknown storage write: $type'),
    };

/// Decode a task record the log holds.
TaskRecord<Object?, Object?, Object?> decodeTaskRecord(
        Map<String, Object?> json) =>
    TaskRecord<Object?, Object?, Object?>(
      id: idFromNumber<TaskKind>(json['id']! as int),
      conversationId:
          idFromNumber<ConversationKind>(json['conversationId']! as int),
      kind: json['kind']! as String,
      version: json['version']! as int,
      input: json['input'],
      state: decodeTaskState(json['state']! as Map<String, Object?>),
      owner: json['owner'] == null
          ? null
          : idFromNumber<TaskKind>(json['owner']! as int),
      background: json['background'] == true,
      abortRequested: json['abortRequested'] == true,
      abortReason: json['abortReason'] as String?,
      abandonOnRestart: json['abandonOnRestart'] as bool?,
      startedAt: json['startedAt'] as int?,
      endedAt: json['endedAt'] as int?,
      restarts: json['restarts'] as int?,
      memos: json['memos'] == null
          ? null
          : (json['memos']! as Map).cast<String, Object?>(),
    );

/// Decode a task state the log holds.
TaskState<Object?, Object?> decodeTaskState(Map<String, Object?> json) {
  final wake = json['wake'] == null
      ? null
      : decodeWakeReason(json['wake']! as Map<String, Object?>);
  final checkpoint = json['checkpoint'];
  switch (json['status']) {
    case 'pending':
      return TaskPending<Object?, Object?>(checkpoint, wake: wake);
    case 'running':
      return TaskRunning<Object?, Object?>(checkpoint, wake: wake);
    case 'waiting':
      return TaskWaiting<Object?, Object?>(
        checkpoint,
        on: <TaskId>[
          for (final id in json['on']! as List<Object?>)
            idFromNumber<TaskKind>(id! as int)
        ],
        policy: JoinPolicy.values.byName(json['policy']! as String),
      );
    case 'sleeping':
      return TaskSleeping<Object?, Object?>(
        checkpoint,
        until: json['until'] as int?,
        signals: (json['signals'] as List<Object?>?)
            ?.map((value) => SignalKey(value! as String))
            .toList(),
      );
    case 'completing':
      return TaskCompleting<Object?, Object?>(
          decodeTaskOutcome(json['outcome']! as Map<String, Object?>));
    case 'terminal':
      return TaskTerminal<Object?, Object?>(
          decodeTaskOutcome(json['outcome']! as Map<String, Object?>));
    default:
      throw ArgumentError('Unknown task status: ${json['status']}');
  }
}

/// Decode a task outcome the log holds.
TaskOutcome<Object?> decodeTaskOutcome(Map<String, Object?> json) =>
    switch (json['status']) {
      'completed' => TaskCompleted<Object?>(json['result']),
      'failed' => TaskFailed<Object?>(
          TaskOutcomeError.fromJson(json['error']! as Map<String, Object?>),
          result: json['result'],
        ),
      'aborted' => TaskAborted<Object?>(
          reason: json['reason'] as String?, result: json['result']),
      'orphaned' => TaskOrphaned<Object?>(json['reason']! as String),
      'faulted' => TaskFaulted<Object?>(
          TaskOutcomeError.fromJson(json['error']! as Map<String, Object?>)),
      final status => throw ArgumentError('Unknown task outcome: $status'),
    };

/// Decode a wake reason the log holds.
WakeReason decodeWakeReason(Map<String, Object?> json) =>
    switch (json['reason']) {
      'time' => const WakeTime(),
      'expired' => const WakeExpired(),
      'signal' => WakeSignal(
          signal: json['signal']! as String, key: json['key']! as String),
      'tasks' => WakeTasks(<TaskId>[
          for (final id in json['ended']! as List<Object?>)
            idFromNumber<TaskKind>(id! as int),
        ]),
      final reason => throw ArgumentError('Unknown wake reason: $reason'),
    };

/// Decode a document content the log holds.
DocumentContent decodeDocumentContent(Map<String, Object?> json) =>
    json['kind'] == 'base'
        ? DocumentBase(
            json['version']! as int,
            (json['value']! as Map).cast<String, Object?>(),
          )
        : DocumentDelta(
            json['version']! as int,
            <Op>[
              for (final op in json['ops']! as List<Object?>)
                decodeOp(op! as List<Object?>)
            ],
          );

/// Decode one Chord operation from its upstream tuple form.
Op decodeOp(List<Object?> op) => switch (op[0]) {
      'r' => OpReplace(op[1]),
      's' => OpSet((op[1]! as List).cast<Seg>(), op[2]),
      'd' => OpDelete((op[1]! as List).cast<Seg>()),
      'a' => OpAppend((op[1]! as List).cast<Seg>(), op[2]! as String),
      't' => OpTruncate((op[1]! as List).cast<Seg>(), op[2]! as int),
      'p' => OpInsert(
          (op[1]! as List).cast<Seg>(),
          op[2]! as int,
          op[3]! as int,
          (op[4]! as List).cast<Object?>(),
        ),
      'm' => OpMove((op[1]! as List).cast<Seg>(), (op[2]! as List).cast<int>()),
      final kind => throw ArgumentError('Unknown op: $kind'),
    };
