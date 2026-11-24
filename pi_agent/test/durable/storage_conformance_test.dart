import 'package:pi/durable.dart';
import 'package:test/test.dart';

/// The assertions the shared suite needs, over `package:test`'s matchers.
class _TestAssertions implements ConformanceAssertions {
  @override
  void ok(bool value, [String? message]) =>
      expect(value, isTrue, reason: message);

  @override
  void strictEqual(Object? actual, Object? expected) =>
      expect(actual, equals(expected));

  @override
  void deepEqual(Object? actual, Object? expected) =>
      expect(actual, equals(expected));

  @override
  void partialDeepEqual(Object? actual, Object? expected) =>
      expect(actual, equals(expected));

  @override
  void greaterThan(int actual, int expected) => expect(actual,
      predicate<int>((value) => value > expected, 'greater than $expected'));

  @override
  Future<void> rejects(
      Future<Object?> operation, String messageIncludes) async {
    await expectLater(operation,
        throwsA(predicate((error) => '$error'.contains(messageIncludes))));
  }
}

void main() {
  final assertions = _TestAssertions();

  group('MemoryStorage', () {
    for (final testCase in createStorageConformance()) {
      test(testCase.name, () async {
        final storage = MemoryStorage();
        await testCase.run(storage, assertions);
      });
    }
  });

  group('JsonlStorage', () {
    for (final testCase in createStorageConformance()) {
      test(testCase.name, () async {
        final storage =
            await JsonlStorage(files: InMemoryFileSystem(), path: 'log.jsonl')
                .open();
        await testCase.run(storage, assertions);
      });
    }
  });

  group('SqliteStorage', () {
    for (final testCase in createStorageConformance()) {
      test(testCase.name, () async {
        final storage =
            await SqliteStorage(executor: InMemorySqliteExecutor()).open();
        await testCase.run(storage, assertions);
      });
    }
  });
}
