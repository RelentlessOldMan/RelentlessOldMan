# New GitHub repo setup — RelentlessOldMan conventions

Point a Claude session at this file when starting a new public project so the repo
matches the rest of my GitHub. Everything here is "personal tool, published as-is":
**MIT-licensed, no contributions accepted, PRs auto-closed, issues off.**

Owner: **RelentlessOldMan** (https://github.com/RelentlessOldMan)
Copyright line: `© <year> RelentlessOldMan` (use the current year).

---

## The rules (what every repo must have)

1. **MIT license** — `LICENSE` file + a `## License` section in the README.
2. **No contributions** — a `## Contributing` section that declines PRs, a workflow
   that auto-closes any PR, and Issues **disabled** in repo settings.
3. **Line-ending hygiene** — a `.gitattributes` that normalizes to LF (prevents the
   "LF will be replaced by CRLF" warnings on every commit).
4. **A signature emoji** for the project, used in the README title, the Contributing
   line, and the auto-close comment.
5. **Listed on the profile** — add it to the `RelentlessOldMan/RelentlessOldMan`
   profile README under the right category section.

---

## Step 1 — Create the repo

```powershell
gh repo create RelentlessOldMan/<Name> --public --description "<one-line hook>"
```

Then, once files are committed (Step 7), disable Issues (we don't take those either):

```powershell
gh repo edit RelentlessOldMan/<Name> --enable-issues=false --enable-wiki=false
```

---

## Step 2 — `LICENSE` (MIT)

Exact copyright line — note the URL suffix (all my repos use this form):

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

---

## Step 3 — `.gitattributes`

Same everywhere. Prevents CRLF churn and the commit-time warnings:

```gitattributes
# Normalize line endings: LF in the repository, checked out natively.
* text=auto eol=lf

# Windows-specific text files keep CRLF.
*.sln text eol=crlf

# Binary / index artifacts (belt-and-suspenders; these are gitignored anyway).
*.idx binary
*.bin binary
```

---

## Step 4 — `.gitignore`

Use a language-appropriate one. Baseline editor/OS block for every repo:

```gitignore
# Editor / OS
.vscode/
.idea/
.DS_Store
Thumbs.db
```

Python projects add:

```gitignore
# Python
__pycache__/
*.py[cod]
*.egg-info/
.venv/
venv/

# PyInstaller build output
build/
dist/
*.spec
```

.NET projects add `bin/`, `obj/`, and any `.corpus/` / test-scratch dirs. Never
commit generated corpora or build output.

---

## Step 5 — `.github/workflows/close-prs.yml`

**Canonical filename is `close-prs.yml`.** Replace `<Name>` and `<emoji>`:

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

---

## Step 6 — `README.md` skeleton

Structure I use: title + emoji, a **bold one-line hook**, a screenshot, then the
usual sections. The last two sections are **required and identical in form** across
every repo:

```markdown
# <Name> <emoji>

**<One-line hook — what it does, in a sentence.>** A short paragraph expanding on it.

![<Name> in action](docs/screenshot.png)

## Why
...

## Usage
...

## How it works
...

## Layout
```
<file tree>
```

## Contributing

This is a personal tool, published as-is — **issues and pull requests aren't accepted** (PRs auto-close). Fork it and make it your own. <emoji>

## License

MIT — see [LICENSE](LICENSE). © <year> RelentlessOldMan.
```

Keep the **Contributing** and **License** lines verbatim (only the emoji/year change).

---

## Step 7 — First commit & push

```powershell
cd C:\Playground\<Name>
git init -b main
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/RelentlessOldMan/<Name>.git
git push -u origin main
```

(If `gh repo create` already made the remote, skip `git remote add`.)

---

## Step 8 — Add it to the profile README

Clone/pull `RelentlessOldMan/RelentlessOldMan`, add a bullet under the matching
section (`Dev / AI`, `Music`, `Rhythm Gaming`, `Magic: The Gathering`, …), commit,
push. Format:

```markdown
- <emoji> **[<Name>](https://github.com/RelentlessOldMan/<Name>)** — <one-line hook>.
```

---

## Optional — release script

Single-file tools (Subtap, Subsync) ship a `release.ps1` that bumps a version, tags,
and cuts a GitHub Release with the artifact attached (`gh release create`). Copy that
pattern if the project has a downloadable build. Larger projects (CodeCompass) use a
`make-release.ps1` that publishes a self-contained zip.

---

## Final checklist

- [ ] `LICENSE` (MIT, correct copyright line with URL)
- [ ] `.gitattributes` (LF normalization)
- [ ] `.gitignore` (language-appropriate; no build output / corpora)
- [ ] `.github/workflows/close-prs.yml`
- [ ] README has `## Contributing` (decline) + `## License` sections, verbatim
- [ ] Issues disabled: `gh repo edit --enable-issues=false`
- [ ] Added to the profile README under the right section
