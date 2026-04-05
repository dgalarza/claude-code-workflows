---
name: prime
description: Guided interactive setup that creates .doc-sync.json configuration for the project
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep, Write, Edit
---

# Prime

Guided interactive setup that creates or updates `.doc-sync.json` — the configuration file that drives all doc-sync detection and output paths. Idempotent: safe to re-run on an existing config.

## `/doc-sync:prime`

### Phase 1: Detect Project Stack

Inspect the project root for stack indicators:

| Indicator | Stack |
|-----------|-------|
| `tsconfig.json` or `package.json` with TypeScript deps | TypeScript / Node |
| `Gemfile` with `rails` or `config/routes.rb` | Ruby / Rails |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pyproject.toml`, `setup.py`, or `requirements.txt` | Python |

If multiple indicators exist, prefer the first match in the order above. If none match, use "generic" defaults.

### Phase 2: Scan for Existing Documentation

Before configuring defaults, scan the project for existing documentation files that doc-sync doc types would overlap with:

| Doc Type | Scan Locations |
|----------|---------------|
| `architecture` | `ARCHITECTURE.md`, `docs/architecture.md`, `docs/reference/architecture.md`, `docs/ARCHITECTURE.md` |
| `changelog` | `CHANGELOG.md`, `CHANGES.md`, `changelog.md` |
| `index` | `docs/INDEX.md`, `docs/index.md`, `docs/README.md` |
| ADR directories | `docs/decisions/`, `docs/adr/`, `docs/adrs/` |
| Agent docs | `AGENTS.md`, `CLAUDE.md`, `docs/reference/agents.md` |
| General docs | `docs/` (note any existing structure) |

Also check for existing doc-audit or agent-ready artifacts:

```bash
# Existing agent-ready artifacts
for f in AGENTS.md CLAUDE.md ARCHITECTURE.md AGENT_READY_ASSESSMENT.md; do
  [ -f "$f" ] && echo "Found: $f"
done

# Docs directory structure
find docs/ -type f -name "*.md" 2>/dev/null | head -20 || echo "No docs/ directory"

# Agent/tool definitions (for agent-schemas detection)
find . -maxdepth 4 -type f \( -name "*agent*" -o -name "*tool*" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" \
  2>/dev/null | head -20
```

Store discovered paths for use in Phase 4.

### Phase 3: Load Existing Config

If `.doc-sync.json` already exists, read it. Present a summary of the current configuration and ask the user whether to update it or start fresh.

### Phase 4: Configure Doc Types

For each doc type below, present the stack-appropriate defaults and ask the user whether to enable it. Accept `y`/`n` (default `y` for all except `agent-schemas` which defaults to `n` unless agent files were detected in Phase 2).

**Use discovered files from Phase 2:** If an existing file was found that matches a doc type, suggest that path instead of the generic default. For example:

- Found `docs/reference/architecture.md` → suggest it for `architecture` output instead of `ARCHITECTURE.md`
- Found `CHANGES.md` → suggest it for `changelog` output instead of `CHANGELOG.md`
- Found agent/tool definitions → auto-enable `agent-schemas` and suggest paths

Present the suggestion clearly: *"I found an existing architecture doc at `ARCHITECTURE.md` — should I use that path? [Y/n]"*

For enabled types, show the output path (discovered or default) and path/pattern globs. Let the user accept or override.

#### Stack Defaults

**TypeScript / Node:**

| Doc Type | Output | Paths | Patterns |
|----------|--------|-------|----------|
| `changelog` | `CHANGELOG.md` | — | — |
| `api-reference` | `docs/reference/` | `src/**`, `lib/**`, `app/**` | — |
| `api-contract` | `docs/reference/api.md` | `src/routes/**`, `src/api/**`, `app/controllers/**`, `routes/**`, `api/**` | `app\.(get\|post\|put\|patch\|delete)\(`, `router\.(get\|post\|put\|patch\|delete\|use\|all\|route)\(` |
| `env-config` | `docs/reference/configuration.md` | `.env*`, `config/**`, `src/config/**` | `process\.env\.` |
| `agent-schemas` | `docs/reference/agents.md` | `src/**/agents/**`, `src/**/tools/**` | `createTool\(`, `Agent\(`, `defineAgent` |
| `architecture` | `ARCHITECTURE.md` | — | — |
| `index` | `docs/INDEX.md` | `docs/**/*.md` | — |

**Ruby / Rails:**

| Doc Type | Output | Paths | Patterns |
|----------|--------|-------|----------|
| `changelog` | `CHANGELOG.md` | — | — |
| `api-reference` | `docs/reference/` | `app/**`, `lib/**` | — |
| `api-contract` | `docs/reference/api.md` | `app/controllers/**`, `config/routes.rb` | `resources\s+:`, `get\s+['"]`, `post\s+['"]`, `namespace\s+:` |
| `env-config` | `docs/reference/configuration.md` | `.env*`, `config/**` | `ENV\[`, `ENV\.fetch` |
| `agent-schemas` | `docs/reference/agents.md` | `app/agents/**`, `app/tools/**` | — |
| `architecture` | `ARCHITECTURE.md` | — | — |
| `index` | `docs/INDEX.md` | `docs/**/*.md` | — |

**Go:**

| Doc Type | Output | Paths | Patterns |
|----------|--------|-------|----------|
| `changelog` | `CHANGELOG.md` | — | — |
| `api-reference` | `docs/reference/` | `cmd/**`, `pkg/**`, `internal/**` | — |
| `api-contract` | `docs/reference/api.md` | `cmd/**/handler*`, `internal/api/**` | `\.HandleFunc\(`, `r\.(Get\|Post\|Put\|Patch\|Delete)\(` |
| `env-config` | `docs/reference/configuration.md` | `.env*`, `config/**` | `os\.Getenv` |
| `agent-schemas` | `docs/reference/agents.md` | `internal/agents/**`, `pkg/agents/**` | — |
| `architecture` | `ARCHITECTURE.md` | — | — |
| `index` | `docs/INDEX.md` | `docs/**/*.md` | — |

**Rust:**

| Doc Type | Output | Paths | Patterns |
|----------|--------|-------|----------|
| `changelog` | `CHANGELOG.md` | — | — |
| `api-reference` | `docs/reference/` | `src/**` | — |
| `api-contract` | `docs/reference/api.md` | `src/routes/**`, `src/handlers/**` | `#\[get\(`, `#\[post\(`, `\.route\(` |
| `env-config` | `docs/reference/configuration.md` | `.env*`, `config/**` | `std::env::var` |
| `agent-schemas` | `docs/reference/agents.md` | `src/agents/**` | — |
| `architecture` | `ARCHITECTURE.md` | — | — |
| `index` | `docs/INDEX.md` | `docs/**/*.md` | — |

**Python:**

| Doc Type | Output | Paths | Patterns |
|----------|--------|-------|----------|
| `changelog` | `CHANGELOG.md` | — | — |
| `api-reference` | `docs/reference/` | `app/**`, `src/**`, `lib/**` | — |
| `api-contract` | `docs/reference/api.md` | `app/views/**`, `src/routes/**` | `@app\.(get\|post\|put\|patch\|delete)\(`, `@router\.(get\|post\|put\|patch\|delete)\(` |
| `env-config` | `docs/reference/configuration.md` | `.env*`, `config/**` | `os\.environ`, `os\.getenv` |
| `agent-schemas` | `docs/reference/agents.md` | `agents/**`, `tools/**` | — |
| `architecture` | `ARCHITECTURE.md` | — | — |
| `index` | `docs/INDEX.md` | `docs/**/*.md` | — |

**Generic (no stack detected):**

Use the TypeScript/Node defaults but omit framework-specific patterns from `api-contract` and `env-config`.

### Phase 5: Write .doc-sync.json

Write the config file to the project root. Use the schema defined in `references/config-schema.md`.

### Phase 6: Recommend .gitignore Additions

Check if `.gitignore` exists and whether it already contains doc-sync runtime entries. If missing, suggest:

```
.doc-queue.json
.doc-sync-last-capture
```

Ask the user whether to append them automatically.

### Phase 7: Integration Check

Check for existing documentation ecosystem plugins and recommend next steps:

- If `AGENT_READY_ASSESSMENT.md` exists → "Your codebase has been assessed. doc-sync will maintain the docs that agent-ready scaffolded."
- If `AGENTS.md`/`CLAUDE.md` exists → "Found existing agent docs. doc-sync will update these when related code changes."
- If neither exists → "Consider running the agent-ready plugin first to scaffold initial docs, then doc-sync will keep them current."

### Phase 8: Confirm

Output a summary:

```
doc-sync configured for <stack> project.

Enabled doc types:
  - changelog → CHANGELOG.md
  - api-reference → docs/reference/
  - api-contract → docs/reference/api.md
  - env-config → docs/reference/configuration.md
  - architecture → ARCHITECTURE.md
  - index → docs/INDEX.md

Config written to .doc-sync.json
Run /doc-sync:capture to generate docs from existing commits.
```
