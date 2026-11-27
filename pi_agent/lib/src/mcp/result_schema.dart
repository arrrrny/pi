/// The output schema of an MCP tool for programs that call it: the whole
/// `CallToolResult`, with the tool's own output schema as
/// `structuredContent`.
///
/// Dart port of `packages/mcp/src/result-schema.ts` at the registry-pinned SHA.
library;

/// MCP content blocks as one compact type with the fields of text and image
/// blocks, which scripts read most. Rendered into every MCP tool's
/// declaration.
const Map<String, dynamic> _contentBlockSchema = {
  'type': 'object',
  'properties': {
    'type': {
      'enum': ['text', 'image', 'audio', 'resource_link', 'resource'],
    },
    'text': {'type': 'string'},
    'data': {'type': 'string'},
    'mimeType': {'type': 'string'},
  },
  'required': ['type'],
  'additionalProperties': true,
};

/// Output schema of an MCP tool: the `CallToolResult` programs receive
/// (without `_meta`, which callers drop), with the tool's own output schema as
/// `structuredContent`. Without one, structured content may be any JSON value.
Map<String, dynamic> createMcpResultSchema(
  Map<String, dynamic>? structuredContentSchema,
) {
  return {
    'type': 'object',
    'properties': {
      'content': {'type': 'array', 'items': _contentBlockSchema},
      'structuredContent': structuredContentSchema != null
          ? _relocateSchema(
              structuredContentSchema,
              '#/properties/structuredContent',
            )
          : <String, dynamic>{},
      'isError': {'type': 'boolean'},
    },
    'required': ['content'],
    // Fields newer protocol versions add.
    'additionalProperties': true,
  };
}

/// Keywords whose values are data, so a `$ref` key in them is not a
/// reference.
const Set<String> _schemaDataKeywords = {
  'const',
  'enum',
  'default',
  'examples',
};

/// Keywords whose values map names to schemas, so their keys are names, not
/// keywords.
const Set<String> _schemaMapKeywords = {
  'properties',
  'patternProperties',
  'dependentSchemas',
  'dependencies',
  r'$defs',
  'definitions',
};

/// [schema] as a subschema at the JSON pointer [pointer]
/// (`#/properties/structuredContent`) of another schema: its local references
/// (`#`, `#/$defs/Item`) are rewritten to point below [pointer], so they
/// resolve to the same subschemas as before.
dynamic _relocateSchema(dynamic schema, String pointer) {
  // The server's schema is wire input of any JSON shape.
  if (schema is List) {
    return schema.map((item) => _relocateSchema(item, pointer)).toList();
  }
  if (schema is! Map) return schema;
  final relocated = <String, dynamic>{};
  for (final entry in schema.cast<String, dynamic>().entries) {
    final key = entry.key;
    final value = entry.value;
    if (key == r'$ref' &&
        value is String &&
        (value == '#' || value.startsWith('#/'))) {
      relocated[key] = '$pointer${value.substring(1)}';
    } else if (_schemaDataKeywords.contains(key)) {
      relocated[key] = value;
    } else if (_schemaMapKeywords.contains(key) && value is Map) {
      relocated[key] = value.cast<String, dynamic>().map(
            (name, subschema) =>
                MapEntry(name, _relocateSchema(subschema, pointer)),
          );
    } else {
      relocated[key] = _relocateSchema(value, pointer);
    }
  }
  return relocated;
}
