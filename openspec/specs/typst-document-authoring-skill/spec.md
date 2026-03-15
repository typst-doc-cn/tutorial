# typst-document-authoring-skill Specification

## Purpose
Define the canonical requirements for a portable, English-facing Typst authoring skill and the updater and validation workflows that maintain it.
## Requirements
### Requirement: Portable authoring skill is English-facing and self-contained
The distributed `typst-grammar-authoring` skill SHALL be complete as a
single-file, English-facing `SKILL.md` so it can be copied into another
repository without requiring sibling support files.

#### Scenario: Single-file portable distribution
- **WHEN** `typst-grammar-authoring` is prepared for downstream use
- **THEN** the skill folder MUST be complete with only `SKILL.md`
- **AND** that `SKILL.md` MUST contain the authoring guidance, grammar lookup,
  and validation workflow needed by the consuming repository

### Requirement: Portable authoring skill avoids Windows-specific path examples
The distributed `typst-grammar-authoring/SKILL.md` SHALL use platform-neutral,
forward-slash, or placeholder filesystem paths in commands and examples.

#### Scenario: Portable command examples
- **WHEN** `typst-grammar-authoring/SKILL.md` is authored or regenerated
- **THEN** command examples MUST use repo-relative or placeholder paths such as
  `path/to/document.typ`
- **AND** the file MUST NOT include Windows absolute paths or Windows-style
  backslash-only command paths

### Requirement: Portable authoring skill embeds compact grammar lookup
The distributed `typst-grammar-authoring/SKILL.md` SHALL embed a compact Typst
grammar lookup derived from `src/tutorial/reference-grammar.typ` so it remains
single-file while still teaching canonical syntax patterns.

#### Scenario: Grammar lookup without sidecar references
- **WHEN** Codex needs a Typst syntax pattern while using
  `typst-grammar-authoring`
- **THEN** the skill MUST provide that lookup inside `SKILL.md`
- **AND** the lookup MUST be derived from canonical examples in
  `src/tutorial/reference-grammar.typ`

### Requirement: Updater skill owns regeneration of the portable skill
The repo-local `update-typst-grammar-authoring` skill SHALL own the workflow
that regenerates the distributed `typst-grammar-authoring/SKILL.md` from
`src/tutorial/reference-grammar.typ`.

#### Scenario: Repo-local regeneration
- **WHEN** a maintainer updates canonical grammar examples from
  `src/tutorial/reference-grammar.typ`
- **THEN** `update-typst-grammar-authoring` MUST provide the update workflow
- **AND** that workflow MUST produce the distributed
  `typst-grammar-authoring/SKILL.md`

### Requirement: Updater skill preserves verbose traceability outside portable context
The updater workflow SHALL preserve exact source traceability in separate
maintenance artifacts without injecting verbose canonical reference and
traceability sections into the distributed `typst-grammar-authoring/SKILL.md`.

#### Scenario: Maintainer needs exact source mapping
- **WHEN** a maintainer needs exact source mapping for a generated grammar entry
- **THEN** `update-typst-grammar-authoring` MUST provide a separate
  traceability artifact
- **AND** the distributed `typst-grammar-authoring/SKILL.md` MUST omit verbose
  canonical reference and traceability sections from its active context

### Requirement: Grammar validation uses Typst compilation
The portable authoring skill SHALL define `typst compile` as the required
validation workflow for grammar and compile-time errors in authored Typst
documents.

#### Scenario: Compile failure is treated as invalid grammar or document state
- **WHEN** Codex validates a `.typ` file with the skill's required workflow
- **THEN** a non-zero `typst compile` result MUST be treated as a blocking
  validation failure

### Requirement: Text output can be validated through HTML export
The portable authoring skill SHALL define a text-validation workflow based on
Typst HTML output so Codex can inspect textual structure and rendered text
separately from compile success.

#### Scenario: HTML validation of authored text
- **WHEN** Codex needs to verify rendered text or document structure after a
  successful compile
- **THEN** the skill MUST direct Codex to use `typst compile --features html`
  to produce HTML output for inspection

### Requirement: Visual output can be validated through SVG and Playwright
The portable authoring skill SHALL define a visual-validation workflow based on
Typst SVG output and Playwright MCP inspection so Codex can review rendered
layout after compilation.

#### Scenario: SVG and Playwright visual inspection
- **WHEN** Codex needs to inspect rendered layout or visual regressions in a
  user Typst document
- **THEN** the skill MUST direct Codex to compile the document to SVG
- **AND** the skill MUST direct Codex to use Playwright MCP as the visual
  inspection step
