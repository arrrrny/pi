import 'package:pi/src/codemode_source.dart';
import 'package:pi/tools.dart' as public_api;
import 'package:test/test.dart';

void main() {
  // The parser is advertised as the public `package:pi/tools.dart` surface
  // (CHANGELOG + commit message); exercise that re-export, not just the
  // private path the rest of this suite imports.
  test('parser is reachable through package:pi/tools.dart', () {
    expect(
      public_api.parseCodemodeSource('text(1)'),
      equals(const ParsedCodemodeSource(
          code: 'text(1)', options: CodemodeSourceOptions())),
    );
  });

  group('parseCodemodeSource', () {
    test('returns plain code unchanged', () {
      expect(
          parseCodemodeSource("text('hi')"),
          equals(const ParsedCodemodeSource(
              code: "text('hi')", options: CodemodeSourceOptions())));
      expect(
          parseCodemodeSource('// just a comment\nreturn 1'),
          equals(const ParsedCodemodeSource(
              code: '// just a comment\nreturn 1',
              options: CodemodeSourceOptions())));
    });

    test('parses the options line and keeps line numbers', () {
      expect(
          parseCodemodeSource(
              '// @options: {"timeout_ms": 10}\nconst a = 1;\ntext(a)'),
          equals(const ParsedCodemodeSource(
              code: '\nconst a = 1;\ntext(a)',
              options: CodemodeSourceOptions(timeoutMs: 10))));
      expect(
          parseCodemodeSource(
                  '  // @options:{"max_output_tokens":0,"timeout_ms":1500}\r\ntext(1)')
              .options,
          equals(const CodemodeSourceOptions(
              maxOutputTokens: 0, timeoutMs: 1500)));
      expect(
          parseCodemodeSource('// @options: {}\ntext(1)'),
          equals(const ParsedCodemodeSource(
              code: '\ntext(1)', options: CodemodeSourceOptions())));
    });

    test('only treats the first line as an options line', () {
      expect(parseCodemodeSource('// @optionsx {}\ntext(1)').options,
          equals(const CodemodeSourceOptions()));
      expect(parseCodemodeSource('text("// @options: {}")').options,
          equals(const CodemodeSourceOptions()));
    });

    // #10631: an options line after the first line used to be ignored.
    test('rejects an options line that is not the first line', () {
      const cases = <List<Object>>[
        [
          '// count things\n// @options: {"timeout_ms": 1000}\nwhile (true) {}',
          2
        ],
        ['\n  // @options: {"timeout_ms": 1000}\nwhile (true) {}', 2],
        ['text(1)\r\n// @options: {"timeout_ms": 1}', 2],
        [
          '// @options: {"timeout_ms": 1}\ntext(1)\n// @options: {"timeout_ms": 2}',
          3
        ],
      ];
      for (final c in cases) {
        final input = c[0] as String;
        final line = c[1] as int;
        expect(() => parseCodemodeSource(input),
            throwsA(isA<CodemodeSourceError>()),
            reason: input);
        expect(
            () => parseCodemodeSource(input),
            throwsA(isA<CodemodeSourceError>().having(
                (e) => e.message,
                'message',
                'The $codeModeOptionsPrefix line must be the first line of the input; found one on line $line')),
            reason: input);
      }
    });

    test('rejects empty input and invalid options', () {
      expect(
          () => parseCodemodeSource(''),
          throwsA(predicate<CodemodeSourceError>((e) => e.message
              .contains('Expected JavaScript source text (non-empty)'))));
      expect(
          () => parseCodemodeSource('  \n'),
          throwsA(predicate<CodemodeSourceError>((e) => e.message
              .contains('Expected JavaScript source text (non-empty)'))));
      expect(
          () => parseCodemodeSource('// @options:\ntext(1)'),
          throwsA(predicate<CodemodeSourceError>((e) => e.message.contains(
              '@options must be a JSON object with supported fields'))));
      expect(
          () => parseCodemodeSource('// @options: {timeout_ms: 1}\ntext(1)'),
          throwsA(predicate<CodemodeSourceError>((e) => e.message
              .contains('@options must be valid JSON with supported fields'))));
      expect(
          () => parseCodemodeSource('// @options: [1]\ntext(1)'),
          throwsA(predicate<CodemodeSourceError>((e) => e.message.contains(
              '@options must be a JSON object with supported fields'))));
      expect(
          () => parseCodemodeSource('// @options: {"yield": 1}\ntext(1)'),
          throwsA(predicate<CodemodeSourceError>((e) => e.message.contains(
              '@options only supports `max_output_tokens` and `timeout_ms`; got `yield`'))));
      expect(
          () => parseCodemodeSource(
              '// @options: {"max_output_tokens": 1.5}\ntext(1)'),
          throwsA(predicate<CodemodeSourceError>((e) => e.message.contains(
              '@options field `max_output_tokens` must be a non-negative safe integer'))));
      expect(
          () => parseCodemodeSource('// @options: {"timeout_ms": 0}\ntext(1)'),
          throwsA(predicate<CodemodeSourceError>((e) => e.message.contains(
              '@options field `timeout_ms` must be a positive integer'))));
      expect(
          () => parseCodemodeSource('// @options: {"timeout_ms": 1}'),
          throwsA(predicate<CodemodeSourceError>((e) => e.message.contains(
              'The @options line must be followed by JavaScript source on subsequent lines'))));
      expect(
          () => parseCodemodeSource('// @options: {"timeout_ms": 1}\n  \n'),
          throwsA(predicate<CodemodeSourceError>((e) => e.message.contains(
              'The @options line must be followed by JavaScript source on subsequent lines'))));
    });
  });
}
