# Code Clarity

## Why This Matters for Agent Readiness

Code clarity determines whether an agent can understand and modify individual files without excessive context. When files are small, focused, and well-named, an agent can fit a complete unit of logic in its context window, understand its purpose from the filename alone, and make targeted changes with confidence. Large, multi-responsibility files force agents to process irrelevant code, increasing the chance of unintended modifications and reducing the effective scope of autonomous work.

## What to Examine

- **Filesystem as interface**: The file and directory structure is the primary way an agent navigates a codebase. Clear structure means clear intent — the agent should be able to infer what a file does from its path and name before reading it
- **File size distribution**: What is the distribution of file sizes across the codebase? Are most files small and focused, or are there many large files?
- **God files / large classes**: Files exceeding 500-1000 lines typically contain multiple responsibilities and are difficult for agents to modify safely
- **Naming clarity**: Can the purpose of a file/class/module be inferred from its name? Vague names (utils, helpers, misc, common, shared) force agents to read files to understand them
- **Single Responsibility Principle**: Do files and classes have a single, clear purpose? Or do they mix multiple concerns?
- **Catch-all directories**: Directories named utils/, helpers/, common/, shared/, misc/ are red flags — they attract unfocused code that has no natural home, making it hard for agents to know what lives where

## Evidence-Gathering Commands

```bash
# Top 20 largest source files (across common languages)
find . -name "*.rb" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.js" -o -name "*.scala" -o -name "*.java" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor | grep -v spec | grep -v test \
  | xargs wc -l 2>/dev/null | sort -rn | head -21

# Average file size
find . -name "*.rb" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.js" -o -name "*.scala" -o -name "*.java" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor | grep -v spec | grep -v test \
  | xargs wc -l 2>/dev/null | awk '{sum+=$1; count++} END {if(count>1) print "Average:", sum/(count-1), "lines"}'

# Files over 500 lines
find . -name "*.rb" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.js" -o -name "*.scala" -o -name "*.java" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor | grep -v spec | grep -v test \
  | xargs wc -l 2>/dev/null | awk '$1 > 500' | sort -rn | head -10

# Files over 1000 lines (god files)
find . -name "*.rb" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.js" -o -name "*.scala" -o -name "*.java" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor | grep -v spec | grep -v test \
  | xargs wc -l 2>/dev/null | awk '$1 > 1000' | sort -rn | head -10

# Directory structure (first 30 directories)
find . -type d 2>/dev/null | grep -v node_modules | grep -v .git | grep -v vendor | head -30

# Catch-all directories
find . -type d \( -name "utils" -o -name "helpers" -o -name "common" -o -name "shared" -o -name "misc" -o -name "lib" \) 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor

# Files in catch-all directories (how much code hides there)
for dir in utils helpers common shared misc; do
  COUNT=$(find . -type f -path "*/$dir/*" 2>/dev/null | grep -v node_modules | grep -v .git | grep -v vendor | wc -l)
  if [ "$COUNT" -gt 0 ]; then
    echo "$dir/: $COUNT files"
  fi
done
```

## Scoring Bands

- **0-20**: Many files exceed 1000 lines. No obvious organizational principle. God files are common. Naming is vague or inconsistent. Agent cannot infer file purpose from path.
- **21-40**: Files commonly 500-1000 lines. Some organization but mixed concerns within files. Naming partially informative but catch-all directories (utils/, helpers/) contain significant code.
- **41-60**: Most files 200-500 lines. Reasonable naming conventions. Some god files remain but are outliers. Directory structure provides moderate navigability. Agent can usually infer purpose from path.
- **61-80**: Typical file under 300 lines. Clear, descriptive naming. Single Responsibility Principle mostly followed with few outliers. Catch-all directories minimal. Agent can confidently navigate and modify individual files.
- **81-100**: Typical file under 200 lines. Excellent naming that communicates intent. SRP evident throughout. Directory structure reveals domain concepts. No catch-all directories. Agent can understand any file's purpose from its path alone.

NOTE: For dimensions where scoring bands differ materially by language, these bands provide the general framing. The language file provides concrete criteria and tooling-specific thresholds.

## Score Modifiers

- **No files exceed 500 lines**: **+5**
- **Catch-all directories (utils/, helpers/, etc.) contain >20 files each**: **-5**
- **More than 10 god files (>1000 lines)**: **-10**

## Output Format

```markdown
## Code Clarity Assessment

**Score: XX/100**

### Evidence
- Average file size: [X lines]
- Files over 500 lines: [count]
- Files over 1000 lines (god files): [count, largest listed]
- Catch-all directories: [list with file counts]
- Directory depth: [typical nesting level]
- Naming quality: [excellent / good / mixed / poor — examples]

### Strengths
- [What's working well]

### Gaps
- [What's missing or weak]

### Recommendations
**Quick Wins (1-2 days):**
- [Specific actionable item]

**High-Value Investments (1-4 weeks):**
- [Specific actionable item]
```
