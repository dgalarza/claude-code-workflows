---
name: capture
description: Scan recent changes and extract durable knowledge into docs
disable-model-invocation: true
argument-hint: "<range|count>"
allowed-tools: Read, Bash, Glob, Grep, Write, Edit
---

# Capture

Scan recent git changes and extract durable knowledge into project documentation. This skill analyzes what changed, determines what documentation should exist, and creates or updates it.

## `/doc-sync:capture $ARGUMENTS`

### Phase 1: Read Configuration

If `.doc-sync.json` exists in the project root, read it to determine output paths and detection rules. Use the configured `paths` globs to categorize changed files and the configured output paths for writing docs.

If `.doc-sync.json` does not exist, use defaults:
- `api-reference` → `docs/reference/` (triggered by files in `src/**`, `lib/**`, `app/**`)
- `changelog` → `CHANGELOG.md` (triggered by `feat:`, `fix:` commits)
- `architecture` → `ARCHITECTURE.md` (triggered by major restructuring)
- `index` → `docs/INDEX.md` (triggered by doc file changes in `docs/`)

### Phase 2: Determine Scope

If `$ARGUMENTS` is provided, parse it as a commit range or count:
- A number (e.g., `5`) — scan the last N commits
- A range (e.g., `abc123..HEAD`) — scan that range
- Empty — scan since the last capture

To detect "since last capture," check for a `.doc-sync-last-capture` file in the project root. If it exists, read the stored commit hash and use `<hash>..HEAD`. If it doesn't exist, default to scanning the last 5 commits.

### Phase 3: Analyze Changes

Run `git log --oneline <range>` to list commits in scope.

For each commit, run `git diff <commit>~1..<commit> --name-only` to see what files changed.

Categorize each change using the configured `paths` globs from `.doc-sync.json`. If no config exists, use these defaults:

| File Pattern | Doc Type | Target |
|---|---|---|
| `src/**`, `lib/**`, `app/**` | api-reference | `docs/reference/` |
| New top-level directories, major restructuring | architecture | `ARCHITECTURE.md` |
| Any `feat:` or `fix:` commit | changelog | `CHANGELOG.md` |
| Any file in `docs/` added or removed | index | `docs/INDEX.md` |

When `.doc-sync.json` is present, also check for `api-contract`, `env-config`, and `agent-schemas` types using their configured `paths` and `patterns`.

### Phase 4: Generate Documentation

For each category with changes, write to the configured output path:

**api-reference**: Read the changed source files. Identify public exports, route definitions, or API endpoints. Create or update a corresponding doc file in the configured directory. Use the module or file name as the doc filename (e.g., `src/auth.ts` maps to `<directory>/auth.md`).

**agent-schemas**: Read the changed agent/tool files. Extract agent definitions (name, role, model, tools) and tool schemas (name, description, input/output shapes). Write structured tables to the configured file. Use machine-parseable formats — tables with consistent column headers, inline code for types.

**api-contract**: Read the changed route files. Extract endpoint definitions and write to the configured file.

**env-config**: Read the changed config files. Extract environment variables and write to the configured file.

**changelog**: Parse the conventional commit messages in range. Group by type (Added for `feat:`, Fixed for `fix:`, Changed for `refactor:`). Append a new version section to the configured changelog file following Keep a Changelog format. If the file doesn't exist, create it with the standard header.

**architecture**: For new modules or major restructuring, append a section to the configured architecture file describing the new component, its purpose, and how it fits into the system. If the file doesn't exist, create it with a basic template.

**index**: Run the same logic as the index-builder agent — glob all markdown files in the docs root and rebuild the index file at its configured path.

### Phase 5: Commit and Record

If any documentation was created or updated:

1. Stage all doc changes with `git add`
2. Commit with message: `docs: update documentation from recent changes`
3. Update `.doc-sync-last-capture` with the current HEAD hash

### Error Handling

- If the git range is invalid, report the error and suggest a valid range
- If the docs directory doesn't exist, create it
- Never modify source code — only documentation files
