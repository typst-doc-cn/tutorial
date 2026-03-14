## Why

Codex can already edit Typst files, but it still benefits from a repo-specific skill that teaches it to prefer canonical grammar patterns over improvised syntax. This repository already contains a rich grammar example table in `src/tutorial/reference-grammar.typ`, so now is a good time to turn that material into an English-only skill that reliably guides authoring and validation for user Typst documents.

## What Changes

- Create a new Codex skill that teaches Typst document authoring by adapting examples from `src/tutorial/reference-grammar.typ` instead of inventing grammar from scratch.
- Require the skill itself to be written in English, including `SKILL.md`, generated references, validation guidance, and UI metadata.
- Add reusable resources that extract and organize grammar examples from `src/tutorial/reference-grammar.typ` for low-context lookup during authoring.
- Standardize grammar validation around `typst compile` so syntax and semantic failures are detected through Typst’s own compiler output instead of editor-specific tooling.
- Define a text-validation workflow based on Typst HTML output, for example `typst compile --features html a.typ a.html`.
- Define a visual-validation workflow based on Typst SVG output plus Playwright MCP inspection, for example `typst compile a.typ a.svg`.

## Capabilities

### New Capabilities
- `typst-document-authoring-skill`: Provide an English-only Codex skill that teaches Typst authoring from canonical grammar examples and validates authored documents with Typst compilation, HTML output, and SVG plus Playwright review.

### Modified Capabilities
- None.

## Impact

- Affects repo-local skill content under `.codex/skills/`.
- Adds or updates scripts and references used to extract grammar examples from `src/tutorial/reference-grammar.typ`.
- Defines compile-based validation workflows for `.typ`, `.html`, and `.svg` outputs.
- Shapes how Codex authoring guidance is presented for user Typst documents in this repository.
