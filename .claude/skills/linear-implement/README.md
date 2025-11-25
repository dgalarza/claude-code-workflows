# Linear Issue Implementation Skill

A Claude Code skill for implementing Linear issues with a complete TDD workflow, automated planning, parallel code reviews, and PR creation with Linear integration.

## Quick Start

This skill automates the entire development lifecycle from Linear issue to merged PR. Simply ask Claude to implement a Linear issue:

```
Implement TRA-142
```

Claude will fetch the issue, gather context from Obsidian/Sentry/GitHub, create a branch, plan the implementation, write tests first, implement the feature, run parallel code reviews, address feedback, and create a comprehensive PR.

## What It Does

The skill orchestrates a 14-step professional software engineering workflow:

1. **Fetch Linear Issue** - Retrieves complete issue details via Linear MCP
2. **Gather Additional Context** - Searches Obsidian, Sentry, and GitHub for related information
3. **Move to In Progress** - Updates issue status for team visibility
4. **Create Feature Branch** - Uses Linear's suggested git branch naming
5. **Analyze & Plan** - Creates detailed implementation plan informed by gathered context
6. **Save to Memory** - Stores plan in memory graph for tracking
7. **Review Plan** - Presents plan for your confirmation before coding
8. **TDD Implementation** - Test-first development with Red-Green-Refactor
9. **Parallel Code Reviews** - Security and Rails best practices reviews run concurrently
10. **Address Feedback** - Systematically implements review suggestions
11. **Validation** - Ensures all tests and linters pass
12. **Logical Commits** - Creates meaningful commit history
13. **Create PR** - Opens pull request with proper Linear linking
14. **Final Verification** - Confirms CI/CD and Linear integration

## Benefits

- **Consistent Quality** - Every feature follows the same rigorous process
- **Security by Default** - Parallel security review catches vulnerabilities early
- **Best Practices Enforced** - Rails/OOP patterns review ensures clean architecture
- **Full Traceability** - Linear integration provides complete audit trail
- **Time Savings** - Automated workflow handles boilerplate tasks

## Usage

The skill activates when you ask Claude to implement a Linear issue:

```
Implement TRA-142
Help me build the feature in DEV-89
Work on Linear issue ABC-456
```

Claude will:
- Pause at the planning phase for your approval
- Show progress through each workflow step
- Present code review findings before addressing them
- Provide a completion checklist when done

## Workflow Highlights

### Context Gathering

Before planning, the skill automatically gathers relevant context:

**Obsidian Vault Search:**
- Searches by issue ID (e.g., "TRA-142")
- Searches by keywords from the issue title/description
- Finds related meeting notes, architecture decisions, and previous work

**Sentry Integration (if referenced):**
- Fetches error stack traces and frequency
- Identifies affected users and environments
- Provides debugging context for bug fixes

**GitHub References (if referenced):**
- Retrieves PR discussions and review feedback
- Fetches issue comments and design decisions
- Gathers context from related code changes

### Test-Driven Development

The skill enforces strict TDD methodology:
- Write failing tests first (Red)
- Implement minimal code to pass (Green)
- Refactor while keeping tests green (Refactor)
- Include system specs for end-to-end coverage

### Parallel Code Reviews

Two specialized review agents run concurrently:

**Security Review:**
- OWASP Top 10 vulnerabilities
- Multi-tenant data isolation
- Authentication/authorization patterns
- Input validation and sanitization

**Rails Best Practices Review:**
- POODR principles (SRP, dependency management)
- Service object patterns
- N+1 query prevention
- Result pattern usage

### Linear Integration

- Creates branches using Linear's suggested naming
- Updates issue status to "In Progress" automatically
- Links PRs to issues with `Closes <Linear-URL>`
- Issues auto-update when PRs merge

## Requirements

This skill requires the following MCP servers and tools to be installed and configured:

| Requirement | Purpose | Documentation |
|-------------|---------|---------------|
| **Linear MCP** | Fetch issues, update status, get branch names | [linear.app/docs/mcp](https://linear.app/docs/mcp) |
| **Sentry MCP** | Gather error context when issues reference Sentry | [docs.sentry.io/product/sentry-mcp](https://docs.sentry.io/product/sentry-mcp/) |
| **GitHub CLI** | Create PRs and fetch referenced PR/issue discussions | [cli.github.com](https://cli.github.com/) |

Additionally:
- **Obsidian Vault** - For searching related notes and documentation
- **Git Repository** - Current directory must be a git repo
- **Testing Tools** - `bundle exec rspec` available
- **Linting** - `bin/lint` script available

## Documentation

- **[SKILL.md](./SKILL.md)** - Complete workflow guide with detailed steps, error handling, and project-specific conventions

## Example Output

After asking Claude to "Implement TRA-142":

```
✅ Linear issue fetched
✅ Context gathered (Obsidian notes, Sentry errors, GitHub discussions)
✅ Implementation planned and approved
✅ Solution implemented with TDD
✅ Comprehensive system specs added
✅ Security review completed
✅ Rails/OOP patterns review completed
✅ All review feedback addressed
✅ All tests and linting pass
✅ Logical commit history created
✅ PR created with Linear integration

PR: https://github.com/org/repo/pull/123
```

## Best Practices

- Review the plan carefully before approving
- Check code review findings for critical issues
- Verify the PR description is accurate before merging
- Use for features that benefit from structured development

---

**Note:** This skill is optimized for Ruby on Rails projects following POODR principles. It integrates with the project's existing testing and linting infrastructure.
