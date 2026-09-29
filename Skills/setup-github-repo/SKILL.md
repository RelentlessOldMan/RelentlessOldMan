---
name: setup-github-repo
description: Set up a new public GitHub repo to RelentlessOldMan conventions — MIT license, no contributions (auto-close PRs, issues off), LF normalization, signature emoji, and a profile-README listing. Use when publishing a new personal project.
---

# New GitHub repo setup — RelentlessOldMan conventions

Canonical source: `C:\Playground\RelentlessOldMan\Project_Instructions\REPO-SETUP.md`
(read it if anything here seems stale). Everything is "personal tool, published
as-is": **MIT, no contributions, PRs auto-closed, issues off.**

Owner: **RelentlessOldMan** (https://github.com/RelentlessOldMan).
Ask the user for the **project name**, a **one-line hook**, and a **signature emoji**
if not given. Use the current year in the copyright line.

## Step 1 — create the repo
```powershell
gh repo create RelentlessOldMan/<Name> --public --description "<one-line hook>"
```
After the first push (Step 7), turn off issues + wiki:
```powershell
gh repo edit RelentlessOldMan/<Name> --enable-issues=false --enable-wiki=false
```

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

## Step 5 — `.github/workflows/close-prs.yml` (canonical filename; replace `<Name>`/`<emoji>`)
```yaml
name: Auto-close PRs

# <Name> is a personal tool published as-is and doesn't accept contributions.
# Any pull request is politely closed automatically.

on:
  pull_request_target:
    types: [opened, reopened]

permissions:
  pull-requests: write

jobs:
  close:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: "Thanks for looking! <emoji> <Name> is a personal tool, published as-is and not accepting contributions — so this PR will auto-close. Please fork it and make it your own."
            });
            await github.rest.pulls.update({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.issue.number,
              state: "closed"
            });
```

## Step 6 — `README.md`
Title `# <Name> <emoji>`, a **bold one-line hook**, optional screenshot, then Why /
Usage / How it works / Layout. The last two sections are verbatim (only emoji/year change):
```markdown
## Contributing

This is a personal tool, published as-is — **issues and pull requests aren't accepted** (PRs auto-close). Fork it and make it your own. <emoji>

## License

MIT — see [LICENSE](LICENSE). © <year> RelentlessOldMan.
```

## Step 7 — first commit & push
```powershell
cd C:\Playground\<Name>
git init -b main
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/RelentlessOldMan/<Name>.git   # skip if gh created the remote
git push -u origin main
```

## Step 8 — list it on the profile
Clone/pull `RelentlessOldMan/RelentlessOldMan`, add a bullet under the matching
section (`Dev / AI`, `Music`, `Rhythm Gaming`, `Magic: The Gathering`, …), push:
```markdown
- <emoji> **[<Name>](https://github.com/RelentlessOldMan/<Name>)** — <one-line hook>.
```

## Optional — release script
Single-file tools ship a `release.ps1` (bump version, tag, `gh release create` with the
artifact). Larger projects use `make-release.ps1` that publishes a self-contained zip.

## Final checklist
- [ ] `LICENSE` (MIT, copyright line with URL)
- [ ] `.gitattributes` (LF normalization)
- [ ] `.gitignore` (language-appropriate; no build output/corpora)
- [ ] `.github/workflows/close-prs.yml`
- [ ] README `## Contributing` (decline) + `## License`, verbatim
- [ ] Issues disabled (`gh repo edit --enable-issues=false --enable-wiki=false`)
- [ ] Added to the profile README under the right section
