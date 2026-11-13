# New GitHub repo setup — RelentlessOldMan conventions

Point a Claude session at this file when starting a new public project so the repo
matches the rest of my GitHub. Everything here is "personal tool, published as-is":
**MIT-licensed, no contributions accepted: pull requests off, issues limited to collaborators.**

Owner: **RelentlessOldMan** (https://github.com/RelentlessOldMan)
Copyright line: `© <year> RelentlessOldMan` (use the current year).

---

## The rules (what every repo must have)

1. **MIT license** — `LICENSE` file + a `## License` section in the README.
2. **No contributions** — a `## Contributing` section that declines them, and two repo
   settings: **Pull requests turned off**, and **Issues on but limited to collaborators**
   (so I can use them as my own to-do list; everyone else can still read them). No
   auto-close workflows; the settings do that job.
3. **Line-ending hygiene** — a `.gitattributes` that normalizes to LF (prevents the
   "LF will be replaced by CRLF" warnings on every commit).
4. **A signature emoji** for the project, used in the README title and the Contributing
   line.
5. **Listed on the profile** — add it to the `RelentlessOldMan/RelentlessOldMan`
   profile README under the right category section.

---

## Step 1 — Create the repo

```powershell
gh repo create RelentlessOldMan/<Name> --public --description "<one-line hook>"
```

Then turn pull requests off and the wiki off, and make sure issues are on:

```powershell
gh api -X PATCH repos/RelentlessOldMan/<Name> -F has_issues=true -F has_pull_requests=false -F has_wiki=false
```

Last, limit issue creation to collaborators. This one isn't in the API or `gh`, so it's
done in the web UI: **Settings → General → Features → Issues → Issue permissions →
"Creation allowed by: Collaborators only"**. (In Claude in Chrome, pick that option from
the dropdown; it saves on its own, no Save button.)

Result, under Settings → Features: **Issues ☑ (Collaborators only)**, **Pull requests ☐**,
Wikis ☐. Forking stays on; that's how people are meant to use it.

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

## Step 5 — `README.md` skeleton

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

This is a personal tool, published as-is, and doesn't take issues or pull requests. Fork it and make it your own. <emoji>

## License

MIT — see [LICENSE](LICENSE). © <year> RelentlessOldMan.
```

Keep the **Contributing** and **License** lines verbatim (only the emoji/year change).

---

## Step 6 — First commit & push

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

## Step 7 — Add it to the profile README

The local copy is `C:\Playground\RelentlessOldMan`: pull it there (never clone a second
copy anywhere else), add a bullet under the matching
section (`Dev / AI`, `Music`, `Rhythm Gaming`, `Magic: The Gathering`, …), commit,
push. Format:

```markdown
- <emoji> **[<Name>](https://github.com/RelentlessOldMan/<Name>)** — <one-line hook>.
```

---

## Optional — release script

Single-file tools (Subtap, Subsync) ship a `release.ps1` that bumps the version, tags,
and cuts a GitHub Release with the artifact attached (`gh release create`). Copy that
pattern if the project has a downloadable build. Larger projects (CodeCompass) use a
`make-release.ps1` that publishes a self-contained zip.

Versions are date-based (`2026.11.13.0`, bumped on every build that day). See
[VERSIONING.md](VERSIONING.md); the existing scripts' semver patch bumps are the old way.

---

## Final checklist

- [ ] `LICENSE` (MIT, correct copyright line with URL)
- [ ] `.gitattributes` (LF normalization)
- [ ] `.gitignore` (language-appropriate; no build output / corpora)
- [ ] README has `## Contributing` (decline) + `## License` sections, verbatim
- [ ] Pull requests off, wiki off: `gh api -X PATCH ... -F has_pull_requests=false -F has_wiki=false`
- [ ] Issues on, creation limited to **Collaborators only** (Settings → Features, web UI)
- [ ] No `close-prs.yml` / `close-issues.yml` workflows
- [ ] Added to the profile README under the right section
