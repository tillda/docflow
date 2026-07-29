---
name: reconstruct-docs
description: Editorial workflow that RECONSTRUCTS the documentation of one app feature — fixing, clarifying, and completing it. Invoked explicitly with /docflow:reconstruct-docs, optionally followed by free-text instructions (file hints, an authoritative-doc pick, or pre-answered "changes" — any wording, no fixed format). Gathers the feature's docs and code, reconciles docs against code, interviews the owner to settle the WANTED end state, presents a plan for approval, then writes two files into <docs_dir>/new/: the spec <feature>.new.md and a companion <feature>.TODO.md of the wanted-vs-actual gaps. Heavyweight and deliberate; for a quick edit to one doc, edit it directly instead.
disable-model-invocation: true
---

# Reconstruct docs

A deliberate, interactive workflow for **fixing, clarifying, and completing the
existing documentation** of **one app feature**. This is rarely a blank page —
the feature already has docs, and the job is to reconcile and finish them, not to
write from scratch. You are the **editor**, not a stenographer: you read
everything, find where the story disagrees with itself, interview the owner to
resolve it, and publish one clean, merged doc.

Invoked explicitly with `/docflow:reconstruct-docs`, optionally followed by free-text
**instructions** (see below). Follow the protocol below. Everything through the
`---` divider is the protocol you execute; the section after it is documentation
for humans.

## The governing idea: document the WANTED state, not the actual state

The code is almost always **a step behind the owner's head**. The owner carries
assumptions that are unimplemented, half-implemented, or implemented wrong. The
job of this skill is **not** to describe what the code does today — it is to
reach, by interview, the **wanted end state** that is coherent from two angles at
once:

1. **User point of view** — the feature behaves the way similar features in the
   app already behave; the UI stories make sense to a user.
2. **Programming architecture** — the dependencies, dataflow, and responsibilities
   are clean and make sense to build.

You keep asking questions until that wanted picture is coherent from both angles.
The new doc describes that wanted state. The gap between wanted and actual is
reported **separately**, in an always-written `<feature-area>.TODO.md` punch-list
(Phase 6) — it never pollutes the spec.

**The owner's answers are the most important input.** The final doc is a **merge**
of the feature-relevant parts of three sources — the authoritative docs, the
non-authoritative docs, and the code — but every one of them is **overridden by
what the owner says in the interview**. Docs and code are the starting material;
the owner's input is the decider — when they conflict, the owner wins. (The
current code can still *inform* the questions you ask, since it shows what is
technically possible.)


### Why this matters: code is derived from docs, not docs from code

Two directions are possible, and only one is good:

- **Right — code derived from docs.** The doc is the valuable, durable artifact;
  code is cheap to regenerate from it. This is the direction the skill feeds: a
  good `<feature-area>.new.md` becomes the source of truth a later session uses to
  bring the code up to it.
- **Wrong — docs generated from code.** Docs auto-derived from code are extremely
  technical to the point of near-uselessness — buried in low-level detail, missing
  the real-world requirements, and drifting from the owner's intent. A doc grown
  that way is a smell and a mess.

The skill exists to break that wrong direction. Its inputs are each only half-good
on their own — stale docs, stale code — so neither alone yields a good doc. The
owner's clarifications are what fuse them:

> half-bad docs + half-good docs + lots of clarifying Q&A → **good docs** →
> (later) code derived from those good docs.

So the reconciliation mines the app author's living **intent** — where their head
is **now**, which runs ahead of (and sometimes flatly contradicts) the
implementation — not what the code happens to do today. That makes
`<feature-area>.new.md` a **forward specification of intent**: this session
produces it; a separate, later session takes it as the source of truth and edits
code, configs, and the other docs to match.

Every other emphasis follows from this: owner overrides everything,
wanted-state-only, no migration archaeology — the doc is an **instruction to the
future implementer**, not a mirror of the present.

### What you're starting from: each input's characteristic staleness

The three inputs are stale in different, predictable ways. Know the pattern so you
weigh each one correctly:

- **Code** — a *reasonable but probably stale* state. It is real, working
  behaviour, so it is **good evidence of how things actually work today** — better
  than nothing, often better than the docs — but it lags the author's intent.
  Mine it for what is genuinely implemented; never treat it as the goal.
- **Old docs, axis 1 — behind the code.** Real features got built that the docs
  never mention. These show up as Phase 2 **doc gaps**; bring each one to the
  owner ("this exists in code, undocumented — is it wanted, and how should it
  read?") and fold the confirmed ones in.
- **Old docs, axis 2 — drifted into worthless detail.** LLM-written docs tend to
  silt up with implementation and programming minutiae that carries no value to a
  reader. **Strip it.** The new doc holds the house-style density — names of major
  config/data files first, module names sparingly, variable-level detail usually
  omitted. Pruning low-value detail is as much the job as adding missing features.

## Pre-supplied instructions (optional)

Any text after `/docflow:reconstruct-docs` is the **instructions** — ordinary prose that
pre-supplies what the skill would otherwise discover or ask. **There is no fixed
format**: it can be plain sentences, a few bullets, explicit file hints, hard
directives, or a structured `<instructions>`/`<changes>` block — interpret whatever
is there. Honour it; it is the owner talking. It can supply any of:

- **Source files** — explicit docs and code files/paths for this feature. When
  given, **the Phase 1 file search respects them**: treat them as the source set
  (plus the obvious references they point at) instead of sweeping the repo wide.
  When absent, search wide as Phase 1 describes.
- **Output file(s)** — where the new doc(s) go; overrides the default
  `<feature-area>.new.md` location in Phase 5.
- **Changes** — upfront clarifications about the debated feature(s): answers the
  owner already knows they want, an upcoming feature, a decision already made
  (whether under a `<changes>` tag or just stated in the text). **Treat each as an
  authoritative answer to a question you would otherwise ask** — a want-to-have for
  the doc, with the same deciding authority as an interview answer. Do not
  re-litigate the *decision* itself; build the wanted state on top of it and mark
  the not-yet-built ones `@TODO` (Phase 5).
  - **If such a change conflicts with or drifts from *anything* in the sources —
    docs or code — that conflict MUST be raised and worked through the question
    sequence toward full resolution.** It is **top-priority** — ask it first.
    Accept the change as the decision, but confirm every implication: what it
    overrides, what else it breaks, what now must change. Never silently apply a
    change that contradicts a source.
  - This does **not** override the round cap (Phase 3). If such a conflict is still
    open after the final round, stop asking and flag it **loudly at the top of the
    `.TODO.md`** (not buried as an ordinary `@TODO`), then proceed.

If the invocation supplies none of these, run every phase as written (Phase 0 will
ask for what it needs).

## Phase 0 — Scope the feature and rank trust

Settle three things, from the invocation prompt or `<instructions>` block if
given, else by asking:

1. **Which feature** is being documented (one feature, named).
2. **Which docs** are related to it. Take any the user names; you will also search
   for more in Phase 1.
3. **Which docs (if any) are authoritative** — the ones the owner trusts as the
   best-written, most up-to-date, cleanest source of *intent*. Everything else
   (other docs **and** the code) is treated as **detail and reality**, often
   implementation-leaning, to be checked against that intent.

If the user did not say which is authoritative, **infer a likely one from the file
names**: a doc whose name carries an authoritative-sounding word — `main`,
`top-level` / `toplevel`, `high-level` / `highlevel`, `overview`, `spec`,
`README`, or an ALL-CAPS spec name — is probably the trusted source of *intent*,
while the deeper, narrower-named docs are detail. Propose that ranking and confirm
it with the owner. It is fine for there to be **no** authoritative doc — then the
comparison in Phase 2 is plain code-vs-docs.

## Phase 1 — Gather everything (search wide)

Find **all** docs and **all** implementing code for the feature. This is a
breadth task — dispatch `Explore` subagents in parallel rather than reading
serially.

**If the `<instructions>` block named source files, the search respects them**:
read that explicit set (and only the obvious references it points at) instead of
sweeping the repo wide. The sweep below is for when no sources were given.

- **Docs sweep** — `docs/` (recursively), every `AGENTS.md`, `README.md`, and any
  `*.md` that mentions the feature or its key terms. Note each doc's apparent
  freshness and whether it reads as intent or as implementation notes.
- **Ignore `*.TODO.md` files entirely.** They are punch-lists emitted by previous
  runs of this skill (see Phase 6), not documentation — pulling them in would
  duplicate and muddle the sources. (`*.new.md` files *are* read — see Phase 5 —
  but TODO files are skipped.)
- **Code sweep** — the modules, files, UI components, data structures, config
  keys, and wire contracts that implement the feature, across the whole codebase
  as relevant. Cite real file paths.

Return from this phase with two lists — docs found, code found — each with a
one-line "what it covers."

## Phase 2 — Reconcile (docs vs reality)

Build two models and diff them.

- **Documented state** — what the docs claim the feature is and does.
- **Actual state** — what the code actually does.

Then compare, picking the axis by Phase 0:

| Phase 0 result | Comparison |
| --- | --- |
| An authoritative doc exists | **authoritative (intent)** vs **code + non-authoritative docs (reality)** |
| No authoritative doc | **code** vs **docs** |

Produce a reconciliation list, grouped:

- **Agreements** — doc and code say the same thing (brief; just confirm).
- **Contradictions** — doc says X, code does Y. The richest source of questions.
- **Doc gaps** — code does something no doc mentions.
- **Code gaps** — a doc describes something the code does not (or not yet) do —
  often exactly where the owner is ahead of the code.
- **Ambiguities** — under-specified in both; the picture is genuinely unsettled.

This list is **input to the interview**, not a deliverable. Do not write it up
formally; turn it straight into questions.

**Doc↔code drift is mandatory to surface.** Whenever the current docs and the
current code disagree — *any* contradiction, doc gap, or code gap above — you must
**raise** it: never silently pick a side, never quietly resolve it toward the code
or the docs, never skip it because the answer "seems obvious." Stale docs vs. live
code is exactly the signal this skill exists to catch. Prioritise drift into the
question rounds (Phase 3); whatever the owner doesn't get to within those rounds
goes into the `.TODO.md` as an open question to revisit (Phase 6) — surfaced, never
quietly decided.

## Phase 3 — Interview to a coherent wanted state (the core of the skill)

This is the most important phase. Convert the reconciliation list into questions,
ask them, and **cycle** — each answer reshapes the picture and spawns the next
questions — until the wanted state is coherent from both the user and the
architecture angle.

**Why ask so much: confirmation is valuable, divergence is gold.** Every claim you
draw from a half-bad doc or stale code is *greatly* strengthened the moment the
owner confirms its mechanics in an answer — at the bare minimum it is now OK'd and
confirmed. More importantly, when there is even a small drift from the owner's
intent, they will answer in **their own framing** (the "Type something / Other /
Chat about this" free-text option) — and that is probably **the single most
valuable input** the whole reconstruction can get. So ask, even when you think you
already know the answer.

### What to ask, in priority order

1. **High-level conceptual** — *most of your questions live here.*
   - What is the **responsibility** of this part? What is it for?
   - What should happen in the UI **when** X? Is the feature doing Y, or not?
   - Where is the boundary — what is in scope, what is deliberately not?
2. **User-facing UI stories** — concrete "when the user does this, that happens"
   walkthroughs. Test them against how **similar features already behave**.
3. **Dependency questions** — what should depend on what, and crucially **what
   should NOT depend on what**. Surface coupling the owner wants forbidden.
4. **Dataflow questions** — how state flows from a source to derived values:
   one-way binding (one-way flow) vs two-way sync; **computed at build time vs at
   runtime**; who owns the source of truth.
5. **Low-level / programming questions — only when the blast radius is big.**
   Ask these *only* when the choice gates the whole feature — e.g. picking data
   structure A over B lets the app do X but never Y. Skip ordinary
   implementation detail; it is not the owner's to decide here.

### How to ask

- Use the **AskUserQuestion** tool. It caps at **4 questions per call**, each with
  **2–4 options** (an "Other" free-text choice is added automatically). The cap is
  **per call, not a budget for the interview.**
- **Run the rounds: at least two, more while answers keep steering, hard cap at five.**
  - **Rounds 1 and 2 are mandatory.** Always ask a first set of 4, then
    deliberately come up with a second set of 4 (~8 questions). One round is almost
    never enough; before stopping, ask "what else is unclear?" and fill the second
    batch.
  - **Keep asking further rounds as long as the owner's answers *steer* the
    picture** — redirect the design, overturn an assumption, or open a fresh
    question — rather than merely confirming. When a round only confirms, stop.
  - **Never exceed five rounds** (a 5×4 ≈ 20-question ceiling, just so there is
    one). Whatever is still unsettled at the cap goes into the `.TODO.md` as an open
    question to revisit (Phase 6), not into more questions.
  - Never drip questions one at a time — always fill the batch.
- Phrase **high-level, not technical** — give plain-English implications and UI
  consequences, not multiple-choice implementation options. "When the download
  finishes, should the row turn green immediately or only after a re-check?" beats
  "should we call `refresh()` synchronously?"
- Lead each question with the tension that prompted it ("the doc says the overview
  auto-downloads, the code requires a button — which is wanted?").
- Offer a recommended option first when you have one, but let the owner override.
- Anything already settled in `<changes>` is a given — don't re-ask it, but do ask
  any follow-up it raises.

### When to stop

Stop cycling when the wanted state passes the **coherence test** from both
angles:

1. **User** — every UI story is consistent with how sibling features behave; no
   surprising or contradictory behaviour.
2. **Architecture** — responsibilities are single and named; dependencies and
   dataflow are clean (no forbidden coupling, a clear source of truth, build-time
   vs runtime settled).

If an answer opens a new inconsistency, that is a question for the next round —
within the round limit above. Prioritise unresolved doc↔code drift into those
rounds; whatever is still open when the rounds run out goes into the `.TODO.md` as
an open question to revisit, never silently decided against the owner.

## Phase 4 — Plan and confirm (approval gate)

Before writing any file, present a short **plan** in chat and get the owner's
acceptance. **Do not author until they approve.** It is a synthesis of the
interview, not a re-ask — keep it scannable, one line per item:

- **Newly decided** — the wanted-state decisions reached this run (from the
  interview and any pre-supplied changes).
- **Clarified** — drifts and ambiguities now resolved, each with its resolution.
- **Deduped / cross-linked, not copied** — content that already lives elsewhere
  (another doc, a `*.new.md`) that the new doc will reference instead of repeat, so
  the owner can see nothing important is dropped, only relocated.
- **Relocated** — any passage that will be **moved** out of another doc into this
  one because it fits here much better, naming which doc loses it, so the owner
  approves the move before files change (see *Relocate* in Phase 5).
- **Going to `.TODO.md`** — the wanted-vs-actual gaps and any still-open questions
  (e.g. drift unresolved at the round cap) headed for the companion file, not the
  spec.
- **Output** — the two file paths that will be written.

Then ask the owner to accept. On approval, proceed to Phase 5. A correction here is
the owner steering — fold it in and proceed; it is a review, not a new Phase 3
question round, so the cap does not apply.

## Phase 5 — Author the new doc

Write **one new doc** about **the feature this call is about — and only that**.
Merge the *relevant passages* from the three inputs — the authoritative docs, the
non-authoritative docs, and the code — into a single coherent account of the
agreed **wanted state**. Carry forward whatever each source got right; drop the
contradictions and dead detail. **Every claim is updated by the owner's interview
answers and `<changes>`** — where a source and the owner disagree, the owner's
version is what gets written.

- **Scope strictly to this call's subject.** The doc is **not** a merge of every
  `.md` you read in Phase 1 — those were read for reconciliation and context. Pull
  in only the passages that concern the feature being reconstructed; leave the rest
  in their own docs and **cross-link** instead. Otherwise every call would drag a
  pile of unrelated related-doc content into one file.
- **A `*.new.md` source is already a reconstructed doc.** If one of your sources
  carries the `.new.md` suffix, it is the product of a previous run — treat its
  content as already-good and **do not duplicate it** in your output. Build on it,
  cross-link it, and add only what this call changes; restating what it already
  says cleanly is wasted output.
- **Relocate a much-better-fitting piece (the exception to cross-linking).**
  Cross-linking is the default, but when a specific principle, explanation, or
  passage currently lives in *another* doc yet clearly **belongs here** — it fits
  this feature far better than where it sits — you may **relocate** it into this
  doc instead of just linking. Relocation is a **move, not a copy**: to avoid
  duplication it must leave its old home.
  - You may edit the other doc to remove the relocated piece **only when that doc
    is one of this skill's own recently-created `*.new.md` outputs** (the family of
    new docs may be rebalanced freely).
  - **Never edit an original source or authoritative doc in place** — if the piece
    came from one, bring it into this doc and record the removal-at-source as an
    item in the `.TODO.md` for the later implementer.
  - Every relocation must be listed in the Phase 4 plan and approved before any
    file changes. Keep it **rare and clearly justified** — it is not licence to
    vacuum content in (see *Scope strictly*, above).
- **Mark every not-yet-real aspect `@TODO`.** Where a passage describes something
  newly decided in this call, wanted but not yet implemented (a code gap), an
  upcoming feature, or an unbuilt `<changes>` item, tag it `@TODO` so the
  downstream implementer agent — and any reader — sees at a glance which parts are
  aspiration and which are shipped. This is the one sanctioned exception to "reads
  as if it already exists": the doc still describes the wanted state, and `@TODO`
  flags which wanted parts are not built yet.
- **Output location** — write to **`<docs_dir>/new/<feature-area>.new.md`**, where
  `<docs_dir>` is the project's standard docs directory (or the one the source docs
  came from — typically `docs/`). Create the `new/` subdirectory if it doesn't
  exist. Example: `docs/new/offline-tiles.new.md`. If `<instructions>` named an
  output file, use that instead. Never overwrite the authoritative doc in place —
  superseding it is the owner's call afterward.
- **Style** — the doc must be **nice to read**. The register comes, in order, from
  a docs-style skill the project ships (read it first and follow it when one
  exists), else the surveyed docs' own voice and outline. Two calibrations either
  way:
  1. **Depth per
     [../spec/references/example-project-doc.md](../spec/references/example-project-doc.md)**
     — the same calibration `/docflow:spec` and `/docflow:accept` use: business,
     UI, and behaviour lead (~3/5 of the text, and growth goes here); technical
     means engineering reasoning (~2/5 — what the chosen algorithm or structure
     buys, which alternatives lost and why); implementation identifiers are sparse
     and selective — config paths and important keys, directories of important
     content, public contract keys, yes; variable, class, and internal names,
     rarely — those live in code comments. **Wanted-state only — no history, no
     "previously", no migration archaeology.**
  2. **The high-level design specs in the project's docs directory.** Read a
     couple as samples. They hold the same register but lean a little more on
     **readable owner's-voice prose**
     that explains the *why* and the design tension behind a choice, with a worked
     example or a small table where it helps. Match that feel: a doc a person
     actually enjoys reading, not a terse fragment table.
- **Lean slightly more concise than usual.** This is software-development
  documentation, not an essay. Say each thing **once**: don't restate the same
  point in two places, don't paste back code snippets already shown in the doc, and
  don't spell out general programming knowledge a developer already carries. Cut
  anything a competent reader of this codebase wouldn't need. (Concise, not
  fragmentary — still readable, just without the padding.)
- **No boilerplate sections.** Skip an unspecific / throat-clearing introduction,
  skip an "Out of scope" section, and skip a "Future directions / Future work"
  section — open with the substance, and let `@TODO` tags and the `.TODO.md` carry
  anything forward-looking, so the doc doesn't forward-drift on its own. (This
  overrides any docs-style skill's optional "Out of scope" allowance for this
  skill's output.) All else equal, **shorter is better**: every spare paragraph costs
  tokens and context on every future LLM read of the doc.
- Cross-link companion docs the way the existing docs do.

## Phase 6 — Always write the `<feature-area>.TODO.md` companion

Alongside the new doc, **always** write a companion punch-list at
**`<docs_dir>/new/<feature-area>.TODO.md`** (the same `new/` directory). It
collects everything the spec deliberately leaves out:

- **wanted-vs-actual gaps** — every place the new wanted state differs from what
  the code does today, as concrete "code must change to match the doc" items;
- **drifts and open questions** carried over from the capped interview (Phase 3);
- **things to revisit / re-check** — anything uncertain, assumed, or deferred;
- the migration / cleanup steps that must never live in the spec itself.

The two files split cleanly: the `.new.md` says what the feature *should be*, the
`.TODO.md` says what work that implies — it is the brief for the later implementer
agent. Give the owner a short pointer to it in chat too. (Prior-run `*.TODO.md`
files are ignored as sources — Phase 1 — so this never compounds across runs.)

## Rules

- This is **fix / clarify / complete**, not greenfield. Start from the existing
  docs and code.
- Honour the `<instructions>` block when present: scope the search to the named
  source files, write to the named output file, and treat `<changes>` as
  authoritative pre-answered clarifications.
- **Scope the output to this call's feature only.** The new doc is not a dump of
  every `.md` read — pull in only passages about the subject and cross-link the
  rest.
- **Relocation exception** (rare): a piece that fits this doc much better than its
  current home may be **moved** in (not copied) — editing the source to remove it
  only if it is one of this skill's own `*.new.md` outputs, never an original/
  authoritative doc (flag that in `.TODO.md`). Must be in the Phase 4 plan and
  approved first.
- One feature per run. If the prompt names several, ask which one, or do them in
  sequence.
- **The owner's interview answers and `<changes>` override docs and code.** When
  sources conflict with each other or with the owner, the owner wins.
- **Every doc↔code drift MUST be surfaced** — asked within the question rounds, or,
  if they run out, listed in the `.TODO.md` as an open question. Never resolved
  silently. (A `<changes>` item that already covers a drift counts as the answer.)
- **An `<instructions>`/`<changes>` item that conflicts with any source is
  top-priority** — explored toward full resolution, asked first, never applied
  silently. If still open after the round cap, flag it at the **top of the
  `.TODO.md`** and proceed.
- The `.new.md` describes the **wanted** state; the `.TODO.md` reports the **gap**.
  Never mix them. **Tag every decided-but-not-yet-built aspect `@TODO`** in the spec.
- **Always ask a full second round** (~2×4 questions), not just one batch —
  over-asking is cheap, a wrong baked-in assumption is not.
- Interview first, write second. Do not author a doc on an incoherent picture.
- **Present a plan and get the owner's approval (Phase 4) before writing any file**
  — newly decided / clarified / deduped-and-cross-linked / going-to-`.TODO.md`.
- Output goes to **`<docs_dir>/new/`**: the spec `<feature-area>.new.md` **and
  always** the companion `<feature-area>.TODO.md` (gaps / drifts / things to
  revisit). `<instructions>` can override the location; never overwrite the
  authoritative doc in place.
- **Ignore `*.TODO.md` sources** (prior-run punch-lists); read but don't duplicate
  `*.new.md` sources.
- Cite real file paths in your reconciliation and punch-list.
- Most questions are high-level/conceptual; low-level questions only for
  big-blast-radius choices.
- No sycophancy, no padding.

---

# Project documentation

Everything below is for humans maintaining this skill. It is not part of the
protocol.

## What this is

A user-invoked editorial workflow that **fixes, clarifies, and completes** the
scattered, partly-stale documentation of a single feature — merging the
authoritative docs, the non-authoritative docs, and the code into one clean,
coherent spec. It reconciles docs against code, then **interviews the owner to the
wanted end state** (typically a step ahead of the code), and the owner's answers
override every other source. The result is two files in `<docs_dir>/new/`: the spec
`<feature-area>.new.md` and an always-written `<feature-area>.TODO.md` punch-list of
the wanted-vs-actual gaps.

## How it relates to a project's docs-style skill

- **A docs-style skill** (when the project ships one) is the **house style** — the
  rules for *how* a doc reads (register, detail density, wanted-state-only).
- **`reconstruct-docs`** (this one) is the **process** — gather, reconcile,
  interview, plan-and-confirm, then author. It runs multiple question rounds and reads across the
  whole codebase, so it is a deliberate, heavyweight pass — **slash-only**
  (`disable-model-invocation: true`), invoked with `/docflow:reconstruct-docs` so it never
  fires by accident. In its final phase it **uses** the project's docs-style skill
  for the actual prose.

Reach for this skill when the goal is "let's reconstruct the docs for feature X —
figure out what it *should* be and write it properly," not "tweak this paragraph."

## Why interview to the wanted state

The owner's design intent runs ahead of the implementation, so transcribing the
current code would freeze that lag into the spec. The interview surfaces the
wanted-vs-actual gap and resolves it: the `.new.md` captures intent, and the
`.TODO.md` is the brief a later session uses to bring the code up to it. (Full
premise in the protocol's "Why this matters" section above.)
