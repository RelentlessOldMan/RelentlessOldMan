# Workflow & Data-Lifecycle Hardening Prompt

This application represents an ongoing user workflow, not merely a collection of independent screens.

Perform a dedicated end-to-end review of the COMPLETE lifecycle of user work.

Identify the application's actual workflow and state transitions, including things such as:

```text
Import/Create
→ Load
→ Edit
→ Save Progress
→ Continue Editing
→ Close
→ Reopen
→ Resume
→ Modify
→ Save Again
→ Export/Finalize
```

Adapt this sequence to the application's actual behavior.

The primary requirement is:

THE USER MUST NEVER LOSE WORK, CORRUPT WORK, ACCIDENTALLY OVERWRITE WORK, OR BECOME CONFUSED ABOUT WHAT STATE THEIR WORK IS IN.

## FIX WHAT YOU FIND

This is NOT primarily a report-generation exercise.

When you find a real data-loss, corruption, overwrite, or state-confusion issue and the appropriate fix is reasonably clear:

1. Understand the surrounding workflow and state transitions.
2. Fix it.
3. Check every other transition and handler for the same pattern.
4. Add a regression test that reproduces the original failure where practical.
5. Rebuild and re-test as you go.
6. Continue searching.

Do not merely produce a giant list of hypothetical concerns and stop.

## TEST SAFELY

Many tests below deliberately provoke failures: permission denied, read-only destinations, disappearing destinations, corrupt files, crashes mid-save, fresh starts, and recent-file and persisted state.

Exercise these ONLY on copies in a temporary/scratch directory. Never open, import, save over, corrupt, delete, or move the user's real documents or projects while testing.

Before fresh-start, recent-file, or persisted-state tests, back up the application's settings/config location or redirect it to a scratch location, and restore it afterward.

Undo any permission or read-only changes you make.

Keep large-import and repeated-save tests bounded in size and duration so they don't fill the disk or lock up the machine.

Delete generated test data when you finish.

## 1. MODEL THE WORKFLOW AS A STATE MACHINE

Explicitly identify meaningful states such as:

- Nothing loaded
- Importing
- Import failed
- Newly imported but unsaved
- Loaded and unchanged
- Loaded and modified
- Saving
- Save failed
- Saved successfully
- Exporting
- Export failed
- Closing with unsaved changes
- Switching to another project/item
- Reloading existing work
- Recovering previously saved work

Determine which transitions are valid.

Then verify that UI controls, menus, buttons, status indicators, titles, and commands correctly reflect EACH state.

Do not rely on scattered event handlers accidentally producing the correct state.

## 2. DIRTY-STATE CORRECTNESS

Audit the concept of "modified/unsaved" extremely carefully.

Every meaningful modification should mark the work dirty.

Non-modifying operations should NOT mark it dirty.

Test:

Open → no changes → close

Open → change value → close

Open → change value → change it back

Open → edit multiple things → save

Save → edit again

Save → failed edit operation

Import → edit → save

Undo/redo if applicable

Programmatic UI refreshes must not accidentally mark the project dirty.

Likewise, a real change must not accidentally remain marked clean.

## 3. SAVE SEMANTICS

Determine exactly what "Save" means.

Verify that ALL state necessary to resume the user's work is persisted.

Do not test saving merely by checking that a file was created.

Perform round-trip testing:

1. Create/import something.
2. Make many different kinds of edits.
3. Save.
4. Completely close the application.
5. Restart it.
6. Reload the saved work.
7. Verify that EVERY relevant piece of state was restored correctly.

Compare the pre-save and post-load state.

Look for fields or settings silently omitted from persistence.

## 4. REPEATED SAVE TESTING

Test:

Save

Save again

Edit → Save

Edit → Save → Edit → Save

Save As → Save

Save As → Cancel

Save → close → reopen → edit → save

Repeated saving must not progressively corrupt, duplicate, reorder, or otherwise alter data.

Saving the same unchanged state twice should normally produce logically equivalent results.

## 5. SAVE FAILURE SAFETY

Force saving to fail where practical.

Examples:

- Invalid path
- Missing directory
- Permission denied
- Read-only destination
- Destination disappears
- Serialization failure
- Disk/write failure where reasonably testable

A failed save must NEVER cause the application to believe the work was successfully saved.

The dirty flag must remain correct.

Existing valid saved data should not be destroyed by a partially completed save.

Where practical, use safe/atomic persistence patterns such as writing to a temporary file and replacing the destination only after the new data has been written successfully.

## 6. IMPORT SEMANTICS

Treat importing as potentially destructive to current application state.

Test:

Import with nothing currently loaded.

Import while another project is loaded.

Import while current work has unsaved changes.

Import → Cancel.

Import invalid file.

Import corrupt file.

Import unsupported file.

Import empty file.

Import partially valid data.

Import same file twice.

Import very large data.

Import file that references missing external resources.

An unsuccessful or canceled import should not destroy the currently valid working state.

Where possible:

Parse and validate incoming data BEFORE replacing the currently loaded project.

Do not clear the current project first and then discover the import failed.

## 7. CANCEL MUST MEAN CANCEL

Audit EVERY multi-step workflow for transactional cancellation semantics.

Examples:

Import → file picker → Cancel

Export → destination picker → Cancel

Save As → picker → Cancel

Open → unsaved changes prompt → Cancel

Close application → unsaved changes prompt → Cancel

Switch project → unsaved changes prompt → Cancel

Cancel should return the user to the previous valid state.

It should not partially execute the requested operation.

Pay special attention to nested sequences such as:

User chooses Open New Project.

Application detects unsaved work.

Application asks Save / Don't Save / Cancel.

If Save:
    Save itself might succeed, fail, or be canceled.

ONLY continue opening the new project if the resulting state actually permits it.

For example:

```text
Open New
→ Unsaved Changes
→ Save
→ Save As dialog
→ CANCEL
```

must NOT continue opening the new project.

The entire higher-level operation should abort.

This class of chained-cancellation bug deserves aggressive testing throughout the application.

## 8. UNSAVED-CHANGES GUARDS

Identify EVERY operation capable of replacing or destroying the current working state.

Examples:

- New
- Open
- Import
- Reload
- Close project
- Close window
- Exit application
- Switch project
- Reset
- Restore defaults
- Delete current item

Ensure unsaved work is handled consistently.

Do not implement this protection separately in ten event handlers if it can reasonably be centralized.

There should ideally be one authoritative mechanism for asking:

"Can the current work safely be abandoned?"

## 9. SAVE / DON'T SAVE / CANCEL

Where applicable, verify all three branches independently.

SAVE:
Attempt saving.
Proceed ONLY if saving succeeds.

DON'T SAVE:
Discard and proceed intentionally.

CANCEL:
Do nothing and return to the current work.

A common bug to hunt aggressively:

The caller interprets "Save was requested" as "Save succeeded."

Those are NOT equivalent.

## 10. PROJECT/WORK FILE IDENTITY

Make sure the application always knows what the currently loaded work actually represents.

Check:

- Current filename
- Current path
- Displayed project/document name
- Window title
- Recent-file entries
- Save destination
- Export destination

Test:

```text
Open A
→ edit
→ Save As B
→ edit
→ Save
```

The final Save should go to B, not A.

Likewise:

```text
Open A
→ attempt Open B
→ B fails to load
```

The application should normally remain on A, with A's identity and state intact.

## 11. WORKING STATE VS PERSISTED STATE

Clearly distinguish:

Current in-memory working state

from:

Last successfully persisted state.

Do not update "last saved" metadata, clean/dirty state, filename identity, recent files, status messages, or other persistence indicators until the save actually succeeds.

## 12. EXTERNAL RESOURCE REFERENCES

If projects reference external files such as images, assets, templates, source files, etc., test what happens when those resources:

- Move
- Are renamed
- Are deleted
- Become inaccessible
- Are modified externally
- Have relative paths
- Have absolute paths
- Exist on another machine
- Exist on removable/network storage

Determine whether resources should be:

- Embedded
- Copied
- Referenced relatively
- Referenced absolutely

Ensure the application's behavior matches its intended portability model.

## 13. CRASH / INTERRUPTION RESILIENCE

Think about what happens if the application dies during:

- Import
- Editing
- Save
- Export
- Autosave
- Shutdown

Do not leave obviously corrupt persistence files where a safer approach is practical.

If autosave/recovery exists, test it thoroughly.

If it does not exist, determine whether the application's workflow actually warrants it before adding anything.

Do not add unnecessary complexity solely because autosave sounds nice.

## 14. MULTIPLE ITEMS / PROJECTS

If the application edits multiple objects, documents, records, items, etc., test transitions between them.

```text
Edit A
→ select B
→ return to A

Edit A
→ save
→ select B
→ edit
→ select A

Edit A
→ delete A

Edit A
→ reorder collection

Edit A
→ filter/search so A disappears
```

Make sure edits are committed or retained according to the application's intended model.

Never allow switching selection to silently discard edits unless that behavior is explicitly intentional and obvious.

## 15. IMPORT → EDIT → SAVE → RELOAD ROUND-TRIP

Create a dedicated end-to-end test containing as many supported features as practical.

Import representative data.

Then deliberately modify:

- Text
- Numeric values
- Selections
- Options
- Styles
- Assets
- Ordering
- Metadata
- Whatever else the application supports

Save it.

Completely restart the application.

Reload it.

Verify EVERYTHING.

Then edit the restored data again.

Save again.

Restart again.

Reload again.

Verify again.

This catches persistence bugs that unit tests around serialization frequently miss.

## 16. EXPORT IS NOT SAVE

If the application has both Save and Export, ensure they have clearly distinct semantics.

Exporting should not accidentally:

- Mark the project saved
- Change the project filename
- Clear dirty state
- Change the working directory unexpectedly
- Replace source data
- Modify editable state

unless explicitly designed to do so.

Likewise, saving project/workflow state should not accidentally behave like final export.

## 17. RECENT FILES / REOPEN

If recent-file functionality exists, test:

- Valid recent file
- Deleted recent file
- Moved recent file
- Corrupt recent file
- Duplicate recent entries
- Save As changing identity
- Recent list persistence
- Opening recent file with current unsaved work

A broken recent-file entry should not destabilize the application.

## 18. STATUS COMMUNICATION

The user should always be able to reasonably understand:

- What is currently loaded
- Whether it has unsaved changes
- Whether an operation is happening
- Whether saving succeeded
- Whether saving failed
- Whether importing succeeded
- Whether importing failed
- What file/project they are currently editing

Avoid misleading transient messages such as "Saved" when only part of the operation succeeded.

## 19. TEST COMPLETE USER JOURNEYS

Do not only test isolated features.

Perform complete realistic sessions such as:

```text
SESSION A:
Launch
→ Import
→ Edit
→ Save
→ Edit
→ Save
→ Exit
→ Restart
→ Reopen
→ Continue editing
→ Save
→ Export
→ Exit

SESSION B:
Launch
→ Import
→ Edit
→ Attempt Open
→ Save prompt
→ Cancel
→ Continue editing
→ Save
→ Open another project

SESSION C:
Launch
→ Open
→ Edit
→ Close
→ Choose Save
→ Save fails
→ Verify application DOES NOT close and work remains intact

SESSION D:
Launch
→ Open A
→ Edit
→ Open B
→ Choose Save
→ Cancel Save As
→ Verify A remains loaded with edits intact

SESSION E:
Launch
→ Open A
→ Attempt Import B
→ Import B fails
→ Verify A remains completely intact

SESSION F:
Launch
→ Create/import
→ Make extensive changes
→ Save
→ Restart
→ Verify state
→ Modify
→ Save again
→ Restart
→ Verify state again
```

Create additional journeys specific to THIS application.

## 20. THE GOLDEN RULE

At every potentially destructive workflow transition, ask:

"What happens to the user's current work if the NEXT operation fails or they press Cancel?"

The safe pattern should generally be:

```text
PRESERVE CURRENT VALID STATE
→ attempt new operation
→ validate new result
→ commit transition only after success
```

rather than:

```text
DESTROY CURRENT STATE
→ attempt operation
→ hope it succeeds.
```

Treat user-created work as precious.

A UI inconvenience is annoying.

Silent loss or corruption of someone's work is unacceptable.

## WORKING PRACTICE

Work in small, provable steps:

- For every bug fix, write the regression test first and see it fail on the unfixed code; a test that passes either way proves nothing.
- Commit one fix (or one tightly coupled group) per commit, with the problem named in the subject, so each fix can be reverted or bisected on its own. A commit is not a release.
- After any scripted or bulk edit, run `git diff --stat` before building and check for surprises: 0-byte files, whole-file churn, line-ending or byte-order-mark changes.
- If a related gap is cheap to test (minutes), write the test instead of listing it.
- On a long session, keep findings and progress in a file at a durable location (the repository's docs folder, or another fixed path the user agrees to), not only in the conversation or a temporary folder, so nothing is lost if the session ends or context is compacted.
- Keep the user informed: post one line when each significant fix lands and whenever a wait lasts longer than about five minutes, saying what is being waited on.

The final report must also include:

- **Changes to documented behavior:** every change a user could notice (behavior, output format or ordering, public API, saved formats, defaults), or "none".
- Fixes split into code changes and documentation-only changes, counted separately.
- For every item left unfixed: your recommended option and its cost, so the user can decide without another round trip.

## FINAL VERIFICATION

When you believe the workflow hardening pass is complete, assume you missed things and make another pass through every destructive transition.

Review your own changes critically.

Then:

1. Build the project cleanly.
2. Run the full relevant test suite, including the regression tests added during this pass.
3. Re-run the Import → Edit → Save → Reload round-trip test.
4. Re-run every complete user journey, including the successful, failed, canceled, repeated, and interrupted paths.
5. Recheck every Save / Don't Save / Cancel branch and every chained cancellation.
6. Review the final diff for accidental behavior changes, especially to file formats and persisted data.
7. Remove debugging artifacts and generated test data introduced during the work.

Do not declare completion simply because the application builds and the tests pass.

## FINAL REPORT

After completing the work, provide a concise report containing:

- Data-loss, corruption, and overwrite bugs fixed
- Workflow transitions hardened
- Cancellation and unsaved-changes bugs fixed
- Persistence/round-trip gaps fixed
- Tests added or changed
- User journeys exercised, and how
- Remaining risks to user work
- Anything you intentionally did NOT change and why

Do not pad this with trivial changes.

Do not finish this pass until you have deliberately exercised the application's major workflows end-to-end, including successful, failed, canceled, repeated, and interrupted paths.