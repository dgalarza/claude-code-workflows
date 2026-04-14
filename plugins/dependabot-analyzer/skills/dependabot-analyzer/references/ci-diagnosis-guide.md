# CI Failure Diagnosis Guide

When a Dependabot PR has failing CI checks, classify the failure into one of three categories before deciding whether to attempt a fix.

## Failure Categories

### Category 1: Upgrade-Related (Fixable)

The failure is directly caused by the dependency update. Symptoms:

- Import path changed (e.g., `require('pkg/old-path')` → `require('pkg/new-path')`)
- Method or function renamed or removed
- Type signature changed (new required parameter, changed return type)
- Configuration format changed (e.g., config key renamed)
- Deprecated API removed in the new version

**Action**: Attempt a fix if the change is mechanical — fewer than 5 files affected, and the migration is documented in the package's changelog or upgrade guide.

### Category 2: Pre-Existing (Do Not Fix)

The same test fails on the main branch. The failure is unrelated to the dependency update.

**How to verify**: Check if the failing test also fails on `main` by reviewing recent CI runs on the default branch, or by looking at `gh pr checks` output for the base branch.

**Action**: Do not attempt a fix. Note in the assessment that CI failure is pre-existing and unrelated to this update.

### Category 3: Infrastructure (Do Not Fix)

The failure is caused by CI infrastructure, not code. Symptoms:

- Timeout errors
- Network connectivity failures (registry unreachable, DNS resolution)
- Runner provisioning failures
- Rate limiting from external services
- Disk space or memory exhaustion
- Docker pull failures

**Action**: Do not attempt a fix. Note in the assessment that CI failure appears to be infrastructure-related. Suggest re-running the workflow.

## Fix Protocol

Only attempt fixes for Category 1 failures that meet ALL of these criteria:

1. **Mechanical change** — The fix is a straightforward substitution (import path, method name, type annotation, config key). No business logic changes.
2. **Small scope** — Fewer than 5 files need modification.
3. **Documented** — The package changelog, release notes, or migration guide describes the required change.
4. **No architectural impact** — The fix does not require restructuring code, changing patterns, or updating multiple abstraction layers.

### Fix Steps

1. Read the failing CI logs (`gh run view --log-failed`)
2. Identify the specific error (compile error, test assertion, type error)
3. Cross-reference with the package changelog for migration instructions
4. Make the minimal change to resolve the error
5. Run the failing test locally if possible to verify
6. Commit with message: `fix: update usage for {package}@{version}`
7. Push to the Dependabot branch

### When to Abort

Stop and fall through to issue creation if:

- The fix requires changing more than 5 files
- The migration guide describes a multi-step process
- The error is in generated code or vendored dependencies
- You are uncertain whether the fix preserves existing behavior
- Multiple unrelated tests are failing
