# Comprehensive C/C++ Code Differ Correctness, Completeness, and Semantic Accuracy Review Specification

## 1. Mission

Perform an exhaustive, adversarial, evidence-based review of the entire code differ implementation to identify every meaningful defect, weakness, ambiguity, or missed opportunity in how it detects, matches, classifies, represents, and reports differences between C and C++ source code.

The primary objective is to establish whether the tool **detects all changes within its declared comparison contract, reports them accurately, avoids false differences, and never silently discards or misattributes changes**.

Review the complete pipeline, including file discovery, input loading, normalization, preprocessing, parsing, symbol resolution, entity matching, difference computation, change classification, source mapping, result aggregation, output generation, and error handling.

Investigate both correctness and precision.

The tool must not merely produce plausible-looking differences. Its results must accurately reflect the inputs and its documented comparison semantics.

Do not assume that a clean or empty diff means the inputs are equivalent.

This review has two phases. **Phase 1 — audit:** do not modify code until the audit is complete; produce a comprehensive, prioritized report with exact code locations, concrete findings, minimal reproducers, root causes, recommended fixes, and regression tests. **Phase 2 — fix:** then fix the confirmed findings in priority order, with evidence for each (see the Phase 2 section near the end).

**Safety:** use small corpora by default, and ask the user before any very large compare or any compare against a network share. Point any results or output directory at a scratch folder, never inside a tree being compared. Run apply, merge, and other write operations only against scratch copies, never against real trees. Never delete or prune the user's saved results.

---

## 2. Establish the Comparison Contract

Before evaluating the implementation, determine exactly what the tool promises to compare.

### 2.1 Comparison granularity

Identify whether the tool supports:

- Individual files.
- Directories.
- Complete projects.
- Git revisions.
- Functions.
- Methods.
- Classes.
- Structures.
- Namespaces.
- Declarations.
- Definitions.
- Statements.
- Expressions.
- Tokens.
- AST nodes.
- Preprocessed source.
- Generated source.
- Build configurations.

Document which levels are supported and how they interact.

Do not assume unsupported capabilities are defects. Identify undocumented limitations separately.

### 2.2 Difference semantics

Determine whether the tool performs:

1. Textual comparison.
2. Whitespace-normalized comparison.
3. Token-based comparison.
4. Syntax-aware comparison.
5. AST structural comparison.
6. Symbol-aware comparison.
7. Semantic comparison.
8. Behavioral equivalence analysis.

These are not interchangeable.

For example, two expressions can have similar AST structures but different behavior. Two syntactically different expressions can have equivalent behavior under particular assumptions.

Do not describe structural equality as semantic equivalence unless the implementation actually establishes the required proof.

### 2.3 Define comparison guarantees

Determine whether the tool guarantees:

- Every input difference is represented.
- Every reported difference corresponds to actual input evidence.
- Source locations are accurate.
- Results are deterministic.
- Renames are recognized.
- Moves are recognized.
- Formatting-only changes are ignored or reported.
- Macro changes are tracked.
- Build configurations are considered.
- Unsupported constructs are diagnosed.
- Partial analysis is explicitly reported.

Document ambiguities and contradictions.

### 2.4 Establish change classifications

Determine which categories the tool supports:

- Added.
- Removed.
- Modified.
- Unchanged.
- Renamed.
- Moved.
- Reordered.
- Signature changed.
- Body changed.
- Type changed.
- Initializer changed.
- Attribute changed.
- Macro changed.
- Conditional compilation changed.
- Dependency changed.
- Unknown.
- Analysis failed.

Investigate whether distinct categories are incorrectly merged.

---

## 3. Fundamental Correctness Properties

### 3.1 No missed differences

Find cases where meaningful changes disappear from the output.

Examples:

- Modified expressions incorrectly classified as unchanged.
- Deleted functions not reported.
- Added declarations ignored.
- Changed overloads matched incorrectly.
- Macro modifications hidden by normalization.
- Changes in unparsed files silently omitted.
- Duplicate names causing one change to overwrite another.

Treat silent omission of an in-scope change as a correctness-critical defect.

### 3.2 No fabricated differences

Find cases where unchanged code is incorrectly reported as changed.

Examples:

- Whitespace differences incorrectly affecting AST identity.
- Source line shifts interpreted as code changes.
- File ordering affecting symbol matching.
- Repeated declarations producing duplicate changes.
- Unstable hash values.
- Nondeterministic traversal order.

Determine whether differences are real under the declared comparison contract.

### 3.3 Accurate change attribution

Determine whether a reported change is associated with the correct:

- File.
- Translation unit.
- Namespace.
- Class.
- Function.
- Overload.
- Template specialization.
- Declaration.
- Definition.
- Source range.

A real change attributed to the wrong symbol is still a defect.

### 3.4 Accurate old/new direction

Verify that additions and deletions are never reversed.

Check whether old and new source locations are consistently associated with the correct revision.

### 3.5 Complete result aggregation

Ensure that differences discovered in one stage are not lost during later aggregation, deduplication, filtering, or output generation.

### 3.6 No silent success on incomplete analysis

If files cannot be read, parsed, matched, or compared, the tool must not report a complete clean result.

Incomplete analysis must remain distinguishable from verified equality.

---

## 4. End-to-End Pipeline Audit

Map every stage:

1. Input selection.
2. File discovery.
3. Path normalization.
4. File loading.
5. Encoding detection.
6. Text normalization.
7. Preprocessing.
8. Parsing.
9. AST extraction.
10. Symbol identification.
11. Entity matching.
12. Rename and move detection.
13. Structural comparison.
14. Difference classification.
15. Source-range mapping.
16. Difference aggregation.
17. Filtering.
18. Output generation.
19. Diagnostics.
20. Caching and incremental comparison.

For each stage, document:

- Inputs.
- Outputs.
- Invariants.
- Assumptions.
- Error handling.
- Information discarded.
- Potential false negatives.
- Potential false positives.
- Failure propagation.
- Relevant tests.

Pay particular attention to information lost between stages.

A correct AST comparison cannot recover a source file silently omitted during discovery.

---

## 5. File Discovery and Input Correctness

### 5.1 Complete file enumeration

Test:

- Added files.
- Removed files.
- Modified files.
- Renamed files.
- Moved files.
- Nested directories.
- Empty directories.
- Empty files.
- Files with unusual extensions.
- Files without extensions.
- Case-sensitive and case-insensitive paths.

### 5.2 Path identity

Inspect:

- Relative paths.
- Absolute paths.
- Canonicalization.
- Symbolic links.
- Junctions.
- Path separators.
- Case folding.
- Unicode filenames.
- Duplicate path representations.

Determine whether two distinct files can be incorrectly merged or one file incorrectly treated as two.

### 5.3 File pairing

Investigate how old and new files are matched.

Test:

- Same path, modified contents.
- Renamed files.
- Moved files.
- Simultaneous rename and modification.
- Identical files at multiple paths.
- Files split into several files.
- Several files merged into one.
- Swapped filenames.

Do not assume file identity is equivalent to path identity.

### 5.4 Input stability

Determine whether files changing during comparison can produce inconsistent results.

Evaluate whether the tool uses snapshots or detects input mutation.

### 5.5 Encoding and line endings

Test:

- UTF-8.
- UTF-8 BOM.
- UTF-16 where supported.
- CRLF.
- LF.
- Mixed line endings.
- Missing final newline.
- Invalid byte sequences.
- Embedded null bytes.

Determine whether normalization hides meaningful changes or fabricates differences.

---

## 6. Textual Difference Correctness

### 6.1 Basic edit operations

Test:

- Single-character insertion.
- Single-character deletion.
- Single-character replacement.
- Whole-line insertion.
- Whole-line deletion.
- Whole-line replacement.
- Multi-line edits.
- Edits at file beginning.
- Edits at file end.
- Empty-to-nonempty changes.
- Nonempty-to-empty changes.

### 6.2 Repeated text

Construct adversarial examples containing:

- Identical lines.
- Repeated blocks.
- Repeated braces.
- Repeated declarations.
- Similar functions.
- Large runs of blank lines.
- Repeated comments.

Determine whether the differ selects valid and stable alignments.

### 6.3 Diff algorithm correctness

Inspect the actual algorithm.

If using Myers, LCS, patience diff, histogram diff, or another approach, evaluate:

- Edit script validity.
- Minimality guarantees.
- Tie-breaking.
- Worst-case complexity.
- Memory requirements.
- Determinism.
- Pathological inputs.

Do not assume every diff algorithm guarantees a globally minimal edit script.

### 6.4 Edit script reconstruction

For a textual diff, verify that applying the reported edit script to the old input reconstructs the new input exactly, except for explicitly documented normalization.

This is a fundamental correctness invariant.

### 6.5 Hunk boundaries

Test:

- Adjacent edits.
- Distant edits.
- Overlapping context.
- Large insertions.
- Large deletions.
- Repeated surrounding lines.
- Edits near beginning and end of files.

Ensure no changed lines are omitted or duplicated.

### 6.6 Normalization

Inspect whitespace, comment, and formatting normalization.

Verify that normalization does not accidentally erase meaningful differences.

Examples:

- Whitespace inside string literals.
- Whitespace inside raw string literals.
- Whitespace affecting preprocessing.
- Backslash-newline continuations.
- Whitespace inside macro definitions.
- Comments that affect preprocessing token separation.

---

## 7. C/C++ Parsing Correctness

### 7.1 AST completeness

Determine whether every supported source construct is represented and compared.

Inspect AST visitors, matchers, and traversal logic.

Look for node types silently skipped.

### 7.2 Declarations and definitions

Test:

- Forward declarations.
- Function definitions.
- Variable definitions.
- Multiple declarations.
- Inline definitions.
- Extern declarations.
- Static declarations.
- Tentative definitions.
- Typedefs.
- Type aliases.

### 7.3 Statements

Test changes to:

- `if`.
- `else`.
- `switch`.
- `case`.
- Loops.
- `break`.
- `continue`.
- `return`.
- `goto`.
- Labels.
- Exception handling.
- Coroutine statements where supported.

### 7.4 Expressions

Test:

- Arithmetic.
- Comparisons.
- Logical expressions.
- Bitwise operations.
- Assignments.
- Conditional expressions.
- Casts.
- Function calls.
- Member access.
- Array indexing.
- Pointer operations.
- Lambda expressions.
- Initializer lists.

### 7.5 Literals

Test changes to:

- Integer literals.
- Floating-point literals.
- Character literals.
- String literals.
- Raw string literals.
- Boolean literals.
- Null pointer literals.
- User-defined literals.

Ensure literal spelling and semantic value are handled according to the comparison contract.

### 7.6 Implicit AST nodes

Investigate whether implicit casts, constructors, destructors, and compiler-generated nodes cause false differences or conceal real changes.

### 7.7 Unsupported syntax

Determine whether unsupported constructs produce explicit diagnostics rather than false equality.

---

## 8. Symbol Identity and Entity Matching

### 8.1 Declaration identity

Inspect use of:

- Canonical declarations.
- Redeclaration chains.
- Qualified names.
- Mangled names.
- USRs.
- Source locations.
- Translation-unit identity.
- Template specialization identity.

Determine whether the tool uses reliable semantic identities.

### 8.2 Same-name collisions

Test:

- Identical static functions in different files.
- Anonymous namespaces.
- Shadowed variables.
- Nested namespaces.
- Overloaded functions.
- Local classes.
- Template specializations.
- Identical methods in unrelated classes.

Ensure unrelated entities are not matched.

### 8.3 Overloads

Verify exact matching of overloads with different:

- Parameter types.
- Qualifiers.
- Reference qualifiers.
- Template arguments.
- Constraints.
- Calling conventions.

### 8.4 Entity renaming

Determine whether a rename is classified correctly rather than as an unrelated deletion and addition, when rename detection is supported.

### 8.5 Entity movement

Test movement:

- Within a file.
- Between namespaces.
- Between classes.
- Between files.
- Between translation units.

Determine whether movement is distinguished from modification.

### 8.6 Ambiguous matching

Construct cases with several plausible matching candidates.

Determine whether the tool:

- Selects a valid match.
- Reports ambiguity.
- Uses deterministic tie-breaking.
- Avoids hiding unmatched changes.

### 8.7 One-to-many and many-to-one changes

Test function splitting and merging.

Do not assume all changes can be represented by one-to-one entity matches.

---

## 9. C++ Templates and Generic Code

### 9.1 Function templates

Test changes to:

- Template parameters.
- Defaults.
- Constraints.
- Return types.
- Function bodies.
- Explicit specializations.
- Explicit instantiations.

### 9.2 Class templates

Test:

- Primary templates.
- Partial specializations.
- Explicit specializations.
- Member templates.
- Static members.
- Nested templates.

### 9.3 Dependent expressions

Determine whether changes inside dependent expressions are detected before or after instantiation as appropriate.

### 9.4 SFINAE and concepts

Test:

- `std::enable_if`.
- Detection idioms.
- `requires` expressions.
- Concepts.
- Constraint changes.
- Overload viability changes.

### 9.5 Compile-time constructs

Test:

- `constexpr`.
- `consteval`.
- `constinit`.
- `static_assert`.
- Type traits.
- `decltype`.
- `noexcept`.

### 9.6 Template matching

Ensure template declarations are not incorrectly matched to unrelated specializations or instantiations.

### 9.7 Instantiation-dependent differences

Investigate whether the tool can detect differences that emerge only under particular template instantiations.

Document limitations explicitly.

---

## 10. C++ Classes and Object Model

### 10.1 Class declarations

Test changes to:

- Base classes.
- Access specifiers.
- Member declarations.
- Member ordering.
- Virtual functions.
- Constructors.
- Destructors.
- Friend declarations.
- Nested types.
- Attributes.

### 10.2 Inheritance

Test:

- Single inheritance.
- Multiple inheritance.
- Virtual inheritance.
- Diamond inheritance.
- Changed base-class access.
- Changed base-class order.

### 10.3 Virtual dispatch

Test:

- Added virtual functions.
- Removed virtual functions.
- Changed overrides.
- Changed `final`.
- Changed `override`.
- Changed pure virtual declarations.
- Changed virtual destructors.

### 10.4 Object layout

Determine whether the tool detects changes affecting:

- Size.
- Alignment.
- Field offsets.
- Base-class layout.
- Bitfields.
- Packing.
- ABI compatibility.

If ABI analysis is unsupported, ensure the tool does not imply that structural equality guarantees ABI compatibility.

### 10.5 Special member functions

Test changes to:

- Default constructors.
- Copy constructors.
- Move constructors.
- Assignment operators.
- Destructors.
- Deleted functions.
- Defaulted functions.

### 10.6 Operator overloading

Verify changes to overloaded operators are correctly identified and attributed.

---

## 11. Preprocessor and Macro Differences

### 11.1 Macro definitions

Test:

- Added macros.
- Removed macros.
- Modified macro bodies.
- Changed macro parameters.
- Variadic macros.
- Token pasting.
- Stringification.
- Nested expansion.

### 11.2 Macro invocation changes

Determine whether changes at invocation sites are detected.

### 11.3 Macro expansion changes

Investigate cases where unchanged source expands differently because a macro definition changed.

### 11.4 Conditional compilation

Test:

- `#if`.
- `#ifdef`.
- `#ifndef`.
- `#elif`.
- `#else`.
- `#endif`.

Determine whether changes in inactive branches are reported or intentionally excluded.

### 11.5 Configuration-specific differences

Compare behavior under different macro definitions and compiler flags.

### 11.6 Macro source mapping

Determine whether changes are attributed to:

- Macro definition.
- Macro invocation.
- Expanded AST node.
- Original source location.

Avoid misleading source locations.

### 11.7 Include changes

Test:

- Added includes.
- Removed includes.
- Reordered includes.
- Changed include targets.
- Conditional includes.
- Include path resolution changes.

### 11.8 Build-configuration dependencies

Identify cases where the same source text produces different behavior under changed compiler flags.

---

## 12. Semantic Difference Classification

### 12.1 Separate syntax from semantics

Determine whether the tool distinguishes:

- Text changed.
- Syntax changed.
- Symbol binding changed.
- Type changed.
- Control flow changed.
- Data flow changed.
- Side effects changed.
- ABI changed.
- Behavior potentially changed.
- Proven equivalent under stated assumptions.

Do not classify a change as behaviorally equivalent merely because its AST shape is similar.

### 12.2 Variable renaming

Test local variable renames that do not alter binding.

Distinguish these from renames that change lookup or shadowing.

### 12.3 Expression equivalence

Test transformations such as:

`a + 0` versus `a`

Do not assume equivalence without accounting for types, overloads, floating-point behavior, volatile accesses, and side effects.

### 12.4 Reordered operations

Test statements reordered without textual additions or deletions.

Determine whether the tool detects potential changes in execution order.

### 12.5 Control-flow changes

Test:

- Changed branch conditions.
- Added early returns.
- Changed loop bounds.
- Changed exception paths.
- Changed `break` or `continue`.
- Changed switch fallthrough.
- Changed short-circuit evaluation.

### 12.6 Side-effect changes

Test changes involving:

- Volatile accesses.
- Atomic operations.
- Global writes.
- Function calls.
- I/O.
- Allocation.
- Deallocation.
- Locking.
- Exceptions.

### 12.7 Type changes

Test:

- Signedness.
- Integer width.
- Pointer qualifiers.
- Reference types.
- Constness.
- Volatile qualification.
- Calling conventions.
- Alignment.
- Template arguments.

### 12.8 Symbol-binding changes

Construct tests where source text remains identical but resolves to a different declaration because surrounding code changed.

This is a particularly important adversarial category.

### 12.9 Semantic uncertainty

If equivalence cannot be established, report uncertainty rather than claiming no semantic change.

---

## 13. Change Propagation and Impact Analysis

If supported, investigate whether the tool identifies code affected indirectly by changes.

### 13.1 Direct changes

Distinguish directly modified source from unchanged source affected by those modifications.

### 13.2 Caller impact

Determine whether changes to a function can affect callers.

### 13.3 Type impact

Investigate changes to shared types, layouts, aliases, and templates.

### 13.4 Macro impact

Determine whether one macro modification affects many unchanged invocation sites.

### 13.5 Global state impact

Investigate changes to global initialization and shared state.

### 13.6 Header impact

Determine whether header changes affect multiple translation units.

### 13.7 Impact classification

Do not conflate:

- Directly changed.
- Potentially affected.
- Definitely affected.
- Proven unaffected.

If impact analysis is unsupported, document it as a separate possible enhancement rather than a defect in ordinary diff functionality.

---

## 14. Source Locations and Mapping

### 14.1 Line and column accuracy

Verify every reported location against the original inputs.

### 14.2 Old/new source ranges

Ensure source ranges are associated with the correct revision.

### 14.3 Insertions and deletions

Test changes that have no corresponding source range on one side.

### 14.4 Macro locations

Distinguish spelling locations from expansion locations.

### 14.5 Multi-line constructs

Test functions, macros, templates, and declarations spanning many lines.

### 14.6 Moved code

Determine whether moved code retains accurate original and destination locations.

### 14.7 Overlapping changes

Ensure nested changes do not create contradictory or misleading ranges.

### 14.8 Source-map validation

Verify that every reported location resolves to the intended text.

---

## 15. Difference Aggregation and Deduplication

### 15.1 Duplicate reports

Identify cases where one source change generates multiple redundant findings.

### 15.2 Lost findings

Determine whether deduplication incorrectly merges distinct changes.

### 15.3 Nested differences

Investigate reporting at multiple levels.

Example:

- Function modified.
- Statement modified.
- Expression modified.

Determine whether the output preserves useful detail without double-counting changes.

### 15.4 Cross-translation-unit duplication

A header change may appear in many translation units.

Determine whether it is reported once with multiple affected contexts or repeatedly as unrelated changes.

### 15.5 Stable ordering

Ensure output ordering is deterministic.

### 15.6 Summary consistency

Verify that summary counts agree with detailed findings.

---

## 16. Output Integrity

### 16.1 Human-readable output

Determine whether the report accurately communicates:

- What changed.
- Where it changed.
- How it changed.
- Whether matching was uncertain.
- Whether analysis was incomplete.

### 16.2 Machine-readable output

If JSON, XML, or another structured format is supported, validate:

- Schema correctness.
- Stable identifiers.
- Escaping.
- Encoding.
- Old/new direction.
- Source locations.
- Change categories.
- Nested relationships.
- Completeness status.

### 16.3 Output filtering

Test whether filters silently remove changes that should remain visible under the selected options.

### 16.4 Summary accuracy

Verify counts for:

- Added files.
- Removed files.
- Modified files.
- Added symbols.
- Removed symbols.
- Modified symbols.
- Renamed symbols.
- Moved symbols.
- Unknown or failed comparisons.

### 16.5 Empty results

An empty result must mean that no in-scope differences were found under a completed comparison, not that analysis failed.

---

## 17. Determinism and Stability

Run identical comparisons repeatedly.

Vary:

- File enumeration order.
- Translation-unit order.
- Thread count.
- Hash-map iteration order.
- Working directory.
- Warm and cold caches.
- Incremental versus clean analysis.
- Absolute versus relative paths.
- Equivalent compiler command ordering.

Investigate changes in:

- Entity matching.
- Difference counts.
- Change classifications.
- Source locations.
- Output ordering.
- Generated identifiers.

Equivalent inputs and configuration should produce stable results.

---

## 18. Incremental Comparison and Cache Correctness

If caching or incremental analysis is supported, inspect:

- File content changes.
- Header changes.
- Macro changes.
- Compiler argument changes.
- Include path changes.
- Language standard changes.
- Target architecture changes.
- Deleted files.
- Renamed files.
- Symbol identity changes.
- Template instantiation changes.

Compare incremental results against clean full comparisons.

Stale cached analysis must not cause missed differences.

---

## 19. Adversarial Test Corpus

Construct a comprehensive corpus of small C/C++ projects with known expected differences.

### 19.1 Atomic change tests

Generate one-change programs for every supported construct.

Examples:

- Change one literal.
- Change one operator.
- Change one type.
- Change one function call.
- Add one statement.
- Remove one statement.
- Rename one variable.
- Change one initializer.
- Change one macro.
- Change one overload.
- Change one template argument.

### 19.2 Similar-symbol tests

Generate projects containing many nearly identical declarations and definitions.

Determine whether the differ matches the correct entities.

### 19.3 Rename and move tests

Test renames, moves, splits, merges, and combinations of those changes with body modifications.

### 19.4 Repeated-code tests

Generate files containing many identical or near-identical functions.

Investigate ambiguous matching and alignment.

### 19.5 Cross-file tests

Create changes involving:

- Headers.
- Source files.
- Shared declarations.
- Inline functions.
- Templates.
- External linkage.
- Anonymous namespaces.

### 19.6 Macro tests

Generate macro-heavy source with known textual and expanded differences.

### 19.7 Configuration tests

Run the same source pairs under different compiler flags and macro definitions.

### 19.8 Large synthetic projects

Generate thousands of files, declarations, and controlled changes.

Measure:

- Missed differences.
- False differences.
- Incorrect matches.
- Source-location errors.
- Duplicate reports.
- Runtime.
- Peak memory.
- Determinism.

### 19.9 Malformed input

Test:

- Syntax errors.
- Missing headers.
- Invalid compiler commands.
- Unsupported extensions.
- Corrupted files.
- Incomplete translation units.

Verify explicit incomplete-analysis reporting.

### 19.10 Combined-feature tests

Construct adversarial combinations.

Examples:

- Rename an overloaded template function.
- Move a function between namespaces while changing its body.
- Modify a macro that generates virtual methods.
- Change a global initializer inside conditional compilation.
- Change a typedef that affects overload resolution.
- Modify a header included by many translation units.
- Rename two identical functions simultaneously.
- Change a template constraint while preserving its body.
- Modify a symbol referenced only through inline assembly.
- Reorder declarations while changing one initializer.

---

## 20. Metamorphic Testing

Use transformations with predictable effects on comparison results.

### 20.1 Identity

Comparing an input with itself must produce no differences under every supported mode.

### 20.2 Reversal

Comparing B against A should correspond to reversing the changes from A against B.

Added and removed classifications must invert appropriately.

Rename and move relationships should reverse consistently.

### 20.3 Irrelevant addition

Adding unrelated code should not alter matching or classifications for unchanged entities.

### 20.4 Formatting transformation

Applying a formatting-only transformation should produce results consistent with the configured normalization policy.

### 20.5 Consistent renaming

Consistently renaming a symbol should produce predictable rename or modification results.

### 20.6 File-order permutation

Changing enumeration order must not change the semantic diff.

### 20.7 Composition

For a sequence A → B → C, verify that reported changes are internally consistent with the source states.

Do not assume edit scripts are simply additive because later edits may undo earlier changes.

### 20.8 Mutation sensitivity

Introduce a deliberate one-token change into otherwise identical inputs.

Verify that the tool detects it unless the comparison contract explicitly excludes that category.

---

## 21. Differential Testing Against Reference Tools

Where practical, compare results with established tools.

Potential references include:

- Git diff.
- GNU diff.
- Clang AST dumps.
- Clang tooling.
- Compiler diagnostics.
- Symbol tables.
- Build outputs.

Use reference tools according to their actual guarantees.

A textual differ cannot establish semantic equivalence.

A compiler cannot prove that two successfully compiled programs behave identically.

Disagreements should trigger investigation rather than automatic acceptance of either result.

---

## 22. Ground Truth and Test Oracles

### 22.1 Exact textual oracle

For textual mode, verify that applying the edit script reconstructs the target input.

### 22.2 Known-change oracle

Generate input pairs from controlled mutations.

Record the exact intended change.

### 22.3 Symbol identity oracle

Use compiler semantic information to verify entity matching where available.

### 22.4 Source-range oracle

Verify reported ranges against actual input substrings.

### 22.5 Semantic test oracle

Where the tool claims semantic properties, use compilation, execution, or stronger analysis as appropriate.

### 22.6 Completeness oracle

Verify that every discovered input file receives a valid comparison outcome.

### 22.7 Failure oracle

Intentionally cause analysis failures and verify that the tool reports incomplete results rather than equality.

---

## 23. Error Handling and Failure Propagation

Investigate:

- Unreadable files.
- Missing directories.
- Missing headers.
- Invalid compilation databases.
- Compiler failures.
- AST construction failures.
- Unsupported syntax.
- Ambiguous symbol matches.
- Invalid encodings.
- Resource exhaustion.
- Interrupted comparisons.
- Partial output generation.

For every failure, determine whether:

1. It is detected.
2. It is reported.
3. Its scope is identified.
4. Affected results are marked incomplete.
5. Unaffected results remain valid.
6. The tool avoids false claims of equality.

Silent omission is unacceptable.

---

## 24. Performance and Scalability

Although correctness is the primary objective, investigate inefficient comparison behavior.

Measure:

- File discovery time.
- Input loading time.
- Parsing time.
- AST construction time.
- Entity matching time.
- Difference computation time.
- Aggregation time.
- Output generation time.
- Peak RAM.
- CPU time.
- Incremental comparison time.

Identify:

- Quadratic matching.
- Repeated parsing.
- Duplicate AST traversal.
- Excessive string copying.
- Repeated hashing.
- Inefficient source mapping.
- Unbounded candidate matching.
- Excessive intermediate representations.
- Unnecessary comparison of unchanged files.

Do not recommend performance optimizations that reduce comparison completeness or accuracy.

---

## 25. Security and Input Robustness

Treat input repositories and build metadata as potentially untrusted.

Investigate:

- Path traversal.
- Symlink loops.
- Unexpected file writes.
- Unsafe temporary files.
- Command injection.
- Malicious compiler arguments.
- Extremely large files.
- Deeply nested syntax.
- Pathological diff inputs.
- Malformed encodings.
- Resource exhaustion.
- Parser crashes.
- Infinite loops.
- Unsafe output serialization.

Ensure comparison does not execute target application code unless explicitly authorized.

---

## 26. Required Review Procedure

All of the steps below belong to Phase 1 (audit). They are numbered as steps so they are not confused with the audit and fix phases; do not change code while performing them.

### Step 1: Contract and architecture

1. Document supported comparison modes.
2. Document difference semantics.
3. Identify supported C/C++ standards.
4. Map the complete pipeline.
5. Identify entity matching algorithms.
6. Identify normalization rules.
7. Identify failure-handling behavior.
8. Inventory existing tests.

### Step 2: Input and textual correctness

Review:

- File discovery.
- File pairing.
- Encoding.
- Normalization.
- Edit script generation.
- Hunk reconstruction.
- Source locations.

### Step 3: Parsing and symbol identity

Review:

- AST traversal.
- Declaration identity.
- Overloads.
- Templates.
- Namespaces.
- Translation-unit boundaries.
- Macro handling.

### Step 4: Matching and classification

Review:

- Added and removed entities.
- Modified entities.
- Renames.
- Moves.
- Ambiguous matches.
- Structural differences.
- Semantic claims.

### Step 5: Aggregation and output

Review:

- Deduplication.
- Nested differences.
- Summary counts.
- Source mapping.
- Machine-readable output.
- Incomplete-analysis reporting.

### Step 6: Adversarial testing

Construct minimal reproducers for suspected defects and missing language-feature coverage.

### Step 7: Cross-component investigation

Trace errors across multiple pipeline stages.

Determine root causes rather than fixing only symptoms.

### Step 8: Completeness pass

Revisit every major category and search deliberately for missed change-detection failures.

Maintain a persistent review ledger.

---

## 27. Finding Classification

#### Critical

- Real changes silently omitted.
- Different code incorrectly classified as equivalent under the declared contract.
- Analysis failure reported as a clean diff.
- Changes attributed to incorrect symbols in ways that conceal actual changes.
- Widespread incorrect entity matching.
- Corrupted or contradictory results.

#### High

- Significant false differences.
- Incorrect rename or move detection.
- Missing major C/C++ construct coverage.
- Incorrect source ranges.
- Macro or template comparison failures.
- Cross-translation-unit matching defects.
- Lost changes during aggregation.

#### Medium

- Ambiguous matching without adequate diagnostics.
- Duplicate reports.
- Inconsistent classifications.
- Limited normalization defects.
- Incremental comparison inconsistencies.
- Determinism problems.

#### Low

- Cosmetic output problems.
- Minor redundant differences.
- Limited formatting inconsistencies.
- Small performance inefficiencies.
- Noncritical diagnostic weaknesses.

Severity must reflect the actual comparison contract and impact.

---

## 28. Required Finding Format

For every finding, provide:

**Finding ID:** Unique identifier.

**Title:** Concise description.

**Severity:** Critical / High / Medium / Low.

**Confidence:** High / Medium / Low.

**Category:** Input, parsing, matching, diff algorithm, classification, source mapping, aggregation, output, or other.

**Location:** Exact file, function, and line numbers.

**Current behavior:** What the differ does.

**Expected behavior:** What the declared comparison contract requires.

**Root cause:** Why the defect occurs.

**Evidence:** Source code, test output, traces, or profiling data.

**Minimal reproducer:** Smallest practical old/new source pair.

**Expected diff:** Correct change representation.

**Actual diff:** Incorrect or incomplete result.

**Impact:** Missed change, false change, incorrect matching, invalid location, or other consequence.

**Recommended fix:** Concrete implementation strategy.

**Correctness risks:** Potential side effects of the proposed fix.

**Regression test:** A test that should permanently detect recurrence.

**Dependencies:** Related findings or prerequisite improvements.

Clearly distinguish confirmed defects from unverified hypotheses.

---

## 29. Required Final Report

### A. Executive Summary

Include:

- Overall assessment of diff correctness.
- Largest risks of missed changes.
- Largest sources of false differences.
- Entity matching weaknesses.
- Semantic analysis limitations.
- Confidence in conclusions.
- Areas not fully reviewed.

### B. Architecture Overview

Describe the complete comparison pipeline and major algorithms.

### C. Ranked Findings

| Rank | Finding | Severity | False-Negative Risk | False-Positive Risk | Confidence | Effort |
|---|---|---|---|---|---|---|

Prioritize missed changes and false equivalence before cosmetic precision improvements.

### D. Detailed Findings

Include every meaningful finding using Section 28.

### E. Missed-Change Risks

Group all defects capable of hiding real changes.

### F. False-Difference Problems

Group cases where unchanged or equivalent constructs are incorrectly reported as changed.

### G. Entity Matching Improvements

Identify weaknesses in symbol identity, rename detection, move detection, and ambiguous matching.

### H. C/C++ Language Coverage

Document parsing and comparison gaps involving macros, templates, overloads, classes, and compiler extensions.

### I. Semantic Accuracy

Identify unsupported semantic claims, incorrect equivalence assumptions, and opportunities for more precise classification.

### J. Source Mapping and Output Integrity

Document location errors, duplicate reports, aggregation defects, and serialization problems.

### K. Adversarial Regression Corpus

List generated tests, executed tests, expected outcomes, and uncovered language features.

### L. Architectural Recommendations

Identify major improvements to correctness, completeness, precision, and maintainability.

### M. Coverage Report

List all reviewed modules, files, comparison modes, and language-feature categories.

### N. Remaining Unknowns

Identify questions requiring additional testing, runtime analysis, compiler-specific validation, or production workloads.

### O. Fixes Applied

Written in Phase 2 (Section 32). For each finding ID:

- The fix that was applied.
- The regression test that failed before the fix and passes after it.
- The test-suite and ground-truth / oracle results after the fix.

Also list every deferred finding with the reason, and anything discovered while fixing.

---

## 30. Deep-Review Questions

After the initial review, explicitly investigate:

- Can a one-character semantic change go undetected?
- Can a function-body modification be incorrectly classified as unchanged?
- Can two unrelated same-named functions be matched?
- Can overloaded functions be confused?
- Can a function rename hide a simultaneous body change?
- Can moving a function cause its modification to disappear?
- Can a deleted file be silently ignored?
- Can an added file be missed?
- Can a header change be incorrectly attributed?
- Can a macro definition change without a corresponding reported difference?
- Can unchanged source expand differently under changed compiler flags?
- Can template changes be missed because no instantiation was analyzed?
- Can changes in inactive preprocessor branches be silently omitted?
- Can symbol-binding changes occur without corresponding source-text changes at the call site?
- Can class-layout changes be missed?
- Can virtual dispatch relationships change without being reported?
- Can changes to global initialization be missed?
- Can source line shifts create false differences?
- Can formatting changes conceal real token changes?
- Can repeated code confuse matching?
- Can one source change generate duplicate findings?
- Can deduplication remove legitimate findings?
- Can ambiguous matching produce confident but incorrect results?
- Can parsing failures produce empty diffs?
- Can stale caches hide changes?
- Can file ordering affect results?
- Can parallel execution affect matching?
- Can reversing old and new produce inconsistent classifications?
- Can textual edit scripts fail to reconstruct the target?
- Can source ranges point to the wrong revision?
- Can summary counts disagree with detailed results?
- Can a reported semantic equivalence be invalidated by side effects, overloads, floating-point behavior, or concurrency?
- What C/C++ constructs are absent from the current test corpus?
- Which implementation assumptions are not documented?
- What changes would a malicious or adversarial test author try to hide from the differ?

Investigate these questions using source inspection and targeted tests wherever practical.

---

## 31. Completion Criteria

The review is complete only when:

1. The comparison contract has been documented.
2. The complete pipeline has been reviewed.
3. File discovery and pairing have been checked.
4. Encoding and normalization have been examined.
5. Textual diff correctness has been evaluated.
6. AST traversal has been reviewed where applicable.
7. Symbol identity has been investigated.
8. Overloads and templates have been tested where supported.
9. Preprocessor behavior has been examined.
10. Entity matching has been reviewed.
11. Rename and move behavior has been tested where supported.
12. Difference classification has been evaluated.
13. Source mapping has been validated.
14. Aggregation and deduplication have been reviewed.
15. Output integrity has been checked.
16. Error and incomplete-analysis handling has been tested.
17. Determinism has been investigated.
18. Incremental analysis has been checked where supported.
19. Adversarial tests have been designed and executed where practical.
20. Findings have been prioritized.
21. A final adversarial completeness pass has been completed.
22. Remaining limitations have been documented.
23. Phase 2: every confirmed finding fixed and verified, or deferred with a reason, and the Fixes Applied section written.

If repository access, tooling, context, or execution limits prevent complete coverage, explicitly document what remains.

Maintain a persistent review ledger across long sessions and context compactions. During Phase 2, record in it which findings have been fixed or deferred.

Do not repeatedly rediscover previously analyzed findings.

---

## 32. Phase 2 — Fix What the Audit Found

Only after the Phase 1 report is complete, fix the confirmed findings. Do not start fixing while still auditing — the complete, ranked list is what keeps effort on the highest-value problems instead of the first ones found.

Work through the findings in priority order. For each fix:

- Turn the finding's minimal reproduction into a regression test first, confirm it fails, then make the fix and confirm it passes.
- Run the full existing test suite and any ground-truth / oracle checks the project has. A fix that resolves one finding but changes results elsewhere is not done.
- Keep each fix small and focused; do not bundle unrelated changes.
- Rebuild and re-run the tests after every fix, not just at the end.

Do **not** implement findings that are high-risk, speculative, unproven, or that would require a broad architectural change or a change to the tool's documented behavior. Leave those in the report as recommendations, with the reason they were deferred.

When finished, update the report with the **Fixes Applied** section (Section 29, O): what was fixed (with the before/after evidence or the regression test that proves it), what was deferred and why, and anything discovered while fixing.

---

## 33. Final Instruction

**Find incorrect differences, missing differences, incorrect matches, and unjustified claims of equivalence.**

A code differ must never confuse a plausible-looking result with a correct result.

Prioritize detecting silent false negatives: real changes that disappear because of parsing omissions, incorrect symbol matching, normalization, deduplication, stale caches, or incomplete analysis.

Also aggressively investigate false positives that make the tool noisy and reduce trust in its results.

Distinguish textual differences, structural differences, symbol-binding differences, and semantic differences.

Do not assume that identical AST shapes imply equivalent behavior.

Do not assume that successful parsing implies complete analysis.

Do not assume that a clean result proves equivalence when the analysis is incomplete.

Prefer precise matching and explicit uncertainty over aggressive heuristics that silently hide changes.

Construct adversarial old/new source pairs designed specifically to defeat the implementation.

For every important language feature, test both whether genuine changes are detected and whether irrelevant differences are correctly handled.

The final deliverable must be the fixes applied in Phase 2 plus a comprehensive, evidence-supported, prioritized report containing reproducible defects, architectural weaknesses, missing test coverage, and concrete recommendations.

**Do not start fixing until the audit is complete, and do not fix what you cannot verify. Do not stop after finding obvious issues. Do not declare the review complete until the required coverage has been achieved or all remaining limitations have been explicitly documented.**