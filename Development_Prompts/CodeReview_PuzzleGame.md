# Deep Puzzle Game Logic / Gameplay / State Review

Perform an extremely thorough, no-stone-unturned review of this entire puzzle game.

This review focuses specifically on PUZZLE-GAME correctness and player-facing gameplay behavior.

It supplements general code, UI, workflow, performance, security, and testing reviews.

The objective is not merely:

> "Does the game launch and can I complete a puzzle?"

The objective is:

> Are the puzzle rules correct under every meaningful state, are puzzles solvable as intended, can player actions ever corrupt or softlock the game, do undo/restart/hints/save/resume work correctly, and does the game behave predictably no matter what order the player does things in?

Approach the game both as:

- A developer
- A tester
- A puzzle designer
- An impatient player
- A player deliberately trying to break the rules

Do not assume intended behavior from implementation alone.

Infer the actual game rules and verify the implementation consistently enforces them.

Adapt this review to the game's actual puzzle mechanics.

---

# 1. UNDERSTAND THE GAME FIRST

Before changing code, determine:

- What is the puzzle?
- What are the rules?
- What constitutes a legal move?
- What constitutes an illegal move?
- What constitutes progress?
- What constitutes failure?
- What constitutes success?
- Can puzzles have multiple valid solutions?
- Is there exactly one intended solution?
- Is randomness involved?
- Are puzzles generated or handcrafted?
- Are hints available?
- Is undo available?
- Is redo available?
- Can puzzles be restarted?
- Can puzzles be abandoned?
- Can progress be saved?
- Is there scoring?
- Is there a timer?
- Is there a move counter?
- Is there progression/unlocking?
- Are there difficulty levels?

Create a mental model of the game's state machine before modifying it.

---

# 2. ESTABLISH RULE INVARIANTS

Identify the fundamental rules that must ALWAYS remain true.

Examples might include:

- Pieces cannot occupy forbidden positions.
- Values remain within allowed ranges.
- Locked pieces cannot move.
- A tile cannot exist in two places simultaneously.
- Inventory counts cannot become negative.
- A completed row must satisfy the puzzle rule.
- Connections must remain valid.
- Player actions cannot create impossible internal state.

Adapt these to the actual game.

These invariants should guide both review and testing.

---

# 3. SINGLE SOURCE OF TRUTH FOR RULES

Look for puzzle rules implemented independently in multiple places.

For example:

UI says move is legal.

Game engine says move is illegal.

Hint system uses slightly different rules.

Win checker uses another implementation.

Puzzle generator uses another.

This is dangerous.

Where practical, centralize authoritative rule logic.

The same fundamental rule should not have five subtly different implementations.

---

# 4. LEGAL MOVE VALIDATION

Review every player action that modifies puzzle state.

Verify legal moves are accepted.

Verify illegal moves are rejected.

Test:

- Normal legal move
- Boundary legal move
- Clearly illegal move
- Almost-legal move
- Repeated move
- Move after completion
- Move during animation
- Move while another operation is pending

Do not rely solely on the UI preventing illegal actions.

The underlying game logic should protect its own invariants.

---

# 5. UI MUST NOT BE THE RULE ENGINE

Do not make game correctness depend entirely on disabled buttons, drag restrictions, or UI checks.

Programmatic calls, race conditions, saved games, hints, undo, or future UI changes may bypass them.

The underlying puzzle state/model should reject invalid transitions.

---

# 6. STATE REPRESENTATION

Review how puzzle state is represented.

Ask:

- Is there one authoritative state?
- Are there duplicated state variables?
- Can UI state disagree with game state?
- Are derived values stored unnecessarily?
- Can caches become stale?
- Is state mutation centralized?
- Are invariants maintained after every mutation?

Avoid having the same fact independently represented in several places.

---

# 7. DERIVED STATE

Values that can reliably be calculated from authoritative state should usually be derived rather than independently maintained.

Examples:

- Number of remaining pieces
- Whether puzzle is complete
- Available moves
- Current score components
- Valid targets

If derived values are cached for performance, verify invalidation rigorously.

---

# 8. INITIAL PUZZLE STATE

Test puzzle initialization.

Verify:

- Correct board dimensions
- Correct pieces
- Correct starting values
- Correct locked/unlocked states
- Correct inventory
- Correct objective
- Correct metadata
- Correct timer/move counter
- Correct difficulty
- Correct solution metadata where applicable

No stale state from the previous puzzle should survive.

---

# 9. NEW GAME

Starting a new game should fully reset everything that belongs to the old game.

Inspect:

- Board state
- Selection
- Hover state
- Hint state
- Undo history
- Redo history
- Timer
- Move count
- Score
- Completion flag
- Animation state
- Temporary highlights
- Cached solution data
- Puzzle identifier
- Random seed
- Failure state

Look aggressively for state leakage.

---

# 10. RESTART PUZZLE

Restart should restore the exact intended initial state of the CURRENT puzzle.

It should generally preserve puzzle identity.

Verify:

Current puzzle
→ make many changes
→ request restart
→ confirm if appropriate
→ exact original puzzle restored

Also verify:

- Timer semantics
- Move counter semantics
- Hint penalties
- Score behavior
- Undo/redo history
- Completion state

Follow intended design consistently.

---

# 11. UNDO

If Undo exists, test it aggressively.

Undo should restore the complete logical state before the previous player action.

Not merely the obvious visual portion.

Potential state includes:

- Piece positions
- Values
- Inventory
- Selection
- Counters
- Score
- Derived state
- Completion state
- Rule-specific metadata

Define exactly what constitutes one undoable action.

---

# 12. ATOMIC UNDO ACTIONS

One conceptual player action should normally undo as one action.

Example:

Player moves one piece.

Internally this might:

- Remove from A
- Add to B
- Update score
- Update candidates
- Update highlights

Undo should reverse the entire conceptual action, not require five Undo presses.

---

# 13. REDO

If Redo exists:

Test:

Move
→ Undo
→ Redo

The exact logical state should return.

Test multiple levels.

Test:

Move A
→ Move B
→ Undo B
→ Undo A
→ Redo A
→ Redo B

---

# 14. REDO INVALIDATION

Test:

Move A
→ Move B
→ Undo B
→ make Move C

Redo B should normally become unavailable.

Do not allow incompatible history branches unless branching history is explicitly a feature.

---

# 15. UNDO AT BOUNDARIES

Test:

- Undo with no history
- Redo with no history
- Undo after restart
- Undo after new puzzle
- Undo after load
- Undo after hint
- Undo after completion
- Undo while animation is running

Nothing should corrupt state.

---

# 16. COMPLETION DETECTION

Review how the game determines puzzle completion.

Completion must be based on actual puzzle correctness.

Do not rely solely on:

- All cells filled
- No pieces remaining
- Player pressed Check
- Visual arrangement looks complete

unless that genuinely defines success.

---

# 17. FALSE POSITIVE COMPLETION

Try to construct invalid states that superficially look finished.

Examples:

- Every slot occupied but arrangement invalid
- Duplicate values
- Missing hidden constraint
- Correct count but incorrect placement
- Visually connected but logically disconnected

The game must not declare victory incorrectly.

---

# 18. FALSE NEGATIVE COMPLETION

Also verify every valid solution is recognized.

This matters especially when puzzles can have multiple solutions.

Do not hardcode one exact arrangement if multiple states legitimately satisfy the rules.

---

# 19. MULTIPLE SOLUTIONS

Determine whether puzzles are intended to have:

- Exactly one solution
- At least one solution
- Multiple equivalent solutions

Ensure:

- Completion logic matches
- Hint logic matches
- Generator matches
- Validation matches
- Scoring does not assume uniqueness incorrectly

---

# 20. SOLVABILITY

Every puzzle presented as playable should be solvable under the game's actual rules.

For generated puzzles, validate solvability before presenting them.

For handcrafted puzzles, provide automated validation where practical.

Do not ship impossible puzzles accidentally.

---

# 21. UNIQUE-SOLUTION VALIDATION

If uniqueness is part of the design, verify it computationally where practical.

A puzzle with two solutions is not unique simply because the generator found one solution first.

Solver logic should be capable of determining whether additional solutions exist.

---

# 22. PUZZLE SOLVER

If practical for the puzzle type, implement or validate an internal solver.

The solver can support:

- Puzzle validation
- Generator validation
- Hint generation
- Difficulty analysis
- Automated testing
- Detecting impossible states

Keep solver logic separate from player-facing UI.

---

# 23. SOLVER CORRECTNESS

Test the solver independently.

Use:

- Known solvable puzzles
- Known impossible puzzles
- Known unique puzzles
- Known multi-solution puzzles
- Edge cases
- Minimal puzzles
- Complex puzzles

A buggy solver can poison generation, hints, and validation simultaneously.

---

# 24. PLAYER-CREATED UNSOLVABLE STATE

Determine whether legal player moves can make a puzzle unsolvable.

Depending on game design, this may be perfectly acceptable.

But distinguish:

"Player made a bad strategic move"

from:

"Game entered an internally impossible state because of a bug."

If dead ends are intentional, make sure restart/undo can recover.

---

# 25. SOFTLOCKS

Aggressively search for softlocks.

A softlock is a state where the application still runs but the player cannot meaningfully continue.

Examples:

- No legal moves but puzzle not failed/completed
- Required piece disappeared
- Input remains disabled
- Modal state never clears
- Animation state remains active forever
- Game thinks operation is still running
- Hint mode blocks input permanently
- Required UI control becomes inaccessible

Try deliberately to create these states.

---

# 26. HARDLOCKS / HANGS

Look for:

- Infinite solver loops
- Infinite generation loops
- Recursive explosion
- Deadlocks
- Unbounded searches
- UI-thread solver work

A pathological puzzle should not freeze the application forever.

---

# 27. PUZZLE GENERATION

If puzzles are generated, review the generator separately.

Verify:

- Generated state is valid
- Puzzle is solvable
- Required uniqueness exists
- Difficulty matches expectations
- Generation terminates
- Generated puzzles vary appropriately
- No illegal structures appear

---

# 28. GENERATE FROM A VALID SOLUTION

Where appropriate for the puzzle type, consider whether generation should begin from a known valid solved state and derive a puzzle from it.

This often provides stronger solvability guarantees than generating arbitrary partial states and hoping they work.

Use whatever method is mathematically appropriate for the game.

---

# 29. GENERATION FAILURE

Puzzle generation can fail.

Do not allow:

while (!validPuzzle)
{
    generateAgain();
}

to run forever without safeguards.

Use:

- Attempt limits
- Time limits
- Fallback generation
- Known-safe puzzles

where appropriate.

---

# 30. RANDOMNESS

If generation uses randomness:

Determine whether randomness should be:

- Fully random
- Seeded
- Reproducible
- Cryptographically secure

Puzzle generation normally does NOT need cryptographic randomness.

Support deterministic seeds where useful for:

- Debugging
- Testing
- Sharing puzzles
- Reproducing bugs

---

# 31. RECORD RANDOM SEEDS

For generated puzzles, consider recording the seed or equivalent generation identifier.

If a user reports:

"Puzzle #whatever is impossible"

the developer should ideally be able to recreate that exact puzzle.

Integrate this with diagnostics where appropriate.

---

# 32. SAME SEED = SAME PUZZLE

If seeded generation is part of the contract:

Same version + same rules + same seed

should produce the expected same puzzle.

If generation algorithms change between versions, account for generator versioning.

---

# 33. GENERATOR VERSIONING

If puzzle IDs/seeds need long-term reproducibility, store:

- Seed
- Generator version
- Relevant rule-set version

Otherwise a future generator update may make old puzzle IDs produce different puzzles.

---

# 34. DIFFICULTY

If difficulty levels exist, determine what they actually mean.

Possible factors:

- Number of moves
- Branching factor
- Required techniques
- Number of clues
- Search depth
- Constraint density
- Time pressure

Do not label difficulty solely from superficial properties unless justified.

---

# 35. DIFFICULTY VALIDATION

Test representative generated puzzles at each difficulty.

Look for:

- "Easy" puzzles that are absurdly difficult
- "Hard" puzzles solved trivially
- Extreme variance
- Difficulty cliffs

If difficulty is heuristic, document that fact internally.

---

# 36. HINT SYSTEM

Review hints as a separate puzzle-solving subsystem.

A hint should:

- Be legal
- Be relevant to current state
- Never suggest an impossible move
- Never corrupt state
- Respect current rules
- Handle already-completed puzzles
- Handle dead-end states

---

# 37. HINT CORRECTNESS

Where possible, derive hints from the same authoritative rules/solver used to validate puzzles.

Avoid maintaining a separate approximation of the rules.

Test hints after unusual player sequences.

---

# 38. HINTS AND MULTIPLE SOLUTIONS

If multiple solutions are valid, hints must not incorrectly insist that only one branch is correct unless the game intentionally chooses a canonical solution.

A hint should not invalidate a legitimate alternate solution.

---

# 39. HINT STATE MUTATION

Determine whether requesting a hint:

- Merely highlights something
- Reveals information
- Makes a move automatically
- Changes score
- Changes timer
- Changes hint count

Ensure all associated state changes are correct and undoable where intended.

---

# 40. REPEATED HINTS

Test:

Hint
→ Hint
→ Hint
→ Hint

Ensure:

- No duplicate nonsense
- No crashes
- No negative hint counters
- No impossible suggestions
- No stale highlights

---

# 41. HINT AFTER UNDO

Test:

Move
→ Hint
→ Undo
→ Hint

The new hint must correspond to CURRENT state, not cached previous state.

---

# 42. STALE ANALYSIS

Any asynchronous:

- Solver
- Hint calculation
- Validation
- Generation
- Preview

must not apply results to a puzzle that has since changed.

Use:

- Puzzle version
- Generation ID
- Cancellation
- State identity

as appropriate.

---

# 43. MOVE COUNTER

If moves are counted, define exactly what counts.

Examples:

- Successful legal move
- Attempted move
- Drag
- Rotation
- Swap
- Hint-applied move
- Undo
- Redo

Apply consistently.

Do not increment counters because a UI event happened if no logical move occurred.

---

# 44. SCORE

If scoring exists, centralize score rules.

Test:

- Normal move
- Excellent move
- Bad move
- Hint
- Undo
- Redo
- Restart
- Pause
- Completion
- Failure

Prevent:

- Negative score accidentally
- Double-awarded score
- Score farming through undo/redo
- Repeating completion reward
- Overflow

---

# 45. UNDO / SCORE EXPLOITS

Explicitly test whether players can manipulate scoring through:

Move
→ gain points
→ Undo
→ Redo
→ gain points again

or:

Hint
→ Undo
→ request same reward

Determine intended policy and enforce it.

---

# 46. TIMER

If timing exists, define exactly when timing begins and ends.

Possible events:

- Puzzle displayed
- First player interaction
- Countdown completion
- Resume

Determine intended behavior.

---

# 47. TIMER PAUSE

Test whether timer behavior is correct during:

- Pause
- Help screen
- Settings
- Modal dialog
- Application minimized
- Application backgrounded
- System sleep
- Save
- Loading

Follow intended game rules.

---

# 48. TIMER CLOCK SOURCE

Use an appropriate monotonic elapsed-time mechanism for durations where available.

Do not calculate gameplay duration solely by subtracting wall-clock timestamps if clock changes can corrupt results.

---

# 49. SYSTEM CLOCK CHANGES

If scores/times matter, consider:

Game starts
→ system clock changes
→ game completes

Elapsed time should remain sensible.

---

# 50. PAUSE EXPLOITS

If pausing exists, test whether players can:

- See puzzle while timer stopped
- Interact while paused
- Use keyboard shortcuts
- Trigger hints
- Modify state
- Exploit modal windows

Match intended behavior.

---

# 51. INPUT MODALITIES

Test all supported input methods.

Examples:

- Mouse
- Keyboard
- Touch
- Controller

Do not assume mouse-only behavior if keyboard/controller support exists.

---

# 52. RAPID INPUT

Act like an impatient player.

Try:

- Double-click
- Spam-click
- Rapid keyboard input
- Drag repeatedly
- Undo repeatedly
- Restart repeatedly
- Hint repeatedly
- New Game repeatedly

The game should not process one conceptual action multiple times accidentally.

---

# 53. INPUT DURING ANIMATION

Test interaction while pieces/tiles/UI are animating.

Decide whether input should:

- Be accepted
- Be queued
- Be ignored
- Cancel animation

Do not allow animation and logical state to diverge.

---

# 54. ANIMATION IS NOT GAME STATE

The logical game state must remain authoritative.

Do not make correctness depend on animation completion callbacks firing perfectly.

Animations should represent state, not define it, unless architecture explicitly requires transactional animation.

---

# 55. DRAG AND DROP

If drag-and-drop exists, test:

- Valid target
- Invalid target
- Drop outside board
- Drop onto original location
- Rapid drag
- Escape/cancel
- Window loses focus
- Mouse released outside window
- Target disappears

The dragged object must not vanish or duplicate.

---

# 56. SELECTION STATE

Test selection through:

- Move
- Undo
- Restart
- New game
- Load
- Completion
- Failure
- Dialog opening
- Hint

Selection should never refer to an object that no longer exists.

---

# 57. KEYBOARD SHORTCUTS

Test shortcuts in every relevant state.

Examples:

- Undo
- Redo
- Restart
- New Game
- Hint
- Pause

Ensure shortcuts do not bypass:

- Confirmation
- Disabled states
- Modal dialogs
- Game-over state

---

# 58. DOUBLE EXECUTION

Look for actions wired through multiple event paths.

Example:

Button click
and
keyboard command

both accidentally invoke the action twice.

Ensure one user action produces one logical action.

---

# 59. PUZZLE COMPLETION TRANSITION

When puzzle completion occurs:

- Freeze/transition gameplay appropriately.
- Record completion once.
- Record score/time once.
- Trigger celebration once.
- Save progression once.
- Disable inappropriate actions.
- Preserve result.

Avoid duplicate completion events.

---

# 60. COMPLETION REENTRANCY

Test:

Final move
→ completion handler begins
→ another event fires
→ completion handler invoked again

Protect completion processing from running multiple times.

---

# 61. ACTION AFTER COMPLETION

Try:

- Move
- Undo
- Hint
- Restart
- Save
- Click puzzle
- Keyboard input

after completion.

Define intentional behavior for each.

Do not let completed state mutate accidentally.

---

# 62. FAILURE STATE

If puzzles can be failed, define exact failure conditions.

Ensure failure triggers once.

Ensure player input afterward follows intended behavior.

Provide clear restart/retry path.

---

# 63. SAVE / RESUME

If puzzle progress is persisted, test:

Start puzzle
→ make moves
→ save/exit
→ restart application
→ resume

Verify exact meaningful state.

---

# 64. PERSISTED GAME STATE

Depending on the game, persistence may include:

- Puzzle ID
- Seed
- Generator version
- Board
- Moves
- Undo history
- Redo history
- Timer
- Score
- Hint usage
- Difficulty
- Completion status
- Progression

Decide deliberately what should survive restart.

---

# 65. SAVE DURING TRANSIENT STATE

Do not persist invalid halfway-through UI state accidentally.

Examples:

- Piece halfway through drag
- Animation halfway complete
- Hint calculation in progress
- Transition between puzzles

Persist a coherent logical state.

---

# 66. CORRUPT SAVE DATA

A corrupt saved game should not prevent the game from launching.

Handle:

- Missing fields
- Invalid values
- Unsupported version
- Impossible board state
- Corrupt file

Fail safely.

Offer a reasonable reset/new-game path.

---

# 67. SAVE VALIDATION

Do not blindly trust loaded state.

Validate loaded puzzle state against invariants.

Saved data may come from:

- Older versions
- Partial writes
- Corruption
- Manual modification
- Bugs in previous releases

---

# 68. SAVE VERSIONING

Version persisted puzzle state.

If format changes, support appropriate migration or safe rejection.

Do not deserialize arbitrary old state and hope it still means the same thing.

---

# 69. PROGRESSION

If puzzles/levels unlock over time, review progression carefully.

Test:

- First launch
- First completion
- Repeated completion
- Restart
- Load
- Multiple difficulty modes
- Final level
- Missing/corrupt progression data

Do not accidentally relock legitimately unlocked content.

---

# 70. COMPLETION CREDIT

Ensure completing the same puzzle repeatedly does not incorrectly grant one-time rewards multiple times unless intended.

Likewise ensure legitimate completion always grants expected progress.

---

# 71. ACHIEVEMENTS

If achievements exist:

Verify conditions using authoritative gameplay state.

Prevent accidental repeated awarding.

Test edge cases around:

- Undo
- Hints
- Restart
- Resume
- Difficulty

---

# 72. DAILY / SEEDED PUZZLES

If daily puzzles exist, verify:

- Correct date semantics
- Time zone policy
- Same intended puzzle for relevant players
- Reproducibility
- Offline behavior
- Date rollover
- Save/resume across rollover

Clearly define whether "day" means local time or some canonical time zone.

---

# 73. PUZZLE IDENTIFIERS

Every puzzle should have an identity useful for:

- Save/resume
- Bug reports
- Diagnostics
- Sharing
- Reproduction

For generated puzzles, consider including:

- Seed
- Generator version
- Difficulty

---

# 74. DIAGNOSTICS INTEGRATION

If a diagnostics system exists, record useful puzzle context without unnecessarily capturing sensitive information.

Examples:

- Puzzle ID
- Seed
- Generator version
- Difficulty
- Move number
- Current state hash
- Last player action
- Solver result
- Completion state

This can make reported "impossible puzzle" bugs reproducible.

---

# 75. STATE HASH

For complex deterministic puzzle state, consider generating a compact diagnostic state hash or canonical representation.

This can help identify whether two bug reports involve identical logical states.

Do not add this if it provides no practical diagnostic value.

---

# 76. REPLAY / ACTION HISTORY

For suitable games, consider maintaining a lightweight logical action history.

Example:

Puzzle seed: X

Move 1: A → B

Move 2: Rotate C

Move 3: Swap D/E

This can be extremely useful for:

- Undo
- Bug reproduction
- Automated testing
- Diagnostics

Do not record raw mouse coordinates when logical actions are sufficient.

---

# 77. DETERMINISTIC REPLAY

If practical, test whether:

Initial puzzle + logical action sequence

reconstructs the same resulting state.

This is powerful for debugging.

Do not force event-sourcing architecture on a simple game merely for this feature.

---

# 78. INVALID REPLAY

If replay/history exists, invalid actions should fail safely.

Do not let corrupt history create impossible state.

---

# 79. PUZZLE DATA VALIDATION

If puzzles are loaded from files/resources/database:

Validate them before gameplay.

Check:

- Required fields
- Dimensions
- Piece counts
- Rule constraints
- Solution existence
- Unique solution where required
- References
- Metadata

Bad puzzle content should be caught before the player invests time.

---

# 80. CONTENT VALIDATION TOOL

If the project contains many handcrafted puzzles, consider building an automated validation test/tool that scans ALL puzzle content.

Report:

- Invalid puzzles
- Unsolvable puzzles
- Duplicate IDs
- Missing assets
- Invalid metadata
- Multiple solutions where prohibited

This can prevent content regressions.

---

# 81. PUZZLE DUPLICATION

If generated or curated puzzles should be distinct, check for unintended duplicates.

Use canonicalization/state equivalence where appropriate.

Do not overcomplicate this if duplicate puzzles are harmless.

---

# 82. SYMMETRY

For puzzles with rotational/reflection symmetry, determine whether apparently different puzzles are actually equivalent.

This may matter for:

- Generation diversity
- Duplicate detection
- Difficulty
- Solution counting

Only implement symmetry normalization if relevant to the puzzle.

---

# 83. SOLVER PERFORMANCE

Measure solver behavior on:

- Easy puzzle
- Typical puzzle
- Hard puzzle
- Pathological puzzle
- Impossible puzzle
- Multi-solution puzzle

An impossible puzzle can sometimes be more expensive to prove impossible than a valid puzzle is to solve.

Prevent unbounded UI freezes.

---

# 84. GENERATOR PERFORMANCE

Measure puzzle generation.

Do not allow users to stare at a frozen screen while random generation retries thousands of times.

Consider background generation or pre-generation where appropriate.

---

# 85. HINT PERFORMANCE

Hints should normally feel responsive.

If hint computation is expensive:

- Run appropriately in background.
- Support cancellation/staleness.
- Provide progress only if genuinely necessary.

Do not block gameplay indefinitely.

---

# 86. LARGE / COMPLEX PUZZLES

Test the largest supported puzzle configuration.

Look for:

- UI clipping
- Tiny unusable pieces
- Solver explosion
- Memory growth
- Slow validation
- Input precision problems
- Scrolling issues

---

# 87. MINIMUM PUZZLE

Also test the smallest legal puzzle.

Boundary configurations frequently expose assumptions such as:

"There are always at least two pieces."

---

# 88. EMPTY / INVALID PUZZLE

If an empty puzzle is invalid, reject it cleanly.

Do not crash because code blindly accesses element zero.

---

# 89. RESIZING

For desktop/windowed puzzle games, test resizing throughout gameplay.

Verify:

- Puzzle remains usable
- Hit testing remains correct
- Logical coordinates remain correct
- Selection remains aligned
- Dragging remains accurate
- Text remains readable

---

# 90. DPI / DISPLAY SCALING

Test common scaling values where relevant.

Visual scaling must not alter logical hit targets incorrectly.

A piece displayed in one location must not respond as though it were somewhere else.

---

# 91. FULLSCREEN / WINDOW MODE

If supported, transition repeatedly between display modes.

Ensure:

- Puzzle state preserved
- Input mapping correct
- Timer behavior correct
- No duplicate initialization
- No lost selection

---

# 92. FOCUS LOSS

Test losing application focus during:

- Drag
- Animation
- Timer
- Pause
- Hint
- Long operation

State should remain coherent when focus returns.

---

# 93. APPLICATION SUSPEND / RESUME

Where platform-relevant, test:

Game active
→ application suspended/backgrounded
→ resume

Verify:

- Timer
- State
- Audio
- Input
- Save
- Background operations

according to intended behavior.

---

# 94. AUDIO STATE

If puzzle actions have sound:

Ensure repeated or canceled actions do not produce inappropriate duplicate sounds.

Completion audio should not trigger repeatedly.

Audio failures should not affect puzzle correctness.

---

# 95. ANIMATION SKIPPING

If animations can be skipped or disabled, verify final logical state is identical.

Animations must not contain hidden game logic required for correctness.

---

# 96. ACCESSIBILITY AND PUZZLE INFORMATION

Ensure critical puzzle information is not communicated ONLY by a distinction some players cannot perceive.

Examples:

- Color alone
- Tiny visual difference
- Animation only
- Sound only

Where appropriate, provide redundant cues.

This is especially important when color itself represents puzzle state.

---

# 97. COLOR-BLIND CONSIDERATIONS

If puzzle mechanics rely heavily on colors, review whether pieces can also be distinguished through:

- Symbols
- Shapes
- Patterns
- Labels

as appropriate to the game.

Do not change artistic design unnecessarily, but do not make the puzzle fundamentally impossible for common color-vision differences if avoidable.

---

# 98. INSTRUCTIONS / TUTORIAL

Compare instructions against actual rules.

Verify every tutorial example is legal and current.

Outdated instructions are gameplay bugs.

A player should not need to reverse-engineer the rules from failed moves.

---

# 99. FIRST PUZZLE EXPERIENCE

Approach the game as someone who has never played it.

Without implementation knowledge, determine:

- What can I interact with?
- What is the goal?
- What constitutes progress?
- What is illegal?
- Why was my action rejected?
- How do I restart?
- How do I get help?

Do not assume developer knowledge.

---

# 100. ERROR FEEDBACK

When a player attempts an invalid action, determine whether feedback is appropriate.

Avoid:

- Silent confusion
- Excessive modal dialogs
- Punishing harmless exploratory input

Use the game's interaction style.

---

# 101. NO-MOVE STATE

If the player reaches a state with no legal moves:

Determine whether that means:

- Failure
- Dead end requiring undo
- Automatic reshuffle
- Puzzle bug

Handle it explicitly.

Do not leave the player staring at an apparently active but impossible game.

---

# 102. DEAD-END DETECTION

If detecting unsolvable/dead-end states is computationally practical and useful, consider doing so.

But do not reveal information that undermines intended puzzle difficulty unless the design calls for it.

---

# 103. RESHUFFLE

If reshuffling exists:

Ensure:

- Puzzle remains solvable
- Required constraints remain valid
- Locked state remains correct
- Score/move penalties are correct
- No pieces duplicate/disappear

---

# 104. AUTOCOMPLETE

If autocomplete exists:

Only trigger when remaining state is logically determined according to intended rules.

Do not autocomplete merely because the implementation happens to know the stored solution.

Respect alternate valid solutions.

---

# 105. "CHECK ANSWER"

If a Check function exists, define what it means.

Possible behaviors:

- Is entire puzzle complete?
- Are current moves legal?
- Are current placements consistent with at least one solution?
- Do entries match canonical solution?

These are NOT equivalent.

Ensure UI wording matches actual semantics.

---

# 106. MISTAKE DETECTION

If the game marks mistakes immediately, determine whether a move is truly invalid or merely inconsistent with one stored solution.

This matters when multiple solutions exist.

Do not punish valid alternate reasoning.

---

# 107. REVEAL SOLUTION

If solution reveal exists:

- Confirm if appropriate.
- Handle scoring/progression intentionally.
- Stop timer appropriately.
- Preserve distinction between solved and revealed.

Do not award normal completion accidentally.

---

# 108. ABANDON / QUIT PUZZLE

Define behavior when leaving an unfinished puzzle.

Possible behavior:

- Auto-save
- Ask
- Discard
- Keep resumable state

Apply consistently.

---

# 109. NEW PUZZLE WHILE DIRTY/ACTIVE

Test:

Active unfinished puzzle
→ New Puzzle

Ensure intended behavior:

- Save/resume old puzzle
- Confirm abandonment
- Discard

Do not silently destroy meaningful progress unless that is clearly the game's design.

---

# 110. SETTINGS DURING GAMEPLAY

Changing gameplay-affecting settings mid-puzzle should not corrupt state.

Examples:

- Difficulty
- Input mode
- Animation speed
- Theme
- Assist mode

Some settings may appropriately apply only to the next puzzle.

Make this explicit.

---

# 111. DIFFICULTY CHANGE MID-PUZZLE

If difficulty determines puzzle rules or generation, do not silently mutate the current puzzle into a different ruleset.

Usually:

Difficulty change
→ applies to next puzzle

unless intentionally designed otherwise.

---

# 112. RULE VARIANTS

If the game supports variants:

Treat rule set as explicit state.

Do not scatter:

if (hardMode)

through unrelated code if a cleaner rule abstraction exists.

Verify:

- Generator
- Solver
- Validator
- Hints
- UI
- Completion

all use the same active rules.

---

# 113. RULE VERSIONING

If rules may evolve while saved/generated puzzles persist, consider versioning the rule set.

Old saved puzzles should not silently acquire new semantics that make them invalid.

---

# 114. CHEAT / DEBUG FEATURES

If developer cheats/debug commands exist:

- Keep them isolated.
- Prevent accidental release exposure where inappropriate.
- Ensure they do not contaminate normal progression/state.
- Make them useful for testing edge cases.

Useful developer actions might include:

- Solve puzzle
- Force completion
- Force failure
- Load seed
- Show solution
- Generate impossible state
- Advance timer
- Set move count

These can dramatically improve testing.

---

# 115. TESTABLE GAME ENGINE

Where practical, keep core puzzle rules testable independently from graphics/UI.

It should ideally be possible to perform something conceptually like:

Create puzzle state

Apply move

Inspect result

without launching the entire graphical application.

This greatly improves correctness testing.

---

# 116. DETERMINISTIC LOGIC TESTS

Core rule tests should be deterministic.

Avoid tests depending on:

- Wall-clock time
- UI timing
- Uncontrolled randomness
- Animation timing

Inject/control these dependencies where useful.

---

# 117. GOLDEN PUZZLES

Maintain a set of known puzzles for testing.

Include:

- Trivial valid puzzle
- Typical puzzle
- Difficult puzzle
- Unique-solution puzzle
- Multi-solution puzzle where relevant
- Impossible puzzle
- Edge-case puzzle
- Previously broken puzzle

These become regression fixtures.

---

# 118. REGRESSION PUZZLES

Whenever a player reports:

"This puzzle is impossible."

or:

"The game says this valid move is wrong."

or:

"Undo broke the board."

preserve that puzzle/seed/action sequence as a regression test whenever practical.

Real player failures should become permanent institutional memory.

---

# 119. ACTION-SEQUENCE FUZZING

For a deterministic puzzle engine, consider generating random sequences of legal and illegal actions.

After every action verify invariants.

Examples:

Move
Undo
Undo
Hint
Invalid move
Redo
Restart
Move
Move

This can expose state-machine bugs humans do not naturally test.

---

# 120. PROPERTY-BASED TESTING

Where appropriate, verify properties such as:

Legal move
→ state remains valid

Move
→ Undo
→ original state

Move
→ Undo
→ Redo
→ moved state

Restart
→ initial state

Save
→ Load
→ equivalent state

Generated puzzle
→ solver finds solution

Unique puzzle
→ solver finds exactly one solution

These are exceptionally valuable puzzle-game tests.

---

# 121. INVARIANT CHECKER

Consider implementing a debug/test-only invariant checker.

After state-changing operations, verify:

- Counts
- Bounds
- Unique identities
- Required references
- Rule constraints
- Internal consistency

Fail loudly during development/tests if impossible state appears.

Do not impose unacceptable runtime cost in production.

---

# 122. SERIALIZATION ROUND TRIP

Test:

Puzzle state
→ serialize
→ deserialize
→ equivalent puzzle state

Include:

- Initial state
- Partially played state
- Hint-used state
- Undo history where persisted
- Completed state where persisted

---

# 123. UNDO ROUND TRIP

For every representative legal action:

State A
→ action
→ State B
→ Undo
→ State A

Compare logically, not merely visually.

---

# 124. REDO ROUND TRIP

Likewise:

State A
→ action
→ State B
→ Undo
→ State A
→ Redo
→ State B

---

# 125. RESTART ROUND TRIP

For arbitrary valid player progress:

Current state
→ Restart
→ exact intended initial state

---

# 126. SOLUTION VALIDATION PROPERTY

Every generated puzzle should satisfy:

Generate
→ Solve
→ Validate solution
→ success

If uniqueness is required:

Generate
→ count solutions
→ exactly one

---

# 127. PERFORMANCE UNDER ADVERSARIAL PUZZLES

Try puzzle states designed to make the solver/generator perform badly.

Add limits where necessary.

A player should not be able to freeze the application merely by loading a pathological puzzle.

---

# 128. MEMORY / RESOURCE REVIEW

Repeatedly:

New puzzle
→ play
→ finish
→ new puzzle

Look for growing:

- Memory
- Timers
- Event subscriptions
- Threads/tasks
- Cached puzzle state
- Textures/images
- Audio resources

The 100th puzzle should not carry 99 dead puzzles behind it.

---

# 129. EVENT SUBSCRIPTIONS

Puzzle screens/pieces/controllers are often event-heavy.

Verify old puzzle objects unsubscribe and can be collected.

Look for static/global events retaining old game instances.

---

# 130. BACKGROUND TASK LIFETIME

Solver/hint/generator tasks from an old puzzle must not continue modifying a new puzzle.

On:

Restart
New Game
Load
Exit

cancel or invalidate stale work appropriately.

---

# 131. NEW PUZZLE RACE

Explicitly test:

Puzzle A hint calculation starts.

User starts Puzzle B.

A's calculation finishes.

It must NOT modify Puzzle B.

---

# 132. RESTART RACE

Test:

Long calculation begins.

User restarts puzzle.

Old calculation completes.

Restarted state must remain authoritative.

---

# 133. SAVE RACE

If saves are asynchronous:

State A save begins.

Player makes additional move producing State B.

Save completes.

Be explicit about whether saved state represents A or B.

Do not accidentally mark B clean if only A was persisted.

---

# 134. COMPLETION RACE

If final move triggers asynchronous work, ensure:

- Completion isn't lost.
- Completion isn't duplicated.
- Further input cannot create contradictory state.

---

# 135. PLAYER EXPERIENCE CONSISTENCY

Review puzzle behavior for consistency.

The same kind of action should behave the same way throughout the game.

Avoid one puzzle screen using:

Right-click to rotate

and another using:

Right-click to delete

without strong reason.

---

# 136. FEEDBACK CONSISTENCY

Use consistent feedback for:

- Legal move
- Illegal move
- Selection
- Hint
- Completion
- Failure

Players learn interaction patterns quickly.

Do not undermine those learned expectations.

---

# 137. STATE VISIBILITY

The player should understand important game state.

Examples:

- Selected piece
- Locked piece
- Invalid position
- Paused state
- Hint
- Completion
- Remaining objective

Do not hide critical state solely in internal variables.

---

# 138. DO NOT LEAK SOLUTION INFORMATION

Review whether UI, logs visible to player, debug labels, accessibility text, filenames, or object IDs accidentally reveal puzzle answers.

Developer diagnostics may contain solution information if appropriate, but normal player-facing behavior should not unintentionally spoil the puzzle.

---

# 139. DATA / CONTENT SEPARATION

If practical, keep:

Puzzle rules

separate from:

Puzzle content

and:

UI presentation.

This allows:

- Rule testing
- Content validation
- Multiple themes
- Solver reuse
- Better maintainability

Do not force an architectural rewrite if current separation is already adequate.

---

# 140. RULE ENGINE VS SOLVER

The solver should use the same fundamental rule definitions as gameplay where practical.

But avoid coupling them so tightly that solver search mutates live game state.

Solver operations should generally operate on isolated/copyable state.

---

# 141. CLONING / COPYING STATE

If puzzle state is cloned for:

- Solver
- Undo
- Hints
- Simulation

verify the copy is genuinely independent where required.

Look for shallow-copy bugs where modifying simulated state mutates the real puzzle.

---

# 142. OBJECT IDENTITY

If pieces/entities have IDs:

Ensure IDs remain:

- Unique
- Stable where needed
- Correct after save/load
- Correct after undo
- Correct after cloning

Do not rely on object-reference identity when persisted/logical identity is required.

---

# 143. INTEGER OVERFLOW / COUNTERS

Review:

- Score
- Move count
- Timer
- Puzzle index
- Seed
- Generation counters

Use sensible types and bounds.

Do not assume nobody will ever leave the game running for an absurd amount of time.

---

# 144. SAVE SCUMMING / EXPLOITS

Determine whether saving/reloading can manipulate:

- Random outcomes
- Score
- Hints
- Timer
- Progression

This may be irrelevant for a casual offline puzzle game.

Do not build anti-cheat infrastructure unless it matters.

But avoid accidental logic bugs.

---

# 145. OFFLINE-FIRST BEHAVIOR

If the game does not fundamentally require internet access, ensure core puzzle gameplay remains independent from unnecessary network availability.

Do not make a local puzzle unplayable because an optional service failed.

---

# 146. EXTERNAL SERVICE FAILURE

If leaderboards/cloud/daily puzzles/etc. exist:

Service failure should not corrupt local puzzle state.

Separate:

Gameplay correctness

from:

Optional online feature availability.

---

# 147. LEADERBOARD VALIDATION

If competitive scores exist, review whether obviously invalid values can be submitted.

Examples:

- Negative completion time
- Impossible move count
- Invalid puzzle ID
- Wrong difficulty

The degree of anti-cheat required depends on the product.

Do not over-engineer security for a purely local casual game.

---

# 148. LOCALIZATION IMPACT

If localization exists:

Ensure translated text does not alter:

- Puzzle parsing
- Rule identifiers
- Serialization
- Internal comparisons

Player-facing strings should not be used as internal logic keys.

---

# 149. INPUT BINDING CONFLICTS

If controls are configurable, test conflicting bindings.

Do not allow one keypress to trigger multiple incompatible gameplay actions accidentally.

---

# 150. CONFIRMATION DIALOGS

Use confirmations only for meaningful destructive actions.

Examples:

- Abandon substantial progress
- Restart
- Reveal solution

Do not ask for confirmation constantly.

If progress is safely recoverable, fewer confirmations may be appropriate.

---

# 151. FAILURE RECOVERY

After an internal operation fails:

- Puzzle should remain coherent.
- Input should recover.
- Busy state should clear.
- Previous valid state should remain available.

Do not require application restart for ordinary recoverable errors.

---

# 152. TRANSACTIONAL PLAYER ACTIONS

Complex player actions should behave atomically.

Conceptually:

Validate action

→ calculate result

→ commit state

→ update UI

If action fails halfway through, do not leave half-applied state.

---

# 153. VALIDATE BEFORE MUTATION

Prefer validating an action before destructively modifying current state.

Avoid:

Remove piece from source
→ discover destination invalid
→ attempt to reconstruct source

when:

Validate destination
→ perform move

is possible.

---

# 154. EXCEPTION SAFETY

If unexpected failure occurs during a move, preserve the last coherent state where practical.

Do not let one exception leave the board logically corrupted.

---

# 155. AUTOSAVE / CRASH RECOVERY

If puzzle progress is worth preserving, integrate with the application's crash-recovery strategy.

Recovery should capture coherent puzzle state.

Do not autosave half-applied actions.

---

# 156. DIAGNOSTIC REPRODUCTION

A useful bug report should ideally allow the developer to know:

- Game version
- Puzzle ID
- Seed
- Generator version
- Difficulty
- Rule variant
- Move/action history or recent actions
- Current state identifier/hash
- Last error

Design diagnostics so "this puzzle broke" can become reproducible.

---

# 157. PLAYER REPORT FEATURE

If appropriate, a "Report Problem / Save Diagnostics" action during a puzzle can include puzzle-specific metadata automatically.

Do not require the player to manually transcribe a 20-digit seed if the application already knows it.

---

# 158. DO NOT TRUST VISUAL INSPECTION ALONE

A board can LOOK correct while internal state is wrong.

After meaningful test actions, inspect logical state.

Likewise, internal state can be correct while rendering is wrong.

Test both independently.

---

# 159. TEST THE GAME LIKE A JERK

Deliberately do things normal players "shouldn't" do.

Examples:

- Click everything rapidly
- Undo 100 times
- Restart repeatedly
- Spam Hint
- Resize while dragging
- Minimize during animation
- Exit during generation
- Load corrupt save
- Change settings mid-operation
- Double-click completion action
- Mash keyboard shortcuts
- Start new game while old background work runs

The application should remain coherent.

---

# 160. TEST THE GAME LIKE AN IDIOT

Also assume the player misunderstands everything.

Try:

- Clicking disabled-looking things
- Dragging to nonsense places
- Entering absurd values
- Ignoring instructions
- Repeating failed actions
- Attempting actions in the wrong order

The game should guide or reject safely rather than corrupt itself.

---

# 161. TEST THE GAME LIKE AN EXPERT

An expert player may:

- Move extremely quickly
- Exploit shortcuts
- Recognize alternate solutions
- Complete puzzles in unusual orders
- Use Undo strategically
- Discover scoring exploits

Ensure assumptions about "normal" play do not reject legitimate expert behavior.

---

# 162. TEST WITHOUT DEVELOPER KNOWLEDGE

Give the game a conceptual fresh-user pass.

Do not rely on knowing:

- Intended solution
- Hidden rules
- Internal state
- Debug commands
- Expected sequence

A puzzle should communicate enough for a normal player to understand what is happening.

---

# 163. AUTOMATED FULL-PUZZLE TEST

Where solver support exists:

Generate/load puzzle.

Solve programmatically using legal moves.

Feed those moves through the SAME public gameplay action path used by normal play where practical.

Verify:

- Every move accepted
- Final state valid
- Completion fires exactly once
- Score/time state valid
- Persistence valid

This is extremely valuable.

---

# 164. RANDOM GENERATED PUZZLE BATCH TEST

If generation exists, generate many puzzles automatically.

For example:

100
1,000
or more depending on generation cost.

For every generated puzzle verify:

- Structural validity
- Solvability
- Unique solution if required
- Solver termination
- No exceptions

Record the seed for every failure.

---

# 165. RANDOM ACTION STRESS TEST

For many generated puzzles:

Perform randomized legal actions, invalid actions, undo, redo, hints, and restart.

After every action:

Verify invariants.

If failure occurs:

Record:

- Seed
- Action sequence
- State

Make failures reproducible.

---

# 166. RELEASE-BUILD TEST

Test actual release/optimized configuration.

Do not assume behavior observed only under debugger/debug build is representative.

Timing and race behavior may differ.

---

# 167. CLEAN INSTALL / FIRST RUN

Test with:

- No save data
- No settings
- No cache
- No previous puzzle
- No developer files

The first-run game must work.

Do not accidentally depend on state left on the developer machine.

---

# 168. OLD DATA

If previous releases exist, test old:

- Saves
- Settings
- Progression
- Puzzle data

Upgrade behavior should be intentional.

---

# 169. CORRUPT LOCAL DATA

Corrupt individual local files.

The game should recover as gracefully as possible.

One corrupt settings file should not necessarily destroy all puzzle progress.

Separate storage concerns where useful.

---

# 170. RESET / FACTORY RESET

If reset functionality exists:

Clearly define what it deletes.

Examples:

- Settings
- Progress
- Saves
- Statistics
- Generated cache

Do not delete more than promised.

---

# 171. TEST CLEANUP

Automated puzzle tests should not pollute real user save/config directories.

Use isolated test locations.

Tests must not destroy developer/player progress.

---

# 172. ASSERT INVARIANTS DURING TESTING

After every meaningful state transition in automated tests, run invariant validation where practical.

Do not wait until the final state to discover corruption.

Find the exact action that first broke state.

---

# 173. PREVIOUS BUG REGRESSION PASS

Search:

- Issue history
- TODO comments
- Existing regression tests
- Commit history where available

Identify prior puzzle/gameplay bugs.

Ensure meaningful fixed bugs have regression protection.

---

# 174. TODO / HACK REVIEW

Search for:

TODO

FIXME

HACK

TEMP

WORKAROUND

Determine whether any represent unfinished gameplay behavior or fragile rule handling.

Do not remove comments blindly.

Resolve important underlying problems.

---

# 175. DEBUG-ONLY ASSUMPTIONS

Ensure release builds do not depend on:

- Assertions performing required work
- Debug initialization
- Debug resources
- Developer file paths
- Debug cheats

Assertions should verify behavior, not create necessary behavior.

---

# 176. FINAL GAMEPLAY STATE-MACHINE REVIEW

Map major states such as:

Main menu

Puzzle loading

Puzzle active

Paused

Hint calculation

Completed

Failed

Restarting

Saving

Exiting

Then review every meaningful transition.

Ask:

- Is transition allowed?
- What state changes?
- What gets canceled?
- What persists?
- What UI becomes enabled?
- Can stale work arrive afterward?

Look for missing transitions and impossible combinations.

---

# 177. FINAL RULE CONSISTENCY REVIEW

Compare rule behavior across:

- Player actions
- Solver
- Generator
- Hints
- Completion checker
- Save validation
- Replay
- Tests

All should agree on the fundamental game rules.

If they disagree, establish one authoritative interpretation.

---

# 178. FINAL "CAN I BREAK THE PUZZLE?" PASS

Try deliberately to produce:

- Impossible internal state
- Duplicate piece
- Missing piece
- Invalid position
- Negative count
- Incorrect completion
- Lost progress
- Stale hint
- Broken undo
- Broken redo
- Infinite generation
- Solver hang
- Softlock
- Double reward
- Timer exploit
- Score exploit

Keep going until major avenues have been exhausted.

---

# 179. FINAL "CAN THE GAME BREAK ITSELF?" PASS

Now assume the PLAYER behaves perfectly.

Look for ways the game itself can corrupt state through:

- Async completion
- Save/load
- Autosave
- Animation
- Events
- Restart
- New Game
- Background solver
- Hint system
- Generator
- Shutdown

A player should not need to behave strangely to trigger a state bug.

---

# 180. FINAL PLAYER EXPERIENCE PASS

Finally, play representative puzzles normally.

Do not inspect code during this pass.

Ask:

- Are rules understandable?
- Are controls predictable?
- Is feedback immediate?
- Is anything frustrating because of implementation rather than puzzle difficulty?
- Can mistakes be recovered from?
- Does Undo behave exactly as expected?
- Are hints trustworthy?
- Does Restart work?
- Does Save/Resume work?
- Does completion feel definitive?
- Does anything feel broken even if technically correct?

Puzzle difficulty is allowed.

Implementation friction is not.

---

# FINAL REPORT

After completing the review, provide a concise but meaningful report containing:

## Rule Engine

- Rule inconsistencies discovered
- Invalid transitions fixed
- Invariants established
- Rule duplication removed

## Puzzle Validity

- Solvability issues
- Unique-solution issues
- Invalid puzzle data
- Generator issues

## Solver / Generator

- Correctness fixes
- Performance fixes
- Determinism/reproducibility improvements
- Seeds or versioning added

## Gameplay State

- State corruption bugs
- Softlocks
- Race conditions
- Stale async operations
- New Game/Restart issues

## Undo / Redo

- History bugs
- Atomic-action fixes
- Redo invalidation fixes
- Score/state interactions

## Hints

- Incorrect hints
- Stale hints
- Multiple-solution problems
- Hint-state fixes

## Completion / Failure

- False completion
- Missed completion
- Duplicate completion
- Reward/progression issues

## Persistence

- Save/resume problems
- Corrupt-save handling
- Versioning/migration
- Crash-recovery integration

## Input

- Rapid-input bugs
- Drag/drop issues
- Keyboard/controller issues
- Animation/input races

## Timing / Scoring

- Timer bugs
- Pause behavior
- Score exploits
- Counter issues

## Testing

- Golden puzzles added
- Regression puzzles added
- Solver tests
- Generator batch tests
- Property/invariant tests
- Random-action stress tests

## Remaining Concerns

- Known limitations
- Intentional design choices
- Areas requiring future work

Do not pad this report with trivial cosmetic changes.

---

# ACCEPTANCE CRITERIA

The puzzle-game review is complete when:

1. Fundamental puzzle rules are explicitly understood.

2. Core rule invariants have been identified.

3. Legal moves are accepted correctly.

4. Illegal moves cannot corrupt state.

5. UI restrictions are not the sole protection for game rules.

6. Puzzle completion is correctly detected.

7. Valid alternate solutions are handled correctly where applicable.

8. Every playable puzzle is solvable.

9. Unique solutions are verified where required.

10. Generator output is validated.

11. Generator failure cannot loop forever.

12. Generated puzzles can be reproduced when appropriate.

13. Undo correctly restores complete logical state.

14. Redo correctly restores undone state.

15. New actions correctly invalidate incompatible redo history.

16. Restart restores the intended initial puzzle state.

17. New Game cannot inherit stale state.

18. Hints are always legal and relevant.

19. Stale asynchronous hints/solver results cannot affect newer state.

20. Player actions cannot produce unintended softlocks.

21. Input during animation cannot corrupt logical state.

22. Rapid/repeated input cannot duplicate actions.

23. Completion processing occurs exactly once.

24. Scoring cannot be trivially exploited through state bugs.

25. Timer behavior is consistent.

26. Save/resume reconstructs meaningful state correctly.

27. Corrupt save data cannot brick the application.

28. Loaded state is validated.

29. Background work cannot modify an obsolete puzzle.

30. Puzzle content is validated automatically where practical.

31. Core game logic is testable independently of presentation where practical.

32. Known problematic puzzles/seeds can become regression tests.

33. Randomized action testing preserves invariants.

34. Generated-puzzle batch testing has been performed where applicable.

35. Repeated puzzle sessions do not leak resources.

36. Release-build behavior has been tested.

37. First-run behavior has been tested without developer-machine state.

38. The game has been tested like an impatient player.

39. The game has been tested like a confused player.

40. The game has been tested like an expert trying unusual but legitimate strategies.

41. The game has been deliberately attacked for softlocks, state corruption, and exploits.

42. Normal gameplay still feels straightforward after all hardening changes.

The final standard is:

> Can the player do things in a completely different order than the developer expected and still leave the game in a valid state?

The answer should be:

> Yes.

Then ask:

> Can Undo, Restart, Hint, Save, Resume, animation, background work, or rapid input ever make the logical puzzle state disagree with what the player sees?

The answer should be:

> No.

Then:

> If the game generates a puzzle, can we prove that the player was not handed impossible garbage?

Where practical, the answer should be:

> Yes.

Then:

> If a player tells me "Puzzle 4F92A is impossible," can I reproduce exactly what they saw?

For generated games, design toward:

> Yes.

And finally:

> Is the puzzle difficult because the PUZZLE is difficult, or because the SOFTWARE is fighting the player?

Only the first is acceptable.

Make the puzzle challenging.

Make the software boringly reliable.