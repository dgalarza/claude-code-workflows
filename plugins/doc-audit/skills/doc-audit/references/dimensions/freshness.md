# Freshness Assessment

Evaluate whether documentation has kept pace with code changes. Fresh docs reflect active maintenance; stale docs signal neglect.

## Checklist

### Critical (docs clearly abandoned)

- [ ] **Doc last modified vs code activity** -- Docs haven't been updated in >30 days while code has active commits
  - Run: `git log -1 --format="%ai" -- AGENTS.md ARCHITECTURE.md docs/` vs `git log -1 --format="%ai"`
  - If gap is >30 days with active development, docs are likely stale
- [ ] **Major features without doc updates** -- New directories, packages, or services added without corresponding doc changes
  - Run: `git log --since="30 days ago" --diff-filter=A --name-only -- '*.ts' '*.js' '*.rb' '*.py'` and check if docs were also updated

### Warning (docs falling behind)

- [ ] **Doc update gap 14-30 days** -- Docs haven't been updated in 14-30 days with active development
  - Not yet critical but trending toward staleness
- [ ] **ADR recency** -- Last ADR was written long before the last significant architectural change
  - Run: `ls -lt docs/decisions/*.md | head -1` vs recent structural commits
- [ ] **TODO/FIXME in docs** -- Documentation contains unresolved markers
  - Run: `grep -rn 'TODO\|FIXME\|HACK\|XXX' AGENTS.md ARCHITECTURE.md docs/ 2>/dev/null`

### Info (minor lag)

- [ ] **Doc update gap 7-14 days** -- Minor lag, acceptable for most projects
- [ ] **Changelog gaps** -- If a CHANGELOG exists, check if recent releases are documented

## Measurement

```bash
# Last doc update
echo "=== DOC FRESHNESS ==="
for f in AGENTS.md CLAUDE.md ARCHITECTURE.md; do
    if [ -f "$f" ]; then
        echo "$f: $(git log -1 --format='%ai (%ar)' -- "$f" 2>/dev/null || echo 'not tracked')"
    fi
done

# Last code update
echo ""
echo "=== CODE ACTIVITY ==="
echo "Last commit: $(git log -1 --format='%ai (%ar)' 2>/dev/null)"
echo "Commits in last 7 days: $(git rev-list --count --since='7 days ago' HEAD 2>/dev/null)"
echo "Commits in last 30 days: $(git rev-list --count --since='30 days ago' HEAD 2>/dev/null)"

# Files added recently without doc updates
echo ""
echo "=== NEW FILES (last 30 days) ==="
git log --since="30 days ago" --diff-filter=A --name-only --pretty=format:"" 2>/dev/null | grep -v '\.md$' | sort -u | head -20

echo ""
echo "=== DOC UPDATES (last 30 days) ==="
git log --since="30 days ago" --name-only --pretty=format:"" -- '*.md' 2>/dev/null | sort -u
```

## Thresholds

| Gap | Rating | Action |
|-----|--------|--------|
| < 7 days | Fresh | No action needed |
| 7-14 days | Info | Minor lag, acceptable |
| 14-30 days | Warning | Schedule doc update |
| > 30 days | Critical | Docs are stale, likely inaccurate |
