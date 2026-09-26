# UI/UX Review & Hardening Prompt

I want you to perform an extremely thorough, no-stone-unturned UI/UX hardening, consistency, and behavioral testing pass over this application.

This is NOT just a visual polish pass.

Treat the UI as a complete stateful system that must remain visually consistent, logically correct, predictable, difficult to misuse, and robust under normal use, unusual use, cancellation, repeated actions, invalid states, and unexpected interaction sequences.

I want you to behave simultaneously like:

- A meticulous UI/UX engineer
- A hostile QA tester
- A user who clicks things in weird orders
- A user who changes their mind halfway through operations
- A user who double-clicks things
- A user who resizes everything
- A user who opens dialogs and cancels them
- A user who tries controls when the application isn't ready for them
- A user who expects every similar-looking control to behave consistently

Do not merely produce a review report.

When you find clear problems, FIX them.

Preserve the application's intended functionality and general design language. The objective is refinement, consistency, robustness, and correctness—not redesigning the application for the sake of redesigning it.

Adapt this review to the actual UI framework, technology, architecture, and purpose of this application. Identify application-specific UI states, workflows, and failure modes that are not explicitly mentioned below.

Do not mechanically treat this as a checklist.

---

# 1. FIRST UNDERSTAND THE UI

Before changing things, inspect the application and determine:

- Major screens/views/windows
- Dialogs
- Menus
- Toolbars
- Tabs
- Panels
- Forms
- Lists/tables/trees
- Editors
- Status areas
- Navigation model
- Main workflows
- Application state model
- Selection state
- Editing state
- Loading/busy state
- Error state
- Empty state
- Unsaved/dirty state
- Modal vs non-modal interactions
- Operations involving files/folders
- Operations that modify or destroy data

Understand what controls SHOULD be available in each state.

Do not evaluate individual controls in isolation.

Think about the UI as a state machine.

---

# 2. UI STATE CORRECTNESS

This is extremely important.

For every meaningful application state, determine which controls should be:

- Enabled
- Disabled
- Visible
- Hidden
- Selected
- Checked
- Read-only
- Editable
- Focusable

A control should not be usable simply because the underlying operation will eventually reject it.

Prevent invalid actions at the UI level whenever practical.

Examples:

If nothing is selected:
- Disable actions requiring a selection.

If no document/project/file is loaded:
- Disable actions requiring one.

If an operation is already running:
- Disable actions that would conflict with it.

If there are no changes:
- Disable Save/Apply where appropriate.

If something is read-only:
- Disable editing controls.

If an option only applies when another option is enabled:
- Disable or hide it appropriately.

If the application enters a different mode:
- Immediately update every affected control.

Do not leave controls enabled that effectively do nothing.

Audit state transitions carefully.

Look for stale UI state after:

- Opening something
- Closing something
- Creating something
- Deleting something
- Selecting something
- Deselecting something
- Canceling
- Saving
- Loading
- Reloading
- Importing
- Exporting
- Undo/redo
- Errors
- Failed operations
- Switching tabs
- Switching documents/projects/items
- Resetting
- Returning from dialogs

Ask constantly:

"Is every control showing the correct state RIGHT NOW?"

---

# 3. CANCELLATION PATHS

Aggressively test cancellation.

This deserves special attention.

For EVERY dialog or operation that can be canceled:

- Open it.
- Cancel it.
- Press Escape if appropriate.
- Close it using the X.
- Back out at different stages.
- Cancel after previously completing the operation successfully.

Cancellation should be a true no-op unless explicitly designed otherwise.

Examples:

If the user clicks Browse and cancels the file picker:

DO NOT:
- Open another file dialog
- Clear an existing path
- Trigger loading
- Trigger validation
- Show an error
- Modify application state
- Treat an empty filename as a real filename
- Continue to the next step
- Reopen the dialog
- Perform an operation using stale data

The operation should simply stop.

Audit every file picker, folder picker, confirmation dialog, color picker, editor dialog, import/export dialog, and other modal interaction for this class of bug.

Also look for accidental fall-through such as:

if canceled -> continue anyway

or:

if canceled -> use previous/default value

unless that behavior is explicitly intended.

---

# 4. BUTTON CONSISTENCY

Perform a complete button consistency audit.

Look at:

- Width
- Height
- Padding
- Margins
- Corner radius
- Font
- Font size
- Font weight
- Icon size
- Icon placement
- Text alignment
- Hover state
- Pressed state
- Disabled state
- Focus state
- Default-button treatment
- Destructive-button treatment

Buttons serving similar purposes should look and behave similarly.

Avoid situations like:

[ Save ]

[        Cancel        ]

[OK]

when those buttons logically belong to the same visual group.

Where appropriate:

- Use common widths.
- Align button edges.
- Maintain consistent spacing.
- Keep button groups visually balanced.
- Keep primary/secondary actions consistent.

Do not blindly force every button in the entire application to identical dimensions. Context matters.

The goal is visual consistency, not mechanical uniformity.

---

# 5. CONTROL CONSISTENCY

Perform the same audit for:

- Text boxes
- Combo boxes
- Dropdowns
- Checkboxes
- Radio buttons
- Sliders
- Numeric controls
- Lists
- Trees
- Tables
- Tab controls
- Group boxes
- Property editors
- Search boxes
- Toolbars
- Context menus
- Status bars
- Splitters

Similar controls in similar contexts should have consistent:

- Height
- Width conventions
- Padding
- Margins
- Fonts
- Alignment
- Label placement
- Border treatment
- Disabled appearance
- Focus appearance

Look for subtle inconsistencies that make the application feel homemade or unfinished.

---

# 6. ALIGNMENT AND SPACING

Inspect the UI carefully for:

- Misaligned labels
- Misaligned controls
- Uneven margins
- Uneven padding
- Inconsistent gaps
- Controls that are 2-5 pixels off from their neighbors
- Inconsistent section spacing
- Text that isn't vertically centered
- Buttons that don't align
- Different left edges that should match
- Different right edges that should match
- Poor visual grouping
- Awkward empty space
- Crowded sections
- Accidental whitespace

Look at the UI as geometry.

Controls that visually belong together should look like they belong together.

---

# 7. WIDTH AND SIZING

Review control widths intelligently.

Look for:

- Text fields that are unnecessarily tiny
- Controls much wider than their expected content
- Buttons with inconsistent widths
- Labels being clipped
- Dropdown contents being clipped
- Columns too narrow for common values
- Columns absurdly wide for their contents
- Dialogs unnecessarily large
- Dialogs unnecessarily cramped

Prefer sensible sizing based on expected content.

---

# 8. WINDOW RESIZING

Aggressively resize every resizable window.

Test:

- Minimum width
- Minimum height
- Very wide windows
- Very tall windows
- Maximized windows
- Restored windows
- Rapid resizing
- Different aspect ratios

Look for:

- Controls overlapping
- Controls disappearing
- Clipped text
- Broken anchoring
- Huge unexplained gaps
- Buttons drifting into strange positions
- Lists not expanding
- Editors not expanding
- Fixed-size controls that should stretch
- Stretching controls that should remain fixed
- Bottom controls disappearing
- Horizontal scrollbars appearing unnecessarily
- Content becoming unusable

Define reasonable minimum window sizes where appropriate.

Do not allow resizing into obviously broken layouts.

---

# 9. DIALOG BEHAVIOR

Audit every dialog.

Check:

- Correct owner/parent
- Correct modality
- Initial position
- Appropriate size
- Correct title
- Correct default button
- Correct Cancel behavior
- Escape behavior
- Enter behavior
- X/close behavior
- Focus placement
- Tab order
- Validation
- Whether it can accidentally open twice
- Whether parent UI becomes incorrectly usable
- Whether closing the parent leaves an orphaned dialog

Dialog results must be handled explicitly.

Never assume closing a dialog means success.

---

# 10. FILE AND FOLDER DIALOGS

Audit EVERY file/folder operation.

Check:

- Open
- Save As
- Import
- Export
- Select Folder
- Select Image
- Select configuration
- Any custom picker

Verify:

- Cancel does nothing.
- Initial directory makes sense.
- File filters make sense.
- Default extensions make sense.
- Existing-file behavior makes sense.
- Overwrite behavior is safe.
- Invalid paths are handled.
- Missing files are handled.
- Permission failures are handled.
- The UI doesn't freeze during slow operations.
- Recent/previous paths aren't used incorrectly.
- Multiple dialogs don't accidentally appear.

Test canceling these repeatedly.

---

# 11. KEYBOARD BEHAVIOR

Use the application without the mouse.

Check:

- Tab order
- Shift+Tab
- Enter
- Escape
- Arrow keys
- Space
- Common shortcuts
- Menu accelerators
- Delete
- F2 or editing shortcuts where applicable
- Ctrl+C/V/X/A
- Ctrl+Z/Y where supported

Focus should move logically.

Hidden or disabled controls should not unexpectedly receive focus.

Enter should not accidentally trigger destructive actions.

Escape should cancel/close where users reasonably expect it.

---

# 12. FOCUS MANAGEMENT

Look for:

- Focus disappearing
- Focus moving somewhere surprising
- Focus returning to the wrong control after dialogs
- Newly opened dialogs having no useful initial focus
- Deleted controls/items leaving weird focus state
- Keyboard input going to the wrong component
- Selection changing unexpectedly after operations

After an operation, ask:

"Where would the user naturally expect the keyboard focus to be?"

---

# 13. DOUBLE-CLICK / RAPID CLICK TESTING

Pretend the user has absolutely no patience.

Rapidly click things.

Double-click buttons that normally expect one click.

Look for:

- Duplicate dialogs
- Duplicate imports
- Duplicate saves
- Duplicate objects
- Multiple asynchronous operations
- Duplicate events
- Reentrant operations
- State corruption
- Double deletion
- Multiple confirmation dialogs
- Buttons remaining enabled while their action is already executing

Long-running actions should generally prevent accidental duplicate invocation.

---

# 14. SELECTION BEHAVIOR

Test:

- Nothing selected
- One item selected
- Multiple items selected
- Selecting then deleting
- Selecting then switching views
- Selecting then reloading
- Selecting an item that becomes invalid
- Selection after sorting/filtering
- Selection after adding an item
- Selection after removing an item

Make sure dependent controls update immediately.

Never leave UI displaying properties/actions for an object that no longer exists.

---

# 15. EMPTY STATES

Test the application with:

- No project/document loaded
- Empty collections
- Empty directories
- No search results
- No recent items
- No selectable items
- Brand-new installation/configuration
- Missing optional resources

The UI should remain coherent.

Empty states should not look like broken states.

---

# 16. TEXT AND LABEL CONSISTENCY

Audit wording.

Look for inconsistent terminology such as:

"Remove" in one place
"Delete" elsewhere
"Load" elsewhere
"Open" elsewhere

when they mean the same thing.

Check:

- Capitalization
- Punctuation
- Terminology
- Singular/plural
- Button labels
- Tooltips
- Menu items
- Dialog titles
- Status messages
- Error messages

Use the same words for the same concepts.

Avoid technical implementation terminology leaking into user-facing UI unless the application is specifically intended for technical users.

---

# 17. ERROR UI

Force operations to fail where practical.

Test things like:

- Missing files
- Invalid files
- Permission failures
- Invalid values
- Corrupt data
- Failed imports
- Failed exports
- Unavailable resources
- Invalid paths

Errors should:

- Explain what failed
- Provide useful context
- Not destroy valid existing state
- Not leave the UI disabled forever
- Not leave progress indicators running
- Not trigger secondary errors
- Not generate cascades of dialogs
- Not expose ugly raw exceptions unnecessarily

After dismissing an error, the application should remain usable whenever recovery is possible.

---

# 18. VALIDATION

Test every editable field.

Try:

- Empty input
- Whitespace
- Extremely long input
- Minimum values
- Maximum values
- Values just outside valid ranges
- Negative numbers
- Zero
- Decimal values
- Unexpected characters
- Unicode
- Pasted input
- Leading/trailing whitespace
- Duplicate values

Validation should occur at an appropriate time.

Do not bombard the user with error dialogs on every keystroke.

Prevent impossible values where the UI control itself can reasonably enforce the restriction.

---

# 19. UNSAVED CHANGES / DIRTY STATE

If applicable, thoroughly test unsaved changes.

Check:

- Edit -> Save
- Edit -> Close
- Edit -> Open another item
- Edit -> Exit
- Edit -> Cancel
- Edit -> Undo back to original
- Save failure
- Save As cancellation

Never silently discard meaningful user work.

But also don't annoy users with "unsaved changes" prompts when nothing actually changed.

---

# 20. DESTRUCTIVE ACTIONS

Review delete/remove/reset/overwrite/replace operations.

Make sure confirmation behavior is proportional to the consequence.

Avoid both extremes:

- Dangerous actions occurring accidentally
- Endless confirmation dialogs for trivial reversible operations

After destructive actions, make sure:

- Selection updates
- Dependent controls update
- Preview/property panels update
- Undo state updates if applicable
- Empty states appear correctly
- Stale references disappear

---

# 21. LOADING / BUSY STATES

For operations that take noticeable time:

Check:

- Busy indicator
- Progress indicator if appropriate
- Disabled conflicting controls
- Cancellation if appropriate
- Cursor state
- Status messages
- Completion state
- Error state

The UI should never appear ready for an action that cannot currently be performed.

Most importantly:

MAKE SURE THE UI RETURNS TO NORMAL AFTER FAILURE.

Look for code paths where:

busy = true

happens, but:

busy = false

doesn't happen on every exit path.

---

# 22. UI STATE SHOULD REFLECT REAL STATE

Never let visual state lie.

Examples:

- Checked toggle while feature is actually off
- Save button enabled when nothing changed
- Selected item that no longer exists
- "Connected" while disconnected
- Progress spinner after operation finished
- Editable control while underlying object is read-only
- Old preview after loading a new object failed
- Status text describing the previous operation

Synchronize UI state with actual application state.

---

# 23. TOOLTIP AUDIT

Check whether controls whose purpose isn't obvious need tooltips.

Tooltips should explain useful information, not simply repeat the label.

Bad:

Button: Export
Tooltip: Export

Useful:

Button: Export
Tooltip: Export the current card as a PNG image.

Do not add tooltips to everything indiscriminately.

---

# 24. VISUAL HIERARCHY

Make sure the UI clearly communicates:

- Primary action
- Secondary actions
- Dangerous actions
- Major sections
- Selected item
- Disabled functionality
- Editable vs read-only information

The user should not have to inspect every control to understand what matters.

Do this while respecting the application's existing design language.

---

# 25. COLORS AND THEMING

If the application supports themes or dark mode, test them.

Look for:

- Hardcoded colors
- Invisible text
- Poor contrast
- Icons disappearing
- Disabled text becoming unreadable
- Selection highlighting problems
- Hover states with poor contrast
- Borders disappearing
- Controls using inconsistent backgrounds

Avoid hardcoded visual values when the framework provides theme-aware resources.

---

# 26. DPI / DISPLAY SCALING

Where applicable, inspect behavior at different scaling levels such as:

- 100%
- 125%
- 150%
- 200%

Look for:

- Clipped labels
- Overlapping controls
- Tiny icons
- Blurry assets
- Dialogs too small
- Incorrect fixed pixel assumptions
- Buttons unable to contain their text

The application should not only work on the developer's exact monitor configuration.

---

# 27. LONG / UNUSUAL CONTENT

Test the UI with realistic worst-case content.

Examples:

- Very long filenames
- Very long paths
- Long object names
- Long descriptions
- Large numbers
- Hundreds/thousands of items
- Unicode characters
- Spaces
- Special characters

Look for:

- Layout destruction
- Text overflowing
- Columns becoming unusable
- Giant dialogs
- Missing ellipsis
- Horizontal scrolling nightmares
- Tooltips needed for truncated content

---

# 28. SCROLLING

Inspect every scrollable region.

Check:

- Scrollbars appear only when appropriate.
- Mouse wheel works where expected.
- Keyboard scrolling works.
- Nested scroll areas aren't miserable to use.
- Content isn't permanently hidden.
- Horizontal scrolling isn't introduced unnecessarily.
- Scrolling doesn't unexpectedly change selections or values.

---

# 29. LISTS / TABLES / TREES

For every collection UI, test:

- Empty
- One item
- Many items
- Very many items
- Long item names
- Sorting
- Filtering
- Adding
- Removing
- Renaming
- Refreshing
- Selection preservation
- Multi-selection if supported

Look for stale rows, duplicates, selection bugs, poor column sizing, and performance degradation.

---

# 30. MENUS AND CONTEXT MENUS

Audit all menus.

Check:

- Enabled/disabled state
- Checked state
- Radio state
- Shortcuts
- Duplicate commands
- Consistent wording
- Logical grouping
- Separators
- Commands appearing when meaningless

Context menus should reflect the object/context they were opened on.

A context menu should not offer an operation that cannot currently work.

---

# 31. DEFAULTS

Review defaults throughout the UI.

Ask:

"If the user never changes this setting, is the resulting behavior sensible?"

Check default:

- Selections
- Values
- Paths
- Formats
- Options
- Checkboxes
- Window sizes
- Column widths
- Export settings
- File types

Defaults should make the common path easy.

---

# 32. PERSISTED UI STATE

If UI settings persist between sessions, test:

- Window position
- Window size
- Splitter positions
- Recent paths
- Recent files
- Selected options
- Column sizes
- User preferences

Make sure persisted values cannot make the application unusable.

Examples:

- Window saved off-screen
- Zero-width panel
- Invalid previous directory
- Previously selected item no longer exists

Recover gracefully.

---

# 33. STARTUP AND SHUTDOWN

Test the UI from a completely fresh start.

Also test repeated open/close cycles.

Look for:

- Flashing incorrect UI state during startup
- Controls temporarily enabled before initialization
- Dialogs appearing unexpectedly
- Stale previous-session state
- Shutdown exceptions
- Operations continuing after shutdown begins
- Unsaved work handling
- Background operations preventing exit
- Windows/dialogs remaining alive after the main window closes

---

# 34. WEIRD USER SEQUENCES

Do things in orders the developer probably didn't expect.

Examples:

Open -> Cancel -> Open -> Cancel -> Open successfully

Select -> Delete -> immediately click Edit

Start operation -> switch tabs -> return

Open dialog -> close parent

Change setting -> cancel -> reopen

Import -> fail -> import again

Save -> Save again

Rapidly change selections

Repeatedly toggle options

Close and reopen the same dialog many times

Use keyboard and mouse simultaneously

Try to trigger an operation while another is completing.

Look specifically for state-machine bugs.

---

# 35. EVENT HANDLER PROBLEMS

Inspect the implementation for:

- Duplicate event subscriptions
- Event handlers attached multiple times
- Missing unsubscription
- Recursive change events
- Initialization accidentally triggering user-action handlers
- Programmatic changes causing unintended operations
- Multiple handlers performing overlapping work
- UI updates firing expensive operations repeatedly

Distinguish programmatic state synchronization from actual user intent where necessary.

---

# 36. UI/BUSINESS LOGIC BOUNDARY

Look for cases where fragile UI behavior exists because business logic is buried directly inside event handlers.

Do not rewrite the architecture unnecessarily, but improve separation where it clearly makes behavior safer and easier to reason about.

UI event handlers should ideally coordinate operations rather than contain enormous amounts of unrelated logic.

---

# 37. ACCESSIBILITY BASICS

Without turning this into a massive accessibility redesign, check obvious issues:

- Keyboard accessibility
- Logical tab order
- Focus visibility
- Labels associated with controls
- Meaningful accessible names where supported
- Information conveyed only by color
- Reasonable contrast
- Controls usable without precision mouse movement

Fix obvious problems.

---

# 38. CONSISTENCY PASS

After functional testing, perform a dedicated visual consistency pass across EVERY screen.

Compare screens side by side conceptually.

Look specifically for:

- Same concept represented differently
- Different margins
- Different button heights
- Different label alignment
- Different fonts
- Different control heights
- Different capitalization
- Different dialog layouts
- Different OK/Cancel ordering
- Different spacing conventions
- Different naming conventions

Centralize shared styling/resources where doing so reduces accidental inconsistency.

---

# 39. DO NOT OVER-ENGINEER

Do not turn this into a redesign project.

Do NOT:

- Introduce a giant design system unnecessarily.
- Rewrite the UI framework.
- Replace working controls simply because another library exists.
- Add animations everywhere.
- Add unnecessary confirmation dialogs.
- Add tooltips to obvious controls.
- Introduce abstraction purely for abstraction's sake.
- Make arbitrary aesthetic changes based solely on personal preference.

Fix things that improve consistency, usability, predictability, correctness, maintainability, or robustness.

---

# 40. ACTUALLY RUN AND TEST THE UI

Do not rely exclusively on static source-code inspection if the environment allows the application to be run.

Build it.

Run it.

Interact with it.

Inspect the actual rendered UI.

Exercise workflows.

Resize windows.

Open dialogs.

Cancel dialogs.

Trigger errors.

Change selections.

Switch modes.

Use keyboard navigation.

Repeat operations.

Test weird sequences.

If automated UI testing infrastructure exists, use it.

If useful and practical, add focused UI tests for regressions discovered during this pass.

Static analysis alone is NOT sufficient for a UI hardening pass.

---

# 41. SCREEN-BY-SCREEN PASS

After the general review, revisit EVERY significant:

- Window
- Screen
- View
- Tab
- Dialog
- Popup
- Menu
- Context menu
- Editor
- Settings panel

For each one ask:

Does it look internally consistent?

Does it match the rest of the application?

Are controls aligned?

Are widths sensible?

Are actions available only when valid?

Does Cancel actually cancel?

Does Close actually close?

Does Save only save when appropriate?

Does the UI update after the action?

What happens if the action fails?

What happens if the user immediately does it again?

What happens if nothing is selected?

What happens with unusual input?

What happens at minimum window size?

What happens after returning to this screen later?

---

# 42. SECOND PASS: TRY TO BREAK YOUR OWN FIXES

After completing the first hardening pass, assume you missed things.

Make another pass.

This time specifically try to break the application.

Focus on:

- Cancellation
- Repeated operations
- Rapid clicking
- Invalid state transitions
- Stale selections
- Failed operations
- Dialog results
- Disabled/enabled states
- Resizing
- Focus
- Keyboard interaction
- Empty states
- Boundary values
- Startup/shutdown
- State restoration

Review your own changes for regressions.

---

# 43. FINAL POLISH PASS

Finally, inspect the application as though it were being shipped today.

Ask:

"Does anything about this UI make it feel unfinished?"

Look for the little things developers become blind to after staring at their own application:

- One weirdly sized button
- A label slightly out of alignment
- Inconsistent terminology
- An unnecessary popup
- A button that should be disabled
- A field that should be read-only
- A dialog that's too large
- A dialog that's too small
- A bad tab order
- A missing tooltip
- A stale status message
- An ugly error
- An operation that doesn't clearly indicate success/failure
- A Cancel button that isn't truly canceling
- An action that can accidentally execute twice
- A layout that breaks when resized
- A control whose state doesn't reflect reality

These details matter.

---

# FINAL VERIFICATION

When you believe the UI hardening pass is complete:

1. Build the project cleanly.
2. Run relevant automated tests.
3. Run the application.
4. Walk through all major workflows.
5. Exercise cancellation paths.
6. Exercise failure paths.
7. Exercise empty states.
8. Exercise selection changes.
9. Exercise resizing.
10. Exercise keyboard navigation.
11. Exercise rapid/repeated actions.
12. Recheck every dialog.
13. Recheck enabled/disabled states.
14. Recheck visual consistency.
15. Review the final diff for accidental behavior changes.

Do not declare completion simply because the application builds.

A UI can compile perfectly and still be full of bugs.

---

# FINAL REPORT

After completing the work, provide a concise report containing:

- UI behavioral bugs fixed
- State-management problems fixed
- Cancellation/dialog bugs fixed
- Layout/alignment improvements
- Consistency improvements
- Keyboard/focus improvements
- Validation/error-handling improvements
- Resizing/DPI improvements
- Tests added or changed
- Areas manually tested
- Remaining concerns
- Anything you intentionally did NOT change and why

Do not pad this with trivial changes.

The standard I want is:

"If a reasonably impatient user starts clicking around this application trying things in unexpected orders, does the UI remain coherent, predictable, and correct?"

And then:

"If I put every screen and dialog next to each other, does this look like ONE application designed intentionally, or a collection of screens built independently?"

Keep digging until both answers are satisfactory.