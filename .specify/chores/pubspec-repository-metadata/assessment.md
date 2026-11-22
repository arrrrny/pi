# Chore Assessment: Correct the pi_agent pubspec repository metadata

- **Slug**: pubspec-repository-metadata
- **Created**: 2026-11-22
- **Source**: https://github.com/arrrrny/pi/issues/9
- **Verdict**: in scope
- **Size**: small

## Report

The issue reports that `pi_agent/pubspec.yaml:4` declares

```yaml
repository: https://github.com/arrrrny/pi-mono
```

while the fork actually lives at `https://github.com/arrrrny/pi`. GitHub cannot resolve
`arrrrny/pi-mono`, so the repository link shown to package consumers is dead. The issue
asks for the metadata to point at the real repository, and for related documentation links
to be checked at the same time. It scopes itself as "a small maintenance fix, separate
from runtime parity work".

Verified against the tree, the pub registry, and the toolchain:

- `pi_agent/pubspec.yaml:4` reads `repository: https://github.com/arrrrny/pi-mono` —
  confirmed, and it is the **only** occurrence of that string in the repo.
- The fork is `https://github.com/arrrrny/pi` (default branch `master`);
  `gh repo view arrrrny/pi-mono` fails with `Could not resolve to a Repository` —
  confirmed.
- The dead link is **live for consumers today**, not only in the tree: `pi` 0.2.0 is
  published on pub.dev and its published pubspec carries the same
  `repository: https://github.com/arrrrny/pi-mono` value (pub.dev API, `latest.pubspec`).
- Nothing catches it. `dart pub publish --dry-run` in `pi_agent/` reports
  `Package has 0 warnings`, and `.github/workflows/ci.yml` has no Dart job at all
  (its jobs are Node: `build-check`, `test`, `mcp-conformance`).
- **Related documentation links: none need changing.** The other `pi-mono` strings in the
  repo are upstream references, not fork metadata — `badlogic/pi-share-hf` and the
  `badlogicgames/pi-mono` Hugging Face dataset in `README.md`, and `earendil-works/pi-mono`
  links in the inherited `packages/coding-agent/CHANGELOG.md`. All of them resolve and all
  of them are upstream attribution.

## Summary

One metadata line in `pi_agent/pubspec.yaml` points the published package at a GitHub
repository that does not exist. Correcting it is a chore rather than a bug or a feature:
it changes no behavior, adds no capability, and fixes no runtime path — it repairs package
metadata that has already gone out to pub.dev with a dead link.

## Constitution Check

`.specify/constitution.md` does not exist in this repository, so the binding rules are the
repository and fleet `AGENTS.md`:

- **No new dependencies** — the change is a single YAML value; nothing is added.
- **The fork never modifies upstream TypeScript** — this is local to `pi_agent/` and cannot
  collide with `.github/workflows/sync-upstream.yml`, which takes upstream text as-is.
- **Changelog policy** — new entries belong under `## [Unreleased]`;
  `pi_agent/CHANGELOG.md` has no such section yet (it begins at `## 0.2.0`), so the
  implementer would create one. See Open Questions.
- **No generated code, no source edits from this command** — this assessment writes only
  under `.specify/chores/`.

No principle is violated.

## Affected Paths

- `pi_agent/pubspec.yaml:4` — the `repository:` value; the single occurrence of the dead
  URL and the whole of the fix.
- `pi_agent/CHANGELOG.md` — recommended only, if the changelog entry is wanted (see Open
  Questions).

## Proposed Approach

**Preferred**: change line 4 to

```yaml
repository: https://github.com/arrrrny/pi
```

and change nothing else. The published 0.2.0 page keeps its dead link until a new version
is published — the correction takes effect on the next `dart pub publish`, not
retroactively.

**Alternatives**:

- `repository: https://github.com/arrrrny/pi/tree/master/pi_agent` — pub.dev would
  deep-link straight to the package directory. Trade-off: it hardcodes the branch name and
  is not literally "the repository" the issue asks for, so it goes stale on a branch
  rename. The bare URL is preferred.
- Add a CI step that asserts the `repository:` URL resolves, so this class of error cannot
  recur. Out of scope for this chore and worth its own issue: CI currently runs no Dart
  job, so the guard would be a new job rather than a line in an existing one.

**Paths likely to change**:

- `pi_agent/pubspec.yaml`
- `pi_agent/CHANGELOG.md` (only if the changelog entry is wanted)

**Verification to run**:

- `cd pi_agent && dart pub publish --dry-run` — must succeed. Note the baseline is
  `Package has 0 warnings` *before* the change too: the point of this check is that the
  edit does not damage the YAML, not that the toolchain notices the fix.
- `grep -rn "arrrrny/pi-mono" pi_agent/` — no matches.
- `grep -n "repository:" pi_agent/pubspec.yaml` — one match, the corrected URL.
- `gh repo view arrrrny/pi` — confirms the target resolves (it does).
- `cd pi_agent && dart analyze` — green.
- After the next publish: `curl -s https://pub.dev/api/packages/pi | jq -r
  .latest.pubspec.repository` reports the corrected URL.

## Risks & Considerations

- **Blast radius is one line.** Nothing at runtime reads `repository:`; it is inert
  metadata. No migration, no API change, no dependency movement.
- **pub.dev stays stale until republish.** Consumers see the dead link on the current 0.2.0
  page until a new version ships.
- **Over-scoping is the real risk.** Rewriting the `pi-mono` mentions in `README.md` or the
  inherited changelogs would overwrite upstream attribution (badlogic's session datasets,
  earendil-works' issue links) and collide with the daily `sync-upstream.yml` merge, which
  takes upstream text as-is. Those mentions are correct and must stay.
- **No automated guard exists.** Neither the Dart toolchain nor CI validates this URL, so
  the same mistake can recur if the fork is renamed again.

## Open Questions

- **Changelog entry.** Repo policy points new entries at `## [Unreleased]`, and
  `pi_agent/CHANGELOG.md` has no such section. Recommendation: create it with a `### Fixed`
  entry ("Corrected the `repository` metadata to point at the fork"). A maintainer may
  prefer to keep a metadata-only change out of the changelog.
- **Bare URL vs. package-scoped tree URL.** Preferred is the bare
  `https://github.com/arrrrny/pi`, matching the issue's wording; the tree URL is the
  alternative above if deep-linking to `pi_agent/` is wanted.