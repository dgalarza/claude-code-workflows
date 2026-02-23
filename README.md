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

| Tip | Description |
|-----|-------------|
| [Use Worktrees for Parallel Agents](tips/worktrees-for-parallel-agents.md) | Run multiple Claude Code agents on the same codebase without conflicts |
| [Customize Your Status Bar](tips/customize-status-bar.md) | Configure the status bar to show model, tokens, and more |
| [Compact Context Proactively](tips/compact-context-proactively.md) | Keep Claude effective by compacting at the right times |
| [Structure Your CLAUDE.md Files](tips/structure-claude-md-files.md) | Give Claude the project context it needs |
| [Use Subagents for Focused Tasks](tips/use-subagents-for-focused-tasks.md) | Spawn specialized subagents for reviews, research, and more |
| [MCP Servers Worth Installing](tips/mcp-servers-worth-installing.md) | Linear, Memory, and Sentry integrations |

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
