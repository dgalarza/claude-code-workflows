# Plugins Worth Installing

Plugins extend Claude Code with specialized behaviors, audit tools, and domain expertise that go beyond what a CLAUDE.md file can provide.

## Recommended Plugins

1. **[Claudit](https://github.com/acostanzo/quickstop/tree/main/plugins/claudit)** - Configuration auditor that evaluates your Claude Code setup against Anthropic's best practices. Scores six categories (over-engineering, CLAUDE.md quality, security, MCP config, plugin health, context efficiency) with letter grades and actionable recommendations. Uses subagents to fetch current docs before auditing, so results stay up to date.

## Setup

Install plugins via the Claude Code CLI:

```bash
/plugin install <plugin-name>
```

Or add them from a marketplace repository:

```bash
/plugin marketplace add <owner>/<repo>
/plugin install <plugin-name>@<marketplace-name>
```
