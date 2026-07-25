# RULES

## Purpose

This file defines execution rules for the spec-driven development workflow in this repository.

## Core Principles

- Specs drive implementation.
- CURRENT defines the only active execution slice.
- Scope expansion must be explicit, never implicit.
- Validation and review are required before calling work complete.

## Control File Roles

- `SPEC.md` defines intent, scope, and acceptance.
- `ARCH.md` defines structure and boundaries.
- `TASKS.md` defines execution-ready backlog.
- `CURRENT.md` defines the one active slice.

## Scope Rules

- Do not implement beyond `CURRENT.md`.
- Do not modify architecture without reflecting it in `ARCH.md`.
- Do not treat `init_idea.md` as authoritative once spec files exist.
- If `CURRENT.md` is too large, split it before implementation.

## Change Discipline

- Prefer minimal changes.
- Keep edits within `Allowed Paths` in `CURRENT.md`.
- If an extra file must change, explain why in the execution report.
- Avoid broad refactors unless explicitly requested by the current slice.

## Validation Rules

- Run relevant tests, checks, or smoke validation before marking a slice complete.
- Never claim completion with failing validation.
- Do not remove or weaken tests just to make validation pass.

## Reporting Rules

Execution work should preserve:

- files changed
- tests/checks run
- result status
- open risks
- next recommended step

## Escalation Rules

Stop and update specs before continuing if:

- implementation needs a new architecture decision
- current tasking is too coarse
- acceptance criteria are not testable
- repo state conflicts with the declared current slice
