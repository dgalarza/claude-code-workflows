# CLAUDE.md Template

Use this template when generating a new CLAUDE.md. Fill in sections based on actual codebase analysis. Remove sections that do not apply. Target ~100 lines.

---

```markdown
# CLAUDE.md

## Project
[Project name] -- [One-two sentence description of what it does and why it exists]

## Build & Run
```bash
[package install command]    # Install dependencies
[build command]              # Build the project
[run command]                # Start locally
```

## Test
```bash
[test command]               # Run full test suite
[single test command]        # Run a single test file
[lint command]               # Run linters
```

## Architecture
See [ARCHITECTURE.md](./ARCHITECTURE.md) for the full codemap.

- [Key architectural fact 1 -- e.g., "Monorepo with packages/ for shared code and apps/ for deployables"]
- [Key architectural fact 2 -- e.g., "Domain logic lives in src/domains/, each domain is self-contained"]
- [Key architectural fact 3 -- e.g., "All external API calls go through src/clients/"]

## Key Conventions
- [Directive 1 -- e.g., "Always add tests for new endpoints"]
- [Directive 2 -- e.g., "Never import from another domain's internals; use the public API"]
- [Directive 3 -- e.g., "Prefer composition over inheritance"]
- [Directive 4 -- e.g., "Always validate inputs at service boundaries using [framework/library]"]
- [Directive 5 -- e.g., "Use [naming convention] for [file type]"]

## Common Workflows
- Setup: [docs/guides/setup.md](docs/guides/setup.md)
- Testing patterns: [docs/guides/testing.md](docs/guides/testing.md)
- Deployment: [docs/guides/deployment.md](docs/guides/deployment.md)
- Adding a new feature: [docs/guides/new-feature.md](docs/guides/new-feature.md)

## Architecture Decision Records
When making significant architectural decisions, create an ADR in [docs/decisions/](docs/decisions/).

Write an ADR when:
- Choosing between competing architectural approaches
- Adopting or rejecting a major technology or framework
- Establishing cross-cutting patterns (auth, logging, error handling)
- Making trade-offs that affect system design

Use the [ADR template](docs/decisions/) to document context, the decision, consequences, and alternatives considered.

## Known Gotchas
- [Gotcha 1 -- e.g., "The `users` table has a trigger that auto-updates `updated_at`; do not set it manually"]
- [Gotcha 2 -- e.g., "Environment variable X must be set even in test; use the .env.test file"]
- [Gotcha 3 -- e.g., "Module Y has a circular dependency with Z; import via the barrel file only"]
```

---

## Template Notes

**Line budget:** Aim for ~100 lines. If a section exceeds 10 lines, extract the detail to a doc and link to it.

**Directive style:** Use must/never/always/avoid/prefer. State the rule, not the rationale. If rationale is needed, put it in a linked doc.

**Linked docs:** Use markdown links (`[path](path)`) to point to docs that exist or will be created. Each link is a promise that the file contains useful detail the agent can read on demand. Do NOT use `@file` syntax -- that eagerly loads files into context on every conversation, defeating progressive disclosure.

**What NOT to include:**
- Code examples longer than 5 lines (put in a guide)
- API inventories or module lists (put in ARCHITECTURE.md)
- Setup tutorials (put in docs/guides/setup.md)
- Historical context or decision rationale (put in ADRs)
- Anything that changes frequently (will rot in CLAUDE.md)
