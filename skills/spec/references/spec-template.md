# Spec template

Fill every section. Delete one only if it is genuinely empty for this feature. The spec
describes the **wanted state**; tag anything decided-but-not-yet-built `@TODO`.

```md
# <Feature> spec

## Context
[The WHY, in product/business terms - the problem, who it's for, what success looks
like. 2-5 sentences. This is the part reverse-engineered docs never have; it is the
reason this file exists. State it even when it feels obvious.]

## Docs update
[The concordance check made durable - the new documentation /docflow:accept folds into
the main docs once the feature ships. The main docs are the authoritative source, so
write this as real docs, not a changelist: flowing explanatory prose a reader could
understand without the old text open beside it.

One entry per main doc this feature touches:
- **path/to/doc.md** (name the section)
  - New text: the passage as the doc should read after this feature lands - actual
    documentation in the doc's own register, explaining how the feature works and how
    it is architected, ready to fold in nearly verbatim.
  - What changed: what the doc says today that this replaces or contradicts, and how
    the new architecture differs from the old (e.g. save() was fire-and-forget; now it
    returns a receipt id the caller must ack, because acks drive the retry queue).
    This is what lets accept remove the stale claims cleanly.

Call out "new area - no existing doc" explicitly where that's the case, and name the doc
that should carry it (or the new doc to create). This is where every clash with the
current docs gets resolved on paper, before any code moves.]

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
