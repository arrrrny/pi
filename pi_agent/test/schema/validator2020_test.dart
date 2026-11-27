/// Differential parity tests for the draft2020-12 validator keywords.
///
/// Runs the Dart [SchemaValidator] against the official JSON-Schema-Test-Suite
/// `validation/tests/*.json` fixtures for the keywords ported in pi#53:
/// `prefixItems`, `dependentRequired`, `dependentSchemas`, `contains` /
/// `minContains` / `maxContains`, `unevaluatedItems`, `unevaluatedProperties`,
/// and `vocabulary`. The merged suite marks each group with a `compatibility`
/// draft expression; only groups applicable to draft2020-12 are exercised.
///
/// Groups whose schema reaches a REMOTE document (`$ref`/`$dynamicRef` to a
/// non-`#` URI) are skipped: the Dart validator resolves local pointers only,
/// and remote resolution is tracked separately (pi#53). The skip is counted so
/// the run never silently passes by exercising nothing.
library;

import 'dart:convert';
import 'dart:io';

import 'package:pi/schema.dart';
import 'package:test/test.dart';

/// The keyword fixture files this suite covers (the draft2020-12 port slice).
///
/// `vocabulary.json` is intentionally excluded: its 2020-12 groups only test
/// that a custom (remote) `$schema` metaschema activates or disables a
/// vocabulary, which needs that remote metaschema. `vocabulary` itself is an
/// annotation-only keyword the validator ignores; `$anchor`/`$dynamicAnchor`/
/// `$dynamicRef` local resolution is covered by `anchor_dynamicref_test.dart`.
const _files = <String>[
  'items.json', // prefixItems
  'dependentRequired.json',
  'dependentSchemas.json',
  'contains.json', // contains / minContains / maxContains
  'unevaluatedItems.json',
  'unevaluatedProperties.json',
];

/// Whether a group's `compatibility` marker applies to draft2020-12.
///
/// The suite uses `2020`/`=2020` for 2020-12, bare `2019` for "2019 and
/// later" (still true in 2020-12), and `=2019`, `9999`, `<=7`, `6`, `7`, … for
/// drafts that are NOT 2020-12. A group with no marker applies to every draft.
bool _appliesTo2020(Object? compatibility) {
  if (compatibility == null) return true;
  final tokens =
      (compatibility as String).split(',').map((t) => t.trim()).toSet();
  return tokens.any((t) => t == '2020' || t == '=2020' || t == '2019');
}

/// Whether [schema] contains a remote (`$ref`/`$dynamicRef`) reference, or a
/// `$schema` that points at a non-standard (remote) metaschema.
bool _hasRemoteRef(Object? schema) {
  if (schema is Map<String, Object?>) {
    for (final entry in schema.entries) {
      if ((entry.key == '\$ref' || entry.key == '\$dynamicRef') &&
          entry.value is String &&
          !(entry.value as String).startsWith('#')) {
        return true;
      }
      if (entry.key == '\$schema' &&
          entry.value is String &&
          (entry.value as String).startsWith('http')) {
        return true;
      }
      if (_hasRemoteRef(entry.value)) return true;
    }
  } else if (schema is List<Object?>) {
    for (final item in schema) {
      if (_hasRemoteRef(item)) return true;
    }
  }
  return false;
}

void main() {
  final dir = Directory('test/schema/fixtures/draft2020-12');
  var skippedRemote = 0;

  test('fixtures exist', () {
    for (final name in _files) {
      expect(File('${dir.path}/$name').existsSync(), isTrue,
          reason: 'missing fixture $name');
    }
  });

  for (final name in _files) {
    test('$name matches the test suite (draft2020-12)', () {
      final doc = jsonDecode(File('${dir.path}/$name').readAsStringSync())
          as Map<String, Object?>;
      final groups =
          (doc['tests'] as List<Object?>).cast<Map<String, Object?>>();
      var cases = 0;
      for (final group in groups) {
        if (!_appliesTo2020(group['compatibility'])) continue;
        final schema = group['schema'];
        if (_hasRemoteRef(schema)) {
          skippedRemote++;
          continue;
        }
        final root =
            schema is Map<String, Object?> ? schema : <String, Object?>{};
        final validator = SchemaValidator(root, draft: Draft.draft2020);
        for (final t
            in (group['tests'] as List<Object?>).cast<Map<String, Object?>>()) {
          final data = t['data'];
          final expected = t['valid'] as bool;
          final actual = validator.check(schema, data);
          expect(actual, expected,
              reason: '${group['description']} / ${t['description']}');
          cases++;
        }
      }
      expect(cases, greaterThan(0),
          reason: '$name exercised no draft2020-12 cases');
    });
  }

  test('remote-ref groups were skipped, not silently passed', () {
    // The local-only validator cannot resolve remote documents; the skip is
    // counted so the run never silently passes by exercising nothing. A real
    // lower bound (mirroring formats2020_test.dart's `nfcDomainSkipped > 0`)
    // guards the accounting: the covered fixtures carry remote-ref groups, so
    // zero skips would mean the skip path itself regressed.
    expect(skippedRemote, greaterThan(0));
  });
}
