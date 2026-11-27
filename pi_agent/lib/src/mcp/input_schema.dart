/// An MCP tool's input schema in the shape LLM tool APIs accept.
///
/// Dart port of `packages/mcp/src/input-schema.ts` at the registry-pinned SHA.
library;

/// The tool's input schema as an object schema. Tool parameters must be
/// objects, MCP servers may omit `type`, and some providers reject object
/// schemas without `properties`. Other keywords are kept.
Map<String, dynamic> normalizeMcpInputSchema(
  Map<String, dynamic> schema,
) {
  return {
    ...schema,
    'type': schema['type'] ?? 'object',
    if (schema['properties'] == null) 'properties': <String, dynamic>{},
  };
}
