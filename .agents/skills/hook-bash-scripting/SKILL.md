---
name: hook-bash-scripting
description: Style guidance for a Claude Code hook's bash `command` in settings.json — when to extract it to a script file and how to reference it. Consult when authoring or editing a PreToolUse/PostToolUse/etc. hook whose bash command is more than a trivial one-liner (multiple conditionals or pipeline stages).
---

- If a hook's bash command needs more than ~1 conditional or pipeline stage, extract it to `~/.claude/hooks/<name>.sh` and reference it from settings.json as `"command": "bash /absolute/path/to/script.sh"`, instead of inlining a long JSON-escaped one-liner.
- Reference via `bash <path>` explicitly rather than relying on the executable bit + shebang alone — avoids failures if permissions don't survive a copy/sync.
- Favor early-exit guard clauses (`[ condition ] || exit 0`) over nested `if` blocks — reads top-to-bottom.
- Before wiring a hook into settings.json, pipe-test it with a synthesized JSON payload on stdin matching the hook event shape (see `update-config` skill's verification steps) — test both the "should fire" and "should no-op" cases.
