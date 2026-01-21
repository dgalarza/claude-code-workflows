# Parallel Code Review

Run multiple specialized review agents simultaneously for comprehensive, efficient code analysis.

## Install

```bash
npx skills add dgalarza/claude-code-workflows --skill "parallel-code-review"

# Or via Claude marketplace
/plugin install parallel-code-review@dgalarza-workflows
```

## What It Does

Launches multiple specialized code review agents in parallel, then consolidates their findings into a single prioritized report.

## Why Parallel?

- **Speed**: 2+ specialized reviews complete in the time of 1
- **Depth**: Each agent focuses on their specialty
- **Coverage**: Security + Architecture + Performance simultaneously

## Review Configurations

### Two-Agent Review (Common)

```
Agent 1: Security Focus
Agent 2: Architecture/Quality Focus
```

Best for most code reviews.

### Three-Agent Review (Comprehensive)

```
Agent 1: Security
Agent 2: Architecture
Agent 3: Performance
```

Best for large features or production-critical code.

## Review Focus Areas

### Security Review
- Authentication and authorization vulnerabilities
- Input validation and injection attacks (SQL, XSS)
- Sensitive data exposure
- Cryptographic weaknesses
- Rate limiting and DoS prevention
- OWASP Top 10 compliance

### Architecture/Quality Review
- Design patterns (SOLID, DRY, KISS)
- Framework conventions
- Code organization and coupling
- Error handling patterns
- Test quality

### Performance Review (Optional)
- N+1 queries and missing indexes
- Memory usage patterns
- Algorithmic complexity
- Caching opportunities

## Consolidated Output

Findings are merged, deduplicated, and organized by severity:

```markdown
# Code Review - PR #123

## Executive Summary
Reviewed 15 files with 342 lines changed.
Found 2 critical issues, 5 high priority items.

## Critical Issues (Immediate Action Required)
### 1. SQL Injection Vulnerability
- **File**: app/services/search_service.rb:23
- **Reviewers**: Security, Architecture
- **Action**: Use parameterized queries

## High Priority
[...]

## Positive Observations
- Good test coverage
- Clear naming conventions
```

## Decision Tracking

The skill maintains a decision log to prevent redundant suggestions across reviews:

- Stores decisions in memory system
- Maintains `code_review_decisions.md` for audit trail
- Future reviews skip previously decided items

## When It Activates

During code review workflows, especially when comprehensive coverage from multiple perspectives is needed.

## Works Well With

- [Cybersecurity Reviewer](../cybersecurity-reviewer/README.md) - Specialized security agent
- [Rails Toolkit](../rails-toolkit/README.md) - Includes Rails-specific parallel reviews
