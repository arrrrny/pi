/// Tool definitions, parameter coercion, and validation.
library;

import 'dart:async';
import 'dart:convert';

import 'types.dart';

/// A tool definition for the agent.
///
/// Tools define functions the LLM can call during conversation.
/// Each tool has a JSON Schema for its parameters, an execute function,
/// and optional hooks for argument preparation and execution mode override.
class AgentTool<TParameters, TDetails> {
  /// Tool name (used by the LLM to reference this tool).
  final String name;

  /// Tool description (shown to the LLM).
  final String description;

  /// JSON Schema describing the tool's parameters.
  final Map<String, dynamic> parameters;

  /// Display label for UI rendering.
  final String label;

  /// Optional argument pre-processing function.
  final Map<String, dynamic>? Function(Map<String, dynamic> args)?
      prepareArguments;

  /// Tool execution function.
  final Future<AgentToolResult<TDetails>> Function(
    String toolCallId,
    Map<String, dynamic> params, {
    void Function(TDetails)? onUpdate,
    bool Function()? isAborted,
  }) execute;

  /// Per-tool execution mode override.
  final ToolExecutionMode? executionMode;

  /// Creates an agent tool.
  const AgentTool({
    required this.name,
    required this.description,
    required this.parameters,
    this.label = '',
    required this.execute,
    this.prepareArguments,
    this.executionMode,
  });

  /// Converts to the tool definition format expected by LLM APIs.
  Map<String, dynamic> toApiFormat() => {
        'type': 'function',
        'function': {
          'name': name,
          'description': description,
          'parameters': parameters,
        },
      };
}

/// Validates parameters against a JSON Schema.
///
/// Returns null if valid, or a list of error messages if invalid.
/// Supports: type, properties, required, enum, items.
List<String>? validateParameters(
  Map<String, dynamic> schema,
  Map<String, dynamic> values,
) {
  final errors = <String>[];

  _validateObject(schema, values, '', errors);

  return errors.isEmpty ? null : errors;
}

/// Coerces [values] to the types [schema] declares, then validates them.
///
/// Coerces a tool call's arguments against [schema], then validates them.
///
/// Mirrors upstream `validateToolArguments`
/// (`packages/ai/src/utils/validation.ts`): models often send `"42"` for a
/// number, a single value for an array, or `null` for an omitted optional
/// property, so coercion runs first and only then the schema check.
///
/// Returns an [ArgumentValidation] carrying either the coerced arguments or the
/// formatted error message, in upstream's `Validation failed for tool ...`
/// shape. The input map is never modified: an unchanged value comes back as the
/// same reference, and a changed one is a copy along the changed paths, so the
/// recorded tool call in the transcript keeps the model's raw arguments.
ArgumentValidation validateToolArguments(
  String toolName,
  Map<String, dynamic> schema,
  Map<String, dynamic> arguments,
) {
  final coerced = coerceArguments(schema, arguments);
  final errors = validateParameters(schema, coerced);
  if (errors == null) return ArgumentValidation.ok(coerced);

  final formatted = errors.map((error) => '  - $error').join('\n');
  return ArgumentValidation.error(
    'Validation failed for tool "$toolName":\n$formatted\n\n'
    'Received arguments:\n${_prettyJson(coerced)}',
  );
}

/// The outcome of [validateToolArguments]: coerced arguments, or an error.
class ArgumentValidation {
  /// The coerced, schema-valid arguments, or null when [error] is set.
  final Map<String, dynamic>? args;

  /// The formatted validation error, or null when the call is valid.
  final String? error;

  /// A valid call, carrying its coerced arguments.
  const ArgumentValidation.ok(Map<String, dynamic> this.args) : error = null;

  /// An invalid call, carrying the formatted message.
  const ArgumentValidation.error(String this.error) : args = null;
}

/// Coerces [values] to the types [schema] declares.
///
/// Three passes, matching pi-schema's `coerce: true` (`packages/schema/src/
/// coerce.ts`): (1) drop a `null` in an optional property whose schema rejects
/// null, as if it were omitted; (2) TypeBox's conversion rules — `"3.5"` to a
/// number, `"true"` to a boolean, a single value to a one-item array, a member
/// of an `enum`/`const` taken from a value of another type that converts to
/// exactly it; (3) primitive coercion by `type`, as in Ajv's `coerceTypes`.
///
/// Copy-on-write: the input is never modified, and a value nothing changed
/// comes back as the same reference.
Map<String, dynamic> coerceArguments(
  Map<String, dynamic> schema,
  Map<String, dynamic> values,
) {
  final withoutNulls = _dropOptionalNulls(schema, values);
  final converted = _convertValue(schema, withoutNulls);
  if (converted is! Map<String, dynamic>) return values;
  return _coerceTypes(schema, converted) as Map<String, dynamic>;
}

/// A single value coerced for [schema], as a tool argument would be.
///
/// Exposed for tests; the agent loop works through [coerceArguments].
Object? coerceValue(Map<String, dynamic> schema, Object? value) {
  final withoutNulls = _dropOptionalNullsForValue(schema, value);
  return _coerceTypes(schema, _convertValue(schema, withoutNulls));
}

// --- Pass 1: optional nulls ---

Object? _dropOptionalNullsForValue(Map<String, dynamic> schema, Object? value) {
  if (value is Map<String, dynamic>) return _dropOptionalNulls(schema, value);
  if (value is List) {
    final items = schema['items'];
    if (items is! Map<String, dynamic>) return value;
    return _mapItems(
        value, (item, _) => _dropOptionalNullsForValue(items, item));
  }
  return value;
}

Map<String, dynamic> _dropOptionalNulls(
  Map<String, dynamic> schema,
  Map<String, dynamic> values,
) {
  final properties = schema['properties'];
  if (properties is! Map<String, dynamic>) return values;

  final required = <Object?>{
    ...?(schema['required'] is List ? schema['required'] as List : null),
  };

  Map<String, dynamic>? out;
  void remove(String key) {
    out ??= Map<String, dynamic>.of(values);
    out!.remove(key);
  }

  for (final entry in properties.entries) {
    final key = entry.key;
    final property = entry.value;
    if (!values.containsKey(key)) continue;
    if (property is! Map<String, dynamic> && property is! bool) continue;
    final isRef =
        property is Map<String, dynamic> && property.containsKey(r'$ref');
    if (values[key] == null && !required.contains(key) && !isRef) {
      final propertySchema =
          property is Map<String, dynamic> ? property : <String, dynamic>{};
      if (!_checkValue(propertySchema, null)) {
        remove(key);
        continue;
      }
    }
    final next = _dropOptionalNullsForValue(
        property is Map<String, dynamic> ? property : const {}, values[key]);
    if (!identical(next, values[key])) {
      out ??= Map<String, dynamic>.of(values);
      out![key] = next;
    }
  }
  return out ?? values;
}

/// Whether [value] satisfies [schema] for a single value; true when it does.
bool _checkValue(Map<String, dynamic> schema, Object? value) {
  final errors = <String>[];
  _validateValue(schema, value, '', errors);
  return errors.isEmpty;
}

// --- Pass 2: TypeBox conversions ---

Object? _convertValue(Map<String, dynamic> schema, Object? value) {
  if (schema.containsKey('const')) {
    return _convertLiteral(schema['const'], value);
  }

  final enumValues = schema['enum'];
  if (enumValues is List) {
    if (enumValues.contains(value)) return value;
    for (final member in enumValues) {
      final candidate = _convertLiteral(member, value);
      if (!identical(candidate, value) && _checkValue(schema, candidate)) {
        return candidate;
      }
    }
    return value;
  }

  final anyOf = schema['anyOf'];
  if (anyOf is List) return _convertUnion(schema, anyOf, value);
  final oneOf = schema['oneOf'];
  if (oneOf is List) return _convertUnion(schema, oneOf, value);

  final allOf = schema['allOf'];
  if (allOf is List) {
    var next = value;
    for (final member in allOf) {
      if (member is Map<String, dynamic>) next = _convertValue(member, next);
    }
    return _convertMembers(schema, next);
  }

  switch (schema['type']) {
    case 'string':
      return _orValue(_tryString(value), value);
    case 'number':
      return _orValue(_tryNumber(value), value);
    case 'integer':
      final result = _tryNumber(value);
      return result == null ? value : result.value.truncate();
    case 'boolean':
      return _orValue(_tryBoolean(value), value);
    case 'null':
      return _orValue(_tryNull(value), value);
    case 'array':
      return _convertArray(schema, value);
    case 'object':
      return _convertObject(schema, value);
    case null:
      if (schema.containsKey('properties') ||
          schema.containsKey('patternProperties')) {
        return _convertObject(schema, value);
      }
      if (schema.containsKey('items') || schema.containsKey('prefixItems')) {
        return _convertArray(schema, value);
      }
      return value;
    default:
      return value;
  }
}

Object? _convertLiteral(Object? literal, Object? value) {
  if (identical(literal, value) || literal == value) return value;
  Object? result;
  if (literal is String) {
    result = _tryString(value)?.value;
  } else if (literal is num) {
    result = _tryNumber(value)?.value;
  } else if (literal is bool) {
    result = _tryBoolean(value)?.value;
  }
  return result != null && result == literal ? result : value;
}

Object? _convertUnion(
    Map<String, dynamic> schema, List<dynamic> branches, Object? value) {
  for (final branch in branches) {
    if (branch is Map<String, dynamic> && _checkValue(branch, value)) {
      return _convertMembers(schema, value);
    }
  }
  for (final branch in branches) {
    if (branch is! Map<String, dynamic>) continue;
    final candidate = _convertMembers(schema, _convertValue(branch, value));
    if (_checkValue(schema, candidate)) return candidate;
  }
  return _convertMembers(schema, value);
}

Object? _convertMembers(Map<String, dynamic> schema, Object? value) {
  final declares = schema.containsKey('properties') ||
      schema.containsKey('patternProperties') ||
      schema.containsKey('additionalProperties');
  return declares ? _convertObject(schema, value) : value;
}

Object? _convertArray(Map<String, dynamic> schema, Object? value) {
  final prefixItems = schema['prefixItems'];
  final itemsArray = schema['items'];
  final prefix = itemsArray is List
      ? itemsArray
      : prefixItems is List
          ? prefixItems
          : null;

  if (prefix != null) {
    // A tuple converts its items and never wraps a single value.
    if (value is! List) return value;
    final rest = itemsArray is List ? null : itemsArray;
    final converted = <Object?>[];
    var changed = false;
    for (var i = 0; i < value.length; i++) {
      final itemSchema = i < prefix.length ? prefix[i] : rest;
      final item = itemSchema is Map<String, dynamic>
          ? _convertValue(itemSchema, value[i])
          : value[i];
      if (!identical(item, value[i])) changed = true;
      converted.add(item);
    }
    return changed ? converted : value;
  }

  if (value is List) {
    if (itemsArray is! Map<String, dynamic>) return value;
    return _mapItems(value, (item, _) => _convertValue(itemsArray, item));
  }
  return [
    if (itemsArray is Map<String, dynamic>)
      _convertValue(itemsArray, value)
    else
      value
  ];
}

Object? _convertObject(Map<String, dynamic> schema, Object? value) {
  if (value is! Map<String, dynamic>) return value;
  final properties = schema['properties'];
  final propertySchemas = properties is Map<String, dynamic>
      ? properties
      : const <String, dynamic>{};

  Map<String, dynamic>? out;
  for (final key in value.keys.toList()) {
    var next = value[key];
    if (next == null) continue;
    final propertySchema = propertySchemas[key];
    if (propertySchema is Map<String, dynamic>) {
      next = _convertValue(propertySchema, next);
    }
    if (!identical(next, value[key])) {
      out ??= Map<String, dynamic>.of(value);
      out[key] = next;
    }
  }
  return out ?? value;
}

// --- Pass 3: primitive coercion by type ---

Object? _coerceTypes(Map<String, dynamic> schema, Object? value) {
  var next = value;

  final allOf = schema['allOf'];
  if (allOf is List) {
    for (final member in allOf) {
      if (member is Map<String, dynamic>) next = _coerceTypes(member, next);
    }
  }
  final anyOf = schema['anyOf'];
  if (anyOf is List) next = _coerceUnion(schema, anyOf, next);
  final oneOf = schema['oneOf'];
  if (oneOf is List) next = _coerceUnion(schema, oneOf, next);

  final types = _typesOf(schema);
  final matchesUnionMember =
      types.length > 1 && types.any((type) => _matchesType(type, next));
  if (types.isNotEmpty && !matchesUnionMember) {
    for (final type in types) {
      final candidate = _coercePrimitive(next, type);
      if (!identical(candidate, next)) {
        next = candidate;
        break;
      }
    }
  }

  if (types.contains('object') && next is Map<String, dynamic>) {
    next = _coerceProperties(schema, next);
  }
  if (types.contains('array') && next is List) {
    next = _coerceItems(schema, next);
  }
  return next;
}

Object? _coerceUnion(
    Map<String, dynamic> schema, List<dynamic> branches, Object? value) {
  for (final branch in branches) {
    if (branch is Map<String, dynamic> && _checkValue(branch, value)) {
      return value;
    }
  }
  for (final branch in branches) {
    if (branch is! Map<String, dynamic>) continue;
    final coerced = _coerceTypes(branch, value);
    if (_checkValue(branch, coerced)) return coerced;
  }
  return value;
}

Object? _coerceProperties(
    Map<String, dynamic> schema, Map<String, dynamic> value) {
  final properties = schema['properties'];
  if (properties is! Map<String, dynamic>) return value;

  Map<String, dynamic>? out;
  for (final entry in properties.entries) {
    final key = entry.key;
    if (!value.containsKey(key)) continue;
    final propertySchema = entry.value;
    if (propertySchema is! Map<String, dynamic>) continue;
    final next = _coerceTypes(propertySchema, value[key]);
    if (!identical(next, value[key])) {
      out ??= Map<String, dynamic>.of(value);
      out[key] = next;
    }
  }
  return out ?? value;
}

Object? _coerceItems(Map<String, dynamic> schema, List<dynamic> value) {
  return _mapItems(value, (item, index) {
    final itemSchema = _itemSchemaAt(schema, index);
    return itemSchema is Map<String, dynamic>
        ? _coerceTypes(itemSchema, item)
        : item;
  });
}

Map<String, dynamic>? _itemSchemaAt(Map<String, dynamic> schema, int index) {
  final items = schema['items'];
  if (items is List) {
    final item = index < items.length ? items[index] : null;
    return item is Map<String, dynamic> ? item : null;
  }
  final prefixItems = schema['prefixItems'];
  if (prefixItems is List && index < prefixItems.length) {
    final item = prefixItems[index];
    return item is Map<String, dynamic> ? item : null;
  }
  return items is Map<String, dynamic> ? items : null;
}

List<String> _typesOf(Map<String, dynamic> schema) {
  final type = schema['type'];
  if (type is String) return [type];
  if (type is List) return type.whereType<String>().toList();
  return const [];
}

bool _matchesType(String type, Object? value) => switch (type) {
      'string' => value is String,
      'number' => value is num,
      'integer' => value is int,
      'boolean' => value is bool,
      'array' => value is List,
      'object' => value is Map,
      'null' => value == null,
      _ => true,
    };

Object? _coercePrimitive(Object? value, String type) => switch (type) {
      'number' || 'integer' => _coerceNumberPrimitive(value, type),
      'boolean' => _coerceBooleanPrimitive(value),
      'string' => _coerceStringPrimitive(value),
      'null' => value == '' || value == 0 || value == false ? null : value,
      _ => value,
    };

Object? _coerceNumberPrimitive(Object? value, String type) {
  if (value == null) return 0;
  if (value is String && value.trim().isNotEmpty) {
    final parsed = _tryNumber(value);
    if (parsed != null) {
      final number = parsed.value;
      if (type == 'number') return number;
      if (number == number.truncate()) return number;
    }
  }
  if (value is bool) return value ? 1 : 0;
  return value;
}

Object? _coerceBooleanPrimitive(Object? value) {
  if (value == null) return false;
  if (value == 'true' || value == 1) return true;
  if (value == 'false' || value == 0) return false;
  return value;
}

Object? _coerceStringPrimitive(Object? value) {
  if (value == null) return '';
  if (value is num || value is bool) return value.toString();
  return value;
}

// --- TypeBox's single-value conversions ---

/// A conversion result: present when the value converted, absent otherwise.
/// A record rather than a nullable `Object?`, because `null` is a real
/// conversion result of its own (`null` -> `"null"` for a string).
typedef _Converted = ({Object? value});

Object? _orValue(_Converted? result, Object? value) =>
    result == null ? value : result.value;

_Converted? _tryString(Object? value) {
  if (value is num || value is bool) return (value: value.toString());
  if (value == null) return (value: 'null');
  if (value is String) return (value: value);
  return null;
}

({num value})? _tryNumber(Object? value) {
  if (value is bool) return (value: value ? 1 : 0);
  if (value is num) return (value: value);
  if (value == null) return (value: 0);
  if (value is! String) return null;
  final coerced = num.tryParse(value);
  if (coerced != null) return (value: coerced);
  final lowercase = value.toLowerCase();
  if (lowercase == 'false') return (value: 0);
  if (lowercase == 'true') return (value: 1);
  return null;
}

_Converted? _tryBoolean(Object? value) {
  if (value is bool) return (value: value);
  if (value is num) {
    if (value == 0) return (value: false);
    if (value == 1) return (value: true);
    return null;
  }
  if (value == null) return (value: false);
  if (value is! String) return null;
  final lowercase = value.toLowerCase();
  if (lowercase == 'false' || value == '0') return (value: false);
  if (lowercase == 'true' || value == '1') return (value: true);
  return null;
}

_Converted? _tryNull(Object? value) {
  if (value == false) return (value: null);
  if (value is num && value == 0) return (value: null);
  if (value == null) return (value: null);
  if (value is! String) return null;
  final lowercase = value.toLowerCase();
  final converts = lowercase == 'undefined' ||
      lowercase == 'null' ||
      value == '' ||
      value == '0';
  return converts ? (value: null) : null;
}

/// A copy of [items] with [map] applied, or the same list when every item maps
/// to itself (index-aware, so duplicates are converted in place).
List<dynamic> _mapItems(
    List<dynamic> items, Object? Function(Object? item, int index) map) {
  List<dynamic>? out;
  for (var i = 0; i < items.length; i++) {
    final next = map(items[i], i);
    if (identical(next, items[i])) continue;
    out ??= List<dynamic>.of(items);
    out[i] = next;
  }
  return out ?? items;
}

String _prettyJson(Object? value) {
  const encoder = JsonEncoder.withIndent('  ');
  try {
    return encoder.convert(value);
  } on JsonUnsupportedObjectError {
    return value.toString();
  }
}

void _validateObject(
  Map<String, dynamic> schema,
  Map<String, dynamic> values,
  String path,
  List<String> errors,
) {
  final type = schema['type'];
  if (type != 'object') return;

  final properties = schema['properties'] as Map<String, dynamic>?;
  final required = schema['required'] as List<dynamic>?;

  if (required != null) {
    for (final field in required) {
      if (!values.containsKey(field)) {
        errors.add(
            '${path.isEmpty ? '' : '$path.'}$field: required field missing');
      }
    }
  }

  if (properties != null) {
    for (final entry in properties.entries) {
      final fieldName = entry.key;
      final fieldSchema = entry.value as Map<String, dynamic>;
      if (values.containsKey(fieldName)) {
        _validateValue(
          fieldSchema,
          values[fieldName],
          '${path.isEmpty ? '' : '$path.'}$fieldName',
          errors,
        );
      }
    }
  }

  final additionalProperties = schema['additionalProperties'];
  if (additionalProperties is bool && !additionalProperties) {
    final allowedKeys = properties?.keys.toSet() ?? <String>{};
    for (final key in values.keys) {
      if (!allowedKeys.contains(key)) {
        errors.add('$path.$key: additional property not allowed');
      }
    }
  }
}

void _validateValue(
  Map<String, dynamic> schema,
  dynamic value,
  String path,
  List<String> errors,
) {
  // A schema may declare its type as a union (`["string", "null"]`), in which
  // case a value matching any member is valid.
  final typeNode = schema['type'];
  final types = typeNode is String
      ? <String>[typeNode]
      : typeNode is List
          ? typeNode.whereType<String>().toList()
          : const <String>[];
  if (types.isNotEmpty && !types.any((t) => _checkType(t, value))) {
    errors
        .add('$path: expected ${types.join(' or ')}, got ${_typeName(value)}');
    return;
  }

  if (schema.containsKey('enum')) {
    final enumValues = schema['enum'] as List<dynamic>;
    if (!enumValues.contains(value)) {
      errors.add('$path: value must be one of $enumValues');
    }
  }

  if (types.contains('object') && value is Map<String, dynamic>) {
    _validateObject(schema, value, path, errors);
  }

  if (types.contains('array') && value is List) {
    final items = schema['items'] as Map<String, dynamic>?;
    if (items != null) {
      for (var i = 0; i < value.length; i++) {
        _validateValue(items, value[i], '$path[$i]', errors);
      }
    }
  }

  if (schema.containsKey('minimum') && value is num) {
    final minimum = schema['minimum'] as num;
    if (value < minimum) {
      errors.add('$path: value $value is less than minimum $minimum');
    }
  }

  if (schema.containsKey('maximum') && value is num) {
    final maximum = schema['maximum'] as num;
    if (value > maximum) {
      errors.add('$path: value $value is greater than maximum $maximum');
    }
  }

  if (schema.containsKey('minLength') && value is String) {
    final minLength = schema['minLength'] as int;
    if (value.length < minLength) {
      errors.add(
          '$path: string length ${value.length} is less than minLength $minLength');
    }
  }

  if (schema.containsKey('maxLength') && value is String) {
    final maxLength = schema['maxLength'] as int;
    if (value.length > maxLength) {
      errors.add(
          '$path: string length ${value.length} exceeds maxLength $maxLength');
    }
  }
}

bool _checkType(String type, dynamic value) => switch (type) {
      'string' => value is String,
      'number' => value is num,
      'integer' => value is int,
      'boolean' => value is bool,
      'array' => value is List,
      'object' => value is Map,
      'null' => value == null,
      _ => true,
    };

String _typeName(dynamic value) => switch (value) {
      null => 'null',
      String() => 'string',
      int() => 'integer',
      double() => 'number',
      bool() => 'boolean',
      List() => 'array',
      Map() => 'object',
      _ => value.runtimeType.toString(),
    };
