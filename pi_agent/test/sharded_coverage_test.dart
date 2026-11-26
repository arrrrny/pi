// Tests for the sharded coverage planner (issue #38).
//
// The full `dart test --coverage` run exceeds a bounded wall-clock budget under
// host CPU starvation because every `dart test` invocation pays a heavy
// compile/startup cost that balloons when the host is loaded. Sharding the suite
// into several bounded `dart test` targets, each with its own `--coverage`
// directory, lets every target finish inside the budget; the per-shard coverage
// JSON files then merge into one report. `planShards` is the pure core of that
// runner: it partitions the discovered test files into a fixed number of
// balanced shards, deterministically, with every file assigned exactly once.

import 'package:test/test.dart';

import '../tool/sharded_coverage.dart';

void main() {
  group('planShards', () {
    test('assigns every file exactly once', () {
      final files = <String>[
        'test/a_test.dart',
        'test/b_test.dart',
        'test/c_test.dart',
        'test/d_test.dart',
        'test/e_test.dart',
      ];
      final shards = planShards(files, 2);
      final flat = shards.expand((s) => s).toList();
      expect(flat.length, files.length);
      expect(flat.toSet().length, files.length);
      expect(flat.toSet(), files.toSet());
    });

    test('produces the requested number of non-empty shards', () {
      final files = List<String>.generate(7, (i) => 'test/t${i}_test.dart');
      final shards = planShards(files, 3);
      expect(shards.length, 3);
      for (final shard in shards) {
        expect(shard, isNotEmpty);
      }
    });

    test('balances shard sizes to within one file', () {
      final files = List<String>.generate(10, (i) => 'test/t${i}_test.dart');
      final shards = planShards(files, 3);
      final sizes = shards.map((s) => s.length).toList();
      final largest = sizes.reduce((a, b) => a > b ? a : b);
      final smallest = sizes.reduce((a, b) => a < b ? a : b);
      expect(largest - smallest, lessThanOrEqualTo(1));
    });

    test('is deterministic for the same input', () {
      final files = List<String>.generate(8, (i) => 'test/t${i}_test.dart');
      expect(planShards(files, 3), planShards(files, 3));
    });

    test('caps the shard count at the number of files', () {
      final files = <String>['test/a_test.dart', 'test/b_test.dart'];
      final shards = planShards(files, 8);
      expect(shards.length, 2);
      for (final shard in shards) {
        expect(shard, isNotEmpty);
      }
    });

    test('throws on a non-positive shard count', () {
      expect(
        () => planShards(<String>['test/a_test.dart'], 0),
        throwsArgumentError,
      );
    });
  });
}
