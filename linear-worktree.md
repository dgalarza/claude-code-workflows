# Linear Issue Worktree Setup

Set up a new git worktree for a Linear issue, creating a separate working directory off the main branch.

## Usage

```
/linear-worktree <project-path> <linear-issue-id>
```

## What this command does

1. **Fetch Linear Issue**: Retrieves issue details to get the suggested git branch name
2. **Create Worktree**: Creates a new git worktree in `../project-<branch-name>` directory
3. **Switch Context**: Changes to the new worktree directory
4. **Ready for Work**: Leaves you in the new worktree, ready to run `/linear-implement`

## Arguments

- First argument: Path to the project directory (e.g., `my-rails-app`)
- Second argument: The Linear issue ID (e.g., `PRJ-123`, `DEV-456`)

## Requirements

- Linear integration configured (MCP Linear tools available)
- Target project directory must be a git repository
- `main` branch exists and is up-to-date in the target project

## Example

```
/linear-worktree my-rails-app PRJ-123
```

This will:

1. Change to the `my-rails-app` directory
2. Fetch Linear issue PRJ-123 details
3. Create a new worktree at `../my-rails-app-<branch-name>`
4. Copy `.env` and `config/master.key` to the new worktree (Rails-specific files)
5. Switch to the new worktree directory
6. Run `bin/setup` inside the new worktree
7. Ready for you to run `/linear-implement PRJ-123`

## Benefits of Using Worktrees

- Work on multiple features simultaneously without branch switching
- Keep your main working directory clean
- Avoid stashing changes when switching between issues
- Each worktree maintains its own file state

---

I'll help you set up a new git worktree for the Linear issue. Let me start by parsing the arguments and changing to the project directory.

## Step 1: Navigate to Project Directory

First, I'll change to the specified project directory:

Project path: **{first argument}**
Issue ID: **{second argument}**

## Step 2: Fetch Linear Issue Details

I'll retrieve the issue information to get the suggested git branch name:

Let me fetch the complete issue details to determine the proper branch name for the worktree.

## Step 3: Prepare Main Branch

I'll ensure the main branch is up-to-date:

I'll switch to main branch and pull the latest changes to ensure the worktree starts from the most current state.

## Step 4: Create Git Worktree

I'll create a new worktree using the Linear issue's suggested branch name:

Based on the issue's git branch name, I'll create a worktree in a parallel directory using the pattern:

- Original repo: `./project-name`
- New worktree: `./project-name-<branch-name>`

This keeps worktrees organized and easy to identify.

## Step 5: Copy Configuration Files

I'll copy necessary configuration files from the parent repo to the new worktree:

1. Copy `.env` file from parent to worktree root
2. Copy `config/master.key` from parent to worktree `config/` directory

## Step 6: Switch to New Worktree

I'll change the working directory to the new worktree:

## Step 7: Run Setup

I'll run the setup process inside the new worktree:

This will install dependencies and configure the new worktree environment.

## Step 8: Summary

The new worktree is ready for development. From here you can:

1. Run `/linear-implement {issue-id}` to start the full implementation workflow
2. Work on the issue manually with full git functionality
3. The worktree maintains its own file state independent of the main repo

✅ **Worktree Created Successfully**

- **Issue**: {issue-id}
- **Branch**: [Shown after fetching issue]
- **Location**: [Shown after creation]
- **Status**: Ready for development

**Next Steps:**

- Run `/linear-implement {issue-id}` to start implementation
- Or begin working on the issue manually
- When done, remove worktree with: `git worktree remove <path>`