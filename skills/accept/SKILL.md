---
name: accept
description: Closes the loop after a feature ships - finalizes its numbered spec against what shipped, then places the spec's Documentation into the project's main docs so they stay the living source of truth. Head chef only and owner-gated - surfaces code/spec divergence, never overwrites docs silently. Use after a sous-chef serve or fire once checks are green.
---

# Accept - place the shipped feature's docs into the main docs

Accept closes the loop that `/docflow:spec` opened. That skill wrote the feature's
documentation into a numbered spec before any code; accept, after the code ships and
verifies, finalizes that spec against what actually shipped and places its
`Documentation` entries into the project's main docs - so the main docs stay the
living source of truth instead of drifting into something reverse-engineered from
code later. The prose was already written in each target doc's register at spec time,
so this is a **placement pass, not a translation**. Head chef only: placing docs is
judgment, so there is no delegation here.

## The one rule that makes this safe

Doc edits are sourced from the **finalized spec (intent), reconciled against the actual
diff - never from the diff alone.** Docs written from the diff are docs reverse-engineered
from code - the exact thing this whole workflow exists to prevent. The diff's only jobs
are to confirm what shipped (so you know which `@TODO`s to clear and which `Documentation`
entries are real) and to surface where the code diverged from the spec - which is yours to
resolve, not to silently transcribe.

## Inputs and when to accept

- The numbered spec for the shipped feature (`docs/tickets/NNNN-<slug>.md`), the actual
  diff (what shipped), and the main docs its `Documentation` names. (Older specs call
  the section `Docs update` or `Docs delta` - treat them the same.)
- Accept after `/sous-chef:serve` or `/sous-chef:fire` finishes and verification is green.
  No spec, or checks still red? Stop - there is nothing settled to fold in.

Label the session first: run `claude-rename.sh accept-NNNN-<slug>` (the helper ships
on PATH with this plugin; best-effort - if it is missing or errors, continue). The
`/resume` list and a watching tmux dashboard tab then show which feature this session
is accepting.

## 1. Reconcile the spec with reality

Walk the spec against the shipped diff:

- **Clear** every `@TODO` whose part actually shipped as specified.
- **Flag divergence** - anything that shipped differently from the spec, or a spec item
  that didn't ship. Do NOT rewrite the spec to match the code. Surface each to the owner:
  fix the code (a fresh `/sous-chef:fire`), or amend the spec on purpose. Their call.
- **Resolve OPEN** - fold in answers the build settled; leave genuinely open ones named.

The result is the finalized spec - the true end state of this feature.

## 2. Plan the placement - the gate

Before touching any main doc, present the plan and get approval - one line per doc:

- `path/to/doc.md` - which section its `Documentation` entry lands in, and what
  today's text it removes as superseded, reconciled with what shipped.

Never silently overwrite hand-written prose. A correction here is the owner steering -
fold it in; do not author until they accept.

## 3. Place into the main docs

Placement, not translation - each entry was written for its target doc at spec time:

- Insert each entry into the section its `Documentation` names, keeping the doc's
  outline intact; adapt joins and transitions, not substance.
- Remove what the entry's what-changed notes flag as superseded - stale claims come
  out in the same pass their replacement goes in.
- A multi-doc feature lands as a set: place every entry, keep the cross-links between
  the touched docs true, and create a new doc with its full text where the spec wrote
  one.
- Then check completeness and register: the main docs alone should now document the
  shipped feature as if it had always been there - someone starting from scratch reads
  only them and understands it - and the new text holds the project's docs register
  (its docs-style skill if it ships one, else the surrounding docs; depth per
  [../spec/references/example-project-doc.md](../spec/references/example-project-doc.md)).
  A gap the spec's `Documentation` missed is surfaced to the owner and written as part
  of this pass, never skipped.
- Cross-link the frozen spec by its number for provenance; the Record (decisions,
  interview reasoning) stays in the spec, never pasted into the main docs.

## 4. Freeze and commit

The finalized numbered spec, the main-doc edits, and the feature code are now one unit -
commit them together (or hand the owner the staged set to commit). From here the numbered
spec is frozen: never touched again. Report what shipped, which main docs changed, and any
divergence you surfaced or `@TODO`/OPEN item still standing.

## Rules

- Head chef only - no Codex; doc prose is judgment.
- Doc edits come from the finalized spec reconciled with the diff, never from the diff
  alone.
- Placement, not translation - entries were written in-register at spec time; accept
  situates them, removes superseded claims, and keeps cross-links true.
- Plan and get approval before editing any main doc; never overwrite hand-written prose
  silently.
- Divergence is surfaced for the owner to resolve, never transcribed into the docs.
- The numbered spec is finalized once, committed with the feature, then frozen.
- Nothing runs accept automatically - you invoke it, or wire the offer into your
  `CLAUDE.md` routing (see docflow's `templates/integration.md`). It never runs
  silently; the doc update is owner-gated.
