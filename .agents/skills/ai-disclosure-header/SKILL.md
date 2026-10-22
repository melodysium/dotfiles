---
name: ai-disclosure-header
description: Adds two fixed disclosure lines to the very top of any AI-authored text placed somewhere a human would normally expect human-curated writing — PR descriptions, PR comments, work ticket descriptions, work ticket comments, wiki pages, and similar. One line flags that the visible text itself is AI-generated (always true, since this agent wrote it); the other flags how much human involvement went into the underlying work the text describes (a code change, an investigation, research, a design decision, etc). Consult this whenever drafting or finalizing text on one of these surfaces through this agent, right before writing the rest of the content. Do not skip it for small or opportunistic edits — the header applies regardless of size or surface.
---

# AI disclosure header

Every piece of text this agent writes onto one of the covered surfaces gets two
header lines prepended, above anything else in the body (summary, description,
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

---

<rest of the PR description>
```

```
Ticket description: 🤖 AI-generated
Underlying work: 🤖+🧑 AI + human collaboration, full human self-review

---

<rest of the ticket description>
```

```
AI disclaimer: 🤖+🧑 AI + human collaboration, full human review and editing before posting

---

<rest of the comment>
```
