# GitHub Documentation Review

Perform a comprehensive review and improvement pass over this project's **public GitHub documentation and presentation**.

This is not merely a proofreading exercise.

Treat the project's GitHub presence as a product surface. Someone arriving at the repository or its GitHub Pages site should quickly understand:

- what the project is
- why it exists
- what it actually does
- whether it is useful to them
- what it looks like
- how to install or run it
- how to accomplish common tasks
- where to find deeper information
- what its important limitations are

You have broad authority to reorganize, rewrite, merge, split, add, or remove documentation when doing so improves the overall experience.

---

# Project Philosophy

This is primarily a **personal software project made publicly available because other people may find it useful**.

Do not turn its documentation into generic corporate or open-source-community boilerplate.

The desired style is:

- practical
- direct
- technically accurate
- concise where possible
- detailed where useful
- approachable
- visually clear
- honest about limitations
- written for actual users

Never add:

- contributor recruitment
- governance language

Avoid unnecessary:

- marketing language
- corporate mission statements
- maintainer hierarchies
- community-building boilerplate
- exaggerated claims
- generic badges
- giant feature dumps
- documentation created merely to check a box

The documentation should feel like a competent developer showing someone a useful thing they built and giving them everything necessary to use and understand it.

---

# Protected House Standards

## CONTRIBUTING

Do not redesign the contribution policy.

The policy is fixed:

- this is a personal tool, published as-is
- issues and pull requests are not accepted (issues are disabled and PRs auto-close)
- users are welcome to fork it and make it their own

The README must contain a Contributing section with exactly this text (add it if missing):

```text
This is a personal tool, published as-is — **issues and pull requests aren't accepted** (PRs auto-close). Fork it and make it your own. <emoji>
```

`<emoji>` is the project's own signature emoji; keep whichever one the project already uses.

Never:

- add `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, issue templates, pull request templates, or `FUNDING.yml`
- enable or point readers to GitHub Discussions
- use "good first issue", "help wanted", or similar recruitment wording
- tell readers to open an issue, file a bug, or submit a pull request

Leave the `.github/workflows/close-prs.yml` auto-close workflow alone.

Only fix typos in the Contributing section. Do not reword it, soften it, or transform the repository into a contribution-driven community project.

## LICENSE

The license is MIT, in a `LICENSE` file at the repository root.

The README License section must read:

```text
MIT — see [LICENSE](LICENSE). © <year> RelentlessOldMan.
```

Do not recommend changing the license unless there is an actual repository-specific legal or consistency problem that needs to be surfaced.

Do not spend review effort debating licensing philosophy.

---

# Scope

Review the entire public-facing GitHub experience, including where applicable:

- repository landing page
- `README.md`
- GitHub Pages site
- `docs/`
- Quick Start
- User Guide
- tutorials
- examples
- screenshots
- GIFs/video links
- diagrams
- CLI documentation
- configuration documentation
- API/reference documentation
- architecture/design documentation
- developer/build documentation
- troubleshooting information
- FAQ
- generated documentation
- release/download instructions
- badges
- repository navigation
- cross-links between documents
- links to source files and examples
- documentation generation scripts
- GitHub Pages configuration
- documentation-related GitHub Actions/workflows

Also inspect the implementation, tests, examples, CLI help, configuration structures, project files, build scripts, and release workflow when necessary to verify documentation claims.

**The implementation is the source of truth.**

Do not assume existing documentation is correct simply because it exists.

---

# 1. Understand the Project

Before changing documentation, understand the project.

Determine:

- its actual purpose
- its primary users
- primary use cases
- major features
- major workflows
- supported platforms
- prerequisites
- installation options
- runtime requirements
- inputs
- outputs
- configuration mechanisms
- command-line interfaces
- external services/APIs
- persistent data
- important limitations
- experimental functionality
- security-sensitive behavior
- network behavior
- privacy implications
- destructive operations
- common failure modes
- build process
- testing strategy
- release/distribution process

Then compare that understanding with what GitHub currently presents.

Identify documentation that is:

- missing
- stale
- misleading
- technically incorrect
- redundant
- poorly located
- unnecessarily verbose
- insufficiently explained
- difficult to discover

---

# 2. Repository First Impression

Evaluate the repository as if you have never seen the project before.

The first screenful matters enormously.

Within seconds, a visitor should be able to answer:

**What the hell is this?**

Then:

**Why would I use it?**

Then:

**What does it look like / what does it produce?**

Then:

**How do I try it?**

Aggressively review the top portion of the README.

Do not bury the actual purpose underneath:

- badges
- logos
- architecture
- implementation details
- long introductions
- development information
- acknowledgments
- generic project language

Prefer concrete descriptions.

Bad:

> An extensible next-generation framework designed to optimize workflows.

Better:

> A desktop editor for creating custom Magic: The Gathering cards, including Scryfall import, custom artwork, reusable card styles, batch generation, and printable sheets.

Use wording appropriate to THIS project.

---

# 3. README Architecture

Treat the README as the project's front door, not its entire documentation system.

A strong README will commonly contain some variation of:

1. Project name / identity
2. One-sentence explanation
3. Screenshot or compelling example
4. Key capabilities
5. Installation / download
6. Quick start
7. A few representative examples
8. Links to deeper documentation
9. Important limitations/status where relevant
10. License/contribution information near the end

Do not mechanically force this exact structure when another structure works better.

The README should optimize for:

**understand → evaluate → try**

It should not require someone to read the entire manual.

---

# 4. GitHub Pages Review

Treat GitHub Pages as the project's actual documentation site rather than a duplicate README.

Evaluate:

- landing page
- navigation
- hierarchy
- discoverability
- visual consistency
- readability
- mobile behavior where relevant
- page titles
- headings
- table of contents
- code formatting
- links
- image sizing
- navigation between related topics
- navigation back to the repository
- access to releases/downloads
- stale pages
- duplicate information

Determine whether GitHub Pages provides meaningful value beyond rendering repository Markdown.

If the Pages site exists, it should make deeper documentation substantially easier to consume.

---

# 5. Information Architecture

Review how information is divided among:

- README
- Quick Start
- User Guide
- tutorials
- examples
- reference
- troubleshooting
- architecture
- developer documentation

Existing files are not sacred.

You may:

- add pages
- delete obsolete pages
- rename pages
- merge redundant pages
- split oversized pages
- move sections
- restructure navigation
- replace duplicate explanations with links
- create a clearer hierarchy

However, do not create documentation simply for organizational aesthetics.

Every page should have a reason to exist.

A useful conceptual division is:

**README**  
Understand, evaluate, and start.

**Quick Start**  
Get something useful working immediately.

**User Guide**  
Learn normal workflows.

**Examples**  
Copy and adapt real usage.

**Reference**  
Look up exact behavior.

**Troubleshooting**  
Solve problems.

**Architecture / Development**  
Understand or modify the implementation.

---

# 6. Progressive Disclosure

Users should encounter complexity gradually.

Prefer:

**What is this?**

→ **Show me**

→ **Get me running**

→ **Show me the common workflow**

→ **Teach me more**

→ **Give me examples**

→ **Give me exact reference information**

→ **Explain the internals**

A normal user should not need to understand architecture.

A developer should still be able to find architecture.

Do not dump every available detail into the README merely because it is important somewhere.

---

# 7. Installation and First Run

Determine the easiest supported way to obtain and run the project.

Present that path first.

If finished releases/binaries exist, ordinary users generally should not encounter:

```text
git clone
<install dependencies>
<build from source>
```

(e.g. `dotnet build`, `npm install && npm run build`, `pip install -e .`, `cargo build`)

before being told they can simply download a release.

Clearly distinguish:

- download/install
- prerequisites
- first run
- building from source
- development environment setup

Verify every command.

Verify every URL.

Verify every path.

Verify prerequisites against the actual project.

---

# 8. Quick Start

The Quick Start must actually be quick.

It should demonstrate the smallest meaningful success case.

Do not turn Quick Start into a condensed User Guide.

A user following it should reach a useful result with minimal decisions.

Where applicable include:

- exact command/action
- minimal required input
- expected result
- next logical step

Commands should be copyable.

Examples should actually work.

---

# 9. Feature Documentation

Compare documented features with implemented features.

Look for:

- implemented features missing from documentation
- documented features that no longer exist
- renamed functionality
- changed behavior
- experimental features presented as finished
- major features buried beneath minor ones

Organize features by what users care about rather than by implementation structure.

Avoid giant undifferentiated bullet lists.

Prefer meaningful groups and concrete descriptions.

---

# 10. Examples

Treat examples as first-class documentation.

Review whether examples cover realistic tasks such as:

- simplest useful workflow
- normal workflow
- batch workflow
- configuration
- advanced usage
- scripting/automation
- unusual but useful functionality

Where appropriate, examples should contain:

**Input → Action → Result**

Verify:

- commands
- filenames
- configuration keys
- API calls
- paths
- generated output
- screenshots
- expected behavior

If useful example artifacts already exist in the repository, make sure documentation exposes them effectively.

---

# 11. Screenshots and Visual Documentation

For GUI applications or projects producing visual output, screenshots are especially important.

Ask:

- Can I see what this thing is before installing it?
- Is there a strong screenshot near the top?
- Are major workflows worth illustrating?
- Are screenshots current?
- Are screenshots readable at normal GitHub width?
- Do they show meaningful states rather than empty windows?
- Are captions helpful?
- Are there too many?
- Are important visuals buried?
- Would before/after examples help?
- Would a gallery help?

For generated-output projects, show representative output.

For command-line/backend projects, do not manufacture unnecessary visual documentation.

Use diagrams only when they genuinely explain something better than prose.

---

# 12. Accuracy Audit

Cross-check factual claims against the repository.

Verify things such as:

- feature counts
- test counts
- supported platforms
- supported languages
- supported formats
- template/frame/provider/plugin counts
- commands
- command options
- defaults
- environment variables
- configuration keys
- dependency requirements
- output formats
- output dimensions
- release packaging
- offline/online behavior
- external API usage
- performance claims
- security behavior

Be suspicious of exact numbers that require manual maintenance.

For example:

> 177 tests

may be accurate today and wrong tomorrow.

Ask whether the exact number provides enough value to justify becoming stale.

Where useful, automate such information instead.

---

# 13. Documentation Drift

Actively hunt for drift between documentation and implementation.

Search for:

- old command names
- renamed features
- removed features
- obsolete options
- stale screenshots
- old UI layouts
- obsolete architecture descriptions
- old filenames
- outdated paths
- stale TODOs
- completed features still described as planned
- features implemented but never documented
- changed defaults
- obsolete configuration examples
- outdated build instructions
- old release procedures

Do not merely report obvious drift.

Correct it when the appropriate fix is clear.

---

# 14. Duplication

Find information maintained manually in multiple places.

Examples:

- README and User Guide explaining the same workflow
- option lists duplicated across several pages
- architecture explanations repeated verbatim
- installation instructions copied everywhere
- feature lists maintained independently
- version requirements repeated across pages

Duplication creates documentation drift.

Prefer one authoritative explanation with good navigation to it.

Some intentional duplication is fine when it materially improves onboarding, especially short summaries.

---

# 15. Navigation and Linking

Review documentation navigation as a system.

Check:

- README → documentation
- README → releases
- README → examples
- Pages → repository
- Pages → releases
- guide → reference
- examples → relevant guide
- troubleshooting → relevant configuration/reference
- architecture → relevant source directories

Check for:

- broken links
- stale anchors
- incorrect relative paths
- links that unnecessarily leave GitHub
- circular navigation
- orphaned pages
- important pages reachable only by knowing their filename

A user should not have to explore the repository tree to discover documentation.

---

# 16. Troubleshooting

Determine whether realistic failure modes are documented.

Examples include:

- missing runtime/dependency
- permissions
- invalid configuration
- malformed input
- network/API failures
- rate limits
- missing assets
- unsupported files
- path problems
- platform-specific behavior
- build failures

Do not create an enormous speculative troubleshooting encyclopedia.

Document failures that are realistically likely or evident from the implementation, tests, or commit history. (GitHub issues are disabled, so there is no issue tracker to mine.)

Where the application produces useful error messages, documentation should complement rather than repeat them.

---

# 17. Technical / Architecture Documentation

Determine whether architecture documentation is useful and proportional to the project.

Document important concepts such as:

- major components
- data flow
- persistence
- rendering pipeline
- indexing pipeline
- plugin architecture
- external integrations
- important abstractions
- unusual implementation decisions

Do not document every class.

Do not convert source code into prose.

Architecture documentation should explain things that are difficult to understand simply by navigating the code.

---

# 18. Developer Documentation

A developer wanting to understand or fork the project should be able to determine:

- prerequisites
- repository layout
- build command
- test command
- run/debug procedure
- generated files
- important tooling
- packaging/release process
- unusual development constraints

Remember the project philosophy:

The goal is to make the source understandable and forkable, **not to recruit contributors**.

---

# 19. Tone and Writing Quality

Review all documentation for:

- unnecessary verbosity
- repetition
- vague language
- unexplained jargon
- awkward wording
- grammar
- inconsistent terminology
- inconsistent capitalization
- excessive headings
- enormous paragraphs
- excessive parentheticals
- generic AI-sounding prose

Remove phrases such as:

> robust and comprehensive solution

> powerful and flexible framework

> seamless experience

> designed with extensibility in mind

unless the statement conveys something concrete and demonstrable.

Prefer specific claims.

Do not sterilize personality unnecessarily.

Documentation can sound like it was written by an actual person.

---

# 20. AI-Slop Audit

Specifically look for documentation that appears mechanically generated without adding useful information.

Warning signs include:

- repetitive summaries
- every section beginning with explanatory filler
- excessive emoji
- unnecessary "Why X?" sections
- restating obvious headings
- excessive tables
- needless comparison matrices
- fake quotations
- marketing superlatives
- conclusions that merely repeat the page
- excessive callout blocks
- obvious statements expanded into paragraphs
- huge lists where five useful items would suffice

Delete low-information prose.

Optimize for information density without making the documentation terse or hostile.

---

# 21. Markdown Quality

Check Markdown itself.

Verify:

- heading hierarchy
- code fences
- language identifiers
- tables
- lists
- image syntax
- relative links
- anchors
- blockquotes
- escaping
- HTML usage
- whitespace
- rendering on GitHub

Avoid clever Markdown that renders inconsistently.

Prefer simple structures.

---

# 22. GitHub Pages Quality

If GitHub Pages is generated from Markdown, Jekyll, MkDocs, or another system, inspect the documentation infrastructure.

Check:

- build configuration
- navigation configuration
- theme configuration
- generated output exclusions
- source organization
- link handling
- assets
- deployment workflow
- reproducibility

Do not redesign working infrastructure merely for technical elegance.

Improve it when doing so directly improves documentation maintainability or user experience.

---

# 23. Repository Presentation

Review other GitHub-facing details represented in or inferable from the repository.

Consider:

- repository description
- project website link
- topics
- release discoverability
- README hero content
- logo/icon usage
- badges
- screenshots
- links to related projects

Badges should communicate useful information.

Do not create a NASCAR hood of badges.

The repository description, website link, and topics are GitHub settings, not repository files. Recommend changes to them in the final report; do not apply them with `gh` or the GitHub API.

Never push, publish, create releases, or change repository settings as part of this review.

---

# 24. Related Projects

If this project belongs to a family of related projects, determine whether cross-linking would genuinely help users.

For example:

> If you like this project, you may also find X useful because it does Y.

Do not turn every README into an advertisement for every repository owned by the author.

Only link projects with a meaningful relationship.

---

# 25. Documentation Maintainability

Look for opportunities to prevent future documentation drift.

Consider whether information can be generated from:

- CLI `--help`
- source metadata
- test output
- build configuration
- release metadata
- schemas
- templates
- configuration definitions

Prefer generated authoritative information when it eliminates meaningful maintenance.

Do not introduce elaborate documentation-generation infrastructure to automate trivial text.

---

# 26. User Journey Test

Mentally walk through several users.

## Visitor

They landed on GitHub from a link.

Can they determine what the project is in 10–20 seconds?

## Interested User

They think the project might help them.

Can they see what it looks like and what it can do?

## New User

They want to try it.

Can they get from GitHub to first success without understanding the source code?

## Returning User

They forgot how to perform a particular operation.

Can they find the answer quickly?

## Advanced User

They need exact configuration/CLI/reference information.

Can they locate it without searching source code?

## Developer/Forker

They want to understand and modify the implementation.

Can they build, test, debug, and understand the major architecture?

Use failures in these journeys to drive documentation improvements.

---

# 27. Classification

For every significant documentation artifact or major section reviewed, classify it when useful as:

## KEEP

Correct, useful, appropriately located, and appropriately detailed.

## IMPROVE

Fundamentally useful but needs rewriting, clarification, updating, formatting, or expansion.

## MERGE

Useful information duplicated across multiple locations that should have one authoritative home.

## SPLIT

A document or section is trying to serve incompatible audiences or has become too large.

## MOVE

Useful content exists but belongs somewhere else in the documentation hierarchy.

## GENERATE

Useful information should be generated automatically rather than manually maintained.

## ADD

Important documentation is missing.

## DEPRECATE

Material is retained temporarily but should no longer be considered authoritative.

## DELETE

Content is obsolete, redundant, misleading, useless, or actively makes the documentation worse.

Do not preserve documentation merely because someone previously spent time writing it.

---

# 28. Make Improvements

This is an implementation-oriented review.

Do not stop after producing a list of observations.

After understanding the project:

1. Identify problems.
2. Determine the desired documentation architecture.
3. Fix straightforward issues.
4. Rewrite weak material.
5. Reorganize where beneficial.
6. Add genuinely missing documentation.
7. Remove obsolete/redundant material.
8. Fix navigation.
9. Fix broken links.
10. Verify examples.
11. Verify GitHub Pages still builds correctly — locally only (e.g. `bundle exec jekyll build`, `mkdocs build`); never push or trigger a deployment to check it.
12. Verify the resulting documentation against the implementation.

Preserve useful existing work.

Do not rewrite good documentation simply to make it different.

---

# Working Practice

- Commit one logical documentation change per commit, with the change named in the subject.
- After any scripted or bulk edit, run `git diff --stat` and check for surprises: 0-byte files, whole-file churn, line-ending or byte-order-mark changes.
- On a long session, keep findings and progress in a file at a durable location (the repository's docs folder, or another fixed path the user agrees to), not only in the conversation or a temporary folder.
- Keep the user informed: post one line when each significant change lands.
- In the final report, give your recommended option and its cost for every gap or follow-up left open, so the user can decide without another round trip.

---

# 29. Final Review Report

After completing the pass, provide a concise report containing:

## Overall Assessment

Describe the state of the GitHub documentation before the review and the major improvements made.

## Major Changes

List the important structural or content changes.

## Accuracy Fixes

Call out significant cases where documentation disagreed with implementation.

## Added Documentation

Identify meaningful new material.

## Removed/Merged Documentation

Explain major deletions or consolidations.

## Remaining Gaps

List anything that still needs human input, screenshots, decisions, external verification, or future work.

## Recommended Follow-Ups

Include only recommendations that provide meaningful additional value.

---

# Final Principle

The goal is not to maximize documentation.

The goal is to maximize the probability that someone encountering this project on GitHub can:

**understand it → decide if they want it → successfully use it → find deeper answers when needed.**

Prefer useful documentation over comprehensive documentation.

Prefer concrete examples over abstract explanation.

Prefer one authoritative explanation over duplicated prose.

Prefer screenshots over paragraphs when the project is inherently visual.

Prefer working commands over descriptions of commands.

Prefer accuracy over impressive-looking claims.

Prefer deleting bad documentation over maintaining it forever.

And above all:

**Document the project that actually exists, not the project the documentation claims exists.**