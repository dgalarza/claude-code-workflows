#!/bin/bash
#
# worktree-remove.sh
#
# WorktreeRemove hook that cleans up a git worktree.
#
# Input (stdin JSON): { "worktree_path": "/abs/path/to/worktree", ... }
# Requires: jq

set -e

# Read JSON from stdin
INPUT=$(cat)
WORKTREE_PATH=$(echo "$INPUT" | jq -r '.worktree_path')

if [ -z "$WORKTREE_PATH" ] || [ "$WORKTREE_PATH" = "null" ]; then
  echo "Error: missing 'worktree_path' in input" >&2
  exit 1
fi

if [ ! -d "$WORKTREE_PATH" ]; then
  echo "Worktree path does not exist: ${WORKTREE_PATH}" >&2
  exit 0
fi

echo "Removing worktree at ${WORKTREE_PATH}" >&2
git worktree remove --force "$WORKTREE_PATH" >&2
echo "Worktree removed successfully" >&2
