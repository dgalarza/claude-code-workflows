# Regression-Aware Quality Gate Pattern

The cross-language pattern the `quality-gates` mode installs. It is deliberately tool-agnostic: the project's native analyzers produce findings, a small baseline layer decides what is new, and CI blocks on that decision. The pattern is the same whether the analyzer is RuboCop, golangci-lint, ESLint, or PMD.

## The Contract

Three commands, identical locally and in CI:

| Command | Purpose | Exit code | Who runs it |
|---------|---------|-----------|-------------|
| `report` | Show every finding grouped as new / worsened / stale / baselined, with changed-file attribution | always 0 | anyone, any time |
| `check` | Fail on new or worsened findings, on stale baseline entries, or on an unreviewed baseline | 1 on failure | CI on every PR; agents before marking work done |
| `baseline` | Create or extend the baseline (needs `--reason`, then human approval); `--prune` removes stale entries and tightens improved metrics | 2 on refusal | humans create/extend/approve; anyone may prune |

Semantics the gate must satisfy (these are what the tests prove):

1. **Unchanged legacy debt passes.** Findings recorded in the baseline do not fail `check`, even when they move to other line numbers.
2. **New or worsened debt fails.** A finding not in the baseline fails. A baselined finding whose count grew, or whose tracked metric (complexity value, duplicated lines) increased, fails.
3. **Stale entries are removed.** When debt is fixed, `check` reports the entry as stale and fails until `baseline --prune` removes it, so the baseline only ever shrinks. Pruning never needs review because it only tightens.
4. **Baselines are reviewed, not blindly blessed.** Creating or extending a baseline requires a written reason, prints a review summary (counts by rule, top files), refuses to run in CI, and leaves the baseline in an unreviewed state that fails `check` until a human approves it with their name. The baseline file is CODEOWNERS-protected.
5. **Merge-base aware.** Findings are attributed to files changed since `git merge-base <base> HEAD`, not since the tip of main; `--changed-only` scopes fast local runs to that set. CI checks out with full history so the merge-base resolves.
6. **Tool failure is not a pass.** A check whose command exits non-zero without producing findings is an error that fails the gate.

## Two Ways to Get There

### Option A: the analyzer has a native baseline or diff mode

Use it. No custom baseline layer is needed; the three commands become thin wrappers.

| Tool | Native mechanism | Notes |
|------|------------------|-------|
| golangci-lint | `issues.new-from-merge-base: origin/main` (or `new-from-rev`) | Complexity (`gocyclo`, `gocognit`), duplication (`dupl`), dead code (`unused`) all in one tool. Merge-base aware out of the box. Stale handling is automatic (no baseline file) |
| detekt | `detekt --baseline detekt-baseline.xml`; `--create-baseline` | Baseline is XML; prune by regenerating after fixes. Review the diff of the baseline file in PRs |
| PHPStan | `--generate-baseline` + `reportUnmatchedIgnoredErrors: true` | The `reportUnmatchedIgnoredErrors` flag is what makes stale entries fail; without it the baseline only grows |
| RuboCop | `.rubocop_todo.yml` + `--regenerate-todo` after fixes | Only counts as regression-aware if the todo file is regenerated (pruned) when offenses are fixed. Pair with `Metrics/*` cops for complexity |
| SonarQube / SonarCloud | New-code quality gate | Vendor-hosted; the local `check` must still exist for agents |

Wrap them so the contract holds: `report` runs the tool in its normal mode, `check` runs it in baseline/diff mode, `baseline` regenerates with `--reason` recorded in the commit message and the PR. Add the review requirement via CODEOWNERS on the baseline file.

### Option B: the analyzer has no baseline mode

Use `assets/quality-gate.py` (stdlib Python, committed to the target repo as `scripts/quality-gate.py`). It runs each configured analyzer, parses one finding per line, fingerprints findings by `check | rule | file | message-without-numbers` (so line numbers and metric values do not affect identity), and compares to `.quality-baseline.json`.

Config, `.quality-gate.json`:

```json
{
  "version": 1,
  "base_ref": "origin/main",
  "baseline": ".quality-baseline.json",
  "checks": {
    "complexity":  { "command": "...", "format": "unix" },
    "duplication": { "command": "...", "format": "jsonl" },
    "dead-code":   { "command": "...", "format": "jsonl", "metric": false }
  }
}
```

Each check's command must print **one finding per line** in one of two formats:

- `unix`: `path:line[:col]: message [rule]` -- what ESLint `-f unix`, RuboCop `-f emacs`, ruff `--output-format concise`, and gcc-style tools emit. A trailing `[rule]` or `(rule)` becomes the rule id; otherwise the check name is used.
- `jsonl`: `{"file": ..., "line": ..., "rule": ..., "message": ...}` per line -- produce it from any tool's JSON output with `jq -c` or a one-line Python adapter.

The first integer in a message is tracked as a metric (a complexity value, a duplicated-line count). A higher value than the baseline is "worsened". Set `"metric": false` on checks whose messages contain incidental numbers (dead-code reports, for instance).

## Adapter Recipes

Each recipe emits the contract format. Test every command by hand before writing it into the config.

**TypeScript / JavaScript**

```bash
# complexity (unix): ESLint's own rule, threshold from the project's config
npx eslint . -f unix --rule 'complexity: ["error", 10]' --no-inline-config || true
# cognitive complexity if eslint-plugin-sonarjs is installed
npx eslint . -f unix --rule 'sonarjs/cognitive-complexity: ["error", 15]' || true
# duplication (jsonl) via jscpd
npx jscpd . --reporters json --output .jscpd-out --silent >/dev/null 2>&1; \
  jq -c '.duplicates[] | {file: .firstFile.name, line: .firstFile.start, rule: "duplicate-block", message: ("\(.lines) lines duplicated with " + .secondFile.name)}' .jscpd-out/jscpd-report.json
# dead code (jsonl) via knip -- reliable enough to block on
npx knip --reporter json 2>/dev/null | jq -c '.files[]? as $f | {file: $f, rule: "unused-file", message: "unused file"}, (.issues[]? | .file as $file | .exports[]? | {file: $file, line: .line, rule: "unused-export", message: ("unused export " + .name)})'
```

**Ruby / Rails**

```bash
# complexity (unix): only the Metrics cops; leave style to the normal rubocop run
bundle exec rubocop --only Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/AbcSize,Metrics/MethodLength -f emacs || true
# duplication (unix) via flay: "path:line: N similar code" lines
bundle exec flay -d app lib 2>/dev/null | awk '/^  [^ ]+:[0-9]+/ {split($1,a,":"); print a[1] ":" a[2] ": similar code (" score ") [flay]"} /^[0-9]+\)/ {score=$1}'
# dead code (jsonl) via debride with a curated whitelist
bundle exec debride --rails --whitelist .debride-whitelist app lib 2>/dev/null | awk '/^  [A-Za-z]/ {print "{\"file\": \"" $NF "\", \"rule\": \"unused-method\", \"message\": \"" $1 " possibly unused\"}"}' | sed 's/:[0-9]*"}/"}/'
```

**Python**

```bash
# complexity (unix): ruff's C901 with the project threshold
ruff check . --select C901 --output-format concise --no-fix || true
# or radon for cognitive/cyclomatic detail
radon cc . -n C -s --json | python3 -c 'import json,sys; d=json.load(sys.stdin); [print(json.dumps({"file": f, "line": b["lineno"], "rule": "complexity", "message": f"{b[\"name\"]} has complexity {b[\"complexity\"]}"})) for f, bs in d.items() for b in bs]'
# duplication (jsonl) via pylint
pylint --disable=all --enable=duplicate-code --output-format=json . 2>/dev/null | python3 -c 'import json,sys; [print(json.dumps({"file": m["path"], "line": m["line"], "rule": "duplicate-code", "message": m["message"].splitlines()[0]})) for m in json.load(sys.stdin)]'
# dead code (unix) via vulture with a whitelist; metric: false
vulture . whitelist.py --min-confidence 80 || true
```

**Go** -- use Option A. Enable `gocyclo`, `gocognit`, `dupl`, and `unused` in `.golangci.yml`, set `issues.new-from-merge-base: origin/main`, and make `check` = `golangci-lint run` and `report` = `golangci-lint run --new=false`.

**Java / Kotlin** -- detekt: Option A with `--baseline`. PMD: Option B with `pmd check -d src -R rulesets/... -f json` piped through `jq -c '.files[] | .filename as $f | .violations[] | {file: $f, line: .beginline, rule: .rule, message: .description}'`, and `pmd cpd --minimum-tokens 100 --format csv` mapped to jsonl.

**Rust** -- `cargo clippy --message-format=json -- -W clippy::cognitive_complexity` piped through `jq -c 'select(.reason=="compiler-message") | .message | select(.code != null) | {file: .spans[0].file_name, line: .spans[0].line_start, rule: .code.code, message: .message}'`; dead code via `cargo machete` (jsonl adapter) or `-W dead_code` from the same clippy stream.

**PHP / Laravel** -- PHPStan: Option A. `phpmd src json cleancode,codesize` and `phpcpd --log-pmd` for complexity/duplication through Option B.

## Baseline Review Protocol

The baseline is where debt gets blessed, so its creation is the one step that must not be automated away:

1. Run `report` first. Present the findings grouped by rule and top files. Ask which of them are cheap to fix now -- fixing before baselining is always preferred over blessing.
2. Run `baseline --reason "<why this debt is accepted for now>" --dry-run` and show the candidate summary.
3. Only on explicit confirmation, run it without `--dry-run`. The baseline is written in an **unreviewed** state and `check` fails until approved.
4. Open a PR containing `.quality-baseline.json`, `.quality-gate.json`, the engine, CI, docs, and tests. A reviewer inspects the accepted debt, then runs `baseline --approve --reviewed-by "<name>"` and pushes.
5. Add the baseline file to CODEOWNERS so extending it always requires a named reviewer.

Agents may run `check`, `report`, and `baseline --prune`. Agents must never run `baseline` (create/extend) or `--approve`. Write that into AGENTS.md.

## CI Shape

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }              # merge-base needs history
- run: git fetch origin ${{ github.base_ref || 'main' }}
- run: python3 scripts/quality-gate.py check   # GITHUB_ACTIONS is set, so findings annotate the diff
```

Never `continue-on-error`. Never regenerate the baseline in CI (`baseline` refuses when `CI` is set). See `assets/quality-gate-ci-template.yml`.

## Tests of the Gate

`assets/quality-gate-test-template.sh` runs against the installed gate with a temporary copy of the baseline and proves the three properties without touching the real baseline:

- clean tree → `check` passes
- a synthetic debt fixture (one function over the complexity threshold, written in the project's language) → `check` fails and names the file
- a stale entry injected into the temporary baseline → `check` reports it, `baseline --prune` removes it, `check` passes

Wire it into the project's test command so the gate is exercised on every CI run. The engine template itself is covered by the unit tests in the agent-ready plugin (`plugins/agent-ready/tests/`).

## Debt Fixture Snippets

One function over a threshold of 10, for the test template's "new debt fails" case:

```
TypeScript : export function qgFixture(n: number) { if (n===1) return 1; if (n===2) return 2; if (n===3) return 3; if (n===4) return 4; if (n===5) return 5; if (n===6) return 6; if (n===7) return 7; if (n===8) return 8; if (n===9) return 9; if (n===10) return 10; if (n===11) return 11; return 0; }
Ruby       : def qg_fixture(n) = n == 1 ? 1 : n == 2 ? 2 : n == 3 ? 3 : n == 4 ? 4 : n == 5 ? 5 : n == 6 ? 6 : n == 7 ? 7 : n == 8 ? 8 : n == 9 ? 9 : n == 10 ? 10 : n == 11 ? 11 : 0
Python     : def qg_fixture(n):\n    if n == 1: return 1\n    if n == 2: return 2\n    ... (12 branches)
Go         : func qgFixture(n int) int { switch n { case 1: return 1; ... case 12: return 12 }; return 0 }
```

Adapt the branch count to the project's configured threshold plus two.
