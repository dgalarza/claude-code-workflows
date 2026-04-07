---
name: resolve
description: Review pending drift warnings and fix affected documentation or dismiss false positives
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep, Write, Edit, Agent
---

# doc-sentinel:resolve

Process accumulated drift warnings from `.doc-sentinel-drift.json`. For each warning, verify whether the doc actually drifted, fix it if so, or dismiss if it is a false positive.

## Phase 1: Load Drift Queue

```bash
cat .doc-sentinel-drift.json 2>/dev/null || echo "No drift warnings pending"
```

If the file is empty or missing, report "No drift warnings to resolve" and exit.

## Phase 2: Deduplicate and Group

Group warnings by doc file. Multiple source changes may affect the same doc — process them together for coherent updates.

Example grouping:

```
ARCHITECTURE.md
  - src/routes/auth.ts changed (commit abc123)
  - src/routes/users.ts changed (commit def456)

docs/api.md
  - src/controllers/payments.ts changed (commit abc123)
```

Present the grouped summary and total count before proceeding.

## Phase 3: Triage Each Group

For each doc file with drift warnings:

### 3a: Read Current State

Read the doc file and the changed source files to understand what actually changed.

### 3b: Classify the Drift

Determine what kind of drift occurred:

| Classification | Description | Action |
|---------------|-------------|--------|
| **Path moved** | Source file was renamed or moved | Update path references in doc |
| **API changed** | Function signatures, endpoints, or interfaces changed | Update API documentation |
| **Config changed** | Env vars, ports, or settings changed | Update config references |
| **Structure changed** | Directories added/removed, module reorganized | Update codemap/architecture sections |
| **Behavioral change** | Logic changed but interface stayed the same | Update descriptions if they mention specific behavior |
| **False positive** | Doc references the file but the relevant content did not change | Dismiss |

### 3c: Apply Fix or Dismiss

**For real drift:**
- Read the doc section that references the changed code
- Read the new state of the source code
- Update the doc to reflect the current reality
- Keep the same writing style and level of detail as the surrounding content
- If unsure about intent, add a `<!-- TODO: verify -->` comment rather than guessing

**For false positives:**
- Record as dismissed (remove from queue)
- No changes needed

## Phase 4: Commit Fixes

After processing all groups:

```bash
# Stage only modified doc files
git add <fixed-doc-files>
git commit -m "docs: resolve documentation drift from recent changes

Updated docs to reflect code changes detected by doc-sentinel:
- <brief summary of fixes>"
```

Use the `docs:` commit prefix to prevent the post-commit hook from re-triggering on this commit.

## Phase 5: Clear Drift Queue

```bash
# Remove the drift file — it is session-scoped
rm -f .doc-sentinel-drift.json
```

## Phase 6: Report

Print resolution summary:

```
doc-sentinel: resolved N drift warning(s)

Fixed:
  - ARCHITECTURE.md — updated 2 path references
  - docs/api.md — updated endpoint documentation

Dismissed (false positives):
  - README.md — logo path unchanged despite src/ changes

Remaining:
  - None (all warnings resolved)
```

If any warnings could not be resolved automatically (require human judgment about intent), list them separately under "Needs Review" with specific questions.

## Rules

- Always read both the doc and the source before making changes
- Preserve the existing writing style — match tone, detail level, and formatting
- Never remove documentation sections wholesale — update them
- Use `docs:` commit prefix to avoid hook feedback loops
- If a doc file has >5 drift warnings from a single commit, consider whether the doc needs a broader rewrite rather than point fixes — dispatch a `drift-resolver` agent for complex cases
- Delete `.doc-sentinel-drift.json` after processing, even if some warnings were dismissed
- If doc-sync or inkwell is also installed, do not duplicate their work — sentinel fixes references and accuracy, not content generation
