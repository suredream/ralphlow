#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Usage: $0 <install-path> [build|plan|write]"
    echo "  install-path  Target directory (will be created if absent)"
    echo "  mode          Workflow type: build (default), plan, or write"
    exit 1
}

# Args
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    usage
fi

INSTALL_PATH="$1"
MODE="${2:-build}"

case "$MODE" in
    build|plan|write) ;;
    *) echo "Error: mode must be build, plan, or write (got: $MODE)"; usage ;;
esac

# Skills per mode
build_skills="build-arch build-current build-review build-spec build-tasks"
plan_skills="plan-actions plan-dp plan-eval plan-focus plan-ready plan-review plan-spec"
write_skills="write-draft write-logic write-review write-spec write-struct"

case "$MODE" in
    build) SKILLS="$build_skills" ;;
    plan)  SKILLS="$plan_skills" ;;
    write) SKILLS="$write_skills" ;;
esac

# Setup target
mkdir -p "$INSTALL_PATH"
cd "$INSTALL_PATH"

if [ ! -d ".git" ]; then
    git init
fi

# Copy CLAUDE.md
case "$MODE" in
    build) cp "$SCRIPT_DIR/CLAUDE.md" ./CLAUDE.md ;;
    plan)  cp "$SCRIPT_DIR/CLAUDE.plan.md" ./CLAUDE.md ;;
    write) cp "$SCRIPT_DIR/CLAUDE.write.md" ./CLAUDE.md ;;
esac

# Copy skills
mkdir -p ".claude/skills"
for skill in $SKILLS; do
    src="$SCRIPT_DIR/.claude/skills/$skill"
    if [ ! -d "$src" ]; then
        echo "Error: skill directory not found: $src"
        exit 1
    fi
    cp -r "$src" ".claude/skills/$skill"
done

# Copy workflow index template
case "$MODE" in
    plan)
        mkdir -p "specs"
        cp "$SCRIPT_DIR/specs/PROJECTS.md" "specs/PROJECTS.md"
        ;;
    write)
        mkdir -p "content"
        cp "$SCRIPT_DIR/content/PROJECTS.md" "content/PROJECTS.md"
        ;;
esac

# Enable Ralph
ralph-enable

echo "Installed ralphlow ($MODE) into: $INSTALL_PATH"
