# The project brain: shared memory for Claude sessions, kept in git

Point a Claude session at this file to set up a "brain" in a new project, or to add one to an
existing project. Not every project needs one. It earns its keep when a project runs over many sessions,
on more than one machine, or long enough that context gets compacted and a session forgets.

---

## The idea

Claude Code's own memory is per machine and per session. If one session learns a rule ("never pull in
library X", "commit straight to main") or how far the work has got, a session on another machine, or the
same machine next week, starts without it.

The brain moves all of that into **two files in the repo**:

| File | Holds | Changes |
|---|---|---|
| `CLAUDE.md` (repo root) | The standing rules: what the project is for, how to work, code rules, git rules, commands, where things are | When a rule changes |
| `docs/status.md` | Where the project stands: what is built, what is next, what was learned, what is still unverified | With every chunk of work |

Claude Code loads `CLAUDE.md` at the start of every session automatically, and `CLAUDE.md` points at
`docs/status.md`. Because both are in git, **every session on every machine gets the same picture after
a pull.**

The test: *a fresh session that knows only what is in git can carry on the work.* If it can't, something
that belongs in the brain is missing.

---

## What goes in, and what stays private

**In the brain** (anything that should travel with the project and could go public with it):
- the project's purpose and the rules that follow from it;
- preferences on how to work ("keep rolling until the plan is done", "warn, don't refuse");
- how to build and test, and how long jobs take (time, memory, GPU), as facts;
- where things are in the repo;
- what is built, what is next, what was learned the hard way, what is still unverified.

**Never in the repo** (not in the brain, code, docs or commit messages):
- confidential names (customers, vendors, partners) when the project must not reveal them;
- anything about one machine or one person: host names, IPs, user names, home-folder paths, device
  serial numbers, COM ports;
- credentials, tokens, keys, account details;
- how one machine shares its CPU or schedules jobs. That belongs to the machine's own setup (the
  user-level `~/.claude/CLAUDE.md`), not the project.

**Where the private things live:** each machine's own Claude memory or user settings, outside the repo.
When another machine needs one (for example a list of words that must never appear), the user passes it
over directly. It is never committed, not even to a private branch.

---

## Keeping it alive

These lines go into the project's `CLAUDE.md` so every session follows them:

- **Update `docs/status.md` with every chunk of work**, in the same commit as the work.
- **Update `CLAUDE.md` when a rule changes.** If the user states a new standing rule, it goes here, not
  into private memory.
- **Move rules out of private memory.** If a session's memory holds a project rule every session should
  know, move it into `CLAUDE.md` (without the private parts) and leave the memory pointing at the brain.
- **Push.** The brain only works across machines if it reaches the remote.

Private memory then shrinks to a few machine-specific facts and one pointer: "this project's rules and
status are in `CLAUDE.md` and `docs/status.md`."

---

## Optional: a check for words that must never appear

If the project must never name something (a vendor, a customer, an internal codename), make it
mechanical:

- Keep the list outside the repo, one word or regex per line, e.g. `~/.<project>/private-words.txt`.
- Add a small script (e.g. `tools/name_check.py`) that scans the tracked files and the last commit
  message against the list. Exit 0 clean, 1 hits, 2 no list on this machine.
- `CLAUDE.md` says to run it before every commit. Exit 2 means "say so and carry on". The list is never
  in the repo, so the brain can say *that* there are forbidden names without saying *which*.

---

## Template: `CLAUDE.md`

```markdown
# <Project>: notes for every session

<One or two sentences: what the project is.> This file is the project's shared brain: the standing
rules, how to work, and where things are. Where the project stands and what comes next is in
[docs/status.md](docs/status.md). Both are in git, so every session on every machine gets the same
picture.

## The brain: what goes in it and what stays private

Claude Code loads this file at the start of every session, on every machine with a clone. Together with
`docs/status.md` it replaces any one session's memory: a session that knows only what is in git should be
able to carry on the work. So:

- **In the brain (this file, `docs/status.md`):** the project's standing rules and preferences, how to
  build and test, where things are, what is built, what is next, what was learned, what is unverified.
- **Never in the repo (brain, code, docs, commit messages):** <confidential names, if any>; anything
  about a particular machine or person (host names, IPs, user names, local paths, serial numbers, ports);
  credentials; rules about how one machine schedules jobs (facts about a job's own needs are fine).
- **Where private things live:** in each machine's own Claude memory or user settings. When another
  machine needs one, the user passes it over directly; it is never committed.
- **Keeping it current:** update `docs/status.md` with every chunk of work, and this file when a rule
  changes. If a session's private memory holds a project rule every session should know, move it here
  (without the private parts).

## What the project is for

- <The goal, and the constraints that follow from it.>

## Working through a plan

<e.g. When the user says "keep rolling", build task after task until the plan is done or truly blocked,
committing and pushing each chunk.>

## Code rules

- <Dependencies allowed and not allowed, style, line length, line endings, typing, testing.>

## Git

- <e.g. Commit and push straight to `main`. Before committing: lint, type check, the tests the change
  touches, the name check.>

## Commands

    <setup, lint, type check, test commands>

Job sizes: <how long the full test suite takes, peak memory, GPU or not>.

## Where things are

- `README.md`: <...>
- `docs/status.md`: built, next, lessons.
- <other key docs and folders>
```

## Template: `docs/status.md`

```markdown
# Status

Where <Project> stands. Updated with every chunk of work; the rules are in `CLAUDE.md`.

## Next

1. **<The next thing>:** <what, and what it waits on, with dates as dates, not "tomorrow">.
1. <...>

## Built

- **<Feature>** (<date>): <what it does, how it was checked, what is still unverified>.

## Not built

- <Out of scope, and why.>

## Lessons

- <Something learned the hard way, written as a rule a future session can apply.>
```

Write dates as absolute dates (2026-11-09, not "Monday"). The file is read weeks later.

---

## Setting up a new project

1. Create `CLAUDE.md` and `docs/status.md` from the templates above, filled in for the project.
2. If there are words that must never appear, set up the name check and put the list on each machine.
3. Commit and push both files with the first real code.
4. On each machine, keep private memory to machine facts plus a pointer to the brain.

## Adding it to an existing project

1. Read the session's private memory for the project (`~/.claude/projects/<project>/memory/`) and any
   existing `CLAUDE.md`.
2. Sort every item: **project rule or status** (goes into the brain) or **private / machine-specific**
   (stays in memory).
3. Write `CLAUDE.md` and `docs/status.md` from the project items. Rewrite them as rules, without the
   private parts.
4. Delete the memory files that moved, and leave one memory saying the rules and status are in the repo.
5. Check: could a fresh session on another machine pick up the work from git alone? Commit and push.

## Checklist

- [ ] `CLAUDE.md` at the repo root, with the "brain" section and a pointer to `docs/status.md`
- [ ] `docs/status.md` with Next, Built, Not built, Lessons
- [ ] No machine names, paths, serials, credentials or confidential names in either file
- [ ] Name check set up, if the project has words that must never appear
- [ ] Project rules moved out of private memory; memory points at the brain
- [ ] Both files committed and pushed
