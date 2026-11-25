// Usage ledger arithmetic: per-model and per-tool token/cost totals.
//
// Port of the pure data layer of `packages/durable/src/harness/usage.ts` at
// upstream `780bf31fcaeb252fa9b68df3964c735eae75bde3` (`UsageState`, `addUsage`,
// `addUsageState`). The `defineDoc` wiring (`UsageDoc`, `recordUsage`) is left to
// the layer that ports `documents.dart`; this file is the testable arithmetic
// core, faithful to upstream's counter-by-counter addition.

import 'package:pi/durable.dart';
import 'package:test/test.dart';

Usage _usage({
  int input = 0,
  int output = 0,
  int cacheRead = 0,
  int cacheWrite = 0,
  int totalTokens = 0,
  int? cacheWrite1h,
  int? reasoning,
  int costInput = 0,
  int costOutput = 0,
  int costCacheRead = 0,
  int costCacheWrite = 0,
  int costTotal = 0,
}) =>
    Usage(
      input: input,
      output: output,
      cacheRead: cacheRead,
      cacheWrite: cacheWrite,
      totalTokens: totalTokens,
      cacheWrite1h: cacheWrite1h,
      reasoning: reasoning,
      cost: UsageCost(
        input: costInput,
        output: costOutput,
        cacheRead: costCacheRead,
        cacheWrite: costCacheWrite,
        total: costTotal,
      ),
    );

void main() {
  group('addUsage', () {
    test('adds every required counter', () {
      final total = _usage(
        input: 1,
        output: 2,
        cacheRead: 3,
        cacheWrite: 4,
        totalTokens: 10,
        costInput: 5,
        costOutput: 6,
        costCacheRead: 7,
        costCacheWrite: 8,
        costTotal: 26,
      );
      addUsage(
        total,
        _usage(
          input: 10,
          output: 20,
          cacheRead: 30,
          cacheWrite: 40,
          totalTokens: 100,
          costInput: 50,
          costOutput: 60,
          costCacheRead: 70,
          costCacheWrite: 80,
          costTotal: 260,
        ),
      );
      expect(total.input, 11);
      expect(total.output, 22);
      expect(total.cacheRead, 33);
      expect(total.cacheWrite, 44);
      expect(total.totalTokens, 110);
      expect(total.cost.input, 55);
      expect(total.cost.output, 66);
      expect(total.cost.cacheRead, 77);
      expect(total.cost.cacheWrite, 88);
      expect(total.cost.total, 286);
    });

    test('optional counters add once either side reports them', () {
      final total = _usage(input: 1);
      addUsage(total, _usage(input: 1, cacheWrite1h: 5, reasoning: 3));
      expect(total.cacheWrite1h, 5);
      expect(total.reasoning, 3);
      addUsage(total, _usage(input: 1, cacheWrite1h: 2, reasoning: 4));
      expect(total.cacheWrite1h, 7);
      expect(total.reasoning, 7);
    });

    test('optional counters stay absent when neither side reports them', () {
      final total = _usage(input: 1);
      addUsage(total, _usage(input: 1));
      expect(total.cacheWrite1h, isNull);
      expect(total.reasoning, isNull);
    });
  });

  group('UsageState.fromJson', () {
    test('missing models/tools buckets decode to empty ledgers', () {
      final decoded = UsageState.fromJson(<String, Object?>{});
      expect(decoded.models, isEmpty);
      expect(decoded.tools, isEmpty);
    });

    test('present buckets still decode their entries', () {
      final decoded = UsageState.fromJson(<String, Object?>{
        'models': <String, Object?>{
          'p/m': <String, Object?>{
            'input': 1,
            'output': 2,
            'cacheRead': 3,
            'cacheWrite': 4,
            'totalTokens': 5,
            'cost': <String, Object?>{'total': 6},
          },
        },
      });
      expect(decoded.models['p/m']!.input, 1);
      expect(decoded.models['p/m']!.cost.total, 6);
      expect(decoded.tools, isEmpty);
    });
  });

  group('addUsageState', () {
    test('merges per-model and per-tool buckets', () {
      final sum = UsageState();
      addUsageState(
          sum,
          UsageState(models: <String, Usage>{
            'p/m': _usage(input: 1, totalTokens: 1),
          }, tools: <String, Usage>{
            'bash': _usage(output: 2, totalTokens: 2),
          }));
      addUsageState(
          sum,
          UsageState(models: <String, Usage>{
            'p/m': _usage(input: 10, totalTokens: 10),
          }, tools: <String, Usage>{
            'bash': _usage(output: 20, totalTokens: 20),
          }));
      expect(sum.models['p/m']!.input, 11);
      expect(sum.models['p/m']!.totalTokens, 11);
      expect(sum.tools['bash']!.output, 22);
      expect(sum.tools['bash']!.totalTokens, 22);
    });

    test('copies a key the sum does not yet hold', () {
      final sum = UsageState();
      addUsageState(
          sum,
          UsageState(models: <String, Usage>{
            'p/m': _usage(input: 5, totalTokens: 5),
          }));
      expect(sum.models['p/m']!.input, 5);
    });

    test('a new key is deep-copied, never aliased to the source ledger', () {
      final source = UsageState(models: <String, Usage>{
        'p/m': _usage(input: 5, totalTokens: 5, costTotal: 2),
      });
      final sum = UsageState();
      addUsageState(sum, source);

      // Mutating the sum's entry must not reach the source (upstream's
      // structuredClone), including its nested mutable cost.
      addUsage(sum.models['p/m']!, _usage(input: 1, costTotal: 1));
      expect(sum.models['p/m']!.input, 6);
      expect(sum.models['p/m']!.cost.total, 3);
      expect(source.models['p/m']!.input, 5);
      expect(source.models['p/m']!.cost.total, 2);
    });

    test('a tool named __proto__ is an ordinary key', () {
      final sum = UsageState();
      addUsageState(
          sum,
          UsageState(tools: <String, Usage>{
            '__proto__': _usage(output: 1),
          }));
      expect(sum.tools['__proto__']!.output, 1);
    });
  });
}
