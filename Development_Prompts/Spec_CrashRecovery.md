# Crash Recovery / Autosave / Work Preservation System — Implementation Specification

Implement a robust, generic crash-recovery and work-preservation system for this application.

This is an IMPLEMENTATION specification — you are building a working system, not producing a review or a report.

The primary objective is:

> A crash, forced termination, power loss, unexpected exception, or other abnormal shutdown should have the smallest practical chance of causing the user to lose meaningful work.

At the same time:

> Recovery mechanisms must NEVER casually overwrite, corrupt, or replace the user's last known-good saved data.

The recovery system should act as a safety net around the application's normal Save workflow.

It is NOT a replacement for Save.

Adapt this specification to the application's actual architecture, persistence model, language, framework, and workflow.

Do not implement features that make no sense for the application.

---

# 1. CORE DESIGN PRINCIPLES

The system should follow these principles:

1. Preserve user work whenever reasonably possible.

2. Never overwrite a known-good user save with unverified recovery data.

3. Recovery data should normally be stored separately from normal saved data.

4. Recovery writes should be as atomic and corruption-resistant as practical.

5. Recovery should happen automatically in the background when appropriate.

6. Restoring recovery data should normally be an explicit user decision.

7. A failed recovery attempt should not destroy the recovery data.

8. A corrupt recovery file should not prevent the application from starting.

9. Normal application behavior should remain understandable.

10. Recovery should not introduce excessive disk I/O or UI pauses.

11. Recovery data should have bounded storage.

12. The system should distinguish normal shutdown from abnormal termination.

13. Recovery state should be observable and diagnosable through the application's logging/diagnostic system if one exists.

---

# 2. UNDERSTAND THE APPLICATION'S WORK MODEL

Before implementation, identify:

- What represents a user project/document/session?
- What constitutes meaningful editable state?
- What constitutes unsaved work?
- What is already persisted during normal Save?
- Are there multiple documents/projects open simultaneously?
- Are there external resources?
- Are resources embedded or referenced?
- Is there an existing dirty-state mechanism?
- Can edits occur continuously?
- Are operations transactional?
- Are there long-running operations?
- Can application state temporarily be invalid while the user is editing?

Design recovery around the actual application rather than blindly serializing arbitrary memory.

---

# 3. RECOVERY STATE VS NORMAL SAVED STATE

Maintain a clear distinction between:

NORMAL SAVE

and:

RECOVERY SNAPSHOT

A normal save is user-authoritative persisted data.

A recovery snapshot is temporary emergency state intended to reconstruct unsaved work after abnormal termination.

Do not silently treat recovery data as the user's canonical saved file.

Recovery data should normally live in an application-controlled recovery location rather than beside or on top of the user's normal file.

---

# 4. RECOVERY IDENTIFIERS

Each recoverable document/project/session should have a stable recovery identity.

Do not rely solely on filename because:

- New unsaved documents may not have filenames.
- Save As changes filenames.
- Files may move.
- Multiple documents could share similar names.

Use an appropriate unique identifier.

Recovery metadata should allow the application to determine what the snapshot belongs to.

---

# 5. SESSION IDENTIFICATION

Assign each application execution a unique session ID.

Record:

- Session ID
- Application version
- Start time
- Process ID where useful
- Normal/abnormal termination state

Recovery artifacts should identify the session that created them.

This also integrates naturally with diagnostic logging.

---

# 6. NORMAL VS ABNORMAL SHUTDOWN

Implement a reliable mechanism to determine whether the previous application session ended normally.

One simple conceptual pattern is:

Application starts
→ create/update session marker indicating RUNNING

Application shuts down successfully
→ mark session CLEAN or remove marker

Next launch:
→ detect previous RUNNING marker
→ previous session likely terminated abnormally

Use an implementation appropriate for the platform.

Do not assume every abnormal marker means the application itself crashed.

Possible causes include:

- Application crash
- Forced termination
- OS shutdown
- Power loss
- Machine crash
- Process killed externally

User-facing language should therefore normally say something like:

"The previous session did not close normally."

rather than making unsupported claims about exactly what happened.

---

# 7. DIRTY-STATE INTEGRATION

Integrate recovery with the application's dirty/modified state.

Recovery work should generally only be necessary when meaningful unsaved changes exist.

Do not continuously write recovery snapshots when absolutely nothing has changed.

A useful conceptual model is:

Change occurs
→ document becomes dirty
→ recovery becomes pending

Recovery snapshot succeeds
→ current dirty state has a recoverable snapshot

Additional change occurs
→ recovery becomes pending again

Normal Save succeeds
→ document becomes clean
→ obsolete recovery data can eventually be removed

Be careful:

"Recovery snapshot exists"

does NOT mean:

"Document has been normally saved."

The normal dirty-state indicator should remain correct.

---

# 8. AUTOSAVE / RECOVERY SNAPSHOT STRATEGY

Implement recovery snapshots automatically when appropriate.

Use a strategy suitable for the application.

Possible triggers include:

- After meaningful changes
- After a debounce period
- Periodically while dirty
- Before potentially dangerous operations
- When application loses focus
- Before shutdown
- Combination of the above

Avoid writing on every keystroke unless the persistence mechanism is specifically designed for that.

A reasonable generic strategy is:

Meaningful edit
→ mark recovery pending
→ debounce
→ write recovery snapshot after activity settles

plus:

Periodic safety snapshot while dirty

if warranted.

Choose actual timing based on application cost and workflow.

Do not blindly hardcode aggressive autosaving.

---

# 9. DO NOT BLOCK THE UI

Recovery snapshots should not noticeably freeze interactive applications.

Where appropriate:

- Serialize off the UI thread.
- Perform disk writes asynchronously.
- Capture necessary state safely.
- Avoid holding UI locks during disk I/O.

However, do not introduce race conditions merely to make autosave asynchronous.

Correctness comes first.

---

# 10. CONSISTENT SNAPSHOT STATE

A recovery snapshot must represent a coherent application state.

Do not serialize half of one edit and half of another.

If state can change concurrently with recovery generation, use an appropriate mechanism such as:

- Immutable snapshot
- Copy-on-write state
- Short synchronization period
- Serialized command/state queue
- Versioned snapshot

depending on the application's architecture.

The snapshot should correspond to a well-defined logical moment.

---

# 11. ATOMIC RECOVERY WRITES

Recovery snapshots should be written safely.

Prefer a pattern conceptually similar to:

1. Serialize recovery state to a new temporary file.
2. Flush/close successfully.
3. Validate enough to know the write completed.
4. Atomically rename/replace the previous recovery snapshot where supported.

Never destroy the previous usable recovery snapshot BEFORE the new snapshot has been written successfully.

The principle is:

OLD VALID RECOVERY
→ write NEW TEMPORARY RECOVERY
→ verify
→ promote NEW
→ only then retire OLD

A crash halfway through should leave either:

- Previous valid recovery

or:

- New valid recovery

rather than:

- Half-written garbage and nothing else.

---

# 12. RECOVERY GENERATIONS

Consider keeping a small number of recent recovery generations.

For example:

Current recovery
Previous recovery
Possibly one or two additional generations

This protects against situations where:

- Latest recovery becomes corrupt
- Application state was already damaged before latest snapshot
- Bug generated invalid recovery data
- User wants an earlier recovery point

Do NOT keep unlimited generations.

Use a small bounded number appropriate for the application's data size.

---

# 13. RECOVERY METADATA

Each recovery snapshot should include enough metadata to understand it.

Examples:

- Recovery format version
- Application version
- Session ID
- Recovery ID
- Original document/project identity
- Original path if appropriate
- Snapshot timestamp
- Last normal save timestamp if known
- Dirty-state information
- Snapshot generation
- Data/schema version
- Optional description of current workflow state

Avoid sensitive information that is unnecessary.

---

# 14. RECOVERY FORMAT VERSIONING

Version the recovery format.

Example concept:

RecoveryFormatVersion: 1

This allows future application versions to recognize:

- Compatible recovery
- Older recoverable format
- Unsupported newer format
- Corrupt/unknown format

Do not assume recovery serialization will remain identical forever.

---

# 15. APPLICATION VERSION COMPATIBILITY

Recovery data may survive an application update.

Therefore:

- Record the creating application version.
- Validate compatibility before restoration.
- Migrate recovery data if the normal persistence system supports migration.
- Refuse safely if restoration would be dangerous.

Never blindly deserialize incompatible recovery state.

---

# 16. RECOVERY DETECTION AT STARTUP

At startup, inspect the recovery location.

Determine whether recoverable unsaved work exists.

Do NOT simply restore everything automatically without user knowledge.

Present recovery only when there is meaningful recovery data.

Avoid bothering the user with obsolete recovery artifacts from documents that were subsequently saved successfully.

---

# 17. RECOVERY UI

When recoverable work exists, present a clear recovery experience.

Depending on application complexity, this might be:

"Unsaved work from a previous session was found."

Show useful information such as:

- Project/document name
- Recovery timestamp
- Last normal save timestamp
- Original path where appropriate
- Number of recoverable documents

Offer actions such as:

- Recover
- Discard
- Inspect/details where useful
- Decide later where appropriate

Use terminology normal users understand.

Do not require users to understand "autosave snapshot generations."

---

# 18. RECOVER SHOULD NOT OVERWRITE ORIGINAL FILE

THIS IS CRITICAL.

Choosing Recover should normally load the recovered state INTO THE APPLICATION.

It should NOT immediately overwrite the user's original saved file.

Example:

User had:

Project.xyz — last normal save at 2:00 PM

Recovery snapshot — 2:37 PM

User launches application at 3:00 PM.

User chooses Recover.

The application should load the 2:37 PM recovered state and mark it appropriately as containing recovered/unsaved work.

The user can then inspect it and choose Save.

Do not automatically overwrite Project.xyz.

---

# 19. RECOVERED STATE SHOULD BE DIRTY

After recovery, the restored work should normally be treated as modified/unsaved.

The user should have to explicitly Save before the recovered state becomes the canonical persisted version.

Make this status clear in the UI.

Examples:

Recovered — Unsaved

or the application's normal dirty indicator.

---

# 20. DO NOT DELETE RECOVERY TOO EARLY

Do NOT delete recovery data merely because:

- User clicked Recover.
- Recovery loaded successfully.
- Application started successfully.

Keep recovery data until there is strong evidence it is no longer needed.

A safer lifecycle is:

Recovery detected
→ user chooses Recover
→ recovered state loads
→ user verifies/continues
→ user successfully performs normal Save
→ recovery becomes obsolete
→ cleanup

If the application crashes AGAIN before the normal save, recovery should still be available.

---

# 21. DISCARD BEHAVIOR

If the user explicitly chooses Discard:

Make sure they understand what is being discarded.

For significant work, consider an appropriate confirmation.

Do not create endless confirmation dialogs for trivial recovery data.

After confirmed discard:

- Remove or quarantine recovery artifacts safely.
- Do not modify the user's normal saved file.

---

# 22. DECIDE LATER

Where useful, allow users to defer the decision.

Do not destroy recovery data simply because they did not restore it immediately.

This is especially useful if multiple documents have recovery snapshots.

---

# 23. MULTIPLE RECOVERABLE DOCUMENTS

If the application supports multiple documents/projects, recovery should handle them independently.

Do not make recovery all-or-nothing unless the application architecture requires it.

Users may want to:

- Recover A
- Discard B
- Ignore C temporarily

Maintain correct document identity.

---

# 24. NEW / NEVER-SAVED DOCUMENTS

Support recovery for work that has never been normally saved.

This is one of the most important cases.

A new document should receive an internal recovery identity immediately.

Its recovery metadata may contain:

OriginalPath: none

or equivalent.

After recovery, the application should present it as unsaved work and require Save/Save As normally.

---

# 25. SAVE AS INTERACTION

Handle Save As carefully.

Example:

User opens A
→ edits
→ recovery exists for A
→ Save As B succeeds

The working document is now B.

Recovery identity/metadata must update appropriately.

Obsolete recovery for A should not later appear as mysterious unsaved work if B contains those changes safely.

However, do not delete old recovery until Save As has fully succeeded.

---

# 26. NORMAL SAVE INTERACTION

When normal Save succeeds:

- Update dirty state.
- Mark persisted state as authoritative.
- Retire obsolete recovery data safely.

When normal Save FAILS:

- Keep dirty state.
- Keep recovery data.
- Do not claim recovery is unnecessary.

The failure of normal Save makes recovery MORE important, not less.

---

# 27. SAVE CANCELLATION

If the user initiates Save or Save As and cancels:

- Preserve dirty state.
- Preserve recovery data.
- Do not update canonical document identity.
- Do not delete recovery.
- Do not treat cancellation as success.

---

# 28. RECOVERY AFTER FAILED SAVE

Explicitly test:

Edit
→ recovery snapshot succeeds
→ normal Save attempted
→ normal Save fails
→ application crashes

On restart:

Recovery should still be available.

This is an important acceptance scenario.

---

# 29. RECOVERY DURING IMPORT

If importing creates or modifies meaningful work, determine when that work becomes recoverable.

Do not autosave obviously incomplete/transient state unless the application knows how to restore it safely.

Prefer recovery snapshots at coherent workflow boundaries.

---

# 30. RECOVERY DURING LONG OPERATIONS

For long-running operations, determine whether:

- Pre-operation state should be snapshotted
- Intermediate state is meaningful
- Only completed operation state should be recoverable

Do not blindly serialize half-completed operations that cannot safely resume.

If necessary, recover to the last coherent state before the operation.

---

# 31. TRANSACTIONAL OPERATIONS

Where operations have clear commit points, align recovery with them.

Conceptually:

Valid State A
→ operation begins
→ temporary/transitional state
→ operation succeeds
→ Valid State B

Recovery should ideally contain A or B.

Avoid snapshots of undefined transitional state.

---

# 32. RECOVERY WRITE FAILURE

Recovery itself can fail.

Examples:

- Disk full
- Permission denied
- Recovery directory inaccessible
- Serialization failure
- I/O error

Handle this safely.

Do not crash the application merely because recovery failed.

Log the failure.

Where appropriate, inform the user if their work is currently NOT protected by recovery.

Avoid repeatedly bombarding them with identical dialogs.

---

# 33. RECOVERY HEALTH STATUS

Internally track whether the current dirty state has been successfully captured.

Conceptually:

Dirty + recovery current

versus:

Dirty + recovery pending

versus:

Dirty + recovery failed

This can be useful for diagnostics and potentially UI behavior.

Do not expose unnecessary technical detail to normal users.

---

# 34. DISK SPACE

Recovery data must not grow without bound.

Consider:

- Snapshot size
- Number of documents
- Number of generations
- Maximum age
- Orphaned sessions

Implement bounded retention.

If recovery snapshots can be extremely large, consider reasonable safeguards.

Do not silently consume gigabytes forever.

---

# 35. CLEANUP POLICY

Implement recovery cleanup.

Remove obsolete recovery data when safe.

Examples:

- Successful normal Save makes older recovery obsolete.
- Explicit user discard.
- Very old orphaned recovery after appropriate policy.
- Temporary incomplete recovery writes.

Be conservative.

It is better to retain a small unnecessary recovery file than prematurely delete the user's only surviving work.

---

# 36. ORPHANED TEMPORARY FILES

A crash may leave:

Recovery.tmp

or equivalent.

At startup, inspect temporary recovery artifacts carefully.

Do not automatically assume they are valid.

Validate them.

If a completed recovery snapshot exists, prefer it over an incomplete temporary artifact.

Clean stale temporary files when safe.

---

# 37. VALIDATE BEFORE RESTORE

Never blindly deserialize recovery data directly into active application state.

Validate:

- File/header
- Format version
- Schema
- Required fields
- Checksums where appropriate
- Object consistency
- References
- Bounds
- Expected types

Treat recovery data as potentially corrupt.

---

# 38. SAFE RESTORATION

Prefer:

Read recovery
→ parse
→ validate
→ construct temporary candidate state
→ verify candidate
→ commit to active application state

rather than:

Destroy current state
→ start reading recovery
→ fail halfway
→ application now has nothing usable

Preserve the previous valid state until restoration succeeds.

---

# 39. CORRUPT RECOVERY

If the newest recovery generation is corrupt:

- Do not crash.
- Do not delete everything immediately.
- Attempt an older generation if available.
- Explain the situation appropriately.
- Preserve corrupt data for diagnostics where useful.

Do not let one bad recovery file make the application unusable.

---

# 40. CHECKSUM / INTEGRITY VALIDATION

For sufficiently important or complex recovery data, consider including integrity information such as a checksum.

This can help distinguish:

- Complete snapshot
- Partial write
- Corruption

Do not add cryptographic complexity unless warranted.

The objective is corruption detection, not security theater.

---

# 41. CRASH DURING RECOVERY WRITE

Explicitly design for:

Old recovery exists.

New recovery begins writing.

Application crashes halfway through.

After restart:

The old recovery should still be usable.

This scenario is fundamental.

---

# 42. CRASH DURING NORMAL SAVE

Normal Save should itself use safe persistence techniques where practical.

Although this specification focuses on recovery, crash recovery cannot compensate for a Save implementation that destroys the original file before safely writing the replacement.

Prefer atomic normal saves too:

Original valid save
→ write temporary new save
→ validate
→ atomic replace

where the platform and application permit.

---

# 43. CRASH DURING RECOVERY RESTORE

If the application crashes while the user is restoring recovery:

Do not delete the recovery snapshot.

On the next launch, recovery should remain available.

---

# 44. CRASH AGAIN AFTER RECOVERY

Test:

Crash
→ Recover
→ continue editing
→ crash again BEFORE normal Save
→ restart

The latest meaningful recovered/edit state should still be recoverable.

Recovery must survive repeated abnormal sessions.

---

# 45. EXTERNAL RESOURCE REFERENCES

If projects reference external assets, recovery must preserve enough information to reconstruct references.

But recovery should not blindly copy huge external resources unless required.

Handle missing external resources gracefully during restore.

Do not make recovery unusable merely because one optional external file disappeared.

---

# 46. EMBEDDED UNSAVED RESOURCES

If users can create or modify resources that do not yet exist independently on disk, determine whether recovery needs to preserve them.

Examples:

- Newly imported image not yet saved
- Generated asset
- Unsaved metadata
- Temporary user-created object

If losing that resource would mean losing user work, recovery should account for it.

---

# 47. PRIVACY

Recovery data may contain user-created content.

Store it locally in an appropriate application data location.

Do not upload recovery data automatically.

Do not expose it through insecure temporary locations unnecessarily.

Use appropriate file permissions provided by the platform.

---

# 48. SECURITY

Treat recovery files as untrusted input during restore.

Do not use unsafe deserialization mechanisms.

Validate paths.

Prevent path traversal if recovery contains file references.

Do not execute content from recovery files.

Do not restore secrets into unsafe locations.

---

# 49. LOGGING / DIAGNOSTICS INTEGRATION

Integrate with the application's diagnostics system if one exists.

Log meaningful events such as:

Recovery snapshot scheduled

Recovery snapshot started

Recovery snapshot succeeded

Recovery snapshot failed

Abnormal previous session detected

Recovery discovered

Recovery restore requested

Recovery restore succeeded

Recovery restore failed

Recovery discarded

Recovery cleaned after successful Save

Do not log the user's actual content unnecessarily.

Include relevant recovery/session identifiers.

---

# 50. SUPPORT PACKAGE INTEGRATION

If the application implements Save Diagnostic Report, include safe recovery metadata where useful.

For example:

- Recovery enabled
- Recovery snapshot status
- Last successful recovery timestamp
- Recovery write failure
- Previous abnormal session detected
- Number of available recovery generations

Do NOT automatically include the user's recovery files themselves unless the user explicitly chooses to include potentially sensitive project data.

---

# 51. OPTIONAL RECOVERY STATUS UI

If appropriate, provide a subtle status indication when:

- Work is protected by a recent recovery snapshot
- Recovery is currently pending
- Recovery repeatedly failed

Do not clutter the UI unnecessarily.

For many applications this can remain entirely invisible unless something fails.

---

# 52. USER SETTINGS

If the application exposes autosave/recovery settings, keep them understandable.

Avoid exposing implementation jargon.

Possible settings:

Automatically protect unsaved work: On

Recovery interval: [reasonable choices]

Keep recovery data for: [...]

Do not expose dozens of tuning knobs unless the application actually needs them.

Choose safe defaults.

---

# 53. DEFAULT BEHAVIOR

Recovery should normally be ENABLED by default for applications where users can lose meaningful work.

A feature designed to prevent catastrophic work loss should not require users to discover it first.

However, adapt this to the application.

A read-only viewer obviously does not need autosave recovery.

---

# 54. PERFORMANCE

Recovery should have minimal impact on normal use.

Measure:

- Serialization time
- Write time
- Snapshot size
- Memory overhead
- UI responsiveness

For large projects, consider:

- Debouncing
- Incremental snapshots
- Journaling
- Change-based recovery
- Background serialization

ONLY if simpler full snapshots are actually too expensive.

Start with the simplest reliable architecture that meets performance needs.

---

# 55. DO NOT OVER-ENGINEER

Do not automatically build:

- Database journaling
- Distributed snapshots
- Cloud synchronization
- Complex event sourcing
- Continuous version history
- Source-control-like systems

unless the application's scale genuinely warrants them.

For many desktop applications:

A few safe, versioned, atomic recovery snapshots are enough.

Reliability matters more than architectural cleverness.

---

# 56. RECOVERY TEST HARNESS

Where practical, make recovery behavior testable.

Avoid architecture where recovery can only be tested by physically pulling the computer's power cable.

Provide abstractions/test hooks allowing tests to simulate:

- Recovery write failure
- Partial recovery write
- Corrupt recovery
- Abnormal previous session
- Old recovery format
- Save failure
- Restore failure

Do not ship dangerous debug controls to normal users unless appropriately hidden/removed.

---

# 57. AUTOMATED TESTS

Add automated tests covering at minimum:

- Dirty state creates recovery
- Clean state does not unnecessarily create recovery
- Recovery snapshot round trip
- New unsaved document recovery
- Existing document recovery
- Multiple recovery generations
- Normal Save cleanup
- Failed Save preserves recovery
- Canceled Save preserves recovery
- Save As behavior
- Corrupt latest recovery
- Older generation fallback
- Unsupported format
- Recovery write failure
- Recovery restore failure
- Abnormal shutdown detection
- Normal shutdown detection
- Recovery retention limits
- Recovery cleanup
- Recovery identity
- Recovery after repeated crash
- Recovery of multiple documents where supported

---

# 58. ROUND-TRIP TESTING

Create meaningful state.

Generate recovery.

Destroy the in-memory state.

Load recovery.

Compare the restored state against the original.

Test as many supported data types/features as practical.

A recovery file existing on disk does NOT prove recovery works.

The only meaningful test is:

Can it actually reconstruct the user's work correctly?

---

# 59. MANUAL CRASH TESTING

Perform real manual testing where practical.

Example:

1. Start application.
2. Open/create work.
3. Make meaningful changes.
4. Wait for recovery snapshot.
5. Forcefully terminate the process.
6. Restart application.
7. Verify abnormal session detection.
8. Verify recovery is offered.
9. Recover.
10. Verify all expected work.
11. Verify recovered work is dirty/unsaved.
12. Save normally.
13. Restart.
14. Verify stale recovery is no longer offered.

Do not rely exclusively on graceful shutdown tests.

---

# 60. CRASH AT DIFFERENT MOMENTS

Test forced termination during:

- Idle dirty state
- Recovery write
- Save
- Save As
- Import
- Export
- Long-running operation
- Recovery restoration
- Application shutdown

The application should recover to the safest coherent state available.

---

# 61. RECOVERY MUST NEVER MAKE THINGS WORSE

At every design decision ask:

"What happens if the recovery system itself fails right here?"

The recovery system must not turn:

"Potentially lose five minutes of work"

into:

"Corrupt the user's entire saved project."

Normal saved data is sacred.

Recovery is secondary.

---

# 62. GOLDEN FAILURE SCENARIOS

Explicitly test these scenarios:

## Scenario A — Simple crash

Open saved project
→ edit
→ recovery snapshot
→ crash
→ restart
→ recover
→ edits restored

## Scenario B — Never-saved work

New project
→ substantial edits
→ recovery snapshot
→ crash
→ restart
→ recover
→ Save As

No work should be lost merely because the project had never received a filename.

## Scenario C — Save failure

Open
→ edit
→ recovery exists
→ Save
→ Save fails
→ crash
→ restart

Recovery must remain available.

## Scenario D — Save As cancellation

New project
→ edit
→ recovery exists
→ Save As
→ Cancel
→ crash

Recovery must remain available.

## Scenario E — Crash during recovery write

Recovery generation N is valid
→ generation N+1 begins
→ terminate process halfway through write
→ restart

Generation N must remain usable.

## Scenario F — Corrupt latest recovery

Generation N valid
→ generation N+1 corrupt
→ restart

Application should safely fall back to N where possible.

## Scenario G — Crash after recovery

Crash
→ recover
→ continue editing
→ recovery updates
→ crash again
→ restart

Latest coherent work should remain recoverable.

## Scenario H — Normal save after recovery

Crash
→ recover
→ verify
→ Save successfully
→ exit normally
→ restart

Obsolete recovery should not continue appearing.

## Scenario I — Original file remains safe

Saved project exists
→ edit
→ recovery exists
→ crash
→ recover

The original saved project must remain unchanged until the user explicitly saves recovered work.

---

# 63. FINAL IMPLEMENTATION REVIEW

After implementing recovery, inspect the system specifically for:

- Premature recovery deletion
- Non-atomic writes
- Incorrect dirty-state transitions
- Race conditions
- UI blocking
- Unlimited recovery growth
- Incorrect Save As identity
- Corrupt recovery handling
- Version compatibility
- Recovery of never-saved work
- Recovery after repeated crashes
- Privacy problems
- Unsafe deserialization
- Logging gaps

Try to identify a sequence that could still cause meaningful user work to disappear.

---

# ACCEPTANCE CRITERIA

The crash-recovery implementation is complete when:

1. Meaningful unsaved work is automatically protected.

2. Recovery data is separate from normal saved data.

3. Recovery writes are resistant to interruption.

4. At least one previous valid recovery can survive a failed newer write where practical.

5. Abnormal previous sessions can be detected.

6. Recoverable work is detected on startup.

7. The user can explicitly recover or discard it.

8. Recovering does NOT automatically overwrite the original saved file.

9. Recovered work is treated as unsaved until explicitly saved.

10. Failed/canceled normal saves do not destroy recovery.

11. Successful normal saves retire obsolete recovery safely.

12. Never-saved documents can be recovered.

13. Corrupt recovery does not prevent application startup.

14. Recovery storage is bounded.

15. Recovery format is versioned.

16. Recovery is compatible with the application's data/schema migration strategy.

17. Recovery operations are logged appropriately.

18. Recovery failures do not normally crash the application.

19. Automated recovery round-trip tests exist where practical.

20. Real forced-termination recovery has been manually tested.

21. Repeated crashes remain recoverable.

22. The recovery system never casually replaces known-good user data.

The final standard is:

> If I spend an hour working, kick the power cord out of the machine, restart it, and open the application, how much work did I lose?

The answer should be:

> As little as reasonably possible.

And equally important:

> Did trying to protect my unsaved work put my last known-good saved work at risk?

The answer must be:

> No.

Treat the user's last known-good save as sacred.

Treat unsaved work as valuable.

Treat recovery data as expendable protection around both.

Design every failure path accordingly.