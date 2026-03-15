## Context

This repository contains a detailed Typst grammar catalog in
`src/tutorial/reference-grammar.typ`. The original change turned that tutorial
asset into a Codex skill, but the first implementation blended portable author
guidance with repo-local maintenance machinery. As a result,
`typst-grammar-authoring` now includes updater scripts, traceability artifacts,
and path examples that are not ideal for copying into another repository.

The revised direction is to separate those responsibilities:

- `typst-grammar-authoring` is the portable skill that authors use.
- `update-typst-grammar-authoring` is the repo-local maintenance skill that
  updates the portable one from canonical tutorial examples.

## Goals / Non-Goals

**Goals:**
- Keep `typst-grammar-authoring` as a self-contained, English-only,
  distributable skill with only `SKILL.md`.
- Keep grammar lookup and validation workflows available inside the portable
  `SKILL.md`.
- Move generator scripts, traceability data, and repo-specific maintenance
  instructions into `update-typst-grammar-authoring`.
- Eliminate Windows-specific command paths and other platform-specific path
  examples from the distributed `SKILL.md`.
- Preserve the ability to regenerate the portable skill from
  `src/tutorial/reference-grammar.typ`.

**Non-Goals:**
- Translate the full Chinese tutorial into English.
- Replace Typst's own compiler diagnostics with a custom parser or validator.
- Depend on Tinymist, VS Code, or any specific editor integration for required
  validation.
- Create a package manager or external publishing workflow for distributing the
  portable skill.

## Decisions

### Decision: Split authoring and maintenance into two skills

The repository will contain two skills with different responsibilities:

- `typst-grammar-authoring` for portable author guidance
- `update-typst-grammar-authoring` for repo-local regeneration and maintenance

Why this approach:
- It keeps the distributed skill easy to copy into other repositories.
- It lets the updater skill retain repo-specific scripts and source references
  without polluting the authoring skill.
- It makes it clearer which instructions are for end users versus maintainers.

Alternative considered:
- Keep one repo-local skill with embedded updater logic. Rejected because it
  mixes portability and maintenance concerns in the same artifact.

### Decision: Make the portable skill a single-file skill

`typst-grammar-authoring` will consist only of `SKILL.md`. It must not depend
on sibling scripts, references, or optional UI metadata to function after being
copied to another repository.

Why this approach:
- A single file is the easiest form to distribute and review.
- It minimizes accidental coupling to repo-local layout and helper artifacts.
- It keeps the authoring experience simple for downstream repositories.

Alternative considered:
- Keep `agents/`, `references/`, or `scripts/` alongside the distributed skill.
  Rejected because the user explicitly wants the authoring skill to remain only
  a Markdown file.

### Decision: Put all repo-specific updater assets under `update-typst-grammar-authoring`

The updater skill will own:

- regeneration scripts
- traceability artifacts
- repo-specific instructions that mention `src/tutorial/reference-grammar.typ`
- any maintenance-only metadata

Why this approach:
- It centralizes maintenance behavior in one place.
- It keeps downstream consumers from carrying unnecessary repo-specific files.
- It preserves exact source traceability without expanding the portable skill
  context.

Alternative considered:
- Leave traceability JSON and generator scripts under the portable skill folder.
  Rejected because those files are maintenance artifacts, not distributed
  authoring guidance.

### Decision: Use platform-neutral path examples in the portable skill

The distributed `SKILL.md` will use forward-slash, repo-relative, or placeholder
paths such as `path/to/document.typ` and `target/typst-grammar-authoring-check/document.html`.
It must not use Windows absolute paths or Windows-style backslash-only command
examples.

Why this approach:
- It keeps the skill readable across operating systems.
- It avoids downstream users mistaking repo-local Windows commands for required
  syntax.
- It makes the portable skill genuinely portable instead of just copyable.

Alternative considered:
- Keep PowerShell-oriented backslash paths because the repo is currently being
  edited on Windows. Rejected because the distributed skill should not inherit a
  single machine's path style.

### Decision: Keep the portable skill self-contained, but keep verbose traceability out of it

The portable skill will still embed a compact grammar lookup and validation
workflow inside `SKILL.md`, but verbose canonical references and source-line
traceability will live in updater-owned artifacts instead.

Why this approach:
- It preserves low-context usability for authors.
- It keeps the portable skill smaller than a fully traceable catalog.
- It still gives maintainers a way to audit generated entries precisely.

Alternative considered:
- Remove all generated grammar data from the portable skill and require a sidecar
  reference file. Rejected because the portable skill must remain single-file.

## Risks / Trade-offs

- A single-file portable skill is still larger than a minimal skill because it
  embeds grammar lookup content. → Mitigation: keep examples compact and keep
  verbose traceability in the updater skill only.
- Splitting the skills adds another artifact to maintain. → Mitigation: make the
  updater skill the clear owner of regeneration and validation steps.
- Portable path examples may drift back toward platform-specific syntax during
  updates. → Mitigation: add explicit tasks and verification for path style.

## Migration Plan

1. Create a repo-local `update-typst-grammar-authoring` skill under
   `.codex/skills/`.
2. Move generator scripts, traceability artifacts, and repo-specific update
   instructions into the updater skill.
3. Reduce `.codex/skills/typst-grammar-authoring/` to a single distributable
   `SKILL.md`.
4. Rewrite distributed validation commands and examples to use platform-neutral
   paths.
5. Verify the updater still regenerates the distributed skill correctly.

Rollback strategy:
- Restore the previous single-skill folder layout if the split causes an
  unacceptable maintenance burden.

## Open Questions

- None at proposal update time. The split between portable and maintenance
  skills is the intended direction.
