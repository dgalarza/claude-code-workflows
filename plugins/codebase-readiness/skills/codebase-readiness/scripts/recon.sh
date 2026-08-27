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
for f in package.json Gemfile pyproject.toml go.mod requirements.txt pom.xml build.sbt Cargo.toml composer.json; do
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
head -5 Cargo.toml 2>/dev/null || true
grep '"name"\|"description"\|laravel' composer.json 2>/dev/null | head -5 || true

echo ""
echo "=== SIZE METRICS ==="
echo -n "Commit count: "
git rev-list --count HEAD 2>/dev/null || echo "Not a git repo or no commits"
echo -n "Contributors: "
git shortlog -sn HEAD 2>/dev/null | wc -l
echo -n "Source files: "
find . -name "*.rb" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.js" -o -name "*.scala" -o -name "*.java" -o -name "*.rs" -o -name "*.php" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor | grep -v target | grep -vE "/(\.next|dist|build|coverage|out|__pycache__)/" | grep -v spec | grep -v test | wc -l

echo ""
echo "=== TEST FILES ==="
echo -n "Test file count: "
find . -name "*_spec*" -o -name "*_test*" -o -name "*.spec.*" -o -name "*.test.*" -o -name "test_*.py" -o -name "*Spec.scala" -o -name "*Test.scala" -o -name "*Suite.scala" -o -path "*/tests/*.rs" -o -name "*Test.php" -o -path "*/tests/*.php" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v target | grep -v vendor | grep -vE "/(\.next|dist|build|coverage|out|__pycache__)/" | wc -l

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
for f in .eslintrc* eslint.config.* biome.json .oxlintrc* .rubocop.yml .flake8 ruff.toml .pylintrc .golangci.yml .prettierrc* .scalafmt.conf .scalafix.conf clippy.toml rustfmt.toml phpstan.neon phpstan.neon.dist pint.json .php-cs-fixer.php; do
  # Use compgen to handle globs that don't match
  compgen -G "$f" > /dev/null 2>&1 && linters="$linters $f"
done
if [ -n "$linters" ]; then
  echo "Found:$linters"
else
  echo "No linting config found"
fi

echo ""
echo "=== QUALITY GATES ==="
# Regression-aware quality gate detection. The orchestrator turns this into a
# Gate Maturity Level (L0-L4) using references/quality-gates.md.
echo "-- structural tooling --"
cfgs=".eslintrc* eslint.config.* biome.json .rubocop.yml pyproject.toml ruff.toml setup.cfg .pylintrc .golangci.yml phpmd*.xml phpstan.neon* detekt*.yml pmd*.xml sonar-project.properties package.json Gemfile Cargo.toml composer.json knip.json* .jscpd.json"
cx=$(grep -lE "complexity|cognitive|C901|Metrics/(Cyclomatic|Perceived)Complexity|gocyclo|gocognit|CyclomaticComplexity" $cfgs 2>/dev/null | tr '\n' ' ')
echo "complexity: ${cx:-none}"
dup=$(grep -lE "jscpd|flay|duplicate-code|\"cpd\"|phpcpd|dupl|simian" $cfgs 2>/dev/null | tr '\n' ' ')
echo "duplication: ${dup:-none}"
dead=$(grep -lE "knip|ts-prune|ts-unused-exports|unused-imports|vulture|debride|deadcode|\bunused\b|cargo-udeps|cargo-machete|UnusedPrivateMember|UnusedPrivateMethod" $cfgs 2>/dev/null | tr '\n' ' ')
echo "dead-code: ${dead:-none}"

echo "-- baselines --"
found_baseline=""
for f in .quality-baseline.json .rubocop_todo.yml phpstan-baseline.neon phpstan-baseline.php detekt-baseline.xml eslint-baseline.json .eslint-baseline.json .betterer.results lint-baseline.xml .mypy-baseline.txt; do
  if [ -f "$f" ]; then
    found_baseline="yes"
    hist=$(git log --numstat --format= -- "$f" 2>/dev/null | awk '{a+=$1; d+=$2} END {print "+" a+0 " -" d+0}')
    echo "$f: $(wc -l < "$f" | tr -d ' ') lines, history $hist, last change $(git log --format=%cs -1 -- "$f" 2>/dev/null)"
  fi
done
[ -z "$found_baseline" ] && echo "no baseline file found"
grep -hE "new-from-rev|new-from-merge-base|reportUnmatchedIgnoredErrors|baseline" .golangci.yml phpstan.neon phpstan.neon.dist detekt.yml 2>/dev/null | sed 's/^/native diff\/baseline mode: /' | head -5
grep -E '"reviewed"|"reason"' .quality-baseline.json 2>/dev/null | head -2 | sed 's/^/governance field: /'

echo "-- CI gate behaviour --"
ci_paths=".github/workflows .gitlab-ci.yml .circleci .buildkite"
gate_jobs=$(grep -rlE "complexity|jscpd|flay|knip|vulture|debride|gocyclo|dupl|phpmd|phpcpd|detekt|pmd|quality-gate|quality_gate" $ci_paths 2>/dev/null | tr '\n' ' ')
echo "CI files running structural checks: ${gate_jobs:-none}"
soft=$(grep -rnE "continue-on-error: *true|\|\| *true|allow_failure: *true|soft_fail" $ci_paths 2>/dev/null | wc -l | tr -d ' ')
echo "soft-fail markers in CI: $soft"
mb=$(grep -rnE "merge-base|merge_base|fetch-depth: *0|changed-files|--changed-only|new-from|reviewdog|danger|base_ref" $ci_paths 2>/dev/null | wc -l | tr -d ' ')
echo "merge-base / diff-aware markers in CI: $mb"

echo "-- local commands and tests --"
grep -hnE "quality|gate|baseline|complexity|duplication|dead-?code" Makefile Rakefile justfile package.json composer.json 2>/dev/null | head -8 || true
ls scripts/quality* script/quality* bin/quality* tools/quality* 2>/dev/null || true
gate_tests=$(find . -path ./node_modules -prune -o -path ./vendor -prune -o -name __pycache__ -prune -o \( -iname "*quality*gate*test*" -o -iname "test_quality_gate*" -o -iname "quality-gate*.spec.*" -o -iname "*gate*_spec.rb" \) -print 2>/dev/null | tr '\n' ' ')
echo "gate tests: ${gate_tests:-none}"
grep -hnE "baseline|_todo|quality-gate" .github/CODEOWNERS CODEOWNERS 2>/dev/null | sed 's/^/CODEOWNERS: /' || true
grep -hnE "quality-gate|quality gate|baseline" AGENTS.md CLAUDE.md 2>/dev/null | head -3 | sed 's/^/agent docs: /' || true

echo "-- suggested level --"
# Heuristic only. The orchestrator copies this line into the Codebase Snapshot
# and adjusts it if the evidence above contradicts it (see references/quality-gates.md).
native_diff=$(grep -lE "new-from-rev|new-from-merge-base|reportUnmatchedIgnoredErrors" .golangci.yml phpstan.neon phpstan.neon.dist detekt.yml 2>/dev/null | tr '\n' ' ')
governance=$(grep -lE '"reviewed"|"reason"' .quality-baseline.json 2>/dev/null)
tooling=""; [ -n "$cx" ] && tooling="$tooling complexity"; [ -n "$dup" ] && tooling="$tooling duplication"; [ -n "$dead" ] && tooling="$tooling dead-code"
if [ -z "$tooling" ]; then
  level="L0"; why="no complexity, duplication, or dead-code tooling detected"
elif [ -z "$gate_jobs" ] || [ "$soft" -gt 0 ]; then
  level="L1"; why="tooling present (${tooling# }) but no CI job runs it without soft-fail"
elif [ -z "$found_baseline" ] && [ -z "$native_diff" ] && [ "$mb" -eq 0 ]; then
  level="L2"; why="CI runs structural checks (${tooling# }) against fixed thresholds; no baseline or merge-base comparison"
elif [ -z "$governance" ] || [ -z "$gate_tests" ]; then
  level="L3"; why="CI blocks against a baseline or merge-base (${tooling# }); missing reviewed baseline and/or gate tests for L4"
else
  level="L4"; why="baseline is governed and the gate has tests (${tooling# })"
fi
echo "Suggested Gate Maturity Level: $level -- $why"

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
