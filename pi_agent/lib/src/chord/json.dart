/// Strict JSON values, their copy boundary, and the predicate over them.
///
/// Port of `packages/chord/src/json.ts` at upstream
/// `780bf31fcaeb252fa9b68df3964c735eae75bde3`: `JsonValue`, `copyJson`,
/// `isJsonValue`.
library;

import 'dart:convert';

/// A strict JSON value: `null`, `bool`, a finite `int`/`double`, `String`, a
/// `List<JsonValue>`, or a `Map<String, JsonValue>`.
///
/// Dart cannot spell a recursive union, so the type is `Object?` and the
/// predicate below is the boundary check. The alias documents intent.
typedef JsonValue = Object?;

/// A strict JSON object: the root shape of every durable document.
typedef JsonObject = Map<String, Object?>;

/// Copy a value into an alias-free strict JSON tree owned by the caller.
///
/// Throws a [TypeError] when [value] is not strict JSON: a non-finite number,
/// a non-JSON value (such as a function), or a cycle.
Object? copyJson(Object? value, {bool omitUndefinedProperties = false}) =>
    _copy(value, null, omitUndefinedProperties);

Object? _copy(
    Object? value, Set<Object>? ancestors, bool omitUndefinedProperties) {
  if (value == null || value is String || value is bool) return value;
  if (value is num) {
    if (value.isFinite) return value;
    throw TypeError();
  }
  final active = ancestors ?? <Object>{};
  if (active.contains(value)) {
    throw TypeError();
  }
  active.add(value);
  try {
    if (value is List) {
      final result = <Object?>[];
      for (final item in value) {
        result.add(_copy(item, active, omitUndefinedProperties));
      }
      return result;
    }
    if (value is Map) {
      final result = <String, Object?>{};
      for (final entry in value.entries) {
        final key = entry.key;
        if (key is! String) throw TypeError();
        if (entry.value == null && omitUndefinedProperties) continue;
        result[key] = _copy(entry.value, active, omitUndefinedProperties);
      }
      return result;
    }
    throw TypeError();
  } finally {
    active.remove(value);
  }
}

/// Return whether [value] is finite strict JSON with plain objects and no cycles.
bool isJsonValue(Object? value) => _check(value, <Object>{});

bool _check(Object? value, Set<Object> ancestors) {
  if (value == null || value is String || value is bool) return true;
  if (value is num) return value.isFinite;
  if (value is List) {
    if (ancestors.contains(value)) return false;
    ancestors.add(value);
    try {
      for (final item in value) {
        if (!_check(item, ancestors)) return false;
      }
      return true;
    } finally {
      ancestors.remove(value);
    }
  }
  if (value is Map) {
    if (ancestors.contains(value)) return false;
    ancestors.add(value);
    try {
      for (final entry in value.entries) {
        if (entry.key is! String) return false;
        if (!_check(entry.value, ancestors)) return false;
      }
      return true;
    } finally {
      ancestors.remove(value);
    }
  }
  return false;
}

/// Decode a JSON object from [text]; a trust-boundary read.
Map<String, Object?> decodeJsonMap(String text) =>
    (jsonDecode(text) as Map).cast<String, Object?>();

/// Encode [value] as compact JSON text.
String encodeJson(Object? value) => jsonEncode(value);
