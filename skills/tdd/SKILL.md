---
name: tdd
description: Use this skill when implementing or changing behavior with test-driven development. Follow red-green-refactor one behavior at a time, confirm a real failure before writing production code, and keep the test command the project's own.
---

# Test-Driven Development

Implement behavior one failing test at a time. The cycle is red, green, refactor. Do not write the production code for a behavior before a test has failed for that behavior, and do not start the next behavior until the current one is green and cleaned up.

This skill is agent-neutral. It does not install hooks, slash commands, or a required subagent. Run the project's existing test command from the current agent.

## When to use

Use this skill when:

- Adding a feature, bugfix, or behavior change that can be expressed as an executable check
- The user asks for TDD, red-green-refactor, or "test first"
- A change is small enough to slice into separately verifiable behaviors

Skip the cycle only when the user explicitly asks for a spike or a non-behavioral change (formatting, comments, generated files). Say that the cycle was skipped and why.

## Before the first test

1. Read the repository instructions (`AGENTS.md`, `CLAUDE.md`, or the equivalent) and find the test command. Prefer a documented command over guessing.
2. If no command is documented, detect it from the project: task runner scripts, `Makefile`, `pytest` / `go test` / `cargo test` / `mvn test` / `gradle test` / `phpunit` / `bin/rspec`, or the language's usual runner. Run the narrowest command that executes one example or one file.
3. Run the existing suite, or the relevant subset, once. If it is already red, stop and report that. Do not stack new work on a broken baseline unless the user asks to fix that baseline first.
4. Name the next behavior in one sentence: the input, the observable output, and the boundary that makes it the smallest next step.

If the test command cannot be found or cannot be executed, stop and say so. Do not claim a cycle completed without a run.

## The cycle

Repeat until the requested behavior is complete. Each iteration covers exactly one behavior.

### 1. Red

Write the smallest test that expresses the next behavior and nothing else.

- One new example, case, or assertion. Do not scaffold the rest of the file "while here."
- Assert on observable behavior (return value, state change, response, emitted event), not on private structure.
- Use the project's existing test style. Match names, fixtures, and helpers already in the tree.

Run that test alone when the runner allows it.

The test must fail, and it must fail because the behavior is missing or wrong — not because of a typo, a missing import, a wrong path, or a setup error. Read the failure. If the failure is not the expected one, fix the test and run it again before writing production code.

If the new test passes immediately, the behavior already exists or the test does not exercise it. Do not treat that as success. Adjust the test or choose a behavior that is not already covered, then re-run until the failure is real.

### 2. Green

Write the minimum production code that makes this test pass. Do not implement the next behavior, the general case, or "what we'll need later."

Hard-coding a single return value is acceptable when it is the smallest change that turns this test green. The following test is what forces the code to become general.

Run the same test again. It must pass. If it fails, change the production code or correct a bad test — do not weaken the assertion to hide a real miss. Then run the relevant surrounding tests to confirm the change did not break an existing behavior.

### 3. Refactor

Only refactor while the tests are green.

- Remove duplication introduced by the last green step.
- Rename for the domain language already used in the code.
- Leave behavior unchanged. A refactor that needs a new test is a new behavior; stop and start another red step.

Run the same tests again after refactoring. If they fail, undo the refactor or fix it before continuing. Do not begin the next behavior on a red suite.

## Slicing work

Keep a short list of behaviors, ordered so each test teaches one new fact. Typical order:

1. The simplest happy path
2. The next variation that forces the hard-coded branch to become real logic
3. Boundaries (empty, zero, one, limits)
4. Failure and error paths the caller can actually hit

Do not write that list as a finished test file. Track it as a plan, then turn one item into a test at a time.

Prefer several small cycles over one test that asserts an entire feature. A cycle that touches many files is a signal to slice again.

## Rules

- Never write a full test file up front and then implement against it.
- Never implement more than the current failing test requires.
- Never delete or skip a failing test to get to green.
- Never change a test and the production code in the same step unless the test itself was wrong (bad assertion, wrong setup). When the test was wrong, return to red and show the corrected failure before continuing.
- Keep tests deterministic. No sleeps, no order dependence, no hidden network calls unless the project already uses a fake or fixture for that dependency.
- Leave the suite green at the end of every cycle, including the last one.

## Done

The work is done when every requested behavior has been through red, green, and refactor, the tests that cover those behaviors pass, and the relevant existing suite still passes. Summarize the behaviors added and the command used to run them. Do not claim coverage that was not executed.
