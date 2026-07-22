# Integrating docflow with sous-chef

docflow and sous-chef are **separate plugins**, wired one way out of the box: docflow's
skills point at `/sous-chef:*`, but sous-chef (pure upstream) doesn't know docflow
exists. This file is the **optional glue** that closes the loop - a short block you add
to your Claude instructions so Claude threads `spec → serve → accept` on its own,
*without ever editing the sous-chef plugin*.

## Do you even need it?

- **Without it, everything still works** - you just drive the handoffs yourself: run
  `/docflow:spec`, then tell Claude "serve this from the spec at `docs/tickets/00NN-…`",
  then run `/docflow:accept`.
- **With it**, Claude does those handoffs by standing policy: `/sous-chef:serve` derives
  its ticket from your spec and offers `/docflow:accept` once the code is green.

It's a convenience, not a requirement. Add it when the manual handoffs start to feel
tedious.

## Where to put it

The glue is Claude-orchestration policy, so it belongs wherever Claude reads standing
instructions. Pick the scope that matches how widely you run the loop:

| Put the block in… | Applies to | Choose when |
|---|---|---|
| `~/.claude/CLAUDE.md` | every project on this machine | you use the loop across most of your repos (recommended) |
| a repo's `./CLAUDE.md` | just that one repo | only some projects follow this loop |
| a repo's `./AGENTS.md`, imported via `@AGENTS.md` in its `CLAUDE.md` | that repo | you already keep repo standards in `AGENTS.md` and want this beside them |

On two machines, add it to each machine's `~/.claude/CLAUDE.md` - or keep that file in
synced dotfiles so it travels with you.

## The block

Copy the fenced block below into whichever file you chose:

```md
## Docs-driven loop (docflow + sous-chef)

The durable artifact is the spec; code is derived from it, not the other way around.

- **Spec before code.** For a new feature or design-ambiguous work, run `/docflow:spec`
  first - it interviews you into a numbered spec at `docs/tickets/NNNN-<slug>.md`.
- **Implement from the spec.** `/sous-chef:serve` (or `/sous-chef:fire`) derives its
  ticket *from* that spec: pull the spec's done-when, interfaces, and constraints into
  the ticket, scoped to the run, and cite the spec path so Codex reads the full intent
  firsthand. The scoping is yours, not Codex's - a spec may carry `@TODO` parts not in
  this run.
- **Close the loop.** After the code ships and verifies, offer `/docflow:accept` - it
  finalizes the spec against what actually shipped and folds its `Docs update` into the
  main docs (owner-gated; never a silent overwrite).
- The numbered spec is a frozen per-feature record committed with the feature; the main
  docs stay the living source of truth.
```
