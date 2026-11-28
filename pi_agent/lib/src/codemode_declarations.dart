/// Codemode declaration rendering: TypeScript declarations for the
/// script-visible API.
///
/// Tools become members of `declare const tools`, globals become
/// `declare function` statements (or members of a `declare const ns`
/// namespace object), descriptions become doc comments, and JSON Schemas
/// become TypeScript type expressions.
///
/// Port of `packages/codemode/src/declarations.ts` and
/// `packages/codemode/src/identifier.ts`. The upstream TypeScript stays the
/// oracle; this is a behavior-for-behavior port of the rendering surface.
library;

import 'dart:convert';

/// A JSON Schema document. Only used to render declarations; values are not
/// validated against it. A schema is either a boolean or a JSON object.
typedef CodemodeJsonSchema = Object;

/// A tool or global as the declaration renderer sees it.
///
/// Mirrors the fields of upstream `CodemodeTool` that
/// `renderDeclarations`/`renderToolSignature` read. `execute` and the sandbox
/// context are not part of the rendering surface and are omitted here.
class CodemodeTool {
  /// The script-visible name. Tools are called as `tools.<id>(args)` with
  /// `<id>` from [toCodemodeIdentifier]; globals as `<name>(args)` or
  /// `<namespace>.<member>`.
  final String name;

  /// Shown as a doc comment in [renderDeclarations], and listed in
  /// `ALL_TOOLS` for tools.
  final String? description;

  /// Schema of the single argument. Rendered as the parameter type; `unknown`
  /// when omitted.
  final CodemodeJsonSchema? inputSchema;

  /// Schema of the resolved value. Rendered as the promise type; `unknown`
  /// when omitted.
  final CodemodeJsonSchema? outputSchema;

  /// Globals only: TypeScript parameter list and return type for
  /// [renderDeclarations], for example `(type: string): Promise<Model[]>` —
  /// shown in backticks. Replaces the rendering from the schemas.
  final String? signature;

  /// Creates a declaration tool or global.
  const CodemodeTool({
    required this.name,
    this.description,
    this.inputSchema,
    this.outputSchema,
    this.signature,
  });
}

/// Options for [renderDeclarations].
class RenderDeclarationsOptions {
  /// Tools rendered as members of `declare const tools`.
  final List<CodemodeTool> tools;

  /// Globals rendered as `declare function` statements or namespace members.
  final List<CodemodeTool> globals;

  /// Creates declaration render options.
  const RenderDeclarationsOptions(
      {this.tools = const [], this.globals = const []});
}

/// Largest rendered input type, in characters, before it becomes `unknown`.
const int defaultInputSchemaMaxChars = 16000;

const String _indent = '  ';
const int _maxRefExpansions = 32;

/// JSON Schema keywords with a number or string value shown as `@keyword
/// value` property tags.
const List<String> _tagKeywords = [
  'minimum',
  'exclusiveMinimum',
  'maximum',
  'exclusiveMaximum',
  'multipleOf',
  'minLength',
  'maxLength',
  'pattern',
  'format',
  'minItems',
  'maxItems',
];

/// Tag keywords whose values all hold at once, so only the largest (lower) or
/// smallest (upper) matters.
const Set<String> _lowerBounds = {
  'minimum',
  'exclusiveMinimum',
  'minLength',
  'minItems'
};
const Set<String> _upperBounds = {
  'maximum',
  'exclusiveMaximum',
  'maxLength',
  'maxItems'
};

/// Longest property tag; longer ones (large defaults, long patterns) are left
/// out.
const int _maxTagChars = 80;

/// Characters that end a `//` comment.
final RegExp _lineTerminators = RegExp(r'[\r\n\u2028\u2029]');

final RegExp _identifier = RegExp(r'^[A-Za-z_$][A-Za-z0-9_$]*$');
final RegExp _identifierStart = RegExp(r'^[A-Za-z_$]$');
final RegExp _identifierPart = RegExp(r'^[A-Za-z0-9_$]$');

/// The identifier a script uses for a tool: characters that are not valid in a
/// JavaScript identifier become `_`. `mcp__docs__search` stays as is,
/// `my-tool` becomes `my_tool`.
///
/// Port of upstream `toCodemodeIdentifier`.
String toCodemodeIdentifier(String name) {
  var identifier = '';
  for (final rune in name.runes) {
    final char = String.fromCharCode(rune);
    final valid = identifier.isEmpty
        ? _identifierStart.hasMatch(char)
        : _identifierPart.hasMatch(char);
    identifier += valid ? char : '_';
  }
  return identifier.isEmpty ? '_' : identifier;
}

/// Render TypeScript declarations for the script-visible API. Tools become
/// members of `declare const tools`, globals become `declare function`
/// statements, and `ns.member` globals members of `declare const ns`.
/// Descriptions become doc comments; schemas become types.
String renderDeclarations(RenderDeclarationsOptions options) {
  final sections = <String>[];
  final tools = options.tools;
  if (tools.isNotEmpty) {
    final members = tools
        .map((tool) =>
            '${_docComment(tool.description, _indent)}$_indent${renderToolSignature(tool)}')
        .toList();
    sections.add('declare const tools: {\n${members.join('\n')}\n};');
  }
  final namespaces = <String, List<String>>{};
  for (final global in options.globals) {
    final dot = global.name.indexOf('.');
    if (dot == -1) {
      sections
          .add(_renderGlobal('declare function ${global.name}', global, ''));
      continue;
    }
    final namespace = global.name.substring(0, dot);
    final members = namespaces.putIfAbsent(namespace, () => <String>[]);
    members.add(_renderGlobal(global.name.substring(dot + 1), global, _indent));
  }
  for (final entry in namespaces.entries) {
    sections
        .add('declare const ${entry.key}: {\n${entry.value.join('\n')}\n};');
  }
  return sections.join('\n\n');
}

/// One tool as a member of the `tools` object: `name(args: T): Promise<R>;`
/// with the name as the identifier scripts use. Input types longer than
/// `inputMaxChars` render as `unknown`.
String renderToolSignature(CodemodeTool tool, {int? inputMaxChars}) {
  final input = tool.inputSchema == null
      ? 'unknown'
      : schemaToType(tool.inputSchema!,
          maxChars: inputMaxChars ?? defaultInputSchemaMaxChars);
  return '${toCodemodeIdentifier(tool.name)}(args: $input): '
      'Promise<${renderToolOutputType(tool.outputSchema)}>;';
}

/// A tool's sample: the description followed by the tool's declaration. Used
/// for tool listings and `ALL_TOOLS` entries.
String renderToolSample(CodemodeTool tool, {int? inputMaxChars}) {
  final declaration =
      'declare const tools: { ${renderToolSignature(tool, inputMaxChars: inputMaxChars)} };';
  final description = tool.description?.trim() ?? '';
  return '$description\n\ncodemode tool declaration:\n```ts\n$declaration\n```';
}

/// The type a tool call resolves to: the output schema's type, and `unknown`
/// without a schema.
String renderToolOutputType(CodemodeJsonSchema? schema) {
  return schema == null ? 'unknown' : schemaToType(schema);
}

String _renderGlobal(String head, CodemodeTool global, String indent) {
  if (global.signature != null) {
    return '${_docComment(global.description, indent)}$indent$head${global.signature};';
  }
  final input = global.inputSchema == null
      ? 'unknown'
      : schemaToType(global.inputSchema!);
  final output = global.outputSchema == null
      ? 'unknown'
      : schemaToType(global.outputSchema!);
  return '${_docComment(global.description, indent)}$indent$head(args: $input): '
      'Promise<$output>;';
}

String _docComment(String? description, String indent) {
  final text = description?.trim();
  if (text == null || text.isEmpty) return '';
  final lines = text.replaceAll('*/', r'*\/').split(RegExp(r'\r?\n'));
  if (lines.length == 1) return '$indent/** ${lines[0]} */\n';
  final body = lines
      .map((line) => '$indent *${line.isNotEmpty ? ' $line' : ''}')
      .join('\n');
  return '$indent/**\n$body\n$indent */\n';
}

String _propertyKey(String name) =>
    _identifier.hasMatch(name) ? name : jsonEncode(name);

String _union(List<String> types) {
  final unique = <String>{...types};
  if (unique.contains('unknown')) return 'unknown';
  if (unique.isEmpty) return 'never';
  return unique.join(' | ');
}

/// Convert a JSON Schema to a TypeScript type expression: objects on one line
/// (`{ a: string; b?: number; }`) with properties sorted by name, or one
/// property per line with `//` comments when a property has a description or
/// constraints the type cannot express (`// @integer @minimum 1 @default 20`);
/// `Array<T>` for arrays. Local references (`#/$defs/...`, `#/definitions/...`)
/// resolve against [schema]; recursive and remote references render as
/// `unknown`. A result longer than [maxChars] is rendered again without the
/// constraint tags, and renders as `unknown` if it is still too long.
String schemaToType(CodemodeJsonSchema schema, {int? maxChars}) {
  String render(bool tags) =>
      _toType(schema, _SchemaContext(root: schema, tags: tags));
  final type = render(true);
  if (maxChars == null || type.length <= maxChars) return type;
  final untagged = render(false);
  return untagged.length <= maxChars ? untagged : 'unknown';
}

class _SchemaContext {
  final Object root;

  /// References being expanded on the current path, to stop at recursive
  /// types.
  final Set<String> resolving = <String>{};

  int expansions = 0;

  /// Whether property comments include constraint tags.
  final bool tags;

  _SchemaContext({required this.root, required this.tags});
}

/// The subschema a local `$ref` (`#`, `#/$defs/Item`) names in [root], or null
/// for remote references and references that name nothing. Pointer segments
/// are URI-decoded and JSON Pointer unescaped (`~1` is `/`, `~0` is `~`).
Object? resolveSchemaRef(String ref, Object? root) {
  if (ref != '#' && !ref.startsWith('#/')) return null;
  Object? current = root;
  final body = ref.length <= 2 ? '' : ref.substring(2);
  for (final segment in body.split('/')) {
    if (segment.isEmpty) continue;
    String decoded;
    try {
      decoded = Uri.decodeComponent(segment);
    } catch (_) {
      // Schemas come from tools and MCP servers: a malformed escape names
      // nothing instead of failing the caller.
      return null;
    }
    final key = decoded.replaceAll('~1', '/').replaceAll('~0', '~');
    if (current is! Map || !current.containsKey(key)) return null;
    current = current[key];
  }
  if (current is bool) return current;
  return current is Map ? current : null;
}

String _toType(Object? schema, _SchemaContext context) {
  if (schema is bool) return schema ? 'unknown' : 'never';
  if (schema is! Map) return 'unknown';
  final map = Map<String, Object?>.from(schema);
  final ref = map['\$ref'];
  if (ref is String) {
    if (context.resolving.contains(ref) ||
        context.expansions >= _maxRefExpansions) {
      return 'unknown';
    }
    final target = resolveSchemaRef(ref, context.root);
    if (target == null) return 'unknown';
    context.expansions++;
    context.resolving.add(ref);
    try {
      return _toType(target, context);
    } finally {
      context.resolving.remove(ref);
    }
  }

  if (map.containsKey('const')) return jsonEncode(map['const']);

  final enumValues = map['enum'];
  if (enumValues is List) {
    return _union(enumValues
        .map((value) => jsonEncode(value))
        .whereType<String>()
        .toList());
  }

  final anyOf = map['anyOf'];
  final oneOf = map['oneOf'];
  final variants = anyOf is List ? anyOf : (oneOf is List ? oneOf : null);
  if (variants != null) {
    return _union(
        variants.map((variant) => _toType(variant, context)).toList());
  }
  final allOf = map['allOf'];
  if (allOf is List) {
    final parts = allOf
        .map((part) => _toType(part, context))
        .where((part) => part != 'unknown')
        .toList();
    if (parts.isEmpty) return 'unknown';
    return parts
        .map((part) => part.contains(' | ') ? '($part)' : part)
        .join(' & ');
  }

  final type = map['type'];
  if (type is List) {
    return _union(type
        .map((entry) => _toType({...map, 'type': entry}, context))
        .toList());
  }
  switch (type) {
    case 'string':
      return 'string';
    case 'number':
    case 'integer':
      return 'number';
    case 'boolean':
      return 'boolean';
    case 'null':
      return 'null';
    case 'array':
      return _arrayType(map, context);
    case 'object':
      return _objectType(map, context);
    case null:
      if (map.containsKey('properties') ||
          map.containsKey('additionalProperties') ||
          map.containsKey('required')) {
        return _objectType(map, context);
      }
      if (map.containsKey('items') || map.containsKey('prefixItems')) {
        return _arrayType(map, context);
      }
      return 'unknown';
    default:
      return 'unknown';
  }
}

String _arrayType(Map<String, Object?> schema, _SchemaContext context) {
  final items = schema['items'];
  if (items != null && items is! List) {
    return 'Array<${_toType(items, context)}>';
  }
  final prefixItems = schema['prefixItems'];
  final tuple = prefixItems is List
      ? prefixItems
      : (items is List ? items : const <Object?>[]);
  if (tuple.isNotEmpty) {
    return '[${tuple.map((item) => _toType(item, context)).join(', ')}]';
  }
  return 'unknown[]';
}

String _descriptionOf(Object? property) {
  final description = property is Map ? property['description'] : null;
  return description is String ? description.trim() : '';
}

/// Constraints of a property that its TypeScript type cannot express, as
/// JSDoc-style tags: `@integer @minimum 1 @maximum 100 @default 20`. Empty when
/// there are none.
String _constraintTags(Object? schema) {
  if (schema is! Map) return '';
  final property = schema;

  // Optional fields such as Pydantic's `int | None` keep their constraints in
  // the non-null branch. The branch's constraints apply together with the
  // property's, so both are read.
  final variantsRaw =
      property['anyOf'] is List ? property['anyOf'] : property['oneOf'];
  final variants = variantsRaw is List ? variantsRaw : const <Object?>[];
  final nonNull = variants
      .where((variant) => (variant is Map ? variant['type'] : null) != 'null')
      .toList();
  final branch = nonNull.length == 1 ? nonNull[0] : null;
  final List<Object?> branches =
      branch is Map ? [property, branch] : [property];

  // Draft-04 and OpenAPI 3.0 make `minimum`/`maximum` exclusive with a boolean
  // `exclusiveMinimum`/`exclusiveMaximum`.
  final schemas = branches.map((entry) {
    final out =
        Map<String, Object?>.of(Map<String, Object?>.from(entry as Map));
    if (out['exclusiveMinimum'] == true) {
      final minimum = out['minimum'];
      out.remove('minimum');
      out['exclusiveMinimum'] = minimum;
    }
    if (out['exclusiveMaximum'] == true) {
      final maximum = out['maximum'];
      out.remove('maximum');
      out['exclusiveMaximum'] = maximum;
    }
    return out;
  }).toList();

  final tags = <String>[];
  bool isInteger(Object? type) =>
      type == 'integer' || (type is List && type.contains('integer'));
  if (schemas.any((schema) => isInteger(schema['type']))) tags.add('@integer');
  for (final keyword in _tagKeywords) {
    final values = schemas.map((schema) => schema[keyword]).toList();
    if (_lowerBounds.contains(keyword) || _upperBounds.contains(keyword)) {
      final numbers = values.whereType<num>().toList();
      if (numbers.isEmpty) continue;
      final chosen = _lowerBounds.contains(keyword)
          ? numbers.reduce((a, b) => a > b ? a : b)
          : numbers.reduce((a, b) => a < b ? a : b);
      tags.add('@$keyword ${_formatNumber(chosen)}');
      continue;
    }
    for (final value in <Object?>{...values}) {
      if (value is num) {
        tags.add('@$keyword ${_formatNumber(value)}');
      } else if (value is String) {
        tags.add('@$keyword $value');
      }
    }
  }
  if (schemas.any((schema) => schema['uniqueItems'] == true)) {
    tags.add('@uniqueItems');
  }
  // Annotations, unlike constraints, come from the property itself.
  final defaultValue = property['default'];
  if (defaultValue != null) {
    tags.add('@default ${jsonEncode(defaultValue)}');
  }
  if (property['deprecated'] == true) tags.add('@deprecated');
  return tags
      .where((tag) => tag.length <= _maxTagChars)
      .map((tag) => tag.replaceAllMapped(
          _lineTerminators,
          (match) =>
              '\\u${match[0]!.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}'))
      .join(' ');
}

String _objectType(Map<String, Object?> schema, _SchemaContext context) {
  final rawProperties = schema['properties'];
  final properties =
      rawProperties is Map ? rawProperties : const <Object?, Object?>{};
  final rawRequired = schema['required'];
  final required = <Object?>{...(rawRequired is List ? rawRequired : const [])};
  final names = properties.keys.cast<String>().toList()..sort();
  final members = names.map((name) {
    final optional = required.contains(name) ? '' : '?';
    return '${_propertyKey(name)}$optional: ${_toType(properties[name], context)};';
  }).toList();
  final additional = schema['additionalProperties'];
  if (additional != null && additional != false) {
    final type = additional == true ? 'unknown' : _toType(additional, context);
    members.add('[key: string]: $type;');
  } else if (additional == null && names.isEmpty) {
    members.add('[key: string]: unknown;');
  }
  if (members.isEmpty) return '{}';
  final comments = names.map((name) {
    final lines = _descriptionOf(properties[name])
        .split(_lineTerminators)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final tags = context.tags ? _constraintTags(properties[name]) : '';
    return tags.isNotEmpty ? [...lines, tags] : lines;
  }).toList();
  if (!comments.any((comment) => comment.isNotEmpty)) {
    return '{ ${members.join(' ')} }';
  }

  final lines = <String>['{'];
  for (var index = 0; index < comments.length; index++) {
    for (final line in comments[index]) {
      lines.add('$_indent// $line');
    }
    lines.add('$_indent${members[index].replaceAll('\n', '\n$_indent')}');
  }
  for (final member in members.skip(names.length)) {
    lines.add('$_indent$member');
  }
  lines.add('}');
  return lines.join('\n');
}

/// Format a number the way JavaScript's `String(number)` does for the values
/// JSON Schemas carry: whole doubles print without a fractional part.
String _formatNumber(num value) {
  if (value is int) return value.toString();
  if (value == value.roundToDouble() && value.abs() < 1e21) {
    return value.toInt().toString();
  }
  return value.toString();
}
