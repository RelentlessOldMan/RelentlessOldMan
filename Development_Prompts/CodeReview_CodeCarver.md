# Comprehensive C/C++ Source Carving, Reachability, and Semantic Correctness Review Specification

## 1. Mission

Perform an exhaustive, adversarial, evidence-based review of CodeCarver, a tool that analyzes C and C++ source code, identifies code required by selected entry points, and removes unnecessary or unreachable code.

The objective is to determine whether CodeCarver produces the **smallest safely justifiable source subset** while preserving all required semantics, dependencies, compilation requirements, linking behavior, and observable runtime behavior.

Find every meaningful situation in which CodeCarver:

1. Removes code that is actually required.
2. Retains code that can be proven unnecessary.
3. Resolves symbols or dependencies incorrectly.
4. Misinterprets C or C++ language constructs.
5. Mishandles preprocessing or conditional compilation.
6. Fails to account for translation-unit boundaries.
7. Mishandles templates, overloads, inheritance, or virtual dispatch.
8. Generates invalid or semantically incorrect source.
9. Makes unsound assumptions about runtime behavior.
10. Produces inconsistent or nondeterministic results.
11. Fails silently or produces misleading diagnostics.
12. Uses overly conservative fallbacks that unnecessarily preserve large amounts of code.

This review has two phases. **Phase 1 — audit:** do not modify code until the audit is complete; produce a detailed report with concrete findings, evidence, minimal reproductions, root causes, recommended fixes, and prioritized improvements. **Phase 2 — fix:** then fix the confirmed findings in priority order, with evidence for each (see the Phase 2 section near the end).

Do not stop after identifying obvious bugs. Review the complete architecture and deliberately search for subtle cases that ordinary tests are unlikely to exercise.

**Safety:** use small corpora by default. Ask the user before any very large run and before any run against a network share. Write carve output only to a scratch directory — never into or over the source tree being carved.

---

## 2. Fundamental Correctness Model

### 2.1 Define the carving contract

Before evaluating the implementation, determine exactly what CodeCarver promises to preserve.

Identify:

- Supported C language standards.
- Supported C++ language standards.
- Supported compilers and extensions.
- Supported target platforms and ABIs.
- Required compilation database or build metadata.
- Entry-point selection rules.
- Whether source files, functions, classes, or individual declarations can be removed.
- Whether code is removed textually, through AST rewriting, or through generated output.
- Whether headers are rewritten.
- Whether macros are rewritten.
- Whether external libraries are assumed available.
- Whether generated code must remain independently buildable.
- Whether the original public ABI must be preserved.
- Whether behavior is preserved for all possible inputs or only specified workloads.
- Whether observable behavior outside the selected entry points is intentionally excluded.

Document assumptions explicitly.

Do not evaluate the tool against an imagined contract.

Where the contract is ambiguous, identify the ambiguity and explain its consequences.

### 2.2 Establish reachability categories

Every relevant symbol or source construct should be classified conceptually as:

**Definitely reachable:** A valid dependency path from an entry point has been established.

**Possibly reachable:** Available static information cannot exclude a dependency.

**Proven unreachable:** The construct cannot affect any behavior required by the carving contract under the configured build and analysis assumptions.

**Unknown or unsupported:** The analyzer lacks sufficient information to make a reliable determination.

Investigate whether CodeCarver incorrectly collapses these categories.

In particular, **absence of a discovered dependency is not automatically proof of unreachability**.

Unknown dependencies must not silently become removal decisions.

### 2.3 Soundness versus precision

Evaluate two distinct properties.

**Soundness:** Does the carved output retain everything necessary to preserve the required behavior?

**Precision:** Does the tool avoid retaining code that is provably unnecessary?

Soundness is the primary correctness requirement.

Precision is the primary effectiveness requirement.

A conservative analyzer may be sound but imprecise.

An aggressive analyzer may appear effective while silently introducing correctness defects.

Identify both failure modes.

### 2.4 Semantic preservation

Evaluate preservation of:

- Program outputs.
- Return values.
- Side effects.
- Global state.
- Static initialization.
- Destruction behavior.
- Exception behavior.
- Object lifetimes.
- Memory ownership.
- Volatile accesses.
- Atomic operations.
- Thread synchronization.
- Callback execution.
- Dynamic dispatch.
- Linkage.
- ABI requirements.
- Externally observable behavior.
- Required build behavior.

Do not assume compilation success proves semantic equivalence.

---

## 3. Complete Pipeline Audit

Map the entire CodeCarver pipeline.

Identify every stage responsible for:

1. Source discovery.
2. Build configuration discovery.
3. Compilation database loading.
4. Compiler argument processing.
5. Preprocessing.
6. Parsing.
7. AST construction.
8. Symbol identification.
9. Declaration-to-definition resolution.
10. Cross-translation-unit symbol merging.
11. Dependency extraction.
12. Call graph construction.
13. Type dependency analysis.
14. Reachability propagation.
15. Conservative fallback decisions.
16. Dead-code classification.
17. Source-range selection.
18. Source rewriting.
19. Header processing.
20. Output generation.
21. Build validation.
22. Diagnostics.
23. Incremental analysis and caching.

For each stage, determine:

- Inputs.
- Outputs.
- Assumptions.
- Error handling.
- Failure modes.
- Data lost between stages.
- Whether uncertainty is preserved.
- Whether incorrect information can propagate downstream.
- Whether later stages can detect earlier mistakes.

Pay special attention to interfaces between stages.

A correct parser does not guarantee a correct dependency graph.

A correct dependency graph does not guarantee safe source rewriting.

---

## 4. Clang AST and Semantic Analysis

Where CodeCarver uses Clang or LLVM, inspect its use of Clang APIs and AST representations.

### 4.1 Declaration identity

Determine whether declarations are identified using reliable semantic identities.

Investigate:

- Canonical declarations.
- Redeclaration chains.
- Definitions.
- Forward declarations.
- Qualified names.
- Mangled names.
- Source locations.
- Unified Symbol Resolution identifiers.
- Template specialization identities.
- Internal versus external linkage.

Identify any logic relying on names alone where names are insufficient.

### 4.2 Declaration versus definition

Test:

- Forward declarations.
- Multiple declarations of one function.
- Definitions in separate files.
- Inline definitions.
- Extern declarations.
- Static declarations.
- Tentative definitions in C.
- C++ inline variables.
- Explicit template instantiations.
- Explicit template specializations.

Determine whether the analyzer correctly associates declarations with their required definitions.

### 4.3 AST traversal completeness

Inspect all AST visitors and matchers.

Determine whether they traverse every relevant expression, declaration, type, and initializer.

Look for omitted AST node categories.

Pay particular attention to nodes that do not resemble ordinary function calls but still introduce dependencies.

### 4.4 Implicit AST nodes

Investigate whether implicit compiler-generated constructs are handled.

Examples:

- Implicit casts.
- Implicit constructors.
- Conversion operators.
- Destructor calls.
- Copy operations.
- Move operations.
- Defaulted functions.
- Temporary object materialization.
- Cleanup expressions.
- Compiler-generated initialization.

Determine whether filtering implicit nodes accidentally removes required dependencies.

### 4.5 Dependent AST nodes

Inspect handling of C++ template-dependent expressions.

Examples:

- Dependent names.
- Dependent calls.
- Dependent types.
- Unresolved overload sets.
- Dependent member access.
- Template parameter substitution.

Determine whether the analyzer incorrectly assumes dependencies are fully resolved before instantiation.

### 4.6 Source-location reliability

Inspect use of:

- Spelling locations.
- Expansion locations.
- Presumed locations.
- File locations.
- Macro expansion ranges.
- Token ranges.
- Character ranges.

Determine whether incorrect location selection can remove or preserve the wrong text.

---

## 5. Preprocessor and Conditional Compilation

The C/C++ preprocessor is a critical source of correctness risks.

### 5.1 Macro expansion

Test:

- Object-like macros.
- Function-like macros.
- Nested macros.
- Recursive expansion rules.
- Token pasting.
- Stringification.
- Variadic macros.
- GNU variadic extensions.
- Macros producing declarations.
- Macros producing function calls.
- Macros producing types.
- Macros producing control flow.
- Macros producing attributes.

Determine whether dependencies introduced through macro expansion are correctly recognized.

### 5.2 Macro-generated symbols

Construct tests where functions, classes, or variables are declared through macros.

Verify that CodeCarver can preserve the necessary original macro definitions and invocation sites.

### 5.3 Conditional compilation

Test:

- `#if`
- `#ifdef`
- `#ifndef`
- `#elif`
- `#else`
- `#endif`
- `defined()`
- Compiler predefined macros.
- Platform macros.
- Feature flags.
- Build configuration macros.

Determine whether reachability is scoped to the actual compilation configuration.

A symbol unreachable in one configuration may be required in another.

### 5.4 Multiple build configurations

Investigate whether CodeCarver:

- Analyzes only one configuration.
- Supports several configurations.
- Unions dependencies across configurations.
- Preserves configuration-specific output.
- Accidentally mixes incompatible configurations.

Explicitly identify which guarantees apply to each configuration.

### 5.5 Header inclusion

Test:

- Nested includes.
- Repeated includes.
- Include guards.
- `#pragma once`.
- Cyclic includes.
- Conditional includes.
- Headers with definitions.
- Headers with static functions.
- Headers with inline functions.
- Headers with global initialization.
- Headers with macro-generated declarations.

### 5.6 Include-order dependencies

Investigate whether generated output preserves required include ordering.

Test headers that depend on declarations, macros, pragmas, or configuration established by earlier includes.

### 5.7 Preprocessor directives and rewriting

Determine whether CodeCarver can safely remove code inside conditional regions without corrupting directive structure.

Test removal of declarations surrounded by nested conditional directives.

Ensure rewritten files remain preprocessable.

### 5.8 Macro safety boundaries

Identify constructs that cannot be safely rewritten at fine granularity because source text is shared across macro expansions.

Evaluate whether CodeCarver uses appropriately conservative source-range boundaries.

Avoid blanket preservation of entire files when a smaller safe boundary can be established.

---

## 6. C Language Semantics

### 6.1 Function pointers

Test:

- Direct function-pointer assignment.
- Function pointers stored in structures.
- Function-pointer arrays.
- Callback tables.
- Function pointers passed through parameters.
- Function pointers returned from functions.
- Function pointers stored globally.
- Function pointers copied through intermediate variables.
- Indirect invocation through aliases.

Determine whether possible call targets are preserved.

### 6.2 Callback registration

Construct tests where a function is referenced only through registration.

Examples:

- Interrupt handlers.
- Event callbacks.
- Protocol handlers.
- Dispatch tables.
- Plugin registries.
- Operating system callbacks.

Verify that registration dependencies propagate correctly.

### 6.3 Global initialization

Test:

- Global variables.
- Static variables.
- Aggregate initialization.
- Function-local statics.
- Initialization through function calls.
- Initialization through macros.
- Cross-file initialization dependencies.

Distinguish initialization that is required from initialization that is provably irrelevant.

### 6.4 Tentative definitions

Test C tentative definitions across translation units.

Verify correct handling of compiler modes and linkage rules.

### 6.5 Compound literals

Test C compound literals and their storage-duration semantics.

Ensure dependencies on contained types, expressions, and referenced symbols are preserved.

### 6.6 Designated initializers

Test nested and out-of-order designated initializers.

Verify field and type dependencies.

### 6.7 Flexible array members

Test structures containing flexible array members.

Verify that size, layout, allocation, and access dependencies are handled correctly.

### 6.8 GNU C extensions

Where supported, test:

- Statement expressions.
- `typeof`.
- Nested functions.
- Computed goto.
- Label addresses.
- Attributes.
- Inline assembly.
- Zero-length arrays.
- Compiler builtins.

Do not assume standard C AST patterns cover compiler extensions.

### 6.9 Volatile and memory-mapped I/O

Test volatile reads and writes, including hardware-register access.

Determine whether the analyzer recognizes side effects that may not resemble ordinary function calls.

### 6.10 Inline assembly

Investigate:

- Symbol references in assembly strings.
- Input and output operands.
- Clobbers.
- Labels.
- Register constraints.
- Compiler-specific syntax.

Identify limitations in static dependency discovery.

---

## 7. C++ Name Resolution and Overloading

### 7.1 Namespaces

Test:

- Nested namespaces.
- Inline namespaces.
- Namespace aliases.
- Anonymous namespaces.
- Using declarations.
- Using directives.
- Qualified lookup.
- Unqualified lookup.

Verify correct symbol identity.

### 7.2 Overloaded functions

Test:

- Overloads differing by parameter type.
- Const-qualified member functions.
- Ref-qualified member functions.
- Rvalue and lvalue overloads.
- Variadic overloads.
- Deleted overloads.
- Constrained overloads.
- Function templates.
- Conversion-based overload selection.

Determine whether the exact selected overload is retained.

### 7.3 Argument-dependent lookup

Construct tests where required functions are found only through ADL.

Verify that the analyzer preserves the selected function and its dependencies.

### 7.4 Operator overloading

Test:

- Arithmetic operators.
- Comparison operators.
- Assignment operators.
- Conversion operators.
- `operator()`.
- `operator[]`.
- `operator->`.
- Allocation operators.
- Deallocation operators.
- Coroutine operators where supported.

Determine whether implicit operator calls are represented correctly in the dependency graph.

### 7.5 Conversion semantics

Test:

- Implicit conversion constructors.
- Explicit constructors.
- User-defined conversion operators.
- Conversion chains.
- Temporary object creation.
- Reference binding.

Ensure required constructors and destructors survive carving.

---

## 8. C++ Templates and Metaprogramming

Templates require a dedicated adversarial review.

### 8.1 Function templates

Test:

- Implicit instantiation.
- Explicit instantiation.
- Explicit specialization.
- Partial ordering.
- Overload resolution.
- Dependent calls.
- SFINAE.
- Concepts and constraints.

Verify that the correct instantiated dependencies are retained.

### 8.2 Class templates

Test:

- Primary templates.
- Partial specializations.
- Explicit specializations.
- Nested templates.
- Member function templates.
- Static template members.
- Variable templates.
- Template aliases.

### 8.3 Template instantiation dependencies

Determine whether CodeCarver understands dependencies that emerge only after substitution.

Investigate whether it incorrectly prunes primary templates, specializations, or helper declarations.

### 8.4 SFINAE and constraints

Test expressions that affect overload viability without appearing in ordinary runtime call paths.

Examples:

- `std::enable_if`.
- `std::void_t`.
- `requires`.
- Concepts.
- Detection idioms.
- Substitution-dependent expressions.

### 8.5 Compile-time evaluation

Test:

- `constexpr`.
- `consteval`.
- `constinit`.
- Constant-expression function calls.
- Compile-time recursion.
- Compile-time lookup tables.
- Static assertions.

Determine whether compile-time-only dependencies are retained when necessary to build the output.

### 8.6 Type traits and unevaluated operands

Test:

- `sizeof`.
- `alignof`.
- `decltype`.
- `typeid`.
- `noexcept`.
- `requires`.
- Type traits.
- `std::declval`.

A dependency may be required for compilation even when no runtime execution occurs.

### 8.7 Template-heavy standard library usage

Test representative uses of:

- `std::vector`.
- `std::array`.
- `std::tuple`.
- `std::variant`.
- `std::optional`.
- `std::function`.
- `std::invoke`.
- `std::visit`.
- Smart pointers.
- Algorithms.
- Ranges.

Identify whether CodeCarver incorrectly attributes library-generated dependencies to removable application code.

---

## 9. C++ Classes, Inheritance, and Virtual Dispatch

### 9.1 Class relationships

Test:

- Single inheritance.
- Multiple inheritance.
- Virtual inheritance.
- Diamond inheritance.
- Private inheritance.
- Protected inheritance.
- Nested classes.
- Friend declarations.

Determine whether type and layout dependencies are preserved.

### 9.2 Virtual functions

Construct tests where a function is reachable only through virtual dispatch.

Verify that all relevant possible overrides are considered.

### 9.3 Dynamic type analysis

Determine whether CodeCarver tracks possible concrete types.

Investigate:

- Factory functions.
- Polymorphic containers.
- Base-class pointers.
- References.
- Type erasure.
- Downcasts.
- Cross-casts.
- Object creation sites.

Identify cases where the analyzer is too aggressive or unnecessarily conservative.

### 9.4 Pure virtual functions

Test abstract classes and pure virtual functions.

Include pure virtual functions that have definitions.

Verify preservation of required declarations, overrides, and definitions.

### 9.5 Virtual destructors

Test deletion through base-class pointers.

Ensure derived destructors and required cleanup dependencies are retained.

### 9.6 RTTI

Test:

- `dynamic_cast`.
- `typeid`.
- Polymorphic type information.
- Cross-casting.
- Runtime type comparisons.

Evaluate whether type information and required class relationships survive carving.

### 9.7 Vtables and ABI

Investigate whether removing apparently unused virtual functions, key functions, or class definitions can change ABI requirements or produce linker failures.

Account for compiler-specific vtable emission rules.

### 9.8 Object layout

Determine whether removing fields, base classes, or declarations can change:

- Structure size.
- Alignment.
- Member offsets.
- Vtable layout.
- Standard-layout properties.
- Triviality.
- ABI compatibility.

Do not recommend member-level elimination without a clearly defined layout-preservation contract.

---

## 10. Constructors, Destructors, and Object Lifetime

### 10.1 Implicit constructors

Test compiler-generated:

- Default constructors.
- Copy constructors.
- Move constructors.
- Converting constructors.

Verify dependencies on member and base-class constructors.

### 10.2 Destructors

Test:

- Explicit destructors.
- Implicit destructors.
- Virtual destructors.
- Destructors of temporary objects.
- Destructors during exception unwinding.
- Destructors of local statics.
- Destructors of global objects.

### 10.3 RAII

Construct tests where important behavior occurs only in destructors.

Examples:

- Lock release.
- File closure.
- Resource cleanup.
- Transaction rollback.
- Reference-count updates.
- Diagnostic recording.

Ensure the analyzer does not overlook destructor-side effects.

### 10.4 Temporary objects

Test temporary materialization, lifetime extension, and cleanup.

Determine whether implicit dependencies are retained.

### 10.5 Static initialization and destruction

Investigate:

- Namespace-scope objects.
- Static data members.
- Function-local statics.
- Initialization guards.
- Dynamic initialization.
- Destruction registration.
- Cross-translation-unit initialization order.

A constructor or destructor may execute without an explicit call from an entry point.

### 10.6 Exception handling

Test:

- `throw`.
- `try`.
- `catch`.
- Exception object construction.
- Exception object destruction.
- Stack unwinding.
- `noexcept`.
- Exception specifications.

Ensure exception-related dependencies survive.

---

## 11. Function Pointers, Callbacks, and Indirect Reachability

### 11.1 Indirect call graph

Evaluate whether CodeCarver handles indirect calls soundly.

Include:

- Function pointers.
- Member-function pointers.
- Virtual calls.
- Callable objects.
- Lambdas.
- `std::function`.
- `std::bind`.
- Type-erased callbacks.
- Dispatch tables.
- Callback registries.

### 11.2 Address-taken functions

Determine how CodeCarver handles functions whose addresses are taken.

Taking a function address does not necessarily mean the function is executed, but it may establish possible reachability.

Evaluate whether the analyzer distinguishes these cases.

### 11.3 Escape analysis

Investigate function pointers passed into:

- External libraries.
- Operating system APIs.
- Threads.
- Timers.
- Event systems.
- Plugin interfaces.
- Unknown functions.

Determine whether targets remain reachable when their eventual invocation cannot be statically observed.

### 11.4 Pointer aliasing

Construct tests where function pointers pass through several assignments, structures, arrays, or parameters.

Evaluate whether alias analysis is sufficient.

### 11.5 Indirect-call precision

Determine whether unresolved indirect calls cause excessive retention.

Investigate opportunities for more precise target-set analysis without introducing unsound removals.

---

## 12. Global Variables, Static State, and Side Effects

### 12.1 Global references

Identify dependencies through global variables.

Test:

- Global arrays.
- Global pointers.
- Global structures.
- Static data members.
- Thread-local variables.
- Global registries.
- Global callback tables.

### 12.2 Initialization side effects

Construct programs where a global constructor performs registration or modifies shared state.

Verify that the initialization is preserved when required.

### 12.3 Destruction side effects

Test global and static destructors that perform observable actions.

### 12.4 Volatile and atomic state

Determine whether accesses to volatile and atomic variables are correctly represented.

### 12.5 Thread-local storage

Test thread-local initialization and destruction.

Account for dependencies triggered by first use or thread termination.

### 12.6 External visibility

Investigate symbols that may be accessed from outside the analyzed source set.

Examples:

- Exported APIs.
- Shared-library symbols.
- Plugin entry points.
- Dynamic symbol lookup.
- Symbols referenced by assembly.
- Symbols referenced by linker scripts.
- Symbols used by external binaries.

Determine whether the carving contract permits removing externally visible symbols.

---

## 13. Cross-Translation-Unit Analysis

### 13.1 Symbol identity across files

Verify that declarations and definitions from different translation units are associated correctly.

Do not rely on simple name matching.

### 13.2 Internal linkage

Test identical static function names in different source files.

Ensure they are not incorrectly merged.

### 13.3 Anonymous namespaces

Verify that same-named entities in different anonymous namespaces remain distinct.

### 13.4 External linkage

Test external functions and variables declared in headers and defined elsewhere.

### 13.5 Inline definitions

Test inline functions defined in headers and used by multiple translation units.

### 13.6 ODR requirements

Investigate C++ One Definition Rule behavior.

Test:

- Inline functions.
- Inline variables.
- Templates.
- Explicit instantiations.
- Weak symbols.
- COMDAT sections.
- Linkonce definitions.
- Conflicting definitions.

### 13.7 Linker dependencies

Identify dependencies not visible as ordinary source-level calls.

Examples:

- Linker-retained sections.
- Startup symbols.
- Registration sections.
- Constructor arrays.
- Weak references.
- Symbol aliases.
- Export tables.
- Linker-generated references.

### 13.8 Whole-program assumptions

Determine whether CodeCarver assumes access to every relevant translation unit.

Identify risks when:

- Libraries are precompiled.
- Source files are missing.
- Compilation commands are incomplete.
- Plugins are loaded dynamically.
- External code calls exported symbols.

Unknown external consumers must not be silently ignored.

---

## 14. Build-System and Compilation Database Correctness

### 14.1 Compilation commands

Inspect handling of:

- Compiler executable.
- Language standard.
- Include paths.
- Macro definitions.
- Forced includes.
- Target architecture.
- ABI options.
- Warning and error settings.
- Compiler extensions.
- Precompiled headers.
- Module options.

### 14.2 Multiple commands per file

Determine how CodeCarver handles one source file compiled under different configurations.

### 14.3 Generated source

Investigate generated headers and source files.

Determine whether generation dependencies are preserved.

### 14.4 Build-system metadata

Evaluate whether required information is obtained from:

- CMake.
- Make.
- Ninja.
- Visual Studio.
- MSBuild.
- Compilation databases.
- Linker command lines.

### 14.5 C and C++ linkage

Test `extern "C"` declarations and mixed-language projects.

### 14.6 Platform-specific code

Test compiler and platform conditionals.

Do not assume that output valid for one target is valid for every supported target.

### 14.7 Modules and precompiled headers

Where supported, investigate C++20 modules, header units, and precompiled headers.

Ensure dependency analysis does not incorrectly treat imported declarations as ordinary textual includes.

---

## 15. Reachability Graph Correctness

### 15.1 Graph node identity

Determine whether nodes represent:

- Declarations.
- Definitions.
- Canonical symbols.
- Template instantiations.
- Types.
- Variables.
- Initializers.
- Macros.
- Source ranges.
- Translation-unit-specific entities.

Evaluate whether the representation is sufficiently precise.

### 15.2 Dependency edge types

Inventory all edge categories.

Examples:

- Direct call.
- Indirect call.
- Virtual dispatch.
- Type use.
- Field access.
- Global variable reference.
- Initializer dependency.
- Destructor dependency.
- Template instantiation.
- Macro dependency.
- Linkage dependency.
- ABI dependency.
- External reference.

Identify missing edge types.

### 15.3 Directionality

Verify dependency edges point in the correct direction.

Incorrect edge direction can cause widespread over-retention or false removal.

### 15.4 Transitive closure

Verify reachability propagation across arbitrarily long dependency chains.

### 15.5 Cycles

Test:

- Mutually recursive functions.
- Cyclic type dependencies.
- Recursive templates.
- Cyclic global references.
- Mutually dependent classes.

Determine whether strongly connected components are handled correctly.

### 15.6 Incremental graph updates

If CodeCarver supports incremental analysis, determine whether graph updates correctly invalidate obsolete dependencies.

### 15.7 Graph completeness

Evaluate whether all relevant AST relationships become graph edges.

Trace representative constructs from AST node through dependency extraction to final reachability classification.

### 15.8 Unknown edges

Determine how unresolved references are represented.

Unknown dependencies must not silently disappear from the graph.

### 15.9 Reachability explanations

Evaluate whether the analyzer can explain why a symbol is retained.

A useful explanation should include a path from a root or a documented conservative retention rule.

### 15.10 Removal explanations

Evaluate whether CodeCarver can explain why a symbol is classified as removable.

Distinguish lack of discovered reachability from actual proof under the tool's assumptions.

---

## 16. Root Selection and Entry-Point Semantics

### 16.1 Entry-point identification

Test:

- `main`.
- `WinMain`.
- `wWinMain`.
- Library entry points.
- Exported functions.
- Test entry points.
- User-selected functions.
- Embedded-system reset handlers.
- Interrupt vectors.
- Plugin entry points.

### 16.2 Multiple roots

Verify that reachability is computed from the complete root set.

### 16.3 Hidden runtime roots

Investigate compiler and runtime initialization mechanisms.

Examples:

- Global constructors.
- Startup routines.
- TLS initialization.
- Registration sections.
- Linker-retained symbols.
- Runtime callbacks.

### 16.4 Externally invoked functions

Determine whether exported or dynamically discovered functions must be treated as roots.

### 16.5 Root configuration errors

Test invalid, missing, ambiguous, and duplicate root specifications.

The tool should fail clearly rather than silently produce incorrect output.

---

## 17. Dead-Code Elimination Precision

### 17.1 Unused functions

Determine whether CodeCarver removes provably unreachable functions.

Test direct, indirect, recursive, inline, template, and overloaded functions.

### 17.2 Unused classes

Evaluate removal of classes that are not required by retained code.

Consider nested declarations, template specializations, RTTI, and ABI constraints.

### 17.3 Unused methods

Determine whether unused nonvirtual methods can be removed safely.

Evaluate virtual methods separately.

### 17.4 Unused global variables

Inspect globals that have no required reads, writes, initialization side effects, or external visibility obligations.

### 17.5 Unused types

Test:

- Structures.
- Classes.
- Unions.
- Enums.
- Typedefs.
- Type aliases.
- Forward declarations.

Determine whether types are needed for compilation, layout, overload resolution, or template instantiation.

### 17.6 Unused includes

Evaluate whether headers can be removed without breaking compilation.

Do not assume a header is unnecessary merely because no directly referenced symbol appears to originate from it.

### 17.7 Unused macros

Determine whether unused macro definitions can be removed safely.

Account for conditional compilation and macro-generated source.

### 17.8 Unused declarations

Investigate whether redundant declarations can be removed while preserving valid name lookup and compilation.

### 17.9 Partial retention

Evaluate whether CodeCarver unnecessarily preserves entire files or classes when only smaller portions are required.

Identify safe opportunities for finer-grained carving.

### 17.10 Minimality limits

Document cases where exact minimal output is impractical or undecidable under the chosen analysis model.

Do not require impossible proof of global minimality.

Instead, evaluate whether the tool is as precise as reasonably possible within its documented guarantees.

---

## 18. Source Rewriting and Output Integrity

### 18.1 Source-range correctness

Inspect how CodeCarver selects text to remove.

Test:

- Adjacent declarations.
- Multiple declarations in one statement.
- Nested declarations.
- Macros.
- Comments.
- Attributes.
- Templates.
- Preprocessor directives.
- Conditional blocks.
- Namespace boundaries.

### 18.2 Token boundaries

Ensure rewriting does not leave malformed tokens, punctuation, or declarations.

### 18.3 Multiple declarators

Test constructs such as:

`int a, b, c;`

Determine whether removing one declarator preserves the others correctly.

### 18.4 Class member removal

Test removal of methods and fields inside class definitions.

Verify access specifiers, syntax, layout, and dependent declarations remain valid.

### 18.5 Template rewriting

Test partial removal inside template declarations and specializations.

### 18.6 Macro rewriting

Determine whether source ranges originating from macro expansions are handled safely.

### 18.7 Comments and formatting

Ensure comments, whitespace, and formatting do not cause incorrect deletion boundaries.

Preserve meaningful comments and directives where required.

### 18.8 Line directives and diagnostics

Determine whether generated output retains useful source-location information.

### 18.9 Output determinism

Repeated runs on identical inputs and configuration should produce equivalent, preferably byte-identical, output.

### 18.10 Output compilation

Validate generated code using the intended compiler and build configuration.

### 18.11 Output linking

Validate all required symbols and libraries.

### 18.12 Output execution

Where practical, execute the carved program and compare its behavior with the original.

---

## 19. Adversarial Test Generation

Construct a comprehensive test corpus designed to break CodeCarver.

Do not rely exclusively on existing tests.

### 19.1 Minimal language-feature tests

For each relevant C/C++ construct, create a minimal program containing:

- One required construct.
- One similar but unnecessary construct.
- A clearly defined root.
- Expected retained symbols.
- Expected removed symbols.
- Expected compilation behavior.
- Expected runtime behavior.

### 19.2 Combined-feature tests

Test interactions between features.

Examples:

- Templates with virtual dispatch.
- Macros generating callbacks.
- Global constructors registering function pointers.
- Anonymous namespaces across translation units.
- SFINAE selecting overloaded functions.
- Virtual inheritance with implicit destructors.
- Conditional compilation with explicit instantiation.
- Inline assembly referencing external symbols.
- Linker registration sections containing callbacks.
- Lambdas stored in global registries.

Many bugs arise from combinations rather than isolated features.

### 19.3 Adversarial symbol naming

Test:

- Identical names in different scopes.
- Identical static names in different files.
- Overloaded functions.
- Namespace aliases.
- Shadowed variables.
- Nested classes.
- Anonymous namespaces.
- Template specializations.
- Mangled-name collisions or assumptions.

### 19.4 Deep dependency chains

Generate long chains of functions, types, templates, and global references.

Verify complete reachability propagation.

### 19.5 Cyclic dependencies

Generate strongly connected dependency graphs.

Verify that reachable cycles are retained and unreachable cycles are removed.

### 19.6 Large generated programs

Generate synthetic C/C++ projects containing thousands of declarations and controlled dependency graphs.

Measure:

- False removals.
- Excessive retention.
- Analysis completeness.
- Determinism.
- Scalability.
- Error handling.

### 19.7 Malformed input

Test:

- Syntax errors.
- Missing headers.
- Invalid compiler arguments.
- Unsupported extensions.
- Incomplete translation units.
- Conflicting declarations.
- Broken templates.

The tool must not silently treat parse failures as evidence that code is unnecessary.

### 19.8 Metamorphic testing

Create equivalent source variants that should produce equivalent carving decisions.

Examples:

- Rename symbols consistently.
- Reorder independent declarations.
- Add irrelevant dead functions.
- Change whitespace and comments.
- Move definitions between files where semantics permit.
- Replace direct syntax with semantically equivalent forms.
- Reorder independent translation units.
- Add unused headers.

Investigate unexpected changes in retained-symbol sets.

### 19.9 Differential testing

For each test program:

1. Compile the original.
2. Execute representative inputs.
3. Record outputs and observable behavior.
4. Run CodeCarver.
5. Compile the carved output.
6. Execute the same inputs.
7. Compare results.
8. Investigate discrepancies.

Use sanitizers where appropriate.

### 19.10 Mutation testing

Deliberately mutate the analyzer or test inputs to determine whether the test suite detects incorrect reachability decisions.

Examples:

- Remove a dependency edge.
- Misresolve an overload.
- Ignore a destructor.
- Omit a template specialization.
- Drop a global initializer dependency.

A strong test suite should detect these defects.

---

## 20. Testing Oracles and Ground Truth

### 20.1 Known dependency graphs

Generate programs from explicitly defined dependency graphs.

Compare expected and actual reachability.

### 20.2 Compiler-based validation

Use compilation and linking as necessary checks.

Do not treat them as sufficient proof of semantic correctness.

### 20.3 Runtime comparison

Compare original and carved behavior under identical inputs and environments.

### 20.4 Symbol-level comparison

Inspect generated symbols where useful.

Compare expected retained and removed symbols.

### 20.5 Coverage metrics

Measure:

- Supported constructs tested.
- Dependency edge types tested.
- Parsing branches tested.
- Reachability logic tested.
- Rewriting paths tested.
- Error paths tested.
- Build configurations tested.

### 20.6 Precision metrics

Where ground truth is available, measure:

- Required symbols incorrectly removed.
- Unnecessary symbols incorrectly retained.
- Retained source bytes.
- Removed source bytes.
- Retained declarations.
- Removed declarations.
- Output compilation success.
- Behavioral equivalence test success.

Use explicit denominators and consistent definitions.

### 20.7 Soundness reporting

Report false removals separately from excessive retention.

Never combine them into a single score that hides correctness failures.

---

## 21. Error Handling and Conservative Fallbacks

### 21.1 Parse failures

Determine whether failed translation units are clearly identified.

### 21.2 Missing dependencies

Inspect behavior when headers, libraries, or build metadata are unavailable.

### 21.3 Unsupported syntax

Identify whether unsupported constructs trigger:

- Explicit diagnostics.
- Conservative retention.
- Partial analysis.
- Incorrect removal.
- Silent failure.

### 21.4 Unresolved symbols

Determine whether unresolved references are preserved as uncertainty rather than discarded.

### 21.5 Fallback granularity

Evaluate whether CodeCarver unnecessarily retains entire files or modules when only a smaller region is uncertain.

### 21.6 Failure propagation

Ensure errors in early pipeline stages cannot silently produce confident but incorrect removal decisions downstream.

### 21.7 Diagnostic quality

Every significant uncertainty should identify:

- Source location.
- Relevant construct.
- Reason for uncertainty.
- Affected symbols.
- Conservative action taken.
- Potential impact on output precision.

---

## 22. Determinism and Reproducibility

Test repeated analysis with:

- Identical inputs.
- Different file enumeration order.
- Different translation-unit order.
- Different thread counts.
- Different hash-map iteration order.
- Warm and cold caches.
- Incremental versus clean analysis.
- Different working directories.
- Equivalent absolute and relative paths.

Determine whether the retained symbol set and generated output remain stable.

Investigate nondeterministic dependency graph construction and race conditions.

---

## 23. Incremental Analysis and Cache Correctness

If CodeCarver supports caching or incremental processing, inspect:

- File change detection.
- Header dependency invalidation.
- Macro definition changes.
- Compiler argument changes.
- Language standard changes.
- Template instantiation changes.
- Cross-file dependency changes.
- Root selection changes.
- Target platform changes.

Verify that cached results cannot cause stale reachability decisions.

Compare incremental output against a clean full analysis.

---

## 24. Security and Robustness

Treat analyzed source code and build metadata as potentially untrusted input.

Investigate:

- Path traversal.
- Unsafe output paths.
- Symlink handling.
- Arbitrary file overwrites.
- Malformed compilation databases.
- Command injection.
- Unexpected compiler execution.
- Excessive resource consumption.
- Deep recursion.
- Parser crashes.
- Integer overflow.
- Unbounded allocations.
- Infinite loops.
- Malicious macro expansion.
- Unexpected generated-file behavior.

Ensure analysis does not execute target program code merely to determine reachability unless explicitly authorized and isolated.

---

## 25. Scalability and Performance

Although correctness is the primary objective, evaluate performance on large projects.

Measure:

- Parsing time.
- AST traversal time.
- Symbol resolution time.
- Graph construction time.
- Reachability propagation time.
- Source rewriting time.
- Peak RAM usage.
- Total CPU time.
- Incremental update time.

Identify pathological complexity.

Examples:

- Repeated whole-graph scans.
- Quadratic symbol resolution.
- Duplicate AST traversal.
- Repeated template processing.
- Excessive cross-translation-unit comparisons.
- Repeated source parsing.
- Inefficient dependency propagation.

Do not prioritize speed improvements over correctness defects.

---

## 26. Required Review Procedure

All of the steps below belong to Phase 1 (audit). They are numbered as steps so they are not confused with the audit and fix phases; do not change code while performing them.

### Step 1: Contract and architecture

1. Identify the intended carving guarantees.
2. Identify supported C/C++ standards and extensions.
3. Map the complete pipeline.
4. Inventory dependency edge types.
5. Identify conservative fallback rules.
6. Identify source rewriting mechanisms.
7. Identify test infrastructure.
8. Identify build configurations.

### Step 2: Parsing and symbol resolution

Review:

- Preprocessor integration.
- AST traversal.
- Declaration identity.
- Name lookup.
- Overloads.
- Templates.
- Translation-unit merging.
- Compiler-generated constructs.

### Step 3: Dependency analysis

Review:

- Direct calls.
- Indirect calls.
- Virtual dispatch.
- Type dependencies.
- Global state.
- Initialization.
- Destruction.
- Linkage.
- ABI dependencies.
- Unknown references.

### Step 4: Reachability and pruning

Review:

- Root selection.
- Graph propagation.
- Cycles.
- Unknown dependencies.
- Removal criteria.
- Conservative fallbacks.
- Over-retention.

### Step 5: Output generation

Review:

- Source ranges.
- Macro boundaries.
- Preprocessor structure.
- Declaration removal.
- Header rewriting.
- Compilation.
- Linking.
- Runtime behavior.

### Step 6: Adversarial testing

Generate targeted tests for every major language-feature category.

Prioritize cases where required code is reachable only through non-obvious dependencies.

### Step 7: Cross-component investigation

Trace failures across parsing, symbol resolution, graph construction, pruning, and rewriting.

Do not assume a defect belongs to the stage where it becomes visible.

### Step 8: Completeness pass

Revisit every major category and actively search for cases not covered by existing tests.

Maintain a persistent review ledger.

---

## 27. Finding Classification

#### Critical

- Required code removed silently.
- Incorrect semantic behavior in generated output.
- Incorrect root or dependency resolution causing widespread false removals.
- Silent analysis failure resulting in unsafe carving.
- Generated code that appears valid but violates the preservation contract.

#### High

- Incorrect handling of major C/C++ constructs.
- Missing cross-translation-unit dependencies.
- Significant virtual dispatch or template analysis gaps.
- Common compilation or linking failures.
- Major unnecessary retention.
- Unsafe source rewriting.

#### Medium

- Overly conservative retention in specific constructs.
- Limited symbol-resolution defects.
- Incomplete diagnostics.
- Missing adversarial coverage.
- Incremental analysis inconsistencies.
- Determinism problems without semantic consequences.

#### Low

- Minor output bloat.
- Small missed elimination opportunities.
- Limited diagnostic weaknesses.
- Cosmetic output problems.

Severity should reflect real correctness risk, affected scope, and practical impact.

---

## 28. Required Finding Format

For every finding, provide:

**Finding ID:** Unique identifier.

**Title:** Concise description.

**Severity:** Critical / High / Medium / Low.

**Confidence:** High / Medium / Low.

**Category:** Parsing, symbol resolution, dependency graph, reachability, pruning, rewriting, build, runtime, or other.

**Location:** Exact file, function, and line numbers.

**Affected language features:** Relevant C/C++ constructs.

**Current behavior:** What CodeCarver does.

**Expected behavior:** What correct carving requires.

**Root cause:** Why the implementation fails or is imprecise.

**Evidence:** Relevant code, AST observations, dependency traces, or test results.

**Minimal reproducer:** Smallest practical C/C++ example demonstrating the issue.

**Expected retained symbols:** Required declarations and definitions.

**Expected removed symbols:** Provably unnecessary declarations and definitions.

**Actual result:** What CodeCarver retains or removes.

**Impact:** Compilation failure, linking failure, behavioral difference, excessive retention, or other consequence.

**Recommended fix:** Concrete implementation strategy.

**Correctness risks:** Potential hazards introduced by the fix.

**Regression test:** Test that should permanently detect recurrence.

**Dependencies:** Related findings or prerequisite improvements.

Clearly label suspected issues that have not been reproduced.

---

## 29. Required Final Report

### A. Executive Summary

Include:

- Overall assessment of CodeCarver correctness.
- Largest risks of incorrect removal.
- Largest sources of excessive retention.
- Major architectural weaknesses.
- Confidence in conclusions.
- Limitations of available evidence.

### B. Architecture Overview

Describe the parsing, dependency analysis, reachability, pruning, and rewriting architecture.

### C. Ranked Findings

Provide:

| Rank | Finding | Severity | Correctness Risk | Precision Impact | Confidence | Effort |
|---|---|---|---|---|---|---|

Prioritize correctness defects before output-size improvements.

### D. Detailed Findings

Include the complete finding format from Section 28.

### E. False-Removal Risks

Group all findings that could remove required code.

Explain triggering conditions and expected consequences.

### F. Excessive-Retention Opportunities

Group all findings where CodeCarver preserves more code than necessary.

Estimate retained declarations, files, or source bytes where practical.

### G. Parsing and Language Coverage Gaps

Identify unsupported or incompletely supported C/C++ constructs.

### H. Dependency Graph Improvements

Recommend missing edge types, improved symbol identity, better indirect-call analysis, and more precise uncertainty tracking.

### I. Source Rewriting Improvements

Identify changes needed for safer and more precise output generation.

### J. Adversarial Test Corpus

List proposed and executed test cases.

Include expected results and coverage categories.

### K. Architectural Recommendations

Identify major changes that could improve soundness, precision, diagnostics, and maintainability.

### L. Coverage Report

List every reviewed subsystem, important file, and language-feature category.

### M. Remaining Unknowns

Identify questions requiring additional testing, compiler-specific analysis, or runtime validation.

### N. Fixes Applied

Written in Phase 2 (Section 32). For each finding ID:

- The fix that was applied.
- The regression test that failed before the fix and passes after it.
- The test-suite and ground-truth / oracle results after the fix.

Also list every deferred finding with the reason, and anything discovered while fixing.

---

## 30. Deep-Review Questions

After the initial review, explicitly investigate:

- Can CodeCarver remove a function that is reachable only through a function pointer?
- Can it miss a virtual override?
- Can it remove a destructor with required side effects?
- Can it remove a global constructor that registers a callback?
- Can it confuse identical static function names in different translation units?
- Can it select the wrong overloaded function?
- Can it miss dependencies introduced by template instantiation?
- Can it mishandle dependent name lookup?
- Can it remove a declaration required only for overload resolution?
- Can it remove a type required only for `sizeof` or `decltype`?
- Can it mishandle a macro-generated function?
- Can it corrupt nested preprocessor directives?
- Can it produce output valid under one configuration but invalid under another?
- Can it remove symbols referenced by inline assembly?
- Can it remove exported symbols required by external consumers?
- Can it miss linker-retained registration tables?
- Can it change global initialization behavior?
- Can it alter class layout or ABI?
- Can it remove a function required during exception unwinding?
- Can it mishandle explicit template instantiations?
- Can it confuse declaration identity across files?
- Can it silently ignore an unparsed translation unit?
- Can stale cached analysis produce incorrect output?
- Can different file ordering change reachability results?
- Can it retain entire classes when only one method is required?
- Can it retain entire headers unnecessarily?
- Can it retain unrelated template specializations?
- Can it retain entire translation units because of one uncertain dependency?
- Can it explain why every retained symbol is required?
- Can it explain why every removed symbol is safe to remove?
- Can its test suite detect intentionally introduced dependency-analysis defects?
- What language constructs are absent from the current test corpus?
- What assumptions about C/C++ semantics are embedded in the implementation but not documented?

Do not merely answer these questions from intuition. Inspect the implementation and construct tests wherever practical.

---

## 31. Completion Criteria

The review is complete only when:

1. The carving contract has been documented.
2. The complete pipeline has been reviewed.
3. Preprocessor handling has been investigated.
4. AST traversal has been reviewed.
5. Symbol resolution has been examined.
6. Cross-translation-unit identity has been checked.
7. Direct and indirect dependencies have been analyzed.
8. Templates and overloads have been investigated.
9. Virtual dispatch has been investigated.
10. Initialization and destruction have been investigated.
11. Linkage and ABI requirements have been considered.
12. Reachability propagation has been verified.
13. Conservative fallback behavior has been reviewed.
14. Dead-code elimination precision has been evaluated.
15. Source rewriting has been reviewed.
16. Compilation and linking validation has been considered.
17. Adversarial tests have been designed and executed where practical.
18. Differential testing has been considered.
19. Incremental analysis and determinism have been checked.
20. Findings have been prioritized.
21. A final adversarial completeness pass has been performed.
22. Remaining limitations have been explicitly documented.
23. Phase 2: every confirmed finding fixed and verified, or deferred with a reason, and the Fixes Applied section written.

Do not claim complete coverage if important components or language features remain unexamined.

If the investigation spans multiple sessions, preserve a persistent review ledger recording coverage, findings, tests, unresolved questions, and — during Phase 2 — which findings have been fixed or deferred.

---

## 32. Phase 2 — Fix What the Audit Found

Only after the Phase 1 report is complete, fix the confirmed findings. Do not start fixing while still auditing — the complete, ranked list is what keeps effort on the highest-value problems instead of the first ones found.

Work through the findings in priority order. For each fix:

- Turn the finding's minimal reproduction into a regression test first, confirm it fails, then make the fix and confirm it passes.
- Run the full existing test suite and any ground-truth / oracle checks the project has. A fix that resolves one finding but changes results elsewhere is not done.
- Keep each fix small and focused; do not bundle unrelated changes.
- Rebuild and re-run the tests after every fix, not just at the end.

Do **not** implement findings that are high-risk, speculative, unproven, or that would require a broad architectural change or a change to CodeCarver's documented behavior. Leave those in the report as recommendations, with the reason they were deferred.

When finished, update the report with the **Fixes Applied** section (Section 29, N): what was fixed (with the before/after evidence or the regression test that proves it), what was deferred and why, and anything discovered while fixing.

---

## 33. Final Instruction

**The purpose of CodeCarver is not merely to produce smaller source code. It is to remove code that is provably unnecessary while preserving everything required by the selected program semantics.**

Treat false removal as a correctness defect.

Treat excessive retention as a precision defect.

Treat unresolved dependencies as uncertainty, not evidence of dead code.

Prefer improving the analyzer's understanding of C/C++ semantics over blanket retention rules — without making the carve unsound; when a target can't be resolved, keeping the candidate set is correct.

Focus particularly on non-obvious dependencies created by templates, virtual dispatch, implicit constructors and destructors, global initialization, function pointers, macros, cross-translation-unit linkage, and compiler-generated behavior.

Challenge every assumption that source-level reachability is equivalent to runtime call reachability.

Generate adversarial examples specifically intended to falsify the analyzer's conclusions.

For each important language feature, determine both whether CodeCarver safely retains required code and whether it avoids retaining unrelated code.

The final deliverable must be the fixes applied in Phase 2 plus a comprehensive, evidence-supported, prioritized review report containing reproducible defects, architectural weaknesses, missed elimination opportunities, and concrete recommendations.

**Do not start fixing until the audit is complete, and do not fix what you cannot verify. Do not stop after finding obvious problems. Do not declare the review complete until the required coverage has been achieved or all remaining limitations have been explicitly documented.**