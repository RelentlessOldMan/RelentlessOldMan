# Comprehensive CPU Efficiency Code Review Specification

## 1. Mission

Perform an exhaustive, systematic review of the entire codebase to identify every meaningful opportunity to reduce wasted CPU cycles without compromising correctness, functionality, reliability, concurrency safety, or maintainability.

The primary objective is to identify **computation that is unnecessary, duplicated, repeated excessively, performed inefficiently, or caused by avoidable architectural decisions**.

Investigate both obvious performance bottlenecks and subtle inefficiencies that accumulate across millions of operations.

Do not limit the review to slow functions or algorithms with poor asymptotic complexity. Many significant CPU inefficiencies involve individually inexpensive operations executed unnecessarily at high frequency.

Review all relevant source code, algorithms, loops, data structures, synchronization mechanisms, background workers, polling systems, parsing, serialization, allocation behavior, and execution architecture.

Be aggressive in identifying inefficiencies but conservative in recommending changes that could affect correctness.

This review has two phases. **Phase 1 — audit:** do not modify code until the audit is complete; produce a comprehensive, evidence-supported report containing concrete findings, estimated CPU savings, risk assessments, and validation recommendations. **Phase 2 — fix:** then fix the confirmed findings in priority order, with evidence for each (see the Phase 2 section near the end).

---

# 2. Core Review Principles

## 2.1 Distinguish CPU performance metrics

Evaluate the following independently:

1. **CPU time:** Total processor time consumed by an operation.
2. **Wall-clock time:** Actual elapsed time required to complete an operation.
3. **CPU utilization:** Percentage of available processor capacity being used.
4. **Throughput:** Amount of useful work completed per unit of time.
5. **Latency:** Time required to complete an individual operation.
6. **Allocation overhead:** CPU time spent allocating and managing memory.
7. **Garbage collection overhead:** CPU time consumed reclaiming memory.
8. **Synchronization overhead:** CPU cycles consumed coordinating threads.
9. **Scheduler overhead:** CPU time spent switching between execution contexts.
10. **System-call overhead:** CPU time spent crossing operating system boundaries.
11. **Cache inefficiency:** CPU stalls caused by poor memory locality.
12. **Instruction inefficiency:** Excess instructions required to perform useful work.
13. **Speculative execution waste:** Work discarded because of branch mispredictions or incorrect speculation.
14. **Background CPU consumption:** CPU used when the application is idle or has no useful work.
15. **Energy efficiency:** Processor work and power consumption required to complete a workload.

Do not conflate these metrics.

A change that reduces latency by using more CPU may be beneficial for a latency-sensitive application but inappropriate for a CPU-efficiency objective.

A change that lowers CPU utilization by making the application slower is not necessarily an optimization.

## 2.2 Define useful work

For each major subsystem, determine what useful output it produces.

Examples:

- Requests processed.
- Files indexed.
- Records transformed.
- Simulations completed.
- Search nodes evaluated.
- Frames rendered.
- Tests executed.
- Messages processed.
- Queries answered.
- Data analyzed.

Evaluate CPU cost relative to useful output.

Where practical, calculate:

`CPU cost per unit = total CPU time / useful units completed`

This is often more informative than raw CPU utilization.

## 2.3 Establish a performance baseline

Where execution and profiling are practical, determine:

- Total CPU time.
- Wall-clock execution time.
- Per-thread CPU consumption.
- CPU utilization during active workloads.
- CPU utilization while idle.
- Hot functions and call paths.
- Invocation counts.
- Time per invocation.
- Instruction counts.
- Cache misses.
- Branch mispredictions.
- Context switches.
- Lock contention.
- Garbage collection CPU time.
- Allocation rate.
- System-call frequency.
- Throughput.
- CPU time per completed operation.

Record the workload, hardware, runtime, compiler settings, and measurement conditions.

If runtime profiling is unavailable, perform static analysis and clearly distinguish hypotheses from measured findings.

## 2.4 Quantify inefficiencies

For every meaningful issue, estimate:

- Cost per execution.
- Execution frequency.
- Total CPU cost.
- Percentage of relevant workload CPU time.
- Expected reduction from the proposed change.
- Potential effects on latency and throughput.
- Potential effects on RAM consumption.

Useful formulas include:

`Total wasted CPU time = avoidable time per invocation × invocation count`

`CPU savings percentage = eliminated CPU time / baseline CPU time × 100`

`Speedup = original execution time / optimized execution time`

Do not invent precise speedups without supporting evidence.

Use ranges and explicit assumptions where necessary.

## 2.5 Preserve correctness

Never recommend an optimization that silently changes:

- Observable behavior.
- Numerical accuracy.
- Determinism.
- Data integrity.
- Thread safety.
- Ordering guarantees.
- Error handling.
- Resource ownership.
- API contracts.
- Serialization compatibility.
- Cancellation semantics.
- Security guarantees.

Consider whether a proposed optimization changes floating-point behavior, timing-sensitive interactions, or concurrency ordering.

---

# 3. Redundant and Unnecessary Computation

## 3.1 Repeated calculations

Identify computations repeatedly performed with identical inputs.

Examples:

- Recalculating derived properties.
- Repeatedly parsing unchanged data.
- Recomputing hashes.
- Repeatedly normalizing strings.
- Repeatedly resolving paths.
- Repeatedly calculating lookup values.
- Rebuilding unchanged metadata.
- Repeatedly evaluating invariant conditions.

Determine whether results can be reused safely.

## 3.2 Loop-invariant computation

Inspect every significant loop for work that does not depend on the loop iteration.

Look for:

- Repeated property lookups.
- Repeated collection length calculations when nontrivial.
- Repeated conversions.
- Repeated configuration reads.
- Repeated parsing.
- Repeated allocation.
- Repeated initialization.
- Repeated construction of lookup tables.
- Repeated validation of immutable inputs.

Consider hoisting invariant work outside loops.

Verify that moving operations does not alter side effects, exception behavior, or concurrency semantics.

## 3.3 Duplicate computation across components

Identify cases where multiple modules independently calculate the same result.

Examples:

- Repeated dependency analysis.
- Duplicate indexing.
- Repeated data transformations.
- Duplicate filtering.
- Repeated validation.
- Repeated metadata extraction.
- Multiple identical database queries.

Trace the complete data flow.

Determine whether sharing intermediate results is safe and worthwhile.

## 3.4 Computation whose result is unused

Look for:

- Calculated values that are discarded.
- Work overwritten before being consumed.
- Unnecessary preprocessing.
- Redundant validation.
- Dead calculations.
- Expensive diagnostics that are never emitted.
- Results computed for disabled features.
- Complete results generated when only partial results are required.

Pay particular attention to computation performed speculatively.

## 3.5 Repeated work after failures

Inspect retry loops and error handling.

Identify operations that repeat expensive work unnecessarily after failure.

Consider whether partial progress can be reused safely.

Ensure retries preserve correctness and idempotency.

---

# 4. Algorithmic Efficiency

## 4.1 Analyze time complexity

For each computationally significant algorithm, determine:

- Expected time complexity.
- Worst-case time complexity.
- Input-size scaling.
- Dominant operations.
- Repeated subproblems.
- Data-dependent behavior.
- Potential pathological inputs.

Look for avoidable:

- O(N²) loops.
- O(N³) algorithms.
- Exponential exploration.
- Repeated linear scans.
- Repeated sorting.
- Repeated graph traversals.
- Unnecessary exhaustive searches.

## 4.2 Nested loops

Inspect nested loops for redundant comparisons or repeated work.

Examples:

- Comparing every item against every other item.
- Repeatedly scanning a collection to find matching records.
- Repeated membership tests against lists.
- Repeated searches for previously discovered information.

Evaluate indexing, hashing, sorting, or preprocessing.

Do not assume an asymptotically better algorithm is faster for very small inputs.

## 4.3 Repeated searching

Identify repeated linear searches where efficient lookup structures would help.

Evaluate:

- Hash maps.
- Hash sets.
- Sorted arrays.
- Binary search.
- Direct indexing.
- Bitsets.
- Compact lookup tables.

Consider construction cost, lookup frequency, memory overhead, and mutation behavior.

## 4.4 Repeated sorting

Find collections sorted multiple times without meaningful changes.

Determine whether:

- Sorting can occur once.
- Sorted order can be maintained incrementally.
- Partial sorting is sufficient.
- Selection algorithms can replace complete sorting.
- Top-K algorithms are appropriate.

## 4.5 Repeated traversal

Inspect algorithms that repeatedly traverse the same graph, tree, or collection.

Determine whether traversal results can be reused or combined.

Examples:

- Multiple passes calculating related aggregates.
- Repeated tree searches.
- Repeated dependency resolution.
- Repeated reachability analysis.
- Repeated parent-chain traversal.

## 4.6 Recursive algorithms

Inspect:

- Duplicate recursive subproblems.
- Excessive recursion.
- Repeated state construction.
- Inefficient base cases.
- Repeated validation.
- Expensive recursive cleanup.
- Stack overhead.

Consider memoization, iterative implementations, or dynamic programming where appropriate.

## 4.7 Incremental computation

Identify complete recalculations triggered by small changes.

Examples:

- Rebuilding an entire index after one record changes.
- Recalculating all statistics after one new sample.
- Revalidating an entire graph after one edge changes.
- Regenerating all derived state after a localized update.

Evaluate incremental updates.

Explicitly consider invalidation complexity and correctness risks.

---

# 5. Loop and Hot-Path Efficiency

## 5.1 Hot-loop analysis

Identify loops executed millions or billions of times.

Inspect every operation inside them.

Look for:

- Unnecessary branches.
- Repeated function calls.
- Repeated bounds checks where avoidable.
- Repeated conversions.
- Unnecessary allocations.
- Redundant loads.
- Redundant stores.
- Expensive abstractions.
- Repeated synchronization.
- Repeated logging checks.
- Repeated virtual dispatch.
- Inefficient iteration.

Even small savings per iteration may produce substantial total benefits.

## 5.2 Function-call overhead

Investigate very small functions called at extremely high frequency.

Determine whether call overhead is significant after compiler optimization.

Consider:

- Inlining.
- Devirtualization.
- Specialization.
- Reducing interface dispatch.
- Avoiding unnecessary abstraction layers.

Do not recommend manual inlining without evidence that the compiler fails to optimize the call.

## 5.3 Branch efficiency

Inspect frequently executed conditional logic.

Look for:

- Redundant conditions.
- Repeated comparisons.
- Predictably constant branches.
- Complex decision chains.
- Branch-heavy processing of regular data.
- Conditions that could be evaluated once per batch.

Evaluate branch prediction and code clarity.

Do not assume branchless code is automatically faster.

## 5.4 Early termination

Identify algorithms that continue processing after the required result is known.

Examples:

- Searching after a match is found.
- Validating remaining records after an unrecoverable failure.
- Generating all candidates when one acceptable candidate suffices.
- Traversing entire structures for a bounded query.
- Computing exact results when a safe threshold decision is sufficient.

Preserve required side effects and error reporting.

## 5.5 Batching

Identify operations with significant fixed overhead per item.

Examples:

- Small system calls.
- Individual database writes.
- Repeated lock acquisition.
- Repeated serialization.
- Repeated network messages.
- Repeated interpreter transitions.

Evaluate batching where it reduces overhead without introducing unacceptable latency or memory usage.

---

# 6. Data Structures and CPU Efficiency

## 6.1 Container selection

Evaluate whether containers match their access patterns.

Inspect:

- Arrays.
- Lists.
- Vectors.
- Linked lists.
- Hash maps.
- Trees.
- Sets.
- Queues.
- Priority queues.
- Graph representations.
- Custom containers.

Consider lookup, insertion, deletion, iteration, and memory locality.

## 6.2 Cache locality

Identify pointer-heavy structures that cause excessive cache misses.

Examples:

- Linked lists.
- Trees with individually allocated nodes.
- Large object graphs.
- Nested dictionaries.
- Scattered heap allocations.

Consider contiguous arrays, flat structures, and compact indexing.

## 6.3 Data layout

Evaluate:

- Array-of-structures versus structure-of-arrays.
- Field ordering.
- Object size.
- Cache-line utilization.
- Alignment.
- Hot versus cold fields.
- Redundant indirection.
- Data access patterns.

Consider separating frequently accessed fields from rarely used metadata.

## 6.4 Excessive indirection

Look for repeated pointer chasing.

Examples:

- Multiple wrapper objects.
- Deep inheritance hierarchies.
- Chains of references.
- Indirect lookup tables.
- Object graphs used for simple numeric state.

Evaluate whether direct indexing or compact representations improve locality.

## 6.5 Hashing overhead

Inspect high-frequency hash map operations.

Look for:

- Repeated hashing of the same keys.
- Expensive string keys.
- Poor hash distribution.
- Excessive collisions.
- Repeated key construction.
- Multiple hash lookups for one operation.
- Unnecessary dictionary use for small datasets.

Consider cached hashes, compact identifiers, or direct indexing when appropriate.

## 6.6 Collection enumeration

Identify repeated enumeration of expensive or lazy sequences.

Look for:

- Repeated LINQ evaluation.
- Multiple passes over generators.
- Repeated filtering.
- Repeated projection.
- Repeated aggregate calculations.
- Unnecessary materialization.

Evaluate whether combining operations or materializing once would reduce CPU work.

---

# 7. Memory-Related CPU Waste

## 7.1 Excessive allocation

Identify allocation hotspots.

Even when allocations do not significantly increase retained RAM, they can consume CPU through:

- Allocator overhead.
- Object initialization.
- Garbage collection.
- Reference tracking.
- Cache pollution.
- Memory zeroing.
- Fragmentation management.

Inspect tight loops and frequently executed code paths.

## 7.2 Unnecessary copying

Look for:

- Array copies.
- String copies.
- Collection cloning.
- Deep copies.
- Serialization round trips.
- Temporary buffers.
- Repeated conversions.
- Full-state snapshots.

Estimate the CPU cost of copying.

Consider views, slices, shared immutable structures, or ownership transfer.

## 7.3 Garbage collection overhead

For managed runtimes, identify allocation patterns causing excessive GC activity.

Measure:

- GC CPU percentage.
- Collection frequency.
- Allocation rate.
- Promotion rates.
- Pause times.
- Heap scanning cost.

Avoid recommending manual garbage collection as a general optimization.

## 7.4 Excessive initialization

Inspect large allocations that are immediately filled or overwritten.

Determine whether unnecessary initialization or clearing can be avoided safely.

## 7.5 Data movement

Find algorithms that move large quantities of memory unnecessarily.

Examples:

- Repeated compaction.
- Repeated array shifting.
- Repeated buffer copying.
- Rebuilding collections.
- Sorting large objects instead of compact references or indices.

Evaluate memory bandwidth and cache effects.

## 7.6 Pooling overhead

Investigate whether object pools actually improve performance.

Pools can introduce:

- Synchronization.
- Cache contention.
- Reset costs.
- Increased memory retention.
- More complex ownership.

Recommend pooling only when measured benefits justify it.

---

# 8. Concurrency and Parallelism

## 8.1 Excessive thread creation

Identify unnecessary thread or task creation.

Inspect:

- Short-lived threads.
- Excessively granular tasks.
- Thread pool misuse.
- Per-request thread creation.
- Unbounded worker creation.
- Excessive asynchronous continuations.

Evaluate scheduling overhead relative to useful work.

## 8.2 Context switching

Identify workloads with excessive context switches.

Investigate:

- Oversubscription.
- Blocking operations.
- Excessive task granularity.
- Frequent synchronization.
- Producer-consumer imbalance.
- Too many runnable threads.

## 8.3 Lock contention

Inspect frequently acquired locks.

Measure or estimate:

- Lock acquisition frequency.
- Contention rate.
- Critical-section duration.
- Time spent blocked.
- Time spent spinning.
- Number of competing threads.

Consider reducing lock scope, batching operations, partitioning state, or using appropriate concurrent structures.

## 8.4 Spin loops and busy waiting

Identify:

- Polling loops without appropriate waits.
- Repeated status checks.
- Spinlocks under prolonged contention.
- Retry loops without backoff.
- Background workers continuously checking queues.
- Timers firing unnecessarily.

These are particularly important sources of wasted CPU.

Evaluate event-driven waiting, blocking primitives, and bounded backoff.

## 8.5 False sharing

Inspect frequently modified fields accessed by different threads.

Determine whether independent variables occupy the same cache line, causing unnecessary cache coherence traffic.

Consider alignment or padding only when supported by profiling or strong evidence.

## 8.6 Atomic operation overhead

Identify excessive use of:

- Atomic increments.
- Compare-and-swap loops.
- Memory fences.
- Interlocked operations.
- Shared counters.
- Global synchronization points.

Consider thread-local accumulation or batched updates.

Preserve memory ordering and correctness.

## 8.7 Parallel overhead

Determine whether parallelism costs more than it saves for small workloads.

Inspect:

- Task startup.
- Scheduling.
- Synchronization.
- Data partitioning.
- Result merging.
- Shared-state contention.
- Memory bandwidth saturation.

Recommend workload-dependent parallelism thresholds where appropriate.

## 8.8 Work imbalance

Identify situations where some workers are overloaded while others are idle.

Evaluate partitioning strategies, work stealing, and scheduling.

Distinguish load imbalance from CPU inefficiency: improving wall-clock time may not reduce total CPU time.

## 8.9 Duplicate parallel work

Look for workers independently performing identical preprocessing, initialization, parsing, or computation.

Determine whether immutable results can be shared.

---

# 9. Idle CPU and Background Activity

## 9.1 Idle-state analysis

Determine whether the application consumes CPU when no useful work is available.

Inspect:

- Background loops.
- Polling.
- Timers.
- Watchdog threads.
- Monitoring systems.
- Status refreshes.
- Queue consumers.
- UI update loops.
- Periodic scans.

Identify unnecessary wakeups.

## 9.2 Polling frequency

Find components checking for changes more frequently than necessary.

Evaluate:

- Event-driven notifications.
- Adaptive polling.
- Longer intervals.
- Change detection.
- Debouncing.
- Coalescing.

## 9.3 Timer proliferation

Identify large numbers of timers performing overlapping or unnecessary work.

Consider centralized scheduling where appropriate.

## 9.4 Repeated background maintenance

Inspect periodic operations such as:

- Cache cleanup.
- Statistics aggregation.
- File scanning.
- Health checks.
- State reconciliation.
- Metrics collection.

Determine whether they perform expensive work even when nothing has changed.

## 9.5 Unnecessary refreshes

Look for repeated recomputation or rendering of unchanged state.

Investigate invalidation tracking and incremental updates.

---

# 10. Parsing, Serialization, and Data Conversion

## 10.1 Repeated parsing

Identify repeated parsing of unchanged input.

Examples:

- JSON.
- XML.
- CSV.
- Configuration files.
- Regular expressions.
- Source code.
- Binary protocols.
- Date and time formats.

Evaluate reuse of parsed representations or compiled parsers.

## 10.2 Serialization round trips

Find workflows that serialize and immediately deserialize data solely for copying, conversion, or transport between internal components.

Evaluate direct transformations.

## 10.3 String processing

Inspect:

- Repeated concatenation.
- Repeated formatting.
- Regular expressions.
- Substring creation.
- Encoding conversion.
- Case normalization.
- Tokenization.
- Path manipulation.

Look for unnecessary intermediate strings and repeated scans.

## 10.4 Regular expression efficiency

Investigate:

- Recompiling expressions.
- Catastrophic backtracking.
- Repeated matching against unchanged data.
- Regex use for simple substring checks.
- Unnecessarily complex patterns.

## 10.5 Data conversion chains

Trace transformations such as:

`Bytes → string → parsed objects → normalized objects → serialized bytes`

Determine whether intermediate conversions can be eliminated.

## 10.6 Partial processing

Identify cases where complete documents are parsed or transformed when only a small portion is needed.

Evaluate selective parsing and streaming.

---

# 11. I/O and System-Call Overhead

## 11.1 Excessive system calls

Look for high-frequency:

- File reads.
- File writes.
- Metadata queries.
- Clock queries.
- Process queries.
- Network operations.
- Handle operations.
- Synchronization calls.

Evaluate batching and caching where safe.

## 11.2 Small I/O operations

Identify repeated tiny reads or writes.

Consider buffering.

## 11.3 Redundant I/O

Find repeated reads of unchanged data.

Determine whether reuse or caching would reduce CPU and I/O overhead.

## 11.4 Excessive logging

Inspect logging inside hot paths.

Look for:

- Expensive formatting.
- Stack trace construction.
- Serialization.
- Synchronous writes.
- Lock contention.
- Repeated timestamps.
- Large diagnostic payloads.

Evaluate lazy formatting, structured logging, and appropriate log levels.

## 11.5 Unnecessary polling of external resources

Identify repeated file-system, network, or process-status checks that could be event-driven.

## 11.6 I/O versus CPU bottlenecks

Do not misclassify time waiting for I/O as CPU consumption.

Distinguish blocked wall-clock time from active processor time.

---

# 12. CPU Cache, Memory Bandwidth, and Hardware Efficiency

## 12.1 Cache miss analysis

Where profiling supports it, inspect:

- L1 cache misses.
- L2 cache misses.
- Last-level cache misses.
- Cache miss rates.
- Memory access latency.
- Data locality.
- Instruction cache pressure.

## 12.2 Memory bandwidth

Identify workloads limited by moving data rather than performing calculations.

Examples:

- Large array scans.
- Repeated copies.
- Poorly structured matrix operations.
- Large state transformations.
- Excessive memory initialization.

Consider reducing data movement before introducing more threads.

## 12.3 Branch prediction

Inspect unpredictable branches in hot loops.

Evaluate whether data ordering, specialization, or alternate algorithms could help.

## 12.4 Instruction count

Identify code performing substantially more instructions than necessary.

Consider:

- Redundant checks.
- Repeated conversions.
- Expensive abstraction.
- Unnecessary calls.
- Repeated address calculations.
- Inefficient arithmetic.
- Excessive object traversal.

## 12.5 Vectorization

Investigate data-parallel loops suitable for SIMD or compiler auto-vectorization.

Examples:

- Numeric arrays.
- Image processing.
- Signal processing.
- Bit operations.
- Bulk comparisons.
- Statistical calculations.

Consider data alignment, contiguous storage, and dependency chains.

Do not recommend SIMD unless the workload and target platforms justify it.

## 12.6 Instruction-level parallelism

Identify unnecessary dependency chains that prevent efficient CPU execution.

Evaluate alternative formulations only for significant hotspots.

## 12.7 Expensive arithmetic

Inspect high-frequency:

- Division.
- Modulo.
- Floating-point transcendental functions.
- Exponentiation.
- Square roots.
- Integer conversions.
- Arbitrary-precision arithmetic.

Consider mathematically equivalent alternatives where safe.

Avoid unsafe approximations without explicit accuracy requirements.

---

# 13. Compiler, Runtime, and Language-Specific Inefficiencies

## 13.1 Compiler optimization opportunities

Investigate whether important hot paths are inhibited by:

- Dynamic dispatch.
- Aliasing.
- Complex control flow.
- Escaping objects.
- Unnecessary abstraction.
- Poor data layout.
- Unpredictable branches.

Verify compiler-generated behavior where practical.

## 13.2 Debug versus release builds

Ensure benchmarks use appropriate optimized builds.

Do not mistake debug-build overhead for production inefficiency.

## 13.3 C# and .NET

Inspect:

- LINQ inside hot loops.
- Repeated enumeration.
- Boxing and unboxing.
- Delegate allocations.
- Closure captures.
- Virtual dispatch.
- Interface dispatch.
- Reflection.
- Dynamic invocation.
- Repeated property calculations.
- `ToArray()` and `ToList()` calls.
- `StringBuilder` usage.
- `Span<T>` opportunities.
- `Memory<T>` usage.
- `ArrayPool<T>` behavior.
- `Dictionary<TKey,TValue>` lookup patterns.
- `TryGetValue()` opportunities.
- `ContainsKey()` followed by indexing.
- Async state-machine overhead.
- Unnecessary `Task.Run()`.
- Excessive task creation.
- `ValueTask` opportunities where justified.
- Garbage collection CPU consumption.
- Large structure copying.
- Unnecessary exception construction.
- Repeated serialization.
- Per-item logging.

Use profiling and benchmarks to determine whether proposed micro-optimizations are meaningful.

## 13.4 C and C++

Inspect:

- Unnecessary copies.
- Pass-by-value of large objects.
- Missed move opportunities.
- Repeated allocations.
- Virtual dispatch in hot paths.
- Pointer-heavy containers.
- Iterator inefficiencies.
- Poor cache locality.
- Excessive reference counting.
- Repeated dynamic casts.
- Inefficient string construction.
- Compiler vectorization barriers.
- False sharing.
- Lock contention.
- Unnecessary atomic operations.
- Poorly sized work units.
- Excessive template-generated code where instruction-cache pressure is measurable.

## 13.5 Python

Inspect:

- Python-level loops over large numeric datasets.
- Repeated object construction.
- Inefficient comprehensions.
- Repeated dictionary lookups.
- Pandas row iteration.
- NumPy array copying.
- Repeated dataframe transformations.
- Excessive serialization.
- Multiprocessing overhead.
- Pickling.
- Repeated imports in hot paths.
- Inefficient regular expressions.
- Excessive function calls.
- Workloads suitable for vectorization or compiled extensions.

## 13.6 JavaScript and TypeScript

Inspect:

- Repeated object allocation.
- Unnecessary array transformations.
- Repeated filtering and mapping.
- Expensive JSON conversions.
- Excessive promise creation.
- Event-loop polling.
- Repeated DOM updates where applicable.
- Expensive getters.
- Hidden-class instability.
- Megamorphic access patterns.
- Worker communication overhead.

## 13.7 Java

Inspect:

- Boxing.
- Stream pipeline overhead.
- Reflection.
- Repeated object allocation.
- Collection traversal.
- Virtual dispatch.
- Garbage collection overhead.
- Synchronization.
- Thread-local retention.
- Serialization.
- Unnecessary temporary objects.

## 13.8 Rust

Inspect:

- Excessive cloning.
- Reference-counting overhead.
- Lock contention.
- Iterator materialization.
- Heap allocation in hot paths.
- Unnecessary dynamic dispatch.
- Data layout.
- Repeated conversions.
- Async task overhead.

## 13.9 Go

Inspect:

- Interface boxing.
- Escaping allocations.
- Reflection.
- Goroutine scheduling.
- Channel overhead.
- Lock contention.
- Map operations.
- String conversions.
- Garbage collection CPU usage.
- Excessive temporary slices.
- Repeated serialization.

## 13.10 Runtime configuration

Check the runtime and build configuration as well as the code. These settings change CPU use across the whole program and are easy to miss in a source review:

- JIT tiering and profile-guided optimization (for example .NET tiered compilation and dynamic PGO, or JVM tiered compilation), which can recompile hot code on many threads at once.
- Ahead-of-time or ready-to-run compilation versus JIT, especially for short-lived or start-up-heavy processes.
- Garbage collector mode (workstation versus server, concurrent, heap-count settings).
- Thread-pool minimum and maximum sizes.
- Compiler optimization level, link-time optimization, and target-CPU flags for native code.

Measure each setting on both a small and a large workload; some help long runs and hurt short ones.

---

# 14. Simulation, Search, and Computational Workloads

Apply especially to simulators, game engines, optimization systems, search tools, and numerical applications.

## 14.1 State evaluation

Identify repeated evaluation of unchanged or partially changed state.

Determine whether incremental scoring is possible.

Examples:

- Recalculating complete scores after one small change.
- Re-evaluating unchanged entities.
- Recomputing legal actions unnecessarily.
- Rebuilding derived state for each candidate.

## 14.2 Full-state copying

Inspect algorithms that clone complete state before evaluating alternatives.

Evaluate:

- Apply-and-undo.
- Delta state.
- Immutable sharing.
- Copy-on-write.
- Compact state representation.
- Incremental updates.
- Reusable scratch state.

Measure whether copying dominates total CPU time.

## 14.3 Search-tree inefficiencies

Investigate:

- Repeated exploration of equivalent states.
- Redundant branches.
- Duplicate candidate generation.
- Inefficient pruning.
- Repeated evaluation.
- Excessive search depth.
- Unnecessary full-state reconstruction.

Consider transposition tables, memoization, pruning, and state canonicalization.

Account for RAM tradeoffs.

## 14.4 Monte Carlo workloads

Inspect:

- Random number generation.
- State initialization.
- Simulation reset.
- Candidate selection.
- Result aggregation.
- Duplicate rollout work.
- Repeated preprocessing.
- Excessive per-simulation allocation.

Evaluate CPU time per simulation and per useful result.

## 14.5 Random number generation

Identify unnecessarily expensive RNG usage.

Determine whether random generators are repeatedly initialized or synchronized.

Preserve required statistical properties, reproducibility, and security requirements.

Never substitute a noncryptographic RNG where cryptographic randomness is required.

## 14.6 Incremental state updates

Identify computations where a small action causes complete recalculation.

Examples:

- Updating game state.
- Recomputing available actions.
- Updating scores.
- Rebuilding dependency information.
- Recalculating aggregate statistics.

Consider maintaining compact derived state incrementally.

## 14.7 Candidate generation

Determine whether algorithms generate many candidates that are immediately rejected.

Evaluate earlier filtering and constraint propagation.

## 14.8 Search termination

Inspect whether search continues after reaching a sufficient confidence, quality, or solution threshold.

Any approximate or early-termination strategy must respect explicitly defined correctness and quality requirements.

---

# 15. Database and Query Efficiency

Where applicable, inspect:

- Repeated queries.
- N+1 query patterns.
- Missing indexes.
- Duplicate result processing.
- Excessive object materialization.
- Repeated filtering after retrieval.
- Unnecessary sorting.
- Unbounded result sets.
- Repeated joins.
- Inefficient query construction.
- Repeated connection setup.

Distinguish CPU consumed by the application from CPU consumed by an external database server.

Consider total system CPU cost when relevant.

---

# 16. Rendering, UI, and Event Processing

Where applicable, inspect:

- Unnecessary redraws.
- Repeated layout calculations.
- Repeated data binding.
- Excessive event processing.
- Redundant state updates.
- Repeated formatting.
- Expensive UI-thread computations.
- Polling-based refresh.
- Unnecessary animation updates.
- Repeated construction of visual elements.

Evaluate dirty-region updates, event coalescing, and incremental rendering.

Preserve responsiveness and correct event ordering.

---

# 17. Logging, Metrics, and Instrumentation

Identify CPU spent on:

- Debug logging.
- Metrics collection.
- Tracing.
- Profiling.
- Statistics aggregation.
- Stack trace generation.
- Diagnostic serialization.
- High-cardinality metric labels.
- Repeated status sampling.

Determine whether diagnostics perform expensive work when disabled.

Evaluate sampling, batching, and deferred formatting.

Do not recommend removing essential observability without an acceptable replacement.

---

# 18. Initialization and Startup CPU

Investigate unnecessary startup work.

Examples:

- Rebuilding unchanged indexes.
- Parsing configuration repeatedly.
- Initializing unused subsystems.
- Scanning entire directories unnecessarily.
- Loading optional features.
- Precomputing data never used.
- Duplicate dependency initialization.
- Repeated environment detection.

Evaluate lazy initialization and persistent derived-data reuse.

Distinguish reducing startup CPU from shifting that work into the first request.

---

# 19. Long-Running CPU Behavior

Analyze whether CPU efficiency degrades over time.

Look for:

- Growing collections causing slower scans.
- Increasing cache maintenance cost.
- Accumulated background tasks.
- Repeated timers.
- Duplicate event subscriptions.
- Increasing garbage collection overhead.
- Larger search spaces.
- Unbounded retry loops.
- Progressive fragmentation affecting locality.
- Repeated rebuilding of historical state.

Compare CPU cost per operation early and late in a long-running session.

---

# 20. Common Suspicious Patterns

Systematically search for:

- Nested loops over large collections.
- Repeated linear searches.
- Repeated sorting.
- Repeated parsing.
- Repeated serialization.
- Repeated normalization.
- Repeated hashing.
- Duplicate validation.
- Full-state cloning.
- Repeated deep copies.
- Expensive operations inside tight loops.
- Allocations inside hot loops.
- Repeated temporary collection creation.
- Multiple passes over the same data.
- Busy-wait loops.
- Excessive polling.
- Timers with short intervals.
- Unbounded retries.
- Frequent lock acquisition.
- Excessive atomic operations.
- Per-item system calls.
- Per-item logging.
- Repeated reflection.
- Dynamic dispatch in critical paths.
- Duplicate background work.
- Repeated cache rebuilding.
- Repeated full-dataset processing.
- Excessive task creation.
- Very small parallel work units.
- Repeated computation after minor state changes.
- Large-scale pointer chasing.
- Poor cache locality.
- Unnecessary data conversion.
- Redundant result construction.
- Work performed for disabled features.
- Expensive work whose result is discarded.

These are investigation targets, not automatic findings.

Every suspected issue must be evaluated in context.

---

# 21. Required Investigation Procedure

All seven steps below are part of Phase 1 (audit); do not change code while working through them.

## Before Step 1: Organize the audit

- For a large codebase, review it area by area (for example input, core algorithm, storage, output, interfaces) so coverage is complete and does not overlap, and keep each area's findings in its own file.
- Give every finding a stable ID (for example an area prefix and a number) and keep it unchanged through Phase 2, commit messages, and later reviews.
- Mark every finding **CONFIRMED**, with the exact reproducer or measurement (input, command, observed output), or **HYPOTHESIS**. Never fix a hypothesis blind; if it cannot be reproduced here, leave it as a hypothesis and say what would confirm it.
- Merge the area findings into one ranked report, and re-check every Critical and High finding against the code before ranking it.
- Write the findings files and the merged report to a durable location (the repository's docs folder, or another fixed path the user agrees to), never a temporary or session folder, so they survive the session ending and context compactions.

**Profile first.** Before the source review (Step 3), take one measured run of a representative workload that reports CPU time, wall time, and allocations per phase or subsystem. Use it to aim the review and to rank findings: a finding's priority is the measured share of the run spent where it applies multiplied by the reduction expected there, not how bad the code looks. A finding in a phase that takes under about 5% of a realistic run is Low regardless of its complexity, and may be deferred with the measured share as the reason. If no run is possible, say so and label every ranking an estimate.

## 21.1 Step 1: Architecture and workload inventory

1. Map the application architecture.
2. Identify computationally intensive subsystems.
3. Identify major algorithms.
4. Identify high-frequency execution paths.
5. Identify background workers.
6. Identify parallel execution.
7. Identify synchronization points.
8. Identify major parsing and serialization paths.
9. Identify allocation-heavy operations.
10. Identify startup and idle activity.

Produce an overview of where CPU time is likely consumed.

## 21.2 Step 2: Establish measurements

Where practical:

1. Select representative workloads.
2. Measure baseline CPU time.
3. Measure wall-clock time.
4. Measure throughput.
5. Capture CPU profiles.
6. Identify dominant call stacks.
7. Record invocation counts.
8. Record allocation and GC overhead.
9. Measure idle CPU usage.
10. Capture hardware performance counters where available.

Use sampling profilers for broad discovery and instrumentation where precise counts are needed.

Avoid relying exclusively on wall-clock timing.

## 21.3 Step 3: Systematic source review

Review every relevant module.

For each module, investigate:

- Algorithmic complexity.
- Repeated work.
- Hot loops.
- Data structure selection.
- Allocation overhead.
- Synchronization.
- Concurrency.
- Caching.
- Parsing.
- Serialization.
- Background activity.
- Error and retry paths.

Maintain a persistent coverage ledger.

## 21.4 Step 4: Cross-component analysis

Investigate inefficiencies spanning multiple modules.

Examples:

- Duplicate preprocessing.
- Repeated parsing between layers.
- Redundant state reconstruction.
- Repeated validation.
- Duplicate cache population.
- Multiple workers repeating identical computation.
- Data converted repeatedly between representations.

Trace complete execution paths.

## 21.5 Step 5: Quantitative analysis

For each significant finding:

1. Identify the waste mechanism.
2. Determine execution frequency.
3. Estimate per-execution cost.
4. Estimate total CPU impact.
5. Identify the relevant workload.
6. Recommend a concrete change.
7. Evaluate RAM tradeoffs.
8. Evaluate correctness risks.
9. Define validation measurements.

## 21.6 Step 6: Prioritization

Rank findings by:

- Expected total CPU savings.
- Expected throughput improvement.
- Confidence.
- Implementation effort.
- Correctness risk.
- Memory impact.
- Maintainability.
- Applicability across workloads.

Prioritize high-impact, low-risk changes.

## 21.7 Step 7: Completeness pass

Revisit:

- Cross-module duplication.
- Hot loops.
- Algorithmic complexity.
- Idle CPU.
- Concurrency overhead.
- Allocation overhead.
- Cache locality.
- Long-running behavior.
- Failure paths.
- Hidden repeated computation.

Do not stop after finding the obvious bottlenecks.

---

# 22. Finding Classification

## Critical

Examples:

- Infinite or uncontrolled CPU-consuming loops.
- Severe algorithmic complexity problems.
- CPU saturation caused by unnecessary work.
- Unbounded retry storms.
- Major duplicate computation across workers.
- Pathological performance under normal workloads.

## High

Examples:

- Major repeated computation.
- Expensive full-state copying.
- Significant lock contention.
- Large algorithmic inefficiencies.
- Excessive background polling.
- Major allocation or garbage collection overhead.

## Medium

Examples:

- Repeated collection scans.
- Inefficient data structures.
- Moderate parsing overhead.
- Unnecessary intermediate transformations.
- Frequent small allocations.
- Avoidable synchronization.

## Low

Examples:

- Minor loop inefficiencies.
- Small redundant calculations.
- Low-frequency unnecessary conversions.
- Limited-scope micro-optimizations.

Severity must reflect demonstrated or credibly estimated impact.

---

# 23. Required Finding Format

For every finding, provide:

**Finding ID:** Unique identifier.

**Title:** Concise description.

**Severity:** Critical / High / Medium / Low.

**Confidence:** High / Medium / Low.

**Location:** File, function, class, and relevant line numbers.

**Category:** Algorithm, duplication, loop, allocation, synchronization, concurrency, cache locality, parsing, I/O, idle CPU, or other.

**Current behavior:** Explain precisely what the code does.

**Why CPU is wasted:** Identify unnecessary operations or inefficient execution.

**Evidence:** Cite source code, profiling data, invocation counts, or benchmarks.

**Execution frequency:** Estimate how often the inefficient operation occurs.

**CPU impact:** Estimate total CPU cost and percentage of relevant workload time.

**Recommended change:** Describe a concrete implementation approach.

**Expected benefit:** Estimate CPU time reduction, throughput improvement, or latency reduction.

**RAM impact:** Explain whether the optimization increases or decreases memory consumption.

**Tradeoffs:** Describe complexity, latency, concurrency, and maintenance costs.

**Correctness risks:** Identify semantic, numerical, ordering, or concurrency risks.

**Validation plan:** Specify how to prove correctness and measure the benefit.

**Change type:** What the recommended fix would change, judged from the code rather than impression: on-disk or saved format / public API / documented behavior / none. One or more may apply.

**Observable output changes:** Anything a user or a downstream tool would see change even when results stay correct: ordering, counts, wording, output layout. Write "none" if there are none.

**Expected work removed:** The fraction of the targeted work the recommended change should remove, and a cheap way to check that before building the full fix (for example, a temporary counter of how many items the new path would still process). Note any work the new design repeats per key, item, or group, which can cost more than it saves.

**Dependencies:** Identify related findings or prerequisite changes.

Do not produce vague recommendations such as "optimize this loop" or "use a faster algorithm."

Every finding must identify a concrete mechanism and actionable improvement.

---

# 24. Required Final Report

## A. Executive Summary

Include:

- Overall assessment of CPU efficiency.
- Largest sources of wasted computation.
- Most promising optimization opportunities.
- Major CPU performance risks.
- Confidence in conclusions.
- Limitations of available evidence.

## B. CPU Architecture Overview

Describe:

- Major computational subsystems.
- Dominant algorithms.
- High-frequency execution paths.
- Background CPU consumers.
- Parallel execution architecture.
- Synchronization hotspots.
- Major data transformations.

## C. Ranked Findings

Provide a table:

| Rank | Finding | Severity | Estimated CPU Savings | Confidence | Effort | Risk |
|---|---|---|---|---|---|---|

Order primarily by practical impact.

Do not add overlapping speedup estimates together.

End the ranked findings with a triage:

- **Ship now:** the top one to three findings by measured value and risk. Phase 2 fixes, proves, and releases these first.
- **Backlog:** the rest, in rank order, with a cut line — the point below which the expected saving (for example under a few percent of the run) does not justify the work. Findings below the cut line are deferred, not fixed.

For each ship-now finding, name the cheapest proxy metric that shows whether a fix works (a count of items processed, filtered, allocated, or retained, not a full-run time) and the output-equivalence check that proves the fix changes no results.

## D. Detailed Findings

Provide the complete finding format from Section 23 for every meaningful issue.

## E. Quick Wins

Identify changes that:

- Require limited code changes.
- Have low correctness risk.
- Offer credible CPU savings.
- Are straightforward to validate.

## F. Major Architectural Opportunities

Identify larger changes such as:

- Incremental computation.
- Elimination of duplicate processing.
- Compact simulation state.
- Improved algorithms.
- Reduced synchronization.
- Better data locality.
- More efficient task scheduling.
- Elimination of polling.
- Improved workload partitioning.

## G. CPU Savings Estimate

Provide:

- Estimated total CPU-time reduction.
- Estimated throughput improvement.
- Estimated latency improvement.
- Estimated idle CPU reduction.
- Confidence ranges.
- Assumptions.
- Interactions between findings.

Separate measured improvements from theoretical estimates.

Present this in two parts:

- **Phase 1 estimates:** the projected savings written at audit time, before any code changed.
- **Phase 2 measured results:** the before/after numbers actually obtained for the fixes applied (see section K), with fixes labeled "unmeasured" kept separate from measured ones.

Do not overwrite the Phase 1 estimates with the Phase 2 results; keeping both shows how accurate the estimates were.

## H. Benchmark and Validation Plan

Describe:

- Representative workloads.
- Baseline metrics.
- Profiling tools.
- Measurement methodology.
- Correctness tests.
- Regression tests.
- Before-and-after comparisons.

## I. Coverage Report

List:

- Modules reviewed.
- Important files reviewed.
- Subsystems reviewed.
- Performance categories investigated.
- Areas not fully analyzed.
- Reasons for incomplete coverage.

## J. Remaining Unknowns

Document issues requiring:

- Runtime profiling.
- Hardware counters.
- Production workload data.
- Long-duration testing.
- Concurrency testing.
- Additional architectural investigation.

## K. Fixes Applied

Written in Phase 2. For each finding ID, record:

- The fix made.
- The before/after measurement, or the regression test that proves the behavior is unchanged when no measurement was possible (label such fixes "unmeasured").
- Fixes implemented and then reverted because the measured gain was negligible or within noise.
- Findings deferred, with the reason (high risk, speculative, unverifiable, architectural, or behavior-changing).
- Anything discovered while fixing, including new findings and corrections to Phase 1 estimates.

Split the list into three groups and count them separately in any summary: **code fix**, **documentation only** (resolved by documenting the behavior rather than changing it), and **deferred**. Every deferred item carries the reviewer's recommendation, its estimated cost, and the decision needed from the user, not only the reason it was deferred.

## L. Changes to Documented Behavior

Written in Phase 2. List every change a user could notice: documented behavior, output ordering or format, public API, saved formats, defaults. For each, give the finding ID, what changed, and whether the user approved it. Write "none" if there are none.

---

# 25. Benchmarking Requirements

In Phase 2, validate every implemented optimization with:

1. Identical input workloads.
2. Identical correctness requirements.
3. Comparable hardware conditions.
4. Optimized release builds.
5. Runtime warmup where appropriate.
6. Multiple benchmark iterations.
7. CPU-time measurement.
8. Wall-clock measurement.
9. Throughput measurement.
10. Allocation and GC measurements where relevant.
11. Concurrency testing.
12. Regression testing.
13. Statistical assessment of measurement noise.
14. Comparison against the original implementation.

Avoid benchmarking under uncontrolled background load.

Account for:

- CPU frequency scaling.
- Thermal throttling.
- Processor affinity.
- JIT compilation.
- Runtime warmup.
- Garbage collection.
- File-system caching.
- Memory bandwidth.
- Operating system scheduling.
- Debugger and profiler overhead.

Benchmark protocol:

- Build the original and the changed version from separate git worktrees into separate output directories, and print each build's version or hash in the benchmark output, so a run can never silently compare a build with itself.
- Keep the built binary for every fix, so any two fixes can be compared later without rebuilding.
- Alternate old and new runs (A, B, A, B, …) for at least four rounds instead of running each back to back, and report the minimum, median, and spread. Back-to-back runs drift with background load.
- Prefer CPU time and operation counts over wall-clock time alone; wall time on I/O-heavy workloads is often noise.
- Include at least one small input, to expose start-up costs, and inputs shaped like each ranked finding, so every fixed finding is actually exercised.
- Check that results are identical before and after (output bytes, or counts of items processed, kept, and dropped).

Keep benchmarks and stress runs bounded in input size and duration. Write generated test data and benchmark output to a temporary location outside the repository, and delete it when finished.

A change is not automatically successful because a microbenchmark improves.

It must improve a meaningful application workload without unacceptable regressions.

---

# 26. Performance Tradeoff Requirements

For every recommendation, evaluate whether it:

- Reduces CPU time.
- Improves wall-clock time.
- Improves throughput.
- Reduces latency.
- Increases RAM usage.
- Increases allocation pressure.
- Increases synchronization.
- Reduces maintainability.
- Changes determinism.
- Changes numerical behavior.
- Adds caching complexity.
- Introduces concurrency hazards.

Explicitly identify optimizations that trade RAM for CPU.

Prefer changes that eliminate unnecessary work rather than merely move the cost elsewhere.

Do not recommend substantial memory increases for trivial CPU savings without justification.

---

# 27. Deep-Review Questions

After the initial analysis, deliberately challenge the findings.

Ask:

- Which function consumes the most total CPU time?
- Which function is called most frequently?
- Which operation has the highest CPU cost per useful result?
- Which algorithm has the worst scaling behavior?
- Which loops execute the most iterations?
- Which calculations are repeated with identical inputs?
- Which computations are performed but never used?
- Which components independently perform the same work?
- Which operations repeatedly scan large collections?
- Which algorithms rebuild results after small changes?
- Which operations cause the most allocations?
- Which code paths generate the most garbage collection work?
- Which locks consume the most CPU through contention or spinning?
- Which background tasks consume CPU while idle?
- Which system calls occur most frequently?
- Which data structures cause excessive cache misses?
- Which workloads are limited by memory bandwidth?
- Which branches are particularly unpredictable?
- Which operations prevent compiler optimization?
- Which tasks are too small to justify parallel execution?
- Which workers duplicate preprocessing or initialization?
- Which simulations repeat equivalent states?
- Which search algorithms fail to prune unnecessary branches?
- Which expensive computations could be performed incrementally?
- Which optimizations could improve both CPU and RAM?
- Which proposed optimizations merely shift work to another component?
- Which apparent bottlenecks are actually waiting for I/O?
- Which optimizations would matter at realistic workload sizes?
- Which improvements would remain valuable after other bottlenecks are fixed?
- What important CPU inefficiencies might a file-by-file review miss?

Investigate the answers before finalizing.

---

# 28. Review Quality Requirements

The review must be:

**Exhaustive:** Cover the entire relevant codebase.

**Evidence-based:** Separate confirmed problems from hypotheses.

**Quantitative:** Estimate CPU impact whenever practical.

**Specific:** Identify exact code locations and mechanisms.

**Correctness-conscious:** Preserve semantics and safety.

**Workload-aware:** Consider realistic execution patterns.

**Architecture-aware:** Investigate cross-component inefficiencies.

**Audit before fixing:** Do not change code until the Phase 1 report is complete.

**Prioritized:** Focus on the greatest achievable improvements.

**Honest about uncertainty:** Never invent measurements or speedups.

**Repeatable:** Document benchmarks and assumptions.

---

# 29. Stop Conditions and Completion Criteria

Do not stop merely because several significant findings have been discovered.

Continue until:

1. Every relevant subsystem has been reviewed.
2. Major algorithms have been examined.
3. High-frequency loops have been investigated.
4. Duplicate computation has been analyzed.
5. Major data structures have been evaluated.
6. Allocation-related CPU overhead has been considered.
7. Synchronization and concurrency have been reviewed.
8. Idle and background CPU usage has been investigated.
9. Parsing and serialization overhead has been examined.
10. I/O and system-call overhead has been considered.
11. Cache locality and data movement have been evaluated.
12. Cross-component inefficiencies have been investigated.
13. Long-running behavior has been considered.
14. Error and retry paths have been reviewed.
15. Findings have been prioritized.
16. A final completeness pass has been completed.
17. Remaining uncertainties have been documented.
18. Phase 2: the ship-now set has been fixed, verified, and released; the backlog has been fixed down to the cut line; every other finding has been reverted or deferred with a recommendation; and the Fixes Applied and Changes to Documented Behavior sections have been written.

If repository access, tooling, runtime measurements, or context limits prevent full coverage, document exactly what remains.

Maintain a persistent review ledger if the investigation spans multiple sessions or context compactions.

Do not repeatedly rediscover previously analyzed findings.

---

# 30. Phase 2 — Fix What the Audit Found

Only after the Phase 1 report is complete, fix the confirmed findings. Do not start fixing while still auditing — the complete, ranked list is what keeps effort on the highest-value problems instead of the first ones found.

Work in this order:

1. Fix, prove, and release the **ship-now** set from the triage first.
2. Then work down the backlog in rank order to the cut line, releasing in batches. Defer everything below it.

Close out each finding before starting the next: once it is proven, commit it, then move on. Do not start another finding while one is half-proven.

For each fix:

- If Phase 1 had no runtime baseline, first build a minimal benchmark for the target path so there is something to measure against. If that is impractical, apply only fixes whose benefit is clear from complexity on known-large inputs and whose behavior is proven by tests, and label them "unmeasured" in Fixes Applied.
- Keep benchmarks and stress runs bounded in input size and duration; write generated data and benchmark output to a temporary location outside the repository, and clean it up afterwards.
- Re-measure after the fix using the same baseline method as Phase 1 and record before/after numbers. If the measured gain is negligible or within noise, revert it and record that in the report.
- Confirm behavior is unchanged: the existing tests pass, and add a test wherever the optimization touches logic that is not already covered.
- Keep each fix small and focused; do not bundle unrelated changes.
- Prove equivalence before claiming anything is faster or smaller: output byte-identical to the original build on the benchmark inputs (ignoring run IDs and timestamps), and for internal changes an old-versus-new comparison on randomized inputs with a fixed seed. Counts of items processed, kept, and dropped must match.
- Iterate on the proxy metric named in the triage; time the full workload once the design works, not for every design iteration.
- Write the test first and see it fail on the unfixed code; a test that passes either way proves nothing. Where practical, also confirm it fails again when the fix is deliberately broken.
- Commit one finding (or one tightly coupled group) per commit, with the finding ID in the commit subject, so each fix can be reverted or bisected on its own. A commit is not a release: a release normally contains several finding commits.
- Run the targeted tests for the change after each fix. Run the full suite after each batch of three or four fixes and always before pushing or releasing; if a batch fails, bisect within it.
- After any scripted or bulk edit, run `git diff --stat` before building and check for surprises: 0-byte files, whole-file churn, line-ending or byte-order-mark changes.
- For a fix that changes what is processed or how (a filter, a skip, a cache, a new order, parallelism), run one pass on real, representative data early, not only at the end. Some failures only appear on real data shapes.
- Have each non-trivial fix reviewed independently (a second reviewer or a separate pass), aimed at the one way it could be wrong, for example whether a new skip can ever drop something that must be kept.
- If a related coverage gap is cheap to test (minutes), write the test instead of listing the gap.

Time-box surprises: if an unexpected result is worth chasing, spend at most about 30–45 minutes on it, then write up what was found and either add it as a new finding or defer it.

Keep the user informed: post one line when each fix lands and whenever a wait lasts longer than about five minutes, saying what is being waited on.

Finish with one run on the real, full-size workload, after asking the user, and record the result in Fixes Applied.

Do **not** implement findings that are high-risk, speculative, unproven, or that would require a broad architectural change or a change to the program's documented behavior. Leave those in the report as recommendations, with the reason they were deferred, the reviewer's recommended option, and its cost, so the user can decide without another round trip. Decisions that change documented behavior, a saved format, or a public API belong to the user.

When finished, update the report with the **Fixes Applied** section (section K of the final report) and the **Changes to Documented Behavior** section (L): what was fixed (with the before/after evidence or the regression test that proves it), what was deferred and why, and anything discovered while fixing.

---

# 31. Final Instruction

**Find wasted CPU, not merely slow code.**

Look for computation that should never have happened, work that should have been reused, algorithms that perform unnecessary operations, data structures that impose excessive processing overhead, and architectural decisions that multiply CPU consumption.

Pay particular attention to multiplicative waste.

A single unnecessary operation executed billions of times may consume more CPU than an obviously expensive function executed occasionally.

Likewise, a poor algorithmic decision can dominate execution time even when every individual instruction is highly optimized.

Prioritize eliminating entire categories of unnecessary work before attempting micro-optimizations.

Prefer:

- Avoiding computation over accelerating computation.
- Reusing valid results over recalculating them.
- Incremental updates over complete recomputation.
- Efficient algorithms over instruction-level tricks.
- Appropriate data structures over repeated searching.
- Event-driven execution over unnecessary polling.
- Better locality over pointer-heavy traversal.
- Reduced synchronization over increasingly complex locking.
- Evidence-based optimization over speculative changes.

The final deliverable must be the fixes applied in Phase 2 plus a comprehensive, evidence-supported, prioritized CPU optimization report containing concrete findings, estimated benefits, and actionable recommendations.

**Do not start fixing until the audit is complete, and do not fix what you cannot verify. Do not stop at obvious bottlenecks. Do not declare the review complete until the coverage and completeness requirements have been satisfied or remaining limitations have been explicitly documented.**