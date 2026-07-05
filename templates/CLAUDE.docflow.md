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
  finalizes the spec against what actually shipped and folds its `Docs delta` into the
  main docs (owner-gated; never a silent overwrite).
- The numbered spec is a frozen per-feature record committed with the feature; the main
  docs stay the living source of truth.
