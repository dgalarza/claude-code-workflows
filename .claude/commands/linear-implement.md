# Linear Issue Implementation Workflow

Implement a Linear issue with TDD approach, planning, memory tracking, subagent code reviews, and automated PR creation.

## Usage

```
/linear-implement <linear-issue-id>
```

## What this command does

1. **Fetch Linear Issue**: Retrieves issue details using Linear API
2. **Move to In Progress**: Updates issue status to "In Progress" to indicate work has started
3. **Create Branch**: Creates a feature branch using Linear git branch naming
4. **Plan Solution**: Analyzes requirements and creates implementation plan
5. **Save to Memory**: Stores plan in memory graph for tracking
6. **Review Plan**: Presents plan for confirmation before execution
7. **TDD Implementation**: Implements solution with test-first approach
8. **System Testing**: Includes comprehensive system specs
9. **Parallel Code Reviews**: Two subagents review for security and Rails/OOP patterns
10. **Address Review Feedback**: Implement suggested improvements
11. **Validation**: Ensures linters and specs pass
12. **Logical Commits**: Creates meaningful commit history
13. **Create PR**: Opens pull request with proper Linear linking

## Arguments

- `$ARGUMENTS` - The Linear issue ID (e.g., `TRA-9`, `DEV-123`)

## Requirements

- Linear integration configured (MCP Linear tools available)
- Current working directory must be a git repository
- `bin/lint` script available for linting
- `bundle exec rspec` available for testing
- `gh` CLI for PR creation

## Example

```
/linear-implement TRA-9
```

This will:

1. Fetch Linear issue TRA-9 details
2. Move issue to "In Progress" status
3. Create branch using Linear's suggested git branch name
4. Generate and review implementation plan
5. Implement with TDD approach
6. Run parallel code reviews (security + Rails/OOP)
7. Create PR with Linear issue linking

---

I'll help you implement the Linear issue using a structured TDD workflow with comprehensive code reviews. Let me start by fetching the issue details and creating a plan.

## Step 1: Fetch Linear Issue Details

I'll retrieve the issue information using the Linear MCP integration:

The issue details show: **$ARGUMENTS**

Now I'll fetch the complete issue details to understand the requirements:

This will give me:

- Issue title and description
- Current status and priority
- Suggested git branch name
- Team and project context
- Any attachments or related work

## Step 2: Move Issue to In Progress

I'll update the issue status to "In Progress" to indicate work has started:

This step:

1. Identifies the current team for the issue
2. Retrieves the "In Progress" state ID for that team
3. Updates the issue status to mark it as actively being worked on
4. Provides visual feedback that implementation has begun

This ensures proper project tracking and lets team members know the issue is being actively developed.

## Step 3: Create Feature Branch

I'll use Linear's suggested git branch name to maintain consistency:

Based on the issue data, I'll:

1. Ensure we're on main branch and up-to-date
2. Create the feature branch using Linear's `gitBranchName`
3. Switch to the new branch

## Step 4: Analyze and Plan Solution

I'll analyze the issue requirements and create a comprehensive implementation plan:

**Analysis Process:**

1. Break down the issue description into specific requirements
2. Identify the affected components and systems
3. Determine the testing strategy (unit, integration, system)
4. Plan the implementation approach
5. Identify potential risks and dependencies

**Planning Output:**

- **Goal**: Clear statement of what needs to be implemented
- **Requirements**: Specific functional and technical requirements
- **Architecture**: How the solution fits into existing codebase
- **Test Strategy**: Comprehensive testing approach including system specs
- **Implementation Steps**: Ordered list of development tasks
- **Acceptance Criteria**: How we'll know when it's complete

## Step 5: Save Plan to Memory

I'll store the implementation plan in the memory graph for tracking:

This creates a permanent record of:

- The issue context and requirements
- Implementation approach and reasoning
- Progress tracking throughout development
- Lessons learned for future similar issues

## Step 6: Review Plan with You

I'll present the complete plan for your review and confirmation:

**Plan Review Includes:**

- Summary of what will be implemented
- Key technical decisions and rationale
- Testing strategy and coverage
- Estimated complexity and risks
- Confirmation request before proceeding

**You can:**

- Approve the plan to proceed
- Request modifications to the approach
- Add additional requirements or constraints
- Ask questions about any aspect of the plan

## Step 7: Test-Driven Development Implementation

Upon your approval, I'll implement using strict TDD methodology:

**TDD Process:**

1. **Red Phase**: Write failing tests first
   - Unit tests for individual components
   - Integration tests for component interactions
   - System specs for end-to-end user workflows
2. **Green Phase**: Implement minimal code to pass tests
   - Focus on making tests pass with simplest solution
   - Avoid over-engineering in initial implementation
3. **Refactor Phase**: Improve code while keeping tests green
   - Extract methods and classes for clarity
   - Optimize performance where needed
   - Ensure code follows project conventions

**System Specs Strategy:**

- Create comprehensive system specs using Capybara
- Test the complete user journey
- Use page objects to keep tests maintainable
- Cover both happy path and edge cases

## Step 8: Parallel Subagent Code Reviews

After implementation, I'll launch two specialized subagents for comprehensive code review:

**Security Review Subagent:**

- Focus on security vulnerabilities and best practices
- Check for SQL injection, XSS, CSRF protections
- Verify authentication and authorization patterns
- Review data validation and sanitization
- Check for secrets or sensitive data exposure
- Validate secure coding practices

**Rails/OOP Patterns Review Subagent:**

- Evaluate adherence to POODR principles
- Check Rails conventions and best practices
- Review object-oriented design patterns
- Verify proper use of Result pattern
- Assess code organization and structure
- Check for code smells and refactoring opportunities

**Parallel Execution:**
Both subagents will run simultaneously to:

- Provide independent perspectives on the code
- Identify different types of issues
- Maximize review efficiency through parallelization
- Generate comprehensive feedback quickly

## Step 9: Address Review Feedback

I'll analyze feedback from both subagents and implement improvements:

**Feedback Processing:**

1. Consolidate recommendations from both reviews
2. Prioritize critical security issues and major design flaws
3. Plan incremental improvements
4. Implement fixes while maintaining test coverage

**Implementation of Fixes:**

- Address security vulnerabilities immediately
- Refactor code to follow better OOP patterns
- Improve Rails convention adherence
- Update tests to cover new scenarios identified
- Ensure all changes maintain backward compatibility

## Step 10: Validation and Quality Assurance

Before creating commits, I'll ensure everything passes:

**Validation Steps:**

1. Run full test suite: `bundle exec rspec`
2. Run linting: `bin/lint`
3. Fix any failures or warnings
4. Verify system specs pass in clean environment
5. Check for any missing test coverage

**Quality Checks:**

- Code follows project POODR principles
- Result pattern used for operations that can fail
- No security vulnerabilities introduced
- Performance impact considered
- All subagent feedback addressed

## Step 11: Create Logical Commits

I'll create meaningful commits that tell the story of implementation:

**Commit Strategy:**

1. **Test commits**: Add failing tests for new functionality
2. **Implementation commits**: Add code to make tests pass
3. **Refactor commits**: Improve code structure and clarity
4. **Security fixes**: Address security review feedback
5. **Pattern improvements**: Implement OOP/Rails pattern suggestions
6. **Documentation commits**: Update docs if needed

**Commit Messages Follow Project Convention:**

- Present-tense summary under 50 characters
- Detailed explanation if needed
- Reference to Linear issue
- Note which review feedback was addressed
- Claude Code attribution

## Step 12: Create Pull Request

Finally, I'll create a comprehensive PR with Linear integration:

**PR Creation:**

- Use `gh pr create` with detailed description
- Include Linear issue link for automatic integration
- Add comprehensive summary of changes
- Include test plan and validation steps
- Document code review process and findings
- Request appropriate reviewers

**PR Description Includes:**

- Summary of what was implemented
- Technical approach and key decisions
- Testing strategy and coverage
- Code review findings and resolutions
- Security considerations addressed
- Any breaking changes or migration notes
- Screenshots or demos if applicable

## Step 13: Final Verification

I'll verify the PR is properly set up:

**Final Checks:**

- CI/CD pipeline triggered successfully
- Linear issue linked and updated
- All tests passing in CI environment
- Code review assignees notified
- Branch protection rules satisfied
- Security and pattern reviews documented

**Completion Summary:**

- ✅ Linear issue analyzed and planned
- ✅ Solution implemented with TDD
- ✅ Comprehensive system specs added
- ✅ Security review completed by subagent
- ✅ Rails/OOP patterns review completed by subagent
- ✅ All review feedback addressed
- ✅ All tests and linting pass
- ✅ Logical commit history created
- ✅ PR created with Linear integration

The Linear issue will be automatically updated when the PR is merged, completing the full development lifecycle with comprehensive quality assurance.
