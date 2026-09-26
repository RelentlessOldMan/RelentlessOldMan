# Development Prompts

Reusable prompts I paste (or point a Claude session at) when working on a project.
Two kinds live here: **review & hardening passes** (`CodeReview*`) that hunt for and
*actually fix* problems in existing code, and **implementation specs** (`Spec_*`) that
build a new subsystem to a defined standard. All are opinionated and insist on real
work over reports, while preserving the project's intended behavior and architecture.

### Review & hardening passes

| Prompt | Use it for |
|--------|------------|
| [`CodeReview.md`](CodeReview.md) | A no-stone-unturned **code** hardening & quality pass — correctness, defensive programming, error handling, resource/concurrency safety, security, performance, tests. |
| [`CodeReview_UI.md`](CodeReview_UI.md) | A no-stone-unturned **UI/UX** hardening pass — state correctness, cancellation paths, control/visual consistency, resizing/DPI, focus/keyboard, error and empty states. |
| [`CodeReview_Workflow.md`](CodeReview_Workflow.md) | An end-to-end **workflow & data-lifecycle** pass — import/edit/save/reopen/export, dirty-state correctness, save-failure safety, chained-cancellation, so the user never loses or corrupts work. |
| [`CodeReview_Performance.md`](CodeReview_Performance.md) | A measure-first **performance, scalability & resource** pass — algorithmic complexity, UI responsiveness, allocations/leaks, caching, scale/stress testing, under realistic and worst-case workloads. |

### Implementation specs

| Prompt | Use it for |
|--------|------------|
| [`Spec_DiagnosticSystem.md`](Spec_DiagnosticSystem.md) | **Build** a local diagnostics/logging/support system — centralized logging, breadcrumbs, exception capture, and a one-click **Save Diagnostic Report** package (with secret redaction) so a remote user's bug report is actually investigable. |
| [`Spec_CrashRecovery.md`](Spec_CrashRecovery.md) | **Build** a crash-recovery/autosave safety net — atomic, versioned recovery snapshots separate from normal saves, abnormal-shutdown detection, and explicit restore, so a crash loses minimal work and *never* corrupts the last known-good save. |
| [`Spec_Testing.md`](Spec_Testing.md) | **Build** a comprehensive, maintainable automated test suite — risk-first (persistence round-trips, failure/cancellation paths, dirty-state, recovery), deterministic and isolated, fast + full tiers, wired into CI. Optimizes for confidence, not coverage %. |

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

## CodeReview_Performance.md — performance & scalability hardening

A measure-first sweep for *real* performance problems — explicitly not speculative
micro-optimization. It maps the performance model and hot paths, establishes baselines
and profiles, then hunts algorithmic complexity, UI-thread blocking, event storms,
redundant work, allocations, memory/resource leaks, unbounded growth, cache
correctness, stale async results, startup/shutdown cost, and behavior under scale
(empty → 10k+ items), long sessions, slow dependencies, and lower-end machines — fixing
what matters, re-profiling as bottlenecks move, and never trading correctness for speed.
Ends with a stress pass and before/after measurements.

Best for anything that gets slow with large data, long sessions, or repeated operations.

## Spec_DiagnosticSystem.md — diagnostics/support system

An implementation spec (not a review): build a robust, reusable local diagnostics
system so that when a user hits a problem they can save **one** package and send it,
and the developer can reconstruct what happened without the user understanding logs or
internals. Covers centralized + structured logging, session IDs, startup/environment
capture, user-action breadcrumbs, operation-lifecycle and exception/crash capture,
bounded log rotation, and a **Help → Save Diagnostic Report** command that produces a
self-describing ZIP (summary, logs, sanitized config, structured `diagnostics.json`).
Heavy emphasis on privacy — secrets and user content are redacted/opt-in, never
silently bundled — and it stays local by default (no telemetry unless asked). Ends with
end-to-end acceptance criteria.

Best for any app you ship to users and have to support at a distance.

## Spec_CrashRecovery.md — crash-recovery / autosave

An implementation spec (not a review): build a generic safety net around Save so a
crash, kill, or power loss loses the least practical work — while treating the user's
last known-good save as sacred. Covers recovery snapshots stored *separately* from
normal saves, atomic/interruption-resistant writes with a small number of bounded
generations, dirty-state integration and debounced background snapshots (no UI
freezes), abnormal-shutdown detection, startup discovery with an explicit
**Recover / Discard / Later** choice, recovered state treated as unsaved (never
auto-overwriting the original file), correct Save/Save As/failed-save/cancel
interactions, corrupt-recovery fallback, validate-before-restore, and recovery of
never-saved documents. Pairs naturally with `Spec_DiagnosticSystem.md` for logging.
Ends with golden failure scenarios and acceptance criteria.

Best for any app where users create and edit work they'd hate to lose.

## Spec_Testing.md — automated testing strategy

An implementation spec (not a review): stand up a comprehensive, maintainable test
suite whose goal is *confidence*, not a coverage number — explicitly avoiding hundreds
of trivial getter/setter tests. It tests behavior over implementation, prioritizes by
risk (data loss, corrupt save/load, invalid state transitions, security), and covers
happy + failure + boundary + invalid-input paths, persistence round-trips (save →
destroy in-memory → reload → compare), dirty-state, cancellation and nested
cancellation, crash-recovery and diagnostic-redaction (when those exist), stale-async
results, fuzzing for parsers, plus fast/full tiers, deterministic isolated tests, CI
wiring, and a meta-check: deliberately break important behavior and confirm the suite
catches it. Complements `Spec_CrashRecovery.md` and `Spec_DiagnosticSystem.md` — it
tests the subsystems they build.

Best for any project mature enough to protect against regressions (i.e. most of them).

## How to use

Point a Claude Code session at the repo you want worked on, then paste the prompt (or
say "follow `Development_Prompts/CodeReview.md`"). Run them separately — each is a
different job. For a GUI, project-based app, a good order for the review passes is:
**code** first, then **workflow**, then **UI**, then **performance** (harden behavior
before chasing speed). The `Spec_*` prompts are independent — run one whenever you want
to build that subsystem.
