# CURRENT

## Slice ID

T2a-rev — 将 build-* skills 移入 builder/ 子目录

## Objective

将 `.claude/skills/` 根目录下现有的五个 builder skill 目录（`build-arch`、`build-current`、`build-review`、`build-spec`、`build-tasks`）移入 `.claude/skills/builder/` 子目录。使目录结构与 ARCH.md 和 SPEC.md 中定义的 `.claude/skills/<workflow>/` 规范一致，为安装器（T1）提供正确的源路径。

> 背景说明：原 CURRENT 记录的是移动 `get-*` 系列 skill，但实际代码库中这些 skill 已被重命名为 `build-*` 格式，因此本 slice 以当前实际状态为准。

## Why Now

`.claude/skills/` 根目录下已有五个命名规范的 builder skill（`build-arch`、`build-current`、`build-review`、`build-spec`、`build-tasks`），但它们未放入 `builder/` 子目录。安装器（T1）需要从 `.claude/skills/builder/` 复制文件。此结构问题不修复，T1 安装器无法按 ARCH 定义的路径正确运行。

## In Scope

- 创建 `.claude/skills/builder/` 目录
- 将以下五个目录从 `.claude/skills/` 移至 `.claude/skills/builder/`：
  - `build-arch/`
  - `build-current/`
  - `build-review/`
  - `build-spec/`
  - `build-tasks/`
- 各目录内的 `SKILL.md` 文件内容不做任何修改

## Out of Scope

- 修改任何 `SKILL.md` 文件的内容
- 新建 builder 的 `CLAUDE.md` 模板（留给 T2b）
- 创建 planner 或 writer bundle（T3、T4）
- 修改 `.claude/skills/shared/`
- 实现安装器脚本（T1）
- 修改 `specs/` 下任何文件（本文件除外）
- 修改根目录 `CLAUDE.md`

## Allowed Paths

- `.claude/skills/builder/build-arch/SKILL.md`（从根目录移入）
- `.claude/skills/builder/build-current/SKILL.md`（从根目录移入）
- `.claude/skills/builder/build-review/SKILL.md`（从根目录移入）
- `.claude/skills/builder/build-spec/SKILL.md`（从根目录移入）
- `.claude/skills/builder/build-tasks/SKILL.md`（从根目录移入）

> 注意：移动操作同时删除 `.claude/skills/<skill-name>/` 根目录下的旧目录，这是预期行为。

## Constraints

- 只移动，不修改文件内容
- 移动后 `.claude/skills/` 根目录下不应残留 `build-arch`、`build-current`、`build-review`、`build-spec`、`build-tasks` 目录
- 不影响 `.claude/skills/shared/`

## Acceptance

- [ ] `.claude/skills/builder/` 目录存在
- [ ] `.claude/skills/builder/` 下恰好有五个子目录：`build-arch`、`build-current`、`build-review`、`build-spec`、`build-tasks`
- [ ] 五个目录各含 `SKILL.md`，内容与移动前一致（未被修改）
- [ ] `.claude/skills/` 根目录下不再存在上述五个 skill 目录（已移走）
- [ ] `.claude/skills/shared/` 不受影响，`README.md` 仍存在

## Required Evidence

- `ls .claude/skills/` 输出：只剩 `builder/` 和 `shared/`
- `ls .claude/skills/builder/` 输出：五个 skill 目录
- 任意一个 `SKILL.md` 的首行 `name:` 字段内容，确认文件完整未损

## Stop Conditions

- 若移动操作导致任何 `SKILL.md` 内容丢失，立即停止并回滚
- 若 `.claude/skills/` 下存在除五个 builder skill 和 `shared/` 之外的其他目录，停止并上报（不要移动未知内容）
- 若需要更新 ARCH.md 中的路径定义才能继续，停止并先更新 ARCH.md

## Next Likely Slice

T2b — 为五个 builder skill 的 `SKILL.md` 顶部确认单句用途注释格式，并新建 builder 的 `CLAUDE.md` 模板文件
