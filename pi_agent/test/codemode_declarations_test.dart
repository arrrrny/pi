import 'package:pi/src/codemode_declarations.dart';
import 'package:pi/tools.dart' as public_api;
import 'package:test/test.dart';

void main() {
  // The declarations surface is advertised through `package:pi/tools.dart`
  // (the public codemode entrypoint); exercise that re-export too.
  test('declarations surface is reachable through package:pi/tools.dart', () {
    expect(public_api.toCodemodeIdentifier('my-tool'), equals('my_tool'));
    expect(public_api.defaultInputSchemaMaxChars, equals(16000));
  });

  group('schemaToType', () {
    test('renders primitives, literals, and unions', () {
      expect(schemaToType({'type': 'string'}), 'string');
      expect(schemaToType({'type': 'integer'}), 'number');
      expect(
          schemaToType({
            'type': ['string', 'null']
          }),
          'string | null');
      expect(schemaToType({'const': 'a'}), '"a"');
      expect(
          schemaToType({
            'enum': ['a', 1, null]
          }),
          '"a" | 1 | null');
      expect(
          schemaToType({
            'anyOf': [
              {'type': 'string'},
              {'type': 'number'}
            ]
          }),
          'string | number');
      expect(
          schemaToType({
            'anyOf': [
              {'type': 'string'},
              {}
            ]
          }),
          'unknown');
      expect(
          schemaToType({
            'allOf': [
              {
                'anyOf': [
                  {'type': 'string'},
                  {'type': 'number'}
                ]
              },
              {'const': 1}
            ]
          }),
          '(string | number) & 1');
      expect(schemaToType({'\$ref': '#/defs/x'}), 'unknown');
      expect(schemaToType(true), 'unknown');
      expect(schemaToType(false), 'never');
    });

    test('renders objects on one line with sorted properties', () {
      expect(
          schemaToType({
            'type': 'object',
            'properties': {
              'city': {'type': 'string'},
              'max-lines': {'type': 'number'}
            },
            'required': ['city'],
            'additionalProperties': false
          }),
          '{ city: string; "max-lines"?: number; }');
      expect(
          schemaToType({
            'type': 'object',
            'additionalProperties': {'type': 'number'}
          }),
          '{ [key: string]: number; }');
      expect(schemaToType({'type': 'object'}), '{ [key: string]: unknown; }');
      expect(
          schemaToType({
            'type': 'object',
            'properties': {},
            'additionalProperties': false
          }),
          '{}');
    });

    test('puts property descriptions on comment lines', () {
      expect(
          schemaToType({
            'type': 'object',
            'properties': {
              'weather': {
                'type': 'array',
                'description': 'look up weather for a given list of locations',
                'items': {
                  'type': 'object',
                  'properties': {
                    'location': {'type': 'string'}
                  },
                  'required': ['location']
                }
              }
            },
            'required': ['weather']
          }),
          '{\n  // look up weather for a given list of locations\n'
          '  weather: Array<{ location: string; }>;\n}');
      expect(
          schemaToType({
            'type': 'object',
            'properties': {
              'outer': {
                'type': 'object',
                'description': 'Outer',
                'properties': {
                  'inner': {'type': 'string', 'description': 'Inner'}
                }
              }
            }
          }),
          '{\n  // Outer\n  outer?: {\n    // Inner\n    inner?: string;\n  };\n}');
    });

    // https://github.com/earendil-works/pi/issues/10707
    test('puts constraints the type cannot express on property comment lines',
        () {
      expect(
          schemaToType({
            'type': 'object',
            'properties': {
              'timeoutMs': {
                'type': 'integer',
                'minimum': 0,
                'maximum': 30000,
                'default': 0,
                'description': 'Wait in milliseconds.'
              },
              'id': {'type': 'string', 'pattern': '^[a-z]+\$', 'maxLength': 8},
              'tags': {
                'type': 'array',
                'items': {'type': 'string'},
                'maxItems': 5,
                'uniqueItems': true,
                'deprecated': true
              },
              'name': {'type': 'string'}
            },
            'required': ['id']
          }),
          [
            '{',
            '  // @maxLength 8 @pattern ^[a-z]+\$',
            '  id: string;',
            '  name?: string;',
            '  // @maxItems 5 @uniqueItems @deprecated',
            '  tags?: Array<string>;',
            '  // Wait in milliseconds.',
            '  // @integer @minimum 0 @maximum 30000 @default 0',
            '  timeoutMs?: number;',
            '}',
          ].join('\n'));
    });

    test('reads constraints of optional fields from the non-null branch', () {
      // Pydantic's `limit: int | None = Field(None, ge=1, le=100)`.
      expect(
          schemaToType({
            'type': 'object',
            'properties': {
              'limit': {
                'anyOf': [
                  {'type': 'integer', 'minimum': 1, 'maximum': 100},
                  {'type': 'null'}
                ],
                'default': null,
                'title': 'Limit'
              }
            }
          }),
          '{\n  // @integer @minimum 1 @maximum 100\n  limit?: number | null;\n}');
      // Constraints of the property and the branch both apply.
      expect(
          schemaToType({
            'type': 'object',
            'properties': {
              'n': {
                'anyOf': [
                  {
                    'type': 'integer',
                    'minimum': 10,
                    'maximum': 50,
                    'format': 'int32'
                  },
                  {'type': 'null'}
                ],
                'minimum': 0,
                'maximum': 20,
                'format': 'port'
              }
            }
          }),
          '{\n  // @integer @minimum 10 @maximum 20 @format port @format int32\n'
          '  n?: number | null;\n}');
    });

    test('reads draft-04 boolean exclusive bounds', () {
      expect(
          schemaToType({
            'type': 'object',
            'properties': {
              'n': {
                'type': 'integer',
                'minimum': 0,
                'exclusiveMinimum': true,
                'maximum': 10,
                'exclusiveMaximum': false
              },
              'm': {
                'anyOf': [
                  {'type': 'number', 'maximum': 5, 'exclusiveMaximum': true},
                  {'type': 'null'}
                ],
                'maximum': 8
              }
            }
          }),
          [
            '{',
            '  // @maximum 8 @exclusiveMaximum 5',
            '  m?: number | null;',
            '  // @integer @exclusiveMinimum 0 @maximum 10',
            '  n?: number;',
            '}',
          ].join('\n'));
    });

    test('leaves out long tags and escapes line terminators', () {
      expect(
          schemaToType({
            'type': 'object',
            'properties': {
              'config': {
                'type': 'object',
                'default': {'text': 'x' * 100}
              }
            }
          }),
          '{ config?: { [key: string]: unknown; }; }');
      expect(
          schemaToType({
            'type': 'object',
            'properties': {
              'sep': {
                'type': 'string',
                'pattern': '^[\r\n\u2028\u2029]\$',
                'default': '\u2028',
                'description': 'a\u2028b'
              }
            }
          }),
          [
            '{',
            '  // a',
            '  // b',
            '  // @pattern ^[\\u000d\\u000a\\u2028\\u2029]\$ @default "\\u2028"',
            '  sep?: string;',
            '}',
          ].join('\n'));
    });

    test('drops constraint tags before rendering a type over budget as unknown',
        () {
      final schema = {
        'type': 'object',
        'properties': {
          'n': {'type': 'integer', 'minimum': 1}
        }
      };
      expect(schemaToType(schema),
          '{\n  // @integer @minimum 1\n  n?: number;\n}');
      expect(schemaToType(schema, maxChars: 20), '{ n?: number; }');
      expect(schemaToType(schema, maxChars: 10), 'unknown');
    });

    test('resolves local references and stops at recursive ones', () {
      final schema = {
        'type': 'object',
        'properties': {
          'item': {'\$ref': '#/\$defs/Item'},
          'legacy': {'\$ref': '#/definitions/Legacy'},
          'remote': {'\$ref': 'https://example.com/schema.json'}
        },
        'required': ['item'],
        '\$defs': {
          'Item': {
            'type': 'object',
            'properties': {
              'id': {'type': 'string'},
              'parent': {'\$ref': '#/\$defs/Item'}
            },
            'required': ['id']
          }
        },
        'definitions': {
          'Legacy': {
            'enum': ['a', 'b']
          }
        }
      };
      expect(schemaToType(schema),
          '{ item: { id: string; parent?: unknown; }; legacy?: "a" | "b"; remote?: unknown; }');
    });

    test('renders arrays and tuples', () {
      expect(
          schemaToType({
            'type': 'array',
            'items': {'type': 'string'}
          }),
          'Array<string>');
      expect(
          schemaToType({
            'type': 'array',
            'prefixItems': [
              {'type': 'string'},
              {'type': 'number'}
            ]
          }),
          '[string, number]');
      expect(schemaToType({'type': 'array'}), 'unknown[]');
    });

    test('renders types over the budget as unknown', () {
      final properties = {
        for (var i = 0; i < 50; i++) 'field$i': {'type': 'string'}
      };
      final schema = {'type': 'object', 'properties': properties};
      expect(schemaToType(schema, maxChars: 100), 'unknown');
      expect(schemaToType(schema), contains('field49?: string;'));
    });
  });

  group('resolveSchemaRef', () {
    final item = {'type': 'string'};
    final root = {
      '\$defs': {'item': item, 'a/b': item, 'c~d': item, 'e f': item}
    };

    test('resolves local references with escaped segments', () {
      expect(resolveSchemaRef('#', root), same(root));
      expect(resolveSchemaRef('#/\$defs/item', root), same(item));
      expect(resolveSchemaRef('#/\$defs/a~1b', root), same(item));
      expect(resolveSchemaRef('#/\$defs/c~0d', root), same(item));
      expect(resolveSchemaRef('#/\$defs/e%20f', root), same(item));
    });

    test('returns null for remote, missing, and malformed references', () {
      expect(resolveSchemaRef('other.json#/\$defs/item', root), isNull);
      expect(resolveSchemaRef('#/\$defs/missing', root), isNull);
      expect(resolveSchemaRef('#/\$defs/%E0%A4%A', root), isNull);
    });
  });

  group('tool declarations', () {
    test('renders signatures with normalized identifiers', () {
      expect(
          renderToolSignature(CodemodeTool(
            name: 'hidden-dynamic-tool',
            inputSchema: {
              'type': 'object',
              'properties': {
                'city': {'type': 'string'}
              },
              'required': ['city'],
              'additionalProperties': false
            },
            outputSchema: {
              'type': 'object',
              'properties': {
                'ok': {'type': 'boolean'}
              },
              'required': ['ok']
            },
          )),
          'hidden_dynamic_tool(args: { city: string; }): Promise<{ ok: boolean; }>;');
      expect(renderToolSignature(CodemodeTool(name: 'free')),
          'free(args: unknown): Promise<unknown>;');
    });

    test(
        'renders output schemas shaped like an MCP CallToolResult as plain types',
        () {
      final outputSchema = {
        'type': 'object',
        'properties': {
          'content': {
            'type': 'array',
            'items': {'type': 'object'}
          },
          'isError': {'type': 'boolean'},
          '_meta': {'type': 'object'}
        },
        'required': ['content']
      };
      expect(
          renderToolSignature(CodemodeTool(
            name: 'plain',
            inputSchema: {'type': 'object', 'properties': {}},
            outputSchema: outputSchema,
          )),
          'plain(args: { [key: string]: unknown; }): Promise<'
          '{ _meta?: { [key: string]: unknown; }; content: Array<{ [key: string]: unknown; }>; isError?: boolean; }>;');
    });

    test('renders the per-tool sample', () {
      expect(
          renderToolSample(CodemodeTool(
            name: 'foo',
            description: 'bar',
            inputSchema: {'type': 'string'},
          )),
          'bar\n\ncodemode tool declaration:\n```ts\n'
          'declare const tools: { foo(args: string): Promise<unknown>; };\n```');
    });
  });

  group('renderDeclarations', () {
    test('renders tools and globals', () {
      final text = renderDeclarations(RenderDeclarationsOptions(tools: [
        CodemodeTool(
          name: 'read',
          description: 'Read a file.\nSecond line.',
          inputSchema: {
            'type': 'object',
            'properties': {
              'path': {'type': 'string'}
            },
            'required': ['path']
          },
          outputSchema: {'type': 'string'},
        ),
        CodemodeTool(name: 'remote-api'),
      ], globals: [
        CodemodeTool(
          name: 'attach',
          description: 'Attach it.',
          inputSchema: {'type': 'string'},
        ),
      ]));
      expect(
          text,
          [
            'declare const tools: {',
            '  /**',
            '   * Read a file.',
            '   * Second line.',
            '   */',
            '  read(args: { path: string; }): Promise<string>;',
            '  remote_api(args: unknown): Promise<unknown>;',
            '};',
            '',
            '/** Attach it. */',
            'declare function attach(args: string): Promise<unknown>;',
          ].join('\n'));
    });

    test('renders namespaced globals and explicit signatures', () {
      final text = renderDeclarations(RenderDeclarationsOptions(globals: [
        CodemodeTool(
          name: 'models.list',
          description: 'List models.',
          signature: '(type: string): Promise<string[]>',
        ),
        CodemodeTool(name: 'models.get', inputSchema: {'type': 'string'}),
        CodemodeTool(name: 'plain', signature: '(): void'),
      ]));
      expect(
          text,
          [
            'declare function plain(): void;',
            '',
            'declare const models: {',
            '  /** List models. */',
            '  list(type: string): Promise<string[]>;',
            '  get(args: string): Promise<unknown>;',
            '};',
          ].join('\n'));
    });

    test('escapes comment terminators in descriptions', () {
      final text = renderDeclarations(RenderDeclarationsOptions(
          tools: [CodemodeTool(name: 'x', description: 'a */ b')]));
      expect(text, contains('/** a *\\/ b */'));
    });
  });
}
