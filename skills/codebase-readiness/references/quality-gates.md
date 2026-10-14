# Regression-Aware Quality Gates

Shared reference for the Code Clarity, Consistency, Feedback Loops, and Change Safety dimensions. It defines what a regression-aware quality gate is, how to detect one, how to assign it a single **Gate Maturity Level**, and which dimension gets credit for which slice of the evidence so nothing is counted twice.

## Why This Matters for Agent Readiness

Under human-paced change, code review holds the line on complexity, duplication, and dead code. Under agent-paced change (dozens to hundreds of PRs a week) review is the bottleneck, and any property that is not mechanically enforced drifts. Report-only tooling ("we run the complexity report nightly") does not hold the line; a gate that fails the PR when it adds or worsens debt does.

The catch is legacy debt. A hard threshold ("no function above complexity 10") is unadoptable on a codebase with 400 violations, so teams either disable the rule or set the threshold so high it never fires. A **regression-aware** gate solves this with a baseline: existing debt is inventoried and allowed to stay, new debt is blocked, worsened debt is blocked, and when debt is removed the baseline entry is pruned so the gate only ever tightens. The baseline itself is a reviewed artifact, not a blanket suppression.

## What a Complete Gate Looks Like

1. **Structural checks**, using the language's native tools: cyclomatic or cognitive complexity, duplication, and a *reliable* dead-code / unused-export check (one the team trusts enough to fail the build on, not one with a known false-positive list)
2. **Baseline treatment of legacy debt**: existing findings are fingerprinted and recorded; the gate compares against the baseline rather than an absolute threshold
3. **PR CI that blocks**: the gate fails the PR on new or worsened findings, is merge-base aware (compares against the branch point, not the tip of main), and reports findings actionably (inline annotations or a changed-files-scoped summary)
4. **Reproducible local commands**: the same `report` / `check` / `baseline` commands run locally and in CI, documented in AGENTS.md or a guide
5. **Governed baseline**: baseline creation and extension require a written reason and human review; stale entries are pruned; the file is protected (CODEOWNERS or equivalent)
6. **Tests of the gate**: focused tests proving that unchanged legacy debt passes, new or worsened debt fails, and stale entries are removed

## Gate Maturity Level

Determine the level **once**, in Phase 1, from `recon.sh`'s `=== QUALITY GATES ===` section, and record it in the Codebase Snapshot. All four dimensions read it from the snapshot; none re-derive it.

| Level | Name | Criteria |
|-------|------|----------|
| **L0** | None | No complexity, duplication, or dead-code tooling configured |
| **L1** | Report-only | Tooling runs (locally, nightly, or in CI) but cannot fail a PR: `continue-on-error`, `\|\| true`, warnings-only, or no CI step at all |
| **L2** | Threshold | CI fails on an absolute threshold. Legacy debt is handled by inline suppressions, a large never-pruned todo/baseline file, or thresholds set above the worst offender |
| **L3** | Regression-aware | CI blocks **new or worsened** findings relative to a baseline or merge-base. Native diff modes count (`golangci-lint issues.new-from-merge-base`, `detekt --baseline`, `phpstan` baseline with `reportUnmatchedIgnoredErrors`, `.rubocop_todo.yml` that is pruned, SonarQube new-code gate) as does a repo-local fingerprint baseline |
| **L4** | Governed | L3 plus: the same commands run locally and in CI, the baseline is human-reviewed with recorded reasons and pruned when debt is fixed, and the gate has its own tests |

Record the level with its justification, for example: `Quality gates: L2 -- eslint complexity rule fails CI at 25; 140 inline disables; no duplication or dead-code check`.

**Highest credit in every dimension requires L3 or L4.** Report-only tooling (L1) earns tooling-presence credit only.

## Credit Ownership (no double counting)

Each dimension scores a distinct slice. Do not award credit for the same fact in two dimensions.

| Slice | Dimension | What earns credit | What does not |
|-------|-----------|-------------------|---------------|
| **Which structural properties are covered** | Code Clarity | Complexity, duplication, and dead-code/unused-export checks exist and are configured with project thresholds; more credit when each is enforced at L3+ | CI ergonomics, baseline governance, lint style rules |
| **Style tooling and lint-debt treatment** | Consistency & Conventions | Lint/format enforcement (already scored) plus how **lint** legacy debt is handled: a pruned, shrinking todo/baseline earns credit; a growing or never-pruned one loses it | Complexity, duplication, or dead-code tools (those are Code Clarity) |
| **Actionability, reproducibility, and gate tests** | Feedback Loops | PR findings are annotated inline or scoped to changed files; merge-base-aware diffing; the local command is identical to the CI command; the gate has tests | Which tools are used; whether the gate blocks (that is Change Safety) |
| **Blocking semantics and baseline governance** | Change Safety | CI blocks new or worsened debt (L3); baseline creation requires a reason and review; stale entries are pruned; baseline is protected and not growing | Tool selection; CI speed or annotation format |

## Evidence-Gathering Commands

`recon.sh` runs the detection sweep. Agents needing more detail for their slice can use:

```bash
# Tool configuration (which structural properties are covered)
grep -rEl "complexity|max-complexity|cognitive|C901|Metrics/(Cyclomatic|Perceived)Complexity|gocyclo|gocognit|cyclomatic" \
  .eslintrc* eslint.config.* biome.json .rubocop.yml pyproject.toml ruff.toml setup.cfg .golangci.yml \
  phpmd*.xml detekt*.yml pmd*.xml sonar-project.properties 2>/dev/null
grep -rEl "jscpd|flay|duplicate-code|cpd|phpcpd|dupl|simian" package.json Gemfile pyproject.toml .golangci.yml .pylintrc pmd*.xml composer.json .jscpd.json 2>/dev/null
grep -rEl "knip|ts-prune|ts-unused-exports|unused-imports|vulture|debride|deadcode|unused|cargo-udeps|cargo-machete|UnusedPrivateMember|unusedFunction" \
  package.json knip.json knip.jsonc Gemfile pyproject.toml .golangci.yml Cargo.toml detekt*.yml phpstan.neon* 2>/dev/null

# Baseline artifacts and their size / staleness
ls .rubocop_todo.yml phpstan-baseline.neon phpstan-baseline.php detekt-baseline.xml .quality-baseline.json .betterer.results \
   eslint-baseline.json .eslint-baseline.json .mypy-baseline* lint-baseline.xml 2>/dev/null
for f in .rubocop_todo.yml phpstan-baseline.neon detekt-baseline.xml .quality-baseline.json; do
  [ -f "$f" ] && echo "$f: $(wc -l < "$f") lines, last shrink: $(git log --diff-filter=M --format=%cs -1 -- "$f" 2>/dev/null)"
done
grep -E "new-from-rev|new-from-merge-base|reportUnmatchedIgnoredErrors|--baseline" .golangci.yml phpstan.neon* detekt*.yml 2>/dev/null

# CI: does the gate block, and is it merge-base aware?
grep -rnE "continue-on-error|\|\| true|allow_failure|soft_fail" .github/workflows .gitlab-ci.yml .circleci 2>/dev/null
grep -rnE "merge-base|merge_base|fetch-depth: 0|changed-files|--changed-only|new-from|reviewdog|danger|--diff-filter|base_ref" .github/workflows .gitlab-ci.yml .circleci .buildkite 2>/dev/null

# Reproducible local commands
grep -nE "quality|gate|baseline|complexity|duplication|dead" Makefile Rakefile justfile package.json composer.json 2>/dev/null | head -20
ls scripts/quality* script/quality* bin/quality* scripts/quality-gate* tools/quality* 2>/dev/null

# Tests of the gate
find . -path ./node_modules -prune -o -path ./vendor -prune -o \( -iname "*quality*gate*test*" -o -iname "test_quality_gate*" -o -iname "quality-gate*.spec.*" -o -iname "*gate*_spec.rb" \) -print 2>/dev/null

# Baseline protection
grep -nE "baseline|_todo|quality-gate" .github/CODEOWNERS CODEOWNERS docs/CODEOWNERS 2>/dev/null
```

## Native Tooling by Language

Prefer these over bespoke scripts. Where the native tool has a diff or baseline mode, the gate can be L3 without any custom code.

| Language | Complexity | Duplication | Dead code / unused exports | Native baseline or diff mode |
|----------|-----------|-------------|----------------------------|------------------------------|
| TypeScript / JavaScript | ESLint `complexity`, `sonarjs/cognitive-complexity`; Biome `noExcessiveCognitiveComplexity` | `jscpd` | `knip` (reliable), `ts-prune` (legacy), `eslint-plugin-unused-imports` | None built in; fingerprint baseline or `betterer` |
| Ruby / Rails | RuboCop `Metrics/*` | `flay` | `debride` (with `--rails`), RuboCop `Lint/UselessAssignment` | `.rubocop_todo.yml` (L3 only if pruned with `--regenerate-todo` after fixes) |
| Python | `ruff` `C901`, `radon`/`xenon` | `pylint --disable=all --enable=duplicate-code` | `vulture` (curate a whitelist), `ruff` `F401`/`F841` | `ruff`/`flake8` per-file-ignores are suppression, not baseline; fingerprint baseline |
| Go | `gocyclo`, `gocognit` via `golangci-lint` | `dupl` via `golangci-lint` | `unused` (staticcheck) via `golangci-lint`, `deadcode` | `golangci-lint` `issues.new-from-merge-base` (native L3) |
| Java / Kotlin | PMD `CyclomaticComplexity`, `detekt` `ComplexMethod` | PMD CPD | PMD `UnusedPrivateMethod`, `detekt` `UnusedPrivateMember` | `detekt --baseline` (native L3); PMD via fingerprint baseline |
| Scala | `scalastyle` `CyclomaticComplexityChecker` | PMD CPD (Scala language module) | `scalafix` `RemoveUnused` | fingerprint baseline |
| Rust | `clippy::cognitive_complexity` | none standard | `dead_code` warnings, `cargo-machete`, `cargo-udeps` | `-D warnings` is threshold; fingerprint baseline |
| PHP / Laravel | `phpmd` `CyclomaticComplexity`, PHPStan level | `phpcpd` | PHPStan unused rules, `phpmd` `UnusedPrivateMethod` | `phpstan --generate-baseline` with `reportUnmatchedIgnoredErrors: true` (native L3) |

"Reliable" dead-code check means the tool's findings can be acted on without a large false-positive list. `knip` for TS and `golangci-lint unused` for Go generally qualify; `vulture` and `debride` need a curated whitelist before they can fail a build.

## Common Anti-Patterns (score as L1 or L2, not L3)

- A todo/baseline file that has only ever grown (`git log` shows additions, no removals)
- `continue-on-error: true` on the quality job, or the job publishes a report artifact and nothing else
- Thresholds set above the worst existing offender so the rule never fires
- Hundreds of inline disables (`eslint-disable`, `rubocop:disable`, `noqa`, `nolint`) substituting for a baseline
- A dead-code tool that runs but whose output is ignored because of false positives
- A baseline any contributor (or agent) can regenerate to make CI green: no reason field, no review, no CODEOWNERS
