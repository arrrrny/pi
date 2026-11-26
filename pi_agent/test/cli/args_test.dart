import 'package:pi/cli.dart';
import 'package:test/test.dart';

void main() {
  group('parsePidartArgs', () {
    test('no args selects interactive mode', () {
      final args = parsePidartArgs([]);
      expect(args.mode, PidartMode.interactive);
      expect(args.prompt, isNull);
    });

    test('--help and -h select help mode', () {
      expect(parsePidartArgs(['--help']).mode, PidartMode.help);
      expect(parsePidartArgs(['-h']).mode, PidartMode.help);
    });

    test('--version and -v select version mode', () {
      expect(parsePidartArgs(['--version']).mode, PidartMode.version);
      expect(parsePidartArgs(['-v']).mode, PidartMode.version);
    });

    test('positional words join into a one-shot prompt', () {
      final args = parsePidartArgs(['hello', 'world']);
      expect(args.mode, PidartMode.oneShot);
      expect(args.prompt, 'hello world');
    });

    test('a single positional is a one-shot prompt', () {
      final args = parsePidartArgs(['summarize this repo']);
      expect(args.mode, PidartMode.oneShot);
      expect(args.prompt, 'summarize this repo');
    });

    test('"--", with nothing after it, stays interactive', () {
      expect(parsePidartArgs(['--']).mode, PidartMode.interactive);
    });

    test('"--", makes the rest positional even if it looks like a flag', () {
      final args = parsePidartArgs(['--', '--help']);
      expect(args.mode, PidartMode.oneShot);
      expect(args.prompt, '--help');
    });

    test('an unknown flag is an error naming the flag', () {
      final args = parsePidartArgs(['--nope']);
      expect(args.mode, PidartMode.error);
      expect(args.error, contains('--nope'));
    });
  });

  group('version constant', () {
    test('pidartVersion is a non-empty semantic version', () {
      expect(pidartVersion, matches(RegExp(r'^\d+\.\d+\.\d+')));
    });
  });
}
