---
name: docs-style
description: The house style for writing and revising documentation — specs, READMEs, design docs, any *.md. Study-notes register: bullet lists, numbered lists, definitions and tables for structured material; prose only where a longer explanation is genuinely needed. States precisely which technical content belongs in a doc and which never does, so implementation detail stays in the code where it belongs. Writes the wanted end state, with no history or migration archaeology. Use whenever you author or substantially revise a Markdown doc, or when the user asks to write, create, update, edit, revise, amend, append to, add to, extend, expand or fix a doc / docs / spec / README / design doc. Trigger phrases include "update docs", "amend docs", "append docs", "add to docs", "edit the doc", "write a spec", "document this". Ships the worked exemplar.
---

# Docs style — the house style

Apply it to every spec, README and design doc. This skill is itself written in the
style it describes.

It is **project-independent**: a good docs style does not change from codebase to
codebase. A project adds its own vocabulary and may name one of its own finished docs
as an extra sample — it never restates these rules.

The single rule, if you remember nothing else: **write study notes, not prose.**

## The register: study notes, not prose

- Default to **bullet lists, numbered lists, definitions, and tables** for any
  structured material.
- Use **paragraphs only where a longer explanation is genuinely needed**, and keep
  them to 1–3 short, easy-to-read sentences.
- If you have written three sentences of prose in a row, stop and ask whether it
  wants to be a list or a table.
- Easy sentences over dense ones — but not detail-free (see density below).

## Density

- Carry **about one programming detail per ~4 sentences** — no more, but not zero.
  The text should read easily yet stay anchored to real artifacts.
- Include only the **important** details, in this priority order:
  1. names of major config / data files — *most important* (e.g. `config/app.toml`
     and its `[webhooks]` block)
  2. names of modules or classes that are **seams** — meant to be used from other
     parts of the app (see [Technical content](#technical-content))
  3. variable names — *least important; usually omit*
- **Share of the text: about 1/4 technical, about 3/4 business, UI and behaviour.**
  When a doc grows, it grows in the business/UI/behaviour part. The technical share
  may run higher where there is genuinely that much high-level content — never by
  padding it with implementation detail.

## Technical content

The test, applied to every technical sentence: **would a refactor that keeps the
behaviour, the contract and the structure make this sentence wrong?** If yes, it is
implementation detail — cut it. The code and its comments own it.

### Keep in — high-level only

**Structure and seams**

- How the code separates into app domains, and which domain decides what.
- **Seam contracts** — judged by how over-arching the seam is. A module or class
  meant to be used from *other parts of the app* has a contract that belongs in the
  doc; the syntax of that contract tends to belong with it. A purely internal
  caller's contract does not.
- Directory and file-name conventions.
- Extension points: where the next feature plugs in.

**Data**

- **High-level data flow** — what is source, what is derived, what is cached.
- **Single source of truth** — when the same fact lives in two places, which one
  wins, and how the other is reconciled.
- **Relations and cardinality** — 1:M, N:M. Can one X have one Y or many?
- **Identity** — what identifies a thing, and what happens when that changes.
- The data structures and algorithms chosen, what they buy, which alternative lost.

**Behaviour**

- **Lifecycle and legal transitions** — the states a thing passes through and which
  moves between them are allowed.
- **Invariants a caller may rely on**, and what is deliberately *not* guaranteed:
  ordering, atomicity, idempotency.
- **Failure and re-run** — what a half-failed run leaves behind, what is safe to
  repeat, what must serialize against what.
- **Versioning and compatibility** — what must be bumped together, and what breaks
  when the pair drifts.
- **Units and conventions** — order, units, ranges (latitude before longitude;
  kilometres; which zoom range).

**Knobs**

- What is **meant to be edited by hand**, and what is generated.
- **Changeable constants** — which ones, and in which file they are written.
- **Which values come from config**, and where the config itself comes from.
- The **resource and scale envelope** — what it costs, where it stops working.
- **Warnings and pitfalls** — the mistake a reader would otherwise make.

### Never — a list, not a judgment call

- Function, method, variable, field, column or test names; signatures; parameter
  lists, defaults, types.
- Control-flow narration ("first it calls X, then Y").
- Code that reproduces logic. A fenced block showing a **file's shape** is fine.
- Error strings, log lines, line numbers, `file:line` references.
- Internal module paths; the contract of a purely internal caller; the full
  config-key list instead of the important keys.
- Null checks, try/catch, retries as mechanics.
- Library versions, unless the version *is* the contract.

## Worked scenarios

A handful of **worked use cases** for the genuinely complex paths, where a plain
description would leave the behaviour implicit. Writing the scenario is what forces
the omission out:

> **Deleting an entity.** `delete` sets a `deleted` flag rather than removing the
> row; the row is removed for real on the next `clear` event.

- They codify **testing and the feature's properties at once** — each one reads as a
  case a test can hold, and as the answer to a question the prose never asked.
- Keep them few and real. One per hard path, not a case per feature.
- Put them where the behaviour they pin is described, not in a trailing appendix.

## Wanted state only

- Write the doc as the **end state that will be true after implementation** — the
  then-current state, as if it already exists.
- **Do not** narrate history: no "previously", "currently", "this replaces X", "used
  to", "the old way", migration debris, or "what worked before".
- Migration and cleanup steps belong in a **plan or chat**, not in the doc.

## Structure

- A `#` title that names the thing (ALL-CAPS for a top-level spec is fine).
- `##` sections; each opens with the point, then gives the structured detail.
- **Numbered lists** for true enumerations and ordered steps.
- **Tables** for comparisons.
- **Definitions** as `**Term** — one-line meaning` bullets.
- Fenced code / YAML blocks to show a file's shape.
- An **Out of scope** section where it helps — a boundary cross-link list naming the
  neighbouring docs that own what this one doesn't.

## Don'ts

- No arrow-chains (`A → B → C`) or stacked technical nouns standing in for a
  sentence.
- No story framing ("here is the journey", "things that will bite you").
- No sycophancy or "overall well-architected" filler.
- No padding — if a section has nothing material, cut it.

## The worked exemplar

[references/example-project-doc.md](references/example-project-doc.md) is a finished
doc in this register. Read it before writing: it shows the share, the depth, and what
the technical quarter looks like when it stays high-level.

A project may name one of its own finished docs as an extra sample. That is a sample,
not a second rulebook — these rules decide.
