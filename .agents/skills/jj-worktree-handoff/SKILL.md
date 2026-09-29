---
name: jj-worktree-handoff
description: >-
  TEMPORARY workaround skill. Writes a self-contained task prompt to a file
  and hands back the exact `claude --worktree <slug>` terminal command to run
  it, so a task can be forked out of a Claude Code Desktop session into a
  properly jj-aware (or git-aware) isolated worktree. Manual-invoke only -
  Claude should never trigger this on its own.
disable-model-invocation: true
---

# jj-worktree handoff (temporary)

## Why this exists

Claude Code Desktop's in-session worktree creation (the `EnterWorktree` tool - used by
Desktop's "Worktree" toggle, or any mid-session "work in a worktree" request) ignores the
`WorktreeCreate`/`WorktreeRemove` hooks configured in `~/.claude/settings.json`. Those hooks
run `~/.claude/hooks/vcs-worktree-create.sh` / `vcs-worktree-remove.sh`, which detect whether
the current repo is jj-managed (`jj -R "$CLAUDE_PROJECT_DIR" root`) and either:

- create a real `jj workspace` (for jj repos, outside the repo tree so Claude Code's own
  git-metadata safety check doesn't refuse it), or
- fall back to a plain `git worktree add` matching Claude Code's own default naming (for
  everything else).

Only the terminal CLI flag `claude --worktree <name>` actually dispatches those hooks today.
This is tracked upstream as
[anthropics/claude-code#36205](https://github.com/anthropics/claude-code/issues/36205)
(duplicate: [#57209](https://github.com/anthropics/claude-code/issues/57209)), which a weekly
scheduled task (`check-jj-worktree-hook-bug`) is watching for a fix.

**Delete this skill, `~/.claude/hooks/vcs-worktree-create.sh`, `~/.claude/hooks/vcs-worktree-remove.sh`,
and the `WorktreeCreate`/`WorktreeRemove` entries in `~/.claude/settings.json` once #36205 is
fixed and Desktop's own worktree toggle dispatches hooks correctly** - at that point this
whole detour is unnecessary.

## Arguments

`$ARGUMENTS` - the task to hand off, in whatever form the user gives it (a short instruction,
or "fork what we just discussed").

## Workflow

1. **Distill a slug.** Pick a short kebab-case identifier for the task, e.g.
   `fix-contact-merge-race`. This becomes the worktree name, the branch name
   (`worktree-<slug>` for git repos), and the handoff filename. If nothing obvious fits, ask.

2. **Write a fully self-contained prompt.** The new `claude --worktree` process starts cold,
   with no memory of this conversation. Write everything it needs - repo path if not obvious,
   relevant file paths, what "done" looks like, any constraints the user stated in this
   session - to `~/.claude/handoff-tasks/<slug>.md`. Don't write "as discussed above" or
   similar; a fresh reader must be able to act on it alone.

3. **Hand back the exact command.** Print it as a single ready-to-copy shell command:

   ```bash
   claude --worktree <slug> -p "$(cat ~/.claude/handoff-tasks/<slug>.md)"
   ```

   Run it from a terminal, from the main checkout of the target repo (not from inside any
   existing worktree).

4. **Don't run it yourself.** This skill only prepares the handoff file and command - the user
   runs the command in their own terminal. Do not attempt to invoke `claude --worktree` via
   the Bash tool from within this session.

5. **Mention cleanup.** When the CLI session finishes normally, Claude Code's own exit-cleanup
   flow calls the `WorktreeRemove` hook, which runs `jj workspace forget`/`git worktree remove`
   as appropriate. If the CLI session is killed or abandoned instead, the workspace/worktree is
   left in place for manual cleanup (`jj workspace forget <slug>` from the main checkout for jj
   repos, or `git worktree remove .claude/worktrees/<slug>` for git repos).
