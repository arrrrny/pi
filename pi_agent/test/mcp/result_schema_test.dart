/// Ported from packages/mcp/test/result-schema.test.ts for pi#83.
///
/// Covers createMcpResultSchema: the output schema of an MCP tool for programs
/// that call it, with the tool's own output schema as structuredContent.
library;

import 'package:pi/mcp.dart';
import 'package:test/test.dart';

void main() {
  group('createMcpResultSchema', () {
    test(
        'declares the CallToolResult, with any structured content without an output schema',
        () {
      final schema = createMcpResultSchema(null);
      expect(
        (schema['properties'] as Map<String, dynamic>).keys.toList(),
        ['content', 'structuredContent', 'isError'],
      );
      expect(schema['properties']['structuredContent'], {});
      expect(schema['required'], ['content']);
      expect(schema['additionalProperties'], isTrue);
    });

    test(
        'moves the output schema\'s local references below structuredContent, keeping data and remote references',
        () {
      final hit = {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
        },
      };
      final schema = createMcpResultSchema({
        'type': 'object',
        'properties': {
          'hits': {
            'type': 'array',
            'items': {r'$ref': r'#/$defs/Hit'},
          },
          'children': {
            'type': 'array',
            'items': {r'$ref': '#'},
          },
          // A property named like a keyword: its value is a schema.
          'default': {r'$ref': '#/definitions/Hit'},
          'remote': {r'$ref': 'https://example.com/schema.json'},
        },
        r'$defs': {
          'Hit': {
            ...hit,
            'default': {r'$ref': '#/stays'},
          },
        },
        'definitions': {'Hit': hit},
      });
      final moved = (schema['properties']
          as Map<String, dynamic>)['structuredContent'] as Map<String, dynamic>;
      final at = '#/properties/structuredContent';
      expect(
        (moved['properties'] as Map)['hits'],
        {
          'type': 'array',
          'items': {r'$ref': '$at/\$defs/Hit'},
        },
      );
      expect(
        (moved['properties'] as Map)['children'],
        {
          'type': 'array',
          'items': {r'$ref': at},
        },
      );
      expect(
        (moved['properties'] as Map)['default'],
        {r'$ref': '$at/definitions/Hit'},
      );
      expect(
        (moved['properties'] as Map)['remote'],
        {r'$ref': 'https://example.com/schema.json'},
      );
      expect(
        ((moved[r'$defs'] as Map)['Hit'] as Map)['default'],
        {r'$ref': '#/stays'},
      );
    });
  });
}
