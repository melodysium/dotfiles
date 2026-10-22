---
name: session-pause-handoff
description: Persist a session's state so a *fresh* session (no transcript) can continue the work later. Use whenever work should resume in a new session: Melody has to go, step away, or shut her laptop; the context is getting long and a fresh start is cheaper; or a scoped phase is done and the next phase belongs in its own session (e.g. "research and linkage are settled; formatting and placing goes to a new session"). Also on "persist", "save state", "leave TODOs for me", "close this out", or "hand off to a new session". Not for forking work into a parallel session now (use jj-worktree-handoff or start_session), and not for distilling lessons into docs (use learn-from-session).
---

# Session handoff

A **new agent with no transcript** will pick the work up, maybe much later. Your job is to make the environment itself carry the state, cheaply and durably.

This happens in two common shapes:
- **Pause:** Melody is leaving and may not read your reply until later.
- **Phase close-out:** she's here, the current phase is done, and the next phase is deliberately scoped to a fresh session. Write the handoff as the next session's starting brief, and consider proposing that session (e.g. `start_session`, own-initiative) once the handoff is committed.

## Rules

- **Don't block on questions when she's leaving.** Write open questions into the handoff file instead of asking in chat. In a close-out she's present, so a quick question is fine; anything left open still goes into the file.
- **Don't publish or commit unasked.** Leave any external system (wiki pages, work tickets, PRs and pushes) alone. If in a VCS / repo, report any state, and save current work in well-formed commits (even if they're incomplete).
- **Don't rush or make bad assumptions.** "Save things now w/o user input" shouldn't imply "Make rushed questionable assumptions for the sake of finishing work." Expectations of quality still apply; we aren't rushing, just pausing.
- **Do other requests in the same message only if they're unambiguous.** If one could mean two things (e.g. "save this as a user skill": *which* "this"?), don't guess; list it as a TODO with your reading and the alternative.
- **Prefer pointers over copies**, but rescue anything that only exists in temp or scratch space (subagent outputs, fetched snapshots). Scratch dirs don't survive.
- **Save a pointer to this current session** in the main handoff doc, so that a future session can go re-read if later clarification is needed.

## Steps

1. **Find the project's own convention.** Look for a journal, a `logs/` dir, `notes/sessions/`, or a README index, and put the handoff where that convention says. If there isn't one, a default suggestion is `HANDOFF-<yyyy-mm-dd>-<slug>.md` at the repo root.
2. **Rescue ephemeral artifacts.** Copy useful scratch or subagent output next to the handoff file, and link it.
3. **Write the handoff file** (call it `HANDOFF.md` when it sits in a session folder) with three sections:
   - **State:** what's done, with links. Versions of external sources as fetched (e.g. "wiki page v25"), and a note to re-check them if they're newer. What has *not* happened: uncommitted changes, nothing published. A reference to the previous session for lookups if necessary.
   - **TODOs for Melody:** numbered, smallest first. Say which ones need *her* knowledge or decisions.
   - **For the next agent:** what to read first and what to skip (so it doesn't re-pay context), the next steps in order, and guardrails (what needs her explicit go-ahead).
   Write it for a cold reader: no "as discussed above" and no transcript-only references.
4. **Update any indexes** if present (e.g. session log tracker) to point at the handoff.
5. **Save a memory pointer.** Add one `project` memory that says where the work stands (paused, or phase done) and names the handoff file, plus its `MEMORY.md` line, so a new session in this folder finds it without being told. Replace any older handoff memory for the same work rather than stacking them.
6. **Report briefly:** where to start, what's uncommitted, and one offered action (usually the commit). Keep it scannable; she'll read it later.

## Check before finishing

- Could a fresh agent resume using only the repo and memory? Read the handoff as if you were that agent.
- Does every path you mention exist where you say it does?
