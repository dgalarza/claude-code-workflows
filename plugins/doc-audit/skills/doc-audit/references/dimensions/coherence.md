# Coherence Assessment

Evaluate whether documentation is internally consistent -- no broken links, no contradictions, no unnecessary duplication.

## Checklist

### Critical (contradictory information)

- [ ] **Conflicting instructions** -- Different docs give different build/test/run commands
  - Check: compare commands in AGENTS.md, README.md, CONTRIBUTING.md, and docs/guides/
  - Common: README says `npm test`, AGENTS.md says `yarn test`
- [ ] **Contradictory architecture claims** -- AGENTS.md describes a different structure than ARCHITECTURE.md
  - Check: module names, layer descriptions, dependency directions
- [ ] **Conflicting env var names** -- Different docs reference different names for the same config
  - Check: `PHOENIX_ENDPOINT` vs `PHOENIX_OTLP_URL` type discrepancies

### Warning (broken references)

- [ ] **Broken markdown links** -- Links between docs that point to files that don't exist
  - Run: extract all relative links from each .md file, verify targets exist
  - Common after file renames or directory restructuring
- [ ] **CLAUDE.md symlink integrity** -- If CLAUDE.md exists, it should be a symlink to AGENTS.md
  - If both exist as regular files, content may diverge
- [ ] **Orphaned docs** -- Files in docs/ that are not linked from any index or parent doc
  - These become invisible to agents navigating via progressive disclosure

### Info (minor duplication)

- [ ] **Content duplication** -- Same information repeated across multiple files
  - Some duplication is acceptable (e.g., project description)
  - Excessive duplication leads to inconsistency when one copy is updated but not others
- [ ] **Redundant sections** -- AGENTS.md contains content that belongs in a linked doc
  - Check: sections longer than 30 lines that could be extracted

## Verification Strategy

```bash
# Check all markdown links in documentation files
echo "=== BROKEN LINKS ==="
for doc in $(find . -maxdepth 3 -name "*.md" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null); do
    grep -oE '\[.*\]\([^)]+\.md[^)]*\)' "$doc" 2>/dev/null | grep -oE '\([^)]+\)' | tr -d '()' | sed 's/#.*//' | while read -r ref; do
        # Resolve relative path
        dir=$(dirname "$doc")
        target="$dir/$ref"
        if [ ! -f "$target" ] && [ ! -f "$ref" ]; then
            echo "BROKEN in $doc: $ref"
        fi
    done
done

# Check for conflicting commands
echo ""
echo "=== BUILD COMMANDS ACROSS DOCS ==="
for doc in AGENTS.md CLAUDE.md README.md CONTRIBUTING.md; do
    if [ -f "$doc" ]; then
        echo "--- $doc ---"
        grep -E '(npm |yarn |pnpm |bundle |pip |cargo |go |make )' "$doc" 2>/dev/null | head -5
    fi
done

# Check CLAUDE.md symlink
echo ""
echo "=== SYMLINK CHECK ==="
if [ -L CLAUDE.md ]; then
    echo "CLAUDE.md -> $(readlink CLAUDE.md)"
elif [ -f CLAUDE.md ] && [ -f AGENTS.md ]; then
    echo "WARNING: CLAUDE.md and AGENTS.md both exist as regular files"
    diff --brief CLAUDE.md AGENTS.md 2>/dev/null || echo "Files differ -- content may be inconsistent"
fi
```

## Common Coherence Failures

1. **Post-rename drift** -- A directory or file was renamed, some docs updated, others not
2. **Merge conflict residue** -- Documentation merged with conflicting changes, neither fully correct
3. **Copy-paste divergence** -- Content was copied between docs, then one copy was updated
4. **Config migration** -- Environment variables or ports changed in code but not all docs caught up
