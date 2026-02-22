#!/bin/bash
#
# worktree-create.sh
#
# WorktreeCreate hook that replaces default git worktree creation.
# Creates the worktree, symlinks gitignored files from .worktreeinclude,
# and runs an optional post-create script.
#
# Input (stdin JSON): { "cwd": "/path/to/project", "name": "feature-auth", ... }
# Output (stdout): Absolute path to the created worktree
# All other output goes to stderr.
#
# Requires: jq

set -e

# Read JSON from stdin
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd')
NAME=$(echo "$INPUT" | jq -r '.name')

if [ -z "$CWD" ] || [ "$CWD" = "null" ]; then
  echo "Error: missing 'cwd' in input" >&2
  exit 1
fi

if [ -z "$NAME" ] || [ "$NAME" = "null" ]; then
  echo "Error: missing 'name' in input" >&2
  exit 1
fi

WORKTREE_PATH="${CWD}/.claude/worktrees/${NAME}"
BRANCH_NAME="claude-worktree/${NAME}"

# Load optional .worktreesync configuration
WORKTREE_LINK_MODE="symlink"
WORKTREE_POST_CREATE=""

if [ -f "${CWD}/.worktreesync" ]; then
  # shellcheck source=/dev/null
  source "${CWD}/.worktreesync"
  echo "Loaded .worktreesync config" >&2
fi

# Ensure .claude/worktrees directory exists
mkdir -p "${CWD}/.claude/worktrees"

# Create the git worktree
# If the branch already exists, use it; otherwise create a new one
cd "$CWD"
if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}" 2>/dev/null; then
  echo "Branch ${BRANCH_NAME} already exists, reusing it" >&2
  git worktree add "$WORKTREE_PATH" "$BRANCH_NAME" >&2
else
  echo "Creating worktree at ${WORKTREE_PATH} with branch ${BRANCH_NAME}" >&2
  git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" >&2
fi

# Process .worktreeinclude if it exists
if [ -f "${CWD}/.worktreeinclude" ]; then
  echo "Processing .worktreeinclude..." >&2

  while IFS= read -r pattern || [ -n "$pattern" ]; do
    # Skip empty lines and comments
    [[ -z "$pattern" || "$pattern" =~ ^# ]] && continue

    # Find files matching the pattern in the original directory
    cd "$CWD"
    for file in $pattern; do
      if [ -f "$file" ] && git check-ignore -q "$file" 2>/dev/null; then
        cd "$WORKTREE_PATH"
        # Create directory structure if needed
        mkdir -p "$(dirname "$file")"
        # Remove if exists (e.g., from a previous run)
        rm -f "$file"

        if [ "$WORKTREE_LINK_MODE" = "copy" ]; then
          cp "${CWD}/${file}" "$file"
          echo "  Copied: $file" >&2
        else
          ln -s "${CWD}/${file}" "$file"
          echo "  Linked: $file" >&2
        fi
        cd "$CWD"
      fi
    done
  done < "${CWD}/.worktreeinclude"
else
  echo "No .worktreeinclude found, skipping file sync" >&2
fi

# Run optional post-create script
if [ -n "$WORKTREE_POST_CREATE" ] && [ -f "${CWD}/${WORKTREE_POST_CREATE}" ]; then
  echo "Running post-create script: ${WORKTREE_POST_CREATE}" >&2
  cd "$WORKTREE_PATH"
  bash "${CWD}/${WORKTREE_POST_CREATE}" "$WORKTREE_PATH" "$NAME" >&2
fi

# Print the absolute worktree path to stdout (this is what Claude Code reads)
echo "$WORKTREE_PATH"
