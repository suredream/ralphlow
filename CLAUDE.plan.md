## Purpose

This repository operates in **plan-planner mode**.

The goal is NOT to build systems or write code, but to:

- analyze project feasibility
- identify and track blockers
- define actionable next steps
- support decision-making (go / no-go / pivot)

---

## Multi-Project Structure

This directory manages multiple projects under `specs/`:

```
specs/
  RULES.md              ← workflow-level rules, shared across all projects
  PROJECTS.md           ← active project index
  <project-name>/       ← one subdirectory per project
    PROJECT.md
    FEASIBILITY.md
    BLOCKERS.md
    ACTIONS.md
    CURRENT_FOCUS.md
    REVIEW.json
    EXECUTION_READINESS.md
    EXECUTION_DECISION.md
  archive/              ← archived projects (completed or abandoned)
    <project-name>/
```

---

## Active Project

There is no global state file. The current project is determined per conversation.

### Declaring the active project

At the start of a conversation, declare which project you are working on:

- English: `project: <name>` (e.g. `project: alpha`)
- 中文：`项目：<name>`（如 `项目：alpha`）

Skills use this declaration automatically for the rest of the conversation.

### Project naming rules

- Allowed characters: lowercase letters, digits, hyphens (`a-z0-9-`)
- No spaces, no uppercase
- Max 32 characters
- Reserved: `archive` (cannot be used as a project name)
- Examples: `market-entry`, `saas-pivot`, `hardware-idea`

### Skill resolution priority

1. **Explicit parameter**: `/plan-eval alpha` → uses `alpha`, overrides declaration
2. **Conversation declaration**: uses the project declared at conversation start
3. **Fallback**: if neither is present, the skill must ask the user — do NOT assume

### Multiple agents

Each agent conversation declares its own project independently — no coordination needed. Two agents declaring different projects operate on different subdirectories with no conflict.

---

## Reading Order

Before doing meaningful work, read in this order:

### Workflow-level (always)
1. `CLAUDE.md`
2. `specs/RULES.md`
3. `specs/PROJECTS.md` ← identify active projects; confirm which project you are working on

### Project-level (substituting `<project>` with the active project name)
4. `specs/<project>/CURRENT_FOCUS.md`
5. `specs/<project>/PROJECT.md`
6. `specs/<project>/FEASIBILITY.md`
7. `specs/<project>/BLOCKERS.md`
8. `specs/<project>/ACTIONS.md`

Do NOT read files under `specs/archive/` unless explicitly asked.

---

## Mode Constraints

- DO NOT switch into code-building behavior
- DO NOT generate implementation-heavy output
- DO NOT assume execution readiness without explicit evaluation
- DO NOT operate on multiple projects in one loop unless explicitly instructed

---

## Primary Objectives per Loop

Each loop must achieve at least one:

- reduce uncertainty
- clarify a blocker
- improve feasibility assessment
- define a better next action
- refine project scope

---

## Expected Outputs

Each iteration should update one or more files under `specs/<project>/`:

- `FEASIBILITY.md`
- `BLOCKERS.md`
- `ACTIONS.md`
- `CURRENT_FOCUS.md`

---

## Archive Policy

Archive a project when:
- it is completed (Success Criteria met)
- it is abandoned (no-go decision)
- it has had no activity for 30+ days with no recovery plan
- it is merged into or replaced by another project

To archive:
1. `mv specs/<name>/ specs/archive/<name>/`
2. Update `specs/PROJECTS.md`: move the entry from Active to Archive, add reason and date.

---

## Available Commands

```
/plan-spec [project]     — initialize PROJECT.md from init_idea.md
/plan-eval [project]     — evaluate feasibility → FEASIBILITY.md
/plan-actions [project]  — define blockers and actions → BLOCKERS.md + ACTIONS.md
/plan-focus [project]    — set next iteration focus → CURRENT_FOCUS.md
/plan-review [project]   — review project state → REVIEW.json
/plan-ready [project]    — assess execution readiness → EXECUTION_READINESS.md
/plan-dp [project]       — make execution decision → EXECUTION_DECISION.md
```

`[project]` is optional. If omitted, the skill uses the project declared in the current conversation.

---

## Anti-Patterns

- vague analysis with no conclusion
- repeating existing content
- expanding scope instead of narrowing it
- producing actions without clear goals
- operating on a project without confirming which one is active

---

## Stop Conditions

Stop and refocus if:

- scope is too broad
- multiple unrelated questions are mixed
- blockers are not clearly defined
- actions are not executable
- active project is ambiguous
