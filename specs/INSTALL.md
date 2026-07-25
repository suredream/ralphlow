生成 install.sh 接受一个本地path 和一个mode, build, plan, write 为 参数，缺省为build

install.sh <install-path> <mode>


执行以下步骤：


mkdir -p <install-path>
git init
如果是 build，cp CLAUDE.md <install-path>
如果是 plan 或 write，cp 对应的 CLAUDE.md

复制对应的 skills 到 .claude/skills下
build 对应以下
build-arch
build-current
build-review
build-spec
build-tasks

plan 对应以下
plan-actions
plan-dp
plan-eval
plan-focus
plan-ready
plan-review
plan-spec
write 对应以下
write-draft
write-logic
write-review
write-spec
write-struct

执行 ralph-enable 命令