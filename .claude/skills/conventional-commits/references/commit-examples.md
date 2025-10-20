# Conventional Commit Examples

A comprehensive collection of commit message examples following the Conventional Commits specification.

## Features (feat)

### Simple Feature Addition

```
feat: add user profile page
```

### Feature with Scope

```
feat(auth): add two-factor authentication
```

### Feature with Body

```
feat(dhf): add automatic traceability suggestions

Implement AI-based similarity detection between artifacts
to automatically suggest traceability links. Uses vector
embeddings with configurable similarity threshold.
```

### Feature with Issue Reference

```
feat(api): add webhook signature verification

Add HMAC-SHA256 signature verification for all incoming
webhooks from external services.

Closes TRA-456
```

### Breaking Change Feature

```
feat(api)!: redesign authentication flow

BREAKING CHANGE: The authentication endpoint now requires
OAuth 2.0 instead of API keys. All clients must migrate
to the new OAuth flow.

Migration guide: docs/oauth-migration.md
```

## Bug Fixes (fix)

### Simple Bug Fix

```
fix: resolve login redirect loop
```

### Bug Fix with Scope

```
fix(api): handle null response from webhook
```

### Bug Fix with Detailed Explanation

```
fix(auth): resolve concurrent login race condition

Add pessimistic locking to prevent race condition when
multiple login attempts occur simultaneously for the
same user account.

The race condition could cause session data corruption
when two requests tried to update the user's last_login_at
timestamp at the same time.

Fixes #789
```

### Critical Bug Fix

```
fix(security): prevent SQL injection in search

Sanitize user input before constructing SQL queries in
the search functionality. Replaces string interpolation
with parameterized queries.

SECURITY: This fixes a critical SQL injection vulnerability.

Fixes #CVE-2024-12345
```

## Documentation (docs)

### Simple Documentation Update

```
docs: update README with setup instructions
```

### Documentation with Scope

```
docs(api): add webhook endpoint documentation
```

### Comprehensive Documentation

```
docs(contributing): add code review guidelines

Add detailed guidelines for code reviewers covering:
- Security review checklist
- Performance considerations
- Test coverage requirements
- Commit message standards

Related to #234
```

## Refactoring (refactor)

### Simple Refactoring

```
refactor: extract validation logic to service
```

### Refactoring with Scope

```
refactor(models): simplify tenant scoping logic
```

### Large Refactoring

```
refactor(services): migrate to Result pattern

Convert all service objects to return explicit Result
objects instead of raising exceptions for control flow.

This improves error handling consistency and makes
service behavior more predictable.

Affects:
- Users::CreateService
- Projects::CreateService
- Artifacts::ProcessService

No behavior changes - pure refactoring.
```

## Performance (perf)

### Simple Performance Improvement

```
perf: add database index for user lookups
```

### Performance with Details

```
perf(queries): eliminate N+1 queries in artifacts index

Add eager loading for associated records when fetching
artifacts. Reduces database queries from ~500 to 3 for
a typical page load.

Before: 2.3s page load time
After: 0.3s page load time
```

### Database Optimization

```
perf(db): add composite index for tenant queries

Add composite index on (tenant_id, created_at) for the
artifacts table. Improves query performance for tenant
artifact lists by 10x.

CREATE INDEX idx_artifacts_tenant_created
ON artifacts(tenant_id, created_at DESC);
```

## Tests (test)

### Simple Test Addition

```
test: add specs for user authentication
```

### Test with Scope

```
test(integration): add webhook processing tests
```

### Comprehensive Test Suite

```
test(services): add complete coverage for CreateOrderService

Add unit tests covering:
- Successful order creation
- Validation failures
- Payment processing errors
- Inventory reservation edge cases
- Concurrent order handling

Increases coverage from 67% to 95%.
```

## Chores (chore)

### Dependency Update

```
chore(deps): bump rails from 7.1.0 to 7.2.0
```

### Build Configuration

```
chore: update Docker configuration for production
```

### Maintenance Work

```
chore(ci): add security scanning to GitHub Actions

Add Brakeman security scanning and bundler-audit to
the CI pipeline. Scans run on every PR and main branch push.
```

## Style (style)

### Code Formatting

```
style: format code with StandardRB
```

### CSS Updates

```
style(ui): update button spacing and colors

Align button styles with design system:
- Increase padding from 8px to 12px
- Update primary color to brand blue
- Add hover state transitions
```

## Build (build)

### Build System Changes

```
build: configure webpack for code splitting
```

### Docker Configuration

```
build(docker): optimize production image size

Reduce Docker image size from 1.2GB to 400MB by:
- Using multi-stage build
- Removing development dependencies
- Optimizing layer caching
```

## CI (ci)

### CI Configuration

```
ci: add parallel test execution
```

### GitHub Actions Update

```
ci(actions): add automatic dependency updates

Configure Dependabot to automatically open PRs for:
- Security updates (daily)
- Ruby gem updates (weekly)
- npm package updates (weekly)
```

## Revert (revert)

### Simple Revert

```
revert: revert "feat: add export feature"

This reverts commit a1b2c3d4.
```

### Revert with Explanation

```
revert: revert "perf: add caching layer"

This reverts commit a1b2c3d4.

The caching implementation caused data inconsistency issues
in multi-tenant environments. Reverting until we can implement
tenant-aware cache invalidation.

Related to #567
```

## Multiple Footers

### Issue References and Co-authors

```
feat(dhf): add artifact classification

Implement AI-based classification of GitHub artifacts
into DHF categories using OpenAI embeddings.

Closes TRA-123
Related to TRA-100, TRA-101
Co-authored-by: Jane Doe <jane@example.com>
```

### Breaking Change with Migration

```
feat(api)!: change webhook payload structure

BREAKING CHANGE: Webhook payloads now nest data under "payload" key.

Before:
{
  "event": "issue.created",
  "issue_id": 123,
  "title": "Bug report"
}

After:
{
  "event": "issue.created",
  "payload": {
    "issue_id": 123,
    "title": "Bug report"
  }
}

Migration steps:
1. Update webhook handlers to access payload.issue_id
2. Deploy new code
3. Update webhook configuration in integrations

See: docs/webhook-migration.md

Closes TRA-234
```

## Real-World Tracewell Examples

### Multi-Tenant Feature

```
feat(tenants): add custom subdomain support

Allow tenants to configure custom subdomains instead of
using auto-generated slugs. Includes:
- Subdomain validation (DNS-safe characters)
- Uniqueness checking
- Automatic DNS verification
- Admin approval workflow

Closes TRA-789
```

### GitHub Integration

```
feat(github): add pull request synchronization

Sync GitHub pull requests as artifacts for DHF traceability.
Includes PR metadata, reviews, and linked issues.

The sync runs via webhook for real-time updates and has a
daily batch job for catching any missed events.

Closes TRA-456
Related to TRA-400 (artifact sync architecture)
```

### DHF Feature

```
feat(dhf): add design input extraction

Extract design inputs from GitHub issues using GPT-4.
Classifies inputs by category (functional, safety,
regulatory) and confidence level.

Extraction results are reviewed by users before being
added to the official DHF.

Closes TRA-234
```

### Security Fix

```
fix(auth): prevent session fixation attacks

Reset session ID on successful login to prevent session
fixation attacks. Also adds secure and httponly flags
to session cookies.

SECURITY: This addresses a medium-severity vulnerability
where attackers could hijack user sessions.

Fixes GHSA-2024-001
```

### Database Migration

```
feat(db): add artifact embeddings for similarity search

Add new artifact_embeddings table to store vector embeddings
for semantic similarity search. Uses pgvector extension.

Migration includes:
- Creating embeddings table with vector columns
- Adding indexes for efficient vector search
- Backfilling embeddings for existing artifacts

Run with: bin/rails db:migrate
Backfill with: bin/rails embeddings:backfill

Closes TRA-567
```

### Background Job

```
feat(jobs): add retry logic for webhook processing

Add exponential backoff retry for failed webhook processing.
Retries up to 5 times with delays: 1s, 2s, 4s, 8s, 16s.

After 5 failures, job is moved to dead queue and alerts
are sent to ops team.

Closes TRA-345
```

### UI Component

```
feat(ui): add confidence badge component

Add ViewComponent for displaying AI confidence scores
with color-coded badges:
- High (>0.8): Green
- Medium (0.5-0.8): Yellow
- Low (<0.5): Red

Component is reusable across artifact classifications,
traceability suggestions, and DHF extractions.

Closes TRA-678
```

### Test Coverage

```
test(system): add end-to-end traceability workflow

Add comprehensive system test covering:
1. User creates project
2. Imports GitHub artifacts
3. AI suggests traceability links
4. User reviews and approves suggestions
5. Generates DHF report

Ensures the complete traceability workflow functions
correctly from end to end.

Closes TRA-890
```

### Performance Optimization

```
perf(api): optimize webhook processing

Reduce webhook processing time from ~500ms to ~50ms by:
- Moving AI analysis to background jobs
- Batching database updates
- Caching tenant configuration
- Using database transactions efficiently

This prevents webhook timeout issues with external services.

Closes TRA-456
```

## Anti-Patterns (Avoid These)

### ❌ Vague Description

```
fix: update stuff
chore: changes
feat: improvements
```

### ❌ Past Tense

```
feat: added user profile
fix: fixed login bug
```

### ❌ Capitalized First Letter

```
Feat: Add user profile
Fix: Resolve login issue
```

### ❌ Ending Period

```
feat: add user profile.
fix: resolve login issue.
```

### ❌ Too Long First Line

```
feat: add a really comprehensive user profile page with avatar upload, bio editing, social links, and activity feed
```

### ❌ Multiple Unrelated Changes

```
feat: add user profile, fix login bug, update README, refactor database queries
```

### ❌ Missing Type

```
add user profile
resolve login issue
```

### ✅ Corrected Versions

```
feat: add user profile
fix: resolve login bug
docs: update README with setup instructions
refactor: optimize database queries
```

## Commit Message Templates

### Git Commit Template

Save to `.gitmessage`:

```
# <type>(<scope>): <description>
#
# [optional body]
#
# [optional footer(s)]
#
# Types: feat, fix, docs, style, refactor, perf, test, chore, build, ci, revert
# Scopes: auth, api, dhf, traceability, github, linear, jira, ui, models, services, jobs, tests, deps
#
# Rules:
# - Use imperative mood in description
# - Don't capitalize first letter
# - No period at the end
# - Keep first line under 50 chars
# - Separate body with blank line
# - Reference issues in footer (Closes #123)
```

Configure Git to use it:
```bash
git config commit.template .gitmessage
```

## Quick Reference

**Basic Format:**
```
<type>(<scope>): <description>
```

**Common Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Formatting
- `refactor:` Refactoring
- `perf:` Performance
- `test:` Tests
- `chore:` Maintenance

**Breaking Changes:**
```
feat!: change API
# or
BREAKING CHANGE: footer
```

**Issue References:**
```
Closes #123
Fixes #456
Related to #789
```
