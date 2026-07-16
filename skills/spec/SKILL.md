---
name: spec
description: Turns a rough sketch into a spec before any code - surveys the feature's docs and code, surfaces where the sketch clashes, interviews you (err toward more questions), then writes a spec that /sous-chef:serve or /sous-chef:fire implements from. Use to plan or spec a feature, or when work is design-ambiguous. Head chef only - no delegation.
---

# Spec - decide the wanted state before any code

Spec is the head chef's own work - there is no delegation here. You survey, reconcile,
interview, and write a spec. Codex never sees this stage; planning is the most
judgment-heavy work on the line, so it stays with you. Its output is what
`/sous-chef:serve` or `/sous-chef:fire` then implements from.

## The governing idea: code is derived from docs, not docs from code

Two directions are possible and only one is good.

- **Right - code derived from a spec.** The spec is the durable, valuable artifact;
  code is cheap to regenerate from it. Spec produces that artifact, and
  `/sous-chef:serve` or `/sous-chef:fire` implements *from* it - the ticket's `<task>`,
  `<done_when>`, `<interfaces>`, and `<constraints>` are derived from the spec, not
  re-improvised from chat.
- **Wrong - docs reverse-engineered from code afterward.** They come out over-technical,
  drowned in low-level detail, missing the business reason, and drifting from what the
  owner actually wanted. This skill exists to break that direction.

So the spec describes the **wanted state** - where the owner's head is *now*, which
usually runs ahead of the code - not what the code happens to do today. The owner's
answers are the decider: docs and code are starting material, but where any of them
conflicts with what the owner says in the interview, the owner wins.

## When to spec vs. go straight to serve

Spec when the *what* or the *why* isn't yet pinned down: a new feature, a change that
touches decisions other code or docs depend on, or anything you'd otherwise start
implementing with unstated assumptions. This is the tool for "resolve design first."

Skip it when the end state is already clear and written - go straight to
`/sous-chef:serve` or `/sous-chef:fire`. Spec is deliberate and interactive (it
interviews you); don't spend it on a task that's already a decided, checkable spec.

## 1. Survey - what already exists

Find the docs and code the sketch touches. This is a breadth task - dispatch `Explore`
subagents in parallel, don't read serially.

- **Docs** - seed from the repo's index and the `AGENTS.md` Map; sweep `docs/`, any
  `README.md`/`CLAUDE.md`, and any `*.md` that names the feature or its key terms. Note
  each doc's freshness and whether it reads as intent or as implementation notes.
- **Code** - the modules, data structures, config keys, and contracts that already
  implement or border the feature. Cite real file paths.

Return two short lists - docs found, code found - each with a one-line "what it covers".

## 2. Reconcile - where the sketch clashes

Build the wanted state (the sketch, read generously) and the current state (what the
docs claim and the code does), and diff them. Group the friction:

- **Contradictions** - a doc or the code says something the sketch overturns.
- **Doc gaps** - the sketch relies on something no doc records.
- **Code gaps** - the sketch wants something the code doesn't do yet (usually where the
  owner is ahead of the code).
- **Ambiguities** - under-specified everywhere; genuinely unsettled.

Every clash is **mandatory to surface** - never silently pick a side, never quietly
resolve toward the code because it "seems obvious." This list is the raw material for
the interview, not a deliverable; turn it straight into questions.

## 3. Interview - to a coherent wanted state

The core of the skill. Convert the reconciliation into questions and cycle until the
picture is coherent from both angles: it makes sense to a *user* (behaves like the
feature's siblings) and to the *architecture* (single responsibilities, clean
dependencies, a clear source of truth).

- **Err toward more questions.** Confirmation is valuable - an assumption the owner
  OK's is now confirmed; divergence is gold - when they answer in their own words, that
  is often the single most valuable input the whole spec gets. Ask even when you think
  you know.
- Use **AskUserQuestion**, batched (its 4-per-call cap is per call, not a budget).
  **At least two rounds** - always draft a deliberate second set before stopping. Keep
  going while answers keep *steering* the picture; stop when a round only confirms;
  **hard cap ~5 rounds**. Whatever is still unsettled at the cap becomes an OPEN
  question in the spec, never silently decided.
- Phrase **high-level, not technical** - plain-English behaviour and UI consequences,
  not implementation options. Lead each question with the tension that prompted it
  ("the doc says it auto-saves, the code needs a button - which is wanted?"). Offer a
  recommended option first when you have one, and let the owner override.
- Drop to low-level questions only when the choice gates the whole feature (data
  structure A allows X but forecloses Y). Ordinary implementation detail is not the
  owner's to decide here.

## 4. Draft and confirm - the gate

Before writing any file, draft the **entire spec** - the complete text, following
[references/spec-template.md](references/spec-template.md) and the principles in step 5,
exactly as it will land on disk - and show that whole draft in chat. The owner must see
the full proposed content to comment on it; a summary of what it *will* contain is not a
substitute. Get approval - do not author the file until they accept.

Lead the draft with a short, scannable orientation so it's quick to review against - one
line per item:

- **Decided** - the wanted-state calls reached this run.
- **Clarified** - each drift or ambiguity now resolved, with its resolution.
- **Open** - anything unsettled at the round cap, headed for the spec's OPEN section.
- **Output** - the spec's file path.

Then show the full drafted spec beneath it. A correction here is the owner steering -
fold it into the draft and proceed; it's a review, not a new interview round.

## 5. Write the spec

Write the approved draft into the **spec archive - a directory kept separate from the
project's main docs**, with
a numbered filename: default `docs/tickets/NNNN-<slug>.md`, where `NNNN` is the next
zero-padded number after the highest already in that directory (start at `0001`). Create
the dir if needed; honour any location the repo or user specifies; never overwrite an
existing spec. Do **not** commit it - leave it in the working tree so it lands in the
same commit as the feature code it specifies. It is a per-feature reference record, not a
main doc: written once here, finalized by `/docflow:accept`, then frozen.

- **Wanted state, owner's version.** Merge what the docs and code got right, drop the
  contradictions and dead detail, and let the interview answers override everything.
- **Concordance is a section, not a hope.** The `Docs delta` block is the exact changelist
  `/docflow:accept` later applies back into the main docs - and because those docs are the
  authoritative source, it has to be precise enough to edit *from* directly, not a vague
  "touches X." For each main doc this feature touches, record three things: what it says now
  (the old abstraction/contract), what it should say instead (the new one), and the exact
  delta between them - tagged add, override, or reconcile, and naming the old and the new
  wherever a contract, term, or abstraction shifts. It needn't be long, but a vague delta
  forces accept to reverse-engineer the docs from the diff - the one direction this whole
  workflow exists to prevent.
- **Cross-link, don't duplicate** - point at existing docs for what they already say
  well; the spec covers only this feature.
- **Tag `@TODO`** every aspect that's decided but not yet built, so the spec reads as
  the wanted state while flagging which parts are aspiration.
- Keep it lean and readable - business reason first, one decision per point, no
  boilerplate intro or "future work" section.

Then label the session after its spec: run `claude-rename.sh NNNN-<slug>` (the helper
ships on PATH with this plugin). It writes the same rename record `/rename` would, so
the `/resume` list - and a tmux dashboard tab, where one is watching - show which
feature this session specs. Best-effort: if the helper is missing or errors, continue
without it.

## 6. Hand off

The spec is the wanted state for this feature; the project's main docs stay the durable
source of truth and are updated from it at the very end. Point the owner at the spec and
name the next step: `/sous-chef:serve <slug>` (or `/sous-chef:fire`) implements from it -
the ticket is derived from the spec (scoped and self-contained), not re-invented. If OPEN
questions remain, name them so the owner knows what the implementer will hit. After the
code ships and verifies, `/docflow:accept` finalizes this spec against what actually
shipped and folds its `Docs delta` into the main docs - then the numbered spec is
committed with the feature and left as a frozen record.

## Rules

- Head chef only - no Codex, no delegation, no profile needed. A git repo is enough to
  commit the spec into.
- Survey and reconcile before asking; never author on an incoherent picture.
- Every doc/code clash is surfaced - asked in a round, or listed OPEN in the spec.
  Never resolved silently.
- The owner's interview answers override docs and code when they conflict.
- Always ask a real second round; over-asking is cheap, a baked-in wrong assumption is
  not.
- Show the full drafted spec in chat and get approval before writing any file - the
  owner approves the actual content, never just a summary of it.
- The spec is the wanted state; tag not-yet-built parts `@TODO`.
- The spec lives in a numbered per-feature archive separate from the main docs and is
  committed with the feature it specifies - a frozen record, not a competing source of
  truth. The main docs remain the living truth.
