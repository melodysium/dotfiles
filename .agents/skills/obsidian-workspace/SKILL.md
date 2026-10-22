---
name: obsidian-workspace
description: How to collaborate with Melody through an Obsidian vault — writing question lists and working notes she can answer inline, deciding whether a vault subfolder deserves to be a jj repo and setting one up so Obsidian's auto-frontmatter plugins don't pollute it, diagnosing stray frontmatter timestamps, and handling Obsidian's silent link rewriting when a file in a repo-in-vault is renamed or moved. Consult when writing a question list or working notes for Melody, when creating or moving a folder or repo inside a vault, when frontmatter timestamps (dateCreated, dateModified, created, updated, datesModified) show up in `jj diff` / `git diff`, when an Obsidian plugin auto-modifies files in a repo, or when a file in a vault repo is renamed or moved. This skill is vault-independent; where her vaults live and how each is organized is in `~/.agents/AGENTS.local.md` (if present) and each vault's top-level `AGENTS.md`.
---

# Working with Melody through Obsidian

Melody reads and answers in Obsidian. Agents edit the same Markdown files from the CLI. The notes below come from working setups; treat them as working notes and re-check anything that looks off.

**Find the vault's own conventions first.** Vault location, layout, and naming live in `~/.agents/AGENTS.local.md` and the vault's top-level `AGENTS.md`, not here.

## Co-working through notes

Reach for a note in the vault instead of chat when the work has **lots of text for Melody to type or edit**: more than a few questions, a draft to review in rounds, a plan she wants to annotate.

- **Question lists:** write a numbered list in a note she can answer inline in Obsidian. This applies even when the current workspace is outside the vault.
- **Where:** wherever the vault's `AGENTS.md` says. If the vault has a per-task note convention and there's no note for this work, ask Melody why. She may be doing untracked, non-core work, and she'd want to notice that.
- **When the note is in a repo,** commit her answers as their own commit before acting on them.
- **Several review rounds on one note:** use numbered "Round N" question blocks, newest on top, with answered rounds kept below. `<!-- -->` comments can carry source notes that Obsidian's reading view hides. This worked well over four rounds on a long design-doc draft.

## Is this folder jj-tracked?

Check before assuming either way: `jj root` from inside the folder, or look for a `.jj/` directory up the tree. Most of a vault is usually **not** a repo; the vault root usually isn't one either.

## Should a new folder be a jj repo?

Consider it when the work will span **several files and several sessions**, and commit history and messages will be useful later (a long-running research or docs journal is the typical case). For one or two notes, plain Obsidian files (with their frontmatter) are lighter. Per global guidance, ask Melody before running `jj init`.

## Setting up a jj repo inside a vault

1. **Melody fully quits Obsidian (Cmd+Q)** before any agent edits plugin config. Confirm with `pgrep -x Obsidian`.
   - A running Obsidian overwrites `data.json` from memory and reverted an edit within minutes.
   - It also re-stamps frontmatter on any file write, and once truncated files mid-cleanup.
2. **Exclude the folder** in the vault's frontmatter plugins, under `<vault>/.obsidian/plugins/`. Use the vault-relative path. Back up `data.json` first.
   - "Update time on edit" (`update-time-on-edit`): `data.json` key `ignoreGlobalFolder` (array).
     - It matches with `path.startsWith(entry)`, so use no glob and no trailing slash.
     - The UI label is "Folder to exclude of all updates".
     - `ignoreCreatedFolder` only stops the created date.
   - "Update modified date" (`frontmatter-modified-date`): `data.json` key `excludedFolders` (array).
     - It matches with `startsWith(folder + "/")`.
     - The UI label is "Exclude folders".
3. **Melody relaunches Obsidian, edits and saves a file in the folder.** Then check `jj diff`: only her edit should appear.
4. **The Folder Notes plugin** may create `<folder-name>.md` in the folder. Commit it on purpose (or ignore it); it's noise for teammates who don't use Obsidian.

## Troubleshooting stray frontmatter

- **Find the writer.**
  - Note which keys appeared, then grep `.obsidian/plugins/*/main.js` for them and read each plugin's `data.json`.
  - Keys that match a plugin's **defaults** but not this vault's settings point to **another vault** reaching the folder through a symlink. `~/Library/Application Support/obsidian/obsidian.json` lists the vaults and which ones are open. That second vault's plugin settings need the same exclusion.
- **Strip only blocks made entirely of timestamp keys**, and only those absent from the parent commit. Do it with Obsidian closed. If files get damaged, recover them from the jj op log (`jj --at-op <id> file show`); if the working copy goes stale, run `jj workspace update-stale`.

## Renaming or moving files inside a repo

Renaming a file through Obsidian (UI, or the Obsidian CLI `move`) silently rewrites links to it elsewhere in the vault, and the rewritten links can be wrong for a repo.

- **What happens:** after a rename, links in other files of the repo came back as vault-root-relative paths (`[X.md](Folder/Sub/…/X.md)`). The originals were repo-relative (`notes/…`, `../notes/…`). The new paths break on the remote host's web UI and in any other clone. There is no prompt.
- **Cause (read from Obsidian's bundled `fileToLinktext`; the rename itself wasn't re-run):** `.obsidian/app.json` has `"alwaysUpdateLinks": true`, so link updates are silent. It sets no `newLinkFormat`, and the built-in default is `"shortest"` (UI: "Shortest path when possible"), so absent and explicit `"shortest"` behave the same. In `shortest` mode Obsidian writes the bare filename only if it's unique in the whole vault. Otherwise it writes the full vault-root path, so a filename that exists in two folders gets full paths.
- **Valid `newLinkFormat` values:** `"shortest"`, `"relative"` (relative to the linking file), `"absolute"` (vault-root path). Possible vault-wide changes in `.obsidian/app.json`: `newLinkFormat` `"relative"`, or `alwaysUpdateLinks` off. Writing `"shortest"` explicitly changes nothing. Whether to change them is Melody's call; check the vault's `AGENTS.md` for a standing decision before proposing it.
- **After any rename or move in a repo-in-vault,** run `jj diff --git` and look for added vault-root paths in link targets. Rewrite them to repo-relative, check each target exists, then commit the rename and the link fixes together.
- **Prevention is weak:** giving files vault-unique names makes `shortest` write a bare name. A bare name is still not repo-relative, so it won't link correctly on the remote host either. Checking `jj diff` after a rename remains the reliable guard.

## Other notes

- `.obsidian/` belongs to the vault. Don't commit plugin config into a project repo.
- `[[wiki-links]]` don't render on most git hosts. Use `[text](path.md)` in files teammates will read there.
- **Don't put `#` (or `|`, `^`, `[`, `]`) in note filenames.** Wikilinks reserve them for section, alias, block and nesting syntax, so `[[foo#123]]` breaks. Write `claude-code 95348`, not `claude-code#95348`. Keep the `#` in URLs and prose, just not in the filename or wikilink target. Grep for the old name after any rename, including scheduled-task prompts.
- After moving a repo into a vault, grep for stale old paths in docs and skills.
