// Usage ledger arithmetic: per-model and per-tool token/cost totals.
//
// Port of the pure data layer of `packages/durable/src/harness/usage.ts` at
// upstream `780bf31fcaeb252fa9b68df3964c735eae75bde3`. `UsageState`, `addUsage`
// and `addUsageState` are ported counter for counter. The `defineDoc` wiring
// (`UsageDoc`, `recordUsage`) depends on `documents.dart`, which the pi#11
// foundation slice did not land; it is left to the layer that ports documents,
// and `verified_upstream_sha` is not advanced for it (coverage row
// `durable.usage.ledger` stays `in_progress`).
library;

/// Token and cost usage of one model response or tool result.
///
/// Port of upstream `Usage` (the `@earendil-works/pi-ai` wire shape) as the
/// durable layer consumes it.
class Usage {
  /// A usage record.
  Usage({
    required this.input,
    required this.output,
    required this.cacheRead,
    required this.cacheWrite,
    required this.totalTokens,
    this.cacheWrite1h,
    this.reasoning,
    required this.cost,
  });

  /// Input tokens.
  int input;

  /// Output tokens (includes [reasoning]).
  int output;

  /// Tokens read from cache.
  int cacheRead;

  /// Tokens written to cache.
  int cacheWrite;

  /// Total tokens.
  int totalTokens;

  /// Subset of [cacheWrite] written with 1h retention (Anthropic only).
  int? cacheWrite1h;

  /// Reasoning/thinking tokens, a subset of [output], when reported.
  int? reasoning;

  /// Catalog- or provider-derived cost.
  UsageCost cost;

  /// This usage as strict JSON, omitting absent optional counters.
  Map<String, Object?> toJson() => <String, Object?>{
        'input': input,
        'output': output,
        'cacheRead': cacheRead,
        'cacheWrite': cacheWrite,
        'totalTokens': totalTokens,
        if (cacheWrite1h != null) 'cacheWrite1h': cacheWrite1h,
        if (reasoning != null) 'reasoning': reasoning,
        'cost': cost.toJson(),
      };

  /// A usage decoded from [json].
  factory Usage.fromJson(Map<String, Object?> json) => Usage(
        input: json['input']! as int,
        output: json['output']! as int,
        cacheRead: json['cacheRead']! as int,
        cacheWrite: json['cacheWrite']! as int,
        totalTokens: json['totalTokens']! as int,
        cacheWrite1h: json['cacheWrite1h'] as int?,
        reasoning: json['reasoning'] as int?,
        cost: UsageCost.fromJson(
          (json['cost'] as Map<String, Object?>?) ?? <String, Object?>{},
        ),
      );
}

/// The cost breakdown of a [Usage].
///
/// Port of upstream `Usage.cost`.
class UsageCost {
  /// A cost record.
  UsageCost({
    required this.input,
    required this.output,
    required this.cacheRead,
    required this.cacheWrite,
    required this.total,
    this.totalFromProvider,
  });

  /// Catalog-derived input cost.
  int input;

  /// Catalog-derived output cost.
  int output;

  /// Catalog-derived cache-read cost.
  int cacheRead;

  /// Catalog-derived cache-write cost.
  int cacheWrite;

  /// Best available total (provider-billed when supported, else estimate).
  int total;

  /// Whether [total] is the provider-reported billed cost.
  bool? totalFromProvider;

  /// This cost as strict JSON.
  Map<String, Object?> toJson() => <String, Object?>{
        'input': input,
        'output': output,
        'cacheRead': cacheRead,
        'cacheWrite': cacheWrite,
        'total': total,
        if (totalFromProvider != null) 'totalFromProvider': totalFromProvider,
      };

  /// A cost decoded from [json].
  factory UsageCost.fromJson(Map<String, Object?> json) => UsageCost(
        input: (json['input'] as num?)?.toInt() ?? 0,
        output: (json['output'] as num?)?.toInt() ?? 0,
        cacheRead: (json['cacheRead'] as num?)?.toInt() ?? 0,
        cacheWrite: (json['cacheWrite'] as num?)?.toInt() ?? 0,
        total: (json['total'] as num?)?.toInt() ?? 0,
        totalFromProvider: json['totalFromProvider'] as bool?,
      );
}

/// Ledger of one conversation's own spend: its entries, and compaction
/// summarization attempts, which have none. Port of upstream `UsageState`.
class UsageState {
  /// A usage ledger.
  UsageState({
    Map<String, Usage>? models,
    Map<String, Usage>? tools,
  })  : models = models ?? <String, Usage>{},
        tools = tools ?? <String, Usage>{};

  /// Assistant entries and summarization attempts, keyed `provider/modelId`.
  final Map<String, Usage> models;

  /// Tool results, keyed by tool name; their usage has no model identity.
  final Map<String, Usage> tools;

  /// This ledger as strict JSON.
  Map<String, Object?> toJson() => <String, Object?>{
        'models': <String, Object?>{
          for (final entry in models.entries) entry.key: entry.value.toJson(),
        },
        'tools': <String, Object?>{
          for (final entry in tools.entries) entry.key: entry.value.toJson(),
        },
      };

  /// A ledger decoded from [json].
  factory UsageState.fromJson(Map<String, Object?> json) {
    Map<String, Usage> decode(Object? raw) => <String, Usage>{
          for (final entry in (raw as Map<String, Object?>).entries)
            entry.key: Usage.fromJson(entry.value! as Map<String, Object?>),
        };
    // Missing buckets decode to empty ledgers, mirroring UsageCost.fromJson's
    // tolerance of absent counters (toJson always emits both, but hand-built or
    // older wire blobs need not).
    return UsageState(
      models: decode(
        (json['models'] as Map<String, Object?>?) ?? const <String, Object?>{},
      ),
      tools: decode(
        (json['tools'] as Map<String, Object?>?) ?? const <String, Object?>{},
      ),
    );
  }
}

/// Add every counter of [usage] to [total]; optional counters are added once
/// either side reports them. Port of upstream `addUsage`.
void addUsage(Usage total, Usage usage) {
  total.input += usage.input;
  total.output += usage.output;
  total.cacheRead += usage.cacheRead;
  total.cacheWrite += usage.cacheWrite;
  total.totalTokens += usage.totalTokens;
  if (usage.cacheWrite1h != null) {
    total.cacheWrite1h = (total.cacheWrite1h ?? 0) + usage.cacheWrite1h!;
  }
  if (usage.reasoning != null) {
    total.reasoning = (total.reasoning ?? 0) + usage.reasoning!;
  }
  total.cost.input += usage.cost.input;
  total.cost.output += usage.cost.output;
  total.cost.cacheRead += usage.cost.cacheRead;
  total.cost.cacheWrite += usage.cost.cacheWrite;
  total.cost.total += usage.cost.total;
}

/// A deep copy of [usage], matching upstream's `structuredClone` when
/// `addUsageState` defines a key the sum does not yet hold. Both [Usage] and
/// its [UsageCost] have mutable fields, so assigning the source by reference
/// would let later `addUsage` calls on the sum mutate the source ledger.
Usage _cloneUsage(Usage usage) => Usage(
      input: usage.input,
      output: usage.output,
      cacheRead: usage.cacheRead,
      cacheWrite: usage.cacheWrite,
      totalTokens: usage.totalTokens,
      cacheWrite1h: usage.cacheWrite1h,
      reasoning: usage.reasoning,
      cost: UsageCost(
        input: usage.cost.input,
        output: usage.cost.output,
        cacheRead: usage.cost.cacheRead,
        cacheWrite: usage.cost.cacheWrite,
        total: usage.cost.total,
        totalFromProvider: usage.cost.totalFromProvider,
      ),
    );

/// Add every bucket of [state] into [sum]. Port of upstream `addUsageState`.
/// New keys are deep-copied (upstream's `structuredClone`) so the two ledgers
/// never share a mutable [Usage].
void addUsageState(UsageState sum, UsageState state) {
  for (final bucket in const <String>['models', 'tools']) {
    final target = bucket == 'models' ? sum.models : sum.tools;
    final source = bucket == 'models' ? state.models : state.tools;
    for (final entry in source.entries) {
      final existing = target[entry.key];
      if (existing != null) {
        addUsage(existing, entry.value);
      } else {
        target[entry.key] = _cloneUsage(entry.value);
      }
    }
  }
}
