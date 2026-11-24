/// The in-memory reference backend.
///
/// Port of `packages/durable/src/storage/memory.ts` at upstream
/// `780bf31fcaeb252fa9b68df3964c735eae75bde3`. Retained writes and every read are
/// copied, which is backend conformance, not validation: the other backends
/// detach through serialization, and this one must agree with them.
library;

import '../../chord/context.dart';
import '../../chord/delta.dart';
import '../../chord/ids.dart';
import '../../chord/json.dart';
import '../errors.dart';
import '../types.dart';
import 'storage.dart';

/// A task record with its input, checkpoint and result left as JSON.
typedef StoredTask = TaskRecord<Object?, Object?, Object?>;

/// A document revision as stored: its content plus the commit that wrote it.
class _DocumentRevision {
  _DocumentRevision(this.content, this.seq);

  final DocumentContent content;
  final Seq seq;
}

class _StoredDocumentState {
  _StoredDocumentState(this.record, this.revisions);

  DocumentRecord record;
  List<_DocumentRevision> revisions;
}

class _DocumentAction {
  DocumentCreate? create;
  DocumentContent? content;
  bool retire = false;
}

class _DocumentAddressIndex {
  _DocumentAddressIndex();

  final List<DocumentId> ids = <DocumentId>[];
  DocumentId? currentId;
}

/// Detached in-memory reference implementation of [Storage].
class MemoryStorage implements Storage {
  final Map<Id<Object>, String> _recordTypes = <Id<Object>, String>{};
  final Map<ConversationId, ConversationRecord> _conversations =
      <ConversationId, ConversationRecord>{};
  final List<ConversationId> _conversationIds = <ConversationId>[];
  final Map<ConversationId, List<ConversationId>>
      _conversationIdsByOwnerConversation =
      <ConversationId, List<ConversationId>>{};
  final Map<TaskId, List<ConversationId>> _conversationIdsByOwnerTask =
      <TaskId, List<ConversationId>>{};
  final Map<EntryId, EntryRecord> _entries = <EntryId, EntryRecord>{};
  final Map<ConversationId, List<EntryId>> _entryIds =
      <ConversationId, List<EntryId>>{};
  final Map<ConversationId, List<EntryId>> _headEntryIds =
      <ConversationId, List<EntryId>>{};
  final Map<EntryId, Seq> _entryCommitSeqs = <EntryId, Seq>{};
  final Map<TaskId, StoredTask> _tasks = <TaskId, StoredTask>{};
  final List<TaskId> _taskIds = <TaskId>[];
  final Map<String, List<TaskId>> _taskIdsByStatus = <String, List<TaskId>>{};
  final Map<SubmissionId, SubmissionRecord> _submissions =
      <SubmissionId, SubmissionRecord>{};
  final List<SubmissionId> _submissionIds = <SubmissionId>[];
  final Map<String, List<SubmissionId>> _submissionIdsByStatus =
      <String, List<SubmissionId>>{};
  final Map<ConversationId, Map<String, SubmissionId>> _submissionIdsByRequest =
      <ConversationId, Map<String, SubmissionId>>{};
  final Map<DocumentId, _StoredDocumentState> _documents =
      <DocumentId, _StoredDocumentState>{};
  final Map<String, _DocumentAddressIndex> _documentAddresses =
      <String, _DocumentAddressIndex>{};
  final Map<String, List<DocumentId>> _documentIdsByScope =
      <String, List<DocumentId>>{};
  int _nextId = 2;
  int _nextSeq = 1;
  static const int _maxSafeId = 9007199254740991;
  bool _closed = false;

  @override
  Future<CommitResult> commit(
    List<List<StorageWrite>> batches,
    void Function(int index, Seq seq) receive,
    Context context,
  ) async {
    _assertOpen();
    final seqs = <Seq>[];
    Object? refused;
    try {
      for (final writes in batches) {
        List<StorageWrite> prepared;
        try {
          prepared = prepareCommit(writes, seqFromNumber(_nextSeq));
        } catch (error) {
          refused = error;
          break;
        }
        seqs.add(_applyPreparedCommit(
            prepared, _actionFor(prepared), seqFromNumber(_nextSeq)));
      }
    } finally {
      for (var index = 0; index < seqs.length; index++) {
        receive(index, seqs[index]);
      }
    }
    if (refused == null) {
      return CommitStored(seqs.length);
    }
    return CommitRefused(seqs.length, refused);
  }

  /// Validate and detach one commit without changing observable state.
  List<StorageWrite> prepareCommit(List<StorageWrite> writes, Seq seq) {
    _assertOpen();
    if (seq.value < _nextSeq) {
      throw StateError(
          'Commit sequence ${seq.value} does not strictly increase');
    }
    final detached = _resolveDocumentCopies(
        <StorageWrite>[for (final write in writes) _cloneWrite(write)]);
    _checkGlobalIds(detached);
    _checkDocumentActions(_actionFor(detached));
    return detached;
  }

  @override
  void publishing(void Function() publish, Context context) {
    // Memory is durable at once, so a commit needs no publication scope of its own.
  }

  @override
  Future<Id<K>> mintId<K extends Object>() async {
    _assertOpen();
    if (_nextId > _maxSafeId) {
      throw StateError('ID space is exhausted');
    }
    return idFromNumber<K>(_nextId++);
  }

  @override
  Future<ConversationRecord?> conversation(
      ConversationId id, Context context) async {
    _assertOpen();
    final value = _conversations[id];
    return value == null ? null : _cloneConversation(value);
  }

  @override
  Future<Page<ConversationRecord>> scanConversations(
    ConversationQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  ) async {
    _assertOpen();
    final ids = query.ownerTaskId != null
        ? (_conversationIdsByOwnerTask[query.ownerTaskId] ??
            const <ConversationId>[])
        : query.ownerConversationId != null
            ? (_conversationIdsByOwnerConversation[query.ownerConversationId] ??
                const <ConversationId>[])
            : _conversationIds;
    final start = scanStart(query.order, cursor, ScanOrder.ascending);
    final values = <ConversationRecord>[];
    for (final index in _scanIndexes(ids, start, (id) => id.value)) {
      if (values.length > limit) {
        break;
      }
      final value = _conversations[ids[index]]!;
      if (query.ownerConversationId != null &&
          value.owner?.conversationId != query.ownerConversationId) {
        continue;
      }
      values.add(value);
    }
    return _page(values, limit, start.order, (value) => value.id.value,
        _cloneConversation);
  }

  @override
  Future<({EntryRecord entry, Seq commitSeq})?> entry(
      EntryId id, Context context) async {
    _assertOpen();
    final entry = _entries[id];
    if (entry == null) {
      return null;
    }
    return (entry: _cloneEntry(entry), commitSeq: _entryCommitSeqs[id]!);
  }

  @override
  Future<({EntryRecord entry, Seq commitSeq})?> entryIn(
    ConversationId conversationId,
    EntryId id,
    Context context,
  ) async {
    _assertOpen();
    final iterator =
        _visibleEntries(conversationId, id.value, id.value).iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return (
      entry: _cloneEntry(iterator.current),
      commitSeq: _entryCommitSeqs[id]!
    );
  }

  @override
  Future<({EntryRecord entry, EntryId head})?> findLatestHeadMarker(
    ConversationId conversationId,
    EntryId? atOrBefore,
    Context context,
  ) async {
    _assertOpen();
    if (!_conversations.containsKey(conversationId)) {
      throw StorageRequestError('Unknown conversation: $conversationId');
    }
    var currentId = conversationId;
    var upperEntryId = atOrBefore?.value ?? 0x7ffffffffffff;
    while (true) {
      final ids = _headEntryIds[currentId] ?? const <EntryId>[];
      final index = _upperBound(ids, upperEntryId, (id) => id.value) - 1;
      if (index >= 0) {
        final entry = _entries[ids[index]]!;
        return (entry: _cloneEntry(entry), head: entry.head!);
      }
      final conversation = _conversations[currentId]!;
      final parent = conversation.parent;
      if (parent == null) {
        return null;
      }
      upperEntryId =
          upperEntryId < parent.at.value ? upperEntryId : parent.at.value;
      currentId = parent.conversationId;
    }
  }

  @override
  Future<Page<EntryRecord>> scanEntries(
      EntryQuery query, int limit, Cursor? cursor, Context context) async {
    _assertOpen();
    final start = scanStart(query.order, cursor, ScanOrder.descending);
    var minEntryId = query.minEntryId?.value;
    var maxEntryId = query.maxEntryId?.value;
    final after = start.after;
    if (after != null && start.order == ScanOrder.descending) {
      maxEntryId = _min(maxEntryId, after - 1);
    }
    if (after != null && start.order == ScanOrder.ascending) {
      minEntryId = _max(minEntryId, after + 1);
    }
    final visible = <EntryRecord>[];
    final entries = start.order == ScanOrder.descending
        ? _visibleEntries(query.conversationId, minEntryId, maxEntryId)
        : _visibleEntriesAscending(
            query.conversationId, minEntryId, maxEntryId);
    for (final entry in entries) {
      visible.add(entry);
      if (visible.length > limit) {
        break;
      }
    }
    return _page(
        visible, limit, start.order, (value) => value.id.value, _cloneEntry);
  }

  @override
  Future<StoredTask?> task(TaskId id, Context context) async {
    _assertOpen();
    final value = _tasks[id];
    return value == null ? null : _cloneTask(value);
  }

  @override
  Future<Page<StoredTask>> scanTasks(
      TaskQuery query, int limit, Cursor? cursor, Context context) async {
    _assertOpen();
    final start = scanStart(query.order, cursor, ScanOrder.ascending);
    final ids = query.status == null
        ? _taskIds
        : (_taskIdsByStatus[query.status!] ?? const <TaskId>[]);
    final values = <StoredTask>[];
    for (final index in _scanIndexes(ids, start, (id) => id.value)) {
      if (values.length > limit) {
        break;
      }
      final value = _tasks[ids[index]]!;
      if (query.conversationId != null &&
          value.conversationId != query.conversationId) {
        continue;
      }
      if (query.kind != null && value.kind != query.kind) {
        continue;
      }
      if (query.abortRequested != null &&
          value.abortRequested != query.abortRequested) {
        continue;
      }
      if (query.background != null && value.background != query.background) {
        continue;
      }
      values.add(value);
    }
    return _page(
        values, limit, start.order, (value) => value.id.value, _cloneTask);
  }

  @override
  Future<SubmissionRecord?> submission(SubmissionId id, Context context) async {
    _assertOpen();
    final value = _submissions[id];
    return value == null ? null : _cloneSubmission(value);
  }

  @override
  Future<Page<SubmissionRecord>> scanSubmissions(
    SubmissionQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  ) async {
    _assertOpen();
    final start = scanStart(query.order, cursor, ScanOrder.ascending);
    final ids = query.status == null
        ? _submissionIds
        : (_submissionIdsByStatus[query.status!] ?? const <SubmissionId>[]);
    final values = <SubmissionRecord>[];
    for (final index in _scanIndexes(ids, start, (id) => id.value)) {
      if (values.length > limit) {
        break;
      }
      final value = _submissions[ids[index]]!;
      if (query.conversationId != null &&
          value.conversationId != query.conversationId) {
        continue;
      }
      values.add(value);
    }
    return _page(values, limit, start.order, (value) => value.id.value,
        _cloneSubmission);
  }

  @override
  Future<SubmissionRecord?> submissionByRequest(
    ConversationId conversationId,
    String requestId,
    Context context,
  ) async {
    _assertOpen();
    final id = _submissionIdsByRequest[conversationId]?[requestId];
    if (id == null) {
      return null;
    }
    return _cloneSubmission(_submissions[id]!);
  }

  @override
  Future<DocumentRecord?> findDocument(
      DocumentAddress address, DocumentPoint at, Context context) async {
    _assertOpen();
    final index = _documentAddresses[address.keyString];
    if (at is CurrentPoint) {
      final currentId = index?.currentId;
      return currentId == null
          ? null
          : _cloneDocumentRecord(_documents[currentId]!.record);
    }
    for (final id in index?.ids ?? const <DocumentId>[]) {
      final record = _documents[id]!.record;
      if (record.isAliveAt(at)) {
        return _cloneDocumentRecord(record);
      }
    }
    return null;
  }

  @override
  Future<StoredDocument?> document(
      DocumentId id, DocumentPoint at, Context context) async {
    _assertOpen();
    final stored = _materializeDocument(id, at);
    if (stored == null) {
      return null;
    }
    return StoredDocument(
      record: _cloneDocumentRecord(stored.record),
      version: stored.version,
      value: _cloneObject(stored.value),
      deltasSinceBase: stored.deltasSinceBase,
    );
  }

  @override
  Future<Page<DocumentRecord>> scanDocuments(
    DocumentQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  ) async {
    _assertOpen();
    final ids =
        _documentIdsByScope[_scopeKeyFor(query.scope)] ?? const <DocumentId>[];
    final after = cursor?.after;
    final start = after == null ? 0 : _upperBound(ids, after, (id) => id.value);
    final values = <DocumentRecord>[];
    for (var index = start;
        index < ids.length && values.length <= limit;
        index++) {
      final record = _documents[ids[index]]!.record;
      if (query.kind != null && record.kind != query.kind) {
        continue;
      }
      if (record.isAliveAt(query.at)) {
        values.add(record);
      }
    }
    return _page(values, limit, ScanOrder.ascending, (value) => value.id.value,
        _cloneDocumentRecord);
  }

  @override
  Future<void> close(Context context) async => _closed = true;

  // ── internals ──────────────────────────────────────────────────────────────

  StoredDocument? _materializeDocument(DocumentId id, DocumentPoint at) {
    final stored = _documents[id];
    if (stored == null) {
      return null;
    }
    if (at is! CurrentPoint && stored.record.isCurrentOnly) {
      throw StorageRequestError(
          'Document $id does not retain historical content');
    }
    if (!stored.record.isAliveAt(at)) {
      return null;
    }
    final revisions = at is CurrentPoint
        ? stored.revisions
        : stored.revisions
            .where(
                (revision) => revision.seq.value <= (at as SeqPoint).seq.value)
            .toList();
    var baseIndex = revisions.length - 1;
    while (baseIndex >= 0 && revisions[baseIndex].content is! DocumentBase) {
      baseIndex--;
    }
    if (baseIndex < 0) {
      throw StateError('Document $id is missing a required base');
    }
    final base = revisions[baseIndex].content as DocumentBase;
    final batches = <List<Op>>[];
    for (var index = baseIndex + 1; index < revisions.length; index++) {
      final revision = revisions[index];
      final content = revision.content;
      if (content is! DocumentDelta || content.version != base.version) {
        throw StateError(
            'Document $id crosses a stored version boundary without a base');
      }
      batches.add(content.ops);
    }
    final value = applyImmutableBatches(_cloneObject(base.value), batches)!
        as Map<String, Object?>;
    return StoredDocument(
      record: stored.record,
      version: base.version,
      value: value,
      deltasSinceBase: revisions.length - baseIndex - 1,
    );
  }

  Iterable<EntryRecord> _visibleEntries(ConversationId conversationId,
      [int? minEntryId, int? maxEntryId]) sync* {
    if (!_conversations.containsKey(conversationId)) {
      throw StorageRequestError('Unknown conversation: $conversationId');
    }
    final lower = minEntryId ?? -0x8000000000000000;
    var upperEntryId = maxEntryId ?? 0x7ffffffffffff;
    var currentId = conversationId;
    while (true) {
      final ids = _entryIds[currentId] ?? const <EntryId>[];
      for (var index = _upperBound(ids, upperEntryId, (id) => id.value) - 1;
          index >= 0;
          index--) {
        final id = ids[index];
        if (id.value < lower) {
          break;
        }
        yield _cloneEntry(_entries[id]!);
      }
      final conversation = _conversations[currentId]!;
      final parent = conversation.parent;
      if (parent == null) {
        break;
      }
      upperEntryId = _min(upperEntryId, parent.at.value);
      if (upperEntryId < lower) {
        break;
      }
      currentId = parent.conversationId;
    }
  }

  Iterable<EntryRecord> _visibleEntriesAscending(
    ConversationId conversationId, [
    int? minEntryId,
    int? maxEntryId,
  ]) sync* {
    if (!_conversations.containsKey(conversationId)) {
      throw StorageRequestError('Unknown conversation: $conversationId');
    }
    final lower = minEntryId ?? -0x8000000000000000;
    final segments = <({ConversationId conversationId, int upper})>[];
    var currentId = conversationId;
    var upperEntryId = maxEntryId ?? 0x7ffffffffffff;
    while (true) {
      segments.add((conversationId: currentId, upper: upperEntryId));
      final conversation = _conversations[currentId]!;
      final parent = conversation.parent;
      if (parent == null) {
        break;
      }
      upperEntryId = _min(upperEntryId, parent.at.value);
      if (upperEntryId < lower) {
        break;
      }
      currentId = parent.conversationId;
    }
    for (final segment in segments.reversed) {
      final ids = _entryIds[segment.conversationId] ?? const <EntryId>[];
      for (var index = _lowerBound(ids, lower, (id) => id.value);
          index < ids.length;
          index++) {
        final id = ids[index];
        if (id.value > segment.upper) {
          break;
        }
        yield _cloneEntry(_entries[id]!);
      }
    }
  }

  void _checkGlobalIds(List<StorageWrite> writes) {
    final claimed = <Id<Object>, String>{};
    for (final write in writes) {
      if (write is DocumentChangeWrite || write is DocumentRetireWrite) {
        continue;
      }
      final isDocument =
          write is DocumentCreateWrite || write is DocumentCopyWrite;
      final table = isDocument
          ? 'document'
          : write is ConversationWrite
              ? 'conversation'
              : write is EntryWrite
                  ? 'entry'
                  : write is TaskWrite
                      ? 'task'
                      : 'submission';
      final id = isDocument
          ? (write as DocumentCreateWrite).record.id
          : write is ConversationWrite
              ? write.value.id
              : write is EntryWrite
                  ? write.value.id
                  : write is TaskWrite
                      ? write.value.id
                      : (write as SubmissionWrite).value.id;
      final existing = _recordTypes[id];
      final earlier = claimed[id];
      if (table == 'conversation' || table == 'entry' || table == 'document') {
        if (existing != null) {
          throw StateError('ID ${id.value} already belongs to $existing');
        }
        if (earlier != null) {
          throw StateError('ID ${id.value} is written more than once');
        }
      } else {
        if (existing != null && existing != table) {
          throw StateError('ID ${id.value} already belongs to $existing');
        }
        if (earlier != null && earlier != table) {
          throw StateError('ID ${id.value} is written as two record types');
        }
      }
      claimed[id] = table;
    }
  }

  Map<DocumentId, _DocumentAction> _actionFor(List<StorageWrite> writes) {
    final actions = <DocumentId, _DocumentAction>{};
    for (final write in writes) {
      if (write is! DocumentCreateWrite &&
          write is! DocumentChangeWrite &&
          write is! DocumentRetireWrite) {
        continue;
      }
      final id = write is DocumentCreateWrite
          ? write.record.id
          : write is DocumentChangeWrite
              ? write.id
              : (write as DocumentRetireWrite).id;
      final action = actions.putIfAbsent(id, _DocumentAction.new);
      switch (write) {
        case DocumentCreateWrite():
          if (action.create != null || action.content != null) {
            throw StateError(
                'Document ${id.value} has more than one content command');
          }
          action.create = write.record;
          action.content = write.content;
        case DocumentChangeWrite():
          if (action.content != null) {
            throw StateError(
                'Document ${id.value} has more than one content command');
          }
          action.content = write.content;
        case DocumentRetireWrite():
          if (action.retire) {
            throw StateError('Document ${id.value} is retired more than once');
          }
          action.retire = true;
        default:
          break;
      }
    }
    return actions;
  }

  void _checkDocumentActions(Map<DocumentId, _DocumentAction> actions) {
    final liveCounts = <String, int>{};
    for (final entry in actions.entries) {
      final id = entry.key;
      final action = entry.value;
      final existing = _documents[id];
      if (action.create == null && existing == null) {
        throw StateError('Unknown document: ${id.value}');
      }
      if (action.create != null && existing != null) {
        throw StateError('Document ${id.value} already exists');
      }
      if (existing != null && existing.record.retiredAt != null) {
        throw StateError('Document ${id.value} is retired');
      }
      final previous =
          existing?.revisions.isEmpty ?? true ? null : existing!.revisions.last;
      final content = action.content;
      if (content is DocumentDelta) {
        if (previous == null) {
          throw StateError('Document ${id.value} delta has no base');
        }
        if (previous.content.version != content.version) {
          throw StateError(
              'Document ${id.value} version transition requires a base');
        }
      }
      final key = _recordAddressKey(
        action.create != null
            ? DocumentRecord(
                id: action.create!.id,
                kind: action.create!.kind,
                scope: action.create!.scope,
                key: action.create!.key,
                createdAt: seqFromNumber(0),
                history: action.create!.history,
                fork: action.create!.fork,
              )
            : existing!.record,
      );
      final currentId = _documentAddresses[key]?.currentId;
      var live = liveCounts[key] ?? (currentId == null ? 0 : 1);
      if (action.retire && currentId == id) {
        live--;
      }
      if (action.create != null && !action.retire) {
        live++;
      }
      liveCounts[key] = live;
    }
    for (final live in liveCounts.values) {
      if (live > 1) {
        throw StateError('Document address already has a current incarnation');
      }
    }
  }

  List<StorageWrite> _resolveDocumentCopies(List<StorageWrite> writes) {
    if (!writes.any((write) => write is DocumentCopyWrite)) {
      return writes;
    }
    final changedDocumentIds = <DocumentId>{};
    for (final write in writes) {
      if (write is DocumentCreateWrite) {
        changedDocumentIds.add(write.record.id);
      } else if (write is DocumentCopyWrite) {
        changedDocumentIds.add(write.record.id);
      } else if (write is DocumentChangeWrite) {
        changedDocumentIds.add(write.id);
      } else if (write is DocumentRetireWrite) {
        changedDocumentIds.add(write.id);
      }
    }
    return <StorageWrite>[
      for (final write in writes)
        if (write is DocumentCopyWrite)
          _resolveCopy(write, changedDocumentIds)
        else
          write,
    ];
  }

  StorageWrite _resolveCopy(
      DocumentCopyWrite write, Set<DocumentId> changedDocumentIds) {
    try {
      if (changedDocumentIds.contains(write.source.id)) {
        throw StateError(
            'Fork source document ${write.source.id.value} is changed in the copy batch');
      }
      final stored = _materializeDocument(write.source.id, write.source.at);
      if (stored == null) {
        throw StateError(
            'Fork source document ${write.source.id.value} cannot be read');
      }
      final sourceScope = stored.record.scope;
      final targetScope = write.record.scope;
      if (sourceScope is! ConversationScope ||
          targetScope is! ConversationScope ||
          stored.record.kind != write.record.kind ||
          stored.record.key != write.record.key ||
          stored.record.history != write.record.history ||
          stored.record.fork != write.record.fork) {
        throw StateError(
            'Fork source document ${write.source.id.value} does not match the copied record');
      }
      return DocumentCreateWrite(
        record: write.record,
        content: DocumentBase(stored.version, _cloneObject(stored.value)),
      );
    } catch (error) {
      throw StateError(
          'Document copy ${write.record.id.value} was rejected: $error');
    }
  }

  Seq _applyPreparedCommit(List<StorageWrite> writes,
      Map<DocumentId, _DocumentAction> actions, Seq seq) {
    for (final write in writes) {
      switch (write) {
        case ConversationWrite(:final value):
          _recordTypes[value.id] = 'conversation';
          _conversations[value.id] = value;
          _insertSorted(_conversationIds, value.id, (id) => id.value);
          final owner = value.owner;
          if (owner != null) {
            _insertMapId(_conversationIdsByOwnerConversation,
                owner.conversationId, value.id, (id) => id.value);
            _insertMapId(_conversationIdsByOwnerTask, owner.taskId, value.id,
                (id) => id.value);
          }
          if (value.id.value + 1 > _nextId) {
            _nextId = value.id.value + 1;
          }
        case EntryWrite(:final value):
          _recordTypes[value.id] = 'entry';
          _entries[value.id] = value;
          _entryCommitSeqs[value.id] = seq;
          _insertSorted(
              _entryIds.putIfAbsent(value.conversationId, () => <EntryId>[]),
              value.id,
              (id) => id.value);
          if (value.head != null) {
            _insertSorted(
                _headEntryIds.putIfAbsent(
                    value.conversationId, () => <EntryId>[]),
                value.id,
                (id) => id.value);
          }
          if (value.id.value + 1 > _nextId) {
            _nextId = value.id.value + 1;
          }
        case TaskWrite(:final value):
          final id = idFromNumber<TaskKind>(value.id.value);
          _recordTypes[id] = 'task';
          final previous = _tasks[id];
          final status = value.state.status;
          if (previous == null) {
            _insertSorted(_taskIds, id, (taskId) => taskId.value);
            _insertSorted(
                _taskIdsByStatus.putIfAbsent(status, () => <TaskId>[]),
                id,
                (taskId) => taskId.value);
          } else if (previous.state.status != status) {
            _removeSorted(_taskIdsByStatus[previous.state.status] ?? <TaskId>[],
                id, (taskId) => taskId.value);
            _insertSorted(
                _taskIdsByStatus.putIfAbsent(status, () => <TaskId>[]),
                id,
                (taskId) => taskId.value);
          }
          _tasks[id] = value;
          if (id.value + 1 > _nextId) {
            _nextId = id.value + 1;
          }
        case SubmissionWrite(:final value):
          _recordTypes[value.id] = 'submission';
          final previous = _submissions[value.id];
          if (previous == null) {
            _insertSorted(_submissionIds, value.id, (id) => id.value);
            _insertSorted(
              _submissionIdsByStatus.putIfAbsent(
                  value.status, () => <SubmissionId>[]),
              value.id,
              (id) => id.value,
            );
          } else if (previous.status != value.status) {
            _removeSorted(
                _submissionIdsByStatus[previous.status] ?? <SubmissionId>[],
                value.id,
                (id) => id.value);
            _insertSorted(
              _submissionIdsByStatus.putIfAbsent(
                  value.status, () => <SubmissionId>[]),
              value.id,
              (id) => id.value,
            );
          }
          final previousRequestId = previous?.requestId;
          if (previousRequestId != null) {
            final previousRequests =
                _submissionIdsByRequest[previous!.conversationId];
            if (previousRequests != null &&
                previousRequests[previousRequestId] == value.id) {
              previousRequests.remove(previousRequestId);
              if (previousRequests.isEmpty) {
                _submissionIdsByRequest.remove(previous.conversationId);
              }
            }
          }
          _submissions[value.id] = value;
          final requestId = value.requestId;
          if (requestId != null) {
            _submissionIdsByRequest.putIfAbsent(value.conversationId,
                () => <String, SubmissionId>{})[requestId] = value.id;
          }
          if (value.id.value + 1 > _nextId) {
            _nextId = value.id.value + 1;
          }
        case DocumentCopyWrite():
          throw StateError('Prepared document copy was not resolved');
        case DocumentCreateWrite():
        case DocumentChangeWrite():
        case DocumentRetireWrite():
          break;
      }
    }
    _applyDocumentActions(actions, seq);
    _nextSeq = seq.value + 1;
    return seq;
  }

  void _applyDocumentActions(
      Map<DocumentId, _DocumentAction> actions, Seq seq) {
    for (final entry in actions.entries) {
      final id = entry.key;
      final action = entry.value;
      var stored = _documents[id];
      final create = action.create;
      if (create != null) {
        final record = DocumentRecord(
          id: create.id,
          kind: create.kind,
          scope: create.scope,
          key: create.key,
          createdAt: seq,
          retiredAt: action.retire ? seq : null,
          history: create.history,
          fork: create.fork,
        );
        stored = _StoredDocumentState(record,
            <_DocumentRevision>[_DocumentRevision(action.content!, seq)]);
        _recordTypes[id] = 'document';
        _documents[id] = stored;
        final key = _recordAddressKey(record);
        final address =
            _documentAddresses.putIfAbsent(key, _DocumentAddressIndex.new);
        _insertSorted(address.ids, id, (documentId) => documentId.value);
        _insertSorted(
          _documentIdsByScope.putIfAbsent(
              _scopeKeyFor(record.scope), () => <DocumentId>[]),
          id,
          (documentId) => documentId.value,
        );
        if (id.value + 1 > _nextId) {
          _nextId = id.value + 1;
        }
      } else if (action.content != null) {
        final revision = _DocumentRevision(action.content!, seq);
        if (action.content is DocumentBase && stored!.record.isCurrentOnly) {
          stored.revisions = <_DocumentRevision>[revision];
        } else {
          stored!.revisions.add(revision);
        }
      }
      if (action.retire && create == null) {
        stored!.record = stored.record.retired(seq);
      }
      if (action.retire && stored!.record.isCurrentOnly) {
        stored.revisions = <_DocumentRevision>[];
      }
      if (create != null || action.retire) {
        final address = _documentAddresses[_recordAddressKey(stored!.record)]!;
        if (action.retire && address.currentId == id) {
          address.currentId = null;
        }
        if (create != null && !action.retire) {
          address.currentId = id;
        }
      }
    }
  }

  void _assertOpen() {
    if (_closed) {
      throw StateError('MemoryStorage is closed');
    }
  }
}

// ── shared helpers ───────────────────────────────────────────────────────────

String _scopeKeyFor(DocumentScope scope) => switch (scope) {
      SessionScope() => 'session',
      ConversationScope(:final conversationId) =>
        'conversation:${conversationId.value}',
      TaskScope(:final taskId) => 'task:${taskId.value}',
    };

String _recordAddressKey(DocumentRecord record) =>
    '${record.kind}|${_scopeKeyFor(record.scope)}|${record.key == null ? 'singleton' : 'family:${record.key}'}';

int _min(int? left, int right) => left == null || right < left ? right : left;

int _max(int? left, int right) => left == null || right > left ? right : left;

int _lowerBound<T>(List<T> values, int target, int Function(T) id) {
  var low = 0;
  var high = values.length;
  while (low < high) {
    final middle = (low + high) >>> 1;
    if (id(values[middle]) < target) {
      low = middle + 1;
    } else {
      high = middle;
    }
  }
  return low;
}

int _upperBound<T>(List<T> values, int target, int Function(T) id) {
  var low = 0;
  var high = values.length;
  while (low < high) {
    final middle = (low + high) >>> 1;
    if (id(values[middle]) <= target) {
      low = middle + 1;
    } else {
      high = middle;
    }
  }
  return low;
}

void _insertSorted<T>(List<T> values, T value, int Function(T) id) {
  if (values.isEmpty || id(values.last) < id(value)) {
    values.add(value);
  } else {
    values.insert(_lowerBound(values, id(value), id), value);
  }
}

void _removeSorted<T>(List<T> values, T value, int Function(T) id) {
  final index = _lowerBound(values, id(value), id);
  if (index < values.length && id(values[index]) == id(value)) {
    values.removeAt(index);
  }
}

void _insertMapId<K, V>(
    Map<K, List<V>> index, K key, V value, int Function(V) id) {
  _insertSorted(index.putIfAbsent(key, () => <V>[]), value, id);
}

Iterable<int> _scanIndexes<T>(
    List<T> values, ScanStart start, int Function(T) id) sync* {
  if (start.order == ScanOrder.ascending) {
    final first =
        start.after == null ? 0 : _upperBound(values, start.after!, id);
    for (var index = first; index < values.length; index++) {
      yield index;
    }
  } else {
    final end = start.after == null
        ? values.length
        : _lowerBound(values, start.after!, id);
    for (var index = end - 1; index >= 0; index--) {
      yield index;
    }
  }
}

Page<T> _page<T>(
  List<T> values,
  int limit,
  ScanOrder order,
  int Function(T) id,
  T Function(T) clone,
) {
  final items = values.take(limit).toList();
  if (values.length <= limit) {
    return Page<T>(<T>[for (final item in items) clone(item)]);
  }
  return Page<T>(
    <T>[for (final item in items) clone(item)],
    next: nextCursor(id(items.last), order),
  );
}

// ── clones ───────────────────────────────────────────────────────────────────

Map<String, Object?> _cloneObject(Map<String, Object?> value) =>
    copyJson(value)! as Map<String, Object?>;

ConversationRecord _cloneConversation(ConversationRecord value) => value;

EntryRecord _cloneEntry(EntryRecord value) => EntryRecord(
      id: value.id,
      conversationId: value.conversationId,
      kind: value.kind,
      model: value.model == null
          ? null
          : (copyJson(value.model) as List).cast<Object?>(),
      data: copyJson(value.data),
      head: value.head,
      edits: value.edits,
      byTaskId: value.byTaskId,
    );

StoredTask _cloneTask(StoredTask value) =>
    TaskRecord<Object?, Object?, Object?>(
      id: value.id,
      conversationId: value.conversationId,
      kind: value.kind,
      version: value.version,
      input: copyJson(value.input),
      state: _cloneState(value.state),
      owner: value.owner,
      background: value.background,
      abortRequested: value.abortRequested,
      abortReason: value.abortReason,
      abandonOnRestart: value.abandonOnRestart,
      startedAt: value.startedAt,
      endedAt: value.endedAt,
      restarts: value.restarts,
      memos: value.memos == null
          ? null
          : (copyJson(value.memos) as Map).cast<String, Object?>(),
    );

TaskState<Object?, Object?> _cloneState(TaskState<Object?, Object?> state) {
  if (state is TaskPending<Object?, Object?>) {
    return TaskPending<Object?, Object?>(copyJson(state.checkpoint),
        wake: state.wake);
  }
  if (state is TaskRunning<Object?, Object?>) {
    return TaskRunning<Object?, Object?>(copyJson(state.checkpoint),
        wake: state.wake);
  }
  if (state is TaskWaiting<Object?, Object?>) {
    return TaskWaiting<Object?, Object?>(copyJson(state.checkpoint),
        on: state.on, policy: state.policy);
  }
  if (state is TaskSleeping<Object?, Object?>) {
    return TaskSleeping<Object?, Object?>(copyJson(state.checkpoint),
        until: state.until, signals: state.signals);
  }
  if (state is TaskCompleting<Object?, Object?>) {
    return TaskCompleting<Object?, Object?>(_cloneOutcome(state.outcome));
  }
  return TaskTerminal<Object?, Object?>(
      _cloneOutcome((state as TaskTerminal<Object?, Object?>).outcome));
}

TaskOutcome<Object?> _cloneOutcome(TaskOutcome<Object?> outcome) =>
    switch (outcome) {
      TaskCompleted(:final result) => TaskCompleted<Object?>(copyJson(result)),
      TaskFailed(:final error, :final result) =>
        TaskFailed<Object?>(error, result: copyJson(result)),
      TaskAborted(:final reason, :final result) =>
        TaskAborted<Object?>(reason: reason, result: copyJson(result)),
      TaskOrphaned(:final reason) => TaskOrphaned<Object?>(reason),
      TaskFaulted(:final error) => TaskFaulted<Object?>(error),
    };

SubmissionRecord _cloneSubmission(SubmissionRecord value) => SubmissionRecord(
      id: value.id,
      conversationId: value.conversationId,
      type: value.type,
      status: value.status,
      requestId: value.requestId,
      entry: value.entry,
      answer: value.answer,
      reason: value.reason,
      detail: copyJson(value.detail),
      notify: value.notify,
    );

DocumentRecord _cloneDocumentRecord(DocumentRecord value) => value;

StorageWrite _cloneWrite(StorageWrite write) => switch (write) {
      ConversationWrite(:final value) =>
        ConversationWrite(_cloneConversation(value)),
      EntryWrite(:final value) => EntryWrite(_cloneEntry(value)),
      TaskWrite(:final value) => TaskWrite(_cloneTask(value)),
      SubmissionWrite(:final value) => SubmissionWrite(_cloneSubmission(value)),
      DocumentCreateWrite(:final record, :final content) => DocumentCreateWrite(
          record: record,
          content: DocumentBase(content.version, _cloneObject(content.value))),
      DocumentCopyWrite(:final record, :final source) =>
        DocumentCopyWrite(record: record, source: source),
      DocumentChangeWrite(:final id, :final content) => DocumentChangeWrite(
          id: id,
          content: content is DocumentBase
              ? DocumentBase(content.version, _cloneObject(content.value))
              : DocumentDelta(
                  content.version, _cloneOps((content as DocumentDelta).ops)),
        ),
      DocumentRetireWrite(:final id) => DocumentRetireWrite(id),
    };

/// Deep-copy an op batch, so a retained delta never aliases a caller's payload.
List<Op> _cloneOps(List<Op> ops) => <Op>[
      for (final op in ops)
        switch (op) {
          OpReplace(:final value) => OpReplace(copyJson(value)),
          OpSet(:final path, :final value) =>
            OpSet(List<Seg>.of(path), copyJson(value)),
          OpDelete(:final path) => OpDelete(List<Seg>.of(path)),
          OpAppend(:final path, :final value) =>
            OpAppend(List<Seg>.of(path), value),
          OpTruncate(:final path, :final length) =>
            OpTruncate(List<Seg>.of(path), length),
          OpInsert(
            :final path,
            :final start,
            :final deleteCount,
            :final items
          ) =>
            OpInsert(
              List<Seg>.of(path),
              start,
              deleteCount,
              <Object?>[for (final item in items) copyJson(item)],
            ),
          OpMove(:final path, :final permutation) =>
            OpMove(List<Seg>.of(path), List<int>.of(permutation)),
        },
    ];
