/// Unit tests for the draft2020-12 reference and annotation keywords ported in
/// pi#53 that the official fixtures exercise only through remote documents:
/// `$anchor`, `$dynamicAnchor`, `$dynamicRef`, and the annotation-only
/// `vocabulary`. Remote `$ref` resolution is a documented remaining divergence.
library;

import 'package:pi/schema.dart';
import 'package:test/test.dart';

void main() {
  group('\$anchor', () {
    test('a local ref resolves a named anchor', () {
      final root = <String, Object?>{
        '\$defs': {
          'positive': {'\$anchor': 'positive', 'type': 'integer', 'minimum': 0},
        },
        '\$ref': '#positive',
      };
      final v = SchemaValidator(root, draft: Draft.draft2020);
      expect(v.check(root, 5), isTrue);
      expect(v.check(root, -1), isFalse);
      expect(v.check(root, 'x'), isFalse);
    });
  });

  group('\$dynamicAnchor / \$dynamicRef', () {
    test('a local dynamicRef resolves a dynamicAnchor', () {
      final root = <String, Object?>{
        '\$defs': {
          'node': {
            '\$dynamicAnchor': 'node',
            'type': 'object',
            'properties': {
              'value': {'type': 'integer'},
            },
          },
        },
        '\$dynamicRef': '#node',
      };
      final v = SchemaValidator(root, draft: Draft.draft2020);
      expect(
          v.check(root, {
            'value': 1,
          }),
          isTrue);
      expect(
          v.check(root, {
            'value': 'no',
          }),
          isFalse);
    });
  });

  group('vocabulary', () {
    test('vocabulary is annotation-only and ignored', () {
      final root = <String, Object?>{
        'vocabulary': {
          'https://json-schema.org/draft/2020-12/vocab/core': true,
        },
        'type': 'integer',
      };
      final v = SchemaValidator(root, draft: Draft.draft2020);
      expect(v.check(root, 1), isTrue);
      expect(v.check(root, 'x'), isFalse);
    });
  });

  group('\$ref sibling semantics by draft', () {
    test('draft7 \$ref ignores siblings', () {
      final root = <String, Object?>{
        '\$defs': {
          'n': {'type': 'integer'},
        },
        '\$ref': '#/\$defs/n',
        'minimum': 10,
      };
      final v7 = SchemaValidator(root); // draft7 default
      expect(v7.check(root, 5), isTrue); // minimum ignored
    });

    test('draft2020 \$ref honours siblings', () {
      final root = <String, Object?>{
        '\$defs': {
          'n': {'type': 'integer'},
        },
        '\$ref': '#/\$defs/n',
        'minimum': 10,
      };
      final v = SchemaValidator(root, draft: Draft.draft2020);
      expect(v.check(root, 5), isFalse); // minimum applied
      expect(v.check(root, 15), isTrue);
    });
  });
}
