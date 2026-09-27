# Deep Reusable Utility Library / Common-Code Review

Perform an extremely thorough, no-stone-unturned review of this entire reusable utility/common-code library.

This review is specifically for a general-purpose "tool belt" library containing classes, helpers, extensions, abstractions, and common functionality intended to be reused across many unrelated applications and projects.

This is NOT merely a normal code review.

Reusable library code requires a different standard because:

> A defect in application code may affect one application.

> A defect, bad abstraction, dangerous default, hidden assumption, or poorly designed API in a common library can propagate into every application that consumes it.

Treat every public API as potentially long-lived.

Treat every hidden assumption as something future applications may accidentally inherit.

Treat every dependency as something downstream applications may also inherit.

Treat every utility as something another developer may use WITHOUT understanding its implementation.

The goal is not merely:

"Does this code work today?"

The goal is:

> Is this code genuinely reusable, difficult to misuse, predictable, maintainable, portable where intended, well-tested, appropriately scoped, and safe to depend upon for years?

Adapt this review to the project's actual language, framework, platforms, architecture, and intended consumers.

Do not mechanically rewrite working code.

Do not create abstractions merely for abstraction's sake.

Do not turn simple helpers into enterprise architecture.

Improve things when there is a concrete correctness, usability, maintainability, portability, safety, performance, or API-design reason.

---

# 1. FIRST UNDERSTAND THE LIBRARY

Before changing anything, inspect the entire library.

Determine:

- What problem is this library intended to solve?
- Who consumes it?
- How many projects consume it?
- Is it internal or public?
- Is backward compatibility important?
- What platforms are intended?
- What runtimes/frameworks are intended?
- What language versions are intended?
- What dependencies exist?
- Which APIs are public?
- Which APIs are heavily used?
- Which APIs are legacy?
- Which components are platform-specific?
- Which components are application-specific despite living here?
- Which components are foundational dependencies for other utilities?

Identify the library's actual role before redesigning it.

---

# 2. INVENTORY THE PUBLIC SURFACE

Create an inventory of the reusable/public surface.

Include as appropriate:

- Public classes
- Interfaces
- Structs
- Records/data objects
- Enums
- Extension methods
- Public methods
- Public properties
- Events
- Delegates
- Constants
- Public configuration types
- Exceptions
- Serialization types
- Public generic constraints

Determine which APIs are intended for external consumption and which became public accidentally.

Reduce unnecessary public surface where doing so does not create unacceptable compatibility problems.

Every public API creates future maintenance obligations.

---

# 3. CLASSIFY EVERY MAJOR UTILITY

For every significant utility, class, subsystem, or public API group, assign one architectural classification:

## KEEP

The utility is appropriately scoped, reusable, understandable, and belongs in the library substantially as-is.

## IMPROVE

The utility belongs here but has correctness, API, testing, documentation, portability, performance, or maintainability issues worth fixing.

## MERGE

The utility overlaps substantially with another utility and should probably become one coherent abstraction.

## SPLIT

The utility contains multiple unrelated responsibilities and should be separated.

## MOVE

The code may be valid but does not belong in this general-purpose library.

Examples:

- Application-specific behavior
- UI-specific logic in an otherwise headless core
- Product-specific policy
- Domain-specific business logic

## DEPRECATE

The API has consumers and should not immediately disappear, but a better replacement should be introduced and the old API phased out.

## DELETE

The utility is unused, redundant, harmful, obsolete, superseded, or provides no meaningful value.

Do not classify merely for the sake of classification.

Use the classification to expose architectural entropy.

Produce a final classification summary.

---

# 4. DOES THIS CODE ACTUALLY BELONG HERE?

For every major component ask:

"Is this genuinely reusable common functionality?"

Watch for the utility library becoming a junk drawer.

Common warning signs:

- Product-specific class names
- Application-specific paths
- Hardcoded UI behavior
- Hardcoded service endpoints
- Business rules
- Project-specific data models
- Product-specific configuration
- One application's workflow logic
- Code only ever used by one specialized application

Do not move code merely because it currently has one consumer.

Some genuinely generic utilities naturally begin with one consumer.

Judge by responsibility and coupling.

---

# 5. PUBLIC API DESIGN

Review every public API as though it may become a permanent contract.

Ask:

- Is the name clear?
- Is its purpose obvious?
- Are parameters understandable?
- Are parameter types appropriate?
- Is parameter ordering intuitive?
- Are defaults safe?
- Is the return type appropriate?
- Is failure behavior obvious?
- Are side effects obvious?
- Is ownership obvious?
- Is mutability obvious?
- Is thread safety obvious where relevant?
- Can the API easily be misused?
- Does the caller need hidden knowledge?

A method can be perfectly implemented and still have a bad API.

---

# 6. BOOLEAN PARAMETER ABUSE

Look for APIs like:

DoThing(value, true, false, true)

This is difficult to understand at call sites.

Consider:

- Enum/options types
- Named configuration objects
- Separate methods
- Strongly typed concepts

where appropriate.

Do not replace every boolean with an elaborate options hierarchy.

Fix genuinely ambiguous APIs.

---

# 7. PARAMETER EXPLOSION

Review methods with many parameters.

Determine whether they represent:

- Too many responsibilities
- Missing domain/configuration object
- Poor abstraction
- Legitimately complex operation

Avoid enormous signatures that are easy to call incorrectly.

---

# 8. RETURN VALUES

Review whether methods return useful and predictable results.

Watch for:

- Returning null unexpectedly
- Returning magic values
- Ambiguous booleans
- Returning mutable internal collections
- Returning disposable resources without clear ownership
- Returning overly concrete types
- Returning implementation-specific details

Make failure and success semantics obvious.

---

# 9. NULL SEMANTICS

For every public API, determine:

- Can parameters be null?
- What does null mean?
- Can the result be null?
- Is null different from empty?
- Is null validated immediately?
- Are nullable annotations correct where supported?

Be consistent.

Do not allow accidental NullReference-style failures deep inside a utility when invalid input could have been rejected clearly at the boundary.

---

# 10. EMPTY INPUT SEMANTICS

Determine behavior for:

- Empty string
- Whitespace
- Empty collection
- Empty file
- Zero-length buffer
- Missing optional data

Null and empty are not automatically equivalent.

Define intentional behavior.

---

# 11. EXCEPTION CONTRACTS

Review exception behavior.

Ask:

- What failures throw?
- Which exception types?
- Are exceptions meaningful?
- Are underlying exceptions preserved?
- Is context added appropriately?
- Are expected conditions incorrectly represented as exceptions?
- Are serious failures silently swallowed?

Avoid:

catch
→ ignore

unless ignoring is explicitly correct and documented.

Avoid wrapping every exception in a generic exception that destroys useful type/stack information.

---

# 12. TRY-PATTERN CONSISTENCY

Where the language/framework commonly uses Try-style APIs, review consistency.

A method named conceptually:

TryParse...

should normally:

- Not throw for ordinary parse failure
- Clearly indicate success/failure
- Produce predictable output on failure

Do not use Try naming for operations that routinely throw on normal failure.

---

# 13. NAMING CONSISTENCY

Review naming across the library.

Similar concepts should use similar language.

Look for inconsistent pairs like:

Load / Read / Fetch / Get / Retrieve

when they mean the same thing.

Likewise:

Remove / Delete

Create / Build / Generate

Convert / Transform / Map

Do not force artificial uniformity where distinctions are meaningful.

But eliminate accidental vocabulary chaos.

---

# 14. DISCOVERABILITY

A consumer should be able to find functionality.

Review:

- Namespaces/packages
- Class names
- Method names
- Extension methods
- Grouping
- Documentation

Avoid generic dumping grounds such as:

Utils

Helpers

Common

Misc

General

if they become giant unrelated collections.

A utility library itself may be a tool belt.

Individual components should still have coherent responsibilities.

---

# 15. STATIC UTILITY CLASSES

Review large static helper classes.

Static utilities can be perfectly appropriate.

But ask:

- Is the class cohesive?
- Does it hide mutable global state?
- Does it make testing difficult?
- Does it contain unrelated methods?
- Does it depend on environment/global configuration?
- Does it secretly require initialization?

Split incoherent utility buckets.

Do not convert every static method into dependency-injected services without reason.

---

# 16. EXTENSION METHODS

Review extension methods carefully.

An extension method should feel like a natural operation on the extended type.

Avoid extension methods that:

- Hide expensive work
- Perform surprising I/O
- Mutate unexpectedly
- Depend on global state
- Pollute common types with niche operations

Extension methods are highly discoverable.

Use that power responsibly.

---

# 17. SIDE EFFECTS

Identify public APIs with side effects.

Examples:

- File writes
- Environment changes
- Process launching
- Global configuration
- Logging
- Network activity
- Mutation

The API should not look like a harmless query while secretly doing substantial work.

A method named:

GetSomething()

should not unexpectedly modify global state.

---

# 18. MUTABILITY

Review mutable public objects.

Ask:

- Does this need to be mutable?
- Who owns it?
- Can callers corrupt invariants?
- Are collections exposed directly?
- Is defensive copying warranted?
- Would immutable/value semantics make the contract safer?

Do not blindly make everything immutable.

Use mutability intentionally.

---

# 19. COLLECTION OWNERSHIP

For every collection crossing a public boundary determine:

- Is it copied?
- Is it shared?
- Is it read-only?
- Can the caller mutate it?
- Can the library mutate it later?
- Is enumeration lazy?
- Can it be enumerated multiple times?

Avoid exposing internal mutable collections accidentally.

---

# 20. LAZY ENUMERATION

Review APIs returning lazy sequences/iterators.

Determine whether enumeration:

- Repeats expensive work
- Depends on disposed resources
- Performs I/O
- Can throw later unexpectedly
- Observes mutable state
- Can only safely occur once

Do not return laziness merely because the language makes it easy.

Use it when semantics are appropriate.

---

# 21. GENERICS

Review generic APIs.

Ask:

- Are generic parameters meaningful?
- Are constraints correct?
- Is genericity actually useful?
- Does it complicate callers?
- Is runtime type inspection defeating the point?

Avoid over-generalizing utilities into unreadable generic machinery.

---

# 22. TYPE SAFETY

Look for APIs using primitive/string values where stronger types would materially prevent mistakes.

Examples might include:

- Paths
- Durations
- IDs
- Units
- Modes
- Encodings
- Options

Do not create a custom type for every string.

Use stronger typing where confusion is realistic and costly.

---

# 23. UNITS

Review numeric APIs for ambiguous units.

Bad:

timeout = 5000

Is that:

- milliseconds?
- seconds?
- microseconds?

Prefer explicit duration types or unmistakable names.

Likewise review:

- Bytes vs KB/MB
- Pixels vs logical units
- Degrees vs radians
- Local time vs UTC

Unit ambiguity in common libraries creates reusable bugs.

---

# 24. TIME HANDLING

Review all date/time code.

Determine:

- Local vs UTC
- Date vs timestamp
- Time zone behavior
- DST behavior
- Serialization format
- Precision
- Clock dependency

Use appropriate time representations.

Where logic depends heavily on "now," consider allowing a controllable clock for testing.

Do not over-abstract trivial timestamp generation.

---

# 25. CULTURE / LOCALE

Review:

- Numeric parsing
- Numeric formatting
- Date parsing
- Date formatting
- Case conversion
- Comparisons
- Sorting

Determine whether behavior should use:

- Current culture
- Invariant culture
- Ordinal comparison
- Culture-aware comparison

Make the choice intentional.

Reusable libraries should not accidentally behave differently because one user's machine uses a different locale.

---

# 26. UNICODE

Test text utilities with:

- ASCII
- Accented Latin text
- CJK
- Emoji
- Combining characters
- Surrogate pairs where relevant
- Different normalization forms

Do not assume:

character == byte

or even:

user-visible character == one code unit.

Adapt rigor to what the utility actually promises.

---

# 27. STRING COMPARISON

Review string equality and ordering.

Determine whether comparisons represent:

- User-visible language
- Identifier
- File/path
- Protocol token
- Case-insensitive key

Use appropriate comparison semantics.

Avoid accidental culture-sensitive identifier comparisons.

---

# 28. PORTABILITY REVIEW

Identify every platform assumption.

Examples:

- Windows APIs
- Registry
- Drive letters
- Backslashes
- Case-insensitive filesystem
- Windows shell
- Linux utilities
- POSIX permissions
- macOS paths
- Environment variables
- Native DLLs
- Process behavior

Determine the library's intended portability contract.

---

# 29. PLATFORM-SPECIFIC CODE

Platform-specific utilities are allowed.

But they should be clearly isolated and named.

Do not let supposedly generic components unexpectedly depend on:

- Windows registry
- Win32
- WMI
- `/proc`
- shell commands
- platform-specific filesystem semantics

Consider separate namespaces/modules/packages where appropriate.

---

# 30. FILE PATH CORRECTNESS

Review filesystem helpers aggressively.

Test:

- Relative paths
- Absolute paths
- Paths with spaces
- Unicode paths
- Long paths
- Root paths
- Trailing separators
- `.` and `..`
- UNC/network paths where applicable
- Different separators
- Nonexistent paths
- Files vs directories
- Symlinks where relevant

Use platform path APIs rather than manual string concatenation.

---

# 31. PATH SECURITY

For utilities handling caller-controlled paths, review:

- Path traversal
- Canonicalization
- Archive extraction paths
- Temporary files
- Symlinks
- Relative path escape

Do not assume joining a trusted root with an untrusted string automatically keeps access inside the root.

---

# 32. FILE OPERATIONS

Review:

- Read
- Write
- Replace
- Move
- Copy
- Delete
- Rename

Check behavior under:

- Missing file
- Existing file
- Permission failure
- Locked file
- Read-only file
- Partial write
- Cancellation
- Cross-volume movement

Do not destroy valid data unnecessarily.

---

# 33. ATOMIC WRITES

If the library provides persistence/file-writing helpers, consider safe write patterns.

Conceptually:

Existing valid file
→ write temporary new file
→ close/flush
→ replace

where appropriate.

A generic helper intended to make saving safer could be valuable.

But document its guarantees accurately.

Do not claim atomicity where the platform cannot provide it.

---

# 34. TEMPORARY FILES

Review temp-file utilities.

Check:

- Unique naming
- Race conditions
- Cleanup
- Permissions
- Failure paths
- Temp directory selection
- File extension assumptions

Avoid predictable unsafe temporary filenames.

---

# 35. STREAM OWNERSHIP

For every API accepting or returning streams/resources, make ownership explicit.

Ask:

- Who closes it?
- Does the method leave input open?
- Is that configurable?
- What happens on exception?

Do not unexpectedly dispose caller-owned resources.

Do not leak library-owned resources.

---

# 36. DISPOSABLE RESOURCE OWNERSHIP

Audit resources requiring disposal.

Examples:

- Streams
- Readers/writers
- HTTP responses
- Timers
- Processes
- Database objects
- Native handles
- Graphics objects

Ownership must be understandable from the API.

---

# 37. THREAD SAFETY INVENTORY

For every significant reusable type, determine its concurrency model.

Classify conceptually as:

- Immutable/thread-safe
- Thread-safe
- Safe for independent instances
- Not safe for concurrent access
- Requires external synchronization

Do not leave thread safety accidental.

---

# 38. SHARED MUTABLE STATE

Search aggressively for:

- Static mutable fields
- Global caches
- Global configuration
- Singleton mutable objects
- Shared random generators where problematic
- Shared buffers
- Shared temporary state

Determine whether synchronization is correct.

Prefer eliminating unnecessary global mutable state.

---

# 39. LOCKING

Review synchronization.

Look for:

- Locking public objects
- Locking strings/types
- Excessively broad locks
- Locks around I/O
- Nested locks
- Deadlock potential
- Lock contention

Use private synchronization objects where appropriate.

Do not sacrifice correctness for speculative lock elimination.

---

# 40. CONCURRENT COLLECTIONS

If shared collections are accessed concurrently, verify the collection and surrounding compound operations are actually safe.

A thread-safe collection does not automatically make:

Check
→ then add

atomic.

Review multi-step operations carefully.

---

# 41. ASYNC API DESIGN

Review every asynchronous API.

Async methods should normally follow language/framework conventions.

Check:

- Naming
- Return types
- Cancellation
- Exception propagation
- Resource lifetime
- Context assumptions

Do not expose asynchronous behavior through misleading synchronous APIs.

---

# 42. SYNC-OVER-ASYNC

Search for patterns conceptually equivalent to:

.Wait()

.Result

blocking async operations synchronously.

Determine whether they can:

- Deadlock
- Block UI threads
- Starve thread pools
- Reduce scalability

Replace where appropriate.

Do not mechanically change APIs without considering compatibility.

---

# 43. ASYNC-OVER-SYNC

Also look for fake async APIs that simply wrap synchronous work unnecessarily.

Do not use thread-pool scheduling merely to put "Async" on a method.

CPU-bound and I/O-bound operations have different requirements.

Use appropriate patterns.

---

# 44. FIRE-AND-FORGET

Audit unawaited tasks.

For each one ask:

- Who owns it?
- Who observes exceptions?
- How is it canceled?
- What happens during shutdown?
- Can it outlive required state?

Uncontrolled fire-and-forget work is dangerous in reusable libraries.

---

# 45. CANCELLATION

Long-running asynchronous APIs should accept cancellation where appropriate.

Verify cancellation is:

- Propagated
- Observed
- Not converted into success
- Not swallowed as generic failure
- Passed to nested operations

Do not add cancellation tokens to trivial operations where they provide no value.

---

# 46. TIMEOUTS

For operations that can wait on external resources, review timeout behavior.

Avoid:

- Infinite waits by accident
- Arbitrary hidden timeouts
- Confusing timeout units
- Timeout represented as unrelated failure

Allow callers appropriate control where warranted.

---

# 47. SYNCHRONIZATION CONTEXT / UI ASSUMPTIONS

A general-purpose library should normally avoid assuming:

- WinForms UI thread
- WPF dispatcher
- MAUI synchronization context
- ASP.NET context
- Specific message loop

Core reusable utilities should not unexpectedly marshal to UI threads.

Keep UI-specific adapters separate.

---

# 48. CALLBACKS AND EVENTS

Review events/callbacks.

Check:

- Subscription lifetime
- Unsubscription
- Memory leaks
- Exception behavior
- Thread on which callbacks occur
- Reentrancy
- Ordering guarantees

Document important behavior.

---

# 49. REENTRANCY

Determine whether callbacks/events can re-enter library code.

Example:

Library changes state
→ raises event
→ consumer calls library again
→ original operation still incomplete

Protect invariants where necessary.

---

# 50. SECURITY REVIEW

Treat common-code security bugs as high impact.

Identify utilities involving:

- Files
- Paths
- Archives
- Processes
- Shells
- Serialization
- Networking
- URLs
- Credentials
- Encryption
- Random values
- Temporary files
- Configuration

Review them aggressively.

---

# 51. PROCESS LAUNCHING

If process helpers exist, inspect:

- Executable selection
- Argument escaping
- Shell invocation
- Working directory
- Environment inheritance
- stdout/stderr handling
- Timeout
- Cancellation
- Exit code
- Process cleanup

Avoid command injection.

Prefer structured argument APIs over constructing shell command strings where possible.

---

# 52. SHELL EXECUTION

Shell helpers deserve special scrutiny.

If a helper runs arbitrary shell text, make that danger obvious.

Do not hide shell execution behind innocent-looking APIs.

Avoid invoking a shell when direct process execution is sufficient.

---

# 53. ARCHIVE EXTRACTION

If archive utilities exist, protect against archive path traversal / Zip Slip-style problems.

Entries must not escape the intended extraction directory.

Also consider:

- Absolute paths
- `..`
- Symlinks
- Excessive expansion
- Huge file counts

---

# 54. SERIALIZATION SECURITY

Avoid unsafe deserialization mechanisms capable of arbitrary object construction/execution.

Validate untrusted serialized input.

Version formats.

Apply reasonable size/depth limits where appropriate.

---

# 55. NETWORK SECURITY

Review network utilities for:

- TLS behavior
- Certificate validation
- Redirect handling
- Credential leakage
- URL validation
- Timeouts
- Proxy behavior
- Request headers
- Response-size limits

Never disable certificate validation globally as a convenience.

---

# 56. SECRETS

Search for:

- Hardcoded passwords
- API keys
- Tokens
- Connection strings
- Private keys
- Credentials

Do not place secrets in reusable source code.

Review helpers that log configuration to ensure secrets are redacted.

---

# 57. RANDOMNESS

Determine whether random-number helpers are intended for:

- Simulation/convenience

or:

- Security

Do not use non-cryptographic randomness for:

- Security tokens
- Password generation
- Secret identifiers
- Cryptographic material

Name APIs clearly enough that callers do not confuse the two.

---

# 58. CRYPTOGRAPHY

If cryptographic helpers exist, scrutinize them heavily.

Prefer established platform/library primitives.

Avoid custom cryptography.

Check:

- Algorithms
- Modes
- Nonces/IVs
- Key derivation
- Salt
- Authentication
- Encoding
- Key storage

If an API makes insecure cryptographic usage easy, redesign it.

---

# 59. DEPENDENCY INVENTORY

Inventory every external dependency.

For each ask:

- Why is it needed?
- Which utility needs it?
- How large is it?
- Is it actively maintained?
- Does the platform already provide equivalent functionality?
- Does it introduce transitive dependencies?
- Does it constrain target frameworks?
- Does it introduce security concerns?
- Does it complicate deployment?

A reusable library's dependencies propagate outward.

Treat them as part of the public cost of the library.

---

# 60. DEPENDENCY HYGIENE

Avoid adding a large package for trivial functionality that can be implemented clearly and safely with standard platform facilities.

Conversely:

Do not reimplement complex, security-sensitive, or mature functionality merely to avoid a reasonable dependency.

Evaluate tradeoffs intelligently.

---

# 61. OPTIONAL DEPENDENCIES

If only one niche utility requires a heavy dependency, consider whether that functionality belongs in:

- Separate module
- Separate package
- Optional integration library

Do not force every consumer to inherit dependencies they do not use.

---

# 62. DEPENDENCY VERSIONING

Review version constraints.

Avoid unnecessarily strict version pinning that causes downstream conflicts.

Also avoid unconstrained behavior that can silently pull incompatible versions.

Follow the ecosystem's established package-versioning practices.

---

# 63. DEPENDENCY COLLISIONS

Consider how the library behaves when consuming applications already depend on different versions of the same packages.

A utility library should minimize dependency-conflict pressure.

---

# 64. FRAMEWORK DEPENDENCIES

Avoid making generic core utilities depend on UI frameworks or application frameworks unnecessarily.

Examples:

Core string/file utilities should not need:

- WinForms
- WPF
- ASP.NET
- MAUI

unless the utility is explicitly framework-specific.

---

# 65. LOGGING ABSTRACTION

If the library logs, determine how that interacts with consuming applications.

Avoid forcing a particular logging stack on every consumer without strong reason.

Consider:

- Existing standard logging abstraction
- Optional callback/interface
- No logging for simple pure utilities

Do not silently write files or console output from generic library code unless that is explicitly its purpose.

---

# 66. CONFIGURATION

Reusable libraries should not casually depend on one application's configuration system.

Avoid hidden reads from:

- Global config files
- Registry
- Environment variables
- Static application settings

unless explicitly part of the API.

Prefer callers supplying required configuration.

---

# 67. ENVIRONMENT SIDE EFFECTS

Search for code modifying:

- Current directory
- Environment variables
- Process-wide culture
- TLS settings
- Global certificate callbacks
- Console configuration
- Thread pool settings

Reusable library code should almost never modify process-wide behavior unexpectedly.

---

# 68. CURRENT DIRECTORY ASSUMPTIONS

Never assume the current working directory is:

- Executable directory
- Project directory
- User data directory

Use explicit paths or appropriate platform APIs.

This is a classic reusable-code bug.

---

# 69. PERFORMANCE

Profile or reason carefully about utilities likely to run frequently.

Look for:

- O(n²) behavior
- Repeated enumeration
- Repeated parsing
- Excessive allocation
- Unnecessary reflection
- Regex recreation
- Repeated encoding conversion
- Excessive locking
- Hidden I/O

Do not micro-optimize rarely used helpers.

Prioritize reusable hot paths.

---

# 70. HIDDEN EXPENSIVE OPERATIONS

An innocent-looking utility should not unexpectedly perform enormous work.

Examples:

property access
→ scans filesystem

extension method
→ network request

ToString-like operation
→ huge serialization

Make expensive behavior discoverable from API design and documentation.

---

# 71. LARGE INPUTS

Test utilities with large inputs where relevant.

Examples:

- Large strings
- Large files
- Large collections
- Deep trees
- Large JSON/XML
- Many directory entries

Watch for:

- Memory explosions
- Stack overflow
- Integer overflow
- Pathological algorithms

---

# 72. RESOURCE LIMITS

For parsers/processors handling potentially untrusted input, consider reasonable limits.

Examples:

- Maximum nesting
- Maximum size
- Maximum entry count
- Maximum output expansion

Do not introduce arbitrary restrictive limits without justification.

---

# 73. CACHES

Review caches.

Ask:

- Why does this exist?
- Is it bounded?
- Is it thread-safe?
- Can values become stale?
- What invalidates them?
- Can cache keys retain huge objects?
- Does the cache provide measurable benefit?

A static cache in a utility library can become a process-lifetime memory leak.

---

# 74. REGULAR EXPRESSIONS

Review regex usage.

Check:

- Correctness
- Compilation/reuse where relevant
- Catastrophic backtracking risk
- Timeout support where available
- Untrusted input behavior

Do not use regex for parsing structures where a real parser is safer and clearer.

---

# 75. REFLECTION

Review reflection-heavy utilities.

Check:

- Performance
- Trimming/AOT compatibility where relevant
- Error handling
- Generic correctness
- Private-member assumptions
- Version fragility

Reflection can be useful.

Do not use it merely to avoid explicit APIs.

---

# 76. SERIALIZATION CONTRACTS

If the library exposes serialized formats:

Treat them as compatibility contracts.

Review:

- Field names
- Versioning
- Optional fields
- Unknown fields
- Backward compatibility
- Forward compatibility where possible
- Default values

Do not casually rename serialized fields because internal property names changed.

---

# 77. VERSIONING

Determine how the library itself is versioned.

If it has external consumers, use meaningful versioning.

Breaking changes should be deliberate.

Do not accidentally introduce breaking API changes in a "cleanup."

---

# 78. BACKWARD COMPATIBILITY

Before changing public APIs, search for consumers.

Determine:

- Who calls this?
- Can they be updated together?
- Is binary compatibility relevant?
- Is source compatibility enough?
- Is deprecation preferable?

Do not treat a utility library like isolated application code.

---

# 79. DEPRECATION STRATEGY

For flawed public APIs with existing consumers:

Prefer where appropriate:

1. Introduce better API.
2. Mark old API deprecated/obsolete.
3. Document replacement.
4. Migrate consumers.
5. Remove later when compatibility policy permits.

Do not keep dangerous APIs forever merely because they already exist.

But do not break consumers casually.

---

# 80. OVERLOAD CONSISTENCY

Review overload families.

They should behave consistently.

Watch for:

- Different defaults
- Different validation
- Different exception behavior
- Different cancellation behavior

One overload should not be subtly dangerous while another is safe.

---

# 81. DEFAULT VALUES

Defaults are part of API design.

Defaults should usually represent:

- Safe behavior
- Common behavior
- Least surprising behavior

Dangerous/destructive behavior should rarely be the effortless default.

---

# 82. IDEMPOTENCE

Identify operations callers may reasonably repeat.

If something is naturally expected to be idempotent, verify it.

Examples:

EnsureDirectoryExists()

Dispose()

Stop()

Unregister()

Do not create surprising failure behavior for harmless repeated operations without reason.

---

# 83. EQUALITY / HASHING

For public value-like types, verify:

- Equality
- Hash code
- Ordering
- Mutability

If objects are used as dictionary keys or set members, mutable equality state can be dangerous.

---

# 84. COMPARERS

If custom comparison/sorting utilities exist, verify:

- Transitivity
- Symmetry
- Equality consistency
- Null behavior
- Culture behavior

Broken comparers can produce bizarre failures far from the source.

---

# 85. NUMERIC CORRECTNESS

Review numeric helpers for:

- Overflow
- Underflow
- Precision
- Integer division
- Signed/unsigned conversion
- Floating-point equality
- NaN
- Infinity
- Negative zero where relevant

Do not silently overflow where correctness matters.

---

# 86. BOUNDARY CONDITIONS

For each utility, explicitly consider:

- Minimum
- Maximum
- Zero
- Empty
- One
- Negative
- Null
- Extremely large
- Duplicate
- Already exists
- Does not exist

Reusable helpers should be boringly predictable at boundaries.

---

# 87. ERROR MESSAGES

Errors from reusable code should help the consuming developer understand what was wrong.

Include relevant context.

Avoid vague messages such as:

"Invalid input."

Prefer meaningful context without exposing secrets.

---

# 88. ARGUMENT VALIDATION

Validate public boundaries appropriately.

Fail early for programmer errors.

Use idiomatic argument exceptions/errors.

Do not repeatedly validate the same internal value through every private layer unless necessary.

---

# 89. SECURITY VS CONVENIENCE

Be suspicious of APIs that make dangerous operations extremely convenient.

Examples:

RunShell(string command)

DisableCertificateValidation()

DeserializeAnyObject()

ExtractZipAnywhere()

DeleteRecursive(path)

If dangerous functionality is legitimately required, make the risk obvious and provide safe defaults.

---

# 90. DESTRUCTIVE OPERATIONS

Review delete/overwrite/replace helpers carefully.

Ask:

- Can wrong path destroy unrelated data?
- Is root deletion possible?
- Are symlinks followed?
- Is recursive behavior explicit?
- Is overwrite explicit?
- What happens on partial failure?

A generic destructive helper has a huge blast radius.

---

# 91. DOCUMENTATION

Public APIs should document non-obvious contracts.

Especially document:

- Null behavior
- Thread safety
- Ownership/disposal
- Side effects
- Exceptions
- Units
- Culture behavior
- Cancellation
- Platform requirements
- Destructive behavior
- Performance characteristics where surprising

Do not document obvious syntax just to increase documentation volume.

---

# 92. EXAMPLES

For nontrivial utilities, provide concise usage examples where useful.

Examples should demonstrate the intended safe path.

Do not make consumers reverse-engineer correct usage from tests or implementation.

---

# 93. DOCUMENTATION ACCURACY

Compare documentation against implementation.

Outdated documentation is worse than missing documentation.

Verify:

- Parameter meaning
- Defaults
- Return behavior
- Exceptions
- Thread safety
- Platform support

---

# 94. TEST COVERAGE

Reusable common code deserves strong tests because its blast radius is large.

Prioritize tests for:

- Core algorithms
- Edge cases
- Error behavior
- Public contracts
- Serialization
- Filesystem operations
- Async behavior
- Concurrency
- Security-sensitive functionality

Do not chase coverage percentage for its own sake.

---

# 95. PARAMETERIZED TESTING

Utilities often lend themselves extremely well to parameterized tests.

Use tables of:

Input
→ expected output

for:

- Parsing
- Formatting
- Validation
- Conversion
- Path handling
- Boundary conditions

This can provide high-value coverage efficiently.

---

# 96. PROPERTY-BASED TESTING

For suitable utility functions, consider properties such as:

Encode → Decode == original

Serialize → Deserialize == original

Normalize(Normalize(x)) == Normalize(x)

Sort output is ordered

Compression → Decompression == original

Use property-based testing where it provides real value.

---

# 97. FUZZ TESTING

Parsers, decoders, archive handlers, and structured-input utilities are good fuzz-testing candidates.

Malformed input should not:

- Crash the process
- Hang forever
- Allocate unbounded memory
- Corrupt unrelated state

---

# 98. THREAD-SAFETY TESTING

For types claiming thread safety, actually test concurrent use.

Run operations from multiple workers.

Repeat tests.

Look for:

- Exceptions
- Lost updates
- Duplicate values
- Corruption
- Deadlocks

Do not label something thread-safe because it happened to work once.

---

# 99. ASYNC TESTING

Test async utilities for:

- Success
- Failure
- Cancellation
- Timeout
- Concurrent calls
- Completion ordering
- Resource cleanup

Avoid tests based on arbitrary long sleeps.

---

# 100. CROSS-PLATFORM TESTING

If the library claims multiple-platform support, test on those platforms where infrastructure permits.

Do not claim portability solely because the code compiles.

Filesystem, path, process, encoding, permissions, and environment behavior can differ substantially.

---

# 101. CONSUMER SIMULATION

This is a critical part of the review.

Stop thinking like the library author.

Pretend you are a developer who:

- Did not write the library
- Has not read its source
- Does not know its history
- Only sees the public API and documentation

Create small representative consumer programs/tests.

Attempt common tasks using ONLY the public contract.

Ask:

- Can I find the functionality?
- Do I know which class to use?
- Are method names understandable?
- Do defaults behave sensibly?
- Do I know what I own/dispose?
- Do I understand failures?
- Can I misuse this accidentally?
- Do I need implementation knowledge?
- Does IntelliSense/API discovery guide me toward correct usage?

Treat confusion as API-design feedback.

---

# 102. PIT OF SUCCESS

The easiest obvious way to use the library should generally be the correct way.

Try to create a "pit of success."

Safe usage should be easy.

Dangerous usage should require deliberate action.

Correct resource ownership should be natural.

Correct async usage should be natural.

Correct encoding/culture behavior should be natural.

---

# 103. MISUSE TESTING

During consumer simulation, deliberately misuse APIs in plausible ways.

Examples:

- Pass null
- Pass empty
- Call twice
- Call concurrently
- Forget optional initialization
- Cancel
- Dispose early
- Use after dispose
- Pass relative path
- Pass nonexistent file
- Supply unusual Unicode

Observe whether failure is:

- Clear
- Safe
- Predictable

A reusable API should fail well.

---

# 104. FRESH-PROJECT CONSUMER TEST

Create or conceptually evaluate a minimal clean consumer.

Reference the library.

Perform representative operations.

Check:

- Dependency burden
- Setup burden
- Configuration requirements
- Platform requirements
- Namespace pollution
- Initialization
- Deployment

A utility should not require half an application framework just to call one helper.

---

# 105. PACKAGE / DISTRIBUTION REVIEW

If distributed as a package/library artifact, inspect:

- Package metadata
- Version
- Target frameworks
- Dependencies
- Documentation
- Symbols
- Source links where applicable
- License information where required
- Included/excluded files

Ensure consumers receive what they need and not development garbage.

---

# 106. BUILD WARNINGS

Build with appropriate warnings enabled.

Investigate warnings.

Do not blindly suppress warnings globally.

For each suppression, ensure the underlying condition is intentional and documented where necessary.

---

# 107. STATIC ANALYSIS

Use appropriate static analyzers available for the language/ecosystem.

Review findings for:

- Correctness
- Security
- Async
- Disposal
- Nullability
- Performance
- API design

Do not mechanically obey every analyzer recommendation.

Use engineering judgment.

---

# 108. NULLABILITY ANALYSIS

Where supported, enable/use nullable/static null analysis appropriately.

Fix meaningful warnings.

Do not silence warnings with null-forgiving operators merely to make the compiler quiet.

---

# 109. DEAD CODE

Find:

- Unused utilities
- Obsolete overloads
- Dead private methods
- Abandoned experiments
- Unused dependencies
- Legacy compatibility code no longer required

Remove when safe.

Public unused APIs may require deprecation rather than immediate deletion.

---

# 110. DUPLICATION

Look for duplicate utilities.

Examples:

Three ways to read a file

Four retry implementations

Multiple JSON helpers

Several almost-identical path functions

Determine whether they should:

- Merge
- Remain separate because semantics differ
- Share a lower-level primitive

Avoid both copy/paste duplication and forced mega-abstractions.

---

# 111. OVER-ABSTRACTION

Look for abstractions that make simple functionality harder to understand.

Examples:

Eight interfaces wrapping a one-line pure function

Factories creating stateless helpers

Dependency injection for arithmetic

Generic frameworks used by one utility

Simplify where the abstraction provides no meaningful value.

---

# 112. UNDER-ABSTRACTION

Also look for repeated complex patterns that clearly deserve a shared implementation.

Examples:

Safe atomic writes

Retry policy

Process invocation

Path validation

Serialization configuration

Centralize when doing so improves correctness and consistency.

---

# 113. COHESION

Each utility/class/module should have a coherent responsibility.

If a class contains:

String parsing
+ file deletion
+ HTTP requests
+ date formatting

split it.

A "utility library" does not mean every utility belongs in one class.

---

# 114. COUPLING

Review dependencies between utility modules.

Avoid unnecessary chains like:

String utility
→ file utility
→ network utility
→ UI framework

Core low-level utilities should generally remain low in the dependency graph.

---

# 115. DEPENDENCY DIRECTION

Identify foundational components.

Higher-level helpers may depend on lower-level primitives.

Lower-level primitives should not depend on specialized high-level modules.

Remove circular or inverted dependency relationships.

---

# 116. EXCEPTION TYPES

If custom exceptions exist, ask whether they provide real value.

Do not create custom exception types merely to rename standard failures.

Use them when callers genuinely need to distinguish a meaningful library-specific condition.

---

# 117. RESULT TYPES

If the library uses result/error objects instead of exceptions, review consistency.

Do not randomly mix:

- Exceptions
- Null
- Boolean
- Error codes
- Result objects

for identical classes of failure without rationale.

---

# 118. API SYMMETRY

Look for natural API pairs.

Examples:

Serialize / Deserialize

Encode / Decode

Register / Unregister

Start / Stop

Open / Close

Add / Remove

Ensure behavior and naming are coherent.

---

# 119. REVERSIBILITY

For conversion/transformation utilities claiming reversible behavior, test round trips.

Example:

A → B → A

should reproduce A where the contract says it should.

---

# 120. DATA LOSS

Pay special attention to utilities that transform or rewrite data.

Ask:

- Is information silently discarded?
- Is precision lost?
- Is encoding changed?
- Are line endings changed?
- Is metadata lost?
- Are unknown fields removed?

Make lossy behavior explicit.

---

# 121. ENCODING

Review text-file utilities.

Do not casually assume platform-default encoding.

Determine:

- UTF-8 behavior
- BOM behavior
- Invalid byte behavior
- Existing encoding preservation where relevant

Encoding decisions should be intentional.

---

# 122. LINE ENDINGS

If text utilities manipulate files, consider:

- CRLF
- LF
- Existing line-ending preservation
- Mixed input

Do not unexpectedly rewrite an entire file's line endings unless intended.

---

# 123. CASE SENSITIVITY

Review assumptions about:

- Files
- Paths
- Extensions
- Identifiers
- Keys

Behavior may differ across platforms.

Use explicit comparison semantics.

---

# 124. FILE EXTENSIONS

Do not use naive string operations for extension handling.

Test:

file.txt

FILE.TXT

file

file.

archive.tar.gz

.hiddenfile

Use platform APIs and explicit semantics.

---

# 125. URL / URI HANDLING

If URL utilities exist:

Use proper URI parsing.

Do not manipulate complex URLs solely with string concatenation.

Consider:

- Escaping
- Query strings
- Fragments
- Relative URIs
- Unicode
- Schemes

---

# 126. HTTP HELPERS

Be cautious with generic HTTP wrappers.

Do not build an abstraction that hides important HTTP semantics or makes advanced behavior impossible.

Review:

- Client lifetime
- Headers
- Cancellation
- Timeouts
- Streaming
- Response disposal
- Error handling
- Retries

Avoid socket exhaustion patterns.

---

# 127. RETRY UTILITIES

If retry helpers exist, inspect carefully.

Retries should consider:

- Maximum attempts
- Delay
- Backoff
- Cancellation
- Retryable vs non-retryable errors
- Idempotence

Do not blindly retry destructive/non-idempotent operations.

Avoid synchronized retry storms.

---

# 128. PROCESS OUTPUT

For process helpers:

Consume stdout and stderr safely.

Avoid deadlocks caused by full output buffers.

Support cancellation/timeouts where appropriate.

Preserve exit code and diagnostic output.

---

# 129. RESOURCE CLEANUP ON FAILURE

For every resource-creating helper, inspect exception paths.

If step 4 of 7 fails:

Are resources created in steps 1–3 released?

Success-path cleanup is not enough.

---

# 130. PARTIAL INITIALIZATION

Constructors/factories should not leave partially initialized objects exposed after failure.

Establish invariants before returning usable objects.

---

# 131. DISPOSAL

If a type is disposable:

- Multiple Dispose calls should be safe where idiomatic.
- Dispose should release owned resources.
- Use-after-dispose behavior should be predictable.
- Finalizers should exist only when actually required.
- Async disposal should be supported where genuinely necessary.

---

# 132. CANCELLATION OWNERSHIP

A library generally should not cancel caller-owned cancellation sources.

Understand ownership boundaries.

Pass tokens downward.

Do not confuse observing cancellation with owning cancellation.

---

# 133. CALLBACK EXCEPTIONS

Determine what happens if consumer-provided callbacks throw.

Possible policies include:

- Propagate
- Aggregate
- Log and continue

Choose intentionally.

Do not accidentally swallow consumer failures.

---

# 134. EVENT HANDLER EXCEPTIONS

Likewise determine whether event handler exceptions can corrupt library state.

Maintain invariants before invoking external code where possible.

---

# 135. USER CODE INVOCATION

Any time the library invokes:

- Callback
- Delegate
- Comparer
- Predicate
- Factory
- Plugin

assume that code may:

- Throw
- Re-enter
- Block
- Be slow

Design boundaries accordingly.

---

# 136. OBSERVABILITY

For complex utilities, determine how consumers diagnose failure.

Provide enough context through:

- Exceptions
- Result information
- Optional logging
- Diagnostic callbacks

Do not require attaching a debugger to understand routine failure.

---

# 137. NO SURPRISE CONSOLE OUTPUT

Generic libraries should not casually write to:

- stdout
- stderr
- debug console

unless explicitly part of the contract.

Let consuming applications control presentation.

---

# 138. NO SURPRISE UI

Generic core libraries should not display:

- Message boxes
- Dialogs
- Notifications

unless the component is explicitly a UI utility.

Core code should return/report failures to its caller.

---

# 139. NO SURPRISE PROCESS TERMINATION

A reusable library should essentially never:

- Exit the process
- Kill the application
- Force restart

unless that behavior is explicitly the purpose of a highly specialized API.

Return control to the caller.

---

# 140. NO SURPRISE GLOBAL EXCEPTION HANDLING

Do not install global exception handlers from generic library initialization unless that is explicitly the component's purpose.

The application owns process-level policy.

---

# 141. INITIALIZATION

Avoid hidden mandatory initialization.

If initialization is required:

- Make it obvious.
- Make ordering clear.
- Make repeated initialization behavior defined.
- Fail clearly when missing.

Prefer components that are usable immediately when practical.

---

# 142. STATIC CONSTRUCTORS

Review static constructors for:

- I/O
- Environment access
- Exceptions
- Expensive work
- Global mutation

A static initialization failure can make a type unusable for the entire process.

Keep static initialization simple.

---

# 143. PLATFORM TRIMMING / AOT

If relevant to target consumers, review compatibility with:

- Trimming
- Native AOT
- Reflection restrictions
- Single-file deployment

Do not optimize for these platforms if they are not intended targets.

But avoid accidentally claiming support that does not exist.

---

# 144. API EVOLUTION

For public APIs, think ahead.

Can likely future requirements be added without breaking callers?

Do not prematurely design for every hypothetical future.

But avoid obvious dead ends.

---

# 145. OPTIONS OBJECTS

Where options/configuration objects exist:

Review:

- Defaults
- Validation
- Mutability
- Reuse
- Thread safety
- Future extensibility

Avoid options objects containing dozens of unrelated flags.

---

# 146. ENUM EVOLUTION

Consumers may switch exhaustively over enums.

Adding values can have consequences.

Do not use enums where arbitrary extensibility is expected.

Do use them where a closed known set is appropriate.

---

# 147. PUBLIC CONSTANTS

Review public constants carefully.

Some languages inline constants into consuming binaries.

Determine whether a public constant might need to change later.

Use the ecosystem's appropriate alternative when necessary.

---

# 148. MAGIC VALUES

Remove unexplained magic numbers/strings where they represent actual concepts.

Do not create named constants for obvious literals that need no explanation.

---

# 149. COMMENTS

Comments should explain:

- Why
- Non-obvious constraints
- Platform quirks
- Security reasoning
- Performance reasoning
- Compatibility requirements

Do not narrate obvious code.

---

# 150. TEST THE PUBLIC API, NOT JUST INTERNALS

Ensure tests exercise the library the same way consumers do.

Internal implementation tests can supplement this.

They should not replace consumer-level contract tests.

---

# 151. BREAKING-CHANGE REVIEW

Before finalizing changes, explicitly identify:

- Removed APIs
- Renamed APIs
- Signature changes
- Behavior changes
- Exception changes
- Default changes
- Thread-safety changes
- Serialization changes
- Dependency changes

Do not allow accidental breaking changes to hide inside "cleanup."

---

# 152. MIGRATION PATH

For intentional breaking/deprecated changes, provide a clear migration path.

Example:

Old:
Foo.DoThing(...)

Replacement:
Bar.Process(...)

Explain behavioral differences where relevant.

---

# 153. REVIEW CONSUMING PROJECTS

If consuming projects are available, inspect representative usage.

Look for:

- Awkward call patterns
- Repeated wrappers
- Defensive code around library quirks
- Misunderstood APIs
- Common misuse
- Duplicate code consumers had to add

Consumers reveal library design problems that the library itself may hide.

---

# 154. WRAPPER SMELL

If every consumer wraps the same library API before using it, ask why.

Possible causes:

- Wrong defaults
- Poor abstraction
- Missing overload
- Bad naming
- Missing validation
- Missing common behavior

Consider moving genuinely universal behavior into the library.

---

# 155. ESCAPE HATCHES

High-level convenience APIs should not unnecessarily prevent advanced consumers from accessing lower-level functionality.

Provide escape hatches where appropriate.

Do not expose internals merely because someone might theoretically need them.

---

# 156. MINIMAL API PRINCIPLE

Prefer the smallest public API that cleanly supports required behavior.

Internal implementation can be richer.

Every unnecessary public member is another thing to support.

---

# 157. SECURITY-CRITICAL API REVIEW

For every security-sensitive public API, perform a separate adversarial thought exercise.

Ask:

"How could a careless consumer use this unsafely?"

Then:

"Can the API make the safe behavior easier?"

Examples:

- Safe path joining
- Process argument handling
- Secret redaction
- Archive extraction
- URL handling
- Cryptographic defaults

---

# 158. PERFORMANCE-CRITICAL API REVIEW

For APIs likely to process large/frequent data, ask:

- Does the signature force unnecessary copying?
- Can streaming be supported?
- Is allocation hidden?
- Can cancellation be supported?
- Does the API force loading everything into memory?

Do not complicate simple APIs without evidence.

---

# 159. THREAD-SAFETY DOCUMENTATION

If thread safety is relevant, document it explicitly.

Examples conceptually:

"Instances are safe for concurrent use."

or:

"Instances are not thread-safe. Callers must synchronize concurrent access."

Ambiguity is worse than either policy.

---

# 160. OWNERSHIP DOCUMENTATION

Likewise document important ownership contracts.

Examples:

"The caller retains ownership of the supplied stream."

"The returned object must be disposed by the caller."

Do not make consumers discover ownership through leaks.

---

# 161. FINAL CONSUMER ABUSE TEST

Create small programs/tests that intentionally behave like imperfect consumers.

Try:

- Null
- Empty
- Huge data
- Unicode
- Invalid path
- Repeated calls
- Concurrent calls
- Cancellation
- Dispose twice
- Use after dispose
- Dependency failure
- Invalid serialized data

Observe the quality of failure.

Reusable code should be resilient to reasonable misuse.

---

# 162. FINAL DEPENDENCY REVIEW

After changes, inspect the dependency graph again.

Ask:

- Did this review add unnecessary packages?
- Did a low-level utility gain a high-level dependency?
- Did portability decrease?
- Did package size increase substantially?
- Did transitive dependencies multiply?

Do not "improve" the library by making every consumer heavier.

---

# 163. FINAL PUBLIC API REVIEW

Read ONLY the public API surface without implementation.

Pretend the source code is unavailable.

Ask:

- Is it understandable?
- Is it coherent?
- Is naming consistent?
- Are dangerous operations obvious?
- Are async APIs recognizable?
- Is cancellation supported appropriately?
- Is ownership understandable?
- Are platform-specific APIs clearly identified?
- Are there obvious duplicates?
- Are there APIs I would regret supporting for ten years?

This is one of the most important passes.

---

# 164. FINAL CLASSIFICATION

Revisit the earlier:

KEEP
IMPROVE
MERGE
SPLIT
MOVE
DEPRECATE
DELETE

classification after completing the technical review.

For every major utility/component provide:

- Classification
- Short rationale
- Action taken or recommended

Do not force every category to be used.

Do not classify trivial private implementation details.

Focus on meaningful library components.

---

# 165. FINAL TEST PASS

Run all relevant tests.

Then test representative consumers.

Verify:

- Build
- Unit tests
- Integration tests
- Consumer simulation
- Platform tests where applicable
- Concurrency tests
- Async tests
- Security-sensitive tests
- Serialization round trips
- Filesystem tests

Ensure the review itself did not break consumers.

---

# 166. FINAL CLEAN-CONSUMER TEST

From a fresh/minimal consumer project:

1. Reference the library.

2. Use several representative utilities.

3. Build.

4. Run.

5. Exercise failure behavior.

6. Remove any accidental dependencies on the developer environment.

The consumer should not require mysterious setup.

---

# 167. FINAL "WOULD I WANT TO DEPEND ON THIS?" PASS

Approach the finished library as an external senior developer evaluating whether to adopt it.

Ask:

- Can I trust its contracts?
- Can I understand failures?
- Does it pull in unreasonable dependencies?
- Does it mutate global state?
- Is it portable as advertised?
- Is thread safety clear?
- Is async behavior correct?
- Are APIs easy to misuse?
- Is security taken seriously?
- Is documentation sufficient?
- Are tests convincing?
- Does it feel like a coherent library or a junk drawer?

Find anything that would make an experienced consumer hesitate.

---

# FINAL REPORT

After completing the review, provide a concise but meaningful report containing:

## Architecture

- Overall library structure
- Major organizational changes
- Responsibilities moved/split/merged

## Public API

- API design issues found
- Breaking changes
- Deprecations
- New safer replacements
- Naming/consistency improvements

## Correctness

- Bugs found
- Edge cases fixed
- Error handling improved

## Portability

- Platform assumptions found
- Platform-specific code isolated
- Cross-platform issues fixed
- Remaining platform restrictions

## Threading / Async

- Thread-safety issues found
- Race conditions fixed
- Async problems fixed
- Cancellation improvements
- Thread-safety contracts clarified

## Security

- Security-sensitive issues found
- Dangerous defaults corrected
- Path/process/archive/network/serialization issues fixed

## Dependencies

- Dependencies removed
- Dependencies added
- Transitive dependency concerns
- Dependency isolation performed

## Performance

- Meaningful performance problems found
- Algorithmic improvements
- Allocation/resource improvements

## Testing

- Tests added
- Edge cases covered
- Consumer tests added
- Concurrency tests added
- Security tests added
- Regression tests added

## Compatibility

- Breaking changes
- Migration requirements
- Deprecated APIs
- Consumer impact

## Classification

Provide the final meaningful component classification:

KEEP / IMPROVE / MERGE / SPLIT / MOVE / DEPRECATE / DELETE

with short rationale for each major component.

## Remaining Concerns

- Known limitations
- Intentional tradeoffs
- Areas requiring future work

Do not pad the report with trivial formatting changes.

---

# ACCEPTANCE CRITERIA

The review is complete when:

1. The entire public API has been examined as a long-term contract.

2. Major utilities have been classified as KEEP / IMPROVE / MERGE / SPLIT / MOVE / DEPRECATE / DELETE.

3. Unnecessary public surface has been identified.

4. Duplicate/overlapping utilities have been examined.

5. Application-specific code has been identified.

6. Platform assumptions have been identified and appropriately isolated or documented.

7. Thread-safety behavior is intentional.

8. Async behavior follows appropriate ecosystem conventions.

9. Cancellation propagates correctly where applicable.

10. Hidden UI/synchronization-context assumptions have been removed from generic code.

11. Resource ownership is clear.

12. Disposable resources are handled correctly.

13. Filesystem/path utilities handle realistic edge cases safely.

14. Security-sensitive utilities have received adversarial review.

15. Process/shell helpers are resistant to injection and misuse.

16. Serialization behavior is safe and version-conscious.

17. Dependencies have been justified individually.

18. Heavy/niche dependencies have been isolated where appropriate.

19. Global/process-wide side effects have been eliminated or explicitly justified.

20. Culture, Unicode, encoding, time, and comparison assumptions have been reviewed.

21. Performance-sensitive utilities have been examined at realistic scale.

22. Public APIs have meaningful behavioral tests.

23. Thread-safe claims have been tested where practical.

24. Async/cancellation behavior has been tested.

25. Consumer simulation has been performed without relying on implementation knowledge.

26. Representative misuse has been tested.

27. A fresh consumer can reference and use the library without mysterious setup.

28. Breaking changes and migrations have been explicitly identified.

29. Deprecated APIs have clear replacements where appropriate.

30. The final public API is coherent, discoverable, predictable, and difficult to misuse.

The final standard is:

> If I drop this library into ten completely different applications written by developers who have never seen its source code, will its behavior remain understandable, predictable, safe, and useful?

Then ask:

> If one subtle bug exists here, how many applications will inherit it?

Treat that blast radius seriously.

Then ask:

> Is this utility here because it is genuinely reusable, or because this project became the place where random code goes?

Be ruthless about that distinction.

Then:

> Could another developer correctly use this API from IntelliSense, its types, and its documentation without reading the implementation?

If not, improve the contract.

Finally:

> Am I comfortable supporting this public API for the next ten years?

If the answer is no, fix it now while the cost is still manageable.

A reusable utility library should be boring in the best possible way:

Predictable.

Focused.

Safe.

Well-tested.

Low-dependency.

Explicit about its contracts.

Hard to misuse.

And trustworthy enough that applications can build on it without inheriting surprises.