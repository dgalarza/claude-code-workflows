#!/bin/bash

# setup-rails-worktree.sh
# Creates a git worktree for parallel development with proper Rails setup
#
# Reads from .worktreeinclude (if present) to determine which gitignored files
# to bring into the new worktree. Uses .gitignore-style patterns.
#
# Usage: ./setup-rails-worktree.sh <branch-name> [worktree-suffix]
#
# Options:
#   --copy         Copy files instead of symlinking (default: symlink)
#   --no-setup     Skip running bin/setup
#   --port <port>  Set APP_PORT in .env.local for the worktree
#
# Examples:
#   ./setup-rails-worktree.sh feature-auth
#   ./setup-rails-worktree.sh bugfix-login fix1
#   ./setup-rails-worktree.sh feature-auth --copy
#   ./setup-rails-worktree.sh feature-auth --port 3001

set -e

# Parse arguments
USE_SYMLINK=true
RUN_SETUP=true
BRANCH_NAME=""
WORKTREE_SUFFIX=""
APP_PORT=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --copy)
      USE_SYMLINK=false
      shift
      ;;
    --no-setup)
      RUN_SETUP=false
      shift
      ;;
    --port)
      APP_PORT="$2"
      shift 2
      ;;
    *)
      if [ -z "$BRANCH_NAME" ]; then
        BRANCH_NAME="$1"
      elif [ -z "$WORKTREE_SUFFIX" ]; then
        WORKTREE_SUFFIX="$1"
      fi
      shift
      ;;
  esac
done

WORKTREE_SUFFIX=${WORKTREE_SUFFIX:-$BRANCH_NAME}

if [ -z "$BRANCH_NAME" ]; then
  echo "Usage: ./setup-rails-worktree.sh <branch-name> [worktree-suffix] [options]"
  echo ""
  echo "Options:"
  echo "  --copy         Copy files instead of symlinking (default: symlink)"
  echo "  --no-setup     Skip running bin/setup"
  echo "  --port <port>  Set APP_PORT in .env.local for the worktree"
  echo ""
  echo "Examples:"
  echo "  ./setup-rails-worktree.sh feature-auth"
  echo "  ./setup-rails-worktree.sh bugfix-login fix1"
  echo "  ./setup-rails-worktree.sh feature-auth --copy"
  echo "  ./setup-rails-worktree.sh feature-auth --port 3001"
  exit 1
fi

# Get the current directory name for naming the worktree
PROJECT_NAME=$(basename "$(pwd)")
WORKTREE_PATH="../${PROJECT_NAME}-${WORKTREE_SUFFIX}"
ORIGINAL_DIR=$(pwd)

echo "==> Creating worktree at ${WORKTREE_PATH}"

# Ensure main is up to date
git checkout main
git pull origin main

# Create worktree with new branch
git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"

echo "==> Processing .worktreeinclude"

cd "$WORKTREE_PATH"

# Check if .worktreeinclude exists
if [ -f "${ORIGINAL_DIR}/.worktreeinclude" ]; then
  echo "    Found .worktreeinclude, processing patterns..."

  # Read patterns from .worktreeinclude and find matching files
  while IFS= read -r pattern || [ -n "$pattern" ]; do
    # Skip empty lines and comments
    [[ -z "$pattern" || "$pattern" =~ ^# ]] && continue

    # Find files matching the pattern in the original directory
    # Only include files that are gitignored (matching Claude Code Desktop behavior)
    cd "$ORIGINAL_DIR"
    for file in $pattern; do
      if [ -f "$file" ] && git check-ignore -q "$file" 2>/dev/null; then
        cd "$WORKTREE_PATH"
        # Create directory if needed
        mkdir -p "$(dirname "$file")"
        # Remove if exists
        rm -f "$file"

        if [ "$USE_SYMLINK" = true ]; then
          ln -s "${ORIGINAL_DIR}/${file}" "$file"
          echo "    Linked: $file"
        else
          cp "${ORIGINAL_DIR}/${file}" "$file"
          echo "    Copied: $file"
        fi
        cd "$ORIGINAL_DIR"
      fi
    done
  done < "${ORIGINAL_DIR}/.worktreeinclude"

  cd "$WORKTREE_PATH"
else
  echo "    No .worktreeinclude found, using defaults..."

  # Default files for Rails projects
  DEFAULT_FILES=(
    ".env"
    ".env.local"
    ".env.development.local"
    ".npmrc"
    "config/master.key"
  )

  for file in "${DEFAULT_FILES[@]}"; do
    if [ -f "${ORIGINAL_DIR}/${file}" ]; then
      mkdir -p "$(dirname "$file")"
      rm -f "$file"

      if [ "$USE_SYMLINK" = true ]; then
        ln -s "${ORIGINAL_DIR}/${file}" "$file"
        echo "    Linked: $file"
      else
        cp "${ORIGINAL_DIR}/${file}" "$file"
        echo "    Copied: $file"
      fi
    fi
  done
fi

echo "==> Setting up database isolation"

# Create worktree-specific database names to prevent collisions
DB_SUFFIX=$(echo "$WORKTREE_SUFFIX" | tr '-' '_')
cat > .env.local << EOF
# Auto-generated for worktree isolation
# This ensures parallel development doesn't collide
DB_DATABASE=${PROJECT_NAME}_development_${DB_SUFFIX}
DB_TEST_DATABASE=${PROJECT_NAME}_test_${DB_SUFFIX}
EOF

if [ -n "$APP_PORT" ]; then
  echo "APP_PORT=${APP_PORT}" >> .env.local
  echo "    Created .env.local with isolated databases and APP_PORT=${APP_PORT}"
else
  echo "    Created .env.local with isolated databases"
fi

if [ "$RUN_SETUP" = true ]; then
  echo "==> Running bin/setup"
  bin/setup
else
  echo "==> Skipping bin/setup (--no-setup)"
fi

echo ""
echo "==> Worktree ready!"
echo ""
echo "Location: ${WORKTREE_PATH}"
echo "Branch:   ${BRANCH_NAME}"
echo "Dev DB:   ${PROJECT_NAME}_development_${DB_SUFFIX}"
echo "Test DB:  ${PROJECT_NAME}_test_${DB_SUFFIX}"
if [ -n "$APP_PORT" ]; then
  echo "Port:     ${APP_PORT}"
fi
echo "Mode:     $([ "$USE_SYMLINK" = true ] && echo "symlinked" || echo "copied")"
echo ""
echo "To start working:"
echo "  cd ${WORKTREE_PATH}"
echo ""
echo "When finished:"
echo "  git worktree remove ${WORKTREE_PATH}"
