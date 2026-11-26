# Publishing `pi` (`pi_agent`)

This document details the local and CI release procedure for `pi` (`pi_agent`), the Dart port of pi's agent core and durable harness.

## Prerequisites

- Dart SDK `^3.0.0` (Dart 3.13.x recommended)
- Authenticated `gh` CLI (account `arrrrny`)
- Access to pub.dev (for publishing)

## Pre-Publish Verification

Run from `pi_agent/`:

1. **Format and Analyze**:
   ```bash
   dart format .
   dart analyze
   ```

2. **Run Tests**:
   ```bash
   dart test -j 2
   ```

3. **Differential Parity Scenarios**:
   ```bash
   node scripts/coverage/differential/run-scenario.mjs --scenario coverage/differential/scenarios/tool-executes.json --sha <target_sha>
   ```

4. **Publish Dry-Run**:
   ```bash
   dart pub publish --dry-run
   ```
   Must exit successfully with `Package has 0 warnings`.

## Publishing Steps

1. Bump version in `pi_agent/pubspec.yaml` and update `pi_agent/CHANGELOG.md` under `## [Unreleased]` for breaking changes, additions, changes, or fixes.
2. Commit changes and push branch.
3. Run `dart pub publish` (or via CI / maintainer authorization).
4. Tag the release.

## Consumer Upgrade Guidance

Consumers pinning `pi` in `pubspec.yaml`:

```yaml
dependencies:
  pi: ^0.2.0
```

To install the CLI executable `pidart`:

```sh
dart pub global activate pi
export PATH="$HOME/.pub-cache/bin:$PATH"
pidart --version
```
