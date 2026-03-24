# ralphlow

**ralphlow** is an installer for AI-native workflows powered by [Claude Code](https://claude.ai/code) and [Ralph](https://github.com/anthropics/ralph). It provisions a project directory with the right skills, CLAUDE.md, and Ralph configuration for three distinct modes of work: **build**, **plan**, and **write**.

---

## How it works

Each workflow installs a set of Claude Code skills into `.claude/skills/` and drops the matching `CLAUDE.md` into the project root. Ralph is then enabled to run execution loops guided by those skills and files.

```
install.sh <install-path> [build|plan|write]
```

**Default mode:** `build`

---

## Workflows

### build

For spec-driven software development. Claude Code maintains a control plane of spec files; Ralph executes one tightly scoped slice at a time.

**Loop:**
```
init_idea.md
  → /build-spec       (SPEC.md)
  → /build-arch       (ARCH.md)
  → /build-tasks      (TASKS.md)
  → /build-current    (CURRENT.md — one slice)
  → /build-review     (REVIEW.json — gate check)
  → ralph             (executes current slice)
  → repeat
```

**Skills installed:**

| Skill | Purpose |
|---|---|
| `/build-spec` | Generate or revise `specs/SPEC.md` from `init_idea.md` |
| `/build-arch` | Generate or revise `specs/ARCH.md` from `SPEC.md` |
| `/build-tasks` | Generate or revise `specs/TASKS.md` from `SPEC.md` + `ARCH.md` |
| `/build-current` | Select and scope the next execution slice into `CURRENT.md` |
| `/build-review` | Review all spec files and produce `REVIEW.json` for execution gating |

**Core files (`specs/`):**
- `SPEC.md` — product intent, scope, acceptance criteria
- `ARCH.md` — architecture, boundaries, trade-offs
- `TASKS.md` — implementation backlog
- `RULES.md` — execution process rules
- `CURRENT.md` — the single active slice

---

### plan

For project feasibility analysis and decision support. No code is written — the goal is to reduce uncertainty, clarify blockers, and define executable next steps.

**Loop:**
```
init_idea.md
  → /plan-spec        (PROJECT.md)
  → /plan-eval        (FEASIBILITY.md)
  → /plan-actions     (ACTIONS.md, BLOCKERS.md)
  → /plan-focus       (CURRENT_FOCUS.md)
  → /plan-ready       (readiness assessment)
  → /plan-dp          (execution decision)
  → /plan-review      (REVIEW.json)
  → repeat or hand off to build
```

**Skills installed:**

| Skill | Purpose |
|---|---|
| `/plan-spec` | Convert an initial idea into a structured `PROJECT.md` |
| `/plan-eval` | Evaluate feasibility of the project |
| `/plan-actions` | Convert feasibility insights into concrete actions and blockers |
| `/plan-focus` | Define the next iteration focus |
| `/plan-ready` | Assess whether the project is ready to move into execution |
| `/plan-dp` | Produce a concrete execution decision with strict constraints |
| `/plan-review` | Evaluate current project state and produce `REVIEW.json` |

**Core files:**
- `PROJECT.md` — project definition and scope
- `FEASIBILITY.md` — feasibility assessment
- `BLOCKERS.md` — active blockers
- `ACTIONS.md` — next executable actions
- `CURRENT_FOCUS.md` — active iteration focus

---

### write

For producing structured written content (articles, long-form pieces, opinion writing). The loop refines a single idea into a polished draft.

**Loop:**
```
idea
  → /write-spec       (CONTENT_SPEC.md)
  → /write-struct     (STRUCTURE.md)
  → /write-draft      (DRAFT.md)
  → /write-logic      (improve argument flow)
  → /write-review     (evaluate quality and readiness)
  → repeat
```

**Skills installed:**

| Skill | Purpose |
|---|---|
| `/write-spec` | Convert an idea into a structured content specification |
| `/write-struct` | Convert a spec into a content structure |
| `/write-draft` | Generate an initial draft based on structure |
| `/write-logic` | Improve logical flow and argument clarity |
| `/write-review` | Evaluate content quality and readiness |

**Core files:**
- `CONTENT_SPEC.md` — content intent and constraints
- `STRUCTURE.md` — section-level outline
- `DRAFT.md` — working draft
- `CURRENT.md` — active focus (paragraph or section level)

---

## Installation

```bash
# Install into a new or existing directory
./install.sh ~/projects/my-app build
./install.sh ~/projects/my-plan plan
./install.sh ~/projects/my-article write
```

The script:
1. Creates the target directory if absent
2. Runs `git init` (idempotent)
3. Copies the matching `CLAUDE.md` as the project root `CLAUDE.md`
4. Copies the workflow's skills into `.claude/skills/`
5. Runs `ralph-enable` to configure the Ralph loop

---

## Key principles (all modes)

- **One slice at a time.** Never execute beyond `CURRENT.md` (or `CURRENT_FOCUS.md`).
- **Specs before code.** Requirements change → update the spec first, then implement.
- **Every step is verifiable.** Acceptance criteria must be concrete and checkable.
- **No silent scope expansion.** All deviations must be explicit and recorded.
