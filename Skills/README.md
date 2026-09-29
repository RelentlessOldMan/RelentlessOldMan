# Skills

Reusable [Claude Code skills](https://docs.claude.com/en/docs/claude-code) — on-demand
procedures Claude loads only when invoked (unlike `CLAUDE.md`, which is always-on
context). This repo is the **source of truth**; the live copies live in
`%USERPROFILE%\.claude\skills\`.

**This is source-of-truth only — editing a file here does nothing until you deploy it.**
Claude loads skills from `~/.claude/skills`, so after adding or changing a skill run:

```powershell
.\deploy-skills.ps1
```

That mirrors each skill folder here into `~/.claude/skills`. On a fresh machine, clone
this repo and run it once to install them all.

## Skills

| Skill | What it does |
|---|---|
| `setup-github-repo` | Stand up a new public repo to these conventions (MIT, no-contributions/auto-close PRs, LF normalization, profile listing). Mirrors `Project_Instructions/REPO-SETUP.md`. |
| `start-remote-session` | Launch a Claude Code Remote Control session in a target directory from inside an existing session (Windows) — for when you're remote and no session is running there. |

## Rules of thumb (skill vs. CLAUDE.md)

- **Skill** — an on-demand procedure you invoke for a specific task. Costs ~one line of
  context until used, then loads its body. Put reusable "how to do X" here.
- **CLAUDE.md** — a passive rule that must apply *unprompted* (e.g. commit hygiene, the
  ComputeWarden gate). A skill would never fire on its own, so these must stay in
  `CLAUDE.md`.
