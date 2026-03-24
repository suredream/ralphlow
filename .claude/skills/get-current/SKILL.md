---
name: get-current
description: Generate or revise specs/CURRENT.md from specs/TASKS.md and specs/RULES.md. Use when one next slice must be selected for execution and tightly scoped for Ralph or another agent loop.
---

# Make CURRENT

Create the single active execution slice in `specs/CURRENT.md`.

## Goal

Select exactly one small, verifiable next slice from `specs/TASKS.md` and express it as an execution contract.

## Inputs

Required:

- `specs/TASKS.md`

Recommended:

- `specs/RULES.md`
- `specs/SPEC.md`
- `specs/ARCH.md`

Optional:

- current repo state
- recent implementation evidence
- prior `specs/CURRENT.md`

## Output

- `specs/CURRENT.md`

## What CURRENT.md must contain

Use this structure unless there is a strong reason not to:

```md
# CURRENT

## Slice ID

## Objective

## Why Now

## In Scope

## Out of Scope

## Allowed Paths

## Constraints

## Acceptance

## Required Evidence

## Stop Conditions

## Next Likely Slice
````

## Rules

* Pick one slice only.
* The slice must be smaller than the parent task if needed.
* `Out of Scope` must be explicit.
* `Allowed Paths` should be as narrow as possible.
* Acceptance must be concrete.
* Required evidence must support later review.
* If the next task is too large, split it before writing CURRENT.
* Favor slices that unblock later work while staying easy to verify.

## Required evidence examples

Use whichever are appropriate:

* changed-files.txt
* git diff summary
* test output
* lint/typecheck output
* short implementation report
* known risks / follow-up notes

## Stop conditions examples

Include execution boundaries such as:

* if implementation requires architecture change, stop and update `specs/ARCH.md`
* if work exceeds allowed paths materially, stop and revise CURRENT
* if acceptance cannot be validated, stop and revise tasking

## Workflow

1. Read `specs/TASKS.md`.
2. Read `specs/RULES.md`.
3. Review current repo state if useful.
4. Select the smallest meaningful next slice.
5. Constrain scope aggressively.
6. Define acceptance and evidence.
7. Write or revise `specs/CURRENT.md`.

## Anti-patterns

Do not:

* select multiple tasks at once
* write a broad feature instead of a slice
* leave `Allowed Paths` empty unless truly unavoidable
* omit `Out of Scope`
* create a CURRENT that cannot be reviewed afterwards

## Example trigger phrases

* "pick the next slice"
* "generate CURRENT"
* "make current execution contract"
* "prepare next Ralph slice"

## Completion checklist

Before finishing, verify:

* `specs/CURRENT.md` exists
* only one slice is selected
* allowed paths are constrained
* out-of-scope is explicit
* acceptance and required evidence are specific
