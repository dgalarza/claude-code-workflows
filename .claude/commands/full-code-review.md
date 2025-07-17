# Full Code Review

Perform a comprehensive code review using parallel specialized subagents for security analysis and Rails best practices review. Incorporates previous review decisions to avoid redundant suggestions.

## Instructions

You will launch TWO specialized subagents in parallel using the Task tool for comprehensive coverage:

1. **Check Previous Decisions**:

   First, search memory for previous code review decisions and read the decision log:

   ```
   mcp__memory__search_nodes query:"code_review_decision"
   Read file: code_review_decisions.md
   ```

2. **Launch Parallel Subagents**:

   Use the Task tool to create TWO subagents simultaneously:

   **Subagent 1: Security Review Specialist**

   - **Get the diff**: Run `git diff main...HEAD` (or `git diff $ARGUMENTS...HEAD` if branch specified)
   - **Security Analysis Focus**:
     - Multi-tenant security (acts_as_tenant data segregation)
     - Control plane security for cross-tenant operations
     - Authentication and authorization vulnerabilities
     - Input validation and injection vulnerabilities
     - Sensitive data exposure and credential management
     - Rate limiting and access controls
     - OWASP Top 10 compliance
     - Rails-specific security patterns
   - **Return**: Detailed security findings with file:line references, categorized by severity (Critical, High, Medium, Low)

   **Subagent 2: Rails Best Practices Specialist**

   - **Get the diff**: Run `git diff main...HEAD` (or `git diff $ARGUMENTS...HEAD` if branch specified)
   - **Rails & Code Quality Focus**:
     - Rails conventions and RESTful design
     - POODR principles and object-oriented design
     - Service object patterns and Result usage
     - Ruby idioms and code clarity
     - Test quality and patterns (no SUT stubbing)
     - Performance considerations (N+1 queries, etc.)
     - Dependency management and coupling
   - **Return**: Detailed code quality findings with file:line references, categorized by priority (High, Medium, Low)

   **Both subagents should**:

   - Respect previous decisions from the decision log
   - Focus only on genuinely new concerns
   - Provide specific file and line references
   - Include code examples where helpful
   - Explain reasoning behind suggestions

3. **Consolidate Findings**:

   - Merge reports from both subagents
   - Organize findings by category and severity
   - Remove any duplicate concerns between reports
   - Highlight critical issues requiring immediate attention
   - Note positive aspects observed across both reviews

4. **Present Consolidated Report** to the user:

   - **Critical Security Issues** (immediate action required)
   - **High Priority Items** (should address soon)
   - **Medium Priority Items** (address in upcoming work)
   - **Low Priority Items** (consider for future improvements)
   - **Positive Observations** (what's working well)
   - **Overall Assessment** with prioritized action plan

5. **Update Decision Tracking**:

   For any new decisions made during the review:

   - Add to memory system with decision details
   - Update code_review_decisions.md file
   - Include rationale and context

6. **After user approval**: Write complete consolidated review to `code_review_feedback.md`, replacing existing contents

## Decision Tracking

This command maintains a log of review decisions to prevent redundant suggestions:

- **Memory System**: Stores decisions as `code_review_decision` entities
- **Decision Log**: `code_review_decisions.md` provides human-readable audit trail
- **Context Awareness**: Future reviews exclude previously decided items

## Usage

```
/full-code-review [branch-name]
```

If no branch specified, reviews changes from main to HEAD.

## Examples

```
/full-code-review
/full-code-review feature-branch
```

This command uses a subagent to perform thorough analysis while maintaining context of previous decisions to avoid review fatigue and focus on genuinely new concerns.
