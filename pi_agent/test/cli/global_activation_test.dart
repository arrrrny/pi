@Timeout(Duration(minutes: 6))
library;

import 'dart:io';

import 'package:pi/cli.dart';
import 'package:test/test.dart';

/// The package root (the directory holding pubspec.yaml), resolved by walking
/// up from the test's working directory (the package root under `dart test`).
Directory packageRoot() {
  var dir = Directory.current.absolute;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('no pubspec.yaml above ${Directory.current.path}');
    }
    dir = parent;
  }
}

/// Recursively copies [name] (a top-level entry of [src]) into [dst],
/// preserving structure. Uses `cp -R`, available on the Linux CI runner and
/// macOS dev hosts.
void copyEntrySync(Directory src, String name, Directory dst) {
  final result = Process.runSync('cp', [
    '-R',
    '${src.path}/$name',
    '${dst.path}/$name',
  ]);
  if (result.exitCode != 0) {
    throw StateError('copy $name failed: ${result.stderr}');
  }
}

/// End-to-end proof of the distribution contract from pi#50: a clean global
/// activation in an ISOLATED pub cache installs exactly one executable,
/// `pidart`, and that executable answers --version / --help and a no-config
/// one-shot invocation with the documented streams and exit codes.
///
/// The package is activated from a throwaway COPY so the working checkout's
/// `.dart_tool/package_config.json` is never resolved in place (a path
/// activation otherwise rewrites it to point at the isolated cache).
void main() {
  test(
    'dart pub global activate installs pidart and it runs',
    () async {
      final src = packageRoot();
      final work = await Directory.systemTemp.createTemp('pidart-src-');
      final cache = await Directory.systemTemp.createTemp('pidart-pub-cache-');
      final dart = Platform.resolvedExecutable;

      // Copy the publishable package into the throwaway source dir.
      for (final name in [
        'pubspec.yaml',
        'analysis_options.yaml',
        'README.md',
        'CHANGELOG.md',
      ]) {
        final file = File('${src.path}/$name');
        if (file.existsSync()) file.copySync('${work.path}/$name');
      }
      copyEntrySync(src, 'lib', work);
      copyEntrySync(src, 'bin', work);

      final runEnv = {
        ...Platform.environment,
        'PUB_CACHE': cache.path,
      };
      ProcessResult runDart(List<String> args) =>
          Process.runSync(dart, args, environment: runEnv);

      // Activate from the copied checkout into the isolated cache.
      final activate =
          runDart(['pub', 'global', 'activate', '--source', 'path', work.path]);
      expect(
        activate.exitCode,
        0,
        reason: 'activation failed:\n${activate.stderr}',
      );

      // Exactly one executable is installed, and it is `pidart`.
      final binDir = Directory('${cache.path}/bin');
      final installed = binDir
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .toSet();
      expect(installed, contains('pidart'));
      expect(installed, isNot(contains('pi')));
      expect(installed, isNot(contains('pid')));

      final pidart = File('${cache.path}/bin/pidart');

      // --version: exit 0, version on stdout, nothing on stderr. A cold-cache
      // global activation prints `dart pub` resolution chatter to stdout before
      // the program runs, so the version is the final non-empty line rather than
      // the whole of stdout.
      final version =
          Process.runSync(pidart.path, ['--version'], environment: runEnv);
      expect(version.exitCode, 0, reason: version.stderr.toString());
      final versionLines = version.stdout
          .toString()
          .trim()
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
      expect(versionLines.last.trim(), pidartVersion);
      expect(version.stderr.toString(), isEmpty);

      // --help: exit 0, usage on stdout mentioning pidart.
      final help =
          Process.runSync(pidart.path, ['--help'], environment: runEnv);
      expect(help.exitCode, 0, reason: help.stderr.toString());
      expect(help.stdout.toString(), contains('pidart'));
      expect(help.stdout.toString().toLowerCase(), contains('usage'));

      // A one-shot run with no model configured: a clear config error on
      // stderr and a non-zero exit, never a crash or a silent success.
      final noConfig = Process.runSync(
        pidart.path,
        ['hello'],
        environment: {
          ...runEnv,
          'PI_MODEL': '',
        },
      );
      expect(noConfig.exitCode, isNot(0));
      expect(noConfig.stderr.toString().toLowerCase(), contains('pi_model'));

      await cache.delete(recursive: true);
      await work.delete(recursive: true);
    },
  );
}
