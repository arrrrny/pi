/// The durable foundation's record, state, and write vocabulary.
///
/// Port of `packages/durable/src/types.ts` (the parts the foundation slice
/// owns) at upstream `780bf31fcaeb252fa9b68df3964c735eae75bde3`.
library;

import '../chord/delta.dart';
import '../chord/ids.dart';
import '../chord/json.dart';

// ─── Documents ───────────────────────────────────────────────────────────────

/// Stored replay state supplied to a document's checkpoint predicate.
class CheckpointInfo {
  /// Information about the replay before the change being evaluated.
  const CheckpointInfo({required this.deltasSinceBase});

  /// Deltas already stored after the newest base, excluding the change being
  /// evaluated.
  final int deltasSinceBase;
}

/// Ownership and lifetime of a document.
///
/// Only conversation documents declare history and fork behaviour.
sealed class DocumentSemantics {
  const DocumentSemantics();
}

/// A session document: current-only, owned by the session.
final class SessionSemantics extends DocumentSemantics {
  /// A session-scoped document.
  const SessionSemantics();
}

/// A conversation document that retains only its current state.
final class LatestConversationSemantics extends DocumentSemantics {
  /// A latest-only conversation document forking by [fork].
  const LatestConversationSemantics(this.fork);

  /// `current` or `initial`.
  final ForkPolicy fork;
}

/// A conversation document whose history remains addressable for as-of reads.
final class RewindableConversationSemantics extends DocumentSemantics {
  /// A rewindable conversation document forking by [fork].
  const RewindableConversationSemantics(this.fork);

  /// `asOf`, `current` or `initial`.
  final ForkPolicy fork;
}

/// A task document: current-only, retired with its task.
final class TaskSemantics extends DocumentSemantics {
  /// A task-scoped document.
  const TaskSemantics();
}

/// How a fork initializes a conversation document's value.
enum ForkPolicy {
  /// At the fork cutoff.
  asOf,

  /// The source's current value.
  current,

  /// The definition's initial value.
  initial,
}

/// The scope a document lives in.
sealed class DocumentScope {
  const DocumentScope();
}

/// A document owned by the session.
final class SessionScope extends DocumentScope {
  /// The session scope.
  const SessionScope();
}

/// A document owned by one conversation.
final class ConversationScope extends DocumentScope {
  /// The scope of [conversationId].
  const ConversationScope(this.conversationId);

  /// The owning conversation.
  final ConversationId conversationId;
}

/// A document owned by one task.
final class TaskScope extends DocumentScope {
  /// The scope of [taskId].
  const TaskScope(this.taskId);

  /// The owning task.
  final TaskId taskId;
}

/// Definition fields shared by singleton documents and document families.
abstract class CommonDocDefinition<T extends JsonObject> {
  /// Stable persisted kind; part of the public protocol.
  String get kind;

  /// Positive integer version of the stored value shape.
  int get version;

  /// The value a new document starts from.
  T initial();

  /// Convert a value stored by an older supported version.
  T? migrate(JsonObject value, int fromVersion) => null;

  /// Required policy: return true to store this ordinary change as a complete
  /// base instead of a delta.
  bool checkpointWhen(T value, List<Op> ops, CheckpointInfo info);
}

/// Singleton document definition.
abstract class DocDefinition<T extends JsonObject>
    extends CommonDocDefinition<T> {
  /// Where the document lives and how it survives forks.
  DocumentSemantics get semantics;
}

/// Keyed document family definition; [initialFor] runs only when a member is
/// absent.
abstract class DocFamilyDefinition<T extends JsonObject, I extends Object?>
    extends CommonDocDefinition<T> {
  /// Where the family lives and how its members survive forks.
  DocumentSemantics get semantics;

  /// The value a new family member seeded with [seed] starts from.
  T initialFor(I seed);
}

/// A typed singleton document token passed explicitly to typed access.
class DocToken<T extends JsonObject, D extends DocDefinition<T>> {
  /// A token for [definition].
  const DocToken(this.definition);

  /// The definition this token carries.
  final D definition;
}

/// A typed document family token passed explicitly to typed access.
class DocFamilyToken<T extends JsonObject, I extends Object?,
    D extends DocFamilyDefinition<T, I>> {
  /// A token for [definition].
  const DocFamilyToken(this.definition);

  /// The definition this token carries.
  final D definition;
}

/// A session-scoped singleton document token.
typedef SessionDocToken<T extends JsonObject> = DocToken<T, DocDefinition<T>>;

/// A conversation-scoped singleton document token.
typedef ConversationDocToken<T extends JsonObject>
    = DocToken<T, DocDefinition<T>>;

/// A task-scoped singleton document token.
typedef TaskDocToken<T extends JsonObject> = DocToken<T, DocDefinition<T>>;

/// A session-scoped document family token.
typedef SessionDocFamilyToken<T extends JsonObject, I extends Object?>
    = DocFamilyToken<T, I, DocFamilyDefinition<T, I>>;

/// A conversation-scoped document family token.
typedef ConversationDocFamilyToken<T extends JsonObject, I extends Object?>
    = DocFamilyToken<T, I, DocFamilyDefinition<T, I>>;

/// A task-scoped document family token.
typedef TaskDocFamilyToken<T extends JsonObject, I extends Object?>
    = DocFamilyToken<T, I, DocFamilyDefinition<T, I>>;

// ─── Entries ─────────────────────────────────────────────────────────────────

/// An immutable override of one visible entry's contribution to model context.
sealed class ContextEdit {
  const ContextEdit(this.target);

  /// The entry whose model messages are affected.
  final EntryId target;
}

/// Omit an entry from model context.
final class ContextOmit extends ContextEdit {
  /// Omit [target].
  const ContextOmit(super.target);
}

/// Replace an entry's model messages for context.
final class ContextReplace extends ContextEdit {
  /// Replace [target]'s messages with [messages].
  const ContextReplace(super.target, this.messages);

  /// The messages contributed instead.
  final List<Object?> messages;
}

/// Immutable transcript event with separate model-facing and application-facing
/// payloads.
class EntryRecord {
  /// An entry record.
  const EntryRecord({
    required this.id,
    required this.conversationId,
    required this.kind,
    this.model,
    this.data,
    this.head,
    this.edits,
    this.byTaskId,
  });

  /// The entry's identity; never reused.
  final EntryId id;

  /// The conversation whose transcript owns this entry.
  final ConversationId conversationId;

  /// Application-defined entry discriminator.
  final String kind;

  /// Messages contributed to model context; absent for display or bookkeeping
  /// entries.
  final List<Object?>? model;

  /// JSON payload consumed by views, extensions, or bookkeeping logic.
  final Object? data;

  /// First entry in the active context selected by this entry.
  final EntryId? head;

  /// Context-only overrides of earlier visible entries.
  final List<ContextEdit>? edits;

  /// Task that appended this entry, when durable work produced it.
  final TaskId? byTaskId;

  /// This record as strict JSON.
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id.value,
        'conversationId': conversationId.value,
        'kind': kind,
        if (model != null) 'model': copyJson(model),
        if (data != null) 'data': copyJson(data),
        if (head != null) 'head': head!.value,
        if (edits != null)
          'edits': <Object?>[for (final edit in edits!) _editToJson(edit)],
        if (byTaskId != null) 'byTaskId': byTaskId!.value,
      };

  /// A record decoded from [json], a value storage returned.
  static EntryRecord fromJson(Map<String, Object?> json) => EntryRecord(
        id: idFromNumber<EntryKind>(json['id']! as int),
        conversationId:
            idFromNumber<ConversationKind>(json['conversationId']! as int),
        kind: json['kind']! as String,
        model: (json['model'] as List<Object?>?)?.map(copyJson).toList(),
        data: copyJson(json['data']),
        head: json['head'] == null
            ? null
            : idFromNumber<EntryKind>(json['head']! as int),
        edits: (json['edits'] as List<Object?>?)
            ?.map((edit) => _editFromJson(edit! as Map<String, Object?>))
            .toList(),
        byTaskId: json['byTaskId'] == null
            ? null
            : idFromNumber<TaskKind>(json['byTaskId']! as int),
      );
}

Map<String, Object?> _editToJson(ContextEdit edit) => switch (edit) {
      ContextOmit(:final target) => <String, Object?>{
          'target': target.value,
          'action': 'omit'
        },
      ContextReplace(:final target, :final messages) => <String, Object?>{
          'target': target.value,
          'action': 'replace',
          'messages': copyJson(messages),
        },
    };

ContextEdit _editFromJson(Map<String, Object?> json) {
  final target = idFromNumber<EntryKind>(json['target']! as int);
  return json['action'] == 'omit'
      ? ContextOmit(target)
      : ContextReplace(
          target, (json['messages'] as List<Object?>?) ?? const <Object?>[]);
}

/// Entry content supplied before the session assigns identity and attribution.
class EntryDraft {
  /// A draft entry of [kind].
  const EntryDraft(
      {required this.kind,
      this.model,
      this.data,
      this.head,
      this.headSelf = false,
      this.edits});

  /// The entry's discriminator.
  final String kind;

  /// Messages contributed to model context.
  final List<Object?>? model;

  /// JSON payload.
  final Object? data;

  /// An explicit head marker, or the entry itself when [headSelf].
  final EntryId? head;

  /// Whether the new entry becomes its own head marker.
  final bool headSelf;

  /// Context-only overrides.
  final List<ContextEdit>? edits;
}

/// A typed entry kind with a narrowing guard.
class Entry<D extends Object?> {
  /// A token for entry [kind].
  const Entry(this.kind);

  /// The entry discriminator this token names.
  final String kind;

  /// Whether [entry] has this kind.
  ///
  /// Upstream names this guard `is`; `is` is a Dart keyword, so the port spells
  /// the same guard `matches`.
  bool matches(EntryRecord? entry) => entry != null && entry.kind == kind;
}

// ─── Conversations ───────────────────────────────────────────────────────────

/// A conversation's fork source and the inclusive parent entry it inherits
/// through.
class ConversationParent {
  /// A fork of [conversationId] through [at].
  const ConversationParent({required this.conversationId, required this.at});

  /// The fork source.
  final ConversationId conversationId;

  /// The inclusive parent entry.
  final EntryId at;

  /// This parent as strict JSON.
  Map<String, Object?> toJson() =>
      <String, Object?>{'conversationId': conversationId.value, 'at': at.value};

  /// A parent decoded from [json].
  static ConversationParent fromJson(Map<String, Object?> json) =>
      ConversationParent(
        conversationId:
            idFromNumber<ConversationKind>(json['conversationId']! as int),
        at: idFromNumber<EntryKind>(json['at']! as int),
      );
}

/// A conversation's creator edge: the task that created it.
class ConversationOwner {
  /// A conversation owned by [taskId] of [conversationId].
  const ConversationOwner({required this.conversationId, required this.taskId});

  /// The owning task's conversation.
  final ConversationId conversationId;

  /// The owning task.
  final TaskId taskId;

  /// This owner as strict JSON.
  Map<String, Object?> toJson() => <String, Object?>{
        'conversationId': conversationId.value,
        'taskId': taskId.value
      };

  /// An owner decoded from [json].
  static ConversationOwner fromJson(Map<String, Object?> json) =>
      ConversationOwner(
        conversationId:
            idFromNumber<ConversationKind>(json['conversationId']! as int),
        taskId: idFromNumber<TaskKind>(json['taskId']! as int),
      );
}

/// Immutable identity, history ancestry, and task ownership of a transcript
/// scope.
class ConversationRecord {
  /// A conversation record.
  const ConversationRecord({required this.id, this.parent, this.owner});

  /// The conversation's identity.
  final ConversationId id;

  /// Fork source and inclusive parent entry.
  final ConversationParent? parent;

  /// Creator edge used for attribution, subtree abort, and subtree idle waits.
  final ConversationOwner? owner;

  /// This record as strict JSON.
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id.value,
        if (parent != null) 'parent': parent!.toJson(),
        if (owner != null) 'owner': owner!.toJson(),
      };

  /// A record decoded from [json].
  static ConversationRecord fromJson(Map<String, Object?> json) =>
      ConversationRecord(
        id: idFromNumber<ConversationKind>(json['id']! as int),
        parent: json['parent'] == null
            ? null
            : ConversationParent.fromJson(
                json['parent']! as Map<String, Object?>),
        owner: json['owner'] == null
            ? null
            : ConversationOwner.fromJson(
                json['owner']! as Map<String, Object?>),
      );
}

/// Ownership selected explicitly whenever a conversation is created.
sealed class ConversationOwnership {
  const ConversationOwnership();
}

/// A conversation with no task owner.
final class OwnerlessOwnership extends ConversationOwnership {
  /// No owner.
  const OwnerlessOwnership();
}

/// A conversation created by [taskId].
final class TaskConversationOwnership extends ConversationOwnership {
  /// Owned by [taskId].
  const TaskConversationOwnership(this.taskId);

  /// The owning task.
  final TaskId taskId;
}

/// Creation inputs for a conversation.
class ConversationInit {
  /// A conversation with [ownership] and optional [parent].
  const ConversationInit({required this.ownership, this.parent});

  /// Who owns the new conversation.
  final ConversationOwnership ownership;

  /// The fork source, when this is a fork.
  final ConversationParent? parent;
}

// ─── Tasks ───────────────────────────────────────────────────────────────────

/// JSON-safe error snapshot persisted instead of a runtime error object.
class TaskOutcomeError {
  /// An outcome error.
  const TaskOutcomeError(this.message, {this.detail});

  /// The failure message.
  final String message;

  /// Optional structured diagnostic data.
  final Object? detail;

  /// This error as strict JSON.
  Map<String, Object?> toJson() => <String, Object?>{
        'message': message,
        if (detail != null) 'detail': copyJson(detail),
      };

  /// An error decoded from [json].
  static TaskOutcomeError fromJson(Map<String, Object?> json) =>
      TaskOutcomeError(json['message']! as String,
          detail: copyJson(json['detail']));
}

/// Durable reason and optional result recorded when a task becomes terminal.
sealed class TaskOutcome<R> {
  const TaskOutcome();
}

/// The task completed with [result].
final class TaskCompleted<R> extends TaskOutcome<R> {
  /// A completed outcome.
  const TaskCompleted(this.result);

  /// The task's result.
  final R result;
}

/// The task committed a domain failure.
final class TaskFailed<R> extends TaskOutcome<R> {
  /// A failed outcome.
  const TaskFailed(this.error, {this.result});

  /// The failure.
  final TaskOutcomeError error;

  /// An optional partial result.
  final R? result;
}

/// The task was explicitly cancelled.
final class TaskAborted<R> extends TaskOutcome<R> {
  /// An aborted outcome.
  const TaskAborted({this.reason, this.result});

  /// Why it was aborted.
  final String? reason;

  /// An optional partial result.
  final R? result;
}

/// The task cannot resume because its definition is unavailable.
final class TaskOrphaned<R> extends TaskOutcome<R> {
  /// An orphaned outcome.
  const TaskOrphaned(this.reason);

  /// Why it cannot resume.
  final String reason;
}

/// The runtime detected a contract failure.
final class TaskFaulted<R> extends TaskOutcome<R> {
  /// A faulted outcome.
  const TaskFaulted(this.error);

  /// The contract failure.
  final TaskOutcomeError error;
}

/// The durable state of a task.
sealed class TaskState<S, R> {
  const TaskState();

  /// The status discriminator, as storage indexes it.
  String get status;
}

/// A [TaskState] that still carries a checkpoint.
sealed class CheckpointedTaskState<S, R> extends TaskState<S, R> {
  const CheckpointedTaskState(this.checkpoint);

  /// The durable state execution resumes from.
  final S checkpoint;
}

/// Eligible for scheduling.
final class TaskPending<S, R> extends CheckpointedTaskState<S, R> {
  /// A pending task.
  const TaskPending(super.checkpoint, {this.wake});

  /// Why the task woke from its last wait or sleep.
  final WakeReason? wake;

  @override
  String get status => 'pending';
}

/// Reserved by one in-memory invocation.
final class TaskRunning<S, R> extends CheckpointedTaskState<S, R> {
  /// A running task.
  const TaskRunning(super.checkpoint, {this.wake});

  /// Why the task woke from its last wait or sleep.
  final WakeReason? wake;

  @override
  String get status => 'running';
}

/// Parked until every task in [on] is terminal.
final class TaskWaiting<S, R> extends CheckpointedTaskState<S, R> {
  /// A waiting task.
  const TaskWaiting(super.checkpoint, {required this.on, required this.policy});

  /// The tasks this task waits on.
  final List<TaskId> on;

  /// How the wait decides it is over.
  final JoinPolicy policy;

  @override
  String get status => 'waiting';
}

/// Parked until the clock reaches [until] or a signal wakes it.
final class TaskSleeping<S, R> extends CheckpointedTaskState<S, R> {
  /// A sleeping task.
  const TaskSleeping(super.checkpoint, {this.until, this.signals});

  /// The clock deadline, in milliseconds.
  final int? until;

  /// Signal keys whose value wakes the task.
  final List<SignalKey>? signals;

  @override
  String get status => 'sleeping';
}

/// An outcome was decided; the task becomes terminal once ordinary owned work
/// drained.
final class TaskCompleting<S, R> extends TaskState<S, R> {
  /// A completing task.
  const TaskCompleting(this.outcome);

  /// The held outcome.
  final TaskOutcome<R> outcome;

  @override
  String get status => 'completing';
}

/// Permanently settled durable result receipt.
final class TaskTerminal<S, R> extends TaskState<S, R> {
  /// A terminal task.
  const TaskTerminal(this.outcome);

  /// The final outcome.
  final TaskOutcome<R> outcome;

  @override
  String get status => 'terminal';
}

/// How a waiting task treats the tasks it waits on.
enum JoinPolicy {
  /// Resume once every task settles; abort the others once one fails.
  failFast,

  /// Resume once every task settles.
  allSettled,

  /// Resume once at least one task settles.
  any,
}

/// Why parked work runs again.
sealed class WakeReason {
  const WakeReason();

  /// The discriminator storage persists.
  String get reason;
}

/// The sleep's deadline came and no signals were listed.
final class WakeTime extends WakeReason {
  /// Woken by time.
  const WakeTime();

  @override
  String get reason => 'time';
}

/// The deadline came before any listed signal.
final class WakeExpired extends WakeReason {
  /// Woken by an expiry.
  const WakeExpired();

  @override
  String get reason => 'expired';
}

/// A listed signal held an unused value.
final class WakeSignal extends WakeReason {
  /// Woken by [signal] under [key].
  const WakeSignal({required this.signal, required this.key});

  /// The signal's token name.
  final String signal;

  /// The signal's key.
  final String key;

  @override
  String get reason => 'signal';
}

/// The tasks a wait named became terminal.
final class WakeTasks extends WakeReason {
  /// Woken by [ended].
  const WakeTasks(this.ended);

  /// The terminal tasks at the reservation.
  final List<TaskId> ended;

  @override
  String get reason => 'tasks';
}

/// A signal key a task can sleep on.
class SignalKey {
  /// A signal key named [name].
  const SignalKey(this.name);

  /// The key's name.
  final String name;

  /// This key as strict JSON.
  String toJson() => name;

  /// A key decoded from [json].
  static SignalKey fromJson(Object? json) => SignalKey(json! as String);
}

/// Who owns a task: its conversation or another task.
sealed class TaskOwnership {
  const TaskOwnership();
}

/// A task its conversation owns: a top-level task.
final class ConversationTaskOwnership extends TaskOwnership {
  /// Owned by the task's conversation.
  const ConversationTaskOwnership();
}

/// A child task owned by [taskId].
final class ParentTaskOwnership extends TaskOwnership {
  /// Owned by [taskId].
  const ParentTaskOwnership(this.taskId);

  /// The owning task.
  final TaskId taskId;
}

/// Creation options for a durable task.
class TaskOptions {
  /// Task creation options.
  const TaskOptions(
      {required this.ownership,
      this.conversationId,
      this.background,
      this.abandonOnRestart});

  /// Required: a task always names its owner.
  final TaskOwnership ownership;

  /// The owning task's conversation, or the transaction's bound conversation.
  final ConversationId? conversationId;

  /// Conversation-owned tasks only: excluded from ordinary idle waits,
  /// conversation aborts, and cascades.
  final bool? background;

  /// Whether the task is aborted with reason `restart` when scheduling starts
  /// in a later harness.
  final bool? abandonOnRestart;
}

/// Complete durable execution state of one task.
class TaskRecord<I, S, R> {
  /// A task record.
  const TaskRecord({
    required this.id,
    required this.conversationId,
    required this.kind,
    required this.version,
    required this.input,
    required this.state,
    this.owner,
    this.background = false,
    this.abortRequested = false,
    this.abortReason,
    this.abandonOnRestart,
    this.startedAt,
    this.endedAt,
    this.restarts,
    this.memos,
  });

  /// The task's identity.
  final TaskId id;

  /// The conversation the task belongs to.
  final ConversationId conversationId;

  /// Registered task definition name.
  final String kind;

  /// Definition version used to migrate live input and checkpoints.
  final int version;

  /// Original task input retained while the task is live or terminal.
  final I input;

  /// Owning task of a child task; absent for a conversation-owned task.
  final TaskId? owner;

  /// Whether this conversation-owned task is excluded from ordinary idle waits,
  /// conversation aborts, and cascades.
  final bool background;

  /// Durable abort mark checked before run-mode progress is committed.
  final bool abortRequested;

  /// Why the mark was set when not by an abort request: `restart`.
  final String? abortReason;

  /// Set from `TaskOptions.abandonOnRestart`.
  final bool? abandonOnRestart;

  /// Wall-clock milliseconds of the first change to running.
  final int? startedAt;

  /// Wall-clock milliseconds of the change to terminal.
  final int? endedAt;

  /// How many times in a row a crash cut the task off while it ran.
  final int? restarts;

  /// The task's execution state.
  final TaskState<S, R> state;

  /// Small first-writer-wins values retained while the task can run.
  final Map<String, Object?>? memos;

  /// This record as strict JSON; storage persists exactly these fields.
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id.value,
        'conversationId': conversationId.value,
        'kind': kind,
        'version': version,
        'input': copyJson(input),
        if (owner != null) 'owner': owner!.value,
        'background': background,
        'abortRequested': abortRequested,
        if (abortReason != null) 'abortReason': abortReason,
        if (abandonOnRestart != null) 'abandonOnRestart': abandonOnRestart,
        if (startedAt != null) 'startedAt': startedAt,
        if (endedAt != null) 'endedAt': endedAt,
        if (restarts != null) 'restarts': restarts,
        'state': taskStateToJson(state),
        if (memos != null) 'memos': copyJson(memos),
      };

  /// This record with [state] replaced.
  TaskRecord<I, S, R> withState(TaskState<S, R> state) => TaskRecord<I, S, R>(
        id: id,
        conversationId: conversationId,
        kind: kind,
        version: version,
        input: input,
        state: state,
        owner: owner,
        background: background,
        abortRequested: abortRequested,
        abortReason: abortReason,
        abandonOnRestart: abandonOnRestart,
        startedAt: startedAt,
        endedAt: endedAt,
        restarts: restarts,
        memos: state is TaskCompleting<S, R> || state is TaskTerminal<S, R>
            ? null
            : memos,
      );

  /// This record with [kind] replaced.
  TaskRecord<I, S, R> withKind(String kind) => TaskRecord<I, S, R>(
        id: id,
        conversationId: conversationId,
        kind: kind,
        version: version,
        input: input,
        state: state,
        owner: owner,
        background: background,
        abortRequested: abortRequested,
        abortReason: abortReason,
        abandonOnRestart: abandonOnRestart,
        startedAt: startedAt,
        endedAt: endedAt,
        restarts: restarts,
        memos: memos,
      );

  /// This record with [abortRequested] and [abortReason] replaced.
  TaskRecord<I, S, R> withAbort(
          {required bool abortRequested, String? abortReason}) =>
      TaskRecord<I, S, R>(
        id: id,
        conversationId: conversationId,
        kind: kind,
        version: version,
        input: input,
        state: state,
        owner: owner,
        background: background,
        abortRequested: abortRequested,
        abortReason: abortReason,
        abandonOnRestart: abandonOnRestart,
        startedAt: startedAt,
        endedAt: endedAt,
        restarts: restarts,
        memos: memos,
      );
}

// ─── Documents: persisted records ────────────────────────────────────────────

/// Persisted lifecycle record for one create-to-retire document incarnation.
class DocumentRecord {
  /// A document incarnation record.
  const DocumentRecord({
    required this.id,
    required this.kind,
    required this.scope,
    required this.createdAt,
    this.key,
    this.history,
    this.fork,
    this.retiredAt,
  });

  /// Unique incarnation ID; never reused when the same document is recreated.
  final DocumentId id;

  /// Stable document definition kind.
  final String kind;

  /// The scope the incarnation lives in.
  final DocumentScope scope;

  /// Family member key; absent for singleton documents.
  final String? key;

  /// The commit that created the incarnation.
  final Seq createdAt;

  /// The commit that retired the incarnation; absent while it is current.
  final Seq? retiredAt;

  /// `latest` or `rewindable` for conversation documents.
  final String? history;

  /// The fork policy for conversation documents.
  final ForkPolicy? fork;

  /// This record with [retiredAt] set.
  DocumentRecord retired(Seq at) => DocumentRecord(
        id: id,
        kind: kind,
        scope: scope,
        key: key,
        createdAt: createdAt,
        retiredAt: at,
        history: history,
        fork: fork,
      );

  /// Whether the incarnation is live at [at].
  bool isAliveAt(DocumentPoint at) => switch (at) {
        CurrentPoint() => retiredAt == null,
        SeqPoint(:final seq) => createdAt.value <= seq.value &&
            (retiredAt == null || seq.value < retiredAt!.value),
      };

  /// Whether the incarnation keeps only its current content.
  bool get isCurrentOnly => scope is! ConversationScope || history == 'latest';

  /// This record as strict JSON.
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id.value,
        'kind': kind,
        if (key != null) 'key': key,
        'createdAt': createdAt.value,
        if (retiredAt != null) 'retiredAt': retiredAt!.value,
        'scope': _scopeToJson(scope),
        if (history != null) 'history': history,
        if (fork != null) 'fork': fork!.name,
      };

  /// A record decoded from [json].
  static DocumentRecord fromJson(Map<String, Object?> json) => DocumentRecord(
        id: idFromNumber<DocumentKindId>(json['id']! as int),
        kind: json['kind']! as String,
        key: json['key'] as String?,
        scope: _scopeFromJson(json['scope']! as Map<String, Object?>),
        createdAt: seqFromNumber(json['createdAt']! as int),
        retiredAt: json['retiredAt'] == null
            ? null
            : seqFromNumber(json['retiredAt']! as int),
        history: json['history'] as String?,
        fork: json['fork'] == null
            ? null
            : ForkPolicy.values.byName(json['fork']! as String),
      );
}

Map<String, Object?> _scopeToJson(DocumentScope scope) => switch (scope) {
      SessionScope() => <String, Object?>{'kind': 'session'},
      ConversationScope(:final conversationId) => <String, Object?>{
          'kind': 'conversation',
          'conversationId': conversationId.value,
        },
      TaskScope(:final taskId) => <String, Object?>{
          'kind': 'task',
          'taskId': taskId.value
        },
    };

DocumentScope _scopeFromJson(Map<String, Object?> json) =>
    switch (json['kind']) {
      'session' => const SessionScope(),
      'conversation' => ConversationScope(
          idFromNumber<ConversationKind>(json['conversationId']! as int)),
      'task' => TaskScope(idFromNumber<TaskKind>(json['taskId']! as int)),
      final other => throw ArgumentError('Unknown document scope: $other'),
    };

/// Fields supplied when storage creates and stamps a new record.
class DocumentCreate {
  /// A document creation request.
  const DocumentCreate(
      {required this.id,
      required this.kind,
      required this.scope,
      this.key,
      this.history,
      this.fork});

  /// The new incarnation's ID.
  final DocumentId id;

  /// The definition kind.
  final String kind;

  /// The scope the incarnation lives in.
  final DocumentScope scope;

  /// Family member key.
  final String? key;

  /// `latest` or `rewindable` for conversation documents.
  final String? history;

  /// The fork policy for conversation documents.
  final ForkPolicy? fork;

  /// This request as strict JSON.
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id.value,
        'kind': kind,
        if (key != null) 'key': key,
        'scope': _scopeToJson(scope),
        if (history != null) 'history': history,
        if (fork != null) 'fork': fork!.name,
      };

  /// A request decoded from [json].
  static DocumentCreate fromJson(Map<String, Object?> json) => DocumentCreate(
        id: idFromNumber<DocumentKindId>(json['id']! as int),
        kind: json['kind']! as String,
        key: json['key'] as String?,
        scope: _scopeFromJson(json['scope']! as Map<String, Object?>),
        history: json['history'] as String?,
        fork: json['fork'] == null
            ? null
            : ForkPolicy.values.byName(json['fork']! as String),
      );
}

// ─── Documents: content ──────────────────────────────────────────────────────

/// A complete checkpoint or a Chord operation batch.
sealed class DocumentContent {
  const DocumentContent(this.version);

  /// The definition version of the content.
  final int version;
}

/// A complete value.
final class DocumentBase extends DocumentContent {
  /// A base of [version].
  const DocumentBase(super.version, this.value);

  /// The complete value.
  final JsonObject value;
}

/// One Chord operation batch.
final class DocumentDelta extends DocumentContent {
  /// A delta of [version].
  const DocumentDelta(super.version, this.ops);

  /// The operations, applied to the previous value.
  final List<Op> ops;
}

/// A point in a document's history.
sealed class DocumentPoint {
  const DocumentPoint();
}

/// The document's current content.
final class CurrentPoint extends DocumentPoint {
  /// The current-content point.
  const CurrentPoint();
}

/// The one current-content point.
const DocumentPoint currentPoint = CurrentPoint();

/// One historical commit sequence.
final class SeqPoint extends DocumentPoint {
  /// The content as of [seq].
  const SeqPoint(this.seq);

  /// The commit sequence.
  final Seq seq;
}

/// Exact logical identity of a singleton or one keyed family member.
class DocumentAddress {
  /// An address of [kind] in [scope], keyed by [key] for a family member.
  const DocumentAddress({required this.kind, required this.scope, this.key});

  /// The definition kind.
  final String kind;

  /// The scope.
  final DocumentScope scope;

  /// Family member key; absent selects the singleton.
  final String? key;

  /// This address as a stable map key.
  String get keyString => _addressKey(this);
}

String _scopeKey(DocumentScope scope) => switch (scope) {
      SessionScope() => 'session',
      ConversationScope(:final conversationId) =>
        'conversation:${conversationId.value}',
      TaskScope(:final taskId) => 'task:${taskId.value}',
    };

String _addressKey(DocumentAddress address) =>
    '${address.kind}|${_scopeKey(address.scope)}|${address.key == null ? 'singleton' : 'family:${address.key}'}';

/// A stored document record together with the exact persisted source a copy
/// selects.
class DocumentCopySource {
  /// A copy source of [id] at [at].
  const DocumentCopySource({required this.id, required this.at});

  /// The source incarnation.
  final DocumentId id;

  /// The point to copy from.
  final DocumentPoint at;

  /// This source as strict JSON.
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id.value,
        'at': at is SeqPoint ? (at as SeqPoint).seq.value : 'current',
      };

  /// A source decoded from [json].
  static DocumentCopySource fromJson(Map<String, Object?> json) =>
      DocumentCopySource(
        id: idFromNumber<DocumentKindId>(json['id']! as int),
        at: json['at'] == 'current'
            ? currentPoint
            : SeqPoint(seqFromNumber(json['at']! as int)),
      );
}

/// Detached materialized value and stored definition version at a selected
/// point.
class StoredDocument {
  /// A materialized document.
  const StoredDocument({
    required this.record,
    required this.version,
    required this.value,
    required this.deltasSinceBase,
  });

  /// The incarnation record.
  final DocumentRecord record;

  /// The definition version of [value].
  final int version;

  /// The materialized value.
  final JsonObject value;

  /// Deltas replayed after the selected base.
  final int deltasSinceBase;
}

// ─── Storage writes ──────────────────────────────────────────────────────────

/// One record or document mutation in an atomic storage commit.
sealed class StorageWrite {
  const StorageWrite();
}

/// Create or replace one conversation.
final class ConversationWrite extends StorageWrite {
  /// Write [value].
  const ConversationWrite(this.value);

  /// The conversation record.
  final ConversationRecord value;
}

/// Append one immutable entry.
final class EntryWrite extends StorageWrite {
  /// Write [value].
  const EntryWrite(this.value);

  /// The entry record.
  final EntryRecord value;
}

/// Create or replace one task record.
final class TaskWrite extends StorageWrite {
  /// Write [value].
  const TaskWrite(this.value);

  /// The task record.
  final TaskRecord<Object?, Object?, Object?> value;
}

/// Create or replace one submission record.
final class SubmissionWrite extends StorageWrite {
  /// Write [value].
  const SubmissionWrite(this.value);

  /// The submission record.
  final SubmissionRecord value;
}

/// Create one document incarnation with a base content.
final class DocumentCreateWrite extends StorageWrite {
  /// Create [record] with [content].
  const DocumentCreateWrite({required this.record, required this.content});

  /// The new incarnation.
  final DocumentCreate record;

  /// The creation content; always a base.
  final DocumentBase content;
}

/// Create one document incarnation by copying another.
final class DocumentCopyWrite extends StorageWrite {
  /// Copy [source] into [record].
  const DocumentCopyWrite({required this.record, required this.source});

  /// The new incarnation.
  final DocumentCreate record;

  /// The source to copy.
  final DocumentCopySource source;
}

/// Change one document incarnation.
final class DocumentChangeWrite extends StorageWrite {
  /// Change [id] to [content].
  const DocumentChangeWrite({required this.id, required this.content});

  /// The incarnation to change.
  final DocumentId id;

  /// The new content.
  final DocumentContent content;
}

/// Retire one document incarnation.
final class DocumentRetireWrite extends StorageWrite {
  /// Retire [id].
  const DocumentRetireWrite(this.id);

  /// The incarnation to retire.
  final DocumentId id;
}

// ─── Submissions ─────────────────────────────────────────────────────────────

/// Where a settling submission delivers its settlement.
class SubmissionNotify {
  /// Deliver to [taskId] under [key].
  const SubmissionNotify({required this.taskId, required this.key});

  /// The task to notify.
  final TaskId taskId;

  /// The signal key it sleeps on.
  final String key;

  /// This notify target as strict JSON.
  Map<String, Object?> toJson() =>
      <String, Object?>{'taskId': taskId.value, 'key': key};

  /// A target decoded from [json].
  static SubmissionNotify fromJson(Map<String, Object?> json) =>
      SubmissionNotify(
          taskId: idFromNumber<TaskKind>(json['taskId']! as int),
          key: json['key']! as String);
}

/// Durable lifecycle of one admitted input, passive entry write, or continue.
class SubmissionRecord {
  /// A submission record.
  const SubmissionRecord({
    required this.id,
    required this.conversationId,
    required this.type,
    required this.status,
    this.requestId,
    this.entry,
    this.answer,
    this.reason,
    this.detail,
    this.notify,
  });

  /// The submission's identity.
  final SubmissionId id;

  /// The conversation it belongs to.
  final ConversationId conversationId;

  /// `input`, `write`, or `continue`.
  final String type;

  /// `queued`, `placed`, `done`, or `unanswered`.
  final String status;

  /// Host-provided deduplication key, scoped to the conversation.
  final String? requestId;

  /// The transcript entry it placed or was answered by.
  final EntryId? entry;

  /// The entry that answered it.
  final EntryId? answer;

  /// Why an unanswered submission could not settle.
  final String? reason;

  /// Structured diagnostic data for [reason].
  final Object? detail;

  /// Where the settlement is delivered.
  final SubmissionNotify? notify;

  /// This record with [status], [entry], [answer], [reason] and [detail]
  /// replaced.
  SubmissionRecord withStatus({
    required String status,
    EntryId? entry,
    EntryId? answer,
    String? reason,
    Object? detail,
  }) =>
      SubmissionRecord(
        id: id,
        conversationId: conversationId,
        type: type,
        status: status,
        requestId: requestId,
        entry: entry,
        answer: answer,
        reason: reason,
        detail: detail,
        notify: notify,
      );

  /// This record as strict JSON.
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id.value,
        'conversationId': conversationId.value,
        'type': type,
        'status': status,
        if (requestId != null) 'requestId': requestId,
        if (entry != null) 'entry': entry!.value,
        if (answer != null) 'answer': answer!.value,
        if (reason != null) 'reason': reason,
        if (detail != null) 'detail': copyJson(detail),
        if (notify != null) 'notify': notify!.toJson(),
      };

  /// A record decoded from [json].
  static SubmissionRecord fromJson(Map<String, Object?> json) =>
      SubmissionRecord(
        id: idFromNumber<SubmissionKind>(json['id']! as int),
        conversationId:
            idFromNumber<ConversationKind>(json['conversationId']! as int),
        type: json['type']! as String,
        status: json['status']! as String,
        requestId: json['requestId'] as String?,
        entry: json['entry'] == null
            ? null
            : idFromNumber<EntryKind>(json['entry']! as int),
        answer: json['answer'] == null
            ? null
            : idFromNumber<EntryKind>(json['answer']! as int),
        reason: json['reason'] as String?,
        detail: copyJson(json['detail']),
        notify: json['notify'] == null
            ? null
            : SubmissionNotify.fromJson(
                json['notify']! as Map<String, Object?>),
      );
}

// ─── Scans ───────────────────────────────────────────────────────────────────

/// ID order of a scan: `ascending` is oldest first, `descending` newest first.
enum ScanOrder {
  /// Oldest first.
  ascending,

  /// Newest first.
  descending,
}

/// Backend-owned JSON continuation state callers only round-trip.
class Cursor {
  /// A cursor continuing after [after] in [order].
  const Cursor({required this.after, required this.order});

  /// The last ID a previous page returned.
  final int after;

  /// The order that page was read in.
  final ScanOrder order;

  /// This cursor as strict JSON.
  Map<String, Object?> toJson() =>
      <String, Object?>{'after': after, 'order': order.name};

  /// A cursor decoded from [json], a value a caller round-tripped.
  static Cursor fromJson(Map<String, Object?> json) {
    final after = json['after'];
    final order = json['order'];
    if (after is! int) {
      throw ArgumentError('Invalid storage cursor');
    }
    if (order != null && order is! String) {
      throw ArgumentError('Invalid storage cursor');
    }
    return Cursor(
        after: after,
        order: order == null
            ? ScanOrder.ascending
            : ScanOrder.values.byName(order as String));
  }
}

/// One ordered scan result and its optional continuation state.
class Page<T> {
  /// A page of [items] continuing with [next].
  const Page(this.items, {this.next});

  /// The items this page returned.
  final List<T> items;

  /// The continuation, when more items may follow.
  final Cursor? next;
}

/// Optional filters for an ordered conversation scan.
class ConversationQuery {
  /// A conversation scan filter.
  const ConversationQuery(
      {this.ownerConversationId, this.ownerTaskId, this.order});

  /// Only conversations owned by this conversation.
  final ConversationId? ownerConversationId;

  /// Only conversations owned by this task.
  final TaskId? ownerTaskId;

  /// Default `ascending`; with a cursor, the cursor's order.
  final ScanOrder? order;
}

/// Inclusive ID bounds for a scan of one conversation's fork-aware history.
class EntryQuery {
  /// An entry scan filter.
  const EntryQuery(
      {required this.conversationId,
      this.minEntryId,
      this.maxEntryId,
      this.order});

  /// The conversation whose visible history is scanned.
  final ConversationId conversationId;

  /// Oldest entry ID that may be returned.
  final EntryId? minEntryId;

  /// Newest entry ID that may be returned.
  final EntryId? maxEntryId;

  /// Default `descending`; with a cursor, the cursor's order.
  final ScanOrder? order;
}

/// Optional filters for an ordered scan of task records.
class TaskQuery {
  /// A task scan filter.
  const TaskQuery(
      {this.conversationId,
      this.kind,
      this.status,
      this.abortRequested,
      this.background,
      this.order});

  /// Only tasks of this conversation.
  final ConversationId? conversationId;

  /// Only tasks of this kind.
  final String? kind;

  /// Only tasks in this status.
  final String? status;

  /// Only tasks with this abort mark state.
  final bool? abortRequested;

  /// Only tasks with this background flag.
  final bool? background;

  /// Default `ascending`; with a cursor, the cursor's order.
  final ScanOrder? order;
}

/// Optional filters for an ordered scan of submission records.
class SubmissionQuery {
  /// A submission scan filter.
  const SubmissionQuery({this.conversationId, this.status, this.order});

  /// Only submissions of this conversation.
  final ConversationId? conversationId;

  /// Only submissions in this status.
  final String? status;

  /// Default `ascending`; with a cursor, the cursor's order.
  final ScanOrder? order;
}

/// Ordered scan of document incarnations alive in one exact scope at one point.
class DocumentQuery {
  /// A document scan filter.
  const DocumentQuery({required this.scope, required this.at, this.kind});

  /// The scope to scan.
  final DocumentScope scope;

  /// The point each incarnation must be alive at.
  final DocumentPoint at;

  /// Only incarnations of this kind.
  final String? kind;
}

/// A batch outcome: every batch stored, or the first one refused.
sealed class CommitResult {
  const CommitResult(this.stored);

  /// How many batches were stored.
  final int stored;
}

/// Every batch of the call was stored.
final class CommitStored extends CommitResult {
  /// [stored] batches landed.
  const CommitStored(super.stored);
}

/// Batch [stored] was refused; it and every later batch were not stored.
final class CommitRefused extends CommitResult {
  /// Batches before [stored] landed; [refused] names the refusal.
  const CommitRefused(super.stored, this.refused);

  /// The error that refused the batch.
  final Object refused;
}

/// A task state as strict JSON.
Map<String, Object?> taskStateToJson(TaskState<Object?, Object?> state) =>
    switch (state) {
      TaskPending(:final checkpoint, :final wake) => <String, Object?>{
          'status': 'pending',
          'checkpoint': copyJson(checkpoint),
          if (wake != null) 'wake': wakeReasonToJson(wake),
        },
      TaskRunning(:final checkpoint, :final wake) => <String, Object?>{
          'status': 'running',
          'checkpoint': copyJson(checkpoint),
          if (wake != null) 'wake': wakeReasonToJson(wake),
        },
      TaskWaiting(:final checkpoint, :final on, :final policy) =>
        <String, Object?>{
          'status': 'waiting',
          'checkpoint': copyJson(checkpoint),
          'on': <Object?>[for (final id in on) id.value],
          'policy': policy.name,
        },
      TaskSleeping(:final checkpoint, :final until, :final signals) =>
        <String, Object?>{
          'status': 'sleeping',
          'checkpoint': copyJson(checkpoint),
          if (until != null) 'until': until,
          if (signals != null)
            'signals': <Object?>[for (final signal in signals) signal.name],
        },
      TaskCompleting(:final outcome) => <String, Object?>{
          'status': 'completing',
          'outcome': taskOutcomeToJson(outcome),
        },
      TaskTerminal(:final outcome) => <String, Object?>{
          'status': 'terminal',
          'outcome': taskOutcomeToJson(outcome),
        },
    };

/// A task outcome as strict JSON.
Map<String, Object?> taskOutcomeToJson(TaskOutcome<Object?> outcome) =>
    switch (outcome) {
      TaskCompleted(:final result) => <String, Object?>{
          'status': 'completed',
          'result': copyJson(result)
        },
      TaskFailed(:final error, :final result) => <String, Object?>{
          'status': 'failed',
          'error': error.toJson(),
          if (result != null) 'result': copyJson(result),
        },
      TaskAborted(:final reason, :final result) => <String, Object?>{
          'status': 'aborted',
          if (reason != null) 'reason': reason,
          if (result != null) 'result': copyJson(result),
        },
      TaskOrphaned(:final reason) => <String, Object?>{
          'status': 'orphaned',
          'reason': reason
        },
      TaskFaulted(:final error) => <String, Object?>{
          'status': 'faulted',
          'error': error.toJson()
        },
    };

/// A wake reason as strict JSON.
Map<String, Object?> wakeReasonToJson(WakeReason wake) => switch (wake) {
      WakeTime() => <String, Object?>{'reason': 'time'},
      WakeExpired() => <String, Object?>{'reason': 'expired'},
      WakeSignal(:final signal, :final key) => <String, Object?>{
          'reason': 'signal',
          'signal': signal,
          'key': key
        },
      WakeTasks(:final ended) => <String, Object?>{
          'reason': 'tasks',
          'ended': <Object?>[for (final id in ended) id.value],
        },
    };
