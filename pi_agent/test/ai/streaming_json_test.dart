// Tests for the streaming JSON machinery ported from upstream
// `packages/ai/src/utils/streaming-json.ts` (parity work in arrrrny/pi#41).
import 'dart:convert';

import 'package:test/test.dart';

import 'package:pi/src/ai/streaming_json.dart';

void main() {
  group('StreamingJsonParser', () {
    test('complete objects parse to plain JSON', () {
      final parser = StreamingJsonParser();
      parser.append('{"a": 1, "b": "two", "c": [true, false, null]}');
      expect(parser.snapshot(), {
        'a': 1,
        'b': 'two',
        'c': [true, false, null],
      });
    });

    test('partial object shows members read so far', () {
      final parser = StreamingJsonParser();
      parser.append('{"name": "she');
      expect(parser.snapshot(), {
        'name': 'she',
      });
      parser.append('ll)", "n": 1');
      expect(parser.snapshot(), {
        'name': 'shell)',
        'n': 1,
      });
    });

    test('unterminated string value shows its text', () {
      final parser = StreamingJsonParser();
      parser.append('{"a": "hel');
      expect(parser.snapshot(), {'a': 'hel'});
    });

    test('unterminated number shows best-effort value', () {
      final parser = StreamingJsonParser();
      // A mantissa without its exponent digits shows nothing yet
      // (pendingScalarValue drops it), matching upstream.
      parser.append('{"a": 1.');
      expect(parser.snapshot(), <String, dynamic>{});
      parser.append('5');
      expect(parser.snapshot(), {'a': 1.5});
    });

    test('unterminated literal prefix shows the literal', () {
      final parser = StreamingJsonParser();
      parser.append('{"a": tru');
      expect(parser.snapshot(), {'a': true});
    });

    test('tolerates missing colon and comma', () {
      final parser = StreamingJsonParser();
      parser.append('{"a" 1 "b": 2}');
      expect(parser.snapshot(), {'a': 1, 'b': 2});
    });

    test('tolerates invalid escapes like repairJson', () {
      final parser = StreamingJsonParser();
      parser.append(String.fromCharCodes([
        0x7b, 0x22, 0x61, 0x22, 0x3a, 0x20, 0x22, 0x5c, 0x71, 0x22,
        0x7d, // {"a": "\q"}
      ]));
      // The backslash stays as text and `q` is read normally.
      expect(parser.snapshot(), {'a': r'\q'});
    });

    test('decodes unicode escapes across appends', () {
      final parser = StreamingJsonParser();
      parser.append('{"a": "b');
      parser.append(String.fromCharCodes([0x5c, 0x75])); // \u
      parser.append('0041"}');
      expect(parser.snapshot(), {'a': 'bA'});
    });

    test('ignores text after the root value', () {
      final parser = StreamingJsonParser();
      parser.append('{"a": 1} trailing');
      expect(parser.snapshot(), {'a': 1});
    });

    test('nested containers snapshot innermost state', () {
      final parser = StreamingJsonParser();
      parser.append('{"list": [{"x": ');
      // The key places nothing until a value starts; the object shows empty.
      expect(parser.snapshot(), {
        'list': [<String, dynamic>{}],
      });
      parser.append('12}]');
      expect(parser.snapshot(), {
        'list': [
          {'x': 12}
        ],
      });
    });

    test('append reports set and append changes', () {
      final parser = StreamingJsonParser();
      // The string start sets the member empty; text appended in the SAME
      // piece extends that set (it is still the newest change).
      final first = parser.append('{"a": "x');
      expect(first.map((c) => c.kind), ['set', 'set']);
      expect((first.whereType<JsonSet>().last).path, ['a']);
      expect((first.whereType<JsonSet>().last).value, 'x');
      // A later piece that extends the string reports an append against
      // the member (the root value is not closed yet).
      final second = parser.append('y');
      final append = second.whereType<JsonAppend>().last;
      expect(append.path, ['a']);
      expect(append.text, 'y');
    });
  });

  group('ToolCallArgumentsStream', () {
    test('append accumulates text and partial arguments', () {
      final stream = ToolCallArgumentsStream();
      final partial = stream.append('{"comma');
      expect(stream.text, '{"comma');
      expect(partial, <String, dynamic>{});
      final partial2 = stream.append('nd": "ls -la"}');
      expect(partial2, {
        'command': 'ls -la',
      });
    });

    test('finish gives the authoritative parse and reports malformed', () {
      final stream = ToolCallArgumentsStream();
      stream.append('{"command": "ls"}');
      final finished = stream.finish();
      expect(finished.argumentsError, isNull);
      expect(finished.arguments, {'command': 'ls'});

      final bad = ToolCallArgumentsStream();
      bad.append('{"command": "ls",,}');
      final badFinished = bad.finish();
      expect(badFinished.argumentsError, isNotNull);
      expect(badFinished.arguments, <String, dynamic>{});
      expect(badFinished.argumentsError, contains('Received arguments:'));
    });

    test('replace extends a continuing prefix', () {
      final stream = ToolCallArgumentsStream();
      stream.append('{"a": ');
      final replaced = stream.replace('{"a": 1}');
      expect(replaced.delta, '1}');
      expect(replaced.arguments, {'a': 1});
    });

    test('replace restarts on a non-prefix', () {
      final stream = ToolCallArgumentsStream();
      stream.append('{"a": 1');
      final replaced = stream.replace('{"b": 2}');
      expect(replaced.delta, isNull);
      expect(replaced.arguments, {'b': 2});
      expect(stream.text, '{"b": 2}');
    });

    test('non-object partial snapshots show as no arguments', () {
      final stream = ToolCallArgumentsStream();
      final partial = stream.append('"just text');
      expect(partial, <String, dynamic>{});
    });

    test('integer numbers stay integers through the snapshot', () {
      final stream = ToolCallArgumentsStream();
      final partial = stream.append('{"count": 12}');
      expect(partial['count'], 12);
      expect(jsonEncode(partial), '{"count":12}');
    });
  });
}
