---
globs: "*.md"
---

# Documentation Reference Hygiene

When writing or editing documentation files:

1. **Use relative paths** — reference source files with paths relative to the repo root (e.g., `src/routes/auth.ts`, not `/Users/me/project/src/routes/auth.ts`). Relative paths are detectable by drift scanning.

2. **Quote file paths in backticks** — wrap paths in backticks so automated tools can extract them: `src/routes/auth.ts` not src/routes/auth.ts.

3. **Keep path references specific** — reference `src/routes/auth.ts` not just `src/routes/`. Specific paths enable precise drift detection when files change.

4. **Document ports with their source** — when mentioning a port, note where it is configured: "Dashboard runs on port 4000 (configured in `compose.yml`)". This makes drift traceable.

5. **Document env vars with their location** — when referencing environment variables, note where they are defined: "`DATABASE_URL` (set in `.env`)".

6. **Update docs in the same commit as code changes** — when renaming files, changing ports, or modifying env vars, update any documentation that references them in the same commit. This prevents drift from accumulating.

7. **Use conventional commit prefixes for doc changes** — prefix documentation-only commits with `docs:` to prevent drift detection hooks from re-triggering.
