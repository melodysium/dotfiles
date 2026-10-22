#!/bin/bash
set -euo pipefail

REPO="$CLAUDE_PROJECT_DIR"
INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r .name)
WORKTREE_PATH=$(echo "$INPUT" | jq -r .worktree_path)

if jj -R "$REPO" root >/dev/null 2>&1; then
  jj -R "$REPO" workspace forget "$NAME" >&2 || true
  rm -rf "$WORKTREE_PATH"
else
  git -C "$REPO" worktree remove "$WORKTREE_PATH"
fi
