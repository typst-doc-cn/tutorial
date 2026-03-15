## Why

The current `typst-grammar-authoring` implementation mixes two different jobs:
portable Typst authoring guidance for end users and repo-local maintenance
logic for regenerating that guidance from `src/tutorial/reference-grammar.typ`.
That coupling makes the distributed skill harder to copy into another
repository, and it has already allowed Windows-style command paths and
repo-specific maintenance details to leak into `SKILL.md`.

We want to split those concerns cleanly:

- `typst-grammar-authoring` should become the portable skill that users can copy
  to another repository as a single `SKILL.md` file.
- `update-typst-grammar-authoring` should become the repo-local maintenance
  skill that regenerates and validates the portable skill from this tutorial's
  canonical grammar source.

## What Changes

- Split the current single skill implementation into two separate skills:
  `typst-grammar-authoring` and `update-typst-grammar-authoring`.
- Make `typst-grammar-authoring` a self-contained, English-only, distributable
  skill consisting only of `SKILL.md`.
- Move generator scripts, traceability artifacts, repo-specific update
  instructions, and any maintenance-only metadata into
  `update-typst-grammar-authoring`.
- Require the distributed `typst-grammar-authoring/SKILL.md` to use
  platform-neutral path examples instead of Windows-specific command paths.
- Keep compile, HTML, and SVG validation guidance in the portable skill while
  keeping verbose traceability data outside its default context.

## Capabilities

### New Capabilities
- `typst-document-authoring-skill`: Provide a portable, single-file Typst
  authoring skill with embedded grammar lookup and compile-based validation
  guidance.
- `typst-document-authoring-skill-maintenance`: Provide a repo-local updater
  skill that regenerates the portable Typst authoring skill from
  `src/tutorial/reference-grammar.typ`.

### Modified Capabilities
- None.

## Impact

- Affects repo-local skill content under `.codex/skills/`.
- Changes `typst-grammar-authoring` from a repo-local folder with support files
  into a portable single-file skill.
- Adds or updates a separate `update-typst-grammar-authoring` skill for
  generation, validation, and traceability workflows.
- Removes Windows-specific command path examples from the distributed authoring
  skill.
