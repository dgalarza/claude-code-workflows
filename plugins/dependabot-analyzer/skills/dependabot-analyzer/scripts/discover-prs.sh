#!/usr/bin/env bash
# discover-prs.sh — Find open Dependabot PRs and extract metadata.
#
# Usage:
#   bash discover-prs.sh [--repo owner/repo]
#
# Output: Structured text blocks, one per PR, separated by "---".

set -euo pipefail

REPO_ARGS=()
if [[ "${1:-}" == "--repo" && -n "${2:-}" ]]; then
  REPO_ARGS=(--repo "$2")
fi

# Fetch open Dependabot PRs
PR_JSON=$(gh pr list \
  "${REPO_ARGS[@]}" \
  --author "app/dependabot" \
  --state open \
  --json number,title,headRefName,additions,deletions,createdAt,statusCheckRollup \
  --limit 100 2>/dev/null)

PR_COUNT=$(echo "$PR_JSON" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

echo "=== DEPENDABOT PR DISCOVERY ==="
echo "Timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Total open PRs: $PR_COUNT"
echo ""

if [[ "$PR_COUNT" == "0" ]]; then
  echo "No open Dependabot PRs found."
  exit 0
fi

# Process each PR
echo "$PR_JSON" | python3 -c "
import sys, json, re
from datetime import datetime, timezone

prs = json.load(sys.stdin)

for pr in prs:
    number = pr['number']
    title = pr['title']
    branch = pr['headRefName']
    additions = pr['additions']
    deletions = pr['deletions']
    created = pr['createdAt']

    # Parse branch: dependabot/{ecosystem}/{dep-name}-{version}
    # or: dependabot/{ecosystem}/{scope}/{dep-name}-{version}
    branch_match = re.match(r'dependabot/([^/]+)/(.+)', branch)
    ecosystem = branch_match.group(1) if branch_match else 'unknown'
    dep_slug = branch_match.group(2) if branch_match else branch

    # Extract version from title patterns like:
    #   'Bump foo from 1.0.0 to 2.0.0'
    #   'Update foo requirement from ~> 1.0 to ~> 2.0'
    version_match = re.search(r'from\s+[~>=<]*\s*([\d][^\s]*)\s+to\s+[~>=<]*\s*([\d][^\s]*)', title)
    current_version = version_match.group(1) if version_match else 'unknown'
    new_version = version_match.group(2) if version_match else 'unknown'

    # Determine semver bump type
    bump_type = 'unknown'
    if current_version != 'unknown' and new_version != 'unknown':
        try:
            cur_parts = current_version.split('.')
            new_parts = new_version.split('.')
            cur_major = int(re.match(r'\d+', cur_parts[0]).group())
            new_major = int(re.match(r'\d+', new_parts[0]).group())
            if new_major > cur_major:
                bump_type = 'major'
            elif len(cur_parts) > 1 and len(new_parts) > 1:
                cur_minor = int(re.match(r'\d+', cur_parts[1]).group())
                new_minor = int(re.match(r'\d+', new_parts[1]).group())
                if new_minor > cur_minor:
                    bump_type = 'minor'
                else:
                    bump_type = 'patch'
            else:
                bump_type = 'patch'
        except (ValueError, AttributeError, IndexError):
            bump_type = 'unknown'

    # Extract dep name from slug (strip trailing version segment)
    dep_name = re.sub(r'-[\d][\d.]*$', '', dep_slug)

    # CI status
    checks = pr.get('statusCheckRollup', []) or []
    ci_status = 'unknown'
    if checks:
        states = [c.get('conclusion') or c.get('status', '') for c in checks]
        if any(s.upper() == 'FAILURE' for s in states):
            ci_status = 'failing'
        elif all(s.upper() == 'SUCCESS' for s in states):
            ci_status = 'passing'
        else:
            ci_status = 'pending'

    # Days open
    try:
        created_dt = datetime.fromisoformat(created.replace('Z', '+00:00'))
        days_open = (datetime.now(timezone.utc) - created_dt).days
    except (ValueError, TypeError):
        days_open = 0

    total_lines = additions + deletions

    print(f'PR: #{number}')
    print(f'Title: {title}')
    print(f'Branch: {branch}')
    print(f'Ecosystem: {ecosystem}')
    print(f'Dependency: {dep_name}')
    print(f'Current version: {current_version}')
    print(f'New version: {new_version}')
    print(f'Bump type: {bump_type}')
    print(f'CI status: {ci_status}')
    print(f'Lines changed: {total_lines} (+{additions} -{deletions})')
    print(f'Days open: {days_open}')
    print('---')
"

# For each PR, detect dependency location from changed files
echo ""
echo "=== DEPENDENCY LOCATIONS ==="
echo "$PR_JSON" | python3 -c "
import sys, json
prs = json.load(sys.stdin)
for pr in prs:
    print(f'#{pr[\"number\"]}')
" | while read -r PR_NUM; do
  NUM="${PR_NUM#\#}"
  CHANGED_FILES=$(gh pr diff "$NUM" "${REPO_ARGS[@]}" --name-only 2>/dev/null || echo "")

  LOCATION="unknown"
  if echo "$CHANGED_FILES" | grep -qiE '(package\.json|Gemfile|requirements.*\.txt|pyproject\.toml|Cargo\.toml|go\.mod|pom\.xml|build\.gradle|\.csproj)'; then
    # Check if it's a dev dependency by looking at the diff content
    # For package.json, check devDependencies vs dependencies
    if echo "$CHANGED_FILES" | grep -q "package.json"; then
      DIFF_CONTENT=$(gh pr diff "$NUM" "${REPO_ARGS[@]}" 2>/dev/null || echo "")
      if echo "$DIFF_CONTENT" | grep -q '"devDependencies"'; then
        LOCATION="dev"
      else
        LOCATION="prod"
      fi
    else
      LOCATION="prod"
    fi
  fi

  echo "PR $PR_NUM: $LOCATION"
  echo "Changed files: $CHANGED_FILES"
  echo "---"
done
