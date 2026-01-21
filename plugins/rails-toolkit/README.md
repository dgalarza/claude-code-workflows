# Rails Toolkit

Complete Rails development workflow with TDD, parallel code reviews, Linear integration, and specialized agents.

## Install

*Bundles require the Claude marketplace to install.*

```bash
/plugin marketplace add dgalarza/claude-code-workflows
/plugin install rails-toolkit@dgalarza-workflows
```

## What's Included

### Agents

| Agent | Purpose |
|-------|---------|
| **Rails Code Reviewer** | Conventions, POODR principles, idiomatic Ruby |
| **Rails Security Reviewer** | Multi-tenant security, ActsAsTenant patterns |
| **Rails Feature Developer** | TDD-driven implementation |
| **Rails Backend Expert** | Architecture guidance and best practices |

### Commands

#### `/rails-toolkit:full-code-review [branch]`

Run parallel security + Rails best practices review:

```bash
/rails-toolkit:full-code-review
/rails-toolkit:full-code-review feature-branch
```

Launches two specialized subagents simultaneously:
- **Security Review**: OWASP Top 10, multi-tenant isolation, auth/authz
- **Rails Review**: Conventions, POODR, Result pattern, test quality

Outputs consolidated report with prioritized findings.

#### `/rails-toolkit:linear-worktree <project> <issue-id>`

Set up a git worktree for a Linear issue:

```bash
/rails-toolkit:linear-worktree myapp TRA-142
```

This will:
1. Fetch Linear issue details
2. Create worktree at `../myapp-<branch-name>`
3. Copy `.env` and `config/master.key`
4. Run `bin/setup`
5. Ready for `/linear-implement`

### Skills

#### Linear Implementation Workflow

Complete workflow from Linear issue to PR:

1. Fetch issue and gather context (Obsidian, Sentry, GitHub)
2. Create feature branch with Linear's suggested name
3. Plan implementation and save to memory
4. TDD implementation (invokes `tdd-workflow`)
5. Parallel code reviews (security + Rails)
6. Address all feedback
7. Create PR with Linear linking

#### RSpec Testing Patterns

Guidance for writing effective RSpec tests:
- Test pyramid strategy
- Thoughtbot patterns
- Better Specs guidelines
- Avoid stubbing system under test

## Requirements

- **[Linear MCP](https://linear.app/changelog/2025-05-01-mcp)** - For Linear integration
- **[Memory MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)** - For persistent context

## Patterns Enforced

### Code Style
- Service objects for business logic
- Result pattern for operations that can fail
- POODR principles (SRP, Tell Don't Ask, Law of Demeter)

### Multi-Tenant Security
- ActsAsTenant automatic scoping
- Tenant isolation verification
- Control plane security for cross-tenant operations

### Testing
- RSpec with shoulda-matchers
- System specs for user workflows
- No stubbing the system under test

### Conventions
- i18n for user-facing text
- Timestamp columns over booleans
- Postgres enums for static values
- `ENV.fetch` for required environment variables

## Works Well With

- [TDD Workflow](../tdd-workflow/README.md) - Invoked during implementation
- [Parallel Code Review](../parallel-code-review/README.md) - Invoked for reviews
- [Cybersecurity Reviewer](../cybersecurity-reviewer/README.md) - Security analysis
- [Conventional Commits](../conventional-commits/README.md) - Commit formatting
