# Quickstart: Durable Storage and Task Foundations

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)
**Oracle**: `earendil-works/pi` at `780bf31fcaeb252fa9b68df3964c735eae75bde3`

This is the validation guide for the slice. It lists the commands that prove the foundation works end to end and what
each one must show. It is not the implementation; the implementation lives in `pi_agent/lib/src/durable/` and
`pi_agent/test/durable/`.

## Prerequisites

- Dart SDK ^3.0.0 (the `pi_agent` constraint).
- `pi_agent/` dependencies fetched: `cd pi_agent && dart pub get --ignore-scripts`.
- The upstream oracle is read from the local checkout at the target SHA; no network call is required to run the Dart
  tests.

## Layout after implementation

```text
pi_agent/
├── lib/durable.dart                      # the public entry library
├── lib/src/schema/                       # prereq: JSON value, schema, validate, coerce
├── lib/src/telemetry/                    # prereq: context, propagation, typed, noop
├── lib/src/chord/                        # context, json, delta, documents, watch, ids
├── lib/src/durable/
│   ├── types.dart entries.dart documents.dart errors.dart
│   ├── session/                          # line, transaction, writer, keys, cache, forks
│   ├── storage/                          # storage, memory, jsonl, sqlite, conformance
│   └── tasks/                            # definition, record, scheduler, abort, graph
└── test/durable/
    ├── conformance/                      # the shared suite, registered per backend
    ├── crash/                            # crash-and-reopen evidence
    └── *.test.dart                       # one per source file
```

## 1. Type-check and lint

```bash
cd pi_agent
dart analyze
```

Expected: no errors, no warnings, no infos. Any forbidden import (`package:zuraffa`, `package:zuraffa_agent`, a
browser package, a product-domain package) fails here.

## 2. Unit and conformance tests

```bash
cd pi_agent
dart test -j 2
```

Expected: every test in `test/durable/` passes. The fleet concurrency cap (`-j 2`) is mandatory.

The suite includes:

- **Storage conformance** — the 34-case shared suite from upstream
  (`packages/durable/src/testing/storage-conformance.ts`) registered once per backend (memory, JSONL, SQLite). Each
  backend passes every case; a deliberately broken backend fails and is named.
- **Session** — atomic commit, durability receipt, publication order, table access rules, detached values, failure
  taxonomy, close semantics.
- **Tasks** — checkpoints, waits (`allSettled`/`failFast`/`any`), sleeps and wakes, ownership, `completing` hold,
  abort cascades.
- **Documents** — scopes, base/delta selection, migrations, rewindable as-of reads, watches (retirement, root
  replacement, close).
- **Crash** — a scripted matrix that kills the session at each commit boundary and asserts the reopened state is a
  complete prefix of the log.

## 3. Crash-and-reopen evidence

```bash
cd pi_agent
dart test -j 2 test/durable/crash/
```

Expected: every run leaves the reopened state a complete prefix of the commit log; zero runs publish a partial commit;
a task killed after any checkpoint resumes at that checkpoint with its wake preserved (SC-002, SC-004).

## 4. Purity

```bash
cd /private/tmp/pi-durable-plans.n5riak/repo
grep -rnE "package:(zuraffa|zuraffa_agent)" pi_agent/lib/src/durable pi_agent/lib/durable.dart || echo "clean"
```

Expected: `clean` (SC-006).

## 5. Coverage rows

The foundation's behavior rows are recorded in the pi#10 registry shape
(`coverage/registry/behavior-registry.json` per `specs/002-upstream-coverage-governance/data-model.md`). Inspect that
only foundation rows changed and that `verified_upstream_sha` is unchanged:

```bash
cd /private/tmp/pi-durable-plans.n5riak/repo
git diff --stat master -- coverage/            # only this slice's rows
grep -n 'verified_upstream_sha' coverage/state.json
```

Expected: only foundation rows changed; `verified_upstream_sha` is `null` (or its prior value) and did not advance
(SC-007). Generation, tools, submissions, signals, and product missions remain unported and point at pi#12 (FR-042).

## 6. End-to-end smoke

A short script under `pi_agent/example/` (or a test) that:

1. Opens a `MemoryStorage` session.
2. Commits a conversation with a few entries and a document.
3. Closes and reopens the same storage; reads the entries and the document back.
4. Defines a two-phase task that parks on a sleep, commits a checkpoint, and completes after a virtual clock advance;
   kills and reopens between phases and asserts it resumes at the checkpoint.

Expected: the reopened transcript equals the committed one byte for byte; the task resumes with its wake reason
preserved (SC-001, SC-004).

## 7. What "done" looks like

- `dart analyze` clean; `dart test -j 2` green, including the shared conformance suite on all three backends and the
  crash suite.
- Purity grep clean.
- Coverage rows: foundation only, `verified_upstream_sha` unchanged, pi#12 scope explicitly deferred.
- No Zuraffa/browser/product import, no renamed or invented runtime type, no `any` in typed positions.