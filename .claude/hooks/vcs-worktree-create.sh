#!/bin/bash
set -euo pipefail

REPO="$CLAUDE_PROJECT_DIR"
INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r .name)
BASE_REF=$(echo "$INPUT" | jq -r .base_ref)

if jj -R "$REPO" root >/dev/null 2>&1; then
  REPO_NAME=$(basename "$REPO")
  DIR="$HOME/.claude/jj-worktrees/$REPO_NAME/$NAME"
  mkdir -p "$(dirname "$DIR")"
  jj -R "$REPO" workspace add "$DIR" --name "$NAME" >&2
  echo "$DIR"
else
  DIR="$REPO/.claude/worktrees/$NAME"
  mkdir -p "$(dirname "$DIR")"
  git -C "$REPO" worktree add "$DIR" -b "worktree-$NAME" "$BASE_REF" >&2
  echo "$DIR"
fi
