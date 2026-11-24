/// Entry kinds and typed documents.
///
/// Port of `packages/durable/src/entries.ts` and `packages/durable/src/documents.ts`
/// at upstream `780bf31fcaeb252fa9b68df3964c735eae75bde3`.
library;

import '../chord/delta.dart';
import '../chord/json.dart';
import 'types.dart';

// ─── Entries ─────────────────────────────────────────────────────────────────

/// Define a typed entry kind.
///
/// Throws an [ArgumentError] for an empty kind, matching upstream's "Entry kind
/// must be a non-empty string".
Entry<D> defineEntry<D extends Object?>(String kind) {
  if (kind.isEmpty) {
    throw ArgumentError('Entry kind must be a non-empty string');
  }
  return Entry<D>(kind);
}

/// A user message entry: `model` carries the user messages.
final Entry<Object?> userEntry = defineEntry<Object?>('pi.user');

/// An assistant message entry: `model` carries the assistant message.
final Entry<Object?> assistantEntry = defineEntry<Object?>('pi.assistant');

/// A system message entry: `model` carries a system message with empty content.
final Entry<Object?> systemEntry = defineEntry<Object?>('pi.system');

/// A tool-result entry: `model` carries the result, `data` the diagnostics.
final Entry<Object?> toolResultEntry = defineEntry<Object?>('pi.tool-result');

/// A reset entry: `model` is absent, or carries a handoff user message.
final Entry<Object?> resetEntry = defineEntry<Object?>('pi.reset');

/// A compaction entry: `model` carries the summary, `data` the reason.
final Entry<Object?> compactionEntry = defineEntry<Object?>('pi.compaction');

/// The built-in entry kinds, in upstream's declaration order.
List<Entry<Object?>> get builtinEntries => <Entry<Object?>>[
      userEntry,
      assistantEntry,
      systemEntry,
      toolResultEntry,
      resetEntry,
      compactionEntry,
    ];

// ─── Documents ───────────────────────────────────────────────────────────────

/// A definition body a caller supplies; [defineDoc] validates it.
class DocSpec<T extends JsonObject> {
  /// A document definition body.
  const DocSpec({
    required this.kind,
    required this.version,
    required this.initial,
    required this.checkpointWhen,
    this.migrate,
  });

  /// Stable persisted kind.
  final String kind;

  /// Positive integer version of the stored value shape.
  final int version;

  /// The value a new document starts from.
  final T Function() initial;

  /// Return true to store a change as a complete base instead of a delta.
  final bool Function(T value, List<Op> ops, CheckpointInfo info)
      checkpointWhen;

  /// Convert a value stored by an older supported version.
  final T? Function(JsonObject value, int fromVersion)? migrate;
}

class _SpecDefinition<T extends JsonObject> extends DocDefinition<T> {
  _SpecDefinition(this.spec, this.semantics);

  final DocSpec<T> spec;

  @override
  final DocumentSemantics semantics;

  @override
  String get kind => spec.kind;

  @override
  int get version => spec.version;

  @override
  T initial() => spec.initial();

  @override
  T? migrate(JsonObject value, int fromVersion) =>
      spec.migrate?.call(value, fromVersion);

  @override
  bool checkpointWhen(T value, List<Op> ops, CheckpointInfo info) =>
      spec.checkpointWhen(value, ops, info);
}

class _SpecFamilyDefinition<T extends JsonObject, I extends Object?>
    extends DocFamilyDefinition<T, I> {
  _SpecFamilyDefinition(this.spec, this.initialForSeed, this.semantics);

  final DocSpec<T> spec;
  final T Function(I seed) initialForSeed;

  @override
  final DocumentSemantics semantics;

  @override
  String get kind => spec.kind;

  @override
  int get version => spec.version;

  @override
  T initial() => spec.initial();

  @override
  T initialFor(I seed) => initialForSeed(seed);

  @override
  T? migrate(JsonObject value, int fromVersion) =>
      spec.migrate?.call(value, fromVersion);

  @override
  bool checkpointWhen(T value, List<Op> ops, CheckpointInfo info) =>
      spec.checkpointWhen(value, ops, info);
}

void _validate(String kind, int version) {
  if (kind.isEmpty) {
    throw ArgumentError('Document kind must be a non-empty string');
  }
  if (version < 1) {
    throw ArgumentError('Document version must be a positive integer');
  }
}

/// Define a session document: current-only, owned by the session.
SessionDocToken<T> defineSessionDoc<T extends JsonObject>(DocSpec<T> spec) {
  _validate(spec.kind, spec.version);
  return SessionDocToken<T>(_SpecDefinition<T>(spec, const SessionSemantics()));
}

/// Define a conversation document that retains only its current value.
ConversationDocToken<T> defineLatestConversationDoc<T extends JsonObject>(
  DocSpec<T> spec, {
  ForkPolicy fork = ForkPolicy.current,
}) {
  _validate(spec.kind, spec.version);
  return ConversationDocToken<T>(
      _SpecDefinition<T>(spec, LatestConversationSemantics(fork)));
}

/// Define a conversation document whose history stays addressable.
ConversationDocToken<T> defineRewindableConversationDoc<T extends JsonObject>(
  DocSpec<T> spec, {
  ForkPolicy fork = ForkPolicy.asOf,
}) {
  _validate(spec.kind, spec.version);
  return ConversationDocToken<T>(
      _SpecDefinition<T>(spec, RewindableConversationSemantics(fork)));
}

/// Define a task document: current-only, retired with its task.
TaskDocToken<T> defineTaskDoc<T extends JsonObject>(DocSpec<T> spec) {
  _validate(spec.kind, spec.version);
  return TaskDocToken<T>(_SpecDefinition<T>(spec, const TaskSemantics()));
}

/// Define a keyed session document family.
SessionDocFamilyToken<T, I>
    defineSessionDocFamily<T extends JsonObject, I extends Object?>(
  DocSpec<T> spec,
  T Function(I seed) initialFor,
) {
  _validate(spec.kind, spec.version);
  return SessionDocFamilyToken<T, I>(
      _SpecFamilyDefinition<T, I>(spec, initialFor, const SessionSemantics()));
}

/// The semantics of a definition, as the storage record persists them.
({String? history, ForkPolicy? fork}) semanticsOf(
        DocumentSemantics semantics) =>
    switch (semantics) {
      SessionSemantics() || TaskSemantics() => (history: null, fork: null),
      LatestConversationSemantics(:final fork) => (
          history: 'latest',
          fork: fork
        ),
      RewindableConversationSemantics(:final fork) => (
          history: 'rewindable',
          fork: fork
        ),
    };
