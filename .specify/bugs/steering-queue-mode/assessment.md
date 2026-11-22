# Bug Assessment: dart-port honor one-at-a-time and all steering/follow-up queue modes

- **Slug**: steering-queue-mode
- **Created**: 2026-11-22
- **Source**: https://github.com/arrrrny/pi/issues/2
- **Verdict**: valid
- **Severity**: medium
- **URL Trust Policy**: `github.com` (host: `github.com`) — `allowlisted`; fetched via `gh issue view` (no redirect following).

## Report (verbatim or summarized)

Dart-port parity defect: `SteeringMode` and `FollowUpMode` are stored but do not affect queue draining; every drain returns all queued messages.

Actual:
- `pi_agent/lib/src/agent.dart:119-124` marks both fields `ignore: unused_field`.
- `pi_agent/lib/src/agent.dart:425-429` copies and clears the entire selected queue regardless of the configured mode.

Expected (upstream behavior):
- `packages/agent/src/agent.ts:149-180` implements `PendingMessageQueue`: `all` drains every message, while `one-at-a-time` drains only the first. Constructor options and setters update those queues at `:255-256` and `:290-305`; loop configuration drains them at `:506-514`.

Required port coverage:
- Implement queue objects (or equivalent behavior) whose `peek`/`drain` honors the selected mode.
- Cover constructor configuration and runtime setters for both queue types.
- Test one-at-a-time delivery across turns, `all` delivery, steering precedence, follow-up placement, queue clearing, and continuation from an assistant message.

Evidence reviewed at Dart commit `1d62d46d9b3ba09c22a2f38fc94e46693ea1cc03` and upstream commit `780bf31fcaeb252fa9b68df3964c735eae75bde3`. Independently re-verified against the current checkout on 2026-11-22.

## Symptom

The Dart `Agent` accepts `steeringMode` and `followUpMode` (`one-at-a-time` vs `all`) at construction and via runtime setters, but the values are never read during queue draining. Every drain returns and clears the entire selected queue, so `one-at-a-time` is silently ignored and all queued messages are delivered in a single turn.

## Reproduction

1. Construct a Dart `Agent` (default modes are `oneAtATime`).
2. Enqueue two steering messages via `steer()`.
3. Run a turn and inspect what is injected: both messages are delivered in the first turn.
4. Switch `agent.steeringMode = SteeringMode.all` and repeat: identical behavior (both messages delivered) — the setter has no effect.

Expected: with `one-at-a-time`, only the first queued message is drained per turn; with `all`, both are drained in one turn. The setters must change behavior.

## Suspected Code Paths

- `pi_agent/lib/src/agent.dart:119-122` — `// ignore: unused_field` on `_steeringMode` and `_followUpMode`; the analyzer flag is itself the proof the fields are write-only.
- `pi_agent/lib/src/agent.dart:176-179` — constructor stores modes but nothing downstream reads them.
- `pi_agent/lib/src/agent.dart:244-248` — `set steeringMode` / `set followUpMode` write the field; no behavior changes.
- `pi_agent/lib/src/agent.dart:416-421` — `getSteeringMessages` / `getFollowUpMessages` close over the raw `_steeringQueue` / `_followUpQueue` lists.
- `pi_agent/lib/src/agent.dart:425-429` — `_drainQueue(List<AgentMessage> queue)` copies the whole list and clears it; no mode check, no `peek()` distinction.
- `pi_agent/lib/src/agent.dart:131-132` — `_steeringQueue` / `_followUpQueue` are plain `List<AgentMessage>`, not queue objects with a mode.

## Root Cause Hypothesis

The port stores the two `QueueMode`-like enums but never introduces the `PendingMessageQueue` abstraction that upstream uses to gate draining. Because the Dart queues are raw `List<AgentMessage>` and `_drainQueue` is mode-agnostic, the configured mode has no path to the drain decision. Confidence: **high** — confirmed by reading both source files at the cited lines.

## Proposed Remediation

**Preferred**: Introduce a `PendingMessageQueue` class in Dart mirroring upstream `packages/agent/src/agent.ts:149-180`:

- Fields: `List<AgentMessage> _messages` and a mutable `QueueMode mode`.
- Methods: `enqueue(AgentMessage)`, `hasItems()`, `peek()` (returns all when mode is `all`, else the first only), `drain()` (calls `peek()` then removes the drained prefix), `clear()`.
- Mode changes affect messages already queued, matching upstream.

Replace the Dart-only `SteeringMode` and `FollowUpMode` enums with one exported `QueueMode` enum containing `all` and `oneAtATime`, corresponding to upstream `packages/agent/src/types.ts:49-55`. Use that type in `AgentOptions`, constructor arguments, and both `steeringMode` and `followUpMode` setters/getters. Do not retain parallel enum names as a compatibility layer: the package's governing contract is strict upstream API/behavior parity.

Then wire `Agent` to use it:
- `_steeringQueue` / `_followUpQueue` become `PendingMessageQueue` instances.
- Constructor passes `steeringMode` / `followUpMode` into the respective queues.
- `steeringMode` / `followUpMode` setters mutate the queue's `mode`, and new getters return it.
- `_drainQueue` (or its callers) call `queue.drain()` so the mode is honored.
- `steer()` / `followUp()` call `queue.enqueue()`.
- `clearSteeringQueue()` / `clearFollowUpQueue()` call `queue.clear()`.
- `hasQueuedMessages()` checks `steeringQueue.hasItems() || followUpQueue.hasItems()`.
- Expose public `peekQueuedMessages()` with upstream semantics: return the steering peek when non-empty, otherwise the follow-up peek, without consuming either queue.
- Remove the obsolete `// ignore: unused_field` annotations and raw mode/list fields.

**Alternatives**:
- Inline a mode check inside `_drainQueue` (branch on `mode == all ? queue : [queue.first]`). Trade-off: smaller diff but no reusable queue object, no `peek`/`clear`/`hasItems` parity, and the mode still lives on `Agent` rather than on the queue — the upstream shape the port is targeting is lost. Not recommended.

**Files likely to change**:
- `pi_agent/lib/src/types.dart` (shared exported `QueueMode`).
- `pi_agent/lib/src/agent.dart` (queue wiring and public API).
- `pi_agent/lib/src/pending_queue.dart` (queue implementation, if not colocated).
- `pi_agent/test/agent_test.dart` (mode-honoring tests).
- `pi_agent/test/agent_loop_test.dart` (mode-dependent drain across turns).

**Tests to add or update**:
1. One-at-a-time steering: queue 2 messages, run a turn, assert only the first is injected; run another turn, assert the second.
2. `all` steering: queue 2 messages with `steeringMode = QueueMode.all`, run one turn, assert both injected.
3. One-at-a-time follow-up across turns.
4. `all` follow-up in one turn.
5. Steering precedence over follow-up when both queues are non-empty.
6. Follow-up placement after the agent would otherwise stop.
7. Queue clearing via `clearSteeringQueue` / `clearFollowUpQueue` / `clearAllQueues` reflected in `hasQueuedMessages()`.
8. Continuation from an assistant tail drains queued steering/follow-up.
9. Constructor and `AgentOptions` mode configuration using `QueueMode` for both queues.
10. Runtime mode switch (`oneAtATime` → `all` via setter) affects the next drain and is visible through the corresponding getter.
11. `peekQueuedMessages()` returns steering first, falls back to follow-up, honors each mode, and never consumes messages.

## Risks & Considerations

- **Behavioral change for any caller relying on the (incorrect) always-drain-all behavior** — but that is the defect; callers that set `one-at-a-time` today get all messages, which is wrong. Severity medium because the default mode is `oneAtATime`, so today's behavior contradicts the documented default for every user who queues more than one steering/follow-up message.
- **Public API alignment** — `peekQueuedMessages()` and the mode getters are additive; replacing the split enums with upstream's shared `QueueMode` is an intentional parity correction, not a new compatibility abstraction. Update call sites and API documentation in the same fix.
- **No cross-cutting concerns** — the change is confined to the agent queue API and its tests, with no migrations or wire-format changes.

## Resolved Scope Decisions

- `peekQueuedMessages()` is public on `Agent`, matching upstream's public method and its steering-first, non-consuming behavior.
- One exported `QueueMode` replaces both Dart-only mode enums everywhere, matching upstream `packages/agent/src/types.ts:55` and `Agent` at `packages/agent/src/agent.ts:289-305`.