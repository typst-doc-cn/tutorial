## ADDED Requirements

### Requirement: Skill materials are English-facing
The skill SHALL present its metadata, instructions, navigation text, validation guidance, and generated reference prose in English so Codex can use it without relying on Chinese tutorial prose.

#### Scenario: English-only authored materials
- **WHEN** the skill folder is created or updated
- **THEN** `SKILL.md`, agent metadata, and generated guidance files MUST use English for authored prose and labels

### Requirement: Skill references canonical grammar examples
The skill SHALL provide reference material derived from `src/tutorial/reference-grammar.typ` so Codex can locate and adapt canonical Typst grammar examples while authoring user documents.

#### Scenario: Grammar lookup from extracted references
- **WHEN** Codex needs a Typst syntax pattern for a user document
- **THEN** the skill MUST provide an extracted reference path that maps back to canonical examples from `src/tutorial/reference-grammar.typ`

### Requirement: Grammar validation uses Typst compilation
The skill SHALL define `typst compile` as the required validation workflow for grammar and compile-time errors in authored Typst documents.

#### Scenario: Compile failure is treated as invalid grammar or document state
- **WHEN** Codex validates a `.typ` file with the skill's required workflow
- **THEN** a non-zero `typst compile` result MUST be treated as a blocking validation failure

### Requirement: Text output can be validated through HTML export
The skill SHALL define a text-validation workflow based on Typst HTML output so Codex can inspect textual structure and rendered text separately from compile success.

#### Scenario: HTML validation of authored text
- **WHEN** Codex needs to verify rendered text or document structure after a successful compile
- **THEN** the skill MUST direct Codex to use `typst compile --features html` to produce HTML output for inspection

### Requirement: Visual output can be validated through SVG and Playwright
The skill SHALL define a visual-validation workflow based on Typst SVG output and Playwright MCP inspection so Codex can review rendered layout after compilation.

#### Scenario: SVG and Playwright visual inspection
- **WHEN** Codex needs to inspect rendered layout or visual regressions in a user Typst document
- **THEN** the skill MUST direct Codex to compile the document to SVG and use Playwright MCP as the visual inspection step
