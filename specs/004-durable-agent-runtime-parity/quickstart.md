# Quickstart: Durable Agent Runtime Parity

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)
**Oracle**: `earendil-works/pi` at `780bf31fcaeb252fa9b68df3964c735eae75bde3`

This is the validation guide for the slice. It lists the commands that prove the durable agent runtime works end to
end and what each one must show. It is not the implementation; the implementation lives in
`pi_agent/lib/src/durable/harness/`, `pi_agent/lib/src/durable/signals.dart`, `pi_agent/lib/src/durable/codemode/`,
and `pi_agent/test/durable/`.

## Prerequisites

- Dart SDK ^3.0.0 (the `pi_agent` constraint).
- The pi#11 foundation landed: `pi_agent/lib/src/durable/` has the Session, task runtime, documents, and storage, and
  `package:pi/durable.dart` exports them.
- `pi_agent/` dependencies fetched: `cd pi_agent && dart pub get --ignore-scripts`.
- The upstream oracle is read from the local checkout at the target SHA; no network call is required to run the Dart
  tests. Paid live providers are never a test dependency (scripted providers and a virtual clock are).

## Layout after implementation

```text
pi_agent/
├── lib/durable.dart                      # pi#11 entry library (extended, not replaced)
├── lib/src/durable/
│   ├── signals.dart                      # defineSignal, SignalToken/Key/State, SubmissionSettled
│   ├── harness/                          # the durable agent runtime
│   │   ├── types.dart define.dart registry.dart registry_reader.dart
│   │   ├── generation.dart tool.dart scheduler.dart agent.dart harness.dart
│   │   ├── live.dart inbox.dart submissions.dart context.dart compaction.dart
│   │   ├── view.dart transcript.dart usage.dart provider.dart task_graph.dart
│   │   ├── prompt.dart partial_changes.dart telemetry.dart parks.dart json.dart util.dart
│   └── codemode/                         # codemode.dart describe.dart models.dart output.dart
└── test/durable/
    ├── harness/                          # generation/tools/submissions/signals/compaction/view/usage
    ├── codemode/                         # deterministic-replay and divergence tests
    └── differential/                     # scripted-provider, virtual-clock differential scenarios
```

## 1. Type-check and lint

```bash
cd pi_agent
dart analyze
```

Expected: no errors, no warnings, no infos. Any forbidden import (`package:zuraffa`, `package:zuraffa_agent`, a
browser package, a product-domain package) fails here.

## 2. Unit tests

```bash
cd pi_agent
dart test -j 2 test/durable/harness
dart test -j 2 test/durable/codemode
```

Expected: all pass. One test file per source file; the upstream-derived cases are ported case by case.

## 3. Differential scenarios

```bash
cd pi_agent
dart test -j 2 test/durable/differential
```

Each scenario runs the same scripted provider, virtual clock, storage ops, signals, and crash points against the
TypeScript oracle and the Dart port and compares normalized outcomes (event stream, transcript, task state, stored
commits, errors, usage). Expected: equal, with no live provider call. Perturb the Dart behavior and the harness
reports a divergence.

## 4. The end-to-end scenarios that must pass

These mirror the spec's acceptance scenarios; each is a differential scenario with a scripted provider.

- **Generation crash-and-resume** — a scripted model emits a tool call, a retryable error, and an answer; kill at
  each commit boundary; assert the generation resumes at its checkpoint, the streamed partial is converted to an
  aborted entry, and no tool effect is duplicated.
- **Tool replay policy** — a replay-safe tool reruns once after a crash and reuses its memoized idempotency key; a
  replay-unsafe tool runs `cancel` and settles `interrupted`.
- **Restart limit** — a task that crashes in a loop ends with the §5.4 outcome (`restart_limit` result /
  `compactionFailure` / `runFailure` / `faulted`) rather than looping.
- **Submission dedup and steering** — a reused `requestId` is deduplicated with no second write; a busy input steers
  per `steeringMode`; a failed run applies `afterFailedRun` (`continue`/`keep`/`withdraw`).
- **Extensions** — two extensions naming the same tool resolve with the later winning in place; a `beforeTool` block
  settles the call with the block text; a per-conversation `configure` changes only that conversation; a registry
  publication wakes a parked gate.
- **Signals, parks, nested calls** — a signal value wakes a sleeping task with `signal`, a passed deadline with
  `expired`; a parked tool resumes on its nested calls' tasks and the nested result never enters the transcript.
- **Subagents and abort** — aborting a parent reaches every foreground descendant with each abort handler observing
  final child outcomes, while a background subagent is not marked and is stopped by a plain close.
- **Compaction and view** — a blocking compaction appends a `pi.compaction` entry with `head` at the first kept
  entry; a mounted view yields document operations mapped under `docs` plus entry splices; `pi.usage` accumulates per
  model and per tool and a fork starts at zero.
- **Code mode** — a script crashed mid-run resumes from its journal, reattaches nested calls by key without rerunning
  them, and completes; a divergent/version-changed/deadline-passed rerun refuses to replay and ends with an error.

## 5. Purity and scope checks

```bash
cd pi_agent
# No forbidden imports (SC-006 / FR-038).
grep -rnE "package:(zuraffa|zuraffa_agent|zuraffa_browser)" lib/src/durable/harness lib/src/durable/signals.dart lib/src/durable/codemode || echo "clean"
# No second agent loop: the only generation loop is pi.generation (SC-010 / FR-039).
grep -rn "while (true)" lib/src/durable || echo "no unbounded loops"
```

Expected: clean — no `zuraffa`/`zuraffa_agent`/browser import, no second agent loop. The existing
`package:pi/pi.dart` surface is untouched.

## 6. Coverage rows

The durable-agent-runtime rows are recorded in the pi#10 registry shape
(`coverage/registry/behavior-registry.json` per `specs/002-upstream-coverage-governance/data-model.md`), as listed in
[coverage-rows.md](./coverage-rows.md). Inspect that only this slice's rows changed and that `verified_upstream_sha`
is unchanged:

```bash
git diff --stat master -- coverage/            # only this slice's rows
grep -n 'verified_upstream_sha' coverage/state.json
```

Expected: only durable-agent-runtime rows changed; `verified_upstream_sha` is `null` (or its prior value) and did not
advance; each row distinguishes this slice's verification from full global parity and links its remaining gap.

## Definition of done

- `dart analyze` clean; `dart test -j 2` green for `test/durable/harness`, `test/durable/codemode`, and
  `test/durable/differential`.
- The end-to-end scenarios above pass as differential scenarios against the TypeScript oracle.
- Purity scan clean; no second agent loop; `package:pi/pi.dart` unchanged.
- Coverage rows: durable-agent-runtime only, `verified_upstream_sha` unchanged, pi#12 scope explicitly deferred for
  the rest.