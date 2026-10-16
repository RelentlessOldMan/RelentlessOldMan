# Comprehensive RAM Efficiency Code Review Specification

## 1. Mission

Perform an exhaustive, systematic review of the entire codebase to identify every meaningful opportunity to reduce RAM consumption without compromising correctness, functionality, reliability, concurrency safety, or maintainability.

The primary objective is to identify **memory that is allocated, retained, duplicated, overprovisioned, or kept alive unnecessarily**.

Investigate both persistent memory consumption and transient memory spikes.

Do not limit the review to conventional memory leaks. Many of the largest opportunities involve memory that is technically reachable, correctly managed, and eventually released, but nevertheless wastes RAM.

Review all relevant source code, configuration, data structures, algorithms, caches, object lifetimes, resource management, and architectural decisions.

Be aggressive in identifying inefficiencies but conservative in recommending or making changes that might affect correctness.

This review has two phases. **Phase 1 — audit:** do not modify code until the audit is complete; produce a detailed, actionable report with supporting evidence, estimated savings, risk assessments, and validation recommendations. **Phase 2 — fix:** then fix the confirmed findings in priority order, with evidence for each (see the Phase 2 section near the end).

**Safety:** keep memory stress runs, soak tests, and large-workload benchmarks bounded (cap input sizes, iteration counts, concurrency, and run time) so they cannot exhaust the machine's RAM or drive it into heavy paging. Write any generated test data to a temporary directory and delete it when finished.

---

## 2. Core Review Principles

### 2.1 Distinguish memory consumption categories

Evaluate each of the following independently:

1. **Baseline memory:** Memory consumed when the application is initialized but idle.
2. **Steady-state memory:** Memory retained during normal sustained operation.
3. **Peak memory:** Maximum memory consumed during demanding operations.
4. **Transient allocation:** Short-lived allocations that create memory pressure.
5. **Retained memory:** Memory that remains reachable longer than necessary.
6. **Leaked memory:** Memory that is no longer useful but cannot be reclaimed.
7. **Reserved memory:** Memory reserved by allocators, runtimes, or containers but not necessarily committed.
8. **Committed memory:** Memory backed by the operating system.
9. **Resident memory:** Physical memory currently resident in RAM.
10. **Shared memory:** Memory shared across processes or mappings that must not be double-counted.
11. **Fragmentation overhead:** Memory unavailable for useful allocations because of allocation patterns.
12. **External memory:** Native allocations, GPU resources, memory-mapped files, and other memory outside the managed heap.

Do not conflate allocation volume with retained memory, virtual address space with physical RAM, or a runtime's reserved heap with actual memory waste.

### 2.2 Establish a baseline

Where execution and profiling are practical, determine:

- Idle resident memory.
- Private committed memory.
- Managed heap size, if applicable.
- Native heap usage.
- Peak working set or RSS.
- Memory usage during representative workloads.
- Allocation rate.
- Garbage collection frequency and pause time.
- Memory retained after workloads finish.
- Memory behavior after repeated operations.
- Memory growth over long-running sessions.
- Memory per active task, request, session, worker, or processed item.

Record the measurement environment and workload.

If runtime measurements are unavailable, perform static analysis and clearly label estimates as unverified.

### 2.3 Quantify findings

For every meaningful issue, attempt to estimate:

- Bytes wasted per instance.
- Typical number of instances.
- Maximum plausible number of instances.
- Total retained memory.
- Peak temporary memory.
- Allocation frequency.
- Estimated reduction from the proposed change.
- Whether the savings affect baseline, steady-state, peak, or allocation rate.

Use formulas where useful.

For example:

`Estimated waste = instance count × avoidable bytes per instance`

For duplicated data:

`Estimated waste = duplicate count × duplicated payload size`

For per-worker overhead:

`Estimated waste = worker count × unnecessary per-worker allocation`

Do not invent precise savings without sufficient evidence. Give bounded estimates and state assumptions.

### 2.4 Preserve correctness

Never recommend an optimization that silently changes:

- Observable program behavior.
- Data ownership.
- Object identity when identity matters.
- Thread safety.
- Lifetime requirements.
- Serialization compatibility.
- Ordering guarantees.
- Error handling.
- Resource disposal behavior.
- API contracts.
- Numerical precision.
- Data integrity.

A lower-memory implementation is not automatically better if it introduces significant CPU overhead, latency, contention, or complexity.

---

## 3. Object Lifetime and Retention Analysis

### 3.1 Unnecessarily long-lived objects

Find objects retained beyond their useful lifetime.

Inspect:

- Static and global references.
- Singleton instances.
- Long-lived service objects.
- Session state.
- Application-wide registries.
- Dependency injection containers.
- Event subscriptions.
- Callback registries.
- Task and thread references.
- Closures.
- Background workers.
- Queues.
- Caches.
- Debugging and diagnostic structures.

For each long-lived object, determine whether all referenced objects genuinely require the same lifetime.

Look for large object graphs retained by a single reference.

### 3.2 Accidental retention

Identify cases where small references keep large allocations alive.

Examples:

- A callback captures an entire service object.
- A closure captures a large collection unnecessarily.
- A task retains its input after processing.
- A completed request remains in a history collection.
- An event subscription prevents an object from being collected.
- A collection retains removed or inactive entities.
- A parent object retains obsolete child objects.
- A diagnostic structure retains complete input or output objects.

Trace retention chains to their roots.

### 3.3 Delayed cleanup

Inspect whether resources are released promptly after their last use.

Check:

- Temporary processing state.
- Completed jobs.
- Finished sessions.
- Canceled operations.
- Failed operations.
- Expired entries.
- Replaced configuration objects.
- Closed documents.
- Disconnected clients.
- Obsolete computation results.

Investigate cleanup that depends on unrelated future activity.

### 3.4 Hidden references

Look for references retained by:

- Timers.
- Delegates.
- Event handlers.
- Futures and promises.
- Async state machines.
- Thread-local storage.
- Continuations.
- Iterator objects.
- Generator state.
- Reactive subscriptions.
- Native callbacks.
- Interop handles.

Pay particular attention to objects retained across `await`, `yield`, or equivalent suspension points.

Determine whether large local variables remain reachable for longer than necessary.

---

## 4. Duplicate Data and Redundant Representations

### 4.1 Duplicate objects

Identify cases where logically identical data exists in multiple independently allocated objects.

Examples:

- Repeated configuration objects.
- Duplicate metadata.
- Repeated strings.
- Repeated lookup tables.
- Identical immutable structures.
- Duplicate parsed representations.
- Repeated copies of input data.
- Repeated cached results.

Determine whether immutable sharing, canonicalization, or interning is appropriate.

### 4.2 Multiple representations of the same data

Find situations where the application simultaneously retains:

- Raw bytes and decoded strings.
- JSON text and parsed objects.
- Serialized and deserialized forms.
- Compressed and decompressed data.
- Original and normalized records.
- Source data and derived structures.
- Mutable and immutable copies.
- Multiple indexed views of the same dataset.

Determine whether all representations must coexist.

Investigate whether one can be regenerated cheaply or discarded after conversion.

### 4.3 Unnecessary copying

Review:

- Array copies.
- List cloning.
- String copying.
- Buffer duplication.
- Collection conversions.
- Deep copies.
- Serialization round trips.
- Copy-on-write implementations.
- Defensive copying.
- Intermediate materialization.

Determine whether views, slices, spans, immutable sharing, or ownership transfer could safely eliminate copies.

Account for aliasing, mutation, and lifetime hazards.

### 4.4 Copy amplification

Identify workflows where data is repeatedly copied through several processing stages.

Trace the complete data path.

For example:

`Input → buffer → string → parsed object → normalized object → cache → output buffer`

Estimate peak simultaneous memory across the pipeline.

Look for ways to reduce the number of simultaneously live representations.

---

## 5. Collection and Container Efficiency

### 5.1 Excess collection capacity

Inspect all significant:

- Arrays.
- Dynamic arrays.
- Lists.
- Vectors.
- Hash maps.
- Dictionaries.
- Hash sets.
- Queues.
- Stacks.
- Trees.
- Graphs.
- Custom containers.

Compare capacity with actual element count.

Find collections with substantial unused capacity, especially long-lived collections.

Check whether capacity remains large after a temporary workload spike.

Evaluate whether shrinking, rebuilding, or more accurate initial sizing would help.

Avoid repeated resizing that introduces unnecessary allocation and copying.

### 5.2 Oversized initial capacities

Identify collections allocated for hypothetical worst-case workloads when actual usage is consistently much smaller.

Examples:

- Allocating space for thousands of elements when typical usage is dozens.
- Reserving maximum request sizes for every request.
- Creating large per-worker arrays that are rarely populated.
- Initializing lookup structures for features that are seldom used.

Recommend sizing based on measured workloads where appropriate.

### 5.3 Inefficient container choices

Evaluate whether each container matches its usage pattern.

Consider:

- Dense arrays instead of hash maps for compact integer keys.
- Vectors instead of linked lists.
- Flat arrays instead of pointer-heavy trees.
- Bitsets instead of boolean objects or hash sets.
- Sorted vectors instead of maps for small mostly static datasets.
- Compact integer-indexed tables instead of object-reference graphs.
- Sparse representations for genuinely sparse datasets.
- Dense representations where sparse-container metadata dominates.
- Struct-of-arrays versus array-of-structs layouts.

Consider lookup complexity, update frequency, ordering, and iteration performance.

### 5.4 Excessive per-element overhead

Identify structures where container overhead is large relative to payload size.

Inspect:

- Node allocations.
- Pointers.
- Hash buckets.
- Alignment padding.
- Object headers.
- Allocator metadata.
- Per-entry wrappers.
- Per-entry strings.
- Redundant keys.
- Per-element synchronization primitives.

Estimate overhead per element and multiply by actual cardinality.

### 5.5 Nested containers

Look for deeply nested collection structures that create many small allocations.

Examples:

- Dictionary of dictionaries.
- List of lists.
- Per-object hash sets.
- Trees of individually allocated nodes.
- Large collections of tiny collections.

Consider flattening, compact indexing, contiguous storage, or shared metadata.

### 5.6 Empty collections

Identify eagerly allocated empty containers.

Consider:

- Shared immutable empty instances.
- Lazy initialization.
- Null or sentinel representations where semantically safe.
- Compact representations for common empty states.

Pay special attention when millions of objects each own an empty collection.

### 5.7 Duplicate indexes

Identify multiple lookup structures that duplicate keys, references, or entire records.

Determine whether every index is necessary.

Evaluate memory-versus-query-speed tradeoffs.

---

## 6. Object Layout and Per-Instance Overhead

### 6.1 Large populations of small objects

Identify types instantiated in very large quantities.

For each significant type, inspect:

- Object header overhead.
- Field sizes.
- Reference fields.
- Alignment.
- Padding.
- Optional fields.
- Unused fields.
- Duplicate metadata.
- Nested allocations.
- Allocation count.

Estimate the total memory footprint of the population, including referenced objects.

### 6.2 Compact representations

Consider replacing:

- Object references with integer IDs.
- Large integer fields with smaller types when valid.
- Repeated strings with compact identifiers.
- Separate flags with bitfields.
- Multiple boolean objects with packed bits.
- Per-instance constants with shared constants.
- Optional objects with compact tagged representations.
- Sparse per-instance metadata with external side tables.

Validate range limits and compatibility.

### 6.3 Structure packing and alignment

For native structures and value types, examine:

- Field ordering.
- Alignment padding.
- Structure size.
- Array stride.
- Cache-line alignment.
- ABI requirements.
- Serialization layout.
- Interop compatibility.

Estimate savings from safe reordering or representation changes.

Do not recommend packed unaligned layouts without accounting for performance and platform constraints.

### 6.4 Overly general object models

Identify cases where a flexible, heavyweight object hierarchy is used for simple data.

Consider whether compact records, value types, arrays, or tagged unions could reduce overhead.

Evaluate the number of objects and references required to represent one logical entity.

### 6.5 Redundant fields

Find fields that:

- Duplicate other fields.
- Can be derived cheaply.
- Are constant for all instances.
- Are unused after initialization.
- Exist only for diagnostics.
- Represent mutually exclusive states inefficiently.
- Duplicate parent or shared metadata.

Determine whether they can be removed or relocated.

---

## 7. Strings and Text Processing

### 7.1 Repeated strings

Look for repeated:

- Names.
- Paths.
- Identifiers.
- Keys.
- Status values.
- Enum-like strings.
- Protocol fields.
- Metadata labels.

Determine whether shared immutable values or integer identifiers are appropriate.

Avoid unbounded global string interning.

### 7.2 Excessive string construction

Identify:

- Repeated concatenation.
- Temporary formatting.
- Repeated substring creation.
- Repeated normalization.
- Repeated encoding conversions.
- String construction in tight loops.
- Unnecessary `ToString()` or equivalent operations.

Evaluate allocation-free formatting, reusable builders, and slices where supported.

### 7.3 Text representation overhead

Inspect whether large quantities of text are stored inefficiently.

Consider:

- UTF-8 versus UTF-16 storage.
- Repeated prefixes.
- Duplicate path segments.
- Repeated tokens.
- Large strings retained for small substrings.
- Per-character objects.
- Excessively granular token structures.

Account for encoding requirements and access patterns.

### 7.4 Logging-related strings

Find expensive strings constructed even when logging is disabled.

Inspect whether logs retain:

- Entire requests.
- Full exception objects.
- Large stack traces.
- Serialized payloads.
- Complete data snapshots.

Prefer deferred formatting and bounded diagnostic retention.

---

## 8. Buffers and Temporary Memory

### 8.1 Oversized buffers

Identify buffers sized for rare maximum inputs rather than typical usage.

Inspect:

- File buffers.
- Network buffers.
- Serialization buffers.
- Compression buffers.
- Image buffers.
- Parsing buffers.
- Temporary computation buffers.
- Per-thread scratch memory.

Measure typical and peak utilization.

### 8.2 Simultaneously live buffers

Trace processing stages to determine whether multiple full-size buffers coexist unnecessarily.

Look for opportunities to:

- Stream data.
- Process in chunks.
- Reuse scratch buffers.
- Transfer ownership.
- Perform in-place transformations.
- Release prior-stage buffers earlier.

### 8.3 Buffer pooling

Evaluate whether frequently allocated temporary buffers would benefit from pooling.

Consider:

- Allocation frequency.
- Typical size distribution.
- Pool retention overhead.
- Maximum pool size.
- Concurrency.
- Memory pressure.
- Clearing sensitive contents.
- Correct return behavior.
- Use-after-return hazards.

Do not recommend pooling by default.

A pool that retains large buffers indefinitely may increase baseline memory substantially.

### 8.4 Stack versus heap allocation

For native code, inspect small, bounded, short-lived allocations.

Consider stack allocation when safe and appropriate.

Avoid large or input-controlled stack allocations.

### 8.5 Temporary arrays and intermediate results

Find algorithms that allocate complete intermediate arrays where incremental processing would suffice.

Investigate:

- Sorting.
- Filtering.
- Grouping.
- Mapping.
- Parsing.
- Graph traversal.
- Search.
- Aggregation.
- Batch transformations.

Estimate peak temporary memory, not just final output size.

---

## 9. Caches and Memoization

### 9.1 Cache inventory

Identify every cache, including implicit caches.

For each cache, document:

- Purpose.
- Key type.
- Value type.
- Maximum size.
- Eviction policy.
- Expiration policy.
- Average occupancy.
- Peak occupancy.
- Hit rate.
- Miss cost.
- Retained bytes.
- Concurrency behavior.
- Whether entries are duplicated elsewhere.

### 9.2 Unbounded caches

Flag caches without effective memory limits.

Investigate caches that grow with:

- User count.
- Session count.
- Unique inputs.
- File count.
- Request count.
- Generated identifiers.
- Historical computations.

Recommend bounded policies where appropriate.

### 9.3 Low-value cached entries

Identify entries that consume substantial memory but are rarely reused.

Consider eviction based on:

- Recency.
- Frequency.
- Entry size.
- Recalculation cost.
- Workload phase.
- Memory pressure.

A cache should justify its retained footprint.

### 9.4 Oversized cached values

Find caches storing complete objects when callers only need a small derived result.

Consider storing:

- Compact summaries.
- IDs.
- Precomputed scalar values.
- Compressed representations.
- References to canonical objects.

### 9.5 Duplicate caching

Identify multiple components caching identical or overlapping data.

Trace ownership and consistency requirements.

Determine whether sharing one cache is safe and beneficial.

### 9.6 Cache lifecycle

Inspect whether caches are cleared or reduced when:

- Projects close.
- Sessions end.
- Workloads complete.
- Configuration changes.
- Data becomes obsolete.
- Memory pressure increases.

### 9.7 Cache key overhead

Evaluate whether cache keys consume disproportionate memory.

Consider compact hashes or identifiers only when collisions are handled correctly.

### 9.8 Memoization explosions

Inspect recursive and dynamic-programming algorithms.

Determine whether memoization stores unnecessary states or retains them beyond the computation.

Estimate the theoretical and observed state-space size.

Consider bounded, scoped, or selective memoization.

---

## 10. Concurrency and Per-Worker Memory

### 10.1 Per-thread allocations

Inspect:

- Thread stacks.
- Thread-local buffers.
- Thread-local caches.
- Worker state.
- Per-thread contexts.
- Per-thread queues.
- Per-thread object pools.

Estimate memory as a function of worker count.

### 10.2 Excessive concurrency

Determine whether the number of simultaneous workers causes unnecessary multiplication of memory.

Examples:

- Each worker loads the same dataset.
- Each worker owns a large scratch buffer.
- Each worker maintains a duplicate cache.
- Each worker holds an entire request graph.
- Each worker independently initializes heavyweight services.

Consider shared immutable state, bounded concurrency, or worker reuse.

### 10.3 Queued work

Inspect queues for:

- Unbounded growth.
- Large queued payloads.
- Duplicate references.
- Work items retaining completed state.
- Missing backpressure.
- Slow consumers.
- Large batches accumulated before processing.

Estimate memory under producer-consumer imbalance.

### 10.4 Async operations

Find suspended tasks retaining large state.

Inspect:

- Captured locals.
- Pending futures.
- Continuations.
- Cancellation state.
- Timeouts.
- Retry queues.
- Exception retention.

Determine whether concurrency limits or smaller state objects could reduce peak memory.

### 10.5 Parallel algorithm memory amplification

Identify algorithms that replicate large state for each parallel branch.

Calculate:

`Peak memory ≈ shared state + concurrent branches × per-branch state`

Investigate immutable sharing, copy-on-write, compact deltas, and reduced branch concurrency.

---

## 11. Algorithmic Memory Complexity

### 11.1 Analyze space complexity

For each memory-intensive algorithm, determine:

- Auxiliary space complexity.
- Output space complexity.
- Peak live data.
- Recursion depth.
- Temporary allocations.
- State duplication.
- Scaling with input size.
- Scaling with concurrency.

Look for avoidable O(N²) or worse memory usage.

### 11.2 Full-state cloning

Pay special attention to algorithms that repeatedly clone complete application or simulation state.

Investigate whether copies can be replaced by:

- Immutable shared structures.
- Copy-on-write.
- Undo/redo logs.
- Transactional mutation.
- Delta state.
- Persistent data structures.
- Compact snapshots.
- Arena allocation.
- Reconstructible state.

Assess the correctness and implementation complexity of each approach.

### 11.3 Search and simulation workloads

Inspect:

- Search trees.
- Branch-and-bound.
- Monte Carlo simulations.
- Game-tree exploration.
- State-space search.
- Backtracking.
- Planning algorithms.
- Graph traversal.

Identify memory wasted by storing complete states, redundant histories, repeated metadata, or unnecessary parent-child copies.

Evaluate whether a compact state representation could reduce both RAM consumption and allocation pressure.

### 11.4 Batch processing

Determine whether entire datasets are loaded into memory when streaming or chunking would suffice.

Evaluate:

- Batch sizes.
- Intermediate collections.
- Result accumulation.
- Sorting requirements.
- Random-access requirements.
- Input/output overlap.

### 11.5 Recomputable data

Identify large retained derived structures that can be regenerated inexpensively.

Compare the memory saved against recomputation cost.

Avoid blindly trading substantial CPU time for small RAM reductions.

---

## 12. Managed Runtime and Garbage Collection

Apply this section when relevant to languages such as C#, Java, Go, JavaScript, or Python.

### 12.1 Allocation hotspots

Find frequently executed paths that allocate unnecessarily.

Inspect:

- Tight loops.
- LINQ or iterator pipelines.
- Closures.
- Delegates.
- Lambdas.
- Boxing.
- Temporary collections.
- Reflection.
- Serialization.
- Logging.
- Async state machines.
- Iterator state machines.

Distinguish allocation-rate reductions from actual retained-memory savings.

### 12.2 Large object allocations

Inspect allocations large enough to enter special large-object allocation regions where applicable.

Investigate:

- Large arrays.
- Large strings.
- Large temporary buffers.
- Repeated large allocations.
- Fragmentation.
- Pooling behavior.

### 12.3 Boxing and wrappers

Find cases where value types are unnecessarily boxed or wrapped in heap objects.

Evaluate generic alternatives and compact representations.

### 12.4 Garbage collection roots

Trace retained objects through:

- Static fields.
- Thread stacks.
- Runtime handles.
- Finalizer queues.
- Event handlers.
- Long-lived tasks.
- Interop references.

Distinguish legitimate retention from accidental retention.

### 12.5 Finalization and disposal

Inspect objects requiring deterministic cleanup.

Check whether finalizers, cleaners, or delayed disposal keep objects and resources alive unnecessarily.

### 12.6 Heap growth and reuse

Determine whether apparent memory growth is caused by:

- Actual live-object growth.
- Runtime heap expansion.
- Allocator reuse.
- Fragmentation.
- Delayed garbage collection.
- Large object retention.

Do not classify runtime-reserved memory as leaked without evidence.

### 12.7 Language-specific concerns

For C#/.NET, inspect:

- `List<T>` capacity.
- `Dictionary<TKey,TValue>` capacity.
- Boxing.
- Closure captures.
- Event subscriptions.
- `ArrayPool<T>`.
- `MemoryPool<T>`.
- `Span<T>` and `Memory<T>`.
- `StringBuilder`.
- `MemoryStream` capacity.
- Large Object Heap behavior.
- Pinned objects.
- `IDisposable` ownership.
- Async state machines.
- Repeated LINQ materialization.
- Excessive `ToArray()` and `ToList()`.
- Duplicate dependency injection scopes.

For Python, inspect:

- Object and dictionary overhead.
- Lists of boxed numeric objects.
- Duplicate strings.
- NumPy array copies.
- Pandas intermediate frames.
- Generator versus list materialization.
- Reference cycles.
- Multiprocessing data duplication.
- Cached function results.
- Unnecessary deep copies.

For JavaScript/TypeScript, inspect:

- Retained closures.
- Detached DOM objects where applicable.
- Unbounded maps.
- Event listeners.
- ArrayBuffer copies.
- Large object graphs.
- Duplicate parsed JSON.
- Worker memory duplication.

For Java, inspect:

- Collection capacity.
- Object headers.
- Boxing.
- String duplication.
- Thread-local retention.
- Direct buffers.
- Off-heap allocations.
- Classloader retention.
- Heap dump dominators.

For Go, inspect:

- Slice capacity.
- Small slices retaining large backing arrays.
- Escaping allocations.
- Goroutine stacks.
- Retained goroutines.
- Maps with large historical capacity.
- Pointer-heavy structures.
- Heap profiles.
- Pool retention behavior.

---

## 13. Native Memory and Resource Management

Apply where relevant to C, C++, Rust, native libraries, and interop.

### 13.1 Allocation ownership

Trace ownership of every significant dynamic allocation.

Look for:

- Missing frees.
- Lost pointers.
- Double ownership.
- Incorrect lifetime transfer.
- Error-path leaks.
- Early-return leaks.
- Exception-path leaks.
- Partial initialization leaks.

### 13.2 Smart pointer overhead

Inspect whether reference-counted ownership is used unnecessarily.

Consider whether unique ownership, borrowed references, or stable IDs are more appropriate.

Do not replace safe ownership models without proving lifetime correctness.

### 13.3 Allocator overhead

Evaluate workloads involving many small allocations.

Consider:

- Arenas.
- Slabs.
- Object pools.
- Region allocators.
- Contiguous storage.
- Allocation batching.

Assess allocator retention and fragmentation.

### 13.4 Fragmentation

Investigate mixed-size allocation patterns and long-lived allocations interspersed with short-lived allocations.

Determine whether allocation lifetime grouping could improve reuse.

### 13.5 Memory mappings

Inspect:

- File mappings.
- Shared mappings.
- Private mappings.
- Page residency.
- Mapping lifetime.
- Copy-on-write behavior.
- Duplicate mappings.

Distinguish mapped virtual memory from resident physical pages.

### 13.6 Native interop

Inspect:

- Marshaling buffers.
- Pinned managed arrays.
- Native handles.
- Native caches.
- Duplicate representations across boundaries.
- Lifetime mismatches.
- Unreleased library allocations.

---

## 14. Serialization, Parsing, and Data Loading

### 14.1 Whole-document loading

Identify code that reads complete files or messages into memory unnecessarily.

Consider streaming parsers and incremental processing.

### 14.2 Repeated parsing

Find data parsed multiple times.

Determine whether parsed structures should be shared, reused, or discarded sooner.

### 14.3 Oversized object models

Evaluate whether deserialization creates heavyweight object graphs for data that is only partially consumed.

Consider selective parsing or compact representations.

### 14.4 Serialization buffers

Inspect whether serializers retain both complete input objects and complete output buffers simultaneously.

Investigate streaming and chunked output.

### 14.5 Data loading lifecycle

Determine whether temporary loading structures remain alive after initialization.

Examples:

- Parse trees.
- Intermediate dictionaries.
- Raw file buffers.
- Validation structures.
- Temporary indexes.
- Sorting buffers.

---

## 15. Diagnostics, Logging, and Development Features

Identify memory consumed by:

- Debug histories.
- Trace buffers.
- Profiling state.
- Metrics labels.
- Request histories.
- Error histories.
- Captured exceptions.
- Verbose diagnostic objects.
- Debug-only lookup structures.
- Internal instrumentation.

Check whether these are enabled unnecessarily in production.

Ensure bounded retention.

Evaluate whether diagnostic structures duplicate large amounts of application state.

Do not recommend removing diagnostics required for reliability or incident investigation without an acceptable replacement.

---

## 16. Initialization and Idle Memory

Investigate memory allocated before it is actually needed.

Look for:

- Eagerly initialized subsystems.
- Large startup caches.
- Preallocated worker buffers.
- Loaded-but-unused datasets.
- Optional feature initialization.
- Duplicate service instances.
- Large default collections.
- Entire file indexes loaded at startup.

Evaluate lazy initialization and feature-scoped allocation.

Check whether initialization temporarily holds multiple copies of the same data.

Determine whether startup peaks can be reduced by releasing intermediate state earlier.

---

## 17. Long-Running Application Behavior

Analyze repeated operations and extended runtime.

Look for memory that increases with:

- Number of completed requests.
- Number of simulations.
- Number of opened files.
- Number of sessions.
- Number of processed records.
- Number of errors.
- Number of reconnects.
- Number of configuration reloads.

Distinguish expected warmup from unbounded growth.

Investigate whether memory returns to a stable plateau after repeated workloads.

Inspect failure, cancellation, timeout, and retry paths separately from successful operations.

---

## 18. Peak Memory and Workload Overlap

Analyze worst-case simultaneous memory demand.

Identify situations where several memory-heavy phases overlap unnecessarily.

Examples:

- Loading new data before releasing old data.
- Building a replacement cache while retaining the original.
- Parsing several large files concurrently.
- Running too many memory-heavy simulations simultaneously.
- Retaining complete input and output buffers.
- Accumulating results before writing them.
- Performing full-state snapshots during active processing.

Evaluate whether scheduling, streaming, bounded concurrency, or staged replacement could reduce peak RAM.

Explicitly distinguish peak reduction from steady-state reduction.

---

## 19. Operating System and Runtime-Level Considerations

Where applicable, investigate:

- Thread stack reservations and commitment.
- Allocator arenas.
- Heap reservation.
- Runtime heap growth policies.
- Memory-mapped file behavior.
- Page cache.
- Shared libraries.
- Copy-on-write pages.
- Native library allocations.
- GPU memory and staging buffers.
- Process isolation overhead.
- Multiprocess duplication.
- Container memory limits.

Do not recommend arbitrary garbage collection, heap compaction, or operating system trimming as a substitute for fixing underlying retention problems.

Do not mistake reduced reported RSS after forced trimming for reduced application memory requirements.

---

## 20. Suspicious Patterns to Search For

Systematically search the codebase for patterns such as:

- Large fixed-size arrays.
- Collections with unusually high initial capacities.
- Collections that never shrink.
- Unbounded dictionaries.
- Unbounded queues.
- Static collections.
- Global caches.
- Deep-copy operations.
- Clone methods.
- Copy constructors.
- Serialization-based cloning.
- Repeated `ToArray()` calls.
- Repeated `ToList()` calls.
- Repeated string concatenation.
- Large temporary buffers.
- Per-worker scratch arrays.
- Per-request service construction.
- Per-object empty collections.
- Nested dictionaries.
- Per-element heap allocations.
- Full-state snapshots.
- Duplicate indexes.
- Retained historical data.
- Event subscriptions without matching unsubscription.
- Background tasks without lifecycle management.
- Timer callbacks.
- Retry histories.
- Logging buffers.
- Captured exception objects.
- Unreleased native resources.
- Redundant data transformations.
- Repeated parsing.
- Whole-file reads.
- Multiple simultaneously live copies of data.

These are search targets, not automatic findings. Every suspected issue must be evaluated in context.

---

## 21. Required Investigation Procedure

All of the steps below belong to Phase 1 (audit). They are numbered as steps so they are not confused with the audit and fix phases; do not change code while performing them.

### Before Step 1: Organize the audit

- For a large codebase, review it area by area (for example input, core algorithm, storage, output, interfaces) so coverage is complete and does not overlap, and keep each area's findings in its own file.
- Give every finding a stable ID (for example an area prefix and a number) and keep it unchanged through Phase 2, commit messages, and later reviews.
- Mark every finding **CONFIRMED**, with the exact reproducer or measurement (input, command, observed output), or **HYPOTHESIS**. Never fix a hypothesis blind; if it cannot be reproduced here, leave it as a hypothesis and say what would confirm it.
- Merge the area findings into one ranked report, and re-check every Critical and High finding against the code before ranking it.
- Write the findings files and the merged report to a durable location (the repository's docs folder, or another fixed path the user agrees to), never a temporary or session folder, so they survive the session ending and context compactions.

**Profile first.** Before the source review (Step 2), take one measured run of a representative workload that reports peak memory, retained memory, and allocation volume per phase or subsystem. Use it to aim the review and to rank findings: a finding's priority is the measured share of memory attributable to where it applies multiplied by the reduction expected there, not how bad the code looks. A finding in a phase that accounts for under about 5% of peak or retained memory on a realistic run is Low regardless of its complexity, and may be deferred with the measured share as the reason. If no run is possible, say so and label every ranking an estimate.

### Step 1: Architecture and memory inventory

1. Map the application architecture.
2. Identify long-lived components.
3. Identify major data models.
4. Identify caches and registries.
5. Identify memory-heavy algorithms.
6. Identify parallel execution paths.
7. Identify large allocations.
8. Identify major data-loading operations.
9. Identify native or external memory consumers.
10. Identify workload phases and cleanup boundaries.

Produce a memory ownership and lifetime overview.

### Step 2: Systematic source review

Review every relevant module.

For each module, inspect:

- Allocation behavior.
- Object ownership.
- Object lifetime.
- Container sizing.
- Duplicate data.
- Temporary allocations.
- Caching.
- Concurrency amplification.
- Cleanup.
- Error paths.
- Peak memory behavior.

Do not stop after finding a few obvious issues.

Maintain a coverage ledger recording which modules, files, and subsystems have been reviewed.

### Step 3: Cross-component analysis

Investigate inefficiencies that cannot be identified within one file.

Examples:

- Two services independently cache the same data.
- One component retains data another component has finished using.
- Multiple processing stages each copy an entire dataset.
- Per-worker initialization duplicates immutable state.
- A caller retains objects after a callee has completed processing.

Trace complete data flows and ownership boundaries.

### Step 4: Quantitative analysis

For each significant finding:

1. Determine the allocation or retention mechanism.
2. Determine its frequency or cardinality.
3. Estimate memory overhead.
4. Identify the relevant workload.
5. Estimate achievable savings.
6. Evaluate CPU and latency impact.
7. Evaluate correctness risks.
8. Propose validation measurements.

Prefer measured values where possible.

### Step 5: Prioritization

Rank findings using:

- Estimated RAM savings.
- Confidence in the estimate.
- Implementation effort.
- Correctness risk.
- Runtime performance impact.
- Scope of affected workloads.
- Baseline versus peak benefit.
- Long-term maintenance impact.

Prioritize changes that deliver large, reliable reductions with limited complexity.

### Step 6: Completeness pass

After reviewing all modules, perform another pass focused on missed opportunities.

Revisit:

- Cross-module duplication.
- High-cardinality objects.
- Peak allocations.
- Long-lived references.
- Failure paths.
- Parallel workloads.
- Hidden caches.
- Runtime-specific overhead.

Do not assume the first review pass is complete.

---

## 22. Finding Classification

Assign every finding a severity.

#### Critical

Examples:

- Unbounded memory growth.
- Significant memory leaks.
- Memory use capable of exhausting available RAM under normal workloads.
- Severe per-worker duplication.
- Major algorithmic memory amplification.

#### High

Examples:

- Large persistent avoidable allocations.
- Significant duplicate datasets.
- Oversized caches.
- Large unnecessary state copies.
- Major peak-memory spikes.

#### Medium

Examples:

- Meaningful collection overcapacity.
- Inefficient high-cardinality object layouts.
- Moderate duplicate data.
- Avoidable intermediate allocations.
- Excessive temporary buffers.

#### Low

Examples:

- Small avoidable allocations.
- Minor per-instance overhead.
- Limited-scope collection inefficiencies.
- Small temporary allocations with little retained-memory impact.

Severity must reflect actual impact, not merely the presence of a suspicious coding pattern.

---

## 23. Required Finding Format

For every finding, provide:

**Finding ID:** Unique identifier.

**Title:** Concise description.

**Severity:** Critical / High / Medium / Low.

**Confidence:** High / Medium / Low.

**Location:** File, function, class, and relevant line numbers.

**Category:** Retention, duplication, allocation, capacity, object layout, cache, algorithm, concurrency, fragmentation, or other.

**Current behavior:** Explain precisely what the code does.

**Why memory is wasted:** Identify the unnecessary allocation or retention mechanism.

**Evidence:** Cite relevant source code, object counts, profiler data, or measured behavior.

**Memory impact:** Estimate avoidable bytes, object counts, and workload-dependent totals.

**Recommended change:** Describe a concrete implementation approach.

**Expected benefit:** Distinguish baseline, steady-state, peak, and allocation-rate improvements.

**Tradeoffs:** Explain CPU, latency, complexity, and other potential costs.

**Correctness risks:** Identify ownership, lifetime, concurrency, or compatibility hazards.

**Validation plan:** Explain how to prove the optimization is correct and beneficial.

**Change type:** What the recommended fix would change, judged from the code rather than impression: on-disk or saved format / public API / documented behavior / none. One or more may apply.

**Observable output changes:** Anything a user or a downstream tool would see change even when results stay correct: ordering, counts, wording, output layout. Write "none" if there are none.

**Expected memory removed:** The fraction of the targeted allocations or retained memory the recommended change should remove, and a cheap way to check that before building the full fix (for example, a temporary count of objects the new path would still create or retain). Note any copies or work the new design repeats per key, item, or group, which can cost more than it saves.

**Dependencies:** Identify other findings or refactors that interact with this change.

Do not present vague recommendations such as "use less memory" or "optimize the cache."

Every recommendation must be tied to a concrete mechanism.

---

## 24. Required Final Report

Organize the final report into the following sections.

### A. Executive Summary

Include:

- Overall assessment of RAM efficiency.
- Largest identified sources of waste.
- Most promising optimization opportunities.
- Major memory risks.
- Confidence in the conclusions.
- Limitations of available evidence.

### B. Memory Architecture Overview

Describe:

- Major memory owners.
- Long-lived data.
- Major caches.
- High-cardinality object populations.
- Large temporary allocations.
- Memory-heavy processing phases.
- Parallel memory amplification.

### C. Ranked Findings

Provide a table containing:

| Rank | Finding | Severity | Estimated RAM Savings | Confidence | Effort | Risk |
|---|---|---|---|---|---|---|

Order primarily by expected practical impact.

Do not add overlapping savings estimates together without accounting for shared allocations and dependencies.

End the ranked findings with a triage:

- **Ship now:** the top one to three findings by measured value and risk. Phase 2 fixes, proves, and releases these first.
- **Backlog:** the rest, in rank order, with a cut line — the point below which the expected saving (for example under a few percent of the run) does not justify the work. Findings below the cut line are deferred, not fixed.

For each ship-now finding, name the cheapest proxy metric that shows whether a fix works (a count of items processed, filtered, allocated, or retained, not a full-run time) and the output-equivalence check that proves the fix changes no results.

### D. Detailed Findings

Include the complete finding format from Section 23 for every meaningful issue.

### E. Quick Wins

Identify changes that:

- Are straightforward.
- Have low correctness risk.
- Require limited refactoring.
- Have credible measurable savings.

### F. Major Architectural Opportunities

Identify larger changes that could materially reduce RAM consumption.

Examples:

- Compact state representations.
- Shared immutable datasets.
- Elimination of full-state cloning.
- Bounded caching.
- Streaming pipelines.
- Reduced per-worker memory.
- Flattened object graphs.

### G. Memory Savings Estimate

Provide:

- Estimated baseline RAM reduction.
- Estimated steady-state RAM reduction.
- Estimated peak RAM reduction.
- Estimated allocation-rate reduction.
- Confidence ranges.
- Assumptions.
- Potential overlap between findings.

Separate measured improvements from theoretical estimates.

### H. Validation and Benchmark Plan

Describe the workloads and metrics needed to confirm the proposed improvements.

Include before-and-after measurements using identical conditions.

### I. Coverage Report

List:

- Modules reviewed.
- Important files reviewed.
- Subsystems reviewed.
- Memory categories investigated.
- Areas not fully analyzed.
- Reasons for incomplete coverage.

### J. Remaining Unknowns

Document questions that require:

- Runtime profiling.
- Production workload data.
- Heap snapshots.
- Long-duration testing.
- Platform-specific measurements.
- Additional architectural investigation.

### K. Fixes Applied

Written in Phase 2 (Section 29). For each finding ID:

- The fix that was applied.
- The before/after measurement, taken with the same baseline method and workload as Phase 1.
- The tests that confirm behavior is unchanged.

Also list every deferred or reverted finding with the reason, and anything discovered while fixing.

Split the list into three groups and count them separately in any summary: **code fix**, **documentation only** (resolved by documenting the behavior rather than changing it), and **deferred**. Every deferred item carries the reviewer's recommendation, its estimated cost, and the decision needed from the user, not only the reason it was deferred.

### L. Changes to Documented Behavior

Written in Phase 2. List every change a user could notice: documented behavior, output ordering or format, public API, saved formats, defaults. For each, give the finding ID, what changed, and whether the user approved it. Write "none" if there are none.

---

## 25. Validation Requirements

For every optimization implemented in Phase 2, validation must include:

1. Correctness tests.
2. Representative workload benchmarks.
3. Peak memory measurement.
4. Steady-state memory measurement.
5. Allocation-rate measurement where relevant.
6. Long-running memory stability tests.
7. Concurrency tests.
8. Error-path and cancellation tests.
9. Performance regression measurements.
10. Comparison against the original implementation.

Use identical workload inputs and comparable runtime conditions.

Account for garbage collection, allocator warmup, operating system caching, and measurement noise.

Repeat benchmarks where necessary.

Benchmark protocol:

- Build the original and the changed version from separate git worktrees into separate output directories, and print each build's version or hash in the benchmark output, so a run can never silently compare a build with itself.
- Keep the built binary for every fix, so any two fixes can be compared later without rebuilding.
- Alternate old and new runs (A, B, A, B, …) for at least four rounds instead of running each back to back, and report the minimum, median, and spread. Back-to-back runs drift with background load.
- Prefer allocation counts, object counts, and peak or retained bytes over wall-clock time alone; wall time on I/O-heavy workloads is often noise.
- Include at least one small input, to expose start-up costs, and inputs shaped like each ranked finding, so every fixed finding is actually exercised.
- Check that results are identical before and after (output bytes, or counts of items processed, kept, and dropped).

A change should not be considered successful merely because it reduces allocation count.

It must improve a meaningful memory metric or remove a demonstrated memory risk.

---

## 26. Review Quality Requirements

The review must be:

**Exhaustive:** Cover the full codebase and all major memory mechanisms.

**Evidence-based:** Distinguish confirmed issues from plausible hypotheses.

**Quantitative:** Estimate impact whenever practical.

**Specific:** Identify exact locations and implementation strategies.

**Correctness-conscious:** Preserve semantics and safety.

**Workload-aware:** Consider realistic and worst-case usage.

**Architecture-aware:** Investigate inefficiencies spanning multiple modules.

**Audit before fixing:** Do not change code until the Phase 1 report is complete.

**Prioritized:** Focus attention on the largest achievable improvements.

**Honest about uncertainty:** Never invent profiling results, object counts, or precise savings.

---

## 27. Additional Deep-Review Requirements

After completing the initial analysis, deliberately challenge the findings.

Ask:

- What is the single largest population of allocated objects?
- Which object type has the greatest aggregate footprint?
- Which allocation site produces the most live bytes?
- Which allocation site produces the most temporary bytes?
- Which cache retains the most memory?
- Which data is represented more than once?
- Which component has the largest idle footprint?
- Which algorithm creates the largest peak-memory spike?
- Which objects survive significantly longer than necessary?
- Which data could be shared safely across workers?
- Which allocations scale linearly with worker count?
- Which allocations scale quadratically or worse with input size?
- Which temporary buffers overlap in lifetime?
- Which objects retain large graphs through seemingly small references?
- Which structures have the highest metadata-to-payload ratio?
- Which collection capacities are far larger than observed counts?
- Which memory costs grow with the application's lifetime?
- Which memory costs could be eliminated by changing the representation rather than optimizing allocations?
- Which optimizations would reduce RAM substantially without harming CPU performance?
- Which apparent memory problems are actually expected runtime or allocator behavior?
- Which proposed changes might simply move memory consumption elsewhere?
- Which findings overlap or depend on one another?
- What important memory inefficiencies might a file-by-file review miss?

Investigate the answers before finalizing.

---

## 28. Stop Conditions and Completion Criteria

Do not stop merely because several high-impact findings have been discovered.

Continue until:

1. Every relevant subsystem has been reviewed.
2. Major object populations have been examined.
3. Long-lived data ownership has been investigated.
4. Major caches have been inventoried.
5. Large and frequent allocations have been examined.
6. High-memory algorithms have been analyzed.
7. Concurrency-related memory amplification has been investigated.
8. Cross-component duplication has been reviewed.
9. Peak-memory scenarios have been considered.
10. Error and cleanup paths have been checked.
11. All findings have been prioritized.
12. A final completeness pass has been performed.
13. Remaining uncertainties have been explicitly documented.
14. Phase 2: the ship-now set fixed, verified, and released; the backlog fixed down to the cut line; every other finding reverted or deferred with a recommendation; and the Fixes Applied and Changes to Documented Behavior sections written.

If tool, context, time, or repository access limitations prevent full coverage, identify exactly what remains rather than claiming completion.

Maintain a persistent review ledger if the investigation spans multiple sessions or context compactions. During Phase 2, record in it which findings have been fixed, reverted, or deferred.

Do not repeatedly rediscover previously analyzed findings. Revisit them only when new evidence changes the assessment.

---

## 29. Phase 2 — Fix What the Audit Found

Only after the Phase 1 report is complete, fix the confirmed findings. Do not start fixing while still auditing — the complete, ranked list is what keeps effort on the highest-value problems instead of the first ones found.

Work in this order:

1. Fix, prove, and release the **ship-now** set from the triage first.
2. Then work down the backlog in rank order to the cut line, releasing in batches. Defer everything below it.

Close out each finding before starting the next: once it is proven, commit it, then move on. Do not start another finding while one is half-proven.

For each fix:

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

When finished, update the report with the **Fixes Applied** section (Section 24, K) and the **Changes to Documented Behavior** section (L): what was fixed (with the before/after evidence or the regression test that proves it), what was deferred and why, and anything discovered while fixing.

---

## 30. Final Instruction

**Find wasted RAM, not merely memory leaks.**

Look for memory that should never have been allocated, memory that should have been shared, memory that could have been represented more compactly, memory that should have been released sooner, and memory that exists only because of unnecessarily expensive architectural decisions.

Focus especially on multiplicative waste: a seemingly insignificant inefficiency repeated across millions of objects, thousands of requests, hundreds of workers, or millions of simulation iterations can dominate the application's memory footprint.

Prefer eliminating unnecessary allocations and retention at their source over compensating through garbage collection, trimming, or pooling.

The final deliverable must be the fixes applied in Phase 2 plus a comprehensive, evidence-supported, prioritized RAM optimization report containing concrete findings and actionable recommendations.

**Do not start fixing until the audit is complete, and do not fix what you cannot verify. Do not stop at obvious issues. Do not declare the review complete until the coverage and completeness requirements have been satisfied or the remaining limitations have been explicitly documented.**