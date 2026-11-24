/// The storage contract every durable backend implements.
///
/// Port of `packages/durable/src/types.ts` (`Storage`) and
/// `storage/store/storage.ts` at upstream
/// `780bf31fcaeb0563-4815-9db3-96e830e0b7df`. One interface, one contract,
/// three backends.
library;

import '../../chord/context.dart';
import '../../chord/ids.dart';
import '../errors.dart';
import '../types.dart';

/// The atomic persistence boundary: commit with receipts, mint, keyed lookups,
/// ordered scans, document reads, and close.
abstract interface class Storage {
  /// Persist [batches] in order, each as one atomic commit with its own seq,
  /// checked against the state the earlier ones left.
  ///
  /// [receive] is called once per durable batch, in order, after the batch is
  /// durable and before the call settles. Stops at the first batch the
  /// backend's own checks refuse.
  Future<CommitResult> commit(
    List<List<StorageWrite>> batches,
    void Function(int index, Seq seq) receive,
    Context context,
  );

  /// Install [publish], which a storage that publishes each commit inside its
  /// own scope calls with that commit's publication.
  void publishing(void Function() publish, Context context);

  /// A fresh ID greater than every ID minted since open and every ID stored.
  Future<Id<K>> mintId<K extends Object>();

  /// The conversation with [id], when it exists.
  Future<ConversationRecord?> conversation(ConversationId id, Context context);

  /// Conversations matching [query], in ID order, at most [limit].
  Future<Page<ConversationRecord>> scanConversations(
    ConversationQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  );

  /// The entry with [id] and the commit that stored it.
  Future<({EntryRecord entry, Seq commitSeq})?> entry(
      EntryId id, Context context);

  /// The entry with [id] visible from [conversationId].
  Future<({EntryRecord entry, Seq commitSeq})?> entryIn(
    ConversationId conversationId,
    EntryId id,
    Context context,
  );

  /// The newest entry visible from [conversationId] that carries a head marker,
  /// at or before [atOrBefore].
  Future<({EntryRecord entry, EntryId head})?> findLatestHeadMarker(
    ConversationId conversationId,
    EntryId? atOrBefore,
    Context context,
  );

  /// Entries of one conversation's fork-aware history, in scan order.
  Future<Page<EntryRecord>> scanEntries(
      EntryQuery query, int limit, Cursor? cursor, Context context);

  /// The task with [id], when it exists.
  Future<TaskRecord<Object?, Object?, Object?>?> task(
      TaskId id, Context context);

  /// Tasks matching [query], in ID order, at most [limit].
  Future<Page<TaskRecord<Object?, Object?, Object?>>> scanTasks(
    TaskQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  );

  /// The submission with [id], when it exists.
  Future<SubmissionRecord?> submission(SubmissionId id, Context context);

  /// Submissions matching [query], in ID order, at most [limit].
  Future<Page<SubmissionRecord>> scanSubmissions(
    SubmissionQuery query,
    int limit,
    Cursor? cursor,
    Context context,
  );

  /// The submission of [conversationId] with [requestId], when it exists.
  Future<SubmissionRecord?> submissionByRequest(
    ConversationId conversationId,
    String requestId,
    Context context,
  );

  /// The incarnation alive at [address] at [at], when one is.
  Future<DocumentRecord?> findDocument(
      DocumentAddress address, DocumentPoint at, Context context);

  /// The materialized content of [id] at [at], when it is readable there.
  Future<StoredDocument?> document(
      DocumentId id, DocumentPoint at, Context context);

  /// Document incarnations matching [query], in ID order, at most [limit].
  Future<Page<DocumentRecord>> scanDocuments(
      DocumentQuery query, int limit, Cursor? cursor, Context context);

  /// Close the backend; every later operation rejects.
  Future<void> close(Context context);
}

/// Where a built-in storage scan starts: its order and the last ID a previous
/// page returned.
class ScanStart {
  /// A scan starting in [order] after [after].
  const ScanStart({required this.order, this.after});

  /// The scan's order.
  final ScanOrder order;

  /// The last ID a previous page returned.
  final int? after;
}

/// Resolve a scan's order and position.
///
/// A cursor continues in the order it was created with, whether the query
/// repeats that order or omits it; a different `order` throws.
ScanStart scanStart(ScanOrder? requested, Cursor? cursor, ScanOrder fallback) {
  if (cursor == null) return ScanStart(order: requested ?? fallback);
  final order = cursor.order;
  if (requested != null && requested != order) {
    throw StorageRequestError(
      'The cursor continues a ${order.name} scan; the query asks for ${requested.name}',
    );
  }
  return ScanStart(order: order, after: cursor.after);
}

/// The continuation of a scan whose last returned item has [id].
Cursor nextCursor(int id, ScanOrder order) => Cursor(after: id, order: order);
