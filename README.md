# docflow

Spec-first, docs-driven development skills for [Claude Code](https://claude.com/claude-code),
built to pair with the [sous-chef](https://github.com/tomascupr/sous-chef) orchestrator.

## The problem: which way does the arrow point?

Between code and docs, one is always derived from the other - and most projects pick
the direction without ever deciding it.

**Docs from code** is the default, and it's a trap. Documentation written after the
fact is reverse-engineering: it comes out over-technical, drowned in identifiers,
missing the business reason - a description of what got built, not of what was
wanted. And it starts rotting on the very next commit. Docs like that earn no trust,
so nobody reads them, so nobody maintains them, and the only source of truth left is
the code itself - which can tell you *what*, but never *why*.

**Code from docs** is the direction worth having. The intent in the owner's head runs
ahead of the implementation - it always does. Write that intent down first, as
documentation of the wanted state, and *that* becomes the durable, valuable artifact;
code is cheap to regenerate from it (never more so than with an LLM implementer). The
docs stay the living source of truth, and the code catches up to them - not the other
way around.

docflow makes that second direction structural instead of aspirational: the spec *is*
the feature's documentation, written before any code; the implementer builds from it;
and once the feature ships, that same prose lands in your main docs.

## The three skills

- **`/docflow:spec`** - *writes the docs before the code.* Surveys a feature's
  existing docs and code, interviews you to a coherent spec (erring toward more
  questions), and writes it to `docs/tickets/NNNN-<slug>.md`. The spec's spine is the
  feature's documentation written before the code; a build contract derived from it
  is what the implementer builds from. An owner-confirmed Scope sets what this build
  delivers and what it must not start, so the implementer polishes what was asked
  instead of building what wasn't.
- **`/docflow:accept`** - *closes the loop after the code ships.* Once the feature
  verifies, finalizes the spec against what actually shipped and places its
  documentation into your main docs, *from intent* - never reverse-engineered from
  the diff, and always owner-gated.
- **`/docflow:reconstruct-docs`** - *repairs docs that already drifted.* An editorial
  pass over an *existing* feature whose docs have gone stale: gathers all its docs
  and code, reconciles them, interviews you to the wanted end state, then writes a
  clean `<feature>.new.md` spec plus a `<feature>.TODO.md` punch-list of the
  wanted-vs-actual gaps into `<docs_dir>/new/`. Heavyweight and deliberate;
  slash-only, so it never fires by accident.

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
