# Code Review & Hardening Prompt

I want you to perform an extremely thorough, no-stone-unturned hardening and quality pass over this entire codebase.

Do NOT treat this as a superficial code review. I want you to actively inspect the project, understand how the pieces interact, identify weaknesses, and FIX them where appropriate.

The goal is to leave the project substantially more robust, maintainable, defensive, reliable, and production-quality without unnecessarily changing its intended behavior or architecture.

## Approach

First, understand the codebase before making broad changes.

Inspect:
- Project structure
- Architecture
- Entry points
- Major execution paths
- Data flow
- State management
- External interfaces
- File/network/process interactions
- Configuration
- Error handling strategy
- Logging
- Concurrency/threading/async behavior
- Resource ownership and lifetime
- Build configuration
- Tests
- Dependencies

Then perform a deep hardening pass.

Do not limit yourself to the items below. They are a starting checklist, not the boundary of the review.

## Correctness

Look aggressively for:
- Logic errors
- Incorrect assumptions
- Edge cases
- Off-by-one errors
- Incorrect boundary handling
- Null/None/nullptr problems
- Invalid state transitions
- Uninitialized state
- Stale state
- Integer overflow/underflow
- Truncation
- Signed/unsigned issues
- Floating-point assumptions
- Incorrect comparisons
- Encoding/Unicode problems
- Time/date/timezone mistakes
- Ordering assumptions
- Lifetime problems
- Use-after-free/dangling references where applicable
- Race conditions
- TOCTOU problems
- Reentrancy problems
- Partial-success states
- Failure paths that leave corrupted/inconsistent state

Trace important execution paths mentally rather than merely reviewing functions independently.

## Defensive Programming

Assume inputs, files, configuration, external APIs, users, devices, processes, and dependencies can behave unexpectedly.

Check:
- Input validation
- Range validation
- Length limits
- Malformed data
- Missing data
- Duplicate data
- Unexpected ordering
- Empty collections
- Extremely large inputs
- Invalid enum/state values
- Corrupt files
- Missing files/directories
- Permission failures
- Disk-full conditions where relevant
- Network failures
- Timeouts
- Partial reads/writes
- Process failures
- Unexpected external program output
- Cancellation/interruption
- Retry behavior

Failures should be controlled, understandable, and preferably recoverable.

## Error Handling

Audit every meaningful failure path.

Look for:
- Swallowed exceptions
- Overly broad catches
- Exceptions used incorrectly
- Missing checks
- Ignored return values
- Misleading success states
- Poor cleanup after failure
- Loss of useful diagnostic information
- Error messages without context
- Errors that surface too late
- Inconsistent error-handling strategies

Make errors actionable.

When wrapping/rethrowing errors, preserve the original cause/context whenever appropriate.

## Resource Management

Look for leaks or incorrect lifetime management involving:
- Memory
- File handles
- Streams
- Sockets
- Processes
- Threads
- Locks
- Timers
- OS handles
- Database connections
- Temporary files
- Native resources
- Disposable objects

Ensure cleanup happens on BOTH success and failure paths.

## Concurrency / Async

If the project contains concurrency, threading, tasks, callbacks, events, or async code, examine it especially carefully.

Look for:
- Race conditions
- Deadlocks
- Lock ordering problems
- Data races
- Unsynchronized shared state
- Blocking async code
- Fire-and-forget failures
- Lost exceptions
- Cancellation bugs
- Shutdown races
- Thread-affinity violations
- Double initialization
- Double disposal
- Operations continuing after their owner is destroyed
- UI-thread blocking if applicable

Do not assume something is thread-safe just because it usually works.

## Security Hardening

Review relevant attack surfaces, including:
- Untrusted input
- Path traversal
- Command injection
- Shell/process invocation
- Unsafe argument construction
- SQL/query injection
- Unsafe deserialization
- XML/JSON parsing assumptions
- File overwrite risks
- Temporary-file handling
- Secrets in source/logs/configuration
- Credential handling
- Excessive permissions
- Unsafe defaults
- Information leakage through errors/logging
- Trust-boundary violations
- Insecure randomness where security matters
- Authentication/authorization mistakes if applicable

Do not invent elaborate security infrastructure where it isn't needed, but fix realistic weaknesses.

## API / Interface Robustness

Inspect public/internal APIs for:
- Ambiguous contracts
- Invalid states being representable unnecessarily
- Inconsistent parameter validation
- Surprising side effects
- Incorrect ownership semantics
- Confusing return values
- Inconsistent naming
- Hidden assumptions
- Brittle coupling
- Missing invariants

Prefer making incorrect usage difficult.

## Architecture

Look for structural problems that materially affect reliability or maintainability:
- Excessive coupling
- Circular dependencies
- God classes/functions
- Duplicated logic
- Multiple sources of truth
- Leaky abstractions
- Hidden global state
- Fragile initialization order
- Business logic mixed unnecessarily with I/O/UI/platform code
- Components doing unrelated jobs
- Configuration scattered throughout the project

Refactor when there is a clear payoff, but DO NOT rewrite working architecture merely because another design is theoretically cleaner.

## Maintainability

Improve code that is:
- Difficult to understand
- Misleading
- Needlessly clever
- Excessively nested
- Duplicated
- Inconsistently named
- Poorly factored
- Full of magic values
- Dependent on undocumented assumptions

Prefer boring, obvious, readable code.

Do not churn code solely for stylistic preference.

## Performance

Look for meaningful performance problems:
- Accidental O(n²) or worse behavior
- Repeated expensive operations
- Unnecessary allocations
- Excessive copying
- Repeated parsing
- Needless disk/network operations
- Blocking operations on critical threads
- Unbounded collections/caches
- Resource exhaustion possibilities
- Hot-path logging
- Polling/busy waiting
- Obviously poor data structures

Do NOT perform speculative micro-optimization.

Correctness and clarity come first unless performance is clearly important to that code path.

## Logging / Diagnostics

Make sure failures can actually be diagnosed.

Check whether important operations provide enough context to understand:
- What failed
- Where it failed
- What operation was being attempted
- Relevant identifiers/state
- The underlying error

Avoid:
- Logging secrets
- Logging huge amounts of useless noise
- Duplicate logging of the same exception at every layer
- Messages like "operation failed" with no useful context

## Configuration / Defaults

Inspect configuration behavior for:
- Missing values
- Invalid values
- Dangerous defaults
- Environment-specific assumptions
- Hardcoded paths
- Hardcoded machine/user assumptions
- Development settings leaking into production behavior
- Invalid combinations of options

Fail early and clearly when configuration makes execution impossible.

## Dependencies

Inspect dependency usage for:
- Unnecessary dependencies
- Incorrect API usage
- Deprecated functionality
- Fragile assumptions about dependency behavior
- Version compatibility problems
- Duplicate functionality that the platform/library already handles safely

Do NOT blindly upgrade dependencies unless there is a concrete reason.

## Tests

Inspect the existing tests and identify important behavior that is insufficiently protected.

Add or improve tests for important fixes and edge cases where practical.

Prioritize tests around:
- Core behavior
- Bugs discovered during this pass
- Failure paths
- Boundary conditions
- Parsing/validation
- State transitions
- Concurrency-sensitive behavior
- Previously implicit assumptions

Do not create meaningless tests simply to increase coverage numbers.

## Build / Static Analysis

Use the tools available in the repository.

Build the project.

Run the tests.

Run appropriate formatters, linters, analyzers, compiler warnings, static-analysis tools, type checking, etc. where they already exist or can reasonably be used.

Treat warnings seriously.

Do not silence warnings just to produce a clean build unless you have verified the warning is genuinely harmless.

After making changes, build and test again.

## Comments / Documentation

Update comments and documentation when your changes invalidate them.

Remove comments that are actively misleading.

Add comments where something genuinely non-obvious needs explanation.

Do NOT litter straightforward code with comments explaining what the code literally says.

Comments should primarily explain WHY, constraints, invariants, unusual behavior, or important assumptions.

## Dead / Suspicious Code

Investigate:
- Dead code
- Unreachable branches
- Unused variables
- Unused parameters
- Abandoned implementations
- TODO/FIXME/HACK comments
- Debug leftovers
- Commented-out code
- Temporary workarounds
- Duplicate implementations

Do not blindly delete something simply because you cannot immediately find a caller. Verify first.

## Compatibility

Preserve existing intended behavior unless there is a compelling correctness/security/reliability reason to change it.

Be especially careful about:
- Public APIs
- File formats
- Configuration formats
- Serialized data
- CLI behavior
- Existing integrations
- Protocols
- User-visible behavior

If a potentially breaking change appears justified, stop and clearly explain it before making that change.

## Important: Actually Fix Things

This is NOT primarily a report-generation exercise.

When you find a real issue and the appropriate fix is reasonably clear:
1. Understand the surrounding behavior.
2. Fix it.
3. Check related code for the same pattern.
4. Add/update tests where useful.
5. Build/test the result.
6. Continue searching.

Do not merely produce a giant list of hypothetical concerns and stop.

## Think Beyond the Checklist

Most importantly, use your own engineering judgment.

I want you actively asking:

"What can go wrong here?"

"What assumptions is this code making?"

"What happens when that assumption isn't true?"

"What happens halfway through this operation if something fails?"

"What happens with empty, malformed, huge, duplicated, delayed, or unexpected input?"

"What happens if this executes twice?"

"What happens if two of these execute simultaneously?"

"What happens during startup and shutdown?"

"What happens after running for days instead of minutes?"

"What happens when an external dependency behaves differently than expected?"

"Could this fail silently?"

"Could this leave the application in a bad state?"

"Would the resulting error give us enough information to diagnose the problem?"

"Is there another occurrence of this same bug pattern elsewhere?"

Do not assume the checklist contains everything worth finding.

## Final Verification

When you believe the hardening pass is complete, make ANOTHER pass through the project specifically looking for things you missed the first time.

Review your own changes critically.

Then:
- Build from a clean state if practical.
- Run the full relevant test suite.
- Review compiler/analyzer warnings.
- Inspect the final diff for accidental behavior changes.
- Remove debugging artifacts introduced during the work.
- Confirm that error paths compile and make sense, not merely the happy path.

## Final Report

Only after completing the work, give me a concise summary containing:

- Important bugs fixed
- Reliability/hardening improvements
- Security improvements
- Significant refactoring
- Tests added/changed
- Remaining concerns you intentionally did NOT change
- Any areas that deserve further investigation
- Build/test/analyzer results

Do not pad the report with trivial formatting changes.

The standard I want is:

"If this code fails in production tomorrow, would I be annoyed that this hardening pass should obviously have caught it?"

Keep digging until the answer is no.