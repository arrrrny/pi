/// The durable foundation's failure taxonomy.
///
/// Port of `packages/durable/src/errors.ts` at upstream
/// `780bf31fcaeb252fa9b68df3964c735eae75bde3`.
library;

import '../chord/ids.dart';

/// The message of a thrown value, without throwing itself.
///
/// Formatting a value that resists formatting (a broken `toString`) must not
/// fail the code that reports it.
String errorMessage(Object? error) {
  if (error is Error) return error.toString();
  if (error is Exception) return error.toString();
  try {
    return '$error';
  } catch (_) {
    return 'an unprintable error';
  }
}

/// A transaction read a table after its first table write.
///
/// Read every required row before writing.
class ReadAfterWrite extends Error {
  /// [operation] names the call, such as `Tx.task()`.
  ReadAfterWrite(this.operation);

  /// The call that read after a write.
  final String operation;

  @override
  String toString() =>
      'ReadAfterWrite: $operation cannot read tables after the first table write';
}

/// A storage read rejected an invalid request, with no durable effect.
///
/// Unlike any other error a storage throws, it fails only that read, not the
/// session.
class StorageRequestError extends Error {
  /// A read that failed as an invalid request.
  StorageRequestError(this.detail);

  /// What was invalid.
  final String detail;

  @override
  String toString() => 'StorageRequestError: $detail';
}

/// The session failed, so nothing runs or commits any more.
///
/// It fails when a storage method throws, a commit cannot be adopted, or the
/// harness's own bookkeeping throws. Reopen the session; reopening recovers
/// from what was committed.
class SessionFailed extends Error {
  /// A session failed because of [cause].
  SessionFailed(this.cause);

  /// The first error that failed the session.
  final Object cause;

  @override
  String toString() =>
      'SessionFailed: Session failed after a storage error; close and reopen it ($cause)';
}

/// The session was opened read-only: a write was refused.
class ReadOnlySession extends Error {
  /// [what] names the refused operation.
  ReadOnlySession(this.what);

  /// The refused operation.
  final String what;

  @override
  String toString() => 'ReadOnlySession: Read-only Harness: $what refused';
}

/// A submission reached a busy conversation and was not admitted.
class ConversationBusy extends Error {
  /// The busy conversation.
  ConversationBusy(this.conversationId);

  /// The busy conversation.
  final ConversationId conversationId;

  @override
  String toString() => 'ConversationBusy: Conversation $conversationId is busy';
}

/// An input with `whenIdle: "reject"` reached an idle conversation.
class ConversationIdle extends Error {
  /// The idle conversation.
  ConversationIdle(this.conversationId);

  /// The idle conversation.
  final ConversationId conversationId;

  @override
  String toString() => 'ConversationIdle: Conversation $conversationId is idle';
}
