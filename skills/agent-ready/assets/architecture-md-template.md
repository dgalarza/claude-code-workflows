# ARCHITECTURE.md Template

Use this template when generating an ARCHITECTURE.md. Fill in sections based on actual codebase analysis. Name real files, modules, and types discovered during reconnaissance.

---

```markdown
# Architecture

## Overview
[One paragraph describing the problem this system solves and why it exists. Focus on the problem domain, not the implementation.]

## Codemap

The codebase is organized as follows:

### [Top-Level Directory 1] -- [Purpose]
[One-two sentence description of what this module/directory contains and its role in the system.]

Key modules:
- `[file or module name]` -- [one-line description]
- `[file or module name]` -- [one-line description]

### [Top-Level Directory 2] -- [Purpose]
[One-two sentence description.]

Key modules:
- `[file or module name]` -- [one-line description]
- `[file or module name]` -- [one-line description]

### [Top-Level Directory N] -- [Purpose]
[Continue for each significant top-level directory.]

## Invariants

Rules that hold across the codebase. Include absences -- things that deliberately do NOT exist.

- [Invariant 1 -- e.g., "All database access goes through the repository layer; no direct SQL in service code"]
- [Invariant 2 -- e.g., "There is no global state; all configuration is dependency-injected"]
- [Invariant 3 -- e.g., "External API responses are always validated at the boundary before use"]
- [Absence 1 -- e.g., "There is no ORM; queries are hand-written in db/queries/"]
- [Absence 2 -- e.g., "There is no custom authentication; we delegate entirely to [service]"]

## Boundaries

### Public API vs Internal
- [Boundary 1 -- e.g., "`src/api/` exposes the public HTTP interface; everything else is internal"]
- [Boundary 2 -- e.g., "Each domain in `src/domains/` exports only through its `index.ts`; internal modules are not imported directly"]

### Layer Dependencies
- [Rule 1 -- e.g., "Controllers depend on services, services depend on repositories, repositories depend on models. Never skip layers."]
- [Rule 2 -- e.g., "The `shared/` directory may be imported by any module but never imports from domain code"]

## Cross-Cutting Concerns

### Error Handling
[How errors are handled across the system -- e.g., "All errors flow through `src/errors/` and are mapped to HTTP status codes at the controller layer"]

### Logging & Observability
[Logging approach -- e.g., "Structured JSON logging via `src/logger.ts`. All log calls include a correlation ID from the request context."]

### Authentication & Authorization
[Auth approach -- e.g., "JWT validation happens in middleware at `src/middleware/auth.ts`. Services receive a validated user context, never raw tokens."]

### Configuration
[Config approach -- e.g., "All config loaded at startup from environment variables via `src/config.ts`. No runtime config changes."]
```

---

## Template Notes

**Keep it stable:** Only include things unlikely to change frequently. This document should be revisited a few times a year, not every sprint.

**Name, don't link:** Reference file and module names so readers can search for them. Avoid hyperlinks that go stale.

**One-line descriptions:** Each module in the codemap gets one line. If it needs more, that detail belongs in a separate doc.

**Absences matter:** The hardest-to-discover invariants are things that do NOT exist. Always include an "absences" section.

**Right granularity:** This is a country map, not a city street map. If you are describing individual functions, you have gone too deep.
