#!/bin/bash
# Doc Audit Reconnaissance Script
# Gathers codebase metadata for documentation comparison
# Run this script, don't read it into context

set -euo pipefail

echo "=== PROJECT TYPE ==="
for f in package.json Gemfile requirements.txt pyproject.toml go.mod Cargo.toml build.sbt pom.xml *.csproj; do
    [ -f "$f" ] && echo "Found: $f"
done

echo ""
echo "=== DOCUMENTATION FILES ==="
find . -maxdepth 3 \( -name "AGENTS.md" -o -name "CLAUDE.md" -o -name "ARCHITECTURE.md" -o -name "README.md" -o -name "CONTRIBUTING.md" \) -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | sort

echo ""
echo "=== DOCS DIRECTORY ==="
find docs/ doc/ -type f -name "*.md" 2>/dev/null | sort || echo "No docs/ directory"

echo ""
echo "=== ADRS ==="
find . -path "*/decisions/*.md" -o -path "*/adr/*.md" -o -path "*/adrs/*.md" 2>/dev/null | grep -v node_modules | grep -v .git | sort || echo "No ADRs found"

echo ""
echo "=== TOP-LEVEL STRUCTURE ==="
ls -1d */ 2>/dev/null | head -20

echo ""
echo "=== SOURCE FILES (top 30) ==="
find . -maxdepth 4 -type f \( -name "*.ts" -o -name "*.js" -o -name "*.rb" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rs" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/vendor/*" 2>/dev/null | head -30

echo ""
echo "=== ENTRY POINTS ==="
ls -1 src/index.* src/main.* app/main.* main.* cmd/ 2>/dev/null || echo "No standard entry points"

echo ""
echo "=== CONFIG FILES ==="
ls -1 docker-compose.yml docker-compose.yaml Dockerfile .env.example .env.sample turbo.json nx.json lerna.json 2>/dev/null || echo "No config files"

echo ""
echo "=== GIT RECENT CHANGES (files changed in last 7 days) ==="
git log --since="7 days ago" --name-only --pretty=format:"" 2>/dev/null | sort -u | head -20 || echo "No git history"
