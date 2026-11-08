---
name: audit
description: Whole-app documentation audit — splits the app into parts and checks each part's docs against the code that shipped, one session per part. Discovery is read-only and ends in a drift report; the owner then releases which findings that same session fixes. Invoked as /docflow:audit, or /docflow:audit part <name> inside a part session.
disable-model-invocation: true
---

# Audit — does every doc still describe the app we have?

A whole-app sanity check and status report. `/docflow:spec` → code →
`/docflow:accept` runs one way only, and `/docflow:reconstruct-docs` repairs one
feature at a time. Nothing checks the **whole** app's docs against what actually
shipped. This does.

The pass **records the drift before it changes anything.** Discovery is read-only —
no `.new.md`, no doc rewrites, no refactors — and it ends in one short drift report
per part. The owner reads that report and releases which findings get fixed; the
same session then fixes what it was released, and the report goes away with the fix.

It is invoked explicitly, and has **two roles**:

| Invocation | Role | What it runs |
| --- | --- | --- |
| `/docflow:audit [instructions]` | **lead** | split the app into parts, then run them one part at a time |
| `/docflow:audit part <name>` | **part session** | audit that one part and write its report |

Any text after the command is **instructions** — ordinary prose, no fixed format.
It may name the parts, cap their number, point at the docs directory, restrict the
audit to one plane of the app, or pre-answer a question. Honour it; it is the owner
talking.

## Where this stops

The protocol is [reconstruct-docs](../reconstruct-docs/SKILL.md) cut down to its
reconciliation half — that skill's Phase 1 (gather), Phase 2 (reconcile) and a
**light** Phase 3 (interview). It stops before Phase 4's plan and Phase 5's
authoring.

| reconstruct-docs | audit |
| --- | --- |
| one feature | every part of the app |
| interviews to the **wanted** state | asks only where the sources genuinely disagree |
| five question rounds | one round minimum, three at most |
| writes `<feature>.new.md` + `.TODO.md` | writes `<part>.md`, a disposable drift report |
| the doc is the deliverable | the **punch-list**, then the fixes the owner releases |

Expect **small** drift where recent work was specced and the app works: wording that
aged, options that got renamed, a number that moved. The most valuable find is a
part that was **built with no doc at all** — a devtools bar, a debug overlay, a CLI
verb nobody wrote down. Those get recorded as gaps even when nothing is wrong.

## The premise: the code is not the authority

Carried over from reconstruct-docs unchanged. The code is good evidence of what
works today, and it lags behind where the owner's head is. So a doc↔code disagreement is
**never silently resolved toward the code** — it is asked, or it is recorded.

In practice the docs are usually the side that moves, because the app works now.
That is an expectation, not a licence to assume it: ask when the right side is not
obvious.

---

# Role 1 — the lead

## 1. Split the app into parts

A **part** is a coherent slice of the app with its own docs and its own code. Aim
for **6–12 parts**; fewer and a session reads half the repo, more and the run never
ends.

Derive them from the repo, in this order of evidence:

1. The docs' own grouping — the index, the `AGENTS.md` Map, the table of
   authoritative contracts, the directory layout under the docs directory.
2. The code's planes and top-level directories.
3. The owner's instructions, which override both.

For each part, record: a **name**, its **anchor docs** (real paths) and the **code
area** it covers. Anchors are a starting point, not a fence — a part follows what
it really covers, and says in its report when a doc belongs to a neighbour instead.

Then **confirm the split with the owner** before starting any session: one table,
plus the order you mean to take the parts in. Ask with `AskUserQuestion` where a
slice could reasonably go either way. A wrong split is expensive — it is what makes
two parts collide over the same files, and what decides whether a second concurrent
session is ever safe to offer.

## 2. One worktree, one timestamped report directory

- **Worktree.** Create one for the audit (the project's own worktree command; a
  plain `git worktree add` where it has none) and run every part session in it.
  Reports are short-lived — they get fixed right away — so they never belong on
  `main` while the pass is running.
- **Report directory.** `<docs_dir>/audit/<YYYY-MM-DD>/`, one file per part,
  `<part>.md`, where `<docs_dir>` is the project's standard docs directory
  (typically `docs/`). The date keeps one run's punch-list from overwriting
  another's, and dates it for the owner, who triages it within days.
- **Index.** Write `<docs_dir>/audit/<YYYY-MM-DD>/README.md`: one table — part name
  · report file · anchor docs · code area · **state** — and one line pointing at
  this skill for the protocol. Do not restate the protocol there; a part session
  reads it from here. Keep the state column current (`pending` / `auditing` /
  `reported` / `fixed`); it is how the owner reads progress, and how you know which
  part to start next.

## 3. Run the parts one at a time

**Sessions, not subagents** — `start_session`, so each part appears in the sidebar
and its questions are answered in its own thread. A subagent cannot interview the
owner, and the interview is where the value is.

- **Start exactly one session on your own.** The next part's session starts only
  when the current part is finished — its interview answered, its report written,
  and whatever fixing the owner released carried out. One part in flight is the
  default state of this pass.
- **A second concurrent session is offered, never assumed.** Where two parts are
  genuinely independent — no shared docs, no shared code — you may **propose** one
  and start it **only on the owner's explicit OK**: ask with `AskUserQuestion`, or
  put it up as a session proposal the owner starts themselves. Two at once is the
  ceiling even then, because two open interviews are already near the limit of what
  anyone can answer in order, and a session that has reached its fix stage is
  writing files in a shared worktree.
- Each session **shares the audit worktree** and works on a **non-overlapping** set
  of docs and code. With one session in flight this is nearly free; it is what makes
  an owner-approved second session safe.
- Each brief is short, because the protocol lives here. It carries: the part name,
  its anchor docs and code area, the report path, the run's index path, the command
  to run — `/docflow:audit part <name>` — and the findings a finished neighbour
  flagged for this part. Where the plugin command is not available in a started
  session, give the brief this file's absolute path to read instead.
- **Every brief carries the silence rule, in these terms: ask your own questions in
  your own session with `AskUserQuestion`, and never message the parent session on
  your own initiative** — not questions, not progress, not findings to relay. The
  owner answers in your thread and reads your report. Where you are genuinely stuck
  and believe the parent has to be told, **offer that as an option in your own
  question and send it only if the owner picks it.**

**Audit one part yourself first**, before any session starts, if the split is at all
uncertain. It costs one part and it proves the whole run: whether the parts are the
right size, whether the anchors hold, and what a report of this app actually looks
like. Its report then goes in the first session's brief as the worked example.

## 4. Collect

After each part, and once more at the end:

- Update the index's state column. Read the finished report's **For the neighbours**
  items and put each one into the brief of the part that owns it — or, when that
  part is already done, record it in the index as outstanding.
- Give the owner one line per finished part — verdict · counts by severity · fixed
  or left · whether it wants a reconstruction — and point at the report. The report
  holds the detail; do not restate findings in chat.
- Name any part that came back **undocumented** separately. That is the finding the
  owner most needs to see.
- When every part is reported and its released fixes have landed, the run directory
  has served its purpose. Say so and offer to remove what is left of it; what the
  owner has not triaged yet stays.

---

# Role 2 — a part session

Invoked as `/docflow:audit part <name>`. You own **one part**, in two stages with
the owner's triage between them.

| Stage | What you do | What gates it |
| --- | --- | --- |
| **A — discovery** | gather, diff, interview, write the report | nothing; it is read-only |
| **B — fix** | fix the findings the owner releases, in this part only | the owner, after reading the report |

Stage A is **strictly read-only**, and the discipline below says what that forbids.
The reason is not caution for its own sake: a session that starts fixing while it is
still forming the picture files worse findings, and touches files the split never
gave it. Stage B is ordinary work, in the same session, with the whole picture still
in context — which is exactly why the fixing belongs here and not in a fresh session
that would have to re-derive it.

## Stage A — discovery, in five steps

1. **Gather.** Read the part's anchor docs **in full**. Find the code that
   implements them — modules, UI components, config keys, data files, wire
   contracts, CLI verbs. `Explore` subagents in parallel for breadth; cite real
   paths.
2. **Two models.** What the docs *claim* the part is and does; what the code
   *actually* does.
3. **Diff**, grouped: contradictions · documented-but-absent · built-but-undocumented
   · ambiguous in both. Agreements are not findings — one line saying the rest
   checks out.
4. **Ask** where the sources disagree and the right side is not obvious.
   `AskUserQuestion`, 4 per call, **one round minimum, three at most**. A bigger
   discrepancy earns the further rounds. High-level and plain-English — "the doc
   says the overview auto-downloads, the code needs a button — which is wanted?",
   never "should we call `refresh()` synchronously?" **Asking is cheap and the
   answers are the most valuable input the pass gets** — ask whenever the drift is
   genuine, even when you think you know the answer. Anything the rounds do not
   settle goes into the report's **Open questions**, never decided quietly.
5. **Write** the report, then put it to the owner. Discovery ends there; stage B
   starts only on their answer, and does not start at all if it does not come.

## Wording a drift question

The owner is picking a **winner between two sources**, so name the sources. Every
option that is a side of a doc↔code disagreement opens with one of these two exact
phrases, followed by what that side actually says:

- `CODE is right: <what the code does, in plain English>`
- `DOCS are right: <what the doc claims, in plain English>`

Use the formulation wherever it fits. An option that is neither side — a third
behaviour the owner might want instead — is worded plainly and comes last.

## Your questions are yours to ask

A question about your own part is asked in **your** session, with `AskUserQuestion`,
and nowhere else. **Never message the parent session on your own initiative** — not
questions, not progress, not findings to relay, not "the owner should decide" in the
hope that someone upstream runs the interview.

The reason is worth knowing, because it is not about tidiness. The parent **cannot
answer** a question about your part; it has no context for it. So it does the only
thing it can — it asks the owner, in *its* thread, while the owner is already
answering you in yours. One question, two threads, and no way to tell where to
answer what. That is the mess each part's own session exists to prevent, and a
message upstream recreates it.

So:

- **A question about your part** — ask it yourself, in your thread.
- **Still open at the round cap** — it goes under **Open questions** in the report.
  That is a record, not a hand-off: nobody upstream is expected to run the interview
  you did not finish.
- **A finding that belongs to another part** — **For the neighbours** in the report,
  naming that part. The lead reads it there and carries it into that part's brief.
  Nothing needs to be sent for that to work.
- **Genuinely stuck** — your part turns out to belong to another session, the brief
  contradicts what you find, something outside your part blocks you, the worktree is
  wrong. Do not go quiet and do not go upstream on your own. **Put it to the owner in
  your own thread, and offer the upstream message as one of the options.** If they
  pick it, send it; if they answer the question instead, you never needed it. The
  owner decides whether a second thread opens — every time.

## What an interview answer changes during discovery

Nothing in the code, and in the docs one thing only:

- A **small** doc edit the owner just decided — a wrong sentence, a stale number, a
  table row — may be applied on the spot. The report records it as **fixed**, with
  the paths.
- Everything else stays a finding, even where the owner has already called the
  decision. Record the decision **with** the finding, so stage B does not re-ask it.

## Stage B — fix what the owner releases

The report is not the end of the session; it is the hand-over to the owner, who
decides what gets fixed now. Nothing here starts before they answer.

- **Ask once, with the report in front of them** — which findings to fix now, which
  to leave. `AskUserQuestion`, in your own thread, as ever.
- **Fix only your own part's released findings.** A finding for a neighbour stays a
  finding; it belongs to that part's session. An unreleased finding stays written
  down, untouched.
- **The cap on code changes is lifted here** — stage A's one-to-three-line limit was
  a discovery rule. A released finding is fixed properly, on whichever side the
  owner named: usually the docs, because the app works, and the code where the owner
  said the code is wrong. The fix stays scoped to what the finding describes; one
  that turns out to need a feature's worth of work goes back to the owner rather
  than into a quiet rewrite.
- **A whole-part rewrite is still not yours.** Where the docs and the code have to
  move together across several pages, the `## Suggested reconstruction` block is the
  answer and the owner runs it. Do not attempt it as a fix.
- **Verify what is cheap to verify** — the project's documented typecheck, lint or
  unit command for the code you touched. Still no builds, no GUI, no data commands.
  Where a change could only be confirmed by one of those, say so plainly instead of
  claiming it works.
- **Then the report is spent.** Delete it in the same commit that lands the fixes;
  it was a punch-list, and a punch-list whose items are done is a stale document
  that reads like current truth. Keep only the parts the owner left unreleased — if
  anything remains, trim the file to those findings instead of deleting it, and say
  which you did.
- Commit with the `--only` discipline below, after the owner approves, and name both
  the fixes and the report's removal in the message.

---

# The discipline

The first two items are **stage A rules** — discovery only. Stage B lifts them as
described above, once the owner has released the findings. Everything after them
holds for the whole session.

- **No fixes during discovery.** No doc rewrites, no `.new.md`, no code edits. Two
  exceptions, each named in the report with its paths: a small doc correction the
  owner just decided, and an **outright bug worth a one-to-three-line fix**. Anything
  larger is a finding, and gets fixed in stage B or not at all.
- **No builds, no GUI, no data commands, no tests during discovery.** Where a claim
  could only be settled by running something, say so in the finding. In stage B the
  project's cheap checks are available for code you changed; builds, the GUI and
  data commands never are.
- **Git: `--only`, or you take someone else's work.** Sessions share one checkout
  and **one index**. The hazard is not `git add -A` — it is that another session's
  files may already be **staged** when you arrive, and then a plain `git commit`
  sweeps everything staged, not just what you added. Staging your own paths first
  does not save you.

  So the only safe form names your paths at commit time. `--only` refuses a path
  git has never seen, so a brand-new report file needs `git add -N` first — it
  records the intent to add without staging any content:

  ```bash
  git add -N <docs_dir>/audit/<date>/<part>.md
  git commit --only <docs_dir>/audit/<date>/<part>.md <the-doc-you-fixed>.md -m "…"
  ```

  Never `git add -A`, never `git commit -a`, never a bare `git commit`, never `git
  stash` (the stack is shared too), never push. Check `git status --short` before
  and after; if the commit's file list is longer than your own paths, you took
  someone's work — say so at once rather than quietly repairing it.

  A stage B commit names the same way — the docs and code it fixed, plus the report
  file whose deletion it carries:

  ```bash
  git commit --only docs/<fixed>.md <code-you-fixed> <docs_dir>/audit/<date>/<part>.md -m "…"
  ```

  **Ask the owner before committing at all**, and end the report with a **Suggested
  commit** line: the subject plus the exact paths you touched.
- **Not audited as docs:** the spec archive (`docs/tickets/` or wherever specs are
  numbered — that is history), `*-TODO.md` and `docs/new/` (punch-lists from earlier
  reconstruct-docs runs). Read them for context; a finding already recorded there is
  worth noting as such, not re-litigating.
- **No house-style policing.** [docs-style](../docs-style/SKILL.md) owns the style
  and its technical requirements move on, so most existing pages diverge from it
  somewhere. Filing that would never end. Judge a page on whether it is **true**,
  not on whether it is in style. The one thing worth raising is a **genuine content
  gap** the style rules make obvious — a contract with no stated owner, a behaviour
  with no stated trigger — and that goes to the owner as a question, not as a style
  finding.
- **No test back-fill.** Do not propose documenting existing test cases, and do not
  file "this behaviour has no test" as a drift finding. Unifying tests with docs is
  separate, owner-driven work. A test that **contradicts** a doc is a real finding;
  a missing one is not.

# The report

`<docs_dir>/audit/<YYYY-MM-DD>/<part>.md`. It is a **working document with a short
life**: the owner triages from it, stage B works through it, and it is deleted with
the commit that lands the fixes. Short-lived is not the same as loose — every
finding must be actionable without re-deriving it, because the reader may be the
owner deciding, you after a context-losing gap, or a later session the owner hands
it to. Keep it tight: a table where a finding fits one line, a short block where it
needs a paragraph.

```markdown
# <Part> — documentation audit

**Verdict:** one sentence. Healthy / minor drift / one real problem / undocumented.
**Docs read:** paths. **Code read:** the areas, not every file.

## Findings

### 1. <what is wrong, as a claim> — ⚠️ · fix the doc
- **Doc says** — `docs/x.md:120`: "…"
- **Code does** — `client/src/y.ts:88`: …
- **Wanted** — the owner's answer, or your reading with its confidence.
- **Fix** — which side changes, and roughly how big.

## Undocumented
What exists in code that no doc mentions, each with its paths and whether it
deserves a doc, a paragraph in an existing doc, or nothing.

## For the neighbours
Findings that belong to another part, each naming that part.

## Open questions
Anything the rounds did not settle.

## Checks out
One short list of the claims that verified, so the next reader skips them.

## Suggested commit
The subject line plus the exact paths this session touched.
```

**Severity:** 🔴 the doc would mislead someone into breaking something · ⚠️ wrong
but harmless · 🔵 stale wording, naming, or an aged example. Pair each one with
which side changes — *fix the doc* or *fix the code*.

## Enough context that the fix lands

Write every finding as if the fixer has **only** the report and none of your reading
of the part. That is literally true when the owner hands it to another session, and
near enough when stage B resumes after a long triage. So each finding carries,
inline, the material a fix needs:

- The **quoted doc sentence** with `path:line`, long enough to locate by search
  after the file shifts — never a line number alone.
- The **code fact** with `path:line`, and the actual value, name or branch, not a
  summary of it. Numbers, enum names, config keys, CLI flags: spelled out.
- **Where the fix lands** — which file and which section, and whether a
  neighbouring doc states the same thing and must move with it.
- **How big** — "one sentence", "one table row", "a short paragraph", "a rewrite of
  the section".

Length is not the constraint; vagueness is. The reader is an LLM with a large
context window, so a finding may run to a paragraph and a table where that is what
it takes. A finding a fixer must re-derive from scratch is a finding that will not
get fixed. Over-detailed is a lesser sin than ambiguous — but a finding that
restates the whole doc helps nobody either.

## When a part needs a real reconstruction

Some parts are not fixable finding-by-finding: the docs and the code have drifted
together across several pages, and both sides need moving. Do not spell that out as
twenty findings. End the report with a ready-to-run hand-off the owner can paste,
or hand to a session:

```markdown
## Suggested reconstruction

/docflow:reconstruct-docs <feature name>

<sources: the exact doc and code paths>
<changes: every decision the owner already made in this part's interview>
<what the new doc must settle that this audit could not>
```

Write it only when a finding-list genuinely will not do, and say in one sentence
why. Everything the owner decided in the interview goes into the `changes` block,
so the reconstruction does not re-ask it.

# Rules

- **Two roles, one skill.** `/docflow:audit` is the lead; `/docflow:audit part
  <name>` is a part session. A part session audits its part only.
- **Discovery records; the fix comes after.** Stage A changes nothing but a small
  doc correction the owner just decided and a one-to-three-line fix to an outright
  bug, both named in the report. Stage B fixes the findings the owner **releases**,
  properly and without that cap, in the same session.
- **Stage A is read-only:** no builds, no GUI, no data commands, no tests. Stage B
  may run the project's cheap checks on code it changed; never a build, the GUI or a
  data command.
- **The report is disposable.** It goes away in the commit that lands its fixes,
  trimmed to the findings the owner left unreleased if any remain.
- **The code is not the authority.** Every doc↔code drift is surfaced — asked in a
  round, or listed under Open questions. Never resolved silently toward the code.
- **Drift questions name their source**: `CODE is right: …` / `DOCS are right: …`.
- **Each session asks its own questions** with `AskUserQuestion`, in its own thread,
  and **never messages the parent on its own initiative** — the parent cannot answer
  for your part, so it would only re-ask the owner in a second thread. Stuck? Offer
  the upstream message as an option in your own question and send it only if the
  owner picks it. A finding for a neighbour goes in the report, not upstream.
- **6–12 parts, confirmed with the owner.** The lead starts **one** session at a
  time; a second runs only when the owner explicitly OKs the one you offered.
- Reports go to `<docs_dir>/audit/<YYYY-MM-DD>/<part>.md` in an audit worktree,
  with a short index README beside them.
- **Shared index:** `git add -N` then `git commit --only <your paths>`, after the
  owner approves. Never `add -A`, `commit -a`, a bare `commit`, `stash`, or a push.
- **No style policing, no test back-fill.** Judge a page on whether it is true.
- An undocumented part is a finding in its own right, and usually the best one.
- No sycophancy, no padding.

---

# Project documentation

Everything below is for humans maintaining this skill. It is not part of the
protocol.

## What this is

The whole-app counterpart to `/docflow:reconstruct-docs`: a meta-pass that splits
the app into parts and reconciles each part's docs against its code, one session per
part, one session at a time. Discovery stops at reconciliation — no authoring — so
what reaches the owner is a punch-list they triage; the same session then fixes what
they release, and the punch-list is thrown away with it.

## How it relates to the other skills

- **[`reconstruct-docs`](../reconstruct-docs/SKILL.md)** owns the per-feature
  repair, and this skill's discovery stage is that one cut down to Phases 1–3. The
  division is by size, not by direction: audit fixes what a finding can describe,
  and when a part needs the docs and the code moved together across several pages,
  its report ends with a ready-to-run `/docflow:reconstruct-docs` invocation instead
  of trying to express that as findings.
- **[`docs-style`](../docs-style/SKILL.md)** is not enforced here. Audit judges
  whether a doc is **true**; style divergence in existing pages is out of scope by
  design, or the pass would never finish.
- **`spec` / `accept`** run forward, per feature. Audit is the only backward pass
  over the whole app, and the only one that reports status rather than changing
  something.

## Why sessions instead of subagents

A part session interviews the owner, and a subagent cannot. Sessions also appear in
the sidebar, so each part's questions are answered in its own thread, in order —
which is why only one runs unless the owner OKs a second. The cost is a shared
checkout and a shared git index, hence the `--only` discipline in the protocol; it
matters more now that a session also writes fixes.
