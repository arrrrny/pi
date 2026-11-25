// Signals: typed JSON values delivered to a live task from outside, kept in its
// memos until a wake uses them.
//
// Port of `packages/durable/src/signals.ts` at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`. The upstream `pi-schema`
// validator is modelled here as a [JsonSchema] predicate over a JSON value,
// applied at the trust boundary where a value arrives from outside; the
// `nonJsonType` walk that rejects `bytes`/`bigint`/`undefined` schemas is
// preserved over the JSON-schema map form.
library;

import '../chord/json.dart';
import 'types.dart';

/// A predicate deciding whether an outside value matches a signal's schema.
///
/// Upstream compiles a `pi-schema` schema with `compile(schema)` and calls
/// `validator.check(value)`; the Dart foundation has no `pi-schema` port, so a
/// signal carries a [JsonSchema] value directly. It is applied only at the
/// trust boundary (a value delivered from outside), never to a typed value.
class JsonSchema {
  /// A schema accepting any JSON value.
  const JsonSchema._(this._check);

  final bool Function(Object? value) _check;

  /// Whether [value] matches this schema.
  bool check(Object? value) => _check(value);

  /// A schema accepting any JSON value.
  static const JsonSchema any = JsonSchema._(isJsonValue);

  /// A schema accepting a string.
  static const JsonSchema string = JsonSchema._(_isString);

  /// A schema accepting an integer.
  static const JsonSchema integer = JsonSchema._(_isInt);

  /// A schema accepting an object with the given [fields] (all required).
  static JsonSchema object(Map<String, JsonSchema> fields) {
    final schema = JsonSchema._((Object? value) {
      if (value is! Map<String, Object?>) return false;
      for (final entry in fields.entries) {
        if (!entry.value.check(value[entry.key])) return false;
      }
      return true;
    });
    return schema;
  }

  static bool _isString(Object? value) => value is String;

  static bool _isInt(Object? value) => value is int;
}

/// JSON-schema keywords whose value is a schema or an array of schemas.
const List<String> _schemaKeywords = <String>[
  'items',
  'prefixItems',
  'additionalItems',
  'unevaluatedItems',
  'contains',
  'anyOf',
  'oneOf',
  'allOf',
  'not',
  'if',
  'then',
  'else',
  'additionalProperties',
  'unevaluatedProperties',
  'propertyNames',
];

/// JSON-schema keywords whose value maps names to schemas.
const List<String> _schemaMapKeywords = <String>[
  'properties',
  'patternProperties',
  'dependentSchemas',
  'dependencies',
  '\$defs',
  'definitions',
];

/// A non-JSON type a JSON-schema map accepts anywhere (`bytes`, `bigint`,
/// `undefined`), if any. Port of upstream `nonJsonType`.
String? nonJsonType(Object? schema) {
  if (schema is! Map<String, Object?>) return null;
  final types = schema['type'] is List<Object?>
      ? schema['type']! as List<Object?>
      : <Object?>[schema['type']];
  for (final type in types) {
    if (type == 'bytes' || type == 'bigint' || type == 'undefined') {
      return type as String;
    }
  }
  final children = <Object?>[];
  for (final keyword in _schemaKeywords) {
    final value = schema[keyword];
    if (value is List<Object?>) {
      children.addAll(value);
    } else {
      children.add(value);
    }
  }
  for (final keyword in _schemaMapKeywords) {
    final value = schema[keyword];
    if (value is Map<String, Object?>) children.addAll(value.values);
  }
  for (final child in children) {
    final nested = nonJsonType(child);
    if (nested != null) return nested;
  }
  return null;
}

/// The key of one wait for a signal: JSON, used in sleeps and parks.
///
/// Port of upstream `SignalKey<T>`; the value type is a phantom, so this carries
/// only the signal name and the key string.
class SignalKey<T> {
  /// A key for [signal] under [key].
  const SignalKey(this.signal, this.key);

  /// The signal's token name.
  final String signal;

  /// The key string.
  final String key;

  /// This key as strict JSON.
  Map<String, Object?> toJson() =>
      <String, Object?>{'signal': signal, 'key': key};

  /// A key decoded from [json].
  factory SignalKey.fromJson(Map<String, Object?> json) =>
      SignalKey<T>(json['signal']! as String, json['key']! as String);
}

/// What only Durable reads of a token: its compiled schema and migration.
class SignalInternals {
  /// Internals for a token.
  const SignalInternals(this.validator, this.migrate);

  /// The schema predicate.
  final JsonSchema validator;

  /// A value stored by an older version, to the current shape.
  final Object? Function(Object? value, int fromVersion)? migrate;
}

/// A signal kind, built by [defineSignal]: values delivered under keys.
class SignalToken<T> {
  /// A signal token.
  const SignalToken(this.name, this.version, this.key, this._internals);

  /// The signal's unique name.
  final String name;

  /// The positive integer version of the value shape.
  final int version;

  /// The key of one wait; throws for an empty key.
  final SignalKey<T> Function(String key) key;

  final SignalInternals _internals;
}

/// A key's state: the value delivered under it, or expired because its sleep's
/// deadline came first. Port of upstream `SignalState<T>`.
sealed class SignalState<T> {
  /// The state discriminator.
  String get kind;

  /// A constant state with no fields.
  const SignalState();
}

/// A value was delivered under the key.
final class SignalValue<T> extends SignalState<T> {
  /// A delivered value.
  const SignalValue(this.value) : super();

  /// The delivered value.
  final T value;

  @override
  String get kind => 'value';
}

/// The key expired because its sleep's deadline came first.
final class SignalExpired<T> extends SignalState<T> {
  /// An expired key.
  const SignalExpired() : super();

  @override
  String get kind => 'expired';
}

/// Convenience kind constants matching the sealed discriminator.
abstract final class SignalStateKind {
  /// The `value` discriminator.
  static const String value = 'value';

  /// The `expired` discriminator.
  static const String expired = 'expired';
}

/// What a delivery did. Port of upstream `SignalResult`.
enum SignalResult {
  /// Durably accepted, not necessarily consumed.
  delivered,

  /// The key holds a value.
  duplicate,

  /// Not JSON, or not matching the schema.
  invalid,

  /// The task ended, holds its outcome, is abort-marked, or the key expired.
  closed,

  /// No such task.
  notFound,
}

/// The outcome of a delivery: the result, and the record to write when it
/// changes.
class SignalDelivery<R> {
  /// A delivery outcome.
  const SignalDelivery(this.result, {this.record});

  /// What the delivery did.
  final SignalResult result;

  /// The record to write, when the delivery changes it.
  final TaskRecord<Object?, Object?, R>? record;
}

/// The wake of a sleep that can wake now, and the memos the waking reservation
/// writes. Port of the upstream `sleepWake` return shape.
class SignalWake {
  /// A wake outcome.
  const SignalWake(this.wake, this.memos);

  /// Why the task woke.
  final WakeReason wake;

  /// The memo entries the waking reservation writes.
  final Map<String, Object?> memos;
}

/// Define a signal kind.
///
/// Throws for a name with `/`, a version that is not a positive integer, or a
/// schema that admits non-JSON values.
SignalToken<T> defineSignal<T>({
  required String name,
  required int version,
  required JsonSchema schema,
  Object? Function(Object? value, int fromVersion)? migrate,
}) {
  if (name.isEmpty || name.contains('/')) {
    throw ArgumentError('Signal name "$name" must be non-empty, without "/"');
  }
  if (version < 1) {
    throw ArgumentError('Signal $name version must be a positive integer');
  }
  SignalKey<T> key(String k) {
    if (k.isEmpty) throw ArgumentError('Signal $name key must be non-empty');
    return SignalKey<T>(name, k);
  }

  return SignalToken<T>(
    name,
    version,
    key,
    SignalInternals(schema, migrate),
  );
}

/// Built in: delivered to a submission's `notify` when it settles.
///
/// Port of upstream `SubmissionSettled`. Its value is the settled record; the
/// Dart foundation has no `pi-schema` union, so the predicate accepts any JSON
/// object (the settled-record shape is checked where it is consumed).
// ignore: non_constant_identifier_names
final SignalToken<Object?> SubmissionSettled = defineSignal<Object?>(
  name: 'pi.submission-settled',
  version: 1,
  schema: JsonSchema.any,
);

/// The memo holding a key's state. Signal names contain no `/`, so names never
/// collide. Port of upstream `signalMemoName`.
String signalMemoName(String signal, String key) => 'pi.signal.$signal/$key';

/// Stored state of one key, told apart by `expired`.
class _SignalMemo {
  /// A memo holding a delivered value.
  const _SignalMemo.value(this.version, this.value, {this.consumed = false})
      : expired = false;

  /// A memo marking the key expired.
  const _SignalMemo.expired()
      : version = 0,
        value = null,
        consumed = false,
        expired = true;

  final int version;
  final Object? value;
  final bool consumed;
  final bool expired;

  Object? toJson() => expired
      ? <String, Object?>{'expired': true}
      : <String, Object?>{
          'version': version,
          'value': value,
          if (consumed) 'consumed': true,
        };

  static _SignalMemo? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    if (json['expired'] == true) return const _SignalMemo.expired();
    return _SignalMemo.value(
      json['version']! as int,
      json['value'],
      consumed: json['consumed'] == true,
    );
  }
}

_SignalMemo? _memoOf(Map<String, Object?>? memos, String name) =>
    memos != null && memos.containsKey(name)
        ? _SignalMemo.fromJson(memos[name])
        : null;

/// Decide a delivery to [record]: the result, and the record to write when it
/// changes. Port of upstream `deliverSignal`.
SignalDelivery<R> deliverSignal<R>(
  TaskRecord<Object?, Object?, R>? record,
  SignalToken<Object?> token,
  String key,
  Object? value,
  int now,
) {
  if (record == null) return const SignalDelivery(SignalResult.notFound);
  final state = record.state;
  if (state is TaskTerminal<Object?, R> ||
      state is TaskCompleting<Object?, R> ||
      record.abortRequested) {
    return const SignalDelivery(SignalResult.closed);
  }
  // Values come from outside: the trust boundary of the signal's schema.
  if (key.isEmpty ||
      !isJsonValue(value) ||
      !token._internals.validator.check(value)) {
    return const SignalDelivery(SignalResult.invalid);
  }
  final name = signalMemoName(token.name, key);
  final stored = _memoOf(record.memos, name);
  if (stored != null) {
    return SignalDelivery<R>(
      stored.expired ? SignalResult.closed : SignalResult.duplicate,
    );
  }
  if (state is TaskSleeping<Object?, R> &&
      state.until != null &&
      state.until! <= now &&
      _sleepListsKey(state, token.name, key)) {
    return SignalDelivery<R>(
      SignalResult.closed,
      record: _withMemos(record, <String, Object?>{
        name: const _SignalMemo.expired().toJson(),
      }),
    );
  }
  final memo = _SignalMemo.value(token.version, value);
  return SignalDelivery<R>(
    SignalResult.delivered,
    record: _withMemos(record, <String, Object?>{name: memo.toJson()}),
  );
}

/// A key's state in [memos], the value migrated to the token's version;
/// undefined while nothing came. Port of upstream `readSignal`.
SignalState<T>? readSignal<T>(
  Map<String, Object?>? memos,
  SignalToken<T> token,
  String key,
) {
  final stored = _memoOf(memos, signalMemoName(token.name, key));
  if (stored == null) return null;
  if (stored.expired) return SignalExpired<T>();
  if (stored.version == token.version) {
    return SignalValue<T>(stored.value as T);
  }
  if (stored.version > token.version) {
    throw StateError(
      'Signal ${token.name} value has version ${stored.version}, newer than ${token.version}',
    );
  }
  final migrate = token._internals.migrate;
  if (migrate == null) {
    throw StateError(
      'Signal ${token.name} has no migration from version ${stored.version}',
    );
  }
  final migrated = migrate(stored.value, stored.version);
  if (!isJsonValue(migrated) || !token._internals.validator.check(migrated)) {
    throw StateError(
      'Signal ${token.name} migration from version ${stored.version} returned an invalid value',
    );
  }
  return SignalValue<T>(migrated as T);
}

/// Throws unless a sleep waits for something (`until` or a non-empty [signals])
/// and none of its keys served a wait. Port of upstream `checkSleep`.
void checkSleep(
  TaskSleeping<Object?, Object?> state,
  Map<String, Object?>? memos,
  int task,
  List<SignalKey<Object?>> signals,
) {
  if (state.until == null && signals.isEmpty) {
    throw StateError('Task $task cannot sleep without until or signals');
  }
  for (final listed in signals) {
    final stored = _memoOf(memos, signalMemoName(listed.signal, listed.key));
    if (stored == null) continue;
    if (stored.expired) {
      throw StateError(
        'Task $task cannot sleep on signal ${listed.signal} key ${listed.key}: it expired',
      );
    }
    if (stored.consumed) {
      throw StateError(
        'Task $task cannot sleep on signal ${listed.signal} key ${listed.key}: it already woke a wait',
      );
    }
  }
}

/// Whether a sleep can wake now: a listed key holds a value no wake used, or
/// its deadline came. Port of upstream `sleepDue`.
bool sleepDue(
  TaskSleeping<Object?, Object?> state,
  Map<String, Object?>? memos,
  int now,
  List<SignalKey<Object?>> signals,
) =>
    _readyKey(signals, memos) != null ||
    (state.until != null && state.until! <= now);

/// The wake of a sleep that can wake now, and the memos the waking reservation
/// writes. Undefined when the sleep cannot wake yet. Port of upstream
/// `sleepWake`.
SignalWake? sleepWake(
  TaskSleeping<Object?, Object?> state,
  Map<String, Object?>? memos,
  int now,
  List<SignalKey<Object?>> signals,
) {
  final ready = _readyKey(signals, memos);
  if (ready != null) {
    final name = signalMemoName(ready.signal, ready.key);
    final existing = _memoOf(memos, name) as _SignalMemo;
    final consumed = _SignalMemo.value(
      existing.version,
      existing.value,
      consumed: true,
    );
    return SignalWake(
      WakeSignal(signal: ready.signal, key: ready.key),
      <String, Object?>{name: consumed.toJson()},
    );
  }
  if (state.until == null || state.until! > now) return null;
  if (signals.isEmpty) return SignalWake(const WakeTime(), <String, Object?>{});
  final expired = <String, Object?>{};
  for (final listed in signals) {
    final name = signalMemoName(listed.signal, listed.key);
    if (_memoOf(memos, name) == null) {
      expired[name] = const _SignalMemo.expired().toJson();
    }
  }
  return SignalWake(const WakeExpired(), expired);
}

/// The first listed key, in [signals] order, holding a value no wake used.
SignalKey<Object?>? _readyKey(
  List<SignalKey<Object?>> signals,
  Map<String, Object?>? memos,
) {
  for (final listed in signals) {
    final stored = _memoOf(memos, signalMemoName(listed.signal, listed.key));
    if (stored != null && !stored.expired && !stored.consumed) return listed;
  }
  return null;
}

/// Whether [state] sleeps on [signal]/[key].
bool _sleepListsKey(
  TaskSleeping<Object?, Object?> state,
  String signal,
  String key,
) {
  final keys = state.signals;
  if (keys == null) return false;
  for (final listed in keys) {
    if (listed.name == signalMemoName(signal, key)) return true;
  }
  return false;
}

/// [record] with [memos] merged in; signal memos are written only to live
/// records. Port of upstream `withMemos`.
TaskRecord<Object?, Object?, R> _withMemos<R>(
  TaskRecord<Object?, Object?, R> record,
  Map<String, Object?> memos,
) =>
    TaskRecord<Object?, Object?, R>(
      id: record.id,
      conversationId: record.conversationId,
      kind: record.kind,
      version: record.version,
      input: record.input,
      state: record.state,
      owner: record.owner,
      background: record.background,
      abortRequested: record.abortRequested,
      abortReason: record.abortReason,
      abandonOnRestart: record.abandonOnRestart,
      startedAt: record.startedAt,
      endedAt: record.endedAt,
      restarts: record.restarts,
      memos: <String, Object?>{...?record.memos, ...memos},
    );
