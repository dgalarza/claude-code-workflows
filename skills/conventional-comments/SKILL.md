---
name: conventional-comments
description: Use this skill when writing, rewriting, or reviewing feedback comments so they follow the Conventional Comments format.
---

# Conventional Comments

Use this skill when feedback needs to be clear, reviewable, and easy to scan. It is useful for code review, document review, design feedback, RFC comments, editing notes, and any other feedback thread where tone and actionability matter.

Source standard: https://conventionalcomments.org/

## Core Format

Write each comment in this shape:

```text
<label> [decorations]: <subject>

[discussion]
```

- `label` is one intent label, such as `suggestion`, `issue`, or `question`.
- `decorations` are optional comma-separated context tags in parentheses.
- `subject` is the direct comment.
- `discussion` is optional supporting context, reasoning, or next step.

Examples:

```text
suggestion: Rename this helper to match the domain term used in the rest of the module.

That makes the call sites easier to connect back to the product copy.
```

```text
issue (blocking): This branch returns a 200 response when validation fails.

Could we return the existing validation error response here so clients can recover correctly?
```

## Label Selection

Choose the narrowest accurate label:

| Label | Use when |
| --- | --- |
| `praise` | Calling out something genuinely good or worth preserving. |
| `nitpick` | Requesting a trivial preference-based change. Usually non-blocking. |
| `suggestion` | Proposing an improvement. Explain what to change and why. |
| `issue` | Identifying a concrete problem. Pair with a suggested fix when possible. |
| `todo` | Flagging a small necessary task. |
| `question` | Asking for clarification because the concern is uncertain. |
| `thought` | Sharing a related idea that should not block the work. |
| `chore` | Requesting a process step required before acceptance. Link the process when possible. |
| `note` | Highlighting useful context with no requested action. |

Optional expressive labels can be used if they are clearer in context:

| Label | Use when |
| --- | --- |
| `typo` | Fixing spelling or small text mistakes. |
| `polish` | Improving quality when nothing is strictly wrong. |
| `quibble` | Calling out a very small preference without implying importance. |

## Decorations

Use decorations only when they add useful context.

Common decorations:

| Decoration | Meaning |
| --- | --- |
| `(blocking)` | The work should not be accepted until this is resolved. |
| `(non-blocking)` | The work can be accepted without resolving this first. |
| `(if-minor)` | Resolve only if the fix is small or trivial. |

Domain decorations can clarify scope, such as `(security)`, `(test)`, `(ux)`, `(performance)`, `(docs)`, or `(accessibility)`. Keep decoration lists short. If the list gets long, split the feedback into separate comments.

## Workflow

1. Identify the review intent before writing the comment.
2. Choose one label that best matches the intent.
3. Add a decoration only if it changes how the author should prioritize or interpret the comment.
4. Write the subject as a concrete, complete sentence.
5. Add discussion only when it explains why the comment matters or how to resolve it.
6. For `issue`, `suggestion`, `chore`, and `todo`, make the expected action explicit.
7. For uncertain concerns, use `question` instead of overstating the problem.

## Tone Rules

- Be direct about the requested change.
- Separate preference from correctness.
- Avoid vague subjects like "This is wrong" or "Fix this."
- Avoid performative praise. Use `praise` only when it is specific and true.
- Prefer one actionable comment over several loosely related concerns.

## Output Patterns

For a single comment, return only the comment:

```text
suggestion (test): Add coverage for the empty input case.

That is the branch most likely to regress because it exits before the normalization step.
```

For a batch of comments, group them as a list:

```markdown
- issue (blocking): The migration drops `account_id` before the backfill runs.

  Could we split this into a backfill migration and a later cleanup migration?

- note: This parser now matches the API contract more closely.
```

For Codex inline code review, use the conventional comment text in the `title` or `body` of the code comment, while keeping the comment tied to the smallest useful line range.

## Quality Bar

Before returning comments, check that:

- Each comment starts with `<label>:` or `<label> (<decorations>):`.
- Each label matches the actual intent.
- Blocking status is explicit when priority could be misunderstood.
- The subject can stand alone without the discussion.
- The discussion adds reasoning, context, or a next step.
- The comment asks for a concrete action when action is expected.
