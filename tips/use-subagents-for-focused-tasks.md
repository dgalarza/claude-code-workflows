# Use Subagents for Focused Tasks

When Claude spawns subagents, each one gets focused context. This keeps the main conversation clean and lets specialized work happen in parallel.

## When to Use Subagents

- **Security review** - Let Claude spawn a security-focused subagent to analyze your code for vulnerabilities.
- **Code review** - Multiple specialized reviewers can work in parallel, each focusing on a different aspect (architecture, testing, performance).
- **Research** - Subagents can explore the codebase or search for information without cluttering your main context.

## How It Works

Claude automatically uses subagents when appropriate. You can also prompt it directly:

```
Review this PR with separate subagents for security, testing, and architecture.
```

The [parallel-code-review](../plugins/parallel-code-review/README.md) skill is built around this pattern, spawning multiple reviewers that each focus on a specific concern.
