# Bug Issue: dart-port: replace placeholder compact() summaries with model-backed compaction

- **Slug**: placeholder-compact-summaries
- **Fetched**: 2026-11-22T11:12:30Z
- **Issue**: 7
- **URL**: https://github.com/arrrrny/pi/issues/7
- **State**: open
- **Severity**: unknown
- **Author**: arrrrny
- **Labels**: bug, dart-port, pkg:coding-agent

## Body

## Dart-port parity defect

The exported standalone `compact()` function still returns a placeholder summary instead of performing upstream's model-backed summarization.

### Actual

`pi_agent/lib/src/compaction.dart:110-145` explicitly documents and calls `_generatePlaceholderSummary`; `:161-171` truncates serialized conversation text into a pseudo-summary. The separate `Conversation.compact()` path does use `summarizeMessages`, so this issue is specifically about the exported `compact()` API and parity between the two paths.

### Expected (upstream behavior)

`packages/coding-agent/src/core/compaction/compaction.ts:641-760` generates/updates summaries through `completeSimple`, with structured prompts, usage, response validation, and previous-summary handling. Durable pi also implements compaction as durable tasks rather than text truncation.

### Required port coverage

- Replace placeholder output with the upstream model-backed behavior and response failure checks.
- Reuse one canonical summarization path so standalone and conversation compaction cannot diverge semantically.
- Preserve token accounting, previous summaries, custom instructions, file-operation details where in scope, and abort/error behavior.
- Add tests proving the model receives the expected context and that capped/error/tool-call responses are not persisted as valid summaries.

Evidence reviewed at Dart commit `1d62d46d9b3ba09c22a2f38fc94e46693ea1cc03` and upstream commit `780bf31fcaeb252fa9b68df3964c735eae75bde3`.

## Dependencies

Depends on: arrrrny/pi#6

## Comments

None.