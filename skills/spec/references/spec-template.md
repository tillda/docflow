# Spec template

Fill every section. Delete one only if it is genuinely empty for this feature. The spec
describes the **wanted state**; tag anything decided-but-not-yet-built `@TODO`. The
`Documentation` section is the spine - write it first; derive `Build contract` from it.

```md
# <Feature> spec

## Context
[The WHY, in product/business terms - the problem, who it's for, what success looks
like. 2-5 sentences. This is the part reverse-engineered docs never have; it is the
reason this file exists. State it even when it feels obvious.]

## Documentation
[The spec's spine - the feature's documentation, written before the code. One entry
per main doc this feature touches; /docflow:accept places these entries nearly
verbatim once the feature ships. Write real docs, not a changelist: wanted-state
prose a reader understands without the old text open beside it, in each target doc's
own register - the project's docs-style skill if it ships one, else the surveyed
docs' voice, with depth calibrated against references/example-project-doc.md
(business/UI/behaviour lead ~3/5; technical reasoning ~2/5; implementation
identifiers sparse and selective).

- **path/to/doc.md** (name the section)
  - New text: the text as the doc should read after this feature lands - ready to
    place nearly verbatim, at whatever length the design needs.
  - What changed: what the doc says today that this replaces or contradicts, and how
    the new design differs from the old. This is what lets accept remove the stale
    claims cleanly.

A new area with no existing doc gets an entry like any other: name the new doc and
write its full text here - naming a destination without writing the text is not an
entry. Together the entries must fully document the feature: after accept places
them, the main docs alone explain it as if it had always been there, with nothing
left that lives only in this spec's other sections, the chat, or the code.]

## Build contract
[Derived from Documentation - the documentation made checkable, the one thing the
implementer takes and builds. Every line here traces to something Documentation
describes; if the implementer needs more, the Documentation is incomplete - fix it
there first. Identifier-dense is right here: this section is for the implementer,
not the docs.]

- Scope
  - In: [what this feature covers]
  - Out: [what it deliberately does not - the boundary that stops scope creep]
- Interfaces / contracts
  [Exact signatures, types, API shapes, data structures, or config keys other code
  depends on. Paste real code, not prose. This feeds the ticket's <interfaces>.]
- Done-when
  - [Checkable criterion, e.g. "pnpm test passes, incl. N new tests covering X"]
  - [Checkable criterion, e.g. "GET /api/foo returns 200 with shape {…}"]
  [These feed the ticket's <done_when> and the tests - declarative success criteria,
  not steps.]

## Decisions
[ADR-lite - only the choices that actually had alternatives. For each:
- Decision - what was chosen.
- Alternatives - what was considered.
- Why - the reason, in one or two lines (often an interview answer).
Skip obvious, no-alternative choices.]

## Open questions
[Resolved: Q - the answer decided in the interview (kept so the reasoning survives).
Still open: anything unsettled when the interview hit its round cap, flagged for the
implementer to surface rather than guess. Empty is fine if nothing is open.]
```
