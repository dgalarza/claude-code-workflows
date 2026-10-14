---
name: team-code-review
description: Review an agent's own code changes or another contributor's pull request by dispatching specialist agents, verifying every finding, and reporting only evidence-backed issues. Use when the user asks for a code review, PR review, review of a diff, or a multi-agent quality audit.
---

# Team Code Review

Run a read-only, static, evidence-driven code review with specialist agents. The main agent owns scope, verification, deduplication, severity, editorial judgment, and the final report. Evidence comes from reading code, not executing it: the review does not run tests, linters, type checkers, or builds — CI owns that feedback loop.

## 1. Establish the review target

Determine whether the target is:

- **Own work:** changes produced by the current agent or agent team.
- **Another contributor's pull request:** a PR authored outside the current agent team.

Read the repository instructions first. Identify the exact review base and head, then inspect the complete diff and relevant surrounding code. Do not silently broaden the review to unrelated working-tree changes. If authorship is unclear, infer it from the conversation and PR metadata when available; ask only when the answer changes the workflow and cannot be discovered.

Detect the application stack from repository evidence such as dependency manifests, framework configuration, and directory structure. Load any matching review profile before dispatching specialists. For a Rails application, read [references/rails.md](references/rails.md) and incorporate its applicable checks into the specialist assignments. Treat profiles as opinionated investigation guidance, not automatic findings; explicit repository instructions and documented architectural decisions take precedence.

Record explicit non-goals and constraints. Keep the review read-only unless the user separately asks for fixes.

Completion criterion: the review target, authorship branch, base/head, repository guidance, changed files, application stack, and applicable review profiles are known.

## 2. Dispatch the review team

Use subagents when the runtime supports them. Give each specialist the same target, base/head, repository instructions, and read-only constraint. Assign non-overlapping primary lenses:

1. **Architecture and code quality** — assess whether responsibilities and abstractions are coherent; identify duplication or misplaced behavior; check for appropriate API clients, service objects, collaborators, boundaries, and reuse without demanding abstractions that the code does not yet need.
2. **Readability** — assess naming, control flow, local complexity, consistency, error handling, and whether intent is easy to recover from the code.
3. **Testing** — trace each changed behavior to meaningful coverage, including success and failure paths, boundary cases, regressions, and integration points. For HTTP behavior, check request construction, headers/authentication, serialization, response parsing, relevant status codes, malformed responses, timeouts, retries/idempotency where applicable, and network failures. Prefer behavioral tests over implementation-coupled assertions.
4. **Maintainability** — assess coupling, extension cost, dependency direction, operational burden, compatibility, observability, and likely future failure modes.
5. **Security** — trace trust boundaries and data flow; assess authentication, authorization, validation, injection, secret exposure, sensitive logging, dependency risk, unsafe defaults, and failure behavior. Do not inflate hypothetical risks beyond what the code supports.
6. **Documentation** — check public interfaces, setup/configuration, migrations, operational changes, examples, changelog/release notes, and repository architecture or runbook documentation affected by the change.

Ask every specialist to return only actionable findings with:

- severity, likelihood, and confidence;
- exact file and tight line range;
- the concrete failure mode or maintenance cost;
- the specific conditions that trigger it, and evidence that a real caller, input, configuration, or schedule can produce those conditions;
- evidence from the diff and relevant surrounding code;
- the reasoning path that validates the claim, grounded in the cited code;
- a concise remediation direction.

Every candidate must pass a reachability test before a specialist reports it. Name what has to be true for the failure to happen, then look for the upstream guard that makes it impossible: validation, database constraint, type signature, route, authorization check, feature flag, caller contract, or the fact that no caller passes that shape. If such a guard exists, there is no finding — drop it rather than reporting it with a hedge. A specialist whose own explanation concedes the path cannot be hit has written a note to itself, not a review comment.

Specialists must also omit praise, style preferences without impact, speculative concerns, defensive handling for states the system already prevents, and hardening, abstraction, error handling, or test coverage beyond what this change demonstrably needs. Findings outside the changed code belong in the review only when the change directly activates them. Three findings the author will act on beat ten the author will dismiss; an empty return is a legitimate result.

They inspect code, tests, and repository context statically and must not run tests, linters, type checkers, builds, or other checks — CI already produces that signal and duplicating it wastes review time and budget. Reading existing CI output is fine when directly relevant. They must not edit files or publish review comments.

Run specialists concurrently when capacity allows; batch them when it does not. The main agent must retain enough context and time to verify their work.

Completion criterion: every lens has been investigated and each specialist has either returned candidate findings or explicitly reported no actionable findings.

## 3. Verify every candidate finding

The main agent must independently verify every candidate before reporting it:

1. Open the cited lines and enough surrounding code to understand the execution path.
2. Confirm the issue is introduced by or materially exposed by the target diff.
3. Try to kill the finding. Search callers, shared abstractions, tests, validations, constraints, configuration, generated-code boundaries, and documentation for anything that already prevents the failure. Verification is an attempt to disprove the claim, not to dress it up; a candidate that survives a genuine attempt to invalidate it has earned its place.
4. Validate with a concrete reasoning path from the diff to the failure mode, grounded in the opened code and traced callers. Do not execute tests, linters, or builds to confirm a finding; run something only when the user explicitly asked for runtime verification.
5. Establish who actually hits this and how often, then calibrate severity to impact times likelihood. Likelihood bounds severity: a failure that needs conditions the system does not produce is not a blocker, and is usually not a finding at all. Drop it rather than reporting it at reduced severity.
6. Merge duplicates across specialists and discard unverified, speculative, or non-actionable items.

Do not report a specialist's claim merely because it sounds plausible. The main agent is accountable for every final finding, including the cost of a false one: findings that turn out to be unreachable teach the author to stop reading the review.

Completion criterion: every reported finding has independently checked evidence, an accurate location, a realistic trigger path, a defensible severity, and a concrete impact; every rejected candidate is omitted.

## 4. Apply editorial judgment before reporting

Verification proves a finding is true. It does not prove the finding is worth the author's attention. Before anything reaches the user or a pull request, the main agent reviews the surviving set as a whole and cuts.

Ask of each survivor: would a thoughtful author change this code because of it? If the honest answer is no, remove it. Specifically, cut:

- findings whose realistic trigger conditions are rare enough that the author would reasonably defer them, unless the impact when they do occur is severe;
- restatements of a tradeoff the author clearly made on purpose, where the review simply prefers the other side;
- "consider" and "you may want to" items with no demonstrated cost attached;
- theoretical robustness, extensibility, and coverage gaps that no planned or likely change would exercise;
- anything that survives only because of how it is worded. A finding that needs a hedge such as "unlikely in practice, but" has already answered the question — drop it.

Then judge the set, not just the items. A long list against a small diff means the bar drifted during the review; re-apply it rather than presenting the volume. Separate what should block from what is optional, and do not let a stack of minor items bury the one finding that matters. Never pad a report to look thorough, and never inflate severity to make a finding feel worth writing. Reporting two real problems and saying the rest of the change looks sound is a stronger review than listing eight.

A clean or near-clean review is a legitimate outcome. Say so plainly rather than reaching for something to report.

Completion criterion: every remaining finding is one the main agent would defend to the author in person, blocking and non-blocking items are distinguished, and the cut items are gone rather than softened.

## 5. Report the review

Lead with findings ordered by severity, then confidence. For each finding include:

- a short imperative title;
- severity;
- file and tight line range;
- why it matters in this specific code path, including what has to happen for it to trigger and how likely that is in real use;
- the smallest useful remediation direction.

Then include:

- a concise overall assessment;
- that verification was static — findings rest on code reading and reasoning — plus any uncertainty that introduces;
- remaining risks or coverage gaps;
- a brief note when no actionable findings were verified.

For **own work**, report the findings directly. Do not fix them unless the user asked for implementation.

For **another contributor's pull request**, provide the verified summary first, then ask whether the user wants a pull request review drafted on their behalf. Do not draft or publish the review before they agree.

If the user agrees to a PR review draft, invoke the `conventional-comments` skill and translate only the verified findings into Conventional Comments. Draft first; publish only with explicit authorization. Preserve severity, precise locations, and the distinction between blocking and non-blocking feedback.

A published comment carries a higher bar than a terminal report: it spends another person's attention, stays on the record, and is read as the user's own judgment. Apply the cut from step 4 again, harder. Post as blocking only what genuinely should block the merge; fold the remaining non-blocking observations into the summary comment or leave them out. If that second pass empties the list, say so and offer an approving or neutral summary instead of manufacturing inline comments.

## Review standard

- Review the change in repository context, not as isolated snippets.
- Execution belongs to CI: review by reading code and tests, not by running them. Consult existing CI results when they are relevant evidence.
- Prefer concrete defects and material design costs over taste.
- Every finding must answer: what breaks, for whom, and how often. A finding that cannot answer the third question is not ready to report.
- Do not ask for defensive code against states the system already prevents, error handling for errors the dependency does not raise, or configurability, abstraction, and validation the change has not shown it needs. Resilience the code does not need is a cost, not a safeguard.
- Judge the change against the standard the repository actually holds itself to, not an idealized one. A pattern the codebase consistently uses is the baseline; deviating from it is the finding, matching it is not.
- Do not confuse missing tests with a proven production defect; describe the actual coverage risk.
- Do not require a pattern such as an API client or service object by name. Recommend it only when it resolves demonstrated duplication, coupling, inconsistency, or testability problems.
- Under-reporting a marginal issue costs less than a review the author learns to discount. When a finding is genuinely borderline, leave it out.
- A clean review is valid when all six lenses were investigated and no candidate survived verification.
