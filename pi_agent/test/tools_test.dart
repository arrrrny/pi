import 'package:test/test.dart';
import 'package:pi/pi.dart';

void main() {
  group('AgentTool', () {
    test('constructs with required fields', () {
      final tool = AgentTool<String, String>(
        name: 'get_weather',
        description: 'Get weather for a city',
        parameters: {
          'type': 'object',
          'properties': {
            'city': {'type': 'string', 'description': 'City name'},
          },
          'required': ['city'],
        },
        execute: (id, params, {onUpdate, isAborted}) async => AgentToolResult(
          content: [const TextBlock('Sunny')],
          details: 'sunny',
        ),
      );

      expect(tool.name, 'get_weather');
      expect(tool.description, 'Get weather for a city');
      expect(tool.label, '');
      expect(tool.executionMode, isNull);
    });

    test('toApiFormat produces correct structure', () {
      final tool = AgentTool<String, String>(
        name: 'search',
        description: 'Search the web',
        parameters: {'type': 'object', 'properties': {}},
        execute: (id, params, {onUpdate, isAborted}) async => AgentToolResult(
          content: [const TextBlock('')],
          details: '',
        ),
      );

      final api = tool.toApiFormat();
      expect(api['type'], 'function');
      expect((api['function'] as Map<String, dynamic>)['name'], 'search');
      expect((api['function'] as Map<String, dynamic>)['parameters'],
          isA<Map<String, dynamic>>());
    });

    test('execute returns result', () async {
      final tool = AgentTool<String, String>(
        name: 'echo',
        description: 'Echo input',
        parameters: {'type': 'object', 'properties': {}},
        execute: (id, params, {onUpdate, isAborted}) async => AgentToolResult(
          content: [TextBlock(params['msg'] as String)],
          details: 'ok',
        ),
      );

      final result = await tool.execute('tc-1', {'msg': 'hello'});
      expect(result.content, hasLength(1));
      expect((result.content[0] as TextBlock).text, 'hello');
      expect(result.details, 'ok');
      expect(result.terminate, false);
    });

    test('terminate flag works', () async {
      final tool = AgentTool<String, String>(
        name: 'stop',
        description: 'Stop',
        parameters: {},
        execute: (id, params, {onUpdate, isAborted}) async => AgentToolResult(
          content: [const TextBlock('done')],
          details: '',
          terminate: true,
        ),
      );

      final result = await tool.execute('tc-1', {});
      expect(result.terminate, true);
    });
  });

  group('validateParameters', () {
    test('returns null for valid simple object', () {
      final schema = {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
          'age': {'type': 'integer'},
        },
        'required': ['name'],
      };
      final values = {'name': 'Alice', 'age': 30};
      expect(validateParameters(schema, values), isNull);
    });

    test('returns errors for missing required field', () {
      final schema = {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
        },
        'required': ['name'],
      };
      final errors = validateParameters(schema, {});
      expect(errors, isNotNull);
      expect(errors!, anyElement(contains('required field missing')));
    });

    test('returns errors for wrong type', () {
      final schema = {
        'type': 'object',
        'properties': {
          'age': {'type': 'integer'},
        },
      };
      final errors = validateParameters(schema, {'age': 'not a number'});
      expect(errors, isNotNull);
      expect(errors!, anyElement(contains('expected integer')));
    });

    test('validates nested objects', () {
      final schema = {
        'type': 'object',
        'properties': {
          'address': {
            'type': 'object',
            'properties': {
              'city': {'type': 'string'},
            },
            'required': ['city'],
          },
        },
      };
      final errors = validateParameters(schema, {
        'address': {'city': 123},
      });
      expect(errors, isNotNull);
      expect(errors!, anyElement(contains('expected string')));
    });

    test('validates arrays with items schema', () {
      final schema = {
        'type': 'object',
        'properties': {
          'tags': {
            'type': 'array',
            'items': {'type': 'string'},
          },
        },
      };
      expect(
          validateParameters(schema, {
            'tags': ['a', 'b']
          }),
          isNull);
      final errors = validateParameters(schema, {
        'tags': ['a', 123]
      });
      expect(errors, isNotNull);
      expect(errors!, anyElement(contains('expected string')));
    });

    test('validates enum constraint', () {
      final schema = {
        'type': 'object',
        'properties': {
          'color': {
            'type': 'string',
            'enum': ['red', 'green', 'blue']
          },
        },
      };
      expect(validateParameters(schema, {'color': 'red'}), isNull);
      final errors = validateParameters(schema, {'color': 'yellow'});
      expect(errors, isNotNull);
      expect(errors!, anyElement(contains('must be one of')));
    });

    test('validates minimum/maximum for numbers', () {
      final schema = {
        'type': 'object',
        'properties': {
          'score': {'type': 'number', 'minimum': 0, 'maximum': 100},
        },
      };
      expect(validateParameters(schema, {'score': 50}), isNull);
      expect(validateParameters(schema, {'score': -1}), isNotNull);
      expect(validateParameters(schema, {'score': 101}), isNotNull);
    });

    test('validates minLength/maxLength for strings', () {
      final schema = {
        'type': 'object',
        'properties': {
          'name': {'type': 'string', 'minLength': 2, 'maxLength': 10},
        },
      };
      expect(validateParameters(schema, {'name': 'Alice'}), isNull);
      expect(validateParameters(schema, {'name': 'A'}), isNotNull);
      expect(validateParameters(schema, {'name': 'A' * 11}), isNotNull);
    });

    test('validates additionalProperties false', () {
      final schema = {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
        },
        'additionalProperties': false,
      };
      expect(validateParameters(schema, {'name': 'ok'}), isNull);
      final errors = validateParameters(schema, {'name': 'ok', 'extra': 'bad'});
      expect(errors, isNotNull);
      expect(errors!, anyElement(contains('additional property not allowed')));
    });

    test('returns null for empty schema', () {
      expect(validateParameters({}, {'anything': 'goes'}), isNull);
    });

    test('returns null for boolean type', () {
      final schema = {
        'type': 'object',
        'properties': {
          'active': {'type': 'boolean'},
        },
      };
      expect(validateParameters(schema, {'active': true}), isNull);
      expect(validateParameters(schema, {'active': 'yes'}), isNotNull);
    });

    test('returns null for number type accepting int and double', () {
      final schema = {
        'type': 'object',
        'properties': {
          'x': {'type': 'number'},
        },
      };
      expect(validateParameters(schema, {'x': 42}), isNull);
      expect(validateParameters(schema, {'x': 3.14}), isNull);
    });
  });

  group('coerceArguments', () {
    test('coerces a string number to an integer', () {
      final schema = {
        'type': 'object',
        'properties': {
          'count': {'type': 'integer'},
        },
        'required': ['count'],
      };
      expect(coerceArguments(schema, {'count': '42'}), {'count': 42});
    });

    test('truncates a fractional string for an integer field', () {
      final schema = {
        'type': 'object',
        'properties': {
          'count': {'type': 'integer'},
        },
      };
      expect(coerceArguments(schema, {'count': '3.5'}), {'count': 3});
    });

    test('coerces a string boolean', () {
      final schema = {
        'type': 'object',
        'properties': {
          'active': {'type': 'boolean'},
        },
      };
      expect(coerceArguments(schema, {'active': 'true'}), {'active': true});
      expect(coerceArguments(schema, {'active': 'false'}), {'active': false});
    });

    test('wraps a single value into a one-item array', () {
      final schema = {
        'type': 'object',
        'properties': {
          'tags': {
            'type': 'array',
            'items': {'type': 'string'},
          },
        },
      };
      expect(coerceArguments(schema, {'tags': 'solo'}), {
        'tags': ['solo']
      });
    });

    test('coerces array items', () {
      final schema = {
        'type': 'object',
        'properties': {
          'sizes': {
            'type': 'array',
            'items': {'type': 'integer'},
          },
        },
      };
      expect(
          coerceArguments(schema, {
            'sizes': ['1', '2']
          }),
          {
            'sizes': [1, 2]
          });
    });

    test('coerces a number to a string field', () {
      final schema = {
        'type': 'object',
        'properties': {
          'label': {'type': 'string'},
        },
      };
      expect(coerceArguments(schema, {'label': 7}), {'label': '7'});
    });

    test('drops null in an optional non-nullable property', () {
      final schema = {
        'type': 'object',
        'properties': {
          'path': {'type': 'string'},
        },
      };
      expect(coerceArguments(schema, {'path': null}), isEmpty);
    });

    test('keeps null when the property allows it', () {
      final schema = {
        'type': 'object',
        'properties': {
          'path': {
            'type': ['string', 'null'],
          },
        },
      };
      expect(coerceArguments(schema, {'path': null}), {'path': null});
    });

    test('never modifies the input map', () {
      final schema = {
        'type': 'object',
        'properties': {
          'count': {'type': 'integer'},
        },
      };
      final values = <String, dynamic>{'count': '42'};
      coerceArguments(schema, values);
      expect(values, {'count': '42'});
    });

    test('returns the same map when nothing changes', () {
      final schema = {
        'type': 'object',
        'properties': {
          'count': {'type': 'integer'},
        },
      };
      final values = <String, dynamic>{'count': 42};
      expect(identical(coerceArguments(schema, values), values), isTrue);
    });

    test('leaves an uncoercible value for validation to report', () {
      final schema = {
        'type': 'object',
        'properties': {
          'count': {'type': 'integer'},
        },
      };
      expect(coerceArguments(schema, {'count': 'many'}), {'count': 'many'});
    });

    test('coerces nested object properties', () {
      final schema = {
        'type': 'object',
        'properties': {
          'options': {
            'type': 'object',
            'properties': {
              'limit': {'type': 'integer'},
            },
          },
        },
      };
      expect(
          coerceArguments(schema, {
            'options': {'limit': '5'}
          }),
          {
            'options': {'limit': 5}
          });
    });
  });

  group('validateToolArguments', () {
    test('returns coerced arguments for a valid call', () {
      final validation = validateToolArguments(
        'tag',
        {
          'type': 'object',
          'properties': {
            'count': {'type': 'integer'},
          },
          'required': ['count'],
        },
        {'count': '42'},
      );
      expect(validation.error, isNull);
      expect(validation.args, {'count': 42});
    });

    test('formats a missing required field like upstream', () {
      final validation = validateToolArguments(
        'write',
        {
          'type': 'object',
          'properties': {
            'path': {'type': 'string'},
          },
          'required': ['path'],
        },
        const {},
      );
      expect(validation.args, isNull);
      final error = validation.error!;
      expect(error, startsWith('Validation failed for tool "write":'));
      expect(error, contains('  - path: required field missing'));
      expect(error, contains('Received arguments:\n{}'));
    });

    test('reports the coerced arguments in the error body', () {
      final validation = validateToolArguments(
        'count',
        {
          'type': 'object',
          'properties': {
            'value': {'type': 'integer'},
          },
          'required': ['value'],
        },
        {'value': 'many'},
      );
      expect(validation.error, contains('Received arguments:'));
      expect(validation.error, contains('"value": "many"'));
    });
  });
}
