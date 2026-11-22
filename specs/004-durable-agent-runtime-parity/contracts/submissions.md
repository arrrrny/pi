# Contract: Submissions, Inbox, and Run Control

**Feature**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md)
**Upstream**: `packages/durable/src/harness/submissions.ts`, `inbox.ts`, `live.ts`, `types.ts`; spec §6, §8.2

## Submission draft

```dart
sealed class SubmissionDraft {}

class InputDraft extends SubmissionDraft {
  final String? requestId;
  final SubmissionNotify? notify;
  final UserInput content;
  final String? whenBusy;   // "steer" | "followUp" | "reject"
  final bool whenIdleReject; // "reject" => ConversationIdle on idle
  final String? onAbort;    // "withdraw" | "keep"
}

class WriteDraft extends SubmissionDraft {
  final String? requestId;
  final SubmissionNotify? notify;
  final EntryDraft entry;
}

class ContinueDraft extends SubmissionDraft {   // idle only; never queues
  final String? requestId;
  final SubmissionNotify? notify;
}
```

## Inbox document (`pi.inbox`, spec §6)

```dart
sealed class InboxItem {}

class InboxInputItem extends InboxItem {
  final SubmissionId id;
  final String mode;          // "steer" | "followUp"
  final UserInput content;
  final InputEntry? entry;
  final String? onAbort;      // only "keep"
}

class InboxWriteItem extends InboxItem {
  final SubmissionId id;      // mode "write"
  final Map<String, Object?> entry;
}

class InboxState { final List<InboxItem> items; }
```

kind `pi.inbox`, version 1, conversation scope, latest history, initial fork; `initial()` = `{items: []}`;
checkpoint is a complete base whenever `items` is empty; created with every Harness conversation. Items are in ID
order.

## Admission and terminal transitions (spec §6)

| action | submission state | other writes |
|---|---|---|
| input, idle with empty inbox | `placed`, with user entry | create run and generation |
| continue, idle | `placed`, no entry | place queued items (final boundary); create run and generation |
| continue, busy | none | reject `ConversationBusy` |
| input with `whenIdle: "reject"`, idle | none | reject `ConversationIdle` |
| display-only write, no queued reset | `done`, with entry | append entry; no run |
| write, idle with empty inbox | `done`, with entry | append entry; no run |
| input or other write, busy or non-empty inbox | `queued` | append inbox item |
| boundary places user item | `placed`, with entry | add ID to current or successor run |
| run answers | input/continue `done`, with answer entry | remove `run` or hand to a successor; with `afterRun` selected keep `run` until its tasks are terminal |
| run fails or its task aborts | input `unanswered`, with reason | remove `run`; inbox per `afterFailedRun` |
| withdraw queued item | `unanswered`, reason `aborted` | remove inbox item |
| stale head write | `unanswered`, reason `stale` | remove inbox item |

- `requestId` deduplicates within one conversation before any write; reusing it for the other submission type
  rejects.
- `Conversation.admit(tx, draft)` runs admission inside the caller's commit; entries it appends carry the task's
  `byTaskId`. Admission must precede the commit's first table write (`ReadAfterWrite` otherwise).
- A `continue` is admitted only while idle and never queues; a context that does not end in a user message or tool
  results ends `unanswered` with `nothing_to_answer`.

## Boundaries and queue modes (spec §6)

- `steeringMode` / `followUpMode` are `one-at-a-time` (first item of that mode) or `all` (every item of that mode).
- `postTools` boundary: all writes, steer first/all by mode, no follow-ups.
- `final` boundary: all writes, steer first/all by mode, follow-up first/all by mode.
- A boundary places selected writes first (in ID order) then selected user items (in ID order). A `head: "self"` write
  at `postTools` behaves as `final`. A queued reset wins over a handoff written before it.

## `afterFailedRun` (spec §6, §8.2)

For a run failing with `model_error`, `no_model`, `interrupted`, `restart_limit`, `nothing_to_answer`, or
`turn_limit`, in the commit that settles its own inputs:

- `keep` (default): leave queued items queued.
- `continue`: apply the final boundary so the next run starts with them.
- `withdraw`: settle them `unanswered` with reason `run_failed`, keeping queued writes.

A run whose task is aborted, faults, or is orphaned keeps its inbox.

## Live document (`pi.live`, spec §8.2)

```dart
class LiveState {
  final RunControl? run;          // present exactly while busy
  final GenerationPresentation? generation;
  final List<ToolSlot>? tools;
  final List<NestedSlot>? nestedTools;
  final List<CompactionStatus>? compactions;
  final CompactionFailure? compactionFailure;
  final RunFailure? runFailure;
}
```

kind `pi.live`, version 3, conversation/latest/initial, `initial()` = `{}`. `migrate` from v1 renames `reason` to
`trigger` and from v1/v2 sets `run.turns` to `0` where missing. Checkpoint is a complete base whenever nothing runs.
Streamed fields (`generation.message`, a running slot's output/droppedBytes/droppedLines/details/diagnostics) are
written by deferred commits; every commit that derives from or clears them acquires `pi.live` first.