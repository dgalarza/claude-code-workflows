# Accuracy Assessment

Evaluate whether documentation reflects the actual state of the codebase. Inaccurate docs are worse than missing docs -- they actively mislead.

## Checklist

### Critical (actively misleading if wrong)

- [ ] **File paths in codemap** -- Every path mentioned in ARCHITECTURE.md exists on disk
  - Run: extract all paths from ARCHITECTURE.md, verify each with `ls` or `test -e`
  - Flag: paths that reference deleted or moved files/directories
- [ ] **Build/test/run commands** -- Commands in AGENTS.md and README.md actually work
  - Check: do the scripts referenced in package.json/Makefile/etc. exist?
  - Check: are the commands syntactically correct for the project's toolchain?
- [ ] **Port numbers** -- Ports documented match docker-compose.yml, .env, and application config
  - Common drift: ports change in docker-compose but docs still reference old ones
- [ ] **Environment variables** -- Env vars listed in docs match what the code actually reads
  - Check: .env.example or .env.sample against documented vars

### Warning (stale but not dangerous)

- [ ] **Dependency counts** -- "We use 3 agents" when there are now 5
  - Check: counts of agents, tools, packages, services against actual code
- [ ] **Technology references** -- "Uses Express" when the project migrated to Fastify
  - Check: framework/library references against package.json/Gemfile/etc.
- [ ] **Agent/tool tables** -- For AI-focused projects, verify agent names, models, and tool assignments
  - Check: agent definitions in code match documentation tables

### Info (minor description drift)

- [ ] **One-line descriptions** -- Directory descriptions in codemap are still accurate
  - These drift naturally but rarely mislead
- [ ] **Architecture diagrams** -- If present, do they reflect current component relationships?
- [ ] **Version numbers** -- Referenced versions match actual dependencies

## Verification Strategy

For each documentation file:

1. Extract all concrete claims (paths, names, numbers, commands)
2. Verify each claim against the codebase
3. Categorize discrepancies by severity

```bash
# Example: extract file paths from ARCHITECTURE.md
grep -oE '`[^`]+\.(ts|js|rb|py|go|java|rs|yaml|yml|json|toml)`' ARCHITECTURE.md 2>/dev/null | tr -d '`' | while read -r path; do
    [ ! -e "$path" ] && echo "MISSING: $path"
done

# Example: extract port numbers
grep -oE 'port[: ]+[0-9]{4,5}' ARCHITECTURE.md docker-compose.yml .env 2>/dev/null | sort
```
