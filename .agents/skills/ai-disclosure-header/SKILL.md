---
name: ai-disclosure-header
description: Adds two fixed disclosure lines to the very top of any AI-authored text placed somewhere a human would normally expect human-curated writing — PR descriptions, PR comments, Jira ticket descriptions, Jira comments, Confluence pages, and similar. One line flags that the visible text itself is AI-generated (always true, since this agent wrote it); the other flags how much human involvement went into the underlying work the text describes (a code change, an investigation, research, a design decision, etc). Consult this whenever drafting or finalizing text on one of these surfaces through this agent, right before writing the rest of the content. Do not skip it for small or opportunistic edits — the header applies regardless of size or surface.
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
- Jira ticket descriptions
- Jira comments
- Confluence pages

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
| Jira ticket description | `Ticket description` |
| Jira comment | `Ticket comment` |
| Confluence page | `Page content` |

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
code output (e.g. a Jira ticket documenting a collaborative incident
investigation gets `🤖+🧑 AI + human collaboration, full human self-review` even
though nothing was committed).

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

Both lines go at the very top of the text body, before the summary, ticket
description, comment content, or any other content, with no blank line between
them, then a blank line before the rest of the text:

```
PR summary: 🤖 AI-generated
PR changes: 🤖+🧑 AI + human collaboration, full human self-review

<rest of the PR description>
```

```
Ticket description: 🤖 AI-generated
Underlying work: 🤖+🧑 AI + human collaboration, full human self-review

<rest of the ticket description>
```
