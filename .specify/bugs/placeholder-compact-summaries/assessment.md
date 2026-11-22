# Bug Assessment: dart-port: replace placeholder compact() summaries with model-backed compaction

- **Slug**: placeholder-compact-summaries
- **Created**: 2026-11-22T11:12:30Z
- **Source**: https://github.com/arrrrny/pi/issues/7
- **Verdict**: valid
- **Severity**: high

## Report (verbatim or summarized)

The exported standalone `compact()` function returns a placeholder summary
instead of performing upstream's model-backed summarization. The issue
([arrrrny/pi#7](https://github.com/arrrrny/pi/issues/7), a `dart-port` parity
defect) records the actual behavior, the upstream reference, and the required
port coverage:

- `pi_agent/lib/src/compaction.dart:110-146` — `compact()` documents the
  placeholder and calls `_generatePlaceholderSummary`;
  `compaction.dart:161-172` truncates the serialized conversation at 2000 chars
  into a pseudo-summary.
- `Conversation.compact()` (the durable-harness path) *does* use
  `summarizeMessages`, so the defect is specifically the standalone exported
  `compact()` API and the semantic divergence between the two paths.
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts:696-753`
  (`generateSummaryWithUsage`) builds a structured prompt and validates the
  response through `completeSummarization` + `getSummarizationFailure`
  (`:585-593`), rejecting `error`/`length` stops and tool-call responses.

Evidence reviewed at Dart commit `1d62d46d9b3ba09c22a2f38fc94e46693ea1cc03`
and upstream commit `780bf31fcaeb252fa9b68df3964c735eae75bde3`.

## Symptom

Calling the exported `compact(entries, model)` (Dart) does not contact the
model at all: it serializes the cut entries and returns a truncated text
placeholder as the "summary" (prefixed with any previous summary). Expected:
the model is asked to produce a structured summary, and error / capped /
tool-call responses are surfaced as failures rather than persisted as a valid
summary. Because `Conversation.compact()` already uses the real
`summarizeMessages`, the two compaction paths can disagree semantically — a
standalone caller gets a non-summary while a conversation gets a real one.

## Reproduction

1. Build a list of `SessionTreeEntry`/`MessageEntry` whose cut entries contain
   conversation text (see `pi_agent/test/compaction_test.dart:202-249`).
2. Call `compact(entries, model, settings: ...)`.
3. Observe the returned `CompactionResult.summary` is the serialized transcript
   truncated to 2000 chars (`compaction.dart:161-172`), with no model call —
   confirmed by the existing test `includes previous summary in placeholder`
   (`compaction_test.dart:227-248`), which asserts the placeholder text rather
   than a model summary.

## Suspected Code Paths

- `pi_agent/lib/src/compaction.dart:114-146` — exported `compact()`: calls
  `_generatePlaceholderSummary`; the placeholder code path.
- `pi_agent/lib/src/compaction.dart:161-172` — `_generatePlaceholderSummary`:
  truncates serialized text; no model call, no failure checks.
- `pi_agent/lib/src/compaction.dart:184-229` — `summarizeMessages`: the real
  model-backed path (single user prompt, no `stopReason` validation, no
  previous-summary/update prompt, no `customInstructions` threading).
- `pi_agent/lib/src/harness.dart:167-204` — `Conversation.compact()`: already
  calls `summarizeMessages` (the canonical path the standalone `compact()` must
  converge on).
- `pi_agent/lib/src/types.dart:226-253` — `AssistantMessage` carries
  `stopReason` (`StopReason`) and `usage`; the data needed for failure checks is
  already present.
- `pi_agent/lib/src/types.dart:38-53` — `StopReason` enum (`endTurn`,
  `maxTokens`, `toolUse`, `stopSequence`, `refused`); the Dart analogue of
  upstream's `length` stop is `maxTokens`.
- `pi_agent/lib/src/types.dart:1053-1070` — `CompactionResult` (summary +
  firstKeptEntryId + tokensBefore).
- `pi_agent/lib/pi.dart:31` — `export 'src/compaction.dart';` makes `compact()`
  public API.
- Upstream reference: `packages/coding-agent/src/core/compaction/compaction.ts:696-753`
  (`generateSummaryWithUsage`), `:585-593` (`getSummarizationFailure`),
  `:618-638` (`completeSummarization` / retry choke point), `:507-579`
  (`SUMMARIZATION_PROMPT` / `UPDATE_SUMMARIZATION_PROMPT`).

## Root Cause Hypothesis

The Dart port implemented two separate compaction paths and only finished one.
`summarizeMessages` (compaction.dart:184-229) and `Conversation.compact`
(harness.dart:167-204) form the real, model-backed path. The exported
`compact()` (compaction.dart:114-146) was left as a stub: it reuses
`prepareCompaction` / `serializeConversation` but then short-circuits to
`_generatePlaceholderSummary` instead of delegating to `summarizeMessages`, and
never checks the response. Confidence: **high** — the placeholder is documented
in the function's own doc comment (`compaction.dart:112-113`) and the existing
test (`compaction_test.dart:227-248`) asserts the placeholder text, so the
current behavior is intentional stub code, not a regression.

This is a **missing port**, not a change in upstream design: upstream's
`generateSummaryWithUsage` is the design being ported, and the Dart repo has the
building blocks (`summarizeMessages`, `AssistantMessage.stopReason`,
`StopReason.maxTokens`) to implement it. The gap is the standalone `compact()`
entry point plus response-failure handling in `summarizeMessages` (which today
ignores `stopReason` and would persist a capped/error/tool-call response).

## Proposed Remediation

**Preferred** (minimal, respects the issue's required port coverage):

1. In `compaction.dart`, make the exported `compact()` delegate to the canonical
   summarization path instead of `_generatePlaceholderSummary`. It must thread a
   `LoopStreamFn` (as `summarizeMessages` requires) so the standalone entry can
   actually reach the model — add a required or defaulted `loopStreamFn`
   parameter mirroring `Conversation.compact`'s default (`streamLLM`), plus
   `apiKey` / `customInstructions` / `abortSignal` pass-through. Reuse
   `summarizeMessages` (compaction.dart:184) so the two paths cannot diverge.
2. In `summarizeMessages` (compaction.dart:184-229), add the upstream failure
   checks the issue calls out:
   - Inspect the returned `AssistantMessage.stopReason`: reject `maxTokens`
     (upstream `length` — see `getSummarizationFailure` compaction.ts:585-593)
     and refuse to persist a partial summary; map the Dart error model (issue
     #6, `StopReason`/`errorMessage` handling) so an `error` stop surfaces as a
     thrown error rather than text.
   - Reject a response whose content contains a `ToolCallBlock`
     (`AssistantMessage.toolCalls`, types.dart:250-252) — upstream throws
     "Summarization attempted to call a tool" (compaction.ts:746-748).
3. Thread `previousSummary` → the update-prompt branch and `customInstructions`
   → the "Additional focus" suffix, mirroring `generateSummaryWithUsage`
   (compaction.ts:713-717), so standalone compaction keeps parity on previous
   summaries and custom instructions. (The prompt text shape — `<conversation>`
   / `<previous-summary>` tags — is the upstream design to mirror where the
   existing `defaultCompactionInstructions` allows.)
4. Remove `_generatePlaceholderSummary` and its doc comment once nothing calls
   it; update the `compact()` doc comment to drop the placeholder note.

This keeps the change inside `pi_agent/` (the fork's value-add) and does not
touch the TypeScript packages. It depends on `arrrrny/pi#6` (error outcomes, not
assistant text) landing first, because the `error`-stop mapping in step 2 reuses
issue #6's `StopReason`/error-outcome work — see **Open Questions / Dependency**.

**Alternatives**:
- Keep two paths but point `compact()` at a thin wrapper that calls
  `summarizeMessages` with a default `streamLLM` — smaller diff, but leaves the
  default-stream coupling hidden inside the library function and makes the
  standalone API harder to test in isolation. Preferred is the explicit
  `loopStreamFn` parameter so callers/tests inject the stream.
- Fully port the durable-task compaction (Durable pi) instead of text
  truncation — correct long-term direction but far larger than this issue's
  scope; the issue asks for the model-backed path, not the durable-task engine.

**Files likely to change**:
- `pi_agent/lib/src/compaction.dart` (export `compact()` delegates to
  `summarizeMessages`; `summarizeMessages` gains failure checks; drop
  `_generatePlaceholderSummary`).
- `pi_agent/test/compaction_test.dart` (replace the placeholder assertions with
  model-backed + failure-case tests).

**Tests to add or update**:
- A scripted-stream test that `compact(entries, model, loopStreamFn: ...)` sends
  the serialized cut entries to the model and returns the model's text as the
  summary (mirrors `compaction_orchestration_test.dart` `_scripted` pattern).
- A `maxTokens` test: the scripted response carries `StopReason.maxTokens` and
  `compact()` throws / does not return a partial summary (parity with upstream
  regression `7048-compaction-truncated-summary.test.ts:40-47`).
- A tool-call test: the scripted response carries a `ToolCallBlock` and
  `compact()` rejects it (parity with compaction.ts:746-748).
- A previous-summary test: `previousSummary` is supplied to the update path and
  appears in the prompt (replace `includes previous summary in placeholder`).
- A parity test asserting standalone `compact()` and `Conversation.compact()`
  produce the same summary for the same scripted stream and cut point.

## Risks & Considerations

- **Dependency ordering**: step 2's `error`-stop mapping overlaps issue
  `arrrrny/pi#6` (provider failures → error outcomes). Landing #7 before #6
  risks a conflicting `StopReason`/error-outcome design. Sequence #7 after #6.
- **Public API change**: adding a required `loopStreamFn` to the exported
  `compact()` is a breaking change to a public function (pi.dart:31). Prefer a
  defaulting parameter (`loopStreamFn` defaulting to `streamLLM`) to avoid
  breaking existing callers, and note it in `pi_agent/CHANGELOG.md` under
  `## [Unreleased]` → `### Changed`.
- **Behavior change for existing callers**: `compact()` currently never fails;
  after the change it can throw on capped/error/tool-call responses. Callers
  that relied on the placeholder must handle the new failure path.
- **Abort handling**: thread `abortSignal` through to `summarizeMessages`
  (already a parameter) so standalone compaction honors cancellation like the
  conversation path.
- **Scope guard**: do not port the durable-task compaction engine or
  file-operation extraction here — the issue scopes this to the model-backed
  summary path and response validation; file-op details are "where in scope".

## Open Questions

- Dependency: this assessment is written against a tree where
  `arrrrny/pi#6` ("map provider failures to error outcomes") is still **open**.
  The remediation's `error`-stop mapping should reuse #6's outcome model; if #6
  lands first, re-check that `StopReason` / `errorMessage` shapes match before
  implementing step 2. (Not a blocker to assessment — flagged for `bug-fix`
  sequencing.)
- The exact prompt text parity (whether to adopt upstream's
  `<conversation>`/`<previous-summary>` tagged format and the full
  `SUMMARIZATION_PROMPT` body) is a judgment call for `bug-fix`; the existing
  `defaultCompactionInstructions` (compaction.dart:175-177) is a shorter
  variant. The minimal remediation keeps the existing instructions unless full
  upstream parity is desired.