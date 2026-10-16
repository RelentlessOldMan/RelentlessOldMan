# Development Prompts

Reusable prompts I paste (or point a Claude session at) when working on a project.
Two kinds live here: **review & fix passes** (`CodeReview_*`) that hunt for and
*actually fix* problems in existing code, and **implementation specs** (`Spec_*`) that
build a new subsystem to a defined standard. All are opinionated and preserve the
project's intended behavior and architecture.

Most review passes fix as they go. A few are **audit-first** (marked below): they
finish a complete, ranked findings report before changing any code, then fix the
confirmed findings in priority order, each proven by a regression test or a
before/after measurement. That's for areas where fixing the first thing you find
does more harm than good: optimization, and soundness-critical tool logic.

### Review & fix passes

| Prompt | Use it for |
|--------|------------|
| [`CodeReview.md`](CodeReview.md) | A no-stone-unturned **code** hardening & quality pass — correctness, defensive programming, error handling, resource/concurrency safety, security, performance, tests. |
| [`CodeReview_UI.md`](CodeReview_UI.md) | A no-stone-unturned **UI/UX** hardening pass — state correctness, cancellation paths, control/visual consistency, resizing/DPI, focus/keyboard, error and empty states. |
| [`CodeReview_Workflow.md`](CodeReview_Workflow.md) | An end-to-end **workflow & data-lifecycle** pass — import/edit/save/reopen/export, dirty-state correctness, save-failure safety, chained-cancellation, so the user never loses or corrupts work. |
| [`CodeReview_Performance.md`](CodeReview_Performance.md) | A measure-first **performance, scalability & resource** pass — algorithmic complexity, UI responsiveness, allocations/leaks, caching, scale/stress testing, under realistic and worst-case workloads. |
| [`CodeReview_WastedCPU.md`](CodeReview_WastedCPU.md) | *Audit-first.* An exhaustive **wasted-CPU** pass — redundant/repeated computation, algorithmic complexity, hot loops, data-structure overhead, lock contention and busy-waiting, idle/background polling, repeated parsing — with estimated savings per finding. |
| [`CodeReview_WastedRAM.md`](CodeReview_WastedRAM.md) | *Audit-first.* An exhaustive **wasted-RAM** pass — over-long object lifetimes, duplicate data, oversized collections/buffers, unbounded caches, per-worker memory amplification, transient spikes — not just leaks. |
| [`CodeReview_TestCoverage.md`](CodeReview_TestCoverage.md) | A **test-coverage analysis & remediation** pass (any language) — measure line/branch/method coverage, classify gaps by risk (MUST / SHOULD / OPTIONAL / intentionally uncovered / dead), add meaningful tests, chase the bugs they expose. Coverage is evidence, not the goal. |
| [`CodeReview_GitHubDocumentation.md`](CodeReview_GitHubDocumentation.md) | A **public GitHub documentation & presentation** pass — README architecture, GitHub Pages, install/quick-start, accuracy and drift audits, AI-slop audit, user-journey tests — while keeping the house no-contributions + MIT standards intact. |
| [`CodeReview_UtilLibrary.md`](CodeReview_UtilLibrary.md) | A stricter-than-normal **reusable-library / common-code** pass — public API as a long-term contract, misuse-resistance, portability, thread-safety, dependency hygiene, security-sensitive helpers, plus a KEEP/IMPROVE/MERGE/SPLIT/MOVE/DEPRECATE/DELETE inventory. |
| [`CodeReview_PuzzleGame.md`](CodeReview_PuzzleGame.md) | A specialized **puzzle-game logic / gameplay / state** pass — rule invariants, solvability & unique-solution validation, completion correctness, softlocks, undo/redo/restart/hints/save-resume, stale async results, and score/timer exploits. Supplements the general passes. |

### Tool-specific passes

| Prompt | Use it for |
|--------|------------|
| [`CodeReview_CodeCarver.md`](CodeReview_CodeCarver.md) | *Audit-first.* An adversarial **C/C++ source-carving correctness** review for [CodeCarver](https://github.com/RelentlessOldMan/CodeCarver) — the carving contract, soundness vs. precision, preprocessor/macros, C and C++ semantics (templates, overloads, virtual dispatch, object lifetime), and anything removed that was actually required. |
| [`CodeReview_CodeDiffer.md`](CodeReview_CodeDiffer.md) | *Audit-first.* An adversarial **C/C++ code-differ correctness** review for [CodeDiffer](https://github.com/RelentlessOldMan/CodeDiffer) — the comparison contract, no missed / no fabricated differences, file pairing, diff-algorithm and hunk correctness, symbol identity and entity matching, templates and the C++ object model. |

### Implementation specs

| Prompt | Use it for |
|--------|------------|
| [`Spec_DiagnosticSystem.md`](Spec_DiagnosticSystem.md) | **Build** a local diagnostics/logging/support system — centralized logging, breadcrumbs, exception capture, and a one-click **Save Diagnostic Report** package (with secret redaction) so a remote user's bug report is actually investigable. |
| [`Spec_CrashRecovery.md`](Spec_CrashRecovery.md) | **Build** a crash-recovery/autosave safety net — atomic, versioned recovery snapshots separate from normal saves, abnormal-shutdown detection, and explicit restore, so a crash loses minimal work and *never* corrupts the last known-good save. |
| [`Spec_Testing.md`](Spec_Testing.md) | **Build** a comprehensive, maintainable automated test suite — risk-first (persistence round-trips, failure/cancellation paths, dirty-state, recovery), deterministic and isolated, fast + full tiers, wired into CI where the project has one. Optimizes for confidence, not coverage %. |

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
destructive actions, busy states, theming, DPI scaling, browser layouts (narrow
viewports, zoom, touch), and more — fixing problems while respecting the existing design
language. Ends with break-your-own-fixes and final-polish passes. Failure and
fresh-start scenarios run against scratch copies and a backed-up settings location,
never the user's real data.

Best for desktop/GUI apps and browser UIs (WinForms/WPF, Electron, single-page HTML tools, etc.).

## CodeReview_Workflow.md — workflow & data-lifecycle hardening

Reviews the application as a *complete lifecycle of user work* rather than a set of
screens. It models the workflow as a state machine (nothing loaded → importing →
modified → saving → saved → exporting → …) and hammers the transitions where work can be
lost or corrupted: dirty-state correctness, save round-trips (save → close → reopen →
verify everything persisted), repeated saves, save-failure safety (atomic/temp-file
writes; a failed save must never look successful), import being non-destructive to
current work, chained-cancellation (`Open New → unsaved → Save → Save As → Cancel` must
abort the whole thing), file identity, export-is-not-save, recent files, and full
end-to-end user journeys. The golden rule: preserve current valid state, attempt the new
operation, commit the transition only after it succeeds. Fixes what it finds as it goes
(each with a regression test), then re-runs the round-trip journeys and reports the
data-loss bugs fixed and the risks that remain. Failure scenarios run on scratch copies,
never the user's real files.

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

## CodeReview_WastedCPU.md — wasted-CPU review

An **audit-first** companion to `CodeReview_Performance.md`, focused on computation that
never needed to happen rather than merely slow code. It separates CPU metrics (latency,
throughput, CPU time, idle CPU), establishes a baseline, then sweeps redundant and
loop-invariant computation, duplicate work across components, algorithmic complexity
(nested loops, repeated search/sort/traversal, incremental computation), hot paths and
batching, container choice and cache locality, allocation/copying/GC-driven CPU,
concurrency overhead (thread churn, contention, spin-waits, false sharing), idle and
background activity (polling, timer proliferation, needless refreshes), and repeated
parsing/serialization. Every finding comes with evidence, estimated savings, risk, and
how to validate it. Emphasis on *multiplicative* waste — a cheap operation run a billion
times — and on avoiding work before accelerating it. Phase 2 then implements the
confirmed wins, re-measuring each against the baseline and reverting any that don't pay
off.

Best when a tool burns CPU at scale or while idle.

## CodeReview_WastedRAM.md — wasted-RAM review

The memory counterpart to the wasted-CPU audit, also **audit-first**. It looks past
classic leaks to memory that is reachable and correctly freed but still wasteful:
objects kept alive too long, accidental/hidden retention, duplicate data and multiple
representations, copy amplification, excess collection capacity and per-element
overhead, large populations of small objects and layout/packing, repeated strings,
oversized or simultaneously-live buffers, unbounded or low-value caches, per-thread and
queued-work memory, and space complexity (full-state cloning). Covers both steady-state
footprint and transient spikes, with estimated savings and risk per finding, then fixes
the confirmed ones with before/after measurements.

Best for tools that hold big datasets or indexes in memory, or run for a long time.

## CodeReview_TestCoverage.md — test-coverage analysis & remediation

Measures coverage with the language's standard tooling (Coverlet, coverage.py,
Istanbul/c8, gcov/llvm-cov, `go test -cover`, …) and then deliberately *doesn't* chase
the number. It builds a baseline, measures line/branch/method coverage, analyzes gaps by
risk, inspects uncovered code and classifies it (MUST TEST / SHOULD TEST / OPTIONAL /
INTENTIONALLY UNCOVERED / DEAD), checks behavioral coverage across normal, boundary,
null/empty, invalid-input, exception, async, cancellation, retry, state-transition and
cleanup scenarios, then adds the missing meaningful tests — investigating (not papering
over) any defect they expose. Strict safety rules: never weaken assertions, delete
legitimate tests, or exclude hard code just to raise the percentage. Ends with a
recalculated before/after report and the remaining justified gaps.

Best for an existing project that has tests and you want to know what they
actually protect. (`Spec_Testing.md` is the one for standing a suite up from scratch.)

## CodeReview_GitHubDocumentation.md — public docs & presentation

Treats the repo's GitHub presence (README, docs, GitHub Pages) as a product surface: a
visitor should quickly learn what it is, why it exists, what it looks like, how to run
it, and its limits. It reviews first impression, README architecture, information
architecture and progressive disclosure, install/first-run and quick start, examples and
screenshots, an accuracy audit against the actual code, documentation drift and
duplication, navigation, troubleshooting, tone, and an **AI-slop audit** — then
classifies each doc (KEEP / IMPROVE / MERGE / SPLIT / MOVE / GENERATE / ADD / DEPRECATE /
DELETE) and makes the improvements, finishing with simulated user journeys (visitor →
new user → forker). It's written for *personal projects shared as-is*: no corporate
boilerplate or contributor recruitment, and the no-contributions policy and MIT license
are protected house standards.

Best before (or after a big change to) any public repo.

## CodeReview_UtilLibrary.md — reusable-library hardening

A review held to a deliberately higher standard than a normal code review, because a
defect or bad API in shared code propagates into *every* consumer. It inventories the
public surface and classifies each major component (KEEP / IMPROVE / MERGE / SPLIT /
MOVE / DEPRECATE / DELETE), then treats every public API as a long-term contract:
naming/parameter/return/null/exception design, misuse-resistance ("pit of success"),
ownership and disposal, thread-safety and async contracts, portability and platform
isolation, culture/Unicode/encoding/time correctness, dependency hygiene (a library's
deps propagate outward), security-sensitive helpers (paths, processes, archives,
serialization, crypto), no surprise global state / console / UI, and consumer
simulation from the outside without reading the source. Flags accidental breaking
changes and junk-drawer sprawl.

Best for a shared "tool belt" / common-code library consumed by multiple projects
(rather than an end-user app).

## CodeReview_PuzzleGame.md — puzzle-game logic & state

A specialized pass that **supplements** the general reviews (code / UI / workflow /
performance / testing) for puzzle games specifically. It infers the actual game rules
and verifies the implementation enforces them everywhere: rule invariants and a single
source of truth for rules (so UI, engine, solver, hints, generator, and win-checker
can't disagree), legal-move validation at the model layer (not just disabled buttons),
completion correctness (no false positive/negative wins, multiple-solution handling),
puzzle solvability and unique-solution validation, solver/generator correctness and
termination, softlock/hardlock hunting, undo/redo/restart/new-game state hygiene, hint
correctness and staleness, save/resume and corrupt-save safety, stale async results
(old puzzle's solver mustn't touch the new one), score/timer exploits, and heavy
automated testing (golden/regression puzzles, generated-batch checks, action-sequence
fuzzing, an invariant checker). The standard: the puzzle is hard because the *puzzle*
is hard, not because the software fights the player.

Best for puzzle games — run it alongside the general passes, not instead of them.

## CodeReview_CodeCarver.md — CodeCarver correctness review

An **audit-first**, adversarial review written specifically for
[CodeCarver](https://github.com/RelentlessOldMan/CodeCarver) (C/C++ reachability
carving). It first pins down the carving contract, reachability categories, and the
soundness-vs-precision trade-off, then audits the whole pipeline: AST/declaration
identity and traversal completeness, preprocessor and conditional compilation (macros,
macro-generated symbols, multiple build configs, include order), C semantics (function
pointers, callback registration, global initialization, GNU extensions, volatile/MMIO,
inline asm), C++ name resolution and overloading, templates and metaprogramming,
classes/inheritance/virtual dispatch, and object lifetime — hunting for code removed
that was required, code kept that was provably dead, invalid output, nondeterminism, and
silent failures, each with a minimal reproduction. Phase 2 turns each reproduction into a
failing regression test, then fixes it.

## CodeReview_CodeDiffer.md — CodeDiffer correctness review

The same treatment for [CodeDiffer](https://github.com/RelentlessOldMan/CodeDiffer),
also **audit-first**. It establishes the comparison contract (granularity, difference
semantics, guarantees, change classifications) and the core properties — no missed
differences, no fabricated differences, correct attribution and old/new direction, no
silent success on incomplete analysis — then audits file discovery and pairing,
encoding/line endings, textual diff and hunk correctness, C/C++ parsing, symbol identity
and entity matching (overloads, renames, moves, ambiguous matches), templates, the C++
object model, and preprocessor differences. An empty diff is never assumed to mean
equivalent inputs. Phase 2 fixes confirmed findings test-first, like the CodeCarver pass.

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

An implementation spec (not a review): stand up a comprehensive, maintainable test suite
whose goal is *confidence*, not a coverage number — explicitly avoiding hundreds of
trivial getter/setter tests. It starts from a baseline of the existing suite, derives
expected values from intended behavior (never locking in current bugs), tests behavior
over implementation, prioritizes by risk (data loss, corrupt save/load, invalid state
transitions, security), and covers happy + failure + boundary + invalid-input paths,
persistence round-trips (save → destroy in-memory → reload → compare), dirty-state,
cancellation and nested cancellation, crash-recovery and diagnostic-redaction (when
those exist), stale-async results, fuzzing for parsers, plus fast/full tiers,
deterministic isolated tests, CI wiring where the project has CI, and a meta-check:
deliberately break important behavior and confirm the suite catches it. Complements
`Spec_CrashRecovery.md` and `Spec_DiagnosticSystem.md` — it tests the subsystems they
build.

Best for any project mature enough to protect against regressions (i.e. most of them).

## How to use

Point a Claude Code session at the repo you want worked on, then paste the prompt (or
say "follow `Development_Prompts/CodeReview.md`"). Run them separately — each is a
different job. For a GUI, project-based app, a good order for the review passes is:
**code** first, then **workflow**, then **UI**, then **performance** (harden behavior
before chasing speed). The **audit-first** passes (`WastedCPU`, `WastedRAM`, and the
`CodeCarver` / `CodeDiffer` tool-specific ones) write their full report before fixing
anything, so you get the ranked findings even if you stop the session early.
`CodeReview_TestCoverage.md` fits after the code pass, and
`CodeReview_GitHubDocumentation.md` is a good last step before sharing a repo.
`CodeReview_UtilLibrary.md` is for **shared libraries** rather than apps — reach for it
(in place of or alongside the code pass) when the project is a reusable tool belt.
`CodeReview_PuzzleGame.md` is a **supplemental** pass for puzzle games — run it
alongside the general passes. The `Spec_*` prompts are independent — run one whenever
you want to build that subsystem.
