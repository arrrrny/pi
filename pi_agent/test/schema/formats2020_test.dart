/// Differential parity tests for the draft2020-12 string `format` checks.
///
/// Runs the Dart format checkers against the official JSON-Schema-Test-Suite
/// `validation/tests/format-*.json` fixtures (the merged suite whose groups
/// carry a `compatibility` draft marker). A format's definition is the same
/// across drafts, so every group in a format file is exercised regardless of
/// the draft it was first introduced in. This is the draft2020-12 companion to
/// `formats_test.dart` (which covers the draft-07 optional/format subset).
library;

import 'dart:convert';
import 'dart:io';

import 'package:pi/schema.dart';
import 'package:test/test.dart';

/// A combining mark (any Unicode `M` category); its presence in an idn-email
/// domain means the case needs NFC composition.
final RegExp _combiningMark = RegExp(r'\p{M}', unicode: true);

void main() {
  final dir = Directory('test/schema/fixtures/draft2020-12');
  final files = dir.listSync().whereType<File>().where((f) {
    final name = f.uri.pathSegments.last;
    return name.startsWith('format-') && name.endsWith('.json');
  }).toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  // idn-email cases whose domain carries a combining mark require Unicode NFC
  // composition, which Dart's core does not provide (pi#53 divergence). They
  // are counted here so the skip is explicit, never a silent pass.
  var nfcDomainSkipped = 0;

  test('format fixtures exist', () {
    expect(files, isNotEmpty);
  });

  for (final file in files) {
    test('${file.uri.pathSegments.last} matches the test suite', () {
      final doc = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final groups =
          (doc['tests'] as List<Object?>).cast<Map<String, Object?>>();
      var cases = 0;
      for (final group in groups) {
        // `format-annotation` groups assert the draft default (format is a
        // non-assertive annotation), so every value is "valid" there; only the
        // `format-assertion` and untagged groups exercise the checker.
        final tags =
            (group['tags'] as List<Object?>?)?.cast<String>() ?? const [];
        if (tags.contains('format-annotation')) continue;
        final schema = group['schema'] as Map<String, Object?>;
        final name = schema['format'] as String;
        for (final t
            in (group['tests'] as List<Object?>).cast<Map<String, Object?>>()) {
          final data = t['data'];
          final expected = t['valid'] as bool;
          if (name == 'idn-email' && data is String) {
            final at = data.lastIndexOf('@');
            final domain = at >= 0 ? data.substring(at + 1) : data;
            if (_combiningMark.hasMatch(domain)) {
              nfcDomainSkipped++;
              continue;
            }
          }
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

  test('idn-email NFC-domain cases were skipped, not silently passed', () {
    expect(nfcDomainSkipped, greaterThan(0));
  });
}
