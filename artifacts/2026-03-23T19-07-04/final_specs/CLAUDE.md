# CLAUDE.md

使用中文进行交流和文档输出

## Project Operating Model

This repository uses a control-plane driven workflow.

Core source documents live in `specs/`:

- `specs/SPEC.md` — product/system intent, scope, acceptance
- `specs/ARCH.md` — architecture, boundaries, trade-offs
- `specs/TASKS.md` — executable implementation backlog
- `specs/RULES.md` — development process rules
- `specs/CURRENT.md` — the single active execution slice

Raw ideation starts in:

- `init_idea.md`

## Mandatory Reading Order

Before making meaningful changes, read in this order:

1. `CLAUDE.md`
2. `specs/RULES.md`
3. `specs/CURRENT.md`
4. `specs/SPEC.md`
5. `specs/ARCH.md`
6. `specs/TASKS.md`

If some of these files do not exist yet, create or update them using the repo skills instead of improvising.

## Non-Negotiable Working Rules

- Do not expand scope beyond `specs/CURRENT.md`.
- Do not treat `init_idea.md` as executable spec.
- Do not implement large features before `SPEC.md`, `ARCH.md`, and `TASKS.md` exist.
- Prefer updating control files first, then code.
- If requirements changed, update `SPEC.md`, `ARCH.md`, `TASKS.md`, and `CURRENT.md` before continuing implementation.
- Do not silently modify architecture without reflecting it in `specs/ARCH.md`.
- Do not mark work complete if validation fails.

## Execution Flow

1. Refine idea in `init_idea.md`
2. Use skills to create/update spec files
3. Run `scripts/sync_to_ralph.sh`
4. Let Ralph execute current slice
5. Run validation/review scripts
6. Update spec files before the next slice if needed

## When Writing Or Updating Specs

- Keep each file focused on its purpose.
- Avoid leaking implementation steps into `SPEC.md`.
- Avoid turning `ARCH.md` into a task list.
- Avoid oversized tasks in `TASKS.md`.
- `CURRENT.md` must represent one small, verifiable slice only.

## Evidence Discipline

When implementation work happens, preserve enough evidence for later review:

- changed files
- tests run
- open risks
- next recommended step
