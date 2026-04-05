---
globs:
  - "*.ts"
  - "*.tsx"
  - "*.js"
  - "*.jsx"
  - "*.py"
  - "*.go"
  - "*.rs"
  - "*.rb"
  - "*.java"
---

# Documentation Hygiene

When modifying code:

1. **Update co-located docs** — if a function signature, API endpoint, or config variable changes and there's a matching doc file nearby, update it in the same commit
2. **Use conventional commits** — prefix commit messages with `feat:`, `fix:`, `refactor:`, `perf:`, `security:`, or `docs:` so doc-sync can detect what changed
3. **No stale comments** — if you change behavior, update the comment. Delete comments that describe removed behavior
4. **Docstrings for public APIs** — exported functions, classes, and route handlers need descriptions. Internal helpers do not
5. **Keep env vars documented** — when adding `process.env.NEW_VAR` or equivalent, ensure `.env.example` is updated
