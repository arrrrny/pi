/// Differential parity tests for the JSON Schema validator.
///
/// Runs the Dart [SchemaValidator] against the official JSON-Schema-Test-Suite
/// draft-07 fixtures bundled under `test/schema/fixtures/draft7`. The upstream
/// TypeScript `packages/schema/test/conformance.test.ts` runs the same corpus,
/// so a passing run proves the Dart port returns the same valid/invalid verdict
/// as the TypeScript oracle for every case in the supported keyword set.
library;

import 'dart:convert';
import 'dart:io';

import 'package:pi/schema.dart';
import 'package:test/test.dart';

void main() {
  final dir = Directory('test/schema/fixtures/draft7');
  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('fixtures exist', () {
    expect(files, isNotEmpty);
  });

  for (final file in files) {
    test('${file.uri.pathSegments.last} matches the test suite', () {
      final groups = (jsonDecode(file.readAsStringSync()) as List<Object?>)
          .cast<Map<String, Object?>>();
      var cases = 0;
      for (final group in groups) {
        final schema = group['schema'];
        final root =
            schema is Map<String, Object?> ? schema : <String, Object?>{};
        final validator = SchemaValidator(root);
        final tests =
            (group['tests'] as List<Object?>).cast<Map<String, Object?>>();
        for (final t in tests) {
          final data = t['data'];
          final expected = t['valid'] as bool;
          final actual = validator.check(schema, data);
          expect(actual, expected,
              reason: '${group['description']} / ${t['description']}');
          cases++;
        }
      }
      expect(cases, greaterThan(0));
    });
  }
}
