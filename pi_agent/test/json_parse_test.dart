import 'package:test/test.dart';
import 'package:pi/src/json_parse.dart';

// Mirrors packages/ai/test/json-parse.test.ts (upstream #10897) for pi#4.
void main() {
  group('repairJson', () {
    test('doubles backslashes before invalid escape characters', () {
      expect(
        repairJson(r'{"note":"\url"}'),
        r'{"note":"\\url"}',
      );
    });

    test('escapes raw control characters inside strings', () {
      expect(
        repairJson('{"text":"a\nb"}'),
        r'{"text":"a\nb"}',
      );
    });

    test('keeps valid escapes untouched', () {
      expect(repairJson(r'{"text":"caf\u00e9"}'), r'{"text":"caf\u00e9"}');
    });
  });

  group('parseToolCallArguments', () {
    test('parses complete JSON and repairs invalid escapes', () {
      final result = parseToolCallArguments(r'{"kind":"seek","note":"\url"}');
      expect(result.arguments, {'kind': 'seek', 'note': r'\url'});
      expect(result.argumentsError, isNull);
    });

    test('escapes raw control characters instead of failing', () {
      final result = parseToolCallArguments('{"text":"a\nb"}');
      expect(result.arguments, {'text': 'a\nb'});
      expect(result.argumentsError, isNull);
    });

    test('uses empty arguments for empty text', () {
      expect(parseToolCallArguments(null).arguments, {});
      expect(parseToolCallArguments(null).argumentsError, isNull);
      expect(parseToolCallArguments('').arguments, {});
      expect(parseToolCallArguments('   ').argumentsError, isNull);
    });

    test('does not keep the valid prefix of malformed JSON', () {
      const raw = '{"action":"apply","actions":[{"kind":"seek","time":.5}]}';
      final result = parseToolCallArguments(raw);
      expect(result.arguments, {});
      expect(result.argumentsError, contains('\n\nReceived arguments:\n'));
      expect(result.argumentsError!.endsWith(raw), isTrue);
    });

    test('does not complete cut-off JSON', () {
      const raw = '{"kind":"seek","clipId":"clip-fl';
      final result = parseToolCallArguments(raw);
      expect(result.arguments, {});
      expect(result.argumentsError!.endsWith(raw), isTrue);
    });

    test('rejects JSON that is not an object', () {
      final result = parseToolCallArguments('[1,2]');
      expect(result.arguments, {});
      expect(
        result.argumentsError,
        'Tool arguments must be a JSON object\n\nReceived arguments:\n[1,2]',
      );
    });

    test('rejects scalar roots', () {
      for (final raw in ['42', '"x"', 'true', 'null']) {
        final result = parseToolCallArguments(raw);
        expect(result.arguments, {}, reason: raw);
        expect(
          result.argumentsError,
          'Tool arguments must be a JSON object'
          '\n\nReceived arguments:\n$raw',
          reason: raw,
        );
      }
    });
  });
}
