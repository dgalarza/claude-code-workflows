# Claude Code Workflows

A collection of skills, agents, and workflows for Claude Code.

> **[YouTube](https://youtube.com/@damian.galarza)** | **[Newsletter](https://www.damiangalarza.com/newsletter?utm_source=github&utm_medium=readme&utm_campaign=claude-code-workflows)** | **[Blog](https://www.damiangalarza.com)**

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
| [YouTube Strategy](plugins/youtube-strategy/README.md) | Content strategy for YouTube videos |

## Agents

| Agent | Description |
|-------|-------------|
| [Cybersecurity Reviewer](plugins/cybersecurity-reviewer/README.md) | Security analysis and threat modeling |
| [Gridfinity Planner](plugins/gridfinity-planner/README.md) | 3D printing baseplate planning |

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

**The solution:** Each agent gets its own worktree.

```bash
git worktree add ../myproject-feature-x -b feature-x
cd ../myproject-feature-x
# When done
git worktree remove ../myproject-feature-x
```

**But wait** - your app won't run because `.env` and other secrets don't copy over. And if both agents run tests, they'll fight over the same database.

**For Rails apps**, use the setup script that handles everything:

```bash
# From your project root
./scripts/setup-rails-worktree.sh feature-branch

# This will:
# 1. Create worktree at ../yourproject-feature-branch
# 2. Symlink files from .worktreeinclude (or defaults)
# 3. Create .env.local with isolated DB_DATABASE and DB_TEST_DATABASE
# 4. Run bin/setup
```

**Configure with `.worktreeinclude`** - create this file in your repo root to specify which gitignored files to include:

```
.env
.env.local
.npmrc
config/master.key
```

Uses the same pattern as [Claude Code Desktop](https://code.claude.com/docs/en/desktop) - only files matching both `.worktreeinclude` AND `.gitignore` are included.

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

**Built by [Damian Galarza](https://www.damiangalarza.com)** - Former CTO, 15+ years in software. I make videos about Claude Code and AI development workflows.
