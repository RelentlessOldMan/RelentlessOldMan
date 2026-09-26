# Comprehensive Automated Testing Strategy — Implementation Specification

Implement a comprehensive, maintainable, practical automated testing system for this application.

This is an IMPLEMENTATION specification.

The objective is not simply to increase a code-coverage percentage.

The objective is:

> Give developers confidence that important application behavior works, remains working after changes, fails safely, preserves user data, and does not silently regress.

Tests should protect behavior that matters.

Do not create tests merely because code exists.

Do not generate hundreds of low-value tests for trivial getters, setters, constructors, framework behavior, or implementation details solely to inflate test counts or coverage.

Adapt this specification to the application's:

- Language
- Framework
- Architecture
- UI technology
- Persistence model
- External dependencies
- Build system
- Deployment model
- Risk profile

Use established testing frameworks and conventions appropriate to the project's technology.

---

# 1. FIRST UNDERSTAND THE APPLICATION

Before adding tests, inspect the application.

Identify:

- Major components
- Core business logic
- User workflows
- Data model
- Persistence layer
- Import/export behavior
- External dependencies
- File operations
- Network operations
- Device interactions
- Background operations
- UI state
- Configuration
- Error handling
- Security-sensitive operations
- Concurrency
- Existing tests
- Existing testing infrastructure

Determine what failures would matter most.

Prioritize tests according to risk, not file count.

---

# 2. DEFINE THE TESTING PYRAMID

Use multiple levels of testing where appropriate.

Potential layers include:

## Unit Tests

Fast, focused tests of isolated logic.

## Component Tests

Tests of meaningful subsystems with limited dependencies.

## Integration Tests

Tests verifying multiple real components work together.

## Persistence Tests

Tests verifying save/load/serialization behavior.

## Workflow Tests

Tests covering complete application workflows.

## UI Tests

Tests exercising meaningful UI behavior where practical.

## Regression Tests

Tests permanently preserving fixes for discovered bugs.

## Performance Tests / Benchmarks

Tests protecting important performance characteristics.

## Security / Robustness Tests

Tests using malformed, hostile, or unexpected input.

Not every application needs every layer.

Choose the layers that provide meaningful value.

---

# 3. TEST BEHAVIOR, NOT IMPLEMENTATION

Prefer tests that verify observable behavior.

Avoid tests tightly coupled to:

- Private methods
- Internal field names
- Exact implementation structure
- Incidental call ordering
- Framework internals

A reasonable internal refactor should not require rewriting the entire test suite if behavior did not change.

Test contracts and outcomes.

---

# 4. PRIORITIZE HIGH-RISK BEHAVIOR

Test the things whose failure would hurt the most.

Examples:

- User data loss
- Data corruption
- Incorrect save/load
- Invalid state transitions
- Security boundaries
- Destructive operations
- Complex calculations
- Parsing
- Import/export
- Recovery
- Authentication/authorization if applicable
- External integrations
- Concurrency-sensitive behavior

Do not spend disproportionate effort testing trivial code while dangerous code remains untested.

---

# 5. CORE BUSINESS LOGIC

Core logic should be testable without requiring the entire application UI to launch.

Where practical, separate logic from UI/platform glue enough to allow focused testing.

Do NOT perform massive architectural rewrites merely to make testing theoretically perfect.

Make pragmatic improvements where testability exposes unhealthy coupling.

---

# 6. HAPPY PATH TESTING

Test expected successful behavior.

For each important feature, verify:

- Correct input
- Expected operation
- Correct result
- Correct state transition
- Correct persisted result where applicable

Happy-path testing is necessary.

It is not sufficient.

---

# 7. FAILURE PATH TESTING

For every important operation, ask:

"What can fail?"

Then test those failures.

Examples:

- File missing
- Permission denied
- Invalid data
- Corrupt data
- Dependency unavailable
- Timeout
- External process failure
- Serialization failure
- Save failure
- Invalid configuration
- Cancellation
- Resource unavailable

Verify not only that an error occurs, but that the application remains in the CORRECT state afterward.

---

# 8. BOUNDARY TESTING

Test values at boundaries.

For numeric ranges:

- Minimum
- Minimum - 1
- Maximum
- Maximum + 1
- Zero
- Negative where applicable

For collections:

- Empty
- One item
- Typical count
- Large count

For strings:

- Empty
- Whitespace
- One character
- Maximum expected length
- Longer than expected
- Unicode
- Special characters

Boundary bugs are common.

Test them deliberately.

---

# 9. INVALID INPUT TESTING

Use malformed input.

Examples:

- Missing fields
- Extra fields
- Invalid types
- Invalid enum values
- Truncated files
- Corrupt files
- Duplicate identifiers
- Invalid references
- Unexpected ordering
- Unsupported versions
- Invalid encodings
- Extremely large values

The application should reject or handle invalid input predictably.

---

# 10. TABLE-DRIVEN / PARAMETERIZED TESTS

Use parameterized tests when the same behavior should hold across many inputs.

This is particularly useful for:

- Validation
- Parsing
- Conversions
- Boundary conditions
- File formats
- State transitions

Avoid copy/pasting nearly identical tests.

---

# 11. PERSISTENCE ROUND-TRIP TESTING

For applications that save state:

Create representative state.

Save it.

Destroy the original in-memory state.

Load the saved data.

Compare.

Test all meaningful persisted fields.

Do not merely verify that Save created a file.

The real question is:

Can the application reconstruct the same meaningful state?

---

# 12. COMPLEX PERSISTENCE ROUND TRIPS

Create a deliberately complex project/document containing as many supported features as practical.

Examples:

- Multiple items
- Different types
- Optional fields
- Custom settings
- External references
- Ordering
- Metadata
- Styles
- User modifications

Save → Load → Verify.

Then:

Modify → Save → Load → Verify again.

This should become a high-value regression test.

---

# 13. SAVE SAFETY TESTING

Test:

- Save new
- Save existing
- Save repeatedly
- Save after modification
- Save unchanged
- Save As
- Save As canceled
- Save failure
- Permission failure
- Invalid destination
- Existing destination
- Partial-write simulation where practical

Verify failed saves do not destroy previous valid data.

---

# 14. IMPORT TESTING

Test:

- Valid import
- Empty import
- Invalid import
- Corrupt import
- Partial data
- Duplicate data
- Large import
- Unsupported version
- Missing external resources
- Import canceled
- Import failure while valid work is already loaded

An unsuccessful import should not destroy existing valid application state.

---

# 15. EXPORT TESTING

Test:

- Valid export
- Repeated export
- Invalid destination
- Permission failure
- Existing destination
- Cancellation
- Missing resources
- Large export
- Partial failure

Verify Export does not incorrectly alter Save state unless explicitly designed to do so.

---

# 16. WORKFLOW TESTING

Test complete user workflows rather than only individual methods.

Examples:

Create
→ edit
→ save
→ close
→ reopen
→ verify

Import
→ edit
→ save
→ export

Open A
→ edit
→ attempt Open B
→ cancel
→ verify A remains intact

Create
→ edit
→ Save As
→ cancel
→ verify work remains intact

These tests catch bugs that isolated unit tests cannot.

---

# 17. STATE MACHINE TESTING

If application behavior depends on state, model important states explicitly.

Examples:

- Nothing loaded
- Loaded clean
- Loaded dirty
- Saving
- Importing
- Exporting
- Recovering
- Error
- Closing

Test valid transitions.

Test invalid transitions.

Verify operations are available only when appropriate.

---

# 18. DIRTY-STATE TESTING

If the application tracks unsaved changes, test it aggressively.

Examples:

Open → clean

Edit → dirty

Save → clean

Edit → undo to original state

Save failure → still dirty

Save cancellation → still dirty

Programmatic refresh → should not accidentally become dirty

Real edit → must become dirty

Dirty-state bugs can cause data loss.

Treat them seriously.

---

# 19. CANCELLATION TESTING

Every cancelable operation needs tests.

Test cancellation:

- Before work begins
- Early
- Mid-operation
- Near completion
- Repeatedly

Verify cancellation:

- Does not report success
- Does not corrupt state
- Does not leave UI/application permanently busy
- Releases resources
- Does not continue destructive follow-up actions

---

# 20. NESTED CANCELLATION

Test chained workflows.

Example:

Open B
→ current A is dirty
→ application asks Save / Don't Save / Cancel
→ choose Save
→ Save As dialog
→ cancel Save As

Expected:

Opening B must abort.

A must remain loaded.

A must remain dirty.

No work should disappear.

Create tests for this class of workflow bug.

---

# 21. CRASH RECOVERY TESTING

If crash recovery exists, test it as a first-class subsystem.

Test:

- Recovery snapshot creation
- Recovery round trip
- Never-saved work
- Existing document
- Failed Save
- Canceled Save
- Corrupt recovery
- Previous recovery generation
- Abnormal shutdown
- Normal shutdown
- Recovery cleanup
- Recovery after repeated crashes

Recovery tests should follow the application's Crash Recovery specification.

---

# 22. CONFIGURATION TESTING

Test configuration behavior.

Examples:

- Default configuration
- Missing configuration
- Corrupt configuration
- Partial configuration
- Unknown settings
- Invalid values
- Old configuration version
- New unsupported version
- Migration
- Reset to defaults

Bad configuration should not unnecessarily brick the application.

---

# 23. VERSION / MIGRATION TESTING

If persisted formats evolve, preserve representative older files as test fixtures.

Verify:

Old version
→ load
→ migrate
→ correct current representation

Where supported:

Current version
→ save
→ load

Do not accidentally break existing user data when formats evolve.

---

# 24. GOLDEN / FIXTURE FILES

Maintain carefully selected test files representing important scenarios.

Examples:

- Small valid file
- Complex valid file
- Old-version file
- Corrupt file
- Truncated file
- Edge-case file
- Large representative file

Keep fixtures intentional.

Do not accumulate hundreds of unexplained mystery files.

Document why each important fixture exists.

---

# 25. GOLDEN OUTPUT TESTS

For deterministic generated output, consider golden/reference tests.

Examples:

Input fixture
→ generate output
→ compare against known-good output

Use this for formats where exact or normalized comparison is meaningful.

Do not make tests unnecessarily brittle due to timestamps, random IDs, metadata ordering, or other irrelevant differences.

Normalize such values where appropriate.

---

# 26. REGRESSION TEST POLICY

Every meaningful bug fix should strongly consider adding a regression test.

The pattern should be:

1. Reproduce bug with test.
2. Confirm test fails.
3. Fix bug.
4. Confirm test passes.
5. Keep test permanently.

This prevents the same bug from returning.

---

# 27. BUG REPRODUCTION TESTS

When a user reports a bug:

Convert the report into the smallest reliable reproduction.

Then preserve it as a test where practical.

Over time, the test suite should become institutional memory for real failures.

---

# 28. FILESYSTEM TESTING

Use isolated temporary directories.

Do not make tests depend on:

- Developer-specific paths
- Desktop
- Documents folder
- Current working directory assumptions
- Existing user files

Each test should own its filesystem environment.

Clean up after tests.

---

# 29. FILESYSTEM FAILURE INJECTION

Where practical, simulate:

- File missing
- Directory missing
- Permission denied
- Read-only destination
- Locked file
- Failed rename
- Failed replacement
- Disk/write failure abstraction

Do not require physically filling the disk for ordinary automated tests if the architecture can simulate failure safely.

---

# 30. TIME TESTING

If behavior depends on time, abstract time enough to test it deterministically.

Avoid tests that literally sleep for long periods.

Test:

- Expiration
- Debounce
- Retry
- Timeout
- Autosave interval
- Recovery interval
- Date boundaries

Do not make the suite slow and flaky because it depends on wall-clock waiting.

---

# 31. RANDOMNESS

If application behavior uses randomness:

Allow deterministic seeds where useful.

Record failing seeds for randomized tests.

Tests should be reproducible.

---

# 32. NETWORK TESTING

If networking exists:

Do not make most tests depend on live internet services.

Use appropriate:

- Fakes
- Test servers
- Mock HTTP handlers
- Recorded fixtures where appropriate

Test:

- Success
- Timeout
- Connection failure
- Invalid response
- Partial response
- Authentication failure
- Server error
- Retry behavior
- Cancellation

Keep a small number of real integration tests if they provide meaningful value and can be executed reliably.

---

# 33. DATABASE TESTING

If a database exists:

Test:

- Schema creation
- Migrations
- Queries
- Transactions
- Rollback
- Constraints
- Duplicate handling
- Failure paths

Prefer realistic database behavior for integration tests where practical.

Do not mock the database so heavily that the test no longer proves the queries work.

---

# 34. EXTERNAL PROCESS TESTING

If the application launches tools/processes, abstract invocation sufficiently to test:

- Success
- Nonzero exit
- Missing executable
- Timeout
- Cancellation
- Invalid output
- Huge output
- stderr output
- Process crash

Use a small deterministic fake executable/test helper where useful.

---

# 35. DEVICE / HARDWARE TESTING

If hardware interaction exists:

Separate protocol/business behavior from actual hardware access where practical.

Provide fake/simulated devices for automated testing.

Keep real-hardware integration tests separate.

Test:

- Connect
- Disconnect
- Timeout
- Malformed response
- Device disappears
- Unexpected version
- Reconnection

---

# 36. UI TESTING

For GUI applications, automate high-value UI behavior where practical.

Do not attempt to automate every pixel.

Prioritize:

- Major workflows
- Enabled/disabled states
- Selection behavior
- Dialog results
- Save/Open behavior
- Cancellation
- Validation
- Dirty-state prompts
- Destructive actions
- Error recovery

UI tests should protect behavior users actually depend upon.

---

# 37. UI STATE TESTS

Where UI state logic can be tested below the rendering layer, do so.

Example:

Given:
No project loaded

Expect:
Save disabled
Export disabled
Edit controls disabled

Given:
Project loaded and dirty

Expect:
Save enabled

This is often faster and more reliable than driving the full GUI for every state combination.

---

# 38. MINIMAL END-TO-END UI TESTS

Maintain a small set of critical end-to-end UI tests.

Examples:

Launch
→ create/open
→ edit
→ save
→ close

Launch
→ import
→ modify
→ export

Launch
→ edit
→ close
→ cancel
→ verify application remains open

Keep these tests focused and valuable.

Do not build a gigantic brittle UI automation suite unless the application warrants it.

---

# 39. VISUAL REGRESSION TESTING

If visual consistency is particularly important and the framework supports reliable screenshot testing, consider visual regression tests for selected stable views.

Use carefully.

Visual tests can become extremely brittle due to:

- Fonts
- DPI
- OS differences
- Rendering engines
- Themes

Only adopt them where the environment can be controlled sufficiently.

---

# 40. CONCURRENCY TESTING

If concurrency exists, test:

- Simultaneous operations
- Cancellation
- Shutdown during operation
- Rapid repeated invocation
- Shared state
- Stale asynchronous results
- Multiple completion orders

Do not assume the same execution order every time.

---

# 41. STALE ASYNC RESULT TEST

Explicitly test:

Request A starts.

Request B starts afterward.

B finishes first.

A finishes later.

The final application state should reflect B where B is the newest authoritative request.

This is especially important for:

- Search
- Preview
- Selection-dependent loading
- Network requests
- Validation
- Background generation

---

# 42. RAPID INTERACTION TESTING

Simulate impatient users.

Examples:

Double-click command

Click Save repeatedly

Change selection rapidly

Start operation then immediately cancel

Start operation then close application

Open dialog repeatedly

Ensure operations do not duplicate or corrupt state.

---

# 43. PROPERTY-BASED TESTING

For suitable pure logic, consider property-based testing.

Examples:

Serialize → Deserialize preserves state

Encode → Decode preserves value

Sorting output is ordered

Normalization is idempotent

Valid transformations preserve invariants

Use this where it genuinely finds edge cases.

Do not introduce it merely because it sounds sophisticated.

---

# 44. FUZZ TESTING

For parsers/importers/file formats/protocols, consider lightweight fuzz testing.

Feed:

- Random bytes
- Mutated valid files
- Truncated data
- Unexpected lengths
- Invalid encodings
- Reordered structures

The primary expectation is:

Malformed input should fail safely.

It should not:

- Crash catastrophically
- Hang
- Consume unbounded memory
- Corrupt existing state

---

# 45. SECURITY TESTING

Where relevant, test:

- Path traversal
- Unsafe filenames
- Injection
- Malicious serialized input
- Invalid URLs
- Oversized inputs
- Credential redaction
- Unauthorized operations
- Unsafe external-process arguments

Security-sensitive fixes should receive regression tests.

---

# 46. DIAGNOSTICS TESTING

If the application has a diagnostics system, test:

- Log creation
- Severity
- Exception capture
- Rotation
- Support package generation
- Summary generation
- Missing logs
- Failed package creation
- Redaction

Explicitly verify secrets do NOT appear in diagnostic packages.

---

# 47. ERROR MESSAGE TESTING

Do not generally test exact complete error strings unless wording is part of a required contract.

Prefer testing:

- Correct error category
- Important context present
- Underlying cause preserved
- State remains valid

Avoid making tests fail because someone improved punctuation.

---

# 48. RESOURCE CLEANUP TESTING

Where practical, verify operations release:

- Files
- Streams
- Processes
- Database connections
- Locks
- Temporary files
- Handles

Example:

Open file
→ close
→ test can rename/delete file

This can expose leaked handles.

---

# 49. MEMORY / LEAK TESTING

For components historically prone to leaks, consider targeted tests.

Examples:

Create view
→ close view
→ ensure it can be collected where meaningful

Repeat operation many times
→ memory should stabilize within reasonable bounds

Do not make ordinary unit tests depend on unreliable exact GC timing.

Use appropriate profiling/benchmark tests separately where necessary.

---

# 50. PERFORMANCE REGRESSION TESTING

Protect important performance characteristics without creating flaky tests.

Good targets include:

- Algorithmic scaling
- Allocation count
- Large-data processing
- Critical operation benchmark

Avoid:

"Must complete in exactly 47 milliseconds."

Prefer generous thresholds or dedicated benchmark comparisons.

---

# 51. LARGE-DATA TESTING

Create representative large workloads.

Verify:

- Correctness
- Reasonable completion
- Bounded memory
- Cancellation
- No stack overflow
- No integer overflow
- No pathological slowdown

Large-data tests may be placed in a slower test category rather than every quick test run.

---

# 52. LONG-RUN / SOAK TESTS

For applications where long sessions matter, create optional soak/stress tests.

Examples:

Repeat workflow 1,000 times.

Process many files.

Open/close repeatedly.

Run background processing for extended periods.

Observe:

- Memory
- Handles
- Threads
- Temporary files
- Queue growth

These do not necessarily need to run on every local build.

---

# 53. TEST CATEGORIES

Organize tests into useful categories such as:

- Unit
- Integration
- UI
- Persistence
- Regression
- Performance
- Stress
- Hardware
- Network
- Slow

Use conventions appropriate to the test framework.

Developers should be able to run:

Fast tests frequently

and:

Full tests before release/merge.

---

# 54. FAST TEST SUITE

Maintain a fast core suite.

This should run often enough that developers actually use it.

Prioritize:

- Core logic
- Validation
- State transitions
- Important regression tests

A test suite that takes forever will be avoided.

---

# 55. FULL TEST SUITE

Maintain a broader suite for deeper verification.

This can include:

- Integration
- Persistence
- Workflow
- UI
- Large data
- Selected stress tests

Run this at appropriate checkpoints.

---

# 56. TEST ISOLATION

Tests should not depend on execution order.

A test should not require another test to run first.

Each test should create its own state.

Avoid shared mutable global test state.

Parallel execution should be safe where supported, or tests requiring serialization should explicitly declare it.

---

# 57. TEST CLEANUP

Tests must clean up:

- Temporary files
- Temporary directories
- Processes
- Servers
- Database instances
- Handles
- Environment modifications

Use framework cleanup mechanisms.

Cleanup should occur even when the test fails.

---

# 58. DETERMINISM

Tests should produce the same result when run repeatedly.

Avoid dependence on:

- Current time
- Random ordering
- Machine-specific paths
- Network availability
- Test execution order
- User locale
- Existing user configuration

Control these dependencies where practical.

---

# 59. FLAKY TEST POLICY

Treat flaky tests as defects.

Do NOT normalize:

"That test fails sometimes; rerun it."

Investigate.

Common causes:

- Timing assumptions
- Race conditions
- Shared state
- Real network dependencies
- Fixed sleeps
- File locks
- Test ordering
- UI timing

Fix the underlying issue.

Do not simply add increasingly long sleeps.

---

# 60. MOCKING STRATEGY

Mock boundaries, not everything.

Good candidates:

- External services
- Clock
- Filesystem abstraction where failure injection is needed
- Hardware
- External processes

Avoid mocking every internal class.

Over-mocking can produce tests that prove only that mocks behave according to their setup.

Use real application components together when practical.

---

# 61. TEST DOUBLES

Use:

- Fake
- Stub
- Mock
- Spy

intentionally.

Prefer simple fakes when they provide realistic behavior.

Keep test doubles reusable and understandable.

---

# 62. TEST DATA BUILDERS

Create reusable builders/factories for complex test data.

Example concept:

CreateValidProject()

CreateComplexProject()

CreateProjectWithMissingAsset()

CreateCorruptProject()

This keeps tests focused on what differs.

Avoid massive repeated setup blocks.

---

# 63. ASSERTION HELPERS

Create meaningful assertion helpers where useful.

Example:

AssertProjectsEquivalent(expected, actual)

rather than hundreds of repetitive field comparisons scattered across tests.

When assertions fail, they should produce useful diagnostic information.

---

# 64. TEST NAMING

Test names should communicate:

- Scenario
- Action
- Expected result

For example:

Save_WhenDestinationWriteFails_PreservesExistingFile

Open_WhenCurrentDocumentDirtyAndSaveCanceled_DoesNotReplaceCurrentDocument

Recovery_WhenLatestSnapshotCorrupt_UsesPreviousGeneration

A developer should understand what broke from the test name.

---

# 65. ARRANGE / ACT / ASSERT

Keep tests easy to read.

A useful general structure is:

Arrange

Act

Assert

Do not enforce ceremonial formatting when unnecessary, but maintain clear separation between setup, behavior, and verification.

---

# 66. ONE CONCEPT PER TEST

Prefer tests with a clear reason to fail.

Do not create giant tests asserting 50 unrelated behaviors unless the purpose is specifically an end-to-end workflow.

When a test fails, the developer should know what broke.

---

# 67. DO NOT DUPLICATE PRODUCTION LOGIC

Tests should not reimplement the same algorithm and compare the application against the duplicate.

Use known expected values, invariants, independent calculations, or fixtures.

Otherwise the same bug can exist in both implementations.

---

# 68. CODE COVERAGE

Measure coverage if appropriate.

Use it as a diagnostic tool.

Coverage can identify suspiciously untested areas.

Do NOT treat 100% coverage as the objective.

100% coverage can coexist with terrible tests.

Prioritize meaningful behavioral coverage.

Pay particular attention to uncovered:

- Error paths
- State transitions
- Persistence
- Destructive operations
- Security boundaries

---

# 69. MUTATION TESTING

If tooling is mature and practical for the language, consider occasional mutation testing on important core logic.

This can reveal tests that execute code without meaningfully verifying it.

Do not make this mandatory if tooling is poor or runtime cost is excessive.

---

# 70. CI INTEGRATION

Integrate automated tests into the project's existing CI/build workflow where appropriate.

At minimum:

- Build
- Run fast/core tests

For important branches/releases, consider:

- Full integration tests
- Persistence tests
- Workflow tests
- Security checks

Do not create an enormous CI pipeline if the project does not warrant it.

---

# 71. FAILED TEST OUTPUT

Test failures should be useful.

Include enough information to diagnose:

- Expected
- Actual
- Relevant input
- Relevant file/fixture
- Relevant state

Do not make developers reproduce every failure manually just to understand what assertion failed.

---

# 72. TEST ARTIFACTS

For failed integration/UI tests, preserve useful artifacts where practical.

Examples:

- Logs
- Screenshot
- Generated file
- Diff
- Diagnostic summary

Only retain artifacts when they help debugging.

Avoid dumping enormous amounts of data on every successful test.

---

# 73. SNAPSHOT / GOLDEN DIFFS

When comparing structured output, produce understandable differences.

A test failure should ideally say WHAT changed.

Normalize irrelevant values such as:

- Timestamps
- Random IDs
- Temporary paths

where those values are not part of the behavior under test.

---

# 74. TEST THE TEST INFRASTRUCTURE

Verify important helpers themselves where warranted.

Examples:

- Failure injection actually fails
- Fake clock advances correctly
- Fixture builders produce valid state
- Corruption helper actually creates invalid data

A broken test helper can create false confidence.

---

# 75. DEVELOPER EXPERIENCE

Make testing easy.

Document simple commands for:

- Run fast tests
- Run all tests
- Run one test
- Run integration tests
- Run UI tests
- Run benchmarks

A new developer should not need tribal knowledge to execute the suite.

---

# 76. TEST DOCUMENTATION

Add a concise testing document describing:

- Test project structure
- Test categories
- How to run them
- Important fixtures
- How to add regression tests
- How to simulate failures
- Which tests require special dependencies

Keep it practical.

Do not write a giant testing manifesto that immediately becomes outdated.

---

# 77. NEW FEATURE EXPECTATION

Establish a project convention:

New meaningful behavior should normally include tests.

Bug fixes should normally include regression tests.

New persistence fields should update round-trip tests.

New state transitions should update state tests.

New failure modes should update failure tests.

Testing should evolve WITH the application.

---

# 78. TEST REVIEW OF EXISTING CODE

After the infrastructure exists, review the current codebase and identify important untested behavior.

Do not attempt to blindly test every line.

Create tests for the highest-risk existing behavior first.

Continue until the major application workflows and dangerous failure paths have meaningful protection.

---

# 79. MINIMUM HIGH-VALUE TEST SET

For a typical stateful application that imports/edits/saves work, ensure tests equivalent to these exist where applicable:

## Basic lifecycle

Create
→ edit
→ save
→ load
→ verify

## Import lifecycle

Import
→ verify
→ edit
→ save
→ reload
→ verify

## Dirty state

Load
→ edit
→ dirty
→ save
→ clean

## Cancel

Edit
→ Open another
→ Save prompt
→ Cancel
→ current work intact

## Nested cancel

Edit
→ Open another
→ Save
→ Save As
→ Cancel
→ original work intact

## Save failure

Edit
→ Save fails
→ work remains intact and dirty

## Failed import

Valid work loaded
→ import bad data
→ failure
→ existing work intact

## Round trip

Complex state
→ save
→ destroy memory state
→ reload
→ equivalent state

## Recovery

Edit
→ recovery snapshot
→ simulate abnormal termination
→ restore
→ verify work

## Corruption

Attempt load of corrupt data
→ controlled failure
→ application remains usable

## Repeated operations

Save repeatedly
→ state remains correct

## Stale async result

A starts
→ B starts
→ B completes
→ A completes
→ B remains authoritative

These tests provide disproportionately high value.

---

# 80. FINAL TEST SUITE VALIDATION

Once the testing system is implemented:

1. Run the complete test suite.

2. Verify tests pass from a clean checkout/build.

3. Run tests repeatedly to expose flakiness.

4. Verify tests do not depend on execution order.

5. Verify temporary resources are cleaned.

6. Verify important failure injection actually works.

7. Review test runtime.

8. Review coverage for suspicious gaps.

9. Intentionally break several important behaviors and verify relevant tests fail.

Examples:

- Break serialization.
- Break dirty-state transition.
- Make Save report success incorrectly.
- Break cancellation propagation.
- Disable recovery cleanup.

The suite should catch these.

Then revert the intentional changes.

A test suite that stays green when important behavior is deliberately broken is not providing sufficient protection.

---

# 81. DO NOT CHASE TEST COUNT

Never optimize for:

- Number of tests
- Number of assertions
- Coverage percentage
- Lines of test code

Optimize for:

CONFIDENCE.

Ten excellent tests protecting critical workflows can be more valuable than one thousand trivial tests.

---

# 82. DO NOT MAKE THE SUITE A MAINTENANCE NIGHTMARE

Tests are production engineering assets.

Keep them:

- Clear
- Fast where possible
- Deterministic
- Focused
- Reusable
- Maintainable

Avoid brittle tests tied to irrelevant implementation details.

If developers become afraid to change working code because 300 meaningless tests break every time a private method changes, the testing strategy has failed.

---

# 83. FINAL IMPLEMENTATION REPORT

After implementing the testing strategy, provide a concise report containing:

- Testing infrastructure added
- Test projects/modules created
- Testing frameworks used
- Test categories established
- Major behaviors now covered
- Failure scenarios covered
- Persistence/workflow tests added
- Regression tests added
- UI tests added where applicable
- Fixtures/helpers created
- CI integration performed
- Coverage information if available
- Test runtime
- Known testing gaps
- Areas intentionally not tested and why
- Recommended future testing work

Do not pad the report with trivial tests.

---

# ACCEPTANCE CRITERIA

The testing system is complete when:

1. The application has a reliable automated test infrastructure.

2. Core logic has meaningful behavioral tests.

3. Important workflows have integration/workflow coverage.

4. Save/load persistence has round-trip testing where applicable.

5. Important failure paths are tested.

6. Cancellation paths are tested.

7. Dirty-state behavior is tested where applicable.

8. Data-loss scenarios receive especially strong protection.

9. Important bugs can be preserved as regression tests.

10. Tests are deterministic.

11. Tests are isolated.

12. Tests can run from a clean environment.

13. The fast/core suite is practical to run frequently.

14. Deeper tests can be run separately where appropriate.

15. Test failures provide useful diagnostic information.

16. Important external dependencies can be simulated where practical.

17. Malformed input is tested where relevant.

18. Important concurrency/async behavior is tested where relevant.

19. Recovery behavior is tested if recovery exists.

20. Diagnostic redaction is tested if diagnostics exist.

21. CI/build integration exists where appropriate.

22. Developers can easily understand how to run and extend the suite.

23. The suite has been verified by deliberately breaking important behavior and confirming tests catch it.

The final standard is:

> If I make a seemingly harmless change six months from now that breaks an important workflow, corrupts saved data, loses user work, mishandles cancellation, or resurrects an old bug, how likely is this test suite to catch it before the user does?

The answer should be:

> Very likely.

And:

> If all tests pass, does that actually tell me something meaningful about whether this application works?

The answer must also be:

> Yes.

Build tests for confidence, not statistics.