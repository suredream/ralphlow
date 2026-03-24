# CURRENT

## Slice ID

T5 — 创建 shared skills 目录结构

## Objective

在 `.claude/skills/shared/` 下建立目录结构，并写入 `README.md` 说明 shared skills 的用途约定。使安装器（T1）在后续实现时能找到可复制的 shared/ 源目录。

## Why Now

T5 无依赖，体量最小（仅新建目录和一个文件），完成后立即解锁 T2、T3、T4 的并行执行，以及 T1 安装器的端到端验收。是整个任务链的第一块基石。

## In Scope

- 创建目录 `.claude/skills/shared/`
- 在该目录下创建 `README.md`，内容包含：
  - shared skills 的定义（什么情况下放入 shared/）
  - 命名规范（与 builder/planner/writer 保持 `<verb>-<domain>` 一致）
  - v1 声明（当前为空，结构占位）
  - 添加哪类 skill 的判断标准（跨 workflow 通用、无领域特化）

## Out of Scope

- 向 `shared/` 添加任何实际 skill 文件（v1 明确为空）
- 修改 builder、planner、writer 的任何现有文件
- 实现安装器逻辑
- 修改 `specs/` 下的任何控制文档（除本文件外）
- 修改 `CLAUDE.md`

## Allowed Paths

- `.claude/skills/shared/README.md`（新建）

## Constraints

- `README.md` 必须用中文写作（项目规范）
- 不引入任何可执行文件或脚本
- 不创建除 `README.md` 以外的文件（`.gitkeep` 不需要，`README.md` 已保证目录不为空）

## Acceptance

- [ ] `.claude/skills/shared/` 目录存在
- [ ] `.claude/skills/shared/README.md` 文件存在
- [ ] `README.md` 包含 shared skills 的定义说明
- [ ] `README.md` 包含命名规范（`<verb>-<domain>`）
- [ ] `README.md` 包含 v1 占位声明（当前无实际 skill）
- [ ] `README.md` 包含判断标准（何时将 skill 放入 shared/）
- [ ] 变更文件数 = 1（仅 `README.md`，CURRENT.md 不计入）

## Required Evidence

- `changed-files.txt`：仅包含 `.claude/skills/shared/README.md`
- `README.md` 内容截图或文本摘要，确认四项内容均已覆盖

## Stop Conditions

- 若发现 `.claude/skills/shared/` 已存在且有内容，停止并上报，不覆盖现有内容
- 若 README.md 需要引用安装器的具体行为（如路径格式），而安装器逻辑尚不确定，停止并记录为 open risk，不猜测

## Next Likely Slice

T2 — 补全 builder workflow bundle 结构（检查五个 builder skill 是否存在且合规，新建 builder 的 CLAUDE.md 模板）
