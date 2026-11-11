# docflow

A Claude Code plugin: spec-first, docs-driven development skills that pair with the
sous-chef orchestrator. Markdown and JSON only - no build step, no code to compile.

## Map

- `.claude-plugin/` - plugin + marketplace manifests
- `skills/docs-style/` - the house style every other skill writes in, plus
  `references/example-project-doc.md`, the register/depth exemplar
- `skills/spec|accept|reconstruct-docs|audit/` - the four workflow skills (each
  `SKILL.md` + optional `references/` - spec ships the spec template)
- `templates/` - `integration.md` - how and where to wire the docflow-sous-chef loop into CLAUDE.md

## Working agreements

- docflow points forward at `/sous-chef:*`; it never edits the sous-chef plugin. The
  reverse glue lives in the user's `CLAUDE.md`, not here - keeps sous-chef pure upstream.
- Dispatch is owner-gated: a handoff that starts a build names the command, the
  implementing model and the read-only critique in one line, and that line, OK'd, is the
  OK - an incomplete one is asked once first. Standing routing policy never substitutes
  for it, and read-only survey subagents are outside the gate.
- The spec's structure is Documentation (spine) → Build contract (derived) → Record
  (provenance); keep skill edits consistent with that hierarchy.
- Keep SKILL.md bodies short and goal-directed; this targets frontier models - no
  step-by-step scaffolding a strong model doesn't need.
- Frontmatter descriptions are third person, state what the skill does AND when to use
  it, under ~350 characters, no ": " (YAML plain scalars break on it - use " - ").
- Spec synthesis, interviews and acceptance stay with the Claude lead; read-only
  survey subagents are allowed. No Codex implementation delegation during planning.
- `audit` is the one skill that fans out, and only into further Claude sessions -
  an owner interview cannot be answered by a subagent. It starts one at a time and
  asks the owner before a second. A part session never messages its parent on its
  own initiative - the parent cannot answer for that part, so it would only re-ask
  the owner in a second thread; being stuck is offered to the owner as an option in
  the session's own question instead.
- `audit`'s discovery stage is `reconstruct-docs` cut down (gather, reconcile, light
  interview, stop) and stays read-only; its fix stage is owner-released and scoped
  to what a finding describes. Authoring or rewriting a whole feature's docs stays
  `reconstruct-docs`'s job - keep that line where it is.
