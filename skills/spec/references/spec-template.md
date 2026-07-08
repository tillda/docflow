# Spec template

Fill every section. Delete one only if it is genuinely empty for this feature. The spec
describes the **wanted state**; tag anything decided-but-not-yet-built `@TODO`.

```md
# <Feature> spec

## Context
[The WHY, in product/business terms - the problem, who it's for, what success looks
like. 2-5 sentences. This is the part reverse-engineered docs never have; it is the
reason this file exists. State it even when it feels obvious.]

## Docs delta
[The concordance check made durable - and the exact changelist /docflow:accept applies
back into the main docs once the feature ships. The main docs are the authoritative
source, so this is the section accept edits *from*: make it precise enough to apply
directly, never a hint that sends accept back to reverse-engineer the diff. It need not
be long, but it must be specific.

One entry per existing main doc this feature touches:
- **path/to/doc.md**
  - Now: what the doc states today - the old abstraction, contract, or claim, cited by
    section so accept can find the spot.
  - Wanted: what it should state instead - the new abstraction/contract, written the way
    the doc should read.
  - Delta: the precise change, tagged add / override / reconcile - which section grows,
    which sentence is overturned and by what, which two claims get squared. Name old and
    new wherever a contract or term shifts (e.g. save() was fire-and-forget; now it
    returns a receipt id the caller must ack).

Call out "new area - no existing doc" explicitly where that's the case, and name the doc
that should carry it. This is where every clash with the current docs gets resolved on
paper, before any code moves.]

## Decisions
[ADR-lite - only the choices that actually had alternatives. For each:
- Decision - what was chosen.
- Alternatives - what was considered.
- Why - the reason, in one or two lines (often an interview answer).
Skip obvious, no-alternative choices.]

## Scope
- In: [what this feature covers]
- Out: [what it deliberately does not - the boundary that stops scope creep]

## Interfaces / contracts
[Exact signatures, types, API shapes, data structures, or config keys other code
depends on. Paste real code, not prose. This feeds the ticket's <interfaces>.]

## Done-when
- [Checkable criterion, e.g. "pnpm test passes, incl. N new tests covering X"]
- [Checkable criterion, e.g. "GET /api/foo returns 200 with shape {…}"]
[These feed the ticket's <done_when> and the tests - declarative success criteria,
not steps.]

## Open questions
[Resolved: Q - the answer decided in the interview (kept so the reasoning survives).
Still open: anything unsettled when the interview hit its round cap, flagged for the
implementer to surface rather than guess. Empty is fine if nothing is open.]
```
