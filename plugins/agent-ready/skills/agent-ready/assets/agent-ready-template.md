# AGENTS.md Template

Use this template when generating a new AGENTS.md. Fill in sections based on actual codebase analysis. Remove sections that do not apply. Target ~120 lines.

Note: Claude Code supports AGENTS.md directly starting with version 2.1.277, so no CLAUDE.md symlink is needed. See [the announcement](https://x.com/trq212/status/2101009392611278961).

---

```markdown
# AGENTS.md

## Project
[Project name] -- [One-two sentence description of what it does and why it exists]

## Build & Run
```bash
[package install command]    # Install dependencies
[build command]              # Build the project
[run command]                # Start locally
```

## Session Startup
Before making changes, run through these steps to orient on a fresh context:
1. `pwd` -- confirm working directory
2. `git log --oneline -10` -- see recent work
3. `git fetch origin` -- refresh remote refs before comparing or integrating work
4. Bring the branch up to date with the upstream default branch (`origin/HEAD`) using the repo's merge or rebase strategy
5. Read `PROGRESS.md` if it exists, otherwise skip
6. Run `[smoke-test command]` -- verify the app is in a working state
7. If anything is broken, fix that before starting new work

## Test
```bash
[test command]               # Run full test suite
[single test command]        # Run a single test file
[lint command]               # Run linters
```

## Architecture
See [ARCHITECTURE.md](./ARCHITECTURE.md) for the full codemap.
- [Domain Knowledge](docs/DOMAIN.md) -- business workflows, relationships, and compliance context
- [Domain Context](CONTEXT.md) -- canonical business terms and avoided synonyms (include only when this file exists)

- [Key architectural fact 1 -- e.g., "Monorepo with packages/ for shared code and apps/ for deployables"]
- [Key architectural fact 2 -- e.g., "Domain logic lives in src/domains/, each domain is self-contained"]
- [Key architectural fact 3 -- e.g., "All external API calls go through src/clients/"]

## Key Conventions
- [Directive 1 -- e.g., "Always add tests for new endpoints"]
- [Directive 2 -- e.g., "Never import from another domain's internals; use the public API"]
- [Directive 3 -- e.g., "Prefer composition over inheritance"]
- [Directive 4 -- e.g., "Always validate inputs at service boundaries using [framework/library]"]
- [Directive 5 -- e.g., "Use [naming convention] for [file type]"]
- Never edit, extend, or approve `[quality baseline file]`; when `[quality-gate check command]` reports stale entries, run `[quality-gate prune command]` and commit the result

## Definition of Done
A change is not complete until:
- [Type-check / lint command] passes
- [Test command] passes, including any new tests for the change
- `[quality-gate check command]` passes -- no new or worsened complexity, duplication, or dead code; fix the code rather than touching the baseline
- The feature has been exercised end-to-end, not just unit-tested
  - Backend changes: hit the actual endpoint, inspect the response
  - UI changes: load the page in a browser, click through the flow
- When documentation, documentation paths, or agent aliases change, `python3 scripts/docs-check.py` passes
- No new warnings in the dev server logs
- Commit message describes *why*, not just *what*

Do not mark work complete based on "the code looks right" or "the unit tests pass." Verify it actually runs end-to-end.

## Common Workflows
- Setup: [docs/guides/setup.md](docs/guides/setup.md)
- Testing patterns: [docs/guides/testing.md](docs/guides/testing.md)
- Quality gates: [docs/guides/quality-gates.md](docs/guides/quality-gates.md)
- Deployment: [docs/guides/deployment.md](docs/guides/deployment.md)
- Adding a new feature: [docs/guides/new-feature.md](docs/guides/new-feature.md)

## Architecture Decision Records
Create an ADR in [docs/adr/](docs/adr/) only when all of these are true:
- Reversing the decision later would be costly
- A future maintainer would not understand the choice from code alone
- Real alternatives were considered and their trade-offs matter

Do not create ADRs for routine implementation choices, temporary constraints, or self-evident conventions. Record the context, decision, and why; add alternatives or consequences only when they preserve non-obvious context.

## Known Gotchas
- [Gotcha 1 -- e.g., "The `users` table has a trigger that auto-updates `updated_at`; do not set it manually"]
- [Gotcha 2 -- e.g., "Environment variable X must be set even in test; use the .env.test file"]
- [Gotcha 3 -- e.g., "Module Y has a circular dependency with Z; import via the barrel file only"]
```

---

## Template Notes

**Line budget:** Aim for ~120 lines. If a section exceeds 10 lines, extract the detail to a doc and link to it.

**Directive style:** Use must/never/always/avoid/prefer. State the rule, not the rationale. If rationale is needed, put it in a linked doc.

**Linked docs:** Use markdown links (`[path](path)`) to point to docs that exist or will be created. Each link is a promise that the file contains useful detail the agent can read on demand. Link `CONTEXT.md` only when it exists. Do NOT use `@file` syntax -- that eagerly loads files into context on every conversation, defeating progressive disclosure.

**AGENTS.md and Claude Code:** AGENTS.md is the shared instruction file. Claude Code supports it directly starting with version 2.1.277 ([announcement](https://x.com/trq212/status/2101009392611278961)); do not create or require a CLAUDE.md symlink. Preserve an existing CLAUDE.md unless explicitly asked to consolidate it.

**Structured ledgers -- prefer JSON over Markdown:** For files that track state agents update incrementally (task lists, feature status, work queues), use JSON with a strict schema rather than Markdown. Agents are far less likely to inappropriately edit, reformat, or "improve" a JSON file. Pair it with an explicit directive in AGENTS.md (e.g., "In `tasks.json`, only flip the `status` field -- never edit `description` or `acceptance_criteria`").

**What NOT to include:**
- Code examples longer than 5 lines (put in a guide)
- API inventories or module lists (put in ARCHITECTURE.md)
- Setup tutorials (put in docs/guides/setup.md)
- Historical context or decision rationale (put in ADRs)
- Anything that changes frequently (will rot in AGENTS.md)
