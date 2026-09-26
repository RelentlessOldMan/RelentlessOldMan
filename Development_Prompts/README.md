# Development Prompts

Reusable prompts I paste (or point a Claude session at) to run a deep, fix-as-you-go
quality pass over a project. Both are opinionated: they insist on *actually fixing*
what they find, not just producing a report, while preserving the project's intended
behavior and architecture.

| Prompt | Use it for |
|--------|------------|
| [`CodeReview.md`](CodeReview.md) | A no-stone-unturned **code** hardening & quality pass — correctness, defensive programming, error handling, resource/concurrency safety, security, performance, tests. |
| [`CodeReview_UI.md`](CodeReview_UI.md) | A no-stone-unturned **UI/UX** hardening pass — state correctness, cancellation paths, control/visual consistency, resizing/DPI, focus/keyboard, error and empty states. |
| [`CodeReview_Workflow.md`](CodeReview_Workflow.md) | An end-to-end **workflow & data-lifecycle** pass — import/edit/save/reopen/export, dirty-state correctness, save-failure safety, chained-cancellation, so the user never loses or corrupts work. |

## CodeReview.md — code hardening

Drives a full correctness-and-robustness sweep of a codebase. It first has the model
understand the architecture and execution paths, then hunts aggressively across
correctness, defensive programming, error handling, resource management, concurrency,
security, API robustness, architecture, maintainability, performance, logging,
configuration, dependencies, tests, dead code, and compatibility — fixing real issues,
checking for the same pattern elsewhere, and re-building/re-testing as it goes. Ends
with a second "what did I miss" pass and a concise report of what changed.

Best for backend/library/CLI/engine code, or the logic layer of any app.

## CodeReview_UI.md — UI/UX hardening

Treats the UI as a stateful system and behaves like a meticulous UI engineer *and* a
hostile QA tester at once — clicking things in weird orders, double-clicking, canceling
dialogs, resizing everything, forcing failures. It audits control enable/disable state
per app state, cancellation being a true no-op, button/control/visual consistency,
alignment, sizing, dialogs, file pickers, keyboard/focus, validation, dirty state,
destructive actions, busy states, theming, DPI scaling, and more — fixing problems
while respecting the existing design language. Ends with break-your-own-fixes and
final-polish passes.

Best for desktop/GUI apps (WinForms/WPF, Electron, browser UIs, etc.).

## CodeReview_Workflow.md — workflow & data-lifecycle hardening

Reviews the application as a *complete lifecycle of user work* rather than a set of
screens. It models the workflow as a state machine (nothing loaded → importing →
modified → saving → saved → exporting → …) and hammers the transitions where work can
be lost or corrupted: dirty-state correctness, save round-trips (save → close →
reopen → verify everything persisted), repeated saves, save-failure safety
(atomic/temp-file writes; a failed save must never look successful), import being
non-destructive to current work, chained-cancellation (`Open New → unsaved → Save →
Save As → Cancel` must abort the whole thing), file identity, export-is-not-save,
recent files, and full end-to-end user journeys. The golden rule: preserve current
valid state, attempt the new operation, commit the transition only after it succeeds.

Best for any app where the user creates and saves work (editors, project-based tools).

## How to use

Point a Claude Code session at the repo you want reviewed, then paste the prompt (or
say "follow `Development_Prompts/CodeReview.md`"). Run them separately — each is a
different job. For a GUI, project-based app, a good order is: **code** pass first, then
**workflow**, then **UI**.
