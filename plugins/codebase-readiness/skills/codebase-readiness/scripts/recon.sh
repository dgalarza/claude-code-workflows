#!/usr/bin/env bash
# Codebase Reconnaissance Script
# Gathers project metadata for the Agent-Ready Codebase Assessment.
# Output is structured for easy parsing by the orchestrator.

set -uo pipefail

echo "=== PROJECT NAME ==="
basename "$(pwd)"

echo ""
echo "=== LANGUAGE/FRAMEWORK DETECTION ==="
manifests=""
for f in package.json Gemfile pyproject.toml go.mod requirements.txt pom.xml build.sbt; do
  [ -f "$f" ] && manifests="$manifests $f"
done
if [ -n "$manifests" ]; then
  echo "Found:$manifests"
else
  echo "No standard manifest found"
fi
cat package.json 2>/dev/null | grep '"name"\|"main"\|"scripts"' | head -5 || true
head -5 Gemfile 2>/dev/null || true
head -5 pyproject.toml 2>/dev/null || true
head -3 go.mod 2>/dev/null || true
head -5 build.sbt 2>/dev/null || true

echo ""
echo "=== SIZE METRICS ==="
echo -n "Commit count: "
git rev-list --count HEAD 2>/dev/null || echo "Not a git repo or no commits"
echo -n "Contributors: "
git shortlog -sn HEAD 2>/dev/null | wc -l
echo -n "Source files: "
find . -name "*.rb" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.js" -o -name "*.scala" -o -name "*.java" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor | grep -v target | grep -v spec | grep -v test | wc -l

echo ""
echo "=== TEST FILES ==="
echo -n "Test file count: "
find . -name "*_spec*" -o -name "*_test*" -o -name "*.spec.*" -o -name "*.test.*" -o -name "test_*.py" -o -name "*Spec.scala" -o -name "*Test.scala" -o -name "*Suite.scala" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v target | wc -l

echo ""
echo "=== CI/CD ==="
ci_found=""
[ -d ".github/workflows" ] && ci_found="$ci_found GitHub Actions" && ls .github/workflows/
[ -d ".circleci" ] && ci_found="$ci_found CircleCI" && ls .circleci/
[ -d ".buildkite" ] && ci_found="$ci_found Buildkite" && ls .buildkite/
[ -f ".gitlab-ci.yml" ] && ci_found="$ci_found GitLab CI"
if [ -n "$ci_found" ]; then
  echo "Found:$ci_found"
else
  echo "No CI/CD config found"
fi

echo ""
echo "=== CLAUDE.MD ==="
find . -name "CLAUDE.md" 2>/dev/null | grep -v node_modules | grep -v .git || echo "No CLAUDE.md found"
find . -name "CLAUDE.md" -exec wc -l {} \; 2>/dev/null | grep -v node_modules || true

echo ""
echo "=== LINTING/FORMATTING ==="
linters=""
for f in .eslintrc* .rubocop.yml .flake8 ruff.toml .golangci.yml .prettierrc* .scalafmt.conf .scalafix.conf; do
  # Use compgen to handle globs that don't match
  compgen -G "$f" > /dev/null 2>&1 && linters="$linters $f"
done
if [ -n "$linters" ]; then
  echo "Found:$linters"
else
  echo "No linting config found"
fi

echo ""
echo "=== README ==="
readme=""
for f in README.md README.rst README.txt; do
  [ -f "$f" ] && readme="$f" && break
done
if [ -n "$readme" ]; then
  echo "$readme"
  wc -l "$readme"
else
  echo "No README found"
fi
