---
name: manage-dotfiles-repo
description: Sort, commit, and push changes to Melody's yadm-managed dotfiles repo across its branches and remotes — triage modified and untracked files, commit each change on the right branch, rebase extension branches onto main, scan for private details, and push to the right remotes. Manual only; invoke as /manage-dotfiles-repo, or when Melody asks to commit, sync, or upstream her dotfiles.
disable-model-invocation: true
---

# Managing the dotfiles repo

Read this when Melody wants her dotfiles changes sorted, committed, and pushed. It is a **checkpointed workflow with her**, not an autonomous cleanup: triage and pushes are her calls.

## Ground rules

- **yadm is plain git here.** Use `yadm <git command>` for everything in this repo, including state-changing ones. This overrides the global "use `jj`" rule for this repo only (jj's commit-everything model doesn't suit a `$HOME` work tree; yadm's staged-on-request model does).
- **Never switch branches in `$HOME`.** The work tree *is* `$HOME`: checking out another branch deletes every file only the old branch tracks (shell config, scripts), breaking live shells and tools mid-session. Make commits on other branches with `scripts/commit-to-branch`, or in a scratch `git worktree` outside `$HOME`.
- **The public remote must never receive private details**: Melody's surname, her employer's internal names/hosts/URLs/ticket IDs, credentials. Section "Keep private details out" is mandatory before any push to it.
- **Push by explicit remote and branch.** Never `--all`, `--mirror`, `--tags`, or a multi-URL "push everywhere" remote (one such remote existed and was deleted: a single wrong push to it would have published the work branch publicly).
- **Back up before rewriting history**: `yadm tag backup/<yyyy-mm-dd>-<branch> <branch>` for each branch you will move. Local tags only; never push them. Delete once she's happy.
- **Check in rather than decide** on anything ambiguous: where a change belongs, whether something is private, whether to force-push.

## What to verify first (don't assume)

```bash
yadm status; yadm branch -vv; yadm remote -v
yadm fetch <remote>          # each remote by name; tracking refs go stale
yadm ls-remote --heads <remote>   # ground truth for what each remote has
```

- **Branches:** `main` is the shared base. Every other branch is an *extension* of main for one context (work, personal). Extension branches are kept as small as possible and rebased onto `main`.
- **Remotes:** each remote receives `main` plus its own extension branch(es), nothing else. The public remote gets `main` and the personal branch only. Which branch and remote are which (names, URLs) is private: see `~/.agents/AGENTS.local.md`. If it's not there, ask Melody.
- **Identity:** commits use the public identity in `~/.config/yadm/config`, which yadm injects. Plain `git --git-dir=…` and plumbing commands do **not**, and would author commits with her global identity. Always check `git log --format='%an <%ae>'` on new commits.

## Where a change belongs

| Change | Goes to |
|---|---|
| Useful on any machine, nothing private | `main` |
| Only meaningful for one context (work tooling, work skills, personal packages) | that extension branch, as a **new file** |
| Mixed: a generic edit entangled with a private one | split it: generic part to `main`, private part to the extension branch |
| A tracked-on-main file that needs private content | **genericize it** on `main`, put the private part in a new file on the extension branch |
| Secrets, caches, history, installer-managed files, generated or borrowed files | the exclude list (below), never a branch |

- **Prefer new files over edits to shared files on extension branches.** Edits conflict on every rebase and tend to leak back. Give `main` a hook that loads an optional `*.local` file (see `.config/yadm/bootstrap` for `bootstrap.local`, and the `.zshrc.local` / `.gitconfig.local` pattern), then put context-specific content in that file on the extension branch.
- **Skills and docs on `main` are generic only.** Use "work ticket" and "wiki page", not product or employer names. Context-specific guidance goes in a skill that exists only on the extension branch, or in `~/.agents/AGENTS.local.md`.
- Home-directory dotfiles that tools create (`~/.zprofile`, `~/.zshrc`, …) while `ZDOTDIR` points elsewhere are a smell: the shell never reads them. De-duplicate against what's in `$ZDOTDIR`, then keep, adapt, or drop what remains.

## Workflow

### 1. Preflight
Run the verification block above. Note which branch is checked out (the others can only be committed to via plumbing or a worktree) and whether any branch needs a rebase onto `main`.

### 2. Survey
```bash
yadm status                       # modified tracked files
yadm diff --stat                  # size of each change
~/.agents/skills/manage-dotfiles-repo/scripts/sweep-untracked   # open decisions among untracked files
```
`sweep-untracked` lists only dotfile-ish places and only what is neither tracked nor in the exclude list, so **its output is exactly the set that needs a decision**. Also look at untracked files *inside* tracked dirs: `yadm ls-files --others --exclude-standard -- <dir>`. Read each diff and each new file; don't triage from names.

### 3. Triage with Melody (checkpoint)
Present a table: each change → `main` / extension branch / exclude / drop, with a one-line reason, plus a recommendation for each ambiguous one. For a new script in `~/.local/bin`, check whether it is hand-written (commit) or installer-managed (exclude). Look for secrets before suggesting any commit (mask when printing). Wait for answers.

### 4. Commit to `main`
Commit **one atomic change per commit**, Conventional Commits style: `<type>: <summary>` (types per the global AGENTS.md; no ticket ID, dotfiles have none), plus the session's attribution trailer.

```bash
export DOTFILES_COMMIT_TRAILER='<attribution line from the session>'
scripts/commit-to-branch main "feat: add foo abbreviation" .config/zsh-abbr/user-abbreviations
```

- Splitting one file's changes into several commits: build each intermediate blob with `git apply --cached <patch>` on a throwaway `GIT_INDEX_FILE`, then pass `<path>=<blobsha>`. Verify that the final blob equals the work-tree file.
- Only commit the work tree's content to `main` when the file is identical on `main` and the checked-out branch at HEAD, otherwise you will commit the other branch's edits. Check with `yadm rev-parse main:<path> HEAD:<path>`.

### 5. Commit to the extension branch(es)
For each extension branch, in a scratch worktree outside `$HOME`:
```bash
git --git-dir=$HOME/.local/share/yadm/repo.git worktree add -b tmp-<branch> <scratch>/wt-<branch> <branch>
cd <scratch>/wt-<branch> && git rebase main     # skip a commit that duplicates one already on main
# copy files in from $HOME, then:  git add … && git commit …
```
- Set the public identity (`GIT_AUTHOR_*` / `GIT_COMMITTER_*`) and `SKIP_TICKET_HOOK=1` (the repo's prepare-commit-msg hook prefixes ticket IDs from branch names; dotfiles don't use them).
- A rebase conflict is information: read it. A commit duplicated across branches with different hashes usually conflicts; check whether main's copy is the intended one and `git rebase --skip`. (Once, an old unresolved conflict had been committed with `<<<<<<<` markers; grep the tree for markers after any rebase: `git grep -nE '^(<<<<<<<|>>>>>>>) ' HEAD`.)
- When done, move the branch and sync the index without touching the work tree. In `$HOME`, with the extension branch checked out: `yadm reset <tmp-branch tip>` (mixed). Then `yadm status` should show only what you *meant* to leave uncommitted. Remove the worktree: `git worktree remove` and `git branch -D tmp-<branch>`.
- If the work tree holds the **old** version of a file whose bad version you just replaced (like the marker case), restore it deliberately with `yadm checkout -- <file>` and tell Melody.

### 6. Keep private details out
Before any push to the public remote, run the scan on every branch it will receive:
```bash
scripts/leak-scan main <personal-branch>                  # full history: surfaces pre-existing leaks too
scripts/leak-scan --since <remote>/<branch> <branch>      # only what's about to be pushed
```
The patterns live in `~/.config/yadm/leak-patterns` (private; exists only on the work branch). If it's missing, ask Melody for the patterns; don't guess. Also confirm authors with `git log --format='%h %an <%ae>' <remote>/<branch>..<branch>`. Any hit blocks the push until Melody decides: fix going forward, or rewrite history (her call; it changes every hash after the leak).

### 7. Push (checkpoint)
Show the plan first: remote, branch, old → new hash, and whether it is a force push. Rebased branches need Melody's standing form:
```bash
yadm push --force-with-lease --force-if-includes <remote> <branch>
```
`main` goes to every remote; each extension branch only to its own. Fast-forward pushes need no force flags. Afterwards `yadm ls-remote --heads <remote>` should show the new hashes.

### 8. Wrap up
Report what landed where (hashes, remotes), what's still uncommitted or undecided, and anything surprising. Mention the backup tags so she can delete them.

## The machine-local exclude list

`~/.local/share/yadm/repo.git/info/exclude` is git's native per-repo ignore file: untracked, never pushed, read automatically. Convention:

- An entry means "**reviewed, decided not to commit**", grouped under a comment that says why and when. Don't add things just to quiet the sweep; undecided items stay unlisted so `sweep-untracked` keeps showing them.
- Name installer-managed files in `~/.local/bin` individually. A wildcard would hide the new hand-written scripts the sweep exists to catch.
- It's lost with the machine, which is fine: rebuilding it is rerunning the sweep and re-deciding. Its header comment points back here.
- `yadm status` hides untracked files by default, so the exclude list only affects `sweep-untracked`, `ls-files --others`, and `git add` of a directory.

## Scripts

- `scripts/commit-to-branch <branch> "<subject>" <path | path=blobsha>...`: commit to a branch that isn't checked out, using a throwaway index. Uses the public identity and refuses if it matches a leak pattern.
- `scripts/leak-scan [--since <rev>] <ref>...`: scan file contents, paths, authors, messages, and diffs for private patterns.
- `scripts/sweep-untracked`: list untracked, un-excluded dotfile candidates. Edit `SWEEP_ROOTS` in it when a new tool starts keeping hand-written config somewhere new.
