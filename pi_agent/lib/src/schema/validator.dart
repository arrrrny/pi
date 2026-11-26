/// A JSON Schema validator for a documented draft-07 subset.
///
/// This is the Dart port of the validation surface of upstream
/// `@earendil-works/pi-schema` (`packages/schema/src/validator.ts` and the
/// checks it compiles). It validates a value against a decoded JSON schema and
/// returns a boolean verdict, matching the upstream `Validator.check` fast path.
///
/// Supported keywords (draft-07): `$ref` (local `#/...` pointers only),
/// `type`, `enum`, `const`, `minimum`, `maximum`, `exclusiveMinimum`,
/// `exclusiveMaximum`, `multipleOf`, `minLength`, `maxLength`, `pattern`,
/// `items`, `additionalItems`, `minItems`, `maxItems`, `uniqueItems`,
/// `contains`, `properties`, `patternProperties`, `additionalProperties`,
/// `required`, `minProperties`, `maxProperties`, `propertyNames`,
/// `dependencies`, `allOf`, `anyOf`, `oneOf`, `not`, `if`/`then`/`else`.
/// Annotation-only keywords (`title`, `description`, `format`, `content*`,
/// `default`, `examples`, `definitions`) are ignored, as in draft-07 where they
/// are non-assertive.
library;

/// Validates decoded JSON values against a draft-07 schema subset.
class SchemaValidator {
  /// Creates a validator over [root] (the schema document, for `$ref`).
  SchemaValidator(this.root);

  /// Marker for a `$ref` pointer that could not be resolved.
  ///
  /// Kept distinct from a resolved value so that a pointer landing on a
  /// boolean schema (`true`/`false`) or on JSON `null` is validated instead of
  /// being mistaken for "no such ref" (which is treated as an empty schema).
  static final Object _unresolvedRef = Object();

  /// The root schema document, used to resolve local `$ref` pointers.
  final Map<String, Object?> root;

  /// Whether [value] is valid against [schema] (a schema object or boolean).
  bool check(Object? schema, Object? value) => _validate(schema, value, root);

  bool _validate(Object? schema, Object? value, Map<String, Object?> doc) {
    // Boolean schemas: `true` accepts everything, `false` rejects everything.
    if (schema is bool) return schema;
    if (schema is! Map<String, Object?>) return true;

    // $ref: local pointer only; other keys alongside $ref are ignored (draft-07).
    final ref = schema['\$ref'];
    if (ref is String) {
      final target = _resolveRef(ref, doc);
      // An unresolvable pointer is tolerated as an empty schema, but a pointer
      // that resolves to a boolean schema must be validated as that schema —
      // notably `$ref: false` must reject every value.
      if (identical(target, _unresolvedRef)) return true;
      return _validate(target, value, doc);
    }

    final type = schema['type'];
    if (type != null && !_checkType(type, value)) return false;

    if (schema.containsKey('enum')) {
      final options = schema['enum'] as List<Object?>;
      if (!options.any((o) => _deepEqual(o, value))) return false;
    }

    if (schema.containsKey('const')) {
      if (!_deepEqual(schema['const'], value)) return false;
    }

    if (value is num) {
      if (!_checkNumber(schema, value)) return false;
    }

    if (value is String) {
      if (!_checkString(schema, value)) return false;
    }

    if (value is List<Object?>) {
      if (!_checkArray(schema, value, doc)) return false;
    }

    if (value is Map<String, Object?>) {
      if (!_checkObject(schema, value, doc)) return false;
    }

    if (!_checkCombinators(schema, value, doc)) return false;

    return true;
  }

  bool _checkType(Object type, Object? value) {
    bool matches(String t) => switch (t) {
          'null' => value == null,
          'boolean' => value is bool,
          'object' => value is Map<String, Object?>,
          'array' => value is List<Object?>,
          'string' => value is String,
          'number' => value is num,
          'integer' =>
            value is int || (value is num && value == value.truncateToDouble()),
          _ => false,
        };
    if (type is String) return matches(type);
    if (type is List<Object?>) {
      return type.any((t) => t is String && matches(t));
    }
    return true;
  }

  bool _checkNumber(Map<String, Object?> schema, num value) {
    final minimum = schema['minimum'];
    if (minimum is num && value < minimum) return false;
    final maximum = schema['maximum'];
    if (maximum is num && value > maximum) return false;
    final exMin = schema['exclusiveMinimum'];
    if (exMin is num && value <= exMin) return false;
    final exMax = schema['exclusiveMaximum'];
    if (exMax is num && value >= exMax) return false;
    final multipleOf = schema['multipleOf'];
    if (multipleOf is num && multipleOf != 0) {
      final quotient = value / multipleOf;
      if (!quotient.isFinite || quotient.isNaN) return false;
      if ((quotient - quotient.roundToDouble()).abs() > 1e-9) return false;
    }
    return true;
  }

  bool _checkString(Map<String, Object?> schema, String value) {
    final minLength = schema['minLength'];
    if (minLength is num && value.runes.length < minLength) return false;
    final maxLength = schema['maxLength'];
    if (maxLength is num && value.runes.length > maxLength) return false;
    final pattern = schema['pattern'];
    if (pattern is String) {
      try {
        if (!RegExp(pattern).hasMatch(value)) return false;
      } on FormatException {
        // An invalid pattern is a malformed schema; treat as non-matching.
        return false;
      }
    }
    return true;
  }

  bool _checkArray(Map<String, Object?> schema, List<Object?> value,
      Map<String, Object?> doc) {
    final minItems = schema['minItems'];
    if (minItems is num && value.length < minItems) return false;
    final maxItems = schema['maxItems'];
    if (maxItems is num && value.length > maxItems) return false;

    final unique = schema['uniqueItems'];
    if (unique == true) {
      for (var i = 0; i < value.length; i++) {
        for (var j = i + 1; j < value.length; j++) {
          if (_deepEqual(value[i], value[j])) return false;
        }
      }
    }

    final contains = schema['contains'];
    if (contains != null) {
      final found = value.any((item) => _validate(contains, item, doc));
      if (!found) return false;
    }

    final items = schema['items'];
    if (items is List<Object?>) {
      for (var i = 0; i < value.length && i < items.length; i++) {
        if (!_validate(items[i], value[i], doc)) return false;
      }
      final additional = schema['additionalItems'];
      if (value.length > items.length) {
        if (additional is bool && !additional) return false;
        for (var i = items.length; i < value.length; i++) {
          if (!_validate(additional, value[i], doc)) return false;
        }
      }
    } else if (items != null) {
      for (final item in value) {
        if (!_validate(items, item, doc)) return false;
      }
    }
    return true;
  }

  bool _checkObject(Map<String, Object?> schema, Map<String, Object?> value,
      Map<String, Object?> doc) {
    final required = schema['required'];
    if (required is List<Object?>) {
      for (final key in required) {
        if (key is String && !value.containsKey(key)) return false;
      }
    }

    final minProps = schema['minProperties'];
    if (minProps is num && value.length < minProps) return false;
    final maxProps = schema['maxProperties'];
    if (maxProps is num && value.length > maxProps) return false;

    final properties = schema['properties'];
    final patternProps = schema['patternProperties'];
    final additional = schema['additionalProperties'];

    for (final entry in value.entries) {
      final key = entry.key;
      final child = entry.value;
      var matched = false;

      if (properties is Map<String, Object?>) {
        final propSchema = properties[key];
        if (properties.containsKey(key)) {
          matched = true;
          if (!_validate(propSchema, child, doc)) return false;
        }
      }

      if (patternProps is Map<String, Object?>) {
        for (final pattern in patternProps.keys) {
          if (RegExp(pattern).hasMatch(key)) {
            matched = true;
            if (!_validate(patternProps[pattern], child, doc)) return false;
          }
        }
      }

      if (!matched) {
        if (additional is bool && !additional) return false;
        if (!_validate(additional, child, doc)) return false;
      }
    }

    final propertyNames = schema['propertyNames'];
    if (propertyNames != null) {
      for (final key in value.keys) {
        if (!_validate(propertyNames, key, doc)) return false;
      }
    }

    final dependencies = schema['dependencies'];
    if (dependencies is Map<String, Object?>) {
      for (final entry in dependencies.entries) {
        if (!value.containsKey(entry.key)) continue;
        final dep = entry.value;
        if (dep is List<Object?>) {
          for (final needed in dep) {
            if (needed is String && !value.containsKey(needed)) return false;
          }
        } else if (dep != null) {
          if (!_validate(dep, value, doc)) return false;
        }
      }
    }

    return true;
  }

  bool _checkCombinators(
      Map<String, Object?> schema, Object? value, Map<String, Object?> doc) {
    final allOf = schema['allOf'];
    if (allOf is List<Object?>) {
      for (final sub in allOf) {
        if (!_validate(sub, value, doc)) return false;
      }
    }

    final anyOf = schema['anyOf'];
    if (anyOf is List<Object?>) {
      final ok = anyOf.any((sub) => _validate(sub, value, doc));
      if (!ok) return false;
    }

    final oneOf = schema['oneOf'];
    if (oneOf is List<Object?>) {
      var count = 0;
      for (final sub in oneOf) {
        if (_validate(sub, value, doc)) count++;
      }
      if (count != 1) return false;
    }

    final notSchema = schema['not'];
    if (notSchema != null && _validate(notSchema, value, doc)) return false;

    final ifSchema = schema['if'];
    if (ifSchema != null) {
      final condition = _validate(ifSchema, value, doc);
      final thenSchema = schema['then'];
      final elseSchema = schema['else'];
      if (condition) {
        if (thenSchema != null && !_validate(thenSchema, value, doc)) {
          return false;
        }
      } else {
        if (elseSchema != null && !_validate(elseSchema, value, doc)) {
          return false;
        }
      }
    }

    return true;
  }

  Object? _resolveRef(String ref, Map<String, Object?> doc) {
    if (!ref.startsWith('#')) return _unresolvedRef;
    final pointer = ref.substring(1);
    if (pointer.isEmpty || pointer == '/') return doc;
    if (!pointer.startsWith('/')) return _unresolvedRef;
    Object? current = doc;
    for (final rawToken in pointer.substring(1).split('/')) {
      final token = rawToken.replaceAll('~1', '/').replaceAll('~0', '~');
      if (current is Map<String, Object?>) {
        if (!current.containsKey(token)) return _unresolvedRef;
        current = current[token];
      } else if (current is List<Object?>) {
        final index = int.tryParse(token);
        if (index == null || index < 0 || index >= current.length) {
          return _unresolvedRef;
        }
        current = current[index];
      } else {
        return _unresolvedRef;
      }
    }
    return current;
  }
}

bool _deepEqual(Object? a, Object? b) {
  if (a == b) return true;
  if (a is num && b is num) return a == b;
  if (a is List<Object?> && b is List<Object?>) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_deepEqual(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map<String, Object?> && b is Map<String, Object?>) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || !_deepEqual(a[key], b[key])) return false;
    }
    return true;
  }
  return false;
}
