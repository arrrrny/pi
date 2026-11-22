# Feature Specification: Durable Agent Runtime Parity

**Feature Branch**: `004-durable-agent-runtime-parity`
**Created**: 2026-11-22
**Status**: Draft
**Input**: GitHub issue [`arrrrny/pi#12`](https://github.com/arrrrny/pi/issues/12) — "dart-port: port the durable agent runtime", the second vertical slice of the durable-pi parity epic [`arrrrny/pi#8`](https://github.com/arrrrny/pi/issues/8)
**Normative reference**: [pi, Zuraffa Agent, and BrowserAgent Architecture Plan](https://github.com/arrrrny/zuraffa_browser/blob/master/handoffs/2026-11-22-pi-zuraffa-browser-agent-architecture-plan.md), §2.1, §6.1–§6.6 (slice 6 "Durable agent")
**Upstream oracle**: `earendil-works/pi` at commit `780bf31fcaeb252fa9b68df3964c735eae75bde3` (`@earendil-works/pi-durable` 1.6.0, `@earendil-works/pi-agent-core` 1.6.0, `@earendil-works/pi-ai` 1.6.0, `@earendil-works/pi-codemode` 1.6.0, with `@earendil-works/pi-schema` 1.6.0, `@earendil-works/pi-telemetry` 1.6.0, `@earendil-works/pi-chord` 1.6.0, `@earendil-works/pi-env` 1.6.0)
**Depends on**: arrrrny/pi#11, arrrrny/pi#2, arrrrny/pi#7

## Why This Exists

The first durable slice, `003-durable-storage-task-foundations` (pi#11), ported the substrate: the schema and
telemetry prerequisites, the Chord primitives, the Session's atomic commits and immutable entries, typed documents
and conversations, the task runtime (definitions, checkpoints, waits, sleeps, ownership, abort cascades), and the
three storage backends under one conformance suite. It deliberately stopped before the durable *agent* — the part
that actually runs a model, executes tools, and recovers across crashes. Without it, nothing built on the
foundation can honestly claim to be a durable agent runtime, because generation, tool execution, submissions,
signals, and compaction are exactly the behaviors that turn a durable store into a durable agent.

Upstream pi-durable is a durable, extensible agent harness, and its built-in tasks are the heart of it:

> `pi.generation` prepares the system prompt and tools, requests or polls the model, retries, and classifies the
> response. `pi.tool` validates, runs hooks, executes, and persists a tool result. `pi.compaction` selects a
> transcript range, summarizes it, and places a headed summary. (`packages/durable/docs/spec.md` §8)

This feature ports that durable agent runtime to Dart as the second vertical slice of pi#8 (architecture plan §6.6
slice 6). It builds directly on the pi#11 foundation — the task runtime, the Session commit boundary, documents,
signals primitives, and storage — and consumes the upstream contracts rather than reinventing them. It delivers the
durable generation task and the individual tool-call task with their replay policies and restart limits; the
submission/inbox machinery (request-ID deduplication, durable inboxes, steering and follow-up, settlement, and
continuation after failed runs); the extension system (registries, sections, hooks, tool and section wrappers,
custom tasks, per-conversation agent configuration, and registry reload); signals, memoized idempotency values,
parked tools, nested calls, human and webhook waits, and approval gates; foreground and background subagents,
ownership and abort of the run, durable compaction, committed conversation views and watches, telemetry, usage and
cost, and provider session identity; and durable code mode with its deterministic replay and journaling.

It ports the upstream-derived differential tests that prove the behavior across every commit, crash, wake, replay,
approval, nested-call, and failure boundary. It adds no Zuraffa entity, no browser concept, no MCP policy, and no
second runtime model. It is a strict upstream port: every Dart type, function, and error is grounded in a named
upstream source file, specification section, test, or example at the target SHA, and every coverage row it adds
names the exact verified upstream SHA and every remaining gap.

## User Scenarios & Testing

### User Story 1 - Durable Generation and Tool-Call Tasks with Replay and Restart Limits (Priority: P1)

A host runs an agent conversation in the Dart port. The runtime prepares a system prompt and tool set, sends the
model context to a provider, classifies the streamed or deferred response, and — when the model asks for tools —
runs each tool call as its own durable task and appends the results. Each generation attempt and each tool call is
a task that commits its progress; when the process dies mid-stream, mid-tool, or between a tool result and the next
request, the task resumes at its last committed checkpoint. A generation that streamed a partial response converts
it to an aborted entry on recovery; a tool call cut off before its result committed reruns if it declared itself
replay-safe and returns an `interrupted` result otherwise. A task that crashes in a loop is bounded by a restart
limit and ends visibly rather than spinning forever.

**Why this priority**: This is the durable agent itself. Every later story — submissions, signals, subagents,
compaction, code mode — is built on the generation and tool tasks. A runtime whose generation and tool tasks are
not crash-safe would make every claim above them false, and it is the behavior the current Dart `Conversation`
most clearly lacks (it models, rather than ports, durable behavior).

**Independent Test**: Define a conversation; drive a scripted model that emits a tool call, a retryable error, and
then an answer; kill the session at each commit boundary (before admission, mid-stream, after a tool result, before
publication) and reopen; assert the generation resumes at its checkpoint with its wake preserved, a streamed
partial is converted to an aborted entry, a replay-safe tool reruns once and a replay-unsafe tool returns
`interrupted`, and a task that exceeds the restart limit ends with a `restart_limit` result rather than looping.

**Acceptance Scenarios**:

1. **Given** a generation that committed `{phase: "request", attempt, model, cutoff}`, **When** the session is
   closed and reopened, **Then** the generation resumes at that request with the same pinned model, thinking level,
   and stream options, and re-runs the `beforeRequest` chain rather than charging the attempt against the retry
   policy.
2. **Given** a generation whose response streamed a committed partial, **When** the host died mid-stream, **Then**
   recovery converts the partial to an aborted `pi.assistant` entry and, if the retry policy allows, sleeps at a
   `retry` checkpoint until the backoff deadline, or settles the inputs `unanswered` with `interrupted` when no
   attempt remains.
3. **Given** a tool call whose task committed intent `{phase: "execute", replay: "safe"}`, **When** the host died
   before the result committed, **Then** a reopen runs `execute()` again from the top with the same arguments and
   the tool's own memoized idempotency key prevents a duplicate external effect.
4. **Given** a tool call whose task committed intent `{phase: "execute", replay: "unsafe"}`, **When** the host died
   before the result committed, **Then** recovery runs the tool's `cancel` cleanup and settles an `interrupted`
   error result; it does not run `execute()` again.
5. **Given** a task whose `restarts` reaches `settings.restartLimit`, **When** the phase starts, **Then** a
   `pi.tool` ends with a `restart_limit` error result, a compaction fails into `pi.live.compactionFailure`, a
   generation ends its run `unanswered` with `runFailure` reason `restart_limit`, and an extension task ends
   `faulted` with detail `{reason: "restart_limit"}`.

---

### User Story 2 - Submissions, Request-ID Dedup, Durable Inboxes, Steering, and Failed-Run Continuation (Priority: P1)

A host submits user input, a continue, or a display-only write to a conversation and gets back an awaitable
submission. Admission deduplicates by request ID within the conversation before any write; a busy conversation
steers or queues the input, an idle one starts a run; queued inputs wait in the durable `pi.inbox` document. When a
run ends — with an answer, a handoff, a tool round that asks to terminate, or a failure — the boundary selects
queued steer and follow-up items by the settings' queue modes and either joins them to a successor run or leaves
them queued. A run that fails with `model_error`, `no_model`, `interrupted`, `restart_limit`,
`nothing_to_answer`, or `turn_limit` applies `afterFailedRun` to decide whether queued inputs continue, stay
queued, or are withdrawn, so a later input or queued write can restart the work without duplicating it.

**Why this priority**: Submissions are how a host talks to a durable agent, and the inbox, dedup, and failed-run
rules are what make "reopen interrupted work without duplicating orders or repeating replay-unsafe effects"
(architecture plan §10.1) actually hold. Without them, a durable generation would drop or double-apply host input
across restarts.

**Independent Test**: Submit an input with a reused request ID and assert it is deduplicated with no second write;
submit while busy and assert it queues in `pi.inbox` and steers the active run per `steeringMode`; force a run to
fail with a scripted provider error and assert `afterFailedRun: "continue"` starts the next run with the queued
input, `"keep"` leaves it queued, and `"withdraw"` settles it `unanswered` with `run_failed`; assert a fork starts
with an empty inbox.

**Acceptance Scenarios**:

1. **Given** two submissions with the same `requestId` in one conversation, **When** the second is admitted,
   **Then** it is deduplicated to the first before any write, and reusing a request ID for the other submission
   type is rejected.
2. **Given** a busy conversation and an input with `whenBusy: "steer"`, **When** it is admitted, **Then** it is
   placed as a steer item and joined to the current run at the next boundary selected by `steeringMode`
   (`one-at-a-time` or `all`).
3. **Given** a run that fails with `no_model`, **When** `afterFailedRun` is `continue`, **Then** the final boundary
   runs in the failure's commit and the next run starts with the queued input; with `withdraw`, the queued inputs
   settle `unanswered` with reason `run_failed` and queued writes stay.
4. **Given** a queued reset or a stale head write, **When** the boundary selects items, **Then** a head write
   whose target predates the active range start settles `unanswered` with `stale`, and a display-only write queues
   behind a queued reset.
5. **Given** a run that answered and waits for its `afterRun` tasks, **When** a new input is admitted, **Then** it
   queues (the conversation is still busy) and starts the next run when that run ends, while
   `Submission.wait()` already sees the answer.

---

### User Story 3 - Extensions: Registries, Sections, Hooks, Wrappers, Custom Tasks, and Per-Conversation Config (Priority: P1)

A host extends the agent without forking it. An extension is a named, immutable bundle of tools, prompt sections,
hooks, tool and section wrappers, and task definitions, installed into a process-local registry that may outlive a
Harness. A conversation selects extensions by name in its `pi.agent` document; resolution computes the offered
tools, sections, hooks, model, thinking level, and cwd from the stored agent, the registry snapshot, and the
settings. A registry install replaces an extension in place and publishes synchronously, waking the scheduler to
reconsider blocked tasks; per-conversation configuration (`configure`) changes a conversation's stored agent without
touching other conversations. Hooks are typed questions a task asks before it commits a decision, dispatched in
extension order, and durable through reload because they match by task name.

**Why this priority**: The architecture plan's whole extension model (§5.2, §7.3) is that Zuraffa extends pi
through these upstream seams rather than by editing pi. A port that omitted the registry, sections, hooks,
wrappers, and per-conversation resolution would force the Zuraffa wrapper to recreate the agent loop, which the
plan forbids. This is the seam that makes "one runtime, pi" possible.

**Independent Test**: Install two extensions that both define a `bash` tool and assert the later one overrides the
earlier in place; wrap a tool and assert the wrapper runs in extension order and a wrapper that renames its target
drops it with `tool_unavailable`; register a `beforeTool` hook that blocks a dangerous call and assert the tool
task settles with the block text; `configure` one conversation's extensions and assert only that conversation's
resolution changes; install a replacement extension and assert a parked gate is woken with no wake.

**Acceptance Scenarios**:

1. **Given** two extensions each naming a tool `bash`, **When** both are selected, **Then** the later extension's
   tool wins in place and any selected tool wrappers apply to the winning tool.
2. **Given** a `beforeTool` hook returning `{block: "Needs approval"}`, **When** the tool task runs its `call`
   phase, **Then** the call settles with the block as an error result and `execute()` never runs.
3. **Given** a conversation that selects `extensions: {add: [Venv]}`, **When** it is resolved, **Then** only that
   conversation's agent includes `Venv`'s tools, and another conversation's resolution is unchanged.
4. **Given** a registry `install` that would create a duplicate task name or an invalid section key, **When** it is
   called, **Then** it throws without publishing anything; a valid install publishes synchronously and notifies
   subscribers.
5. **Given** a task parked at a gate under one registry snapshot, **When** a registry publication replaces that
   snapshot, **Then** the task is woken with no wake and re-runs its whole `call` phase against the new gates.

---

### User Story 4 - Signals, Memoized Idempotency, Parked Tools, Nested Calls, and Approval Gates (Priority: P1)

A host delivers a typed value to a waiting task from outside — a webhook result, a person's answer, a submission's
settlement — under a key that names one wait. A task or tool parks by sleeping on a signal key (optionally with a
deadline), holding no invocation, and resumes when the value arrives or the deadline passes. A tool uses memos for
first-writer-wins idempotency keys so a replayed external effect is not duplicated. A running tool calls another
tool as a nested call with its own task ID, its own replay policy, and its own key, parking on the nested calls'
tasks rather than holding an invocation; the nested result returns to the caller and never enters the transcript.
A `beforeTool` gate can sleep a call at its gates until an approval signal arrives, binding the approval to the
arguments it saw.

**Why this priority**: Signals, memos, parks, and nested calls are how durable work waits for the outside world and
composes without a second runtime model — exactly what browser order missions and price checks need (architecture
plan §10.1 step 6: "present blockers to the user and resume through durable signals"). A port that omitted them
would force the Zuraffa layer to invent a parallel waiting/idempotency mechanism.

**Independent Test**: Define a signal and a task that sleeps on its key with a deadline; deliver a value and assert
the task wakes with `signal`, and let the deadline pass and assert it wakes with `expired`; memoize a key in a
replay-safe tool and assert a rerun reuses it; run a tool that makes two nested calls and parks on them with
`{kind: "wait", policy: "any"}`, assert the nested tasks have their own IDs and replay policies and their results
return as `NestedToolExecutionResult` without entering the transcript; register an approval gate and assert a risky
call sleeps until the approval signal arrives or blocks after the deadline.

**Acceptance Scenarios**:

1. **Given** a task sleeping on signal key `K` with a deadline, **When** a value is delivered under `K`, **Then**
   the task wakes with reason `signal` and reads the value; **When** the deadline passes first, **Then** it wakes
   with reason `expired` and the key is marked expired.
2. **Given** a key that already holds a consumed value, **When** a second wait sleeps on it, **Then** the commit
   rejects (the task) or the call ends `invalid_park` (the tool), preventing an immediate-forever wake loop.
3. **Given** a replay-safe tool that memoizes an idempotency key before an external effect, **When** it reruns
   after a crash, **Then** the memo returns the same key and the external service is not called twice.
4. **Given** a tool that parks `{kind: "wait", on: [a, b], policy: "any"}`, **When** either nested call is
   terminal, **Then** the tool resumes with `wake.reason === "tasks"` naming the ended call and reads its result
   from the caller's `NestedCallDoc`, which retires when the caller settles.
5. **Given** a `beforeTool` hook that sleeps a risky call until an approval signal, **When** the call is approved
   within the deadline, **Then** it executes with the approved arguments; **When** the deadline passes, **Then** it
   blocks with "No approval within a day".

---

### User Story 5 - Subagents, Ownership/Abort, Durable Compaction, Views/Watches, Usage, and Provider Identity (Priority: P1)

A host runs foreground and background subagents as tasks owned by the conversation or by another task; ownership is
immutable and owned work cannot outlive its owner. A tool or extension can hand work to a child conversation (a
subagent) and wait for it, or run it in the background behind an ownership boundary. Abort cascades down the
ownership tree to foreground work, stops at background boundaries, and a terminal owner never cascades. Compaction
replaces an old prefix of the model context with a headed summary without deleting history, started manually, by a
threshold, or on overflow, with a resolved policy and a pure range-selection function. A conversation exposes a
committed view — a window over the transcript plus its built-in documents — through watches and observers that
derive each revision from the Session's commits. The runtime records usage per model and per tool in `pi.usage`,
reports failures and lifecycle events through the telemetry contract (the typed `DURABLE_TELEMETRY_SCHEMA` spans and
events, and `onReport` for failures that do not fail the calling operation), and carries the conversation's persisted
provider session identity across requests.

**Why this priority**: Subagents, ownership/abort, compaction, and views are the durable runtime's composition and
recovery surface — the part that makes a long-running, restartable agent usable by a host. They are also the parts
the current Dart harness either lacks or only approximates. The architecture plan (§6.6 slice 6, §10) makes durable
compaction and committed views explicit deliverables of this slice.

**Independent Test**: Create a foreground subagent task and a background one; abort the parent and assert the
foreground child receives an abort mark and its abort handler runs after its owned work drains, while the
background child is not marked but is stopped by a plain session close; trigger a blocking compaction and assert it
appends a `pi.compaction` entry with `head` at the first kept entry and removes the status; mount a conversation
view and assert it yields document operations mapped under `docs` plus entry splices; sum `pi.usage` across
conversations and assert a fork starts at zero; and configure a telemetry host and assert the harness emits the typed
`pi.durable.*` spans/events and reports a non-fatal failure through `onReport` without failing the caller.

**Acceptance Scenarios**:

1. **Given** a live parent task owning a foreground child, **When** the parent is aborted, **Then** the child gets
   an abort mark, its abort handler runs before the parent's observing the child's final outcome, and new owned
   work under the abort-marked owner is refused.
2. **Given** a task that owns a background subagent, **When** the owner is aborted, **Then** the background
   subagent is not marked and does not block the owner's finish, but a plain session close stops it.
3. **Given** a conversation whose context exceeds `contextWindow - reserveTokens`, **When** a generation prepares,
   **Then** a blocking compaction owned by the generation runs, the generation waits for it with `allSettled`, and
   on success appends the request in the new context; on failure it ends `model_error`.
4. **Given** a mounted conversation view, **When** a commit touches the conversation, **Then** the observer receives
   one batch of document operations mapped under `docs["<kind>"]` followed by that observer's entry splices, and
   head markers stay in place in `entries`.
5. **Given** assistant and tool-result entries with usage, **When** they are committed, **Then** `pi.usage.models`
   and `pi.usage.tools` accumulate the spend in the same commit, and `Harness.usage()` sums every conversation
   while a fork starts at zero.
6. **Given** a configured telemetry host, **When** the harness runs a generation, tool call, and compaction,
   **Then** it emits the typed `pi.durable.*` spans and events, and a failure that does not fail the calling
   operation (a hook throw, a malformed after-run task, a stale write) is reported through `onReport` with its
   `kind`, without failing the caller.

---

### User Story 6 - Durable Code Mode and Deterministic Replay (Priority: P2)

A host exposes a code-mode tool that runs model-written JavaScript in a sandbox where the only capability is calling
injected tools, and the script survives a restart. The tool is replay-safe by deterministic replay: the sandbox runs
only when the host hands it a result, and given the same start data, clock, seed, and results in the same order, it
makes the same calls with the same arguments. A journal, written before each delivery, records the VM call ID, the
clock value, the calls the VM had issued, and a global's outcome; nested calls reattach to their tasks by key so
they never run twice unless their own replay policy reruns them. A rerun refuses to replay — and ends with an error
result — when the module version or VM fingerprint changed, when the deadline passed, or when the script diverges
from the journal.

**Why this priority**: Durable code mode is the architecture plan's slice 7 prerequisite landing early here because
the durable harness's code-mode tool is built on this slice's generation/tool/nested-call machinery (§6.6). It is
P2 because it is one tool, not the runtime spine, but it is in scope because the issue names it and it exercises
the replay contract end to end.

**Independent Test**: Run a code-mode script that makes nested reads; crash mid-script and reopen; assert the tool
resumes from the journal, hands the sandbox the results it got before in order, reattaches nested calls by key
without rerunning them, and completes; then change the module version or make the script diverge and assert the
rerun refuses to replay and ends with an error result.

**Acceptance Scenarios**:

1. **Given** a replay-safe code-mode script that made nested calls, **When** the host crashes before the result
   commits, **Then** the rerun starts the script again from the stored start data and hands it the prior results in
   order from the journal, never rerunning an already-settled nested call.
2. **Given** a code-mode rerun where the script issues a different call than the journal records, **When** the
   divergence is detected, **Then** the call ends with an error result and no new nested calls are admitted.
3. **Given** a code-mode call whose deadline has passed, **When** it reruns, **Then** it refuses to replay and ends
   with an error result.
4. **Given** a code-mode call that completes, **When** its outcome is committed with the store writes in one
   transaction, **Then** a later rerun returns that outcome without starting a VM.

---

### User Story 7 - Runtime Parity, Provably Scoped and Grounded (Priority: P2)

A maintainer wants to know that this slice ported the durable agent runtime and nothing more: no Zuraffa entities,
no browser concepts, no MCP policy, no renamed runtime model, no second agent loop, and no convenience API invented
ahead of the upstream source that defines it. The slice updates only its own coverage-manifest rows, each naming the
exact verified upstream SHA and every remaining gap, and it does not advance the verified upstream SHA or claim
parity for the port as a whole. The differential tests it ports are the evidence; a row that cannot be
differentially tested says so explicitly and is not `verified` on that basis.

**Why this priority**: The port's value is that it is a faithful, provable port. A runtime slice that quietly
invents API, imports a product package, or stands up a second agent loop would make every parity claim built above
it unverifiable. This is a guardrail, so it follows the mechanisms it protects.

**Independent Test**: Scan the new Dart source for imports of `zuraffa`, `zuraffa_agent`, browser packages, or
product-domain code, and for any type or function not grounded in a named upstream source file; assert none exist;
inspect the coverage rows this slice touched and assert no row outside the durable-agent-runtime set changed and the
verified SHA is unchanged; run the differential harness's scripted scenarios against both implementations and assert
the normalized outcomes are equal, then perturb the Dart behavior and assert the harness reports a divergence.

**Acceptance Scenarios**:

1. **Given** the new Dart library code, **When** the purity scan runs, **Then** zero imports of `zuraffa`,
   `zuraffa_agent`, browser packages, or product-domain code are found.
2. **Given** the coverage manifest, **When** this slice is recorded, **Then** only durable-agent-runtime rows
   changed, and `verified_upstream_sha` is unchanged.
3. **Given** a durable-agent behavior with no upstream source, specification, test, or example behind it, **When**
   the row is reviewed, **Then** it is absent rather than marked verified.
4. **Given** the differential harness, **When** a scripted scenario runs on both implementations, **Then** the
   normalized event stream, transcript, task state, and usage are equal, and a perturbed Dart behavior is reported
   as a divergence and its row is not `verified`.
5. **Given** full global parity (every applicable row verified at one SHA), **When** a slice row is inspected,
   **Then** the row distinguishes this slice's verification from full global parity and links any remaining gap to
   its tracking issue.

---

### Edge Cases

- **Crash after a generation's tool-calling answer committed but before its tool tasks were created.** Reopen finds
  the `tools` checkpoint and creates the tool tasks; no call is lost and none is duplicated.
- **A tool round with a sequential execution mode, crashed between calls.** The `tools` checkpoint holds the
  started tasks and the `pending` call IDs; reopen creates the next pending call's task and waits on the shorter
  list.
- **A `handoff` tool round vs. a queued reset at the same boundary.** A queued reset wins over a handoff written
  before it; the run's inputs settle `unanswered` with `reset` and selected user items start a successor run.
- **A stale head write targeting an entry older than the active range start.** It settles `unanswered` with `stale`
  and is removed; a `head: "self"` write is never stale.
- **A `continue` submitted while the conversation is busy.** It is rejected with `ConversationBusy` before any
  write; a continue on an idle conversation whose context does not end in a user message or tool results ends
  `unanswered` with `nothing_to_answer`.
- **An abort arriving while a generation's request or deferred poll is in flight.** The attempt is charged against
  the retry policy first; at the restart limit the run ends `interrupted` or `restart_limit`, not silently retried.
- **A registry install replacing an extension while a call is parked at its gates.** The call is woken with no wake
  and re-runs its whole `call` phase; if its `until` has passed it takes the deadline path.
- **A nested call whose replay-safe caller reruns after recovery.** It reuses the committed result by key; a caller
  that is not replay-safe had its nested calls abandoned before they ran and settles `interrupted`.
- **A compaction that finds nothing to compact or is declined.** It completes with `{}` and removes its status; a
  blocking compaction whose outcome lacks an `entryId` fails an overflow generation with `model_error`.
- **A code-mode rerun after the module version or VM fingerprint changed.** It refuses to replay and ends with an
  error result rather than running a divergent script.
- **A signal value delivered before any wake used it.** It is not consumed, so a later sleep on that key wakes at
  once; a second wait for the same signal uses a new key.

## Requirements

### Functional Requirements

#### Durable Generation

- **FR-001**: The port MUST provide the `pi.generation` task (version 3) with the upstream phases `prepare`,
  `request`, `retry`, `poll`, `tools`, `finish`, `drain`, `afterTools`, and `yield`, each with the upstream
  checkpoint shape, starting at `{phase: "prepare", attempt: 1}` and migrating older records as upstream does.
- **FR-002**: `prepare` MUST resolve the conversation's agent and settings once, fail `no_model` when no model is
  configured or known, fail `nothing_to_answer` when the committed context does not end in a user message or tool
  results (system messages aside), check compaction thresholds, and append the planned `pi.system` entries before
  moving to `request` with the pinned model, thinking level, stream options, and `cutoff`.
- **FR-003**: `request` and `poll` MUST resolve the checkpoint's model through `models.getModel()`, convert a
  leftover partial to an aborted `pi.assistant` entry, stream the model context with the invocation signal,
  thinking level as `reasoning` (omitted for `off`), the conversation's persisted provider `sessionId`, and the
  pinned stream options, committing throttled partials deferred, and classify the terminal message.
- **FR-004**: Classification MUST handle `stop`/`length` (running the `onYield` chain, applying the final boundary,
  or starting a successor generation), `toolUse` with at least one call (starting a tool round), retryable `error`
  within the retry policy (sleeping at `retry`), non-retryable `error` or `aborted` (settling inputs `unanswered`
  with `model_error`), context `error` recognized by `isContextOverflow()` (creating a blocking compaction), and
  `deferred` (sleeping at `poll`).
- **FR-005**: A host death while a request or deferred fetch was in flight MUST charge the attempt against the retry
  policy (a close does not charge); past `restartLimit` the run MUST end `restart_limit`, and a run that answered
  already in `finish`/`drain`/`yield` MUST end without a failure with its inputs `done`.

#### Durable Tool Tasks

- **FR-006**: The port MUST provide the `pi.tool` task (version 4) with input `{kind: "model"|"nested", …}` and
  phases `call`, `execute`, and `parked`, migrating a version-1 input to `kind: "model"` and older checkpoints as
  upstream does.
- **FR-007**: `call` MUST read the call, resolve the tool among the phase agent's tools (settling `tool_unavailable`
  for an `unoffered` call), validate arguments with the schema before and after the `beforeTool` chain, and on a
  `sleep` from the chain park the call at its gates as `sleeping` at `{phase: "call"}` so every wake re-runs `call`
  from the top; on a `block` settle with the block text.
- **FR-008**: Once intent is committed, `execute()` MUST run with the final arguments, the `afterTool` chain, and
  the committed result; a throw becomes a `tool_error` result, and a `ToolPark` (`sleep`/`wait`) parks the call so
  it holds no invocation.
- **FR-009**: The port MUST honor the tool's replay policy: `safe` (the default is `unsafe`) reruns `execute()` after
  a crash before its result committed; `unsafe` runs the tool's `cancel` cleanup and settles an `interrupted` error
  result; omitted `outputLimits` are 50 KiB, 2,000 lines, `retain: "head"`.
- **FR-010**: The port MUST bound retained output to whole lines of the stream per the limits, sanitize control
  characters, throttle progress commits per `settings.progress`, and emit diagnostics as a channel (never into the
  model's data) ending with one `<harness>` text item per the upstream format.

#### Submissions, Inbox, and Run Control

- **FR-011**: The port MUST provide the built-in `pi.inbox` document (`kind: "pi.inbox"`, version 1, conversation
  scope, latest history, initial fork) holding ordered `InboxItem`s (`steer`/`followUp` inputs and `write` entries),
  created with every Harness conversation.
- **FR-012**: Admission MUST deduplicate by `requestId` within one conversation before any write, rejecting a reuse
  for the other submission type; place an input on an idle conversation with a user entry and create a run and
  generation; queue a busy input by `whenBusy` (`steer`/`followUp`/`reject`); reject an idle input with
  `whenIdle: "reject"` (`ConversationIdle`); and settle a display-only write `done` in the same commit ahead of
  earlier queued submissions (behind a queued reset).
- **FR-013**: The port MUST provide the `continue` submission (idle only, never queues, rejected `ConversationBusy`
  when busy), ending `unanswered` with `nothing_to_answer` when the context has nothing to answer.
- **FR-014**: The port MUST provide the built-in `pi.live` document (version 3) carrying `run`, `generation`,
  `tools`, `nestedTools`, `compactions`, `compactionFailure`, and `runFailure` with the upstream shapes, migrating
  versions 1 and 2 as upstream does.
- **FR-015**: Boundaries MUST select queued items deterministically by ID with the settings' `steeringMode` and
  `followUpMode` (`one-at-a-time` or `all`), placing selected writes first in ID order then selected user items, and
  treating a `head: "self"` write at `postTools` as `final`.
- **FR-016**: `afterFailedRun` MUST decide what a run failing with `model_error`, `no_model`, `interrupted`,
  `restart_limit`, `nothing_to_answer`, or `turn_limit` does with queued inputs: `keep` (default) leaves them
  queued, `continue` runs the final boundary, `withdraw` settles them `unanswered` with `run_failed` keeping queued
  writes.

#### Extensions, Hooks, and Configuration

- **FR-017**: The port MUST provide an extension registry (`createRegistry`) that installs/uninstalls immutable
  extensions in place, publishes synchronously, notifies subscribers, and validates uniqueness and section-key rules
  (`^[a-z][a-z0-9_-]*$`, `instructions` reserved) as it would be after the replacement.
- **FR-018**: The port MUST provide `defineExtension`, `section`, `hook`, `wrapTool`, and `wrapSection`, where an
  extension bundles tools, sections, hooks, wrappers, and task definitions, and the built-in tasks are always present
  and not an extension.
- **FR-019**: Resolution MUST compute a conversation's agent from its stored `pi.agent`, a registry snapshot, and the
  settings: extensions (array or `{add, remove}`), tools (extension order, later same-name replaces in place, then
  wrappers, then `tools`/`modelTools` filters and `callers`), sections (same-key replacement then wrappers then
  `instructions`), hooks (selected extensions' hooks for the task's name in extension order), model, thinking, cwd,
  and compaction.
- **FR-020**: The port MUST dispatch the upstream hooks (`beforeRequest`, `beforeProviderRequest`, `afterResponse`,
  `onYield`, `beforeTool`, `afterTool`, `afterTools`, `afterRun`, `beforeCompact`) with the upstream composition
  (replacement chain, first result wins, all observers, block/sleep), running them off the line in extension order,
  with durable first-writer-wins decisions through task memos.
- **FR-021**: The port MUST provide per-conversation configuration (`configure`) that changes one conversation's
  stored agent, and registry reload that makes no commit and changes no view, with a conversation on the default
  selection changing on its next preparation.
- **FR-022**: Hooks MUST match by task name so they survive a reload of their task, and a registry install while a
  call is parked at its gates MUST wake it with no wake to re-run its `call` phase.

#### Signals, Idempotency, Parks, and Nested Calls

- **FR-023**: The port MUST provide `defineSignal` (unique name without `/`, positive version, JSON schema, optional
  migrate) yielding a `SignalToken` whose `key()` produces a `SignalKey`, and `tx.signal()`/`Harness.signal()`
  delivering a value under a key with the upstream result taxonomy (`delivered`, `duplicate`, `invalid`, `closed`,
  `not_found`).
- **FR-024**: A task or tool MUST park by sleeping on signal keys with an optional finite deadline (or waiting on
  owned tasks), resume with `signal`/`expired`/`time`/`tasks` wake, and a sleep on a consumed or expired key MUST
  reject (the task) or end `invalid_park` (the tool).
- **FR-025**: The port MUST provide memoized first-writer-wins values (`memo`/`memoSet`) so a replayed external
  effect reuses its idempotency key.
- **FR-026**: The port MUST provide nested calls (`executeTool` with `wait: true|false`) as their own `pi.tool` tasks
  owned by the caller, keyed by `<callId>/<key>`, recording their state in a task-scoped `NestedCallDoc`
  (`pi.tool.nested-call`) that retires with the caller, returning a `NestedToolExecutionResult` that never enters
  the transcript and a replay-safe caller reusing a committed result by key.
- **FR-027**: The port MUST provide `beforeTool` gates that sleep a call at its gates until a signal arrives or a
  deadline passes, binding the approval to the arguments it saw, with one memoized deadline per question.

#### Subagents, Ownership, Compaction, Views, Usage, and Identity

- **FR-028**: The port MUST support foreground and background subagents as tasks owned by a conversation or another
  task, with immutable owner edges, owned work not outliving its owner, a background task as an abort boundary, and
  `createTask`/`createConversation` under a `completing`/`terminal`/abort-marked owner rejected.
- **FR-029**: The port MUST implement the abort protocol (commit abort mark, signal and join the active invocation,
  wait for owned work to drain, run a fresh abort invocation that commits the terminal outcome) and an idempotent
  cascade to foreground-owned work that stops at background boundaries, with a terminal owner never cascading.
- **FR-030**: The port MUST provide the `pi.compaction` task (version 1, phases `select`/`summarize`/`retry`) that
  resolves the `CompactionPolicy` field by field, selects a range as a pure function of a `ContextView` and
  `keepRecentTokens`, summarizes with the pinned request, and places a `pi.compaction` entry whose `head` is the
  first kept entry without deleting history, in blocking (direct append) or conversation-owned (write submission)
  placement.
- **FR-031**: The port MUST provide a committed conversation view (`ConversationView`) mounting the transcript window
  and `pi.agent`/`pi.live`/`pi.inbox`/`pi.provider`/`pi.usage` under `docs`, exposed through watches and observers
  that derive each revision from the Session's commits, with head markers staying in place and a window that only
  appends.
- **FR-032**: The port MUST provide the `pi.usage` document (version 1) accumulating `models` (keyed
  `provider/modelId`) and `tools` (keyed by tool name) spend in the same commit as each assistant/tool-result entry
  and nested-call result and each compaction attempt, with `Harness.usage()` summing every conversation and a fork
  starting at zero.
- **FR-033**: The port MUST carry the conversation's persisted provider session identity (the built-in `pi.provider`
  document) across requests, passing it as the provider `sessionId` on generation and compaction requests, and
  handling providers that suppress that identity when caching is disabled.
- **FR-033a**: The port MUST report through the telemetry contract — the typed `DURABLE_TELEMETRY_SCHEMA` spans and
  events the harness emits (generation attempts, tool rounds, compaction, submission, signal) and `HarnessOptions.onReport`
  for failures that do not fail the calling operation — with each report carrying its `kind` and origin, exactly as
  upstream's `harness/telemetry.ts` and `Report` define.

#### Durable Code Mode

- **FR-034**: The port MUST provide a durable code-mode tool that runs model-written JavaScript in a sandbox whose
  only capability is calling injected tools, replay-safe by deterministic replay: the sandbox runs only when the
  host hands it a result, and the same start data, clock, seed, and ordered results produce the same calls.
- **FR-035**: The port MUST journal each delivery (`pi.codemode.journal`) before delivering it, record the run's
  start data and outcome (`pi.codemode.run`), reattach nested calls to their tasks by key (`c<VM call id>`) so they
  never run twice unless their own replay policy reruns them, and reuse the committed outcome on a rerun after the
  call decided.
- **FR-036**: A code-mode rerun MUST refuse to replay (no new nested calls; ending with an error result) when the
  module version or VM fingerprint changed, when the deadline passed, or when the script diverges from the journal.

#### Differential Evidence and Scope Discipline

- **FR-037**: The port MUST port the upstream-derived differential tests that exercise every commit, crash, wake,
  replay-safe/unsafe tool, approval timeout, nested call, and failed-run continuation boundary in this slice, run
  against both implementations with no live paid provider, and a perturbed Dart behavior MUST be reported as a
  divergence.
- **FR-038**: The port MUST NOT import `zuraffa`, `zuraffa_agent`, a browser package, or product-domain code, and
  the check MUST fail on any such import.
- **FR-039**: The port MUST NOT introduce a runtime model, type, or function that renames or reinterprets an upstream
  concept, MUST NOT stand up a second agent loop, and MUST NOT invent convenience API ahead of the upstream source
  that defines it.
- **FR-040**: This slice MUST add coverage-manifest rows for the durable-agent-runtime areas only, each naming the
  exact verified upstream SHA and every remaining durable gap, and MUST NOT advance `verified_upstream_sha` or imply
  global parity.
- **FR-041**: Every coverage row MUST distinguish this slice's verification from full global parity and explicitly
  link any remaining gap (full providers, MCP, coding-agent, TUI, evals, or global parity at one SHA) to its
  tracking issue.
- **FR-042**: This slice MUST preserve the `Depends on: arrrrny/pi#11, arrrrny/pi#2, arrrrny/pi#7` declaration
  verbatim and MUST NOT add a Zuraffa wrapper or any product integration.

### Key Entities

- **Generation Task**: The durable `pi.generation` state machine: prepare, request, retry, poll, tools, finish,
  drain, afterTools, yield.
- **Tool Task**: The durable `pi.tool` state machine: call, execute, parked; one per model or nested tool call.
- **Compaction Task**: The durable `pi.compaction` state machine: select, summarize, retry.
- **Submission**: An awaitable host object (input, write, continue) with a request ID, dedup, and a settlement state.
- **Inbox Item**: An ordered `steer`/`followUp` input or `write` entry in the `pi.inbox` document.
- **Live State**: The `pi.live` document's run control and presentation state (run, generation, tools, nestedTools,
  compactions, runFailure).
- **Extension**: A named, immutable bundle of tools, sections, hooks, wrappers, and task definitions.
- **Registry**: The process-local install/uninstall/publish surface of extensions, read as immutable snapshots.
- **Hook**: A typed question a task asks before committing a decision, dispatched in extension order.
- **Signal**: A typed JSON value delivered to a waiting task under a key naming one wait.
- **Memo**: A first-writer-wins durable value in the task's memos, used for idempotency keys and gate deadlines.
- **Tool Park**: A `sleep` or `wait` a tool returns instead of a result, holding no invocation.
- **Nested Call**: A tool call made by a running tool as its own `pi.tool` task, keyed and recorded in
  `NestedCallDoc`.
- **Subagent**: A foreground or background task or conversation owned by another task, reached by ownership
  traversal.
- **Conversation View**: A committed window over the transcript and built-in documents, exposed through watches.
- **Usage**: The `pi.usage` ledger of per-model and per-tool spend.
- **Coverage Row**: One durable-agent-runtime behavior's ledger record, pinned to the verified upstream SHA, with its
  Dart implementation, tests, status, divergence, and tracking issue.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A scripted conversation that emits a tool call, a retryable error, and an answer, killed at every
  commit boundary, reopens with the generation resumed at its checkpoint, the streamed partial converted to an
  aborted entry, and zero duplicated tool effects; across the crash suite, zero runs lose committed progress.
- **SC-002**: A task whose `restarts` reaches `settings.restartLimit` ends with the upstream outcome (tool
  `restart_limit` result, compaction `compactionFailure`, generation `runFailure` reason `restart_limit`, extension
  task `faulted`); across the crash suite, zero tasks loop forever.
- **SC-003**: A reused request ID is deduplicated with no second write; a busy input steers per `steeringMode`; a
  failed run applies `afterFailedRun` (`continue`/`keep`/`withdraw`) exactly as upstream specifies; a fork starts
  with an empty inbox.
- **SC-004**: Two extensions naming the same tool resolve with the later winning in place; a `beforeTool` block
  settles the call with the block text; a per-conversation `configure` changes only that conversation; a registry
  publication wakes a parked gate with no wake.
- **SC-005**: A signal value wakes a sleeping task with `signal` and a passed deadline wakes it with `expired`; a
  consumed key rejects a second wait; a replay-safe tool reuses its memoized idempotency key; a parked tool resumes
  on its nested calls' tasks and the nested result never enters the transcript.
- **SC-006**: An abort of a parent reaches every foreground descendant with each abort handler observing final child
  outcomes, while a background subagent is not marked and is stopped by a plain close; zero work outlives its
  owner.
- **SC-007**: A blocking compaction appends a `pi.compaction` entry with `head` at the first kept entry and removes
  its status; a conversation view yields document operations mapped under `docs` plus entry splices; `pi.usage`
  accumulates per model and per tool and a fork starts at zero; and a configured telemetry host receives the typed
  `pi.durable.*` spans/events while a non-fatal failure is reported through `onReport` without failing the caller.
- **SC-008**: A code-mode script crashed mid-run resumes from its journal, reattaches nested calls by key without
  rerunning them, and completes; a divergent or version-changed or deadline-passed rerun refuses to replay and ends
  with an error result.
- **SC-009**: The differential harness runs each scripted scenario against both implementations with no live
  provider call, and a deliberately perturbed Dart behavior is reported as a divergence and its row is not
  `verified`.
- **SC-010**: A scan of the new Dart library finds zero imports of `zuraffa`, `zuraffa_agent`, browser packages, or
  product-domain code, and zero renamed, invented, or second-loop runtime types.
- **SC-011**: Only durable-agent-runtime coverage rows change; `verified_upstream_sha` is unchanged; each row
  distinguishes this slice's verification from full global parity and links its remaining gap to a tracking issue.

## Assumptions

- **Depends on**: arrrrny/pi#11, arrrrny/pi#2, arrrrny/pi#7 — preserved verbatim. pi#11 provides the durable
  storage/task foundation (Session commit boundary, immutable entries, typed documents, conversations, the task
  runtime with checkpoints/waits/sleeps/ownership/abort, signals primitives, and the three storage backends) this
  slice builds its generation, tool, submission, signal, and compaction tasks on. pi#2 (steering/follow-up queue
  modes) and pi#7 (model-backed compaction) are the baseline correctness fixes this slice's inbox boundaries and
  compaction task must not regress. Where pi#10's coverage tooling is not yet built, this slice records its rows in
  the registry shape pi#10's spec defines (`coverage/registry/behavior-registry.json` per
  `specs/002-upstream-coverage-governance/data-model.md`) and states that dependency explicitly rather than inventing
  a second manifest format.
- **Target SHA**: `780bf31fcaeb252fa9b68df3964c735eae75bde3`, the upstream commit every durable-agent package
  (`durable`, `agent`, `ai`, `codemode`, with `schema`, `telemetry`, `chord`, `env`) is read at. Those package
  trees are byte-identical between that commit and this checkout's `HEAD`, so the port reads the target SHA's
  content.
- **Normative reference wins**: the architecture plan linked in the header is normative; where this spec and that
  plan disagree, the plan wins and this spec is corrected.
- **Strict port only**: every Dart type, function, and error in this slice is grounded in a named upstream source
  file, specification section, test, or example at the target SHA. No Zuraffa entities, no browser concepts, no MCP
  policy, no renamed runtime model, no second agent loop, no speculative convenience API. `zfa` is not applicable:
  this package is a hand-written port, not a Zuraffa application.
- **Scope boundary**: this slice ports the durable agent runtime (generation, tools, submissions, signals, parks,
  nested calls, approvals, extensions, subagents, compaction, views, usage, identity, and durable code mode). It
  consumes the pi#11 foundation and the upstream `agent`/`ai`/`codemode` contracts; it does not re-port the
  foundation, does not port full providers, MCP, coding-agent, TUI, or evals, and does not wire the existing
  `package:pi/pi.dart` wrappers (`Agent`, `AgentLoop`, `Conversation`) onto the durable runtime — the durable
  runtime is additive, exported through `package:pi/durable.dart`.
- **One package, new entry surface**: the runtime lives under `pi_agent/lib/src/durable/harness/` (alongside the
  pi#11 `pi_agent/lib/src/durable/` foundation) and is exported through `package:pi/durable.dart`, mirroring
  upstream's package boundary without disturbing the existing `package:pi/pi.dart` surface.
- **Pure Dart**: the runtime adds no dependency beyond what pi#11 established (`dart:async`, `dart:convert`,
  `dart:typed_data`); it consumes the pi#11 `schema`, `telemetry`, `chord`, and `env` ports and the pi-ai model
  catalog/streaming contract as an injected `Models` seam, with scripted providers and virtual clocks in tests and
  no paid live provider.
- **Durable code mode sandbox seam**: the QuickJS-in-Wasm sandbox sits behind an injectable host seam (the upstream
  `CodemodeSandboxBase`/host boundary); the deterministic-replay journal and reattach logic are pure Dart over that
  seam, and a real Wasm driver lands with a platform adapter, not in this slice's core.
- **Coverage rows never advance global parity**: this slice marks only its own rows and leaves
  `verified_upstream_sha` untouched; full parity is global at one SHA and is not implied by any slice. Each row
  distinguishes this slice's verification from full global parity and links any remaining gap to its tracking issue.
- **Differential evidence is best-effort where practical**: where a behavior cannot be differentially tested against
  the TypeScript oracle, its row says so explicitly and is not `verified` on that basis.