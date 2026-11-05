---
name: ai-disclosure-header
description: Adds fixed disclosure lines to the very top of any AI-authored text placed somewhere a human would normally expect human-curated writing — PR descriptions, PR comments, work ticket descriptions, work ticket comments, wiki pages, and similar. One line flags that the visible text itself is AI-generated (always true, since this agent wrote it); one flags how much human involvement went into the underlying work the text describes (a code change, an investigation, research, a design decision, etc); and a usage line reports the model, harness, tokens and estimated cost behind it (computed by a script, usually only on the main body of a change). Consult this whenever drafting or finalizing text on one of these surfaces through this agent, right before writing the rest of the content. Do not skip it for small or opportunistic edits — the header applies regardless of size or surface.
---

# AI disclosure header

Every piece of text this agent writes onto one of the covered surfaces gets two
header lines prepended (plus a third usage line where "Line 3" below says so), above
anything else in the body (summary, description,
comment text, etc). These are disclosure metadata about provenance, not part of
the content itself, so they stay separate from and unaffected by any other style
guidance (e.g. `change-description-style`) applied to the rest of the text.

## Covered surfaces

- PR descriptions
- PR comments
- Work ticket descriptions
- Work ticket comments
- Wiki pages
- GitHub issues, issue comments, and PRs (e.g. upstream open-source contributions)

**Learning (2026-10-16, Melody):** we bias too much toward two lines. Where the
text and the underlying work have the same provenance (e.g. a comment Melody and
this agent drafted together), one line suffices:

```
AI disclaimer: 🤖+🧑 AI + human collaboration, full human review and editing before posting
```

Use the two-line form below only when the text's authorship and the work's
human involvement really differ. Default to one line on public surfaces
(like GitHub) and when in doubt, show Melody the draft header.

If a new surface comes up that isn't listed here but fits the same pattern (AI
text landing somewhere a human reader would assume a human wrote it), apply the
same two-line convention and ask Melody whether to add it to this list.

## Line 1: always the same, label varies by surface

```
<Surface label>: 🤖 AI-generated
```

This line is unconditional — the trigger is simply that an LLM agent authored
the visible text, which is true every time this skill runs. Use the label that
matches the surface:

| Surface | Line 1 label |
|---|---|
| PR description | `PR summary` |
| PR comment | `PR comment` |
| Work ticket description | `Ticket description` |
| Work ticket comment | `Ticket comment` |
| Wiki page | `Page content` |

## Line 2: reflects human involvement in the underlying *work*, not the text

```
Underlying work: <one of the three values below>
```

(PR descriptions keep the existing `PR changes` label instead of `Underlying
work`, for continuity with prior PRs — the meaning is identical.)

This line is about whatever the text is documenting — a code change, a live
investigation/debugging session, research, a design decision — which is a
separate question from who wrote the text describing it. Pick exactly one:

| Situation | Value |
|---|---|
| AI did the work with little human oversight | `🤖 AI, minimal human oversight` |
| Human operator actively collaborated on and reviewed the work | `🤖+🧑 AI + human collaboration, full human self-review` |
| Work is mostly human-done; AI only reviewed or made small contributions | `🧑 human, minimal AI modification` |

This line applies whenever the text describes work that happened, which in
practice is almost always — including pure investigations or research with no
code output (e.g. a work ticket documenting a collaborative incident
investigation gets `🤖+🧑 AI + human collaboration, full human self-review` even
though nothing was committed).

## Line 3: usage (model, harness, tokens, cost)

Added 2026-11-05 (Melody): readers should be regularly informed about, and able to
discuss reasonably, what AI work actually costs. Motivation: the
a PR 404 review thread
(2026-11-05). It is the **last** disclosure line, directly above the horizontal rule:

```
usage: Sonnet 5.5 · Claude Code · ~1.7M tokens (1.6M cache reads, 70k new input, 18k output) · ~$0.62 est.
```

**Generate it with the script; never estimate by eye.** Run it right before posting:

```
python3 -I ~/.agents/skills/ai-disclosure-header/scripts/session-usage.py --session-id <id>
```

- **Session id**: the UUID directory in the scratchpad path in your environment
  (`/private/tmp/claude-502/<project>/<session-id>/scratchpad`). `--latest` instead
  guesses the newest transcript for the cwd, which is wrong if two sessions share a
  folder. The script prints a per-model breakdown to stderr; sanity-check it.
- **What the numbers mean.** `tokens` is everything sent to and generated by the API
  across every call in the session tree (this session plus its subagents), and the three
  parenthetical parts add up to it (modulo rounding):
    - **cache reads**: context re-read from the prompt cache on each call, at a small
      fraction of the input price. Usually the bulk of the volume and the smallest part
      of the cost.
    - **new input**: fresh input plus cache writes, billed at full price or more. This
      is the part that grows when a turn lands on an old session whose cache expired,
      because the whole context is written again.
    - **output**: what the model generated (thinking included), the priciest per token.

  It is **not** the context length. That is the size of the window on a single call
  (input plus cached), for example 100k at its largest in a session whose total was
  1.7M. The script prints it as `peak-context` in its stderr breakdown, but it doesn't
  belong on the line because it doesn't add up with the rest.
  `cost` prices these at list API prices from `scripts/pricing.json`. It is an estimate,
  not what the Enterprise plan bills; `≥` means a model had no price on file.
- **Measuring part of a session**: `--since` / `--until` (ISO UTC timestamps) slice by
  call time. Use them only when asked about a specific stretch; the line on a post
  covers the whole session tree.
- **Scope: this session tree.** The script adds ` across N sessions + M subagents` by
  itself, only when it is more than one simple session. If other sessions plausibly
  contributed (a handoff, a fork, a PR continued from an earlier session), ask Melody
  what to include before posting, then pass extra `--session-id`s.
- **Effort**: pass `--effort <level>` only when the session's effort differs from the
  default (High); it then shows as `Sonnet 5.5 (max effort)`.
- **Harness**: `--harness` defaults to `Claude Code`; set it when running somewhere else.
- **No transcript** (script exits 3, or a harness that doesn't write one): use the
  fallback line it prints, `... · tokens: unknown · cost: unknown`. Don't guess, and
  tell Melody.
- **Keep prices current.** `pricing.json` has an `as_of` date and the source page.
  Re-fetch the page and update when it is old or a model is missing. Take cache-read
  prices from the page, not a multiplier (0.025x, 0.05x or 0.1x depending on the
  model), and don't trust the `claude-api` skill's cached table over the page: on
  2026-11-05 it listed Sonnet 5.5 cache reads at $0.20 where the page says $0.10.

**When to include it:**

- Put it on the **main body** of a change (PR description, ticket description, wiki
  page). Skip it on comments and follow-ups about work whose main body already reports it.
- Include it on **standalone** comments (no main body reports it), including short ones
  (it keeps the `usage:` label in the short form) and on public surfaces like GitHub.
- It is a **snapshot at first post**. Don't refresh it when editing. After a larger
  revision, say what changed in a new comment, which carries its own usage line. Ideally
  the revision happens in a new session, so the figures are that session's own. If it
  happens in the same session, report the whole session's totals (cumulative, as the
  script does by default): that is deliberate, because it shows how expensive a new turn
  on an old session can be (the cache has expired, so the context is paid for again as
  new input).

## Melody may drop the header after heavy editing

If Melody edits a posted draft enough that she no longer considers it AI-authored, she may delete the header herself (observed 2026-10-19). That doesn't change what to do beforehand: still add the header when drafting and posting. Don't restore a header she removed.

## Deciding which value applies: ask, don't assume

This is a judgment call about what happened over the course of a session, and
this agent doesn't have reliable visibility into everything the human did
outside the conversation (e.g. edits made by hand outside this tool, or review
that happened silently). Per Melody's standing preference to be checked in with
rather than have decisions made for her on incomplete information, don't infer
this category from session activity alone unless it's unambiguous.

- If the session context makes it obvious (for example, Melody explicitly said
  "I wrote this, just fix the typo" or the entire work was done autonomously
  with no back-and-forth), use that.
- Otherwise, ask directly before finalizing the text — a quick question like
  "How would you categorize the human involvement here: mostly-autonomous AI,
  active collaboration with your review, or mostly your own work?" is enough.
  Don't post or update the text with a guessed value.
- Exception: when the underlying work is trivial in scope — e.g. noticing
  something in a log and checking the one file responsible, not a multi-step
  investigation — don't interrupt to ask. At that scale the distinction
  between the three values is basically moot (per Melody, Sep 2026): line 1
  already discloses that the text is AI-generated, and it's not worth a
  question just to pick a label for a few minutes of trivial legwork. Default
  to `🤖+🧑 AI + human collaboration, full human self-review` in these cases
  rather than asking.

## Updating the annotation after the fact

The disclosure isn't necessarily a one-time, write-once label. If Melody
reviews, edits, or extends AI-authored text after this skill first posted it
(for example, adding her own reviewed notes to a ticket description after the
AI-drafted investigation summary), update line 2 to reflect the increased human
involvement rather than leaving the original value stale. When in doubt about
whether the change is significant enough to bump the category, ask.

## Placement

The disclosure (both lines, or the single collaboration line) goes at the very
top of the text body, before the summary, ticket description, comment content,
or any other content. In the two-line form there's no blank line between the
lines. Always put a horizontal line directly below the disclosure, then the rest
of the text, so readers can see where the disclosure ends and the content begins.

Pick the horizontal line by what the surface supports, in this order:

1. **Rich-text horizontal rule element**, if the environment has one (e.g. a
   wiki or ticket editor's divider). Use it.
2. **HTML**, if the surface renders it: `<hr>`. Try this where it's plausible.
3. **Otherwise**, a Markdown/plain-text `---` on its own line, with a blank line
   before and after (the blank line before keeps `---` from turning the
   disclosure into a setext heading):

```
PR summary: 🤖 AI-generated
PR changes: 🤖+🧑 AI + human collaboration, full human self-review
usage: Sonnet 5.5 · Claude Code · ~1.7M tokens (1.6M cache reads, 70k new input, 18k output) · ~$0.62 est.

---

<rest of the PR description>
```

```
Ticket description: 🤖 AI-generated
Underlying work: 🤖+🧑 AI + human collaboration, full human self-review
usage: Opus 5.5 + Sonnet 5.5 · Claude Code · ~6.2M tokens (6.0M cache reads, 246k new input, 36k output) across 1 subagent · ~$3.25 est.

---

<rest of the ticket description>
```

```
AI disclaimer: 🤖+🧑 AI + human collaboration, full human review and editing before posting
usage: Sonnet 5.5 · Claude Code · ~918k tokens (806k cache reads, 104k new input, 8k output) · ~$0.58 est.

---

<rest of the comment>
```
