/// Ported from packages/mcp/test/input-schema.test.ts for pi#83.
///
/// Covers normalizeMcpInputSchema: an MCP tool's input schema in the shape LLM
/// tool APIs accept.
library;

import 'package:pi/mcp.dart';
import 'package:test/test.dart';

void main() {
  group('normalizeMcpInputSchema', () {
    test('adds type object and empty properties when missing', () {
      expect(normalizeMcpInputSchema({}), {'type': 'object', 'properties': {}});
      expect(
        normalizeMcpInputSchema({'type': 'object'}),
        {'type': 'object', 'properties': {}},
      );
    });

    test('keeps the schema\'s own keywords', () {
      final schema = {
        'type': 'object',
        'properties': {
          'query': {'type': 'string'},
        },
        'required': ['query'],
        'additionalProperties': false,
      };
      expect(normalizeMcpInputSchema(schema), schema);
      expect(
        normalizeMcpInputSchema({
          'properties': {
            'a': {},
          },
          r'$defs': {
            'x': {},
          },
        }),
        {
          'type': 'object',
          'properties': {
            'a': {},
          },
          r'$defs': {
            'x': {},
          },
        },
      );
    });
  });
}
