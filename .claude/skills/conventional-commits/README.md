# Conventional Commits Skill

A Claude Code skill for writing Git commits that follow the [Conventional Commits specification](https://www.conventionalcommits.org/).

## Overview

This skill teaches Claude how to write clear, structured commit messages using the Conventional Commits format. It's framework-agnostic and works with any programming language or project type.

## Benefits

Clear, structured commit messages enable:
- **Better collaboration** - Team members instantly understand the nature of changes
- **Clear project history** - Easy to scan git log and understand what happened when
- **Improved code review** - Reviewers quickly grasp the intent of each commit
- **Consistent communication** - Standardized format across all contributors
- **Easy navigation** - Find specific changes quickly using commit types

## Basic Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Commit Types

| Type | Purpose | Example |
|------|---------|---------|
| `feat` | New feature | `feat: add user authentication` |
| `fix` | Bug fix | `fix: resolve login redirect loop` |
| `docs` | Documentation only | `docs: update README with setup instructions` |
| `refactor` | Code refactoring | `refactor: extract validation to service` |
| `perf` | Performance improvement | `perf: add database index for queries` |
| `test` | Add or update tests | `test: add user authentication specs` |
| `chore` | Maintenance tasks | `chore: update dependencies` |
| `style` | Formatting changes | `style: format code with prettier` |
| `build` | Build system changes | `build: configure webpack` |
| `ci` | CI configuration | `ci: add automated testing workflow` |

## Quick Examples

```bash
# Simple feature
feat: add password reset functionality

# Feature with scope
feat(api): add rate limiting for endpoints

# Bug fix with body
fix(auth): resolve session timeout bug

Increase session timeout from 15 to 30 minutes to prevent
premature logouts during active user sessions.

Fixes #123

# Breaking change
feat!: redesign authentication API

BREAKING CHANGE: The /auth endpoint now requires OAuth 2.0.
Update all clients to use the new authentication flow.
```

## Usage in Claude Code

This skill is automatically invoked when you ask Claude to create Git commits. Claude will:
- Analyze your code changes
- Select the appropriate commit type
- Write a clear, concise description following the imperative mood
- Add context in the body when changes need explanation
- Reference relevant issues in footers

Simply ask Claude to "commit these changes" or "create a commit for this work" and the skill handles the rest.

## Documentation

- **[SKILL.md](./SKILL.md)** - Complete guide with all commit types, scopes, formatting rules, and best practices
- **[references/commit-examples.md](./references/commit-examples.md)** - Comprehensive collection of real-world commit examples

## Key Rules

**Format:**
- Use imperative mood: "add" not "added" or "adds"
- Don't capitalize the first letter of the description
- No period at the end of the description
- Keep the first line under 50-72 characters
- Separate body and footer with blank lines

**Content:**
- Make atomic commits (one logical change per commit)
- Explain *why* in the body, not *what* (code shows what)
- Reference issues/tickets in the footer
- Mark breaking changes clearly with `!` or `BREAKING CHANGE:`

## Breaking Changes

For commits that introduce breaking changes:

**Option 1: Use `!` after type/scope**
```bash
feat!: change authentication endpoint
feat(api)!: remove deprecated login method
```

**Option 2: Add `BREAKING CHANGE:` footer**
```bash
feat(api): change authentication endpoint

BREAKING CHANGE: The /auth endpoint now requires a client_id parameter.
Update all API clients to include client_id in authentication requests.
```

## Common Mistakes to Avoid

❌ **Vague descriptions**
```bash
fix: update stuff
feat: changes
```

❌ **Past tense**
```bash
feat: added user profile
fix: fixed the bug
```

❌ **Wrong capitalization**
```bash
Feat: Add feature
fix: Fix bug
```

❌ **Ending period**
```bash
feat: add user profile.
```

❌ **Combining unrelated changes**
```bash
feat: add profile, fix login, update deps, refactor queries
```

## Customizing for Your Project

The skill uses generic scopes that work for any project. Common scopes include:
- `auth` - Authentication/authorization
- `api` - API endpoints
- `ui` - User interface
- `database` or `db` - Database changes
- `tests` - Test suite
- `docs` - Documentation
- `config` - Configuration

Adapt scopes to match your project's architecture and domain.

## References

- [Conventional Commits Specification](https://www.conventionalcommits.org/) - Official specification (v1.0.0)

---

**Note:** This skill focuses on the Conventional Commits format itself, not on tooling or automation. It helps you write better commit messages for clearer communication and collaboration.
