/// Branded numeric identifiers and commit sequences.
///
/// Port of `packages/durable/src/ids.ts` and the `Id`/`Seq` brands in
/// `packages/durable/src/types.ts` at upstream
/// `780bf31fcaeb252fa9b68df3964c735eae75bde3`.
library;

/// Erased nominal number identifying one durable record kind.
///
/// The type parameter is the kind marker (`ConversationKind`, `EntryKind`, …),
/// so a `ConversationId` is not usable where an `EntryId` is required, exactly
/// as upstream's branded number is not.
final class Id<Kind extends Object> implements Comparable<Id<Kind>> {
  /// Brand [value] as an [Id] of [Kind].
  const Id(this.value);

  /// The underlying number.
  final int value;

  @override
  int compareTo(Id<Kind> other) => value.compareTo(other.value);

  // The brand is a COMPILE-TIME distinction only, exactly as upstream's is: all
  // five record kinds share one numeric namespace, so `Id<EntryKind>(100)` must
  // equal `Id<TaskKind>(100)` at runtime or the storage's global-ID ownership
  // check would read two rows as different IDs.
  @override
  bool operator ==(Object other) => other is Id<Object> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '$value';
}

/// Marker for [ConversationId].
final class ConversationKind {}

/// Marker for [EntryId].
final class EntryKind {}

/// Marker for [TaskId].
final class TaskKind {}

/// Marker for [SubmissionId].
final class SubmissionKind {}

/// Marker for [DocumentKindId].
final class DocumentKindId {}

/// Marker for [Seq].
final class SeqKind {}

/// Identifies one conversation record.
typedef ConversationId = Id<ConversationKind>;

/// Identifies one entry record.
typedef EntryId = Id<EntryKind>;

/// Identifies one task record.
typedef TaskId = Id<TaskKind>;

/// Identifies one submission record.
typedef SubmissionId = Id<SubmissionKind>;

/// Identifies one document incarnation.
typedef DocumentId = Id<DocumentKindId>;

/// Strictly increasing sequence assigned to one atomic storage commit; gaps
/// are permitted.
typedef Seq = Id<SeqKind>;

/// The root conversation always uses this reserved ID.
const ConversationId rootConversationId = Id<ConversationKind>(1);

/// Brand [value] as an [Id]; applied at a trust boundary (decoded storage,
/// a cursor, an untyped wire field).
Id<K> idFromNumber<K extends Object>(int value) => Id<K>(value);

/// Brand [value] as a [Seq]; applied at a trust boundary.
Seq seqFromNumber(int value) => Id<SeqKind>(value);
