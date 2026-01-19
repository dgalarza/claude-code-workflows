# Claude Code Workflows

A collection of skills, agents, and workflows for Claude Code.

> **[YouTube](https://youtube.com/@dgalarza86)** | **[Newsletter](https://www.damiangalarza.com/newsletter)** | **[Blog](https://www.damiangalarza.com)**

---

## Quick Install

```bash
# Add the marketplace
/plugin marketplace add dgalarza/claude-code-workflows

# Install what you need
/plugin install tdd-workflow@dgalarza-workflows
```

See [INSTALL.md](INSTALL.md) for full installation options.

---

## Table of Contents

### Plugins
- [TDD Workflow](#tdd-workflow) - Test-driven development, one test at a time
- [Conventional Commits](#conventional-commits) - Structured commit messages
- [Parallel Code Review](#parallel-code-review) - Multi-agent reviews
- [Meeting Transcript](#meeting-transcript) - Process transcripts into notes
- [Cybersecurity Reviewer](#cybersecurity-reviewer) - Security analysis agent
- [Gridfinity Planner](#gridfinity-planner) - 3D printing baseplate planning
- [Rails Toolkit](#rails-toolkit) - Complete Rails development workflow

### Tips & Tricks
- [Tip 1: Use worktrees for parallel work](#tip-1-use-worktrees-for-parallel-work)
- [Tip 2: Customize your status bar](#tip-2-customize-your-status-bar)
- [Tip 3: Compact context proactively](#tip-3-compact-context-proactively)
- [Tip 4: Structure your CLAUDE.md files](#tip-4-structure-your-claudemd-files)
- [Tip 5: Use subagents for focused tasks](#tip-5-use-subagents-for-focused-tasks)
- [Tip 6: MCP servers worth installing](#tip-6-mcp-servers-worth-installing)

### Configurations
- [Status Bar Setup](configs/status-bar.md)
- [MCP Server Recommendations](configs/mcp-servers.md)

---

## Plugins

### TDD Workflow

**Install:** `/plugin install tdd-workflow@dgalarza-workflows`

A skill that enforces true test-driven development:

1. Write ONE failing test
2. Write minimal code to pass
3. Refactor
4. Repeat

Claude follows the red-green-refactor cycle step by step instead of writing all tests upfront.

**When it activates:** Automatically when implementing features with TDD.

---

### Conventional Commits

**Install:** `/plugin install conventional-commits@dgalarza-workflows`

Structured commit messages following the [Conventional Commits](https://www.conventionalcommits.org/) specification.

```
feat(api): add webhook signature verification
fix: resolve login redirect loop
docs: update README with setup instructions
```

Includes reference material for commit types, scopes, and examples.

**When it activates:** When creating Git commits.

---

### Parallel Code Review

**Install:** `/plugin install parallel-code-review@dgalarza-workflows`

Run multiple specialized review agents in parallel for comprehensive feedback. Get security, architecture, and style feedback simultaneously.

**When it activates:** During code review workflows.

---

### Meeting Transcript

**Install:** `/plugin install meeting-transcript@dgalarza-workflows`

Process raw meeting transcripts (from Granola, Otter, or manual notes) into structured notes with:

- Summary
- Action items with owners
- Key decisions
- Follow-up questions

**When it activates:** When processing meeting transcripts.

---

### Cybersecurity Reviewer

**Install:** `/plugin install cybersecurity-reviewer@dgalarza-workflows`

Security analysis agent for:

- Vulnerability assessment (OWASP Top 10)
- Threat modeling
- Authentication/authorization review
- Data protection analysis

Provides actionable remediation with code examples.

**When to use:** Security reviews, penetration test prep, architecture review.

---

### Gridfinity Planner

**Install:** `/plugin install gridfinity-planner@dgalarza-workflows`

Plan and design gridfinity baseplates for 3D printing:

- Calculate optimal grid sizes from measurements (metric or imperial)
- Slice large grids into printable chunks based on printer bed size
- Calculate padding for non-exact fits
- Generate parameters for gridfinity.perplexinglabs.com

**When to use:** Designing gridfinity storage systems for drawers, toolboxes, or shelves.

---

### Rails Toolkit

**Install:** `/plugin install rails-toolkit@dgalarza-workflows`

Complete Rails development workflow bundle. Includes:

**Agents:**
- Rails Code Reviewer - Conventions, POODR, idiomatic Ruby
- Rails Security Reviewer - Multi-tenant security, ActsAsTenant
- Rails Feature Developer - TDD-driven implementation
- Rails Backend Expert - Architecture guidance

**Commands:**
- `/rails-toolkit:full-code-review` - Parallel security + Rails review
- `/rails-toolkit:linear-worktree` - Set up worktree from Linear issue

**Skills:**
- Linear implementation workflow
- RSpec testing patterns

**Requirements:**
- [Linear MCP](https://linear.app/changelog/2025-05-01-mcp) for Linear integration
- [Memory MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/memory) for persistent context

---

## Tips & Tricks

### Tip 1: Use Worktrees for Parallel Work

Git worktrees let you work on multiple features simultaneously without branch switching or stashing.

```bash
# Create a worktree for a new feature
git worktree add ../myproject-feature-x -b feature-x

# Work in isolation
cd ../myproject-feature-x

# When done, remove it
git worktree remove ../myproject-feature-x
```

**Why it matters:** Each worktree has its own file state. No more "let me stash this first" when switching contexts.

The `rails-toolkit` plugin includes `/rails-toolkit:linear-worktree` which automates this with Linear issue context.

---

### Tip 2: Customize Your Status Bar

Claude Code's status bar can show useful context while you work.

```bash
claude config set --global statusLineTemplate '${cwd.basename} | ${model} | ${tokenUsage}'
```

This shows:
- Current directory (which project you're in)
- Model being used
- Token usage (so you know when to compact)

See [configs/status-bar.md](configs/status-bar.md) for more options.

---

### Tip 3: Compact Context Proactively

Don't wait until Claude starts forgetting things. Compact when:

- You finish a logical unit of work
- You're about to start a different task
- Token usage is getting high
- Claude starts repeating itself or forgetting earlier context

```bash
/compact
```

Think of it like saving your game - do it at good checkpoints.

---

### Tip 4: Structure Your CLAUDE.md Files

A well-structured `CLAUDE.md` helps Claude understand your project faster.

```markdown
# Project Name

## Overview
One paragraph on what this project does.

## Tech Stack
- Framework: Rails 7.2
- Database: PostgreSQL
- Background jobs: Sidekiq

## Key Patterns
- Service objects in app/services/
- Result pattern for service returns
- ActsAsTenant for multi-tenancy

## Testing
- RSpec with FactoryBot
- Run tests: `bin/rspec`

## Common Commands
- Setup: `bin/setup`
- Console: `bin/rails c`
- Server: `bin/dev`
```

The goal: Give Claude the context it needs to make good decisions without overwhelming it.

---

### Tip 5: Use Subagents for Focused Tasks

When Claude spawns subagents, each one gets focused context. Use this to your advantage:

- Security review? Let it spawn a security-focused subagent
- Code review? Multiple specialized reviewers in parallel
- Complex implementation? Let it break down and delegate

Subagents complete their task and return results - they don't pollute your main conversation with intermediate steps.

---

### Tip 6: MCP Servers Worth Installing

Start with these:

1. **Linear** - If you use Linear for project management
2. **Memory** - Persistent context across sessions
3. **Sentry** - Debug production errors without context-switching

See [configs/mcp-servers.md](configs/mcp-servers.md) for setup instructions and configuration snippets.

---

## Contributing

Found a bug? Have a workflow to share? PRs welcome.

## License

MIT

---

**Built by [Damian Galarza](https://www.damiangalarza.com)** - Former CTO, 15+ years in software. I make videos about Claude Code and AI development workflows.
