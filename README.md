# Claude Code Workflows

A collection of skills, agents, and workflows for Claude Code.

> **[YouTube](https://youtube.com/@damian.galarza)** | **[Newsletter](https://www.damiangalarza.com/newsletter?utm_source=github&utm_medium=readme&utm_campaign=claude-code-workflows)** | **[Blog](https://www.damiangalarza.com?utm_source=github&utm_medium=readme&utm_campaign=claude-code-workflows)**

---

## Quick Install

**Via npx (skills only):**
```bash
npx skills add dgalarza/claude-code-workflows --skill "tdd-workflow"
```

**Via Claude marketplace (skills, agents, bundles):**
```bash
/plugin marketplace add dgalarza/claude-code-workflows
/plugin install tdd-workflow@dgalarza-workflows
```

See [INSTALL.md](INSTALL.md) for full details.

---

## Skills

| Skill | Description |
|-------|-------------|
| [TDD Workflow](plugins/tdd-workflow/README.md) | Test-driven development, one test at a time |
| [Conventional Commits](plugins/conventional-commits/README.md) | Structured commit messages |
| [Parallel Code Review](plugins/parallel-code-review/README.md) | Multi-agent code reviews |
| [Meeting Transcript](plugins/meeting-transcript/README.md) | Process transcripts into structured notes |
| [Gridfinity Planner](plugins/gridfinity-planner/README.md) | 3D printing baseplate planning |

## Agents

| Agent | Description |
|-------|-------------|
| [Cybersecurity Reviewer](plugins/cybersecurity-reviewer/README.md) | Security analysis and threat modeling |

## Hooks

| Plugin | Description |
|--------|-------------|
| [Worktree Sync](plugins/worktree-sync/README.md) | Automated `.worktreeinclude` syncing for `claude --worktree` |

## Bundles

| Bundle | Description |
|--------|-------------|
| [Rails Toolkit](plugins/rails-toolkit/README.md) | Complete Rails workflow with TDD, reviews, Linear integration |

---

## Tips & Tricks

### Tip 1: Use Worktrees for Parallel Agents

Git worktrees let you run multiple Claude Code agents on the same codebase without conflicts.

**The problem:** If you run 2+ agents on the same repo, you get:
- Unrelated changes in one branch
- Agents overwriting each other's files
- Test suites colliding on the same database

**The solution:** Each agent gets its own worktree via `claude --worktree`.

**But wait** - your app won't run because `.env` and other secrets don't copy over. And if both agents run tests, they'll fight over the same database.

**Automate it with [worktree-sync](plugins/worktree-sync/README.md)** - uses Claude Code's `WorktreeCreate` hook to automatically symlink gitignored files into new worktrees:

1. Add a `.worktreeinclude` to your project root:
```
.env
.env.local
config/master.key
```

2. Configure the hooks in `.claude/settings.json` (see [setup instructions](plugins/worktree-sync/README.md#setup))

3. Run `claude --worktree` and your secrets are there automatically.

Only files matching both `.worktreeinclude` AND `.gitignore` are synced. You can also configure a post-create script via `.worktreesync` for project-specific setup like database isolation.

**For Rails apps**, there's also a standalone setup script for manual worktree creation:

```bash
./scripts/setup-rails-worktree.sh feature-branch
```

Get the script: [scripts/setup-rails-worktree.sh](scripts/setup-rails-worktree.sh) | [example.worktreeinclude](scripts/example.worktreeinclude) | [Git Worktrees Cheat Sheet](https://www.damiangalarza.com/downloads/git-worktree-cheatsheet?utm_source=github&utm_medium=readme&utm_campaign=claude-code-workflows)

The `rails-toolkit` plugin also includes `/rails-toolkit:linear-worktree` which automates this with Linear issue context.

---

### Tip 2: Customize Your Status Bar

```bash
claude config set --global statusLineTemplate '${cwd.basename} | ${model} | ${tokenUsage}'
```

See [configs/status-bar.md](configs/status-bar.md) for more options.

---

### Tip 3: Compact Context Proactively

Don't wait until Claude starts forgetting things. Compact when you finish a logical unit of work, switch tasks, or token usage gets high.

```bash
/compact
```

---

### Tip 4: Structure Your CLAUDE.md Files

```markdown
# Project Name

## Overview
One paragraph on what this project does.

## Tech Stack
- Framework: Rails 7.2
- Database: PostgreSQL

## Key Patterns
- Service objects in app/services/
- Result pattern for service returns

## Testing
- RSpec with FactoryBot
- Run tests: `bin/rspec`
```

---

### Tip 5: Use Subagents for Focused Tasks

When Claude spawns subagents, each one gets focused context. Security review? Let it spawn a security-focused subagent. Code review? Multiple specialized reviewers in parallel.

---

### Tip 6: MCP Servers Worth Installing

1. **Linear** - Project management integration
2. **Memory** - Persistent context across sessions
3. **Sentry** - Debug production errors

See [configs/mcp-servers.md](configs/mcp-servers.md) for setup instructions.

---

## Configurations

- [Status Bar Setup](configs/status-bar.md)
- [MCP Server Recommendations](configs/mcp-servers.md)

---

## Contributing

Found a bug? Have a workflow to share? PRs welcome.

## License

MIT

---

**Built by [Damian Galarza](https://www.damiangalarza.com?utm_source=github&utm_medium=readme&utm_campaign=claude-code-workflows)** - Former CTO, 15+ years in software. I make videos about Claude Code and AI development workflows.
