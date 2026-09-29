---
name: learn-from-session
description: >-
  Capture session learnings and propose durable improvements for future agents
  and developers. Proposes changes in chat for user review before writing any
  files. Prioritizes docs, skills, CLAUDE.md entries, and tips. Use when the
  user asks to learn from a session, distill takeaways, improve future agent
  behavior, or wrap up with "what should we remember."
disable-model-invocation: true
---

# Learn from Session Outcomes

Let's take what we learned in this session and make some improvements for future agents and humans.

> **CRITICAL — Propose first, write only after approval**
>
> The first response **MUST** be a chat proposal only. Do **not** create, edit, or delete docs, skills, CLAUDE.md entries, hooks, or other durable artifacts in the same turn.
> Wait for Melody to review, revise, or approve specific items. Implement **only** what she explicitly OKs — and only in a follow-up turn.
>
> Note: this is a separate, deliberate workflow from this agent's own auto-memory system (which silently captures narrow, user-taught corrections as it goes). This skill covers the whole session's arc and every artifact type below, and always surfaces proposals in chat first — don't treat auto-memory writes made earlier in the session as already having covered this step.

## Workflow

1. **Review the session** — Re-read the conversation arc: what was tried, what failed, what surprised us, what worked, and what context was missing or wrong.
2. **Extract candidate learnings** — List only items that would help a *future* agent or developer in a similar situation. Drop one-off trivia, session-specific IDs, and conclusions that depend on unverified assumptions.
3. **Stress-test each candidate** — Apply the [Constraints](#constraints) below. If a learning might be broadly applicable, pause and ask whether it truly generalizes or is worth writing down.
4. **Propose outputs in priority order** — For each surviving learning, pick the highest-priority artifact type that fits. Prefer one small change over several overlapping ones. Present everything using the [Proposal format](#proposal-format) below.
5. **Stop and ask** — End with a clear ask: which proposals (if any) should be implemented, and any edits to the drafts. If none look worth codifying, say so and offer tips-only takeaways instead.
6. **Implement approved items only** — In a **later** turn, after explicit approval, apply changes. Re-show final text if the user edited drafts in chat.

## Output priority (in order of preference)

Consider updating or adding these:

1. **Docs** — For info that can help other devs (README sections, `docs/`, Confluence links, inline code comments only when the code itself is the doc).
2. **Skills** — For contextual AI behaviors (multi-step workflows, tool/MCP usage, domain procedures). Personal skills live under `~/.claude/skills/<name>/SKILL.md`; use the `anthropic-skills:skill-creator` skill to scaffold or refine one.
3. **CLAUDE.md entries** — For global or repo-wide AI behaviors. Global preferences go in `~/.claude/CLAUDE.md`; repo-specific ones go in that repo's own `CLAUDE.md`. Claude Code has no per-glob rule scoping like Cursor's `alwaysApply`/`globs` — the nearest equivalent to a narrowly-scoped rule is a directory-scoped skill (see `Skill` tool docs) or a project-level `CLAUDE.md` section, rather than a global one.
4. **Tips for the user** — Just shared in chat; use when the learning is personal preference, situational judgment, or not yet ready to codify. If a tip is itself durable + applicable + legible *and* traces back to something Melody explicitly taught or corrected (not just an observation this agent made on its own), it may also be a candidate for a memory file under the auto-memory directory — flag that possibility but don't write it without the same explicit approval as any other artifact here.
5. **Other misc.** — Hooks, MCP config, sub-agents, steering docs, etc. Use the `update-config` skill for hooks/settings.json changes.

When multiple types could apply, prefer the *narrowest* durable form (e.g. a directory-scoped skill or repo `CLAUDE.md` section over the global `~/.claude/CLAUDE.md`; a skill over a `CLAUDE.md` entry).

## Constraints

These apply to every proposed or written artifact:

- **MUST** avoid overly generalized assertions from this particular session's topic. While it's sometimes correct to apply a specific learning in a broad context, take some extra thought in such cases to confirm whether it's so broadly applicable (or even worth writing down).
- **MUST** consider learnings as "work-in-progress" rather than absolute truth. Bias towards doubt and recommendations over requirements and assertions.
- **MUST** be as concise as possible. Prefer links and references. When examples are warranted, prefer minimal demonstrations over thorough walk-throughs.

### Wording patterns

| Avoid                        | Prefer                                                          |
| ---------------------------- | ---------------------------------------------------------------- |
| "Always do X"                | "When Y, consider X"                                            |
| "Never use Z"                | "Z caused issues here; verify before using in similar cases"    |
| Long explanations            | Link to source + one-line rationale                             |

## Proposal format

**This is the required first-turn output.** Do not skip to file edits.

```markdown
## Session learnings

### 1. [Short title]
- **Learning**: …
- **Confidence**: low / medium / high
- **Proposed artifact**: doc | skill | claude.md | tip/memory | other
- **Location**: path or target
- **Draft snippet**: (minimal)

### Skipped
- … — reason (too session-specific, unverified, etc.)
```

## Implementation notes

Apply these **only after** Melody approves specific proposals in a follow-up turn.

- **Docs**: Add or extend existing docs; link to tickets, Confluence, or code rather than duplicating content. **MUST NOT** link to AI-specific skills, CLAUDE.md, or other agent-only documents.
- **Skills**: Personal (`~/.claude/skills/`) unless the learning is repo-specific (then place it under that repo, per Claude Code's directory-scoped skill convention); keep `SKILL.md` short; use `disable-model-invocation: true` unless ambient auto-invoke is intentional.
- **CLAUDE.md entries**: Prefer a repo-specific `CLAUDE.md` section over the global `~/.claude/CLAUDE.md`; one concern per section/heading.
- **Tips / memory**: No files for plain tips — share directly in chat. For a memory-file candidate, follow the frontmatter and applicability/durability/legibility bar the auto-memory system already uses, and note if a tip should be revisited for codification later.
- **Hooks / MCP / sub-agents**: Only when a repeatable automation or integration gap was demonstrated; document prerequisites and failure modes briefly.

## Anti-patterns

- Writing or editing files in the proposal turn, or implementing proposals the user did not explicitly approve.
- Referring to AI-specific files (skills, CLAUDE.md) from general docs meant for human readers.
- Codifying the session's topic as if it were universal team law.
- Creating a new skill or CLAUDE.md section that duplicates an existing one — update in place instead.
- Writing durable artifacts for learnings that were never verified (failed once, fixed, not retested).
- Burying a one-line tip in a new skill file.
