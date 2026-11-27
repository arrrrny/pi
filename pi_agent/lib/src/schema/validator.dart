/// A JSON Schema validator for a documented draft-07 subset plus the
/// draft2020-12 keywords ported in pi#53.
///
/// This is the Dart port of the validation surface of upstream
/// `@earendil-works/pi-schema` (`packages/schema/src/validator.ts` and the
/// checks it compiles). It validates a value against a decoded JSON schema and
/// returns a boolean verdict, matching the upstream `Validator.check` fast path.
///
/// Supported keywords (draft-07): `$ref` (local `#/...` pointers and `#anchor`
/// names), `type`, `enum`, `const`, `minimum`, `maximum`, `exclusiveMinimum`,
/// `exclusiveMaximum`, `multipleOf`, `minLength`, `maxLength`, `pattern`,
/// `items`, `additionalItems`, `minItems`, `maxItems`, `uniqueItems`,
/// `contains`, `properties`, `patternProperties`, `additionalProperties`,
/// `required`, `minProperties`, `maxProperties`, `propertyNames`,
/// `dependencies`, `allOf`, `anyOf`, `oneOf`, `not`, `if`/`then`/`else`.
///
/// Added in pi#53 (draft2020-12): `prefixItems`, `dependentRequired`,
/// `dependentSchemas`, `minContains`/`maxContains`, `unevaluatedItems`,
/// `unevaluatedProperties`, `$anchor`, `$dynamicAnchor`, `$dynamicRef`. The
/// annotation-only keywords (`title`, `description`, `format`, `content*`,
/// `default`, `examples`, `definitions`, `$defs`, `$schema`, `vocabulary`) are
/// ignored, as in draft-07 where they are non-assertive.
library;

/// The JSON Schema draft whose `$ref` sibling semantics apply.
enum Draft {
  /// Draft-07: `$ref` ignores every sibling keyword.
  draft7,

  /// Draft 2019-09 / 2020-12: `$ref` is an in-place applicator; siblings apply.
  draft2020,
}

/// The result of validating one instance location: a verdict plus the instance
/// locations this schema object evaluated (used by `unevaluated*`).
class _Outcome {
  const _Outcome(this.valid, this.evaluatedProperties, this.evaluatedItems);

  final bool valid;
  final Set<String> evaluatedProperties;
  final Set<int> evaluatedItems;

  static const empty = _Outcome(true, <String>{}, <int>{});
}

/// Validates decoded JSON values against a schema subset.
class SchemaValidator {
  /// Creates a validator over [root] (the schema document, for `$ref`).
  ///
  /// [draft] selects the `$ref` sibling semantics: [Draft.draft7] ignores
  /// siblings, [Draft.draft2020] honours them.
  SchemaValidator(this.root, {this.draft = Draft.draft7});

  /// Marker for a `$ref` pointer that could not be resolved.
  ///
  /// Kept distinct from a resolved value so that a pointer landing on a
  /// boolean schema (`true`/`false`) or on JSON `null` is validated instead of
  /// being mistaken for "no such ref" (which is treated as an empty schema).
  static final Object _unresolvedRef = Object();

  /// The root schema document, used to resolve local `$ref` pointers.
  final Map<String, Object?> root;

  /// The draft whose `$ref` sibling semantics apply.
  final Draft draft;

  /// Whether [value] is valid against [schema] (a schema object or boolean).
  bool check(Object? schema, Object? value) =>
      _validate(schema, value, root).valid;

  _Outcome _validate(Object? schema, Object? value, Map<String, Object?> doc) {
    // Boolean schemas: `true` accepts everything, `false` rejects everything.
    if (schema is bool) {
      return schema
          ? _Outcome.empty
          : const _Outcome(false, <String>{}, <int>{});
    }
    if (schema is! Map<String, Object?>) return _Outcome.empty;

    var valid = true;
    final props = <String>{};
    final items = <int>{};

    // $ref (and $dynamicRef): an in-place applicator; siblings are honoured
    // (draft2020-12 semantics). An unresolvable pointer is tolerated as an
    // empty schema.
    final ref = schema['\$ref'];
    if (ref is String) {
      final target = _resolveRef(ref, doc);
      if (draft == Draft.draft7) {
        // Draft-07: `$ref` overrides every sibling keyword.
        if (identical(target, _unresolvedRef)) return _Outcome.empty;
        return _validate(target, value, doc);
      }
      if (!identical(target, _unresolvedRef)) {
        final outcome = _validate(target, value, doc);
        valid = valid && outcome.valid;
        props.addAll(outcome.evaluatedProperties);
        items.addAll(outcome.evaluatedItems);
      }
    }
    if (draft == Draft.draft2020) {
      final dynamicRef = schema['\$dynamicRef'];
      if (dynamicRef is String) {
        final target = _resolveDynamicRef(dynamicRef, doc);
        if (!identical(target, _unresolvedRef)) {
          final outcome = _validate(target, value, doc);
          valid = valid && outcome.valid;
          props.addAll(outcome.evaluatedProperties);
          items.addAll(outcome.evaluatedItems);
        }
      }
    }

    final type = schema['type'];
    if (type != null && !_checkType(type, value)) valid = false;

    if (schema.containsKey('enum')) {
      final options = schema['enum'] as List<Object?>;
      if (!options.any((o) => _deepEqual(o, value))) valid = false;
    }

    if (schema.containsKey('const')) {
      if (!_deepEqual(schema['const'], value)) valid = false;
    }

    if (value is num && !_checkNumber(schema, value)) valid = false;
    if (value is String && !_checkString(schema, value)) valid = false;
    if (value is List<Object?>) {
      final outcome = _checkArray(schema, value, doc);
      valid = valid && outcome.valid;
      props.addAll(outcome.evaluatedProperties);
      items.addAll(outcome.evaluatedItems);
    }
    if (value is Map<String, Object?>) {
      final outcome = _checkObject(schema, value, doc);
      valid = valid && outcome.valid;
      props.addAll(outcome.evaluatedProperties);
      items.addAll(outcome.evaluatedItems);
    }

    final combinator = _checkCombinators(schema, value, doc);
    valid = valid && combinator.valid;
    props.addAll(combinator.evaluatedProperties);
    items.addAll(combinator.evaluatedItems);

    // unevaluated* runs last: it sees every annotation the other applicators
    // in THIS schema object produced (but never a cousin's).
    if (value is List<Object?> && schema.containsKey('unevaluatedItems')) {
      final outcome =
          _checkUnevaluatedItems(schema['unevaluatedItems'], value, items, doc);
      valid = valid && outcome.valid;
      items.addAll(outcome.evaluatedItems);
    }
    if (value is Map<String, Object?> &&
        schema.containsKey('unevaluatedProperties')) {
      final outcome = _checkUnevaluatedProperties(
          schema['unevaluatedProperties'], value, props, doc);
      valid = valid && outcome.valid;
      props.addAll(outcome.evaluatedProperties);
    }

    return _Outcome(valid, props, items);
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

  _Outcome _checkArray(Map<String, Object?> schema, List<Object?> value,
      Map<String, Object?> doc) {
    var valid = true;
    final evaluated = <int>{};

    final minItems = schema['minItems'];
    if (minItems is num && value.length < minItems) valid = false;
    final maxItems = schema['maxItems'];
    if (maxItems is num && value.length > maxItems) valid = false;

    final unique = schema['uniqueItems'];
    if (unique == true) {
      for (var i = 0; i < value.length; i++) {
        for (var j = i + 1; j < value.length; j++) {
          if (_deepEqual(value[i], value[j])) valid = false;
        }
      }
    }

    // prefixItems (draft2020-12 tuple form): positional, indices < length.
    final prefixItems = schema['prefixItems'];
    if (prefixItems is List<Object?>) {
      for (var i = 0; i < value.length && i < prefixItems.length; i++) {
        final outcome = _validate(prefixItems[i], value[i], doc);
        valid = valid && outcome.valid;
        if (outcome.valid) evaluated.add(i);
      }
    }

    final contains = schema['contains'];
    if (contains != null) {
      final matched = <int>[];
      for (var i = 0; i < value.length; i++) {
        if (_validate(contains, value[i], doc).valid) matched.add(i);
      }
      final minContains = schema['minContains'];
      final maxContains = schema['maxContains'];
      final min = minContains is num ? minContains : 1;
      final max = maxContains is num ? maxContains : double.infinity;
      if (matched.length < min || matched.length > max) valid = false;
      // `contains` marks the matched items as evaluated (unevaluatedItems).
      evaluated.addAll(matched);
    }

    final items = schema['items'];
    if (items is List<Object?>) {
      // draft-07 tuple form: positional items + additionalItems for the rest.
      for (var i = 0; i < value.length && i < items.length; i++) {
        final outcome = _validate(items[i], value[i], doc);
        valid = valid && outcome.valid;
        if (outcome.valid) evaluated.add(i);
      }
      if (value.length > items.length) {
        final additional = schema['additionalItems'];
        if (additional is bool && !additional) {
          valid = false;
        } else {
          for (var i = items.length; i < value.length; i++) {
            final outcome = _validate(additional, value[i], doc);
            valid = valid && outcome.valid;
            if (outcome.valid) evaluated.add(i);
          }
        }
      }
    } else if (items != null) {
      // draft2020-12: `items` applies to indices past prefixItems.
      final start = prefixItems is List<Object?> ? prefixItems.length : 0;
      for (var i = start; i < value.length; i++) {
        final outcome = _validate(items, value[i], doc);
        if (items is bool && !items) {
          valid = false;
        } else {
          valid = valid && outcome.valid;
          if (outcome.valid) evaluated.add(i);
        }
      }
    }

    return _Outcome(valid, <String>{}, evaluated);
  }

  _Outcome _checkObject(Map<String, Object?> schema, Map<String, Object?> value,
      Map<String, Object?> doc) {
    var valid = true;
    final evaluated = <String>{};

    final required = schema['required'];
    if (required is List<Object?>) {
      for (final key in required) {
        if (key is String && !value.containsKey(key)) valid = false;
      }
    }

    final minProps = schema['minProperties'];
    if (minProps is num && value.length < minProps) valid = false;
    final maxProps = schema['maxProperties'];
    if (maxProps is num && value.length > maxProps) valid = false;

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
          final outcome = _validate(propSchema, child, doc);
          valid = valid && outcome.valid;
          if (outcome.valid) evaluated.add(key);
        }
      }

      if (patternProps is Map<String, Object?>) {
        for (final pattern in patternProps.keys) {
          if (RegExp(pattern).hasMatch(key)) {
            matched = true;
            final outcome = _validate(patternProps[pattern], child, doc);
            valid = valid && outcome.valid;
            if (outcome.valid) evaluated.add(key);
          }
        }
      }

      if (!matched && additional != null) {
        if (additional is bool && !additional) {
          valid = false;
        } else {
          final outcome = _validate(additional, child, doc);
          valid = valid && outcome.valid;
          if (outcome.valid) evaluated.add(key);
        }
      }
    }

    final propertyNames = schema['propertyNames'];
    if (propertyNames != null) {
      for (final key in value.keys) {
        if (!_validate(propertyNames, key, doc).valid) valid = false;
      }
    }

    // draft-07 `dependencies`: array form (property deps) or schema form.
    final dependencies = schema['dependencies'];
    if (dependencies is Map<String, Object?>) {
      for (final entry in dependencies.entries) {
        if (!value.containsKey(entry.key)) continue;
        final dep = entry.value;
        if (dep is List<Object?>) {
          for (final needed in dep) {
            if (needed is String && !value.containsKey(needed)) valid = false;
          }
        } else if (dep != null) {
          final outcome = _validate(dep, value, doc);
          valid = valid && outcome.valid;
          evaluated.addAll(outcome.evaluatedProperties);
        }
      }
    }

    // dependentRequired (draft2019-09/2020-12): property presence deps.
    final dependentRequired = schema['dependentRequired'];
    if (dependentRequired is Map<String, Object?>) {
      for (final entry in dependentRequired.entries) {
        if (!value.containsKey(entry.key)) continue;
        final needed = entry.value;
        if (needed is List<Object?>) {
          for (final name in needed) {
            if (name is String && !value.containsKey(name)) valid = false;
          }
        }
      }
    }

    // dependentSchemas (draft2019-09/2020-12): schema deps over the whole object.
    final dependentSchemas = schema['dependentSchemas'];
    if (dependentSchemas is Map<String, Object?>) {
      for (final entry in dependentSchemas.entries) {
        if (!value.containsKey(entry.key)) continue;
        final outcome = _validate(entry.value, value, doc);
        valid = valid && outcome.valid;
        evaluated.addAll(outcome.evaluatedProperties);
      }
    }

    return _Outcome(valid, evaluated, <int>{});
  }

  _Outcome _checkCombinators(
      Map<String, Object?> schema, Object? value, Map<String, Object?> doc) {
    var valid = true;
    final props = <String>{};
    final items = <int>{};

    final allOf = schema['allOf'];
    if (allOf is List<Object?>) {
      for (final sub in allOf) {
        final outcome = _validate(sub, value, doc);
        valid = valid && outcome.valid;
        props.addAll(outcome.evaluatedProperties);
        items.addAll(outcome.evaluatedItems);
      }
    }

    final anyOf = schema['anyOf'];
    if (anyOf is List<Object?>) {
      final outcomes = anyOf.map((sub) => _validate(sub, value, doc)).toList();
      final anyValid = outcomes.any((o) => o.valid);
      if (!anyValid) {
        valid = false;
      } else {
        for (final o in outcomes) {
          if (o.valid) {
            props.addAll(o.evaluatedProperties);
            items.addAll(o.evaluatedItems);
          }
        }
      }
    }

    final oneOf = schema['oneOf'];
    if (oneOf is List<Object?>) {
      final outcomes = oneOf.map((sub) => _validate(sub, value, doc)).toList();
      final validOnes = outcomes.where((o) => o.valid).toList();
      if (validOnes.length != 1) {
        valid = false;
      } else {
        props.addAll(validOnes.first.evaluatedProperties);
        items.addAll(validOnes.first.evaluatedItems);
      }
    }

    final notSchema = schema['not'];
    if (notSchema != null && _validate(notSchema, value, doc).valid) {
      valid = false;
    }

    final ifSchema = schema['if'];
    if (ifSchema != null) {
      final condition = _validate(ifSchema, value, doc);
      if (condition.valid) {
        // Annotations from `if` are kept whether or not `then` is present.
        props.addAll(condition.evaluatedProperties);
        items.addAll(condition.evaluatedItems);
        final thenSchema = schema['then'];
        if (thenSchema != null) {
          final outcome = _validate(thenSchema, value, doc);
          valid = valid && outcome.valid;
          props.addAll(outcome.evaluatedProperties);
          items.addAll(outcome.evaluatedItems);
        }
      } else {
        final elseSchema = schema['else'];
        if (elseSchema != null) {
          final outcome = _validate(elseSchema, value, doc);
          valid = valid && outcome.valid;
          props.addAll(outcome.evaluatedProperties);
          items.addAll(outcome.evaluatedItems);
        }
      }
    }

    return _Outcome(valid, props, items);
  }

  _Outcome _checkUnevaluatedItems(Object? unevaluated, List<Object?> value,
      Set<int> evaluated, Map<String, Object?> doc) {
    var valid = true;
    final newlyEvaluated = <int>{};
    for (var i = 0; i < value.length; i++) {
      if (evaluated.contains(i)) continue;
      final outcome = _validate(unevaluated, value[i], doc);
      if (unevaluated is bool && !unevaluated) {
        valid = false;
      } else {
        valid = valid && outcome.valid;
        if (outcome.valid) newlyEvaluated.add(i);
      }
    }
    return _Outcome(valid, <String>{}, newlyEvaluated);
  }

  _Outcome _checkUnevaluatedProperties(
      Object? unevaluated,
      Map<String, Object?> value,
      Set<String> evaluated,
      Map<String, Object?> doc) {
    var valid = true;
    final newlyEvaluated = <String>{};
    for (final entry in value.entries) {
      if (evaluated.contains(entry.key)) continue;
      final outcome = _validate(unevaluated, entry.value, doc);
      if (unevaluated is bool && !unevaluated) {
        valid = false;
      } else {
        valid = valid && outcome.valid;
        if (outcome.valid) newlyEvaluated.add(entry.key);
      }
    }
    return _Outcome(valid, newlyEvaluated, <int>{});
  }

  Object? _resolveRef(String ref, Map<String, Object?> doc) {
    if (!ref.startsWith('#')) return _unresolvedRef;
    final pointer = ref.substring(1);
    if (pointer.isEmpty) return doc;
    if (pointer.startsWith('/')) return _resolvePointer(pointer, doc);
    // A plain-name fragment is an `$anchor` lookup.
    return _resolveAnchor(pointer, doc);
  }

  Object? _resolveDynamicRef(String ref, Map<String, Object?> doc) {
    if (!ref.startsWith('#')) return _unresolvedRef;
    final pointer = ref.substring(1);
    if (pointer.isEmpty) return doc;
    if (pointer.startsWith('/')) return _resolvePointer(pointer, doc);
    return _resolveDynamicAnchor(pointer, doc);
  }

  Object? _resolvePointer(String pointer, Map<String, Object?> doc) {
    if (pointer == '/') return doc;
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

  /// Resolves a plain `$anchor` name fragment to the schema object carrying it.
  ///
  /// `$anchor` names are unique per schema resource, so the first static match
  /// is exact.
  Object? _resolveAnchor(String name, Map<String, Object?> doc) {
    final found = _findAnchor(doc, '\$anchor', name);
    return found ?? _unresolvedRef;
  }

  /// Resolves a `$dynamicRef` name fragment to its `$dynamicAnchor` target.
  ///
  /// Known divergence from JSON Schema 2020-12 dynamic scope (pi#94 review):
  /// a conforming implementation walks the referencing chain and rebinds to the
  /// OUTERMOST in-scope schema carrying the same `$dynamicAnchor` name. This
  /// port threads only the root document and has no scope chain, so it resolves
  /// statically. That is exact for the non-shadowed case — exactly one
  /// `$dynamicAnchor` of this name in the document, which is the recursive /
  /// extended-schema case `$dynamicRef` exists for. When the name is SHADOWED
  /// (defined in more than one in-scope schema) a static first-match could bind
  /// the wrong schema and silently mis-validate, so the shadowed case is gated
  /// to unresolved (the `$dynamicRef` applies no constraint) rather than
  /// guessed. `anchor_dynamicref_test.dart` exercises the non-shadowed path.
  Object? _resolveDynamicAnchor(String name, Map<String, Object?> doc) {
    final matches = _findAnchors(doc, '\$dynamicAnchor', name);
    if (matches.length != 1) return _unresolvedRef;
    return matches.single;
  }

  Object? _findAnchor(Object? node, String key, String name) {
    if (node is Map<String, Object?>) {
      if (node[key] == name) return node;
      for (final child in node.values) {
        final found = _findAnchor(child, key, name);
        if (found != null) return found;
      }
    } else if (node is List<Object?>) {
      for (final child in node) {
        final found = _findAnchor(child, key, name);
        if (found != null) return found;
      }
    }
    return null;
  }

  /// Collects every node whose [key] equals [name], in document order.
  List<Object?> _findAnchors(Object? node, String key, String name) {
    final found = <Object?>[];
    _collectAnchors(node, key, name, found);
    return found;
  }

  void _collectAnchors(
      Object? node, String key, String name, List<Object?> found) {
    if (node is Map<String, Object?>) {
      if (node[key] == name) found.add(node);
      for (final child in node.values) {
        _collectAnchors(child, key, name, found);
      }
    } else if (node is List<Object?>) {
      for (final child in node) {
        _collectAnchors(child, key, name, found);
      }
    }
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
