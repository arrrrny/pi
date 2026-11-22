# Bug Issue: dart-port honor one-at-a-time and all steering/follow-up queue modes

- **Slug**: steering-queue-mode
- **Fetched**: 2026-11-22
- **Issue**: 2
- **URL**: https://github.com/arrrrny/pi/issues/2
- **State**: open
- **Severity**: unknown
- **Author**: arrrrny
- **Labels**: bug, dart-port, pkg:agent

## Body

## Dart-port parity defect

`SteeringMode` and `FollowUpMode` are stored but do not affect queue draining; every drain returns all queued messages.

### Actual

- `pi_agent/lib/src/agent.dart:119-124` marks both fields `ignore: unused_field`.
- `pi_agent/lib/src/agent.dart:425-429` copies and clears the entire selected queue regardless of the configured mode.

### Expected (upstream behavior)

`packages/agent/src/agent.ts:149-180` implements `PendingMessageQueue`: `all` drains every message, while `one-at-a-time` drains only the first. Constructor options and setters update those queues at `:255-256` and `:290-305`; loop configuration drains them at `:506-514`.

### Required port coverage

- Implement queue objects (or equivalent behavior) whose `peek`/`drain` honors the selected mode.
- Cover constructor configuration and runtime setters for both queue types.
- Test one-at-a-time delivery across turns, `all` delivery, steering precedence, follow-up placement, queue clearing, and continuation from an assistant message.

Evidence reviewed at Dart commit `1d62d46d9b3ba09c22a2f38fc94e46693ea1cc03` and upstream commit `780bf31fcaeb252fa9b68df3964c735eae75bde3`.

## Comments

**arrrrny** (2026-11-22): Full assessment artifact: [`specs/003-issue-2-steering-queue-assessment/spec.md`](https://github.com/arrrrny/pi/blob/master/specs/003-issue-2-steering-queue-assessment/spec.md) — CONFIRMED verdict. `SteeringMode` and `FollowUpMode` stored in `agent.dart:119-122` with `// ignore: unused_field` but never consulted during drain. `_drainQueue` (`:425-429`) unconditionally copies and clears the entire queue. Upstream `PendingMessageQueue` (`packages/agent/src/agent.ts:149-180`) honors `one-at-a-time` vs `all`. Minimal remediation: add `PendingMessageQueue` class, replace raw lists, remove ignores, add `peekQueuedMessages()`, add 10 verification cases.