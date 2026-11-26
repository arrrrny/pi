# TUI and Application Adaptation Seam (PI-PAR-009)

Issue: arrrrny/pi#47. Pinned upstream SHA: `c11a73bfba1310dc4075ad836254ea87003f409b`.

This document records the evidence-backed decision for every `packages/tui`
behavior row and every upstream `apps/*` target, and the seam through which the
terminal/session behavior that is not ported into `pi_agent` is adapted by the
Zuraffa packages. The machine-readable record is
`coverage/adaptation-decisions.json` (one entry per TUI row) plus the
`app_decisions` section of the generated manifest. The full-parity release gate
(`scripts/coverage/check-release-evidence.mjs`) fails while any TUI row or app
lacks an evidence-backed decision, so no full-parity claim can be made while a
TUI or application surface is silently omitted.

## What stays in Pi vs what is adapted

The Dart port (`pi_agent`) is deliberately slim and ships **no terminal UI
package**. `pi_agent/lib` exposes `ai`, `coding_agent`, `durable`, `schema`,
`telemetry`, and `pi` entry libraries; there is no `tui.dart`. Terminal and
session behavior is therefore not ported into `pi` — it is **adapted** by the
Zuraffa packages that own a UI surface:

- **`zuraffa_tui`** adapts the terminal-rendering half of `packages/tui`: the
  renderers (`TuiMainScreen`, `TuiAltScreen`), the layout primitives (`Box`,
  `HStack`, `Spacer`, `Stack`), the text widgets (`Text`, `TruncatedText`), the
  input/terminal adapters (`ProcessTerminal`, `StdinBuffer`, `Editor` host
  side), the color/oklab utilities, the fuzzy matcher used by the command
  palette, the wheel-scroll accumulator, and the cancellable loader.
- **`zuraffa_ui`** adapts the application-facing widget half: `Editor`,
  `Input`, `Markdown`/`Marked`, `SettingsList`, `MouseRegion`, and the editor
  component contract — the surfaces a product app binds to.

The terminal/session seam is the `Terminal` / `TUI` interface boundary. Pi's
agent loop never talks to a terminal; it emits structured events and
`stopReason`/`errorMessage` (see `packages/agent/src/agent.ts`). `zuraffa_tui`
implements the `Terminal`/`TUI` contract over the host pty and renders those
events; `zuraffa_ui` binds the widget surface. No Zuraffa type leaks into
`pi_agent` (enforced by the purity gate, `scripts/coverage/check-purity.mjs`).

## Not-applicable rows

Rows marked `not_applicable` fall into three groups, each with an evidence
reason in `coverage/adaptation-decisions.json`:

- **Native/terminal-protocol surfaces with no Dart equivalent** —
  `getNativeClipboard`, `isAppleTerminalSession`, `renderLatex`,
  `formatProgramStatus`, and the native-clipboard / terminal-image /
  suspend-signal / exit-restore test fixtures. These depend on a Node helper
  binary, an Apple Terminal session, or an external LaTeX renderer; the
  Dart port has no such surface and the Zuraffa host shell owns its own
  environment detection.
- **Upstream TypeScript component tests** — the `packages/tui/test/*.test.ts`
  files. Their behavior is verified by the `zuraffa_tui` / `zuraffa_ui` test
  suite that adapts the component, not by a 1:1 Dart port of the TS test file.
  Porting the test file itself would add a Dart test with no Dart subject.

## Application exclusions (reconfirmed at the pinned SHA)

The upstream `apps/*` directories at `c11a73b` are `apps/p2`, `apps/p2-mac`,
and `apps/p3` — exactly the three the manifest decides. All three are
`not_applicable` with an approved reason: each is a product application with
its own deploy pipeline and no Dart library surface to port. The set is
reconfirmed against the pinned SHA by the generator (a missing or extra `apps/*`
entry fails generation) and re-verified by the release gate.