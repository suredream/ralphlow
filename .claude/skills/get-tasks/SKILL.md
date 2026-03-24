---
name: get-tasks
description: Generate or revise specs/TASKS.md from specs/SPEC.md and specs/ARCH.md. Use when requirements and architecture exist but the implementation backlog is too vague, too large, or not execution-ready.
---

# ARCH to TASKS

Convert `specs/SPEC.md` and `specs/ARCH.md` into a small, executable, verifiable task backlog.

## Goal

Produce a `specs/TASKS.md` that decomposes the work into:

- small implementation slices
- explicit dependencies when needed
- clear acceptance conditions
- a progression from enabling work to user-visible closure

## Inputs

Required:

- `specs/SPEC.md`
- `specs/ARCH.md`

Optional:

- `specs/TASKS.md`
- current codebase
- `specs/RULES.md`

## Output

- `specs/TASKS.md`

## What TASKS.md must contain

Use this structure unless there is a strong reason not to:

```md
# TASKS

## Tasking Principles

## Task List

### T1 - <task title>
- Goal
- Why it exists
- Scope
- Dependencies
- Acceptance
- Notes / Risks

### T2 - <task title>
...
````

## Rules

* Break work into the smallest units that still produce a meaningful result.
* Prefer vertical slices over vague layer-based buckets.
* Avoid tasks like "build backend", "implement frontend", or "finish integration".
* Every task must be reviewable and testable.
* Every task should have a clear goal and acceptance.
* Keep dependencies explicit but lightweight.
* Preserve useful existing tasks if they are still valid.
* Order tasks in a way that supports incremental execution.

## Task sizing guidance

A good task:

* has one primary purpose
* changes a limited part of the system
* can be validated with tests, inspection, or a smoke run
* does not require broad repo-wide refactors
* is understandable without reading the whole project history

## Workflow

1. Read `specs/SPEC.md`.
2. Read `specs/ARCH.md`.
3. Read existing `specs/TASKS.md` if present.
4. Identify the minimum path from architecture to working behavior.
5. Decompose work into small tasks.
6. Ensure each task has explicit acceptance.
7. Order tasks sensibly.
8. Write or revise `specs/TASKS.md`.

## Anti-patterns

Do not:

* create giant tasks
* create purely organizational tasks with no acceptance
* create task lists that are only directory-based
* hide architecture decisions inside tasks
* use "misc cleanup" as a real task unless tightly scoped

## Example trigger phrases

* "break architecture into tasks"
* "generate TASKS.md"
* "make this implementation-ready"
* "split this into execution slices"

## Completion checklist

Before finishing, verify:

* `specs/TASKS.md` exists
* each task has Goal and Acceptance
* tasks are small enough for iterative execution
* dependencies are clear enough
* the list supports gradual delivery
