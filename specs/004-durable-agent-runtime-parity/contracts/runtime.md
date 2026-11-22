# Contract: Subagents, Ownership/Abort, Compaction, Views, Usage, Identity

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md)
**Upstream**: `packages/durable/src/harness/scheduler.ts`, `task-graph.ts`, `agent.ts`, `compaction.ts`, `view.ts`,
`transcript.ts`, `usage.ts`, `provider.ts`, `context.ts`; spec §5.4–§5.5, §8.2, §8.6–§8.7, §9.3–§9.4

## Ownership and subagents (spec §5.5, §7.3)

- Every task names its owner at creation: its conversation (`{kind: "conversation"}`) or a task
  (`{kind: "task", taskId}`); owner edges are immutable.
- A subagent is a task or owned conversation reached by ordinary traversal. A background task is a boundary:
  ordinary traversal skips that task and its complete owned subtree; a directly-aborted live background task includes
  its ordinary owned subtree, and nested background owners remain boundaries.
- `createTask`/`createConversation` with task ownership reject an owner that is `completing`, `terminal`, or
  abort-marked.
- A terminal owner never cascades: it became terminal only after its ordinary owned work drained.

## Abort protocol and cascade (spec §5.4)

```text
commit abortRequested
signal and join active run invocation
wait until ordinary owned work is no longer live
start a fresh abort invocation
abort handler commits terminal outcome
```

- A run invocation may not commit after its durable abort mark appears; every runtime operation rejects after its
  owning invocation ends.
- `Conversation.abort()` withdraws queued inputs and marks live non-background tasks selected by ordinary traversal;
  with `{background: true}` it crosses background boundaries.
- An abort mark cascades idempotently to foreground-owned work; the durable cancellation intent is a live owner's own
  record (its abort mark, or a held `completing` outcome other than `completed`). Held outcomes `failed`, `faulted`,
  `orphaned`, and `aborted` record the same intent; `completed` does not.
- The cascade derives the marks in a later reconcile commit and again at open, so a crash in between loses nothing.

## Compaction task (spec §8.7)

```dart
class CompactionInput { final String reason; final String? instructions; }   // "manual"|"threshold"|"overflow"

class SummaryRequest {
  final int attempt;
  final ModelRef model;
  final ModelThinkingLevel thinkingLevel;
  final ConversationStreamOptions streamOptions;
  final int maxTokens;
  final EntryId tail;        // newest entry of the context the range was selected from
  final EntryId firstKept;   // first entry kept verbatim; the summary's head
}

sealed class CompactionCheckpoint {}

class CompactionSelect extends CompactionCheckpoint {}                              // { phase: "select" }
class CompactionSummarize extends CompactionCheckpoint { final SummaryRequest r; }  // { phase: "summarize", ...r }
class CompactionRetry extends CompactionCheckpoint { final int until; final SummaryRequest r; }

class CompactionResult { final EntryId? entryId; final SubmissionId? submissionId; }
```

`pi.compaction` is version 1 and starts at `{phase: "select"}`.

- **Policy** — resolve `CompactionPolicy` field by field from the first layer that sets the field: the conversation's
  `modelOverrides` entry, the settings' `modelOverrides` entry, the conversation's own fields, then the settings'
  policy over the defaults. A model-specific value beats a general one; the conversation beats the harness at the same
  level; an unset `enabled` in the conversation's `modelOverrides` lets the conversation's own `enabled: false` win.
- **Range selection** is a pure function of a `ContextView` and `keepRecentTokens`: walk the non-marker entries from
  newest to oldest, adding `estimateMessageTokens()`; at the first entry where the sum reaches `keepRecentTokens`, the
  cut is the first candidate at or after it in transcript order (candidates are non-marker entries whose contribution
  begins with a user or assistant message). Nothing to compact when the sum never reaches it or no non-marker entry
  before the cut contributes a model message.
- **Phases** — `select` captures the committed context and runs the `beforeCompact` hooks (first decision wins:
  `{decline}` completes `{}`; `{summary}` is placed). `summarize` derives the summarized messages, serializes them to
  text, and sends a tools-less request with the pinned request (`cacheRetention: "none"`, the pinned `maxTokens`); it
  classifies `stop` with non-empty text as the summary, a retryable `error` as a sleep at `retry`, and anything else
  as `model_error`. `retry` returns to `summarize` with the next attempt and the same pinned request.
- **Placement** — a blocking compaction appends the `pi.compaction` entry directly (`{kind: "pi.compaction", head:
  firstKept, model: [wrapped user message], data: {reason}}`) and completes `{entryId}`; a conversation-owned
  compaction admits it as a write submission with request ID `compaction:<taskId>` and completes `{submissionId}`.
  Raw history stays in storage; compaction never deletes entries.

## Conversation view and transcript (spec §9.3)

```dart
class ConversationView {
  final ConversationRecord conversation;
  final List<EntryRecord> entries;          // window over the fork-aware transcript, in entry ID order
  final EntryId? before;                    // ID just before the window
  final Map<String, Map<String, Object?>> docs;   // pi.agent, pi.live, pi.inbox, pi.provider, pi.usage
}

class ConversationWindow { final EntryId? from; final int min; final int max; }   // defaults 50 / 2*min

abstract interface class Conversation {
  Future<ConversationWatch> watch(Context context, {ConversationWindow? window});
}
// Harness.observeConversation(id, observer, context, {window}) -> Observation<ConversationView>
```

- Each watch/observer has its own window: newest `min` entries with the ID before them in `before`; with `from`, it
  starts there when at most `max` entries are at or after it. The window only appends; when it would hold more than
  `max` entries its oldest leave in one splice and `before` moves to the last one that left.
- Head markers (compaction summaries, resets, handoffs) stay in place in `entries`; the view does not derive the
  active transcript.
- A mount derives each next revision from the Session's commits: document operations mapped under
  `docs["<kind>"]` followed by that observer's entry splices. One mount per conversation; dropped when its last
  observer detaches.

```dart
class ConversationTranscript {
  ConversationTranscript(EntryLoader load, {int pageSize = 50});
  TranscriptView merge(ConversationView view);
  Future<TranscriptView> loadEarlier(Context context);
  Future<TranscriptView> fillGap(TranscriptGap gap, Context context);
  EntryId? get newest;
  ConversationWindow? get resume;
}
```

## Usage (spec §8.6)

```dart
class UsageState {
  final Map<String, Usage> models;   // keyed "provider/modelId"
  final Map<String, Usage> tools;    // keyed by tool name; no model identity
}
```

kind `pi.usage`, version 1, conversation/latest/initial, `initial()` = `{models: {}, tools: {}}`, checkpoint a
complete base on every change. Every built-in writer of a `pi.assistant` entry adds its usage to `models`; every
writer of a `pi.tool-result` entry with usage and every nested-call result commit adds it to `tools`; every compaction
attempt adds its response's usage to `models` in the classifying commit. `Harness.usage()` sums every conversation;
a fork starts at zero.

## Provider identity (spec §8.3, §2.2)

- The conversation's persisted provider `sessionId` (the built-in `pi.provider` document) is passed as the provider
  `sessionId` on generation and compaction requests, so a reopen continues the same provider session.
- A provider that suppresses that identity when caching is disabled is honored; the column is absent then.

## Telemetry and reports (spec §4, §10.1; `harness/telemetry.ts`)

- The harness reports through the typed `DURABLE_TELEMETRY_SCHEMA` spans and events (generation attempts, tool
  rounds, compaction, submission, signal) on the host's `TelemetryContext`, and the pi#11 no-op context is used when
  none is configured.
- `HarnessOptions.onReport(report)` receives failures that do not fail the calling operation — a hook throw, a
  malformed after-run task, a stale write, a Session failure (once) — each with its `kind` and origin, exactly as
  upstream's `Report`/`ReportFrom` define. A report never fails the caller.

## Task graph view (spec §9.4)

```dart
sealed class TaskGraphState {}
class TaskGraphNode { final TaskId id; final TaskId? owner; final String kind; final TaskGraphStatus status; }
class TaskGraph { final List<TaskGraphNode> nodes; }
```

A watchable view of the ownership tree, used by inspection and by a host's task-graph UI.