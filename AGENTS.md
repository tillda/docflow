# docflow

A Claude Code plugin: spec-first, docs-driven development skills that pair with the
sous-chef orchestrator. Markdown and JSON only - no build step, no code to compile.

## Map

- `.claude-plugin/` - plugin + marketplace manifests
- `skills/spec|accept/` - the two skills (each `SKILL.md` + optional `references/`)
- `templates/` - the `CLAUDE.docflow.md` glue snippet users append to their CLAUDE.md

## Working agreements

- docflow points forward at `/sous-chef:*`; it never edits the sous-chef plugin. The
  reverse glue lives in the user's `CLAUDE.md`, not here - keeps sous-chef pure upstream.
- Keep SKILL.md bodies short and goal-directed; this targets frontier models - no
  step-by-step scaffolding a strong model doesn't need.
- Frontmatter descriptions are third person, state what the skill does AND when to use
  it, under ~350 characters, no ": " (YAML plain scalars break on it - use " - ").
- Both skills are head-chef-only - no Codex, no delegation, no setup.
