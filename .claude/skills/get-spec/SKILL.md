---
name: get-spec
description: Generate or revise specs/SPEC.md from init_idea.md. Use when raw idea notes exist but the executable specification is missing, weak, outdated, or inconsistent.
---

# Init Idea to SPEC

Convert `init_idea.md` into a high-quality `specs/SPEC.md`.

## Goal

Produce a clear specification that defines:

- the problem to solve
- intended user or operator flow
- scope boundaries
- non-goals
- acceptance criteria
- key assumptions and risks when needed

## Inputs

Primary input:

- `init_idea.md`

Optional supporting inputs if present:

- `specs/SPEC.md`
- `specs/ARCH.md`
- `specs/TASKS.md`
- `specs/RULES.md`
- existing codebase context

## Outputs

Primary output:

- `specs/SPEC.md`

You may revise an existing `specs/SPEC.md` instead of recreating it.

## What SPEC.md must contain

Use this structure unless there is a strong reason not to:

```md
# SPEC

## Title

## Goal

## Problem Statement

## Intended Users / Operators

## User or System Flow

## In Scope

## Out of Scope

## Functional Requirements

## Non-Functional Requirements

## Acceptance Criteria

## Assumptions

## Open Questions
````

## Rules

* Treat `init_idea.md` as raw material, not as the final truth.
* Infer structure, but do not invent major requirements without labeling them.
* Keep implementation details out of `SPEC.md` unless they are true constraints.
* Do not turn the spec into architecture prose.
* Prefer testable acceptance criteria.
* Explicitly separate "in scope" and "out of scope".
* If an existing `specs/SPEC.md` exists, preserve good content and improve weak sections.
* If requirements are ambiguous, record the ambiguity under `Open Questions` instead of pretending certainty.

## Required quality bar

A good `SPEC.md`:

* is readable by both a product-minded person and an engineer
* explains what success looks like
* avoids tool-specific implementation choices unless required
* can later drive architecture and task breakdown

## Workflow

1. Read `init_idea.md`.
2. Read existing `specs/SPEC.md` if present.
3. Extract the core system objective.
4. Identify user-visible flows or operator flows.
5. Separate scope from non-scope.
6. Rewrite requirements into crisp, testable form.
7. Add assumptions and open questions where the source is incomplete.
8. Write or update `specs/SPEC.md`.

## Anti-patterns

Do not:

* write "build the backend" as a requirement
* specify tables, classes, frameworks, or modules unless the idea explicitly requires them
* hide uncertainty
* turn `Acceptance Criteria` into vague statements like "works well"

## Example trigger phrases

* "turn init idea into spec"
* "generate SPEC from my notes"
* "clean up requirements"
* "make this executable as a spec"

## Completion checklist

Before finishing, verify:

* `specs/SPEC.md` exists
* scope and out-of-scope are explicit
* acceptance criteria are concrete
* implementation detail is minimal
* open questions are captured instead of guessed away
