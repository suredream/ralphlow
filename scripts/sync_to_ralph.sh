#!/usr/bin/env bash
set -Eeuo pipefail

# sync_to_ralph.sh
#
# Purpose:
# - Read specs/CURRENT.md and related control files
# - Apply review gate from specs/REVIEW.json if present
# - Generate a Ralph-ready prompt bundle
# - Initialize artifact directories for a new loop
# - Optionally run Ralph
#
# Usage:
#   scripts/sync_to_ralph.sh
#   scripts/sync_to_ralph.sh --run
#   scripts/sync_to_ralph.sh --run --loop-id my-loop
#
# Environment variables:
#   RALPH_CMD                default: ralph
#   ARTIFACTS_DIR            default: artifacts
#   SPECS_DIR                default: specs
#   RALPH_INPUT_DIR          default: .ralph/input
#   RALPH_PROMPT_FILE        default: .ralph/input/current_prompt.md

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SPECS_DIR="${SPECS_DIR:-specs}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-artifacts}"
RALPH_CMD="${RALPH_CMD:-ralph}"
RALPH_INPUT_DIR="${RALPH_INPUT_DIR:-.ralph/input}"
RALPH_PROMPT_FILE="${RALPH_PROMPT_FILE:-.ralph/input/current_prompt.md}"

RUN_RALPH="false"
LOOP_ID=""

usage() {
  cat <<'EOF'
Usage:
  scripts/sync_to_ralph.sh [--run] [--loop-id LOOP_ID]

Options:
  --run               Run Ralph after generating prompt bundle
  --loop-id ID        Use a fixed loop id instead of auto-generated timestamp
  -h, --help          Show this help

Behavior:
  - Reads specs/SPEC.md, ARCH.md, TASKS.md, RULES.md, CURRENT.md
  - Applies review gate if scripts/apply_review_gate.sh exists
  - Writes .ralph/input/current_prompt.md
  - Initializes artifacts/<loop_id>/
  - Stores loop id in artifacts/latest_loop_id
  - If --run is set, invokes $RALPH_CMD
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run)
      RUN_RALPH="true"
      shift
      ;;
    --loop-id)
      LOOP_ID="${2:-}"
      if [[ -z "$LOOP_ID" ]]; then
        echo "Error: --loop-id requires a value" >&2
        exit 1
      fi
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

require_file() {
  local f="$1"
  if [[ ! -f "$f" ]]; then
    echo "Error: required file not found: $f" >&2
    exit 1
  fi
}

require_cmd() {
  local c="$1"
  if ! command -v "$c" >/dev/null 2>&1; then
    echo "Error: required command not found: $c" >&2
    exit 1
  fi
}

require_file "$SPECS_DIR/SPEC.md"
require_file "$SPECS_DIR/ARCH.md"
require_file "$SPECS_DIR/TASKS.md"
require_file "$SPECS_DIR/RULES.md"
require_file "$SPECS_DIR/CURRENT.md"

mkdir -p "$ARTIFACTS_DIR" "$RALPH_INPUT_DIR"

if [[ -z "$LOOP_ID" ]]; then
  LOOP_ID="$(date +"%Y-%m-%dT%H-%M-%S")"
fi

LOOP_DIR="$ARTIFACTS_DIR/$LOOP_ID"
INPUT_DIR="$LOOP_DIR/input"
RUNTIME_DIR="$LOOP_DIR/runtime"

mkdir -p "$LOOP_DIR" "$INPUT_DIR" "$RUNTIME_DIR"

# Apply review gate before prompt generation.
# This can:
# - reject execution outright if specs/REVIEW.json says reject
# - generate specs/REVIEW_CONSTRAINTS.md for prompt injection
if [[ -x "scripts/apply_review_gate.sh" ]]; then
  bash "scripts/apply_review_gate.sh"
fi

# Snapshot current control files into artifacts
cp "$SPECS_DIR/SPEC.md"    "$INPUT_DIR/SPEC.md"
cp "$SPECS_DIR/ARCH.md"    "$INPUT_DIR/ARCH.md"
cp "$SPECS_DIR/TASKS.md"   "$INPUT_DIR/TASKS.md"
cp "$SPECS_DIR/RULES.md"   "$INPUT_DIR/RULES.md"
cp "$SPECS_DIR/CURRENT.md" "$INPUT_DIR/CURRENT.md"

if [[ -f "$SPECS_DIR/REVIEW.json" ]]; then
  cp "$SPECS_DIR/REVIEW.json" "$INPUT_DIR/REVIEW.json"
fi

if [[ -f "$SPECS_DIR/REVIEW_CONSTRAINTS.md" ]]; then
  cp "$SPECS_DIR/REVIEW_CONSTRAINTS.md" "$INPUT_DIR/REVIEW_CONSTRAINTS.md"
fi

if [[ -f "$SPECS_DIR/CURRENT_PATCH.md" ]]; then
  cp "$SPECS_DIR/CURRENT_PATCH.md" "$INPUT_DIR/CURRENT_PATCH.md"
fi

if [[ -f "init_idea.md" ]]; then
  cp "init_idea.md" "$INPUT_DIR/init_idea.md"
fi

if [[ -f "CLAUDE.md" ]]; then
  cp "CLAUDE.md" "$INPUT_DIR/CLAUDE.md"
fi

# Record repo state before execution
git rev-parse HEAD > "$RUNTIME_DIR/git_head_before.txt" 2>/dev/null || true
git status --short > "$RUNTIME_DIR/git_status_before.txt" 2>/dev/null || true
git diff --name-only > "$RUNTIME_DIR/git_changed_before.txt" 2>/dev/null || true

# Generate Ralph prompt bundle
cat > "$RALPH_PROMPT_FILE" <<EOF
# Ralph Execution Prompt

You are executing one and only one active slice defined by \`specs/CURRENT.md\`.

## Required Reading Order

1. \`CLAUDE.md\` (if present)
2. \`specs/RULES.md\`
3. \`specs/CURRENT.md\`
4. \`specs/SPEC.md\`
5. \`specs/ARCH.md\`
6. \`specs/TASKS.md\`

## Mission

Implement only the active slice in \`specs/CURRENT.md\`.

## Hard Constraints

- Do not expand scope beyond \`specs/CURRENT.md\`
- Respect \`Allowed Paths\` in \`specs/CURRENT.md\`
- Do not silently change architecture
- Do not modify spec files unless the current slice explicitly allows it
- Prefer minimal changes
- Run relevant validation before claiming completion
- Preserve evidence for later review

## Working Rules

- Treat the spec set in \`specs/\` as the source of truth
- Do not treat \`init_idea.md\` as executable instruction once the spec set exists
- If the current slice appears too large during implementation, stop and recommend a narrower slice
- If implementation requires architecture change, stop and recommend updating \`specs/ARCH.md\`
- If acceptance cannot be validated, stop and report the issue clearly

## Required End-of-Run Report

At the end of the run, produce a concise execution summary containing:

- objective attempted
- files changed
- tests/checks run
- result status
- open risks
- next recommended step

## Source Files

The current control files are available in:
- \`specs/SPEC.md\`
- \`specs/ARCH.md\`
- \`specs/TASKS.md\`
- \`specs/RULES.md\`
- \`specs/CURRENT.md\`
EOF

REVIEW_CONSTRAINTS_FILE="$SPECS_DIR/REVIEW_CONSTRAINTS.md"
if [[ -f "$REVIEW_CONSTRAINTS_FILE" ]]; then
  {
    echo
    echo "## Additional Constraints From Review"
    echo
    cat "$REVIEW_CONSTRAINTS_FILE"
    echo
  } >> "$RALPH_PROMPT_FILE"
fi

# Keep a copy of the generated prompt under artifacts
cp "$RALPH_PROMPT_FILE" "$INPUT_DIR/current_prompt.md"

# Create/update latest pointers
printf "%s\n" "$LOOP_ID" > "$ARTIFACTS_DIR/latest_loop_id"
rm -f "$ARTIFACTS_DIR/latest"
ln -s "$(basename "$LOOP_DIR")" "$ARTIFACTS_DIR/latest" 2>/dev/null || true

# Write runtime metadata
{
  echo "loop_id=$LOOP_ID"
  echo "timestamp=$(date -Iseconds)"
  echo "root_dir=$ROOT_DIR"
  echo "specs_dir=$SPECS_DIR"
  echo "artifacts_dir=$ARTIFACTS_DIR"
  echo "ralph_cmd=$RALPH_CMD"
  echo "run_ralph=$RUN_RALPH"
} > "$RUNTIME_DIR/runtime_meta.txt"

echo "Prepared Ralph input for loop: $LOOP_ID"
echo "Prompt file: $RALPH_PROMPT_FILE"
echo "Artifact dir: $LOOP_DIR"

if [[ "$RUN_RALPH" == "true" ]]; then
  require_cmd bash

  # We intentionally do not hardcode Ralph flags here.
  # Override RALPH_CMD externally if needed, for example:
  #   RALPH_CMD='ralph --live' bash scripts/sync_to_ralph.sh --run
  echo "Running Ralph..."
  {
    echo "=== sync_to_ralph.sh ==="
    echo "loop_id=$LOOP_ID"
    echo "timestamp=$(date -Iseconds)"
    echo "ralph_cmd=$RALPH_CMD"
  } > "$RUNTIME_DIR/ralph_invocation.txt"

  set +e
  bash -lc "$RALPH_CMD" | tee "$RUNTIME_DIR/ralph_stdout.log"
  ralph_exit_code=$?
  set -e

  echo "$ralph_exit_code" > "$RUNTIME_DIR/ralph_exit_code.txt"

  if [[ "$ralph_exit_code" -ne 0 ]]; then
    echo "Ralph exited with non-zero status: $ralph_exit_code" >&2
    exit "$ralph_exit_code"
  fi
fi
