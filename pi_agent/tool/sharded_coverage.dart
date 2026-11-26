// Sharded Dart coverage runner (issue #38).
//
// A single `dart test --coverage` over the whole suite pays one heavy
// compile/startup cost and then runs every test in one process. Under host CPU
// starvation that wall-clock cost balloons past any bounded budget (the reported
// failure was killed at 900s with load average ~540, no test failing), and a
// monolithic run that is killed loses ALL of its coverage. Sharding the suite
// into several bounded `dart test` targets, each writing its own `--coverage`
// directory, lets every target finish inside a single bounded invocation; the
// per-shard coverage JSON files then merge into one lcov report. A shard that
// completes keeps its coverage on disk, so an interrupted sweep resumes by
// re-running only the missing shards.
//
// `planShards` is the pure, deterministic core: it partitions the discovered
// test files into a fixed number of balanced shards with every file assigned
// exactly once. The rest (`main`) discovers the files and runs shards.
//
// Per-shard bounded workflow (each invocation fits one budget):
//   dart run tool/sharded_coverage.dart --shards 4 --only 0 --timeout 900
//   dart run tool/sharded_coverage.dart --shards 4 --only 1 --timeout 900
//   ... (one per shard) ...
//   dart run tool/sharded_coverage.dart --merge-only
// With no `--only`, all shards run sequentially in one invocation and merge.
//
// Dev-only: not exported from `package:pi/pi.dart`, not part of the published
// surface, and adds no dependency to `pi_agent/pubspec.yaml` — it uses
// `dart:io`/`dart:async` only and shells out to the `coverage` package already
// resolved transitively by `package:test`.

import 'dart:async';
import 'dart:io';

/// Partition [files] into [shardCount] balanced shards.
///
/// Every file is assigned to exactly one shard; shard sizes differ by at most
/// one; the result is deterministic for the same input. [shardCount] is capped
/// at [files.length] so no shard is empty. Throws [ArgumentError] when
/// [shardCount] is not positive.
List<List<String>> planShards(List<String> files, int shardCount) {
  if (shardCount <= 0) {
    throw ArgumentError.value(shardCount, 'shardCount', 'must be positive');
  }
  final count = shardCount < files.length ? shardCount : files.length;
  final shards = List<List<String>>.generate(count, (_) => <String>[]);
  for (var i = 0; i < files.length; i++) {
    shards[i % count].add(files[i]);
  }
  return shards;
}

/// Discover `*_test.dart` files under [root] (recursive), sorted for
/// determinism.
List<String> discoverTestFiles(String root) {
  final files = <String>[];
  for (final entity in Directory(root).listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('_test.dart')) {
      files.add(entity.path);
    }
  }
  files.sort();
  return files;
}

/// Merge every per-shard coverage JSON under [coverageRoot] into one lcov
/// report. `package:coverage` reads the directory recursively, so all
/// `shard-N/` subdirectories are combined in a single pass.
Future<void> mergeCoverage(String coverageRoot) async {
  stdout.writeln('merging coverage from $coverageRoot ...');
  final result = await Process.run('dart', <String>[
    'run',
    'coverage:format_coverage',
    '--in',
    coverageRoot,
    '--out',
    '$coverageRoot/lcov.info',
    '--report-on',
    'lib',
    '--lcov',
  ]);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    stderr.writeln('coverage merge failed (exit ${result.exitCode})');
    exit(result.exitCode);
  }
  stdout.writeln('coverage written to $coverageRoot/lcov.info');
}

Future<void> main(List<String> args) async {
  var shardCount = 4;
  var timeoutSeconds = 900;
  int? only;
  var mergeOnly = false;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--shards':
        shardCount = int.parse(args[++i]);
      case '--timeout':
        timeoutSeconds = int.parse(args[++i]);
      case '--only':
        only = int.parse(args[++i]);
      case '--merge-only':
        mergeOnly = true;
      default:
        stderr.writeln('unknown argument: ${args[i]}');
        exit(64);
    }
  }

  final coverageRoot = 'coverage';
  if (mergeOnly) {
    await mergeCoverage(coverageRoot);
    return;
  }

  final files = discoverTestFiles('test');
  if (files.isEmpty) {
    stderr.writeln('no test files found under test');
    exit(1);
  }

  final shards = planShards(files, shardCount);
  Directory(coverageRoot).createSync(recursive: true);

  final indices =
      only != null ? <int>[only] : List<int>.generate(shards.length, (i) => i);
  for (final s in indices) {
    if (s < 0 || s >= shards.length) {
      stderr.writeln(
        'shard index $s out of range (0..${shards.length - 1})',
      );
      exit(64);
    }
    final shard = shards[s];
    stdout.writeln(
      'shard ${s + 1}/${shards.length}: ${shard.length} file(s), '
      'timeout ${timeoutSeconds}s',
    );
    final process = await Process.start(
      'dart',
      <String>['test', ...shard, '--coverage=$coverageRoot/shard-$s'],
      mode: ProcessStartMode.inheritStdio,
    );
    Timer? timer;
    if (timeoutSeconds > 0) {
      timer = Timer(Duration(seconds: timeoutSeconds), () {
        stderr.writeln('shard ${s + 1} timed out after ${timeoutSeconds}s');
        process.kill(ProcessSignal.sigkill);
      });
    }
    final code = await process.exitCode;
    timer?.cancel();
    if (code != 0) {
      stderr.writeln('shard ${s + 1} failed (exit $code); not merging');
      exit(code);
    }
  }

  if (only != null) {
    stdout.writeln(
      'shard $only complete; run --merge-only once every shard is done',
    );
    return;
  }
  await mergeCoverage(coverageRoot);
}
