/// Differential parity tests for string `format` checks.
///
/// Runs the Dart format checkers against the official JSON-Schema-Test-Suite
/// draft-07 optional/format fixtures, matching the upstream TypeScript format
/// validators for the ported format set.
library;

import 'dart:convert';
import 'dart:io';

import 'package:pi/schema.dart';
import 'package:test/test.dart';

void main() {
  final dir = Directory('test/schema/fixtures/draft7/optional/format');
  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('format fixtures exist', () {
    expect(files, isNotEmpty);
  });

  for (final file in files) {
    test('${file.uri.pathSegments.last} matches the test suite', () {
      final groups = (jsonDecode(file.readAsStringSync()) as List<Object?>)
          .cast<Map<String, Object?>>();
      var cases = 0;
      for (final group in groups) {
        final schema = group['schema'] as Map<String, Object?>;
        final name = schema['format'] as String;
        for (final t
            in (group['tests'] as List<Object?>).cast<Map<String, Object?>>()) {
          final data = t['data'];
          final expected = t['valid'] as bool;
          // `format` only constrains strings; non-string data is always valid.
          final actual = data is String ? checkFormat(name, data) : true;
          expect(actual, isNotNull, reason: 'unknown format $name');
          expect(actual, expected,
              reason: '${group['description']} / ${t['description']}');
          cases++;
        }
      }
      expect(cases, greaterThan(0));
    });
  }
}
