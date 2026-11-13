---
name: setup-github-repo
description: Set up a new public GitHub repo to RelentlessOldMan conventions — MIT license, no contributions (pull requests off, issues limited to collaborators), LF normalization, signature emoji, and a profile-README listing. Use when publishing a new personal project.
---

# New GitHub repo setup — RelentlessOldMan conventions

Canonical source: `C:\Playground\RelentlessOldMan\Project_Instructions\REPO-SETUP.md`
(read it if anything here seems stale). Everything is "personal tool, published
as-is": **MIT, no contributions: pull requests off, issues limited to collaborators.**

Owner: **RelentlessOldMan** (https://github.com/RelentlessOldMan).
Ask the user for the **project name**, a **one-line hook**, and a **signature emoji**
if not given. Use the current year in the copyright line.

## Step 1 — create the repo
```powershell
gh repo create RelentlessOldMan/<Name> --public --description "<one-line hook>"
```
Turn pull requests and the wiki off, issues on:
```powershell
gh api -X PATCH repos/RelentlessOldMan/<Name> -F has_issues=true -F has_pull_requests=false -F has_wiki=false
```
Then limit issue creation to collaborators. It isn't in the API or `gh`, so use the web UI
(Claude in Chrome): **Settings → General → Features → Issues → Issue permissions →
"Creation allowed by: Collaborators only"** (saves on selection). No auto-close workflows.

## Step 2 — `LICENSE` (MIT) — copyright line verbatim (note the URL suffix)
```
MIT License

Copyright (c) <year> RelentlessOldMan (https://github.com/RelentlessOldMan)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Step 3 — `.gitattributes` (same everywhere; kills CRLF churn)
```gitattributes
# Normalize line endings: LF in the repository, checked out natively.
* text=auto eol=lf

# Windows-specific text files keep CRLF.
*.sln text eol=crlf

# Binary / index artifacts (belt-and-suspenders; these are gitignored anyway).
*.idx binary
*.bin binary
```

## Step 4 — `.gitignore`
Baseline for every repo: `.vscode/ .idea/ .DS_Store Thumbs.db`.
Python: `__pycache__/ *.py[cod] *.egg-info/ .venv/ venv/ build/ dist/ *.spec`.
.NET: `bin/ obj/` + any test-scratch/`.corpus/` dirs. Never commit build output or generated corpora.

## Step 5 — `README.md`
Title `# <Name> <emoji>`, a **bold one-line hook**, optional screenshot, then Why /
Usage / How it works / Layout. The last two sections are verbatim (only emoji/year change):
```markdown
## Contributing

This is a personal tool, published as-is, and doesn't take issues or pull requests. Fork it and make it your own. <emoji>

## License

MIT — see [LICENSE](LICENSE). © <year> RelentlessOldMan.
```

## Step 6 — first commit & push
```powershell
cd C:\Playground\<Name>
git init -b main
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/RelentlessOldMan/<Name>.git   # skip if gh created the remote
git push -u origin main
```

## Step 7 — list it on the profile
The local copy is `C:\Playground\RelentlessOldMan`: pull it there (never clone a second
copy anywhere else), add a bullet under the matching
section (`Dev / AI`, `Music`, `Rhythm Gaming`, `Magic: The Gathering`, …), push:
```markdown
- <emoji> **[<Name>](https://github.com/RelentlessOldMan/<Name>)** — <one-line hook>.
```

## Optional — release script
Single-file tools ship a `release.ps1` (bump version, tag, `gh release create` with the
artifact). Larger projects use `make-release.ps1` that publishes a self-contained zip.
Versions are date-based, `YYYY.M.D.N` (e.g. `2026.11.13.0`, N bumped on every build that
day, tag `v<version>`); follow `Project_Instructions\VERSIONING.md`, not semver patch bumps.

## Final checklist
- [ ] `LICENSE` (MIT, copyright line with URL)
- [ ] `.gitattributes` (LF normalization)
- [ ] `.gitignore` (language-appropriate; no build output/corpora)
- [ ] README `## Contributing` (decline) + `## License`, verbatim
- [ ] Pull requests off, wiki off (`gh api -X PATCH ... -F has_pull_requests=false -F has_wiki=false`)
- [ ] Issues on, creation limited to **Collaborators only** (Settings → Features, web UI)
- [ ] No `close-prs.yml` / `close-issues.yml` workflows
- [ ] Added to the profile README under the right section
