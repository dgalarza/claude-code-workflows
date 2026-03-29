# Single-Package Documentation Audit Patterns

Additional audit considerations for standard single-package projects.

## Detection

A project is single-package if:
- No monorepo config files exist (turbo.json, nx.json, lerna.json, pnpm-workspace.yaml)
- Standard directory structure: src/, lib/, app/, tests/, config/

## Completeness Checks

- [ ] **Entry point documented** -- The main entry file (src/index.*, main.*, app.*) is mentioned in docs
- [ ] **Directory structure** -- ARCHITECTURE.md codemap covers all top-level source directories
- [ ] **API surface** -- If the project exposes an API (REST, GraphQL, CLI), it's documented
- [ ] **Configuration** -- Environment variables and config files are documented
- [ ] **Testing** -- How to run tests, test file conventions, test fixtures location

## Accuracy Checks

- [ ] **Source directory names** -- Directories mentioned in docs match actual filesystem
- [ ] **Import paths** -- Any import examples in docs use correct module paths
- [ ] **CLI commands** -- If the project has a CLI, documented commands match actual implementation
- [ ] **Dependencies** -- Major dependencies listed in docs match package manifest

## Freshness Checks

- [ ] **New modules** -- Recently added source directories are covered in the codemap
- [ ] **Deleted modules** -- Removed directories are no longer referenced
- [ ] **API changes** -- New endpoints, commands, or public functions are documented

## Coherence Checks

- [ ] **Single source of truth for setup** -- Build/run instructions appear in one place, linked from others
- [ ] **Consistent terminology** -- The same concepts use the same names throughout docs
- [ ] **Test commands match CI** -- Documented test commands match what CI runs

## Common Single-Package Doc Failures

1. **Stale entry point** -- docs reference `src/index.ts` but project uses `src/main.ts`
2. **Missing config docs** -- Environment variables are used in code but not documented
3. **Test instructions wrong** -- `npm test` fails because the project uses `jest --config custom.config.js`
4. **Outdated architecture** -- Major refactor moved code between directories but ARCHITECTURE.md wasn't updated
