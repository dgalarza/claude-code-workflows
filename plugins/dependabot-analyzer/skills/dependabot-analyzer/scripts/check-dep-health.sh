#!/usr/bin/env bash
# check-dep-health.sh — Query package registry APIs for dependency health metrics.
#
# Usage:
#   bash check-dep-health.sh <ecosystem> <package-name>
#
# Supported ecosystems: npm, pip, bundler (rubygems), cargo, gomod
# Output: Structured text with health rating and supporting data.

set -euo pipefail

ECOSYSTEM="${1:-}"
PACKAGE="${2:-}"

if [[ -z "$ECOSYSTEM" || -z "$PACKAGE" ]]; then
  echo "Usage: check-dep-health.sh <ecosystem> <package-name>"
  echo "Ecosystems: npm, pip, bundler, cargo, gomod"
  exit 1
fi

echo "=== DEPENDENCY HEALTH CHECK ==="
echo "Package: $PACKAGE"
echo "Ecosystem: $ECOSYSTEM"
echo ""

fetch_npm() {
  local data
  data=$(curl -sf "https://registry.npmjs.org/$PACKAGE" 2>/dev/null) || {
    echo "Registry: npm"
    echo "Status: NOT FOUND"
    echo "Health: unknown"
    return
  }

  local latest modified weekly_downloads
  latest=$(echo "$data" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('dist-tags',{}).get('latest','unknown'))" 2>/dev/null || echo "unknown")
  modified=$(echo "$data" | python3 -c "import sys,json; print(json.load(sys.stdin).get('time',{}).get('modified','unknown'))" 2>/dev/null || echo "unknown")

  # Get download count
  weekly_downloads=$(curl -sf "https://api.npmjs.org/downloads/point/last-week/$PACKAGE" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('downloads',0))" 2>/dev/null || echo "0")

  echo "Registry: npm"
  echo "Latest version: $latest"
  echo "Last modified: $modified"
  echo "Weekly downloads: $weekly_downloads"
}

fetch_pip() {
  local data
  data=$(curl -sf "https://pypi.org/pypi/$PACKAGE/json" 2>/dev/null) || {
    echo "Registry: pypi"
    echo "Status: NOT FOUND"
    echo "Health: unknown"
    return
  }

  local version upload_time
  version=$(echo "$data" | python3 -c "import sys,json; print(json.load(sys.stdin)['info']['version'])" 2>/dev/null || echo "unknown")
  upload_time=$(echo "$data" | python3 -c "
import sys,json
d=json.load(sys.stdin)
v=d['info']['version']
urls=d.get('urls',[])
if urls:
    print(urls[0].get('upload_time','unknown'))
else:
    releases=d.get('releases',{}).get(v,[])
    print(releases[0].get('upload_time','unknown') if releases else 'unknown')
" 2>/dev/null || echo "unknown")

  echo "Registry: pypi"
  echo "Latest version: $version"
  echo "Last release: $upload_time"
}

fetch_bundler() {
  local data
  data=$(curl -sf "https://rubygems.org/api/v1/gems/$PACKAGE.json" 2>/dev/null) || {
    echo "Registry: rubygems"
    echo "Status: NOT FOUND"
    echo "Health: unknown"
    return
  }

  local version downloads
  version=$(echo "$data" | python3 -c "import sys,json; print(json.load(sys.stdin).get('version','unknown'))" 2>/dev/null || echo "unknown")
  downloads=$(echo "$data" | python3 -c "import sys,json; print(json.load(sys.stdin).get('downloads',0))" 2>/dev/null || echo "0")

  echo "Registry: rubygems"
  echo "Latest version: $version"
  echo "Total downloads: $downloads"
}

fetch_cargo() {
  local data
  data=$(curl -sf "https://crates.io/api/v1/crates/$PACKAGE" 2>/dev/null) || {
    echo "Registry: crates.io"
    echo "Status: NOT FOUND"
    echo "Health: unknown"
    return
  }

  local version downloads updated
  version=$(echo "$data" | python3 -c "import sys,json; print(json.load(sys.stdin)['crate']['newest_version'])" 2>/dev/null || echo "unknown")
  downloads=$(echo "$data" | python3 -c "import sys,json; print(json.load(sys.stdin)['crate']['downloads'])" 2>/dev/null || echo "0")
  updated=$(echo "$data" | python3 -c "import sys,json; print(json.load(sys.stdin)['crate']['updated_at'])" 2>/dev/null || echo "unknown")

  echo "Registry: crates.io"
  echo "Latest version: $version"
  echo "Total downloads: $downloads"
  echo "Last updated: $updated"
}

fetch_gomod() {
  echo "Registry: pkg.go.dev"
  local data
  data=$(curl -sf "https://proxy.golang.org/$PACKAGE/@latest" 2>/dev/null) || {
    echo "Status: NOT FOUND"
    echo "Health: unknown"
    return
  }

  local version time_stamp
  version=$(echo "$data" | python3 -c "import sys,json; print(json.load(sys.stdin).get('Version','unknown'))" 2>/dev/null || echo "unknown")
  time_stamp=$(echo "$data" | python3 -c "import sys,json; print(json.load(sys.stdin).get('Time','unknown'))" 2>/dev/null || echo "unknown")

  echo "Latest version: $version"
  echo "Release time: $time_stamp"
}

# Route to the appropriate registry
case "$ECOSYSTEM" in
  npm|npm_and_yarn)     fetch_npm ;;
  pip|pip3|pipenv)      fetch_pip ;;
  bundler|rubygems)     fetch_bundler ;;
  cargo)                fetch_cargo ;;
  gomod|go_modules)     fetch_gomod ;;
  *)
    echo "Registry: $ECOSYSTEM (unsupported)"
    echo "Health: unknown"
    echo "Note: Ecosystem '$ECOSYSTEM' is not yet supported. Manual review recommended."
    ;;
esac

# Check for known vulnerabilities via GitHub Advisory Database
echo ""
echo "=== VULNERABILITY CHECK ==="
VULN_DATA=$(gh api graphql -f query="
{
  securityVulnerabilities(first: 5, ecosystem: $(echo "$ECOSYSTEM" | python3 -c "
import sys
eco = sys.stdin.read().strip()
mapping = {
    'npm': 'NPM', 'npm_and_yarn': 'NPM',
    'pip': 'PIP', 'pip3': 'PIP', 'pipenv': 'PIP',
    'bundler': 'RUBYGEMS', 'rubygems': 'RUBYGEMS',
    'cargo': 'RUST',
    'gomod': 'GO', 'go_modules': 'GO',
    'nuget': 'NUGET',
    'maven': 'MAVEN'
}
print(mapping.get(eco, 'NPM'))
"), package: \"$PACKAGE\") {
    nodes {
      advisory { summary severity publishedAt }
      vulnerableVersionRange
    }
  }
}" 2>/dev/null) || VULN_DATA=""

if [[ -n "$VULN_DATA" ]]; then
  VULN_COUNT=$(echo "$VULN_DATA" | python3 -c "
import sys,json
d=json.load(sys.stdin)
nodes=d.get('data',{}).get('securityVulnerabilities',{}).get('nodes',[])
print(len(nodes))
for n in nodes:
    adv = n.get('advisory',{})
    print(f\"  - {adv.get('severity','UNKNOWN')}: {adv.get('summary','No summary')} (range: {n.get('vulnerableVersionRange','unknown')})\")
" 2>/dev/null || echo "0")
  echo "Known vulnerabilities: $VULN_COUNT"
else
  echo "Known vulnerabilities: Unable to check (gh API unavailable)"
fi