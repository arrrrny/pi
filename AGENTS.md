<!-- fleet-agents-pointer:begin -->
# ⚠️ FLEET RULES — LOAD ~/.agents/AGENTS.md FIRST

Before applying any rule in this file, load and follow `~/.agents/AGENTS.md`
— the fleet-level rules file every machine carries (synced from
`arrrrny/skills`, the single source of truth, by `sync-skills` inside
`kimi-code-update`, 3x/day). It owns the fleet-wide HARD RULES: the
skills-sync rule (every merge-PR task must check the repo's exposed skills —
create or update them on exported-behavior changes — and auto-PR them to
`arrrrny/skills`), the English-only response rule, the GitHub account
spelling (`arrrrny` = a + exactly 4 r's + ny), and the machine bootstrap
contract (`arrrrny/scripts` + `arrrrny/skills`). Future fleet-wide rule
changes are made ONCE in that file — never by editing every repo. Where this
file and the fleet file disagree, the fleet file wins unless this file is
MORE restrictive for this repo.
<!-- fleet-agents-pointer:end -->
# Development Rules

<!-- misfire-rule:begin -->
## ZURAFFA MISFIRE RULE (HARD, NON-NEGOTIABLE — HARDCODED TOP RULE)

**On ANY misfire (test failure, compilation error, runtime crash, unexpected output) related to zuraffa:**

1. **STOP IMMEDIATELY** on the first misfire.
2. **Report the issue** to zuraffa GitHub (`arrrrny/zuraffa`) with: the command that failed, expected vs actual output, and root cause.
3. **Continue with a workaround** to make the task pass (e.g., skip the failing test, use an alternative approach, or mock the failing component).
4. **Add a comment** in the code explaining the workaround applied and linking to the zuraffa GitHub issue.

**On ANY misfire related to the repo itself (not zuraffa):**

1. **STOP IMMEDIATELY** on the first misfire.
2. **Report the issue** to the repo's GitHub with full details.
3. **Continue with a workaround** to make the task pass.
4. **Add a comment** in the code explaining the workaround applied.

This rule takes precedence over all other rules. Never skip a misfire or rationalize it away.
<!-- misfire-rule:end -->

<!-- pool-pr:begin -->
## The forklift pool owns the PR — never merge a pull request yourself

Every pull request in these repos is reviewed by the **forklift pool**
(`arrrrny/forklift` — the local PR-review pipeline). It mints three tasks, in
this order, and that chain is the only sanctioned way from "PR opened" to "PR
merged":

1. `PR review <repo>#<n>` — the automated review; it posts its actionable
   findings on the PR.
2. `Apply review fixes <repo>#<n>` — one fixes round, pushed onto the PR's
   branch.
3. `Merge PR <repo>#<n>` — the merge itself; the task refuses while reviewer
   findings are still unaddressed.

**Never merge or close a PR by hand, and never merge one because it "looks
finished".** A hand merge lands the code while findings are still open: the
pool's fixes task is then killed by its closed-PR guard — the dispatcher log
says `…#<n> is closed — cancelled, no agent started` — and every finding the
review posted is dropped with nobody to own it. That is not a review, it is a
race the pipeline cannot win.

**Wait for the pool, and read the pool for the state.** The three task rows are
the truth; the PR page is not:

```bash
# the pool's board — loopback, IPv4-only (never `localhost`)
curl -s http://127.0.0.1:8888/tasks \
  | jq -r '.[] | select(.title | test("PR review|Apply review fixes|Merge PR")) \
          | [.title, .status, .id] | @tsv'
```

One row per stage. `status` is one of `queued`, `running`, `done`, `failed`,
`needsInput`, `cancelled`, `paused`. The PR is done when the
`Merge PR <repo>#<n>` row reads `done`. A fixes row that reads `failed` or
`cancelled` means the PR was **not** reviewed-and-fixed: read the row's
`errorMessage`, fix the cause, and let the pipeline requeue it (relabelling a
failed task requeues it in the same call — `POST /tasks/<id>/label`).

**An agent can simply wait for the whole process** — poll the board above until
the `Merge PR` row is terminal. Everything else is the pool's job: it drives
the review, the fixes round and the merge.
<!-- pool-pr:end -->

<!-- tmp-clone:begin -->
## Work in a `/tmp` clone — never in `~/Developer`

Every piece of work on a PR or an issue happens in its own clone under `/tmp`,
and that clone dies with the task:

```bash
git clone https://github.com/<owner>/<repo>.git /tmp/<repo>-<pr-or-issue>
```

Never clone into `~/Developer`, and never clone into the forklift checkout —
a bare repo slug as the clone target is how a stray checkout ends up inside the
repo root, and a clone left behind in `~/Developer` is indistinguishable from
the primary checkout. The pool's lanes already mint their clones this way
(`/tmp/fix-pr-<n>`, `/tmp/review-pr-<n>`, `/tmp/issue-<n>`, …) and remove them
when the task settles.
<!-- tmp-clone:end -->

## Conversational Style

- Keep answers short and concise
- No emojis in commits, issues, PR comments, or code
- No fluff or cheerful filler text (e.g., "Thanks @user" not "Thanks so much @user!")
- Technical prose only, be direct
- Use concise, clear, simple language. Define unavoidable jargon before using it.
- Explain non-trivial designs and problems as: problem, concrete example or short trace, then solution. State why the solution is necessary and distinguish it from optional complexity.
- Prefer concrete behavior and small illustrations over abstract summaries, dense terminology, or unexplained lists of changes.
- When the user asks a question, answer it first before making edits or running implementation commands.
- When responding to user feedback or an analysis, explicitly say whether you agree or disagree before saying what you changed.

## Code Quality

- Read files in full before wide-ranging changes, before editing files you have not fully inspected, and when asked to investigate or audit. Do not rely on search snippets for broad changes.
- Before recommending a fix design, check how sibling implementations (other adapters, providers, commands) handle the same concern, and follow that pattern. If you deviate, say why.
- No `any` unless absolutely necessary.
- Never tell the members of a typed union apart with `in` (`"report" in entry`): make it a tagged union (a `kind` field) and switch on the tag. `in` is only for values of unknown type at a trust boundary (wire input, files, Node errors), for feature detection, and for stored or frozen wire formats that a version bump would have to change (say so in a comment).
- No runtime checks of values whose types TypeScript already guarantees (no `typeof`/`instanceof`/`Array.isArray`/shape guards on typed parameters, typed callback results or typed declarations). Validate only at decided trust boundaries (wire input, schema-checked arguments and params).
- Inline single-line helpers that have only one call site.
- Check node_modules for external API types; don't guess.
- **No inline imports** (`await import()`, `import("pkg").Type`, dynamic type imports). Top-level imports only.
- In `packages/coding-agent`, resolve package assets through helpers in `src/config.ts`. Do not use `__dirname` directly; the helpers account for source checkouts, npm installations, and standalone binaries.
- Never remove or downgrade code to fix type errors from outdated deps; upgrade the dep instead.
- Use only erasable TypeScript syntax (Node strip-only mode) in code checked by the root config (`packages/*/src`, `packages/*/test`, `packages/coding-agent/examples`): no parameter properties, `enum`, `namespace`/`module`, `import =`, `export =`, or other constructs needing JS emit. Use explicit fields with constructor assignments.
- Always ask before removing functionality or code that appears intentional.
- Do not preserve backward compatibility unless the user asks for it.
- Never hardcode key checks (e.g. `matchesKey(keyData, "ctrl+x")`). Add defaults to `DEFAULT_EDITOR_KEYBINDINGS` or `DEFAULT_APP_KEYBINDINGS` so they stay configurable.
- Never modify `packages/ai/src/models.generated.ts` directly; update the catalog definitions in `packages/ai/catalog/` instead (see its README), then regenerate. Including the resulting `models.generated.ts` diff is always OK, even if regeneration includes unrelated upstream model metadata changes. The generated model data in `packages/ai/src/providers/data/` is gitignored: never stage it, and don't look for it in git history.

## Chord v2 Code Style

Binding for Chord v2 (`packages/chord/src/`) and its tests, when writing and when reviewing. The model is pi-durable's source.

- Files: one concept per file, named after it; no one-helper files, no grab-bag files. First line: a comment saying what the file is for. Order: imports, exported types, then the public entry point first and its helpers below it in the order they are used; constants right above their first user. A blank line between top-level declarations. Split files by concept, never by size: one concept may take a long file (up to about 1,000 lines is fine); a second concept in a file is the reason to split.
- Functions: every export has a one-line doc comment saying what it does or guarantees. Inline comments explain a non-obvious why (cost, race, decided rule), never what the next line does. Short functions with one job (about 40 lines needs a reason; one `switch` over a tagged union is fine). No boolean flag parameters that switch behaviour: two functions or a tagged value. Never write the same lines twice. Context last: required args, then `context`/`ctx` (always required, as in Durable; optional only on error-reporting paths), then optional args.
- Types and checks: tagged unions for every state and result. Casts only where TypeScript cannot express a decided invariant, each with a short why. Every remaining runtime check names the trust boundary it serves (wire input, schema-checked params and arguments, declaration policy the types cannot express). Same-host values are plain data, immutable by convention: never copied, frozen or walked to enforce it; freeze only Chord-owned metadata when a decision says so. No defensive code against broken adapters, callers or our own modules.
- Cost and memory: no hot-path work a decision did not ask for (walks, copies, compilations, per-call allocations). The function doing counted work counts it through its context; call sites never count for others. Caches are `WeakMap`s keyed by their owner, each with a GC test; no module-level strong caches.
- Names and API: the design's vocabulary (`params`, `binding`, `principal key`), no invented synonyms; decided `ChordError` codes and reasons. Export only what a later layer or app needs. No dev or test modes, no unrequested options.
- Tests: one test file per source file, one `describe` per mechanism, the layer spec's test list case by case; cost guards through the in-memory telemetry adapter; GC tests for every cache and binding. Every slice also adds one or more runnable examples in `packages/chord/test/examples/NN-topic.ts`, one topic each, numbered across slices, written as references for Chord's users (Durable's `test/examples/` format: header with what it shows and how to run it, commented steps, printed results).
- Slices: Chord v2 is built in vertical slices (`packages/chord/docs/slices.md`). Implementers and reviewers read the slice spec, the feature map in `slices.md` and the whole of `packages/chord/docs/design.md` in full, and check the work against all three; slice specs cite design sections for orientation, not as a reading limit.
- Deferred work: anything left to a later slice goes into the section "Carry-over" of `packages/chord/docs/slices.md` under that slice, in the same change; a slice's spec and build include every entry of its section.
- Before reporting: re-read every changed file top to bottom as a stranger would; each file must be understandable without jumping around. Then `npm run check` and the layer's tests.

## Reviews

- When reviewers (subagents or other sessions) report while others are still reviewing, do not summarize or relay their findings piecemeal. Wait until every report is in, then give one report that covers all of them.

## Commands

- After code changes (not docs): `npm run check` (full output, no tail). Fix all errors, warnings, and infos before committing. Does not run tests.
- `apps/p2` is outside the root check and the root tests. After p2 changes also run `cd apps/p2 && npm run check`; p2's suite is `cd apps/p2 && npm test` (TUI tests need Node 26, browser tests need `CHROMIUM_BIN`).
- Run `npm run build` whenever something needs built output (`dist/`): tests or benchmarks that import built packages, Durable's workerd suite. The full suites of Chord and Durable need it: Chord's tests that start Node processes or bundle with esbuild load workspace packages from `dist/` (the rest run from source by its vitest config), and Durable imports pi-ai's `utils/*`, which have no source export. Never use it to type check or lint: that is `npm run check`, the preferred check.
- Never run `npm test` unless requested by the user.
- Never run the full vitest suite directly: it includes e2e tests that activate when endpoint/auth env vars are present. For all non-e2e tests, run `./test.sh` from the repo root. It runs `packages/*` only. Otherwise run specific tests from the package root:
  - Vitest: `node "$(git rev-parse --show-toplevel)/node_modules/vitest/dist/cli.js" --run test/specific.test.ts`
  - `packages/tui` (`node:test`): `node --test test/specific.test.ts`
- If you create or modify a test file, run it and iterate on test or implementation until it passes.
- For `packages/coding-agent/test/suite/`, use `test/suite/harness.ts` + the faux provider. No real provider APIs, keys, or paid tokens.
- When regressions tests for fixing a github issue, add a comment with the github issue number next to the test.
- For ad-hoc scripts, `write` them to a temp file (e.g. `/tmp`), run, edit if needed, remove when done. Don't embed multi-line scripts in `bash` commands.
- Never commit unless the user asks.

## Dependency and Install Security

- Treat npm dep and lockfile changes as reviewed code. Direct registry deps, including internal workspace deps, stay pinned to exact versions.
- When updating `undici`, you MUST read its changelog/release notes for the target version and evaluate whether any changes may affect functionality before applying the update.
- Hydrate/update locally with `npm install --ignore-scripts`; clean/CI-style with `npm ci --ignore-scripts`. Don't run lifecycle scripts unless the user asks.
- If dep metadata changes, refresh `package-lock.json` with `npm install --package-lock-only --ignore-scripts`.
- If `packages/coding-agent/install-lock/` needs regen, run `node scripts/generate-coding-agent-install-lock.mjs` (verify with `--check` or `npm run check`). New deps with lifecycle scripts require review and an explicit allowlist entry in that script; never add one silently.
- Pre-commit blocks lockfile commits unless `PI_ALLOW_LOCKFILE_CHANGE=1`. Don't bypass unless the user wants the lockfile change committed.

## Git

Multiple pi sessions may be running in this cwd at the same time, each modifying different files. Git operations that touch unstaged, staged, or untracked files outside your own changes will stomp on other sessions' work. Follow these rules:

Committing:

- Only commit files YOU changed in THIS session.
- Stage explicit paths (`git add <path1> <path2>`); never `git add -A` / `git add .`.
- Before committing, run `git status` and verify you are only staging your files.
- `packages/ai/src/models.generated.ts` may always be included alongside your files.
- Message format: `{feat,fix,docs}[(ai,tui,agent,coding-agent)]: <commit message> (optionally multiple lines)`. Message is informative and concise.

Never run (destroys other agents' work or bypasses checks):

- `git reset --hard`, `git checkout .`, `git clean -fd`, `git stash`, `git add -A`, `git add .`, `git commit --no-verify`.

If rebase conflicts occur:

- Resolve conflicts only in files you modified.
- If a conflict is in a file you did not modify, abort and ask the user.
- Never force push.

## Issues and PRs

See `CONTRIBUTING.md` for the contributor gate (auto-close workflows, `lgtm`/`lgtmi`, quality bar).

When reviewing PRs:

- Do not run `gh pr checkout`, `git switch`, or otherwise move the worktree to the PR branch unless the user explicitly asks.
- Use `gh pr view`, `gh pr diff`, `gh api`, and local `git show`/`git diff` against fetched refs to inspect PR metadata, commits, and patches without changing branches.
- If you need PR file contents, fetch/read them into temporary files or use `git show <ref>:<path>` without switching branches.

When creating issues:

- Add `pkg:*` labels for affected packages (`pkg:agent`, `pkg:ai`, `pkg:coding-agent`, `pkg:tui`); use all that apply.

When posting issue/PR comments:

- Write the comment to a temp file and post with `gh issue/pr comment --body-file` (never multi-line markdown via `--body`).
- Keep comments concise, technical, in the user's tone.
- End every AI-posted comment with the AI-generated disclaimer line specified by the originating prompt (e.g. `This comment is AI-generated by `/wr``).

When closing issues via commit:

- Include `fixes #<number>` or `closes #<number>` in the message so merging auto-closes the issue. For multiple issues, repeat the keyword per issue (`closes #1, closes #2`); a shared keyword (`closes #1, #2`) only closes the first.

## Writing p2 plugin code

Before writing or reviewing plugin code in `apps/p2` (server and worker facets, contracts, stores), read [apps/p2/docs/plugin-practices.md](apps/p2/docs/plugin-practices.md) in full and follow it.

## Working on p3 (Pi Roam) packages

Work on a p3 (Pi Roam) package in `apps/p3` starts by reading [apps/p3/docs/README.md](apps/p3/docs/README.md), then the guides it lists, in its order, in full. Follow them.

## Building p2's web UI

For building or changing p2's web UI (`apps/p2`), load and follow [.pi/skills/p2-ui.md](.pi/skills/p2-ui.md).

## Testing pi Interactive Mode with tmux

For testing pi's interactive mode, load and follow [.pi/skills/interactive-testing.md](.pi/skills/interactive-testing.md).

## Changelog

Location: `packages/*/CHANGELOG.md` (one per package).

Sections under `## [Unreleased]`: `### Breaking Changes` (API changes requiring migration), `### Added`, `### Changed`, `### Fixed`, `### Removed`.

Rules:

- All new entries go under `## [Unreleased]`. Read the full section first and append to existing subsections; never duplicate them.
- Released version sections (e.g. `## [0.12.2]`) are immutable; never modify them.
- Do not create changelog entries when the work targets a branch other than `main`

Attribution:

- Internal (from issues): `Fixed foo bar ([#123](https://github.com/earendil-works/pi/issues/123))`
- External contributions: `Added feature X ([#456](https://github.com/earendil-works/pi/pull/456) by [@username](https://github.com/username))`

## Releasing

For release preparation, publishing, verification, or recovery, load and follow [.pi/skills/release.md](.pi/skills/release.md).

## User Override

If the user's instructions conflict with any rule in this document, ask for explicit confirmation before overriding. Only then execute their instructions.

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan:
`specs/001-dart-agent-package/plan.md`
<!-- SPECKIT END -->

<!-- local-ci:begin -->
## Running CI locally — `scripts/local_ci.sh`

GitHub Actions is billing-blocked on our private repos: every workflow run ends in
~3s with **zero steps executed**, so a red check here means nothing. Run the same
gate locally instead:

```bash
./scripts/local_ci.sh              # every job of the pull_request workflow
./scripts/local_ci.sh --plan       # print every step that would run, run nothing
./scripts/local_ci.sh --list       # workflows, triggers and jobs in this repo
./scripts/local_ci.sh --job <id>   # one job only
./scripts/local_ci.sh --event push # simulate the push-triggered workflow
./scripts/local_ci.sh --keep-going # do not stop at the first failure
./scripts/local_ci.sh -v           # echo each command before running it
```

It reads `.github/workflows/*` at run time and executes that workflow's jobs and
steps in order, so it cannot drift from CI — it is not a second copy of the gate.
Edit the workflow and the local run changes with it. Exit 0 means every executed
step passed.

What it cannot reproduce, and prints on startup instead of guessing:

- **Linux.** CI runs `ubuntu-latest`; this runs on macOS. The step set is the
  same, the platform is not. `sudo apt-get install` steps are mapped to a local
  presence probe rather than silently passed.
- **GitHub context.** A step needing `${{ secrets.* }}`, `${{ inputs.* }}`,
  `${{ vars.* }}`, `${{ steps.* }}` or `${{ github.event.* }}` is SKIPPED with the
  reason printed, never run with a guessed value.
- **`uses:` actions** are not executed. Toolchain setups (`setup-dart`,
  `setup-node`, `flutter-action`, `rust-toolchain`, …) become a version assertion
  against the local tool; checkout/cache/artifact are noted as no-ops; anything
  else is skipped by name. A Windows-runner job is skipped outright.
- **Cargo cross targets.** A step that builds for a rust cross target (e.g.
  `cargo build --target wasm32-wasip2`) is answered against this host's
  toolchain: a rustup toolchain carrying EVERY target the step asks for is used
  for that step — selected through the rustup proxy (`RUSTUP_TOOLCHAIN`), so
  `cargo +<toolchain>` keeps working — and when no local toolchain carries them
  the step is SKIPPED with the reason printed (`rustup target add <target>`) —
  never a red step that says nothing about the repo. The toolchain the workflow
  pins wins over another one that merely happens to carry the target. A host
  with no rust toolchain at all is a MISSING TOOLCHAIN, not a missing target:
  the step FAILS, as this script's convention says.
- **`container:`** jobs run on the host toolchain, not in the declared image.
- **`continue-on-error: true`** steps are advisory locally, exactly as in CI.
- **Local-only checkout state.** CI checks out the committed tree; this checkout
  also has gitignored and untracked paths, which whole-tree commands (e.g.
  `dart analyze .`) see. A step that fails naming only such paths is reported as
  a LOCAL-ONLY failure, not as a CI failure — pass `--strict` to count it anyway.
  A step that would `git clone` over a sibling checkout that already exists here
  is skipped; `--allow-outside-clone` forces it.

Canonical copy: `arrrrny/forklift` → `scripts/local_ci.sh` (reference:
`docs/forklift-scripts.md`).
<!-- local-ci:end -->

<!-- test-concurrency:begin -->
## Test concurrency (fleet guard)

Cap test concurrency at **2** — one un-capped `flutter test` fan starved the
shared host's services once (load 260; arrrrny/forklift#176).

There is **no config-file knob for `flutter test`**: it ignores
`dart_test.yaml` entirely (its only test-config file is
`flutter_test_config.dart`, an execution hook), so the flag is the only
lever — and it must be passed every time:

```sh
flutter test --concurrency=2
dart test -j 2
```

A repo whose `dart_test.yaml` carries `concurrency: 2` already defaults to it
for `dart test`; pass the flag anyway when you override it, and never raise
the number on a host that also runs the forklift pool. CI carries the same
flags in `.github/workflows`.
<!-- test-concurrency:end -->

<!-- dependency-bump-rule:begin -->
## Publishing without a dependency bump is a no-op — file the upgrade chore

Before any release, resolve the lockfile and align the DECLARED constraints to
what actually resolved. The lockfile is what ships: a `pubspec.yaml` saying
`^7.3.8` next to a resolved `7.4.2` only guarantees the next machine resolves
to something else, so the release you just cut is not the release anyone else
gets.

```bash
rm -f pubspec.lock
dart pub get                     # or `flutter pub get` for an app
# then set every caret constraint to the version the resolver picked
```

**Then look at what is still held back.** `dart pub outdated` (or
`flutter pub outdated`) lists every package whose declared constraint refuses
an available upgrade — the canonical example is `google_fonts` sitting on
`8.2.1` while `9.0.0` is out. Those are the upgrades this release did NOT take.

**The rule:** when a package could be upgraded but was not bumped
automatically, the publish **continues as normal** — do not block the release
on it — and you MUST file a GitHub chore issue for the available upgrades.
A publish that silently leaves upgrades on the table is not a smaller publish;
it is a publish nobody knows is stale. File the issue with the package names,
the current and available versions, and whether the constraint or a transitive
pin is what holds it.

Two corollaries worth remembering:

- **A `dart pub upgrade` that changes nothing is a signal, not a success.**
  If the constraint blocks the upgrade, bumping the constraint is the fix —
  and that is exactly the chore issue above.
- **Transitive holds are still chore material.** A package held only because
  a dependency pins it is not this repo's constraint to widen, but it is still
  an available upgrade a human should decide on.

This applies to every Dart/Flutter repo in the fleet. A repo whose publish
flow already runs the lockfile dance (see each repo's `PUBLISH.md`) still owes
the chore issue for whatever `pub outdated` reports.
<!-- dependency-bump-rule:end -->