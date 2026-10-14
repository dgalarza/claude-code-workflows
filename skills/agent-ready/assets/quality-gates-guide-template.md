# Quality Gates

This repository runs a regression-aware quality gate on every PR. Legacy debt recorded in `.quality-baseline.json` is allowed to stay; any change that adds new complexity, duplication, or dead code -- or makes a baselined finding worse -- fails CI.

## Commands

Same commands locally and in CI:

| Command | What it does |
|---------|--------------|
| `[REPORT_CMD]` | Show all findings: new, worsened, stale, and baselined. Add `--changed-only` to scope to files changed since the merge-base |
| `[CHECK_CMD]` | Exit 1 on new or worsened findings, stale baseline entries, or an unreviewed baseline. Run before marking work done |
| `[PRUNE_CMD]` | Remove baseline entries for debt that has been fixed and tighten improved metrics. Safe for anyone to run; commit the result |

## Checks

| Check | Tool | What it catches | Threshold |
|-------|------|-----------------|-----------|
| `complexity` | [TOOL] | [Cyclomatic / cognitive complexity per function] | [N] |
| `duplication` | [TOOL] | [Duplicated blocks] | [N lines / tokens] |
| `dead-code` | [TOOL] | [Unused exports, files, methods] | -- |

Configuration lives in `.quality-gate.json`.

## When the gate fails

1. Read the output. Each finding names the file, the rule, and whether the file is part of this change.
2. Fix the code. Reduce the function, extract the duplicate, delete the dead export.
3. Re-run `[CHECK_CMD]` until it passes.

Do **not** add findings to the baseline to get past the gate. The baseline records debt that existed before the gate was installed; it is not an escape hatch.

## Stale entries

If `check` reports stale entries, someone fixed debt and the baseline has not caught up. Run `[PRUNE_CMD]` and commit `.quality-baseline.json`. The baseline only ever shrinks this way.

## Extending the baseline (humans only)

Rarely, accepting new debt is the right call -- a vendored module, a generated file, a deliberate stop-gap with a dated follow-up. That is a reviewed decision:

```bash
[BASELINE_CMD] --extend --reason "why this debt is accepted"
# open a PR; the reviewer inspects the accepted entries, then:
[BASELINE_CMD] --approve --reviewed-by "Reviewer Name"
```

`check` fails while a baseline is unreviewed. `.quality-baseline.json` is protected by CODEOWNERS. Agents never run `--extend` or `--approve`.

## Tests of the gate

`[TEST_CMD]` proves the gate works: a clean tree passes, a synthetic over-complex function fails, and a stale entry is pruned. It runs in CI alongside the gate.
