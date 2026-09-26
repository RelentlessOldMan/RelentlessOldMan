# Development Prompts

Reusable prompts I paste (or point a Claude session at) to run a deep, fix-as-you-go
quality pass over a project. Both are opinionated: they insist on *actually fixing*
what they find, not just producing a report, while preserving the project's intended
behavior and architecture.

| Prompt | Use it for |
|--------|------------|
| [`CodeReview.md`](CodeReview.md) | A no-stone-unturned **code** hardening & quality pass — correctness, defensive programming, error handling, resource/concurrency safety, security, performance, tests. |
| [`CodeReview_UI.md`](CodeReview_UI.md) | A no-stone-unturned **UI/UX** hardening pass — state correctness, cancellation paths, control/visual consistency, resizing/DPI, focus/keyboard, error and empty states. |

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

## How to use

Point a Claude Code session at the repo you want reviewed, then paste the prompt (or
say "follow `Development_Prompts/CodeReview.md`"). Run the two separately — a codebase
pass and a UI pass are different jobs. For a GUI app, do the code pass first, then the
UI pass.
