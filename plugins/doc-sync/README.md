# doc-sync

Continuous documentation synchronization engine for Claude Code. Detects code changes via hooks, queues documentation tasks, and processes them at session boundaries — keeping docs accurate as a side effect of development.

## How It Works

```
Developer commits code
    ↓
PostToolUse hook fires (detects git commit)
    ├─ Reads .doc-sync.json configuration
    ├─ Matches changed files against path/pattern rules
    ├─ Queues tasks to .doc-queue.json
    └─ Completes in <2s, never blocks
    ↓
Queue accumulates during session
    ↓
Stop hook fires (end of Claude's turn)
    ├─ Checks .doc-queue.json for pending tasks
    └─ Sends systemMessage to process queue
    ↓
doc-writer agent processes tasks
    ├─ Reads source files
    ├─ Writes/updates documentation
    ├─ Commits with 'docs:' prefix
    └─ Clears queue
```

## Where It Fits

doc-sync bridges two existing plugins in the documentation lifecycle:

1. **[agent-ready](../agent-ready/)** scaffolds initial documentation (AGENTS.md, ARCHITECTURE.md, docs/)
2. **doc-sync** keeps those docs current automatically as code changes
3. **[doc-audit](../doc-audit/)** periodically validates accuracy and finds deeper issues

```
agent-ready (scaffold) → doc-sync (maintain) → doc-audit (validate)
```

## Installation

### From Marketplace

Install directly from the marketplace registry.

```bash
claude plugin install doc-sync@claude-code-workflows
```

### From Local Source

If you have the repo cloned locally, install from disk.

```bash
claude plugin install --source /path/to/claude-code-workflows/plugins/doc-sync --scope project
```

### Manual Copy

Copy the plugin directory into your project's plugin folder.

```bash
cp -r /path/to/claude-code-workflows/plugins/doc-sync .claude/plugins/doc-sync
```

After installing, run `/doc-sync:prime` to configure for your project.

## Quick Start

```
/doc-sync:prime          # Interactive setup — creates .doc-sync.json
/doc-sync:capture 10     # Scan last 10 commits and generate docs
/doc-sync:stale          # Check which docs are out of date
/doc-sync:process        # Manually process queued tasks
```

After running `/doc-sync:prime`, the hooks handle everything automatically. Documentation updates happen at session boundaries without manual intervention.

## Documentation Types

| Type | Trigger | Output |
|------|---------|--------|
| `changelog` | Conventional commits (feat:, fix:, etc.) | CHANGELOG.md |
| `api-reference` | Source file changes matching configured paths | docs/reference/ (per-module) |
| `api-contract` | Route/handler file changes | docs/reference/api.md |
| `env-config` | .env or config file changes | docs/reference/configuration.md |
| `agent-schemas` | Agent/tool definition changes | docs/reference/agents.md |
| `architecture` | Major structural changes (5+ new directories) | ARCHITECTURE.md |
| `index` | Doc files added or removed | docs/INDEX.md |

## Configuration

`.doc-sync.json` in the project root controls all detection and output paths. Run `/doc-sync:prime` for guided setup, or create manually:

```json
{
  "version": 1,
  "stack": "typescript",
  "docs": {
    "changelog": { "enabled": true, "file": "CHANGELOG.md" },
    "api-reference": { "enabled": true, "directory": "docs/reference/", "paths": ["src/**"] },
    "agent-schemas": { "enabled": true, "file": "docs/reference/agents.md", "paths": ["src/**/agents/**", "src/**/tools/**"] },
    "architecture": { "enabled": true, "file": "ARCHITECTURE.md" },
    "index": { "enabled": true, "file": "docs/INDEX.md", "paths": ["docs/**/*.md"] }
  }
}
```

## Stack Support

`/doc-sync:prime` detects your project stack and provides appropriate defaults:

- **TypeScript / Node** — src/, lib/, app/ paths with process.env patterns
- **Ruby / Rails** — app/controllers, config/routes.rb, ENV[] patterns
- **Go** — cmd/, pkg/, internal/ with os.Getenv patterns
- **Rust** — src/ with attribute macro patterns
- **Python** — app/, src/ with os.environ patterns

## Agents

| Agent | Role | Dispatched By |
|-------|------|---------------|
| `doc-writer` | Reads source changes, writes documentation, commits | Stop hook, `/doc-sync:capture` |
| `index-builder` | Scans doc directories, rebuilds index | `doc-writer` agent |

## Safety

- Hook scripts exit cleanly on missing dependencies (jq, git) — never block
- Without `.doc-sync.json`, the hook falls back to changelog-only detection
- `docs:` commits are detected and skipped to prevent feedback loops
- The Stop hook only suggests processing — Claude decides whether to act
- Queue file (`.doc-queue.json`) is plain JSON, human-readable, and safe to delete at any time
- Skills are `disable-model-invocation: true` — they only run when explicitly invoked

## .gitignore

Add these runtime files to your `.gitignore`:

```
.doc-queue.json
.doc-sync-last-capture
```

## Requirements

- `jq` — required for full detection (falls back to changelog-only without it)
- `git` — required for change detection
- Claude Code — hooks require the Claude Code hook system

## Troubleshooting

**Queue not processing after commits**
The Stop hook only fires when Claude's turn ends. If you commit and immediately ask another question, processing is deferred to the next Stop event. Check `.doc-queue.json` — if tasks are queued, they will be processed when the current conversation turn completes.

**No documentation generated for source changes**
doc-sync needs `.doc-sync.json` to detect non-changelog doc types. Without config, only changelog entries (from `feat:`, `fix:`, etc. commits) are detected. Run `/doc-sync:prime` to enable full detection.

**"jq: command not found" or changelog-only detection**
The hook scripts require `jq` for JSON processing. Without it, the hook falls back to changelog-only detection. Install jq: `brew install jq` (macOS), `apt install jq` (Linux).

**Docs commits appearing in changelog**
doc-sync skips commits with a `docs:` prefix to prevent feedback loops. If you see doc changes being re-documented, check that the doc-writer agent's commit message starts with `docs:`.
