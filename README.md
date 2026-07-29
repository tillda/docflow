# docflow

Spec-first, docs-driven development skills for [Claude Code](https://claude.com/claude-code),
built to pair with the [sous-chef](https://github.com/tomascupr/sous-chef) orchestrator.

**The durable artifact is the documentation - the spec writes it before the code; code
is derived from it, not the other way around.**

## The three skills

- **`/docflow:spec`** - surveys a feature's existing docs and code, interviews you to a
  coherent spec (erring toward more questions), and writes it to
  `docs/tickets/NNNN-<slug>.md`. The spec's spine is the feature's documentation
  written before the code; a build contract derived from it is what the implementer
  builds from.
- **`/docflow:accept`** - after the code ships and verifies, finalizes the spec against
  what actually shipped and places its documentation into your main docs, *from
  intent* - never reverse-engineered from the diff, and always owner-gated.
- **`/docflow:reconstruct-docs`** - editorial pass over an *existing* feature whose
  docs have gone stale: gathers all its docs and code, reconciles them, interviews
  you to the wanted end state, then writes a clean `<feature>.new.md` spec plus a
  `<feature>.TODO.md` punch-list of the wanted-vs-actual gaps into `<docs_dir>/new/`.
  Heavyweight and deliberate; slash-only, so it never fires by accident.

All three are **head-chef-only**: no delegation, no Codex, no setup. Pure planning and
documentation judgment.

## How it fits with sous-chef

docflow is the docs-driven *bookends*; sous-chef is the *engine* in between:

```text
/docflow:spec  →  /sous-chef:serve (or :fire)  →  /docflow:accept
   the spec          implement from it              place the docs into main docs
```

`/docflow:reconstruct-docs` sits beside this loop rather than in it: a docs-repair
pass for a feature that already exists, whose `.new.md`/`.TODO.md` output a later
session takes as the source of truth to bring the code and other docs up to.

The two plugins stay cleanly separated. docflow points *forward* at `/sous-chef:*`; it
never edits sous-chef. The one piece of glue that makes `serve` aware of the loop lives
in **your `CLAUDE.md`**, not in either plugin - so sous-chef stays pure upstream (no fork,
no merges). See [`templates/integration.md`](templates/integration.md) for the glue block
and where to put it.

## Install

```text
/plugin marketplace add tillda/docflow
/plugin install docflow@docflow
```

For local development, point the marketplace at your checkout instead:

```text
/plugin marketplace add /Users/mtill/Projects/docflow
/plugin install docflow@docflow
```

Then wire the loop by adding the glue block from `templates/integration.md` to your
`CLAUDE.md` (that guide covers where to put it and whether you need it). Install
sous-chef separately (see its README).

## Why a separate plugin

Separate responsibilities, separate plugins. docflow owns the spec/docs lifecycle and
carries its own namespace (`/docflow:*`), so it never collides with - or forks - the
sous-chef engine. Update either independently.

## License

MIT © Michal Till
