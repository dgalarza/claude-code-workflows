# Recommended MCP Servers

MCP (Model Context Protocol) servers extend Claude Code's capabilities by connecting to external tools and services. Here are the servers I use and recommend.

## Essential Servers

### Linear

Project management integration. Fetch issues, update status, create branches based on issue details.

**Why I use it:** The `rails-toolkit` workflows depend on this. Being able to fetch issue context directly makes implementation smoother.

**Docs:** [Linear MCP Documentation](https://linear.app/docs/mcp)

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.linear.app/mcp"]
    }
  }
}
```

---

### Knowledge Graph Memory Server

Persistent memory across sessions. Claude can remember decisions, patterns, and context.

**Why I use it:** During code reviews, Claude remembers what it already suggested. Prevents redundant feedback across sessions.

**Docs:** [Memory Server on GitHub](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

---

### Sentry

Error monitoring integration. Pull error details, stack traces, and affected users directly into Claude.

**Why I use it:** Debugging production issues without context-switching. Claude can analyze errors and suggest fixes in one flow.

**Docs:** [Sentry MCP Documentation](https://docs.sentry.io/product/sentry-mcp/)

> **See it in action:** [Using the Sentry MCP to Debug Production Issues](https://youtu.be/GfDczm2xJ1M) - I walk through resolving a real bug using this workflow.

```json
{
  "mcpServers": {
    "Sentry": {
      "url": "https://mcp.sentry.dev/mcp"
    }
  }
}
```

On first use, you'll be prompted to authenticate with your Sentry account.

---

## Configuration

### Using the CLI

The easiest way to add MCP servers is via the command line:

```bash
# Add to your local machine only (default, not committed to git)
claude mcp add

# Add globally (available in all projects)
claude mcp add --scope user

# Add to current project (committed to git, shared with team)
claude mcp add --scope project
```

| Scope | Location | Shared? |
|-------|----------|---------|
| `local` (default) | `~/.claude.json` | No - private, current project only |
| `user` | `~/.claude.json` | No - private, all your projects |
| `project` | `.mcp.json` | Yes - committed to repo |

### Manual Configuration

You can also edit settings files directly:

- **User/Local:** `~/.claude.json`
- **Project:** `.mcp.json` in your project root

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.linear.app/mcp"]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "Sentry": {
      "url": "https://mcp.sentry.dev/mcp"
    }
  }
}
```

## Tips

1. **Start with Linear + Memory** - These two provide the most value for typical development workflows.

2. **Add servers as needed** - Don't install everything. Add servers when you have a specific use case.

3. **Check token usage** - MCP servers add context. If you're hitting token limits, consider which servers are active.

4. **Project-specific servers** - Use `.claude/settings.json` in your project root for project-specific MCP configurations.
