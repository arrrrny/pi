# Bug Assessment: Steering/Follow-Up Queue Mode Defect

**Issue**: [`arrrrny/pi#2`](https://github.com/arrrrny/pi/issues/2)
**Date**: 2026-11-22
**Depends on**: none
**Verdict**: **CONFIRMED** — `SteeringMode` and `FollowUpMode` are stored but never consulted during queue draining.

## Summary

The Dart `Agent` stores `steeringMode` and `followUpMode` as private fields with `// ignore: unused_field` annotations (`pi_agent/lib/src/agent.dart:119-124`). The `_drainQueue` method (`:425-429`) unconditionally copies and clears the entire queue regardless of the configured mode. Upstream's `PendingMessageQueue` (`packages/agent/src/agent.ts:149-180`) honors `one-at-a-time` vs `all` by peeking/draining only the first message or all messages respectively.

## Root Cause

### Dart (defective)

`pi_agent/lib/src/agent.dart`:

- **Fields** (`:119-122`): `_steeringMode` and `_followUpMode` declared with `// ignore: unused_field`.
- **Constructor** (`:176-179`): Stores the modes with defaults `SteeringMode.oneAtATime` / `FollowUpMode.oneAtATime`.
- **Setters** (`:244-248`): Write to the fields but the values are never read.
- **Config** (`:416-421`): `getSteeringMessages` and `getFollowUpMessages` close over `_steeringQueue` and `_followUpQueue` respectively.
- **Drain** (`:425-429`): `_drainQueue(List<AgentMessage> queue)` copies the entire list and clears it — no mode check, no `peek` distinction.

```dart
List<AgentMessage> _drainQueue(List<AgentMessage> queue) {
  final msgs = List<AgentMessage>.from(queue);
  queue.clear();
  return msgs;
}
```

### Upstream (correct)

`packages/agent/src/agent.ts`:

- **`PendingMessageQueue`** (`:149-180`): A class with `enqueue`, `hasItems`, `peek()`, `drain()`, `clear()`. `peek()` returns all messages when `mode === "all"`, or just the first when `mode === "one-at-a-time"`. `drain()` calls `peek()` and slices off the returned count.
- **Constructor** (`:255-256`): Creates two `PendingMessageQueue` instances with the respective modes.
- **Setters** (`:290-305`): `set steeringMode` / `set followUpMode` mutate the queue's `.mode` field.
- **Loop config** (`:506-514`): `getSteeringMessages` and `getFollowUpMessages` call `queue.drain()`, which honors the mode.

## Upstream Test Coverage

`packages/agent/test/agent.test.ts` covers:

1. **Steering message queue basic** (`:649-657`): `steer()` queues without adding to `state.messages`.
2. **Follow-up message queue basic** (`:659-667`): `followUp()` queues without adding to `state.messages`.
3. **Continue with follow-up after assistant turn** (`:786-822`): `continue()` drains queued follow-up when last message is assistant.
4. **Continue with one-at-a-time steering from assistant tail** (`:824-858`): Parameterized test — `one-at-a-time` mode produces 2 requests (one per message), `all` mode produces 1.
5. **Continue with queued steering at startup** (`:1010-1041`): Parameterized — `one-at-a-time` sends "first" then "second" in separate turns; `all` sends both in first request.
6. **Steering precedes follow-up** (`:1043-1069`): When both queues have messages, steering is drained first.
7. **Queue persistence on error/abort** (`:1071-1134`): Queues survive error and aborted runs; `peekQueuedMessages()` previews without consuming.
8. **Peek without consuming** (`:1136-1153`): `peekQueuedMessages()` honors mode (returns first for `one-at-a-time`, all for `all`).

## Dart Test Coverage (Gaps)

`pi_agent/test/agent_test.dart` covers:

- Construction with defaults (`:9-18`)
- Basic `steer()` / `followUp()` queueing (`:326-362`)
- `clearSteeringQueue` / `clearFollowUpQueue` / `clearAllQueues` (`:339-361`)
- Setter smoke tests (`:460-468`): `agent.steeringMode = SteeringMode.all` — writes the field but asserts nothing about behavior.

`pi_agent/test/agent_loop_test.dart` covers:

- Steering messages injected before next turn (`:203-222`): Uses a callback that returns messages regardless of mode — does not test mode-dependent behavior.
- Follow-up messages continue the loop (`:182-201`): Same — mode-agnostic.

**Missing coverage:**

1. One-at-a-time delivery: only first message per drain across multiple turns.
2. `all` delivery: all queued messages in a single drain.
3. Steering precedence over follow-up (drain steering before follow-up).
4. Follow-up placement (after agent would otherwise stop).
5. Queue clearing (partial — clear methods exist but no drain-then-clear verification).
6. Continuation from an assistant message (drains queued steering/follow-up).
7. `peekQueuedMessages()` equivalent (doesn't exist in Dart at all).

## Minimal Remediation Scope

### 1. Add a `PendingMessageQueue` class (or equivalent) in Dart

**Location**: `pi_agent/lib/src/agent.dart` or a new `pi_agent/lib/src/pending_queue.dart`.

**Requirements**:
- Fields: `List<AgentMessage> _messages`, `SteeringMode _mode` (or `FollowUpMode`).
- Methods: `enqueue(AgentMessage)`, `hasItems()`, `peek()` (returns 1 or all based on mode), `drain()` (peek + remove drained), `clear()`.
- Mode setter: updates `_mode` on the queue object (so existing enqueued messages are affected).

### 2. Replace raw `List<AgentMessage>` queues with `PendingMessageQueue`

In `agent.dart`:
- `_steeringQueue` and `_followUpQueue` become `PendingMessageQueue` instances.
- Constructor passes `steeringMode` / `followUpMode` to the respective queues.
- `steeringMode` / `followUpMode` setters update the queue's mode.
- `_drainQueue` calls `queue.drain()` which honors the mode.
- `steer()` / `followUp()` call `queue.enqueue()`.
- `clearSteeringQueue()` / `clearFollowUpQueue()` call `queue.clear()`.
- `hasQueuedMessages()` checks `steeringQueue.hasItems() || followUpQueue.hasItems()`.

### 3. Remove `// ignore: unused_field` annotations

Once the modes are actually read by the queue's `peek()`/`drain()`, the `ignore` comments are no longer needed.

### 4. Add `peekQueuedMessages()` method (upstream parity)

```dart
List<AgentMessage> peekQueuedMessages() {
  final steering = _steeringQueue.peek();
  return steering.isNotEmpty ? steering : _followUpQueue.peek();
}
```

## Verification Cases

1. **One-at-a-time steering**: Queue 2 steering messages, run a turn, verify only the first is injected; run another turn, verify the second is injected.
2. **All steering**: Queue 2 steering messages with `steeringMode = all`, run a turn, verify both are injected in the same turn.
3. **One-at-a-time follow-up**: Queue 2 follow-up messages, run turns until agent stops, verify follow-ups are delivered one per turn.
4. **All follow-up**: Queue 2 follow-up messages with `followUpMode = all`, verify both delivered in one turn.
5. **Steering precedence**: Queue both steering and follow-up; verify steering is drained first.
6. **Follow-up after stop**: Agent produces end-turn; follow-up messages appear in transcript after the assistant message.
7. **Clear queues**: Queue messages, call `clearSteeringQueue()` / `clearFollowUpQueue()` / `clearAllQueues()`, verify `hasQueuedMessages()` reflects the clear.
8. **Continue from assistant**: Last message is `AssistantMessage`; call `continue_()`; verify queued steering/follow-up are drained and fed into the loop.
9. **Constructor modes**: Create `Agent(steeringMode: SteeringMode.all, followUpMode: FollowUpMode.all)`; verify both queues drain all messages.
10. **Runtime mode switch**: Create agent with `oneAtATime`, queue messages, switch to `all` via setter, verify next drain returns all.

## Triage Result

**Bug Fix** — Existing fields and setters exist but are inert. The fix is to wire them through a queue object that honors the mode.

**Complexity: Simple** — Single file change (`agent.dart`), well-defined upstream reference implementation, no cross-cutting concerns. The queue logic is ~30 lines. Tests are straightforward extensions of the existing agent_test.dart patterns.

**Depth Plan**: Read the upstream `PendingMessageQueue` and its test coverage (done), implement the Dart equivalent, add mode-honoring tests mirroring the upstream parameterized tests, verify with `dart test`.