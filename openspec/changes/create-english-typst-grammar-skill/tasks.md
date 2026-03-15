## 1. Skill setup

- [x] 1.1 Audit any existing Typst skill or prototype files and choose the final repo-local skill target under `.codex/skills/`
- [x] 1.2 Create or update the repo-local skill scaffold and English-facing agent metadata for the Typst document authoring skill

## 2. Grammar reference resources

- [x] 2.1 Implement or update the extraction flow that reads `src/tutorial/reference-grammar.typ` and produces skill reference material
- [x] 2.2 Generate an English-facing grammar reference catalog that preserves traceability back to the canonical source examples
- [x] 2.3 Write the final English-only `SKILL.md` and reference guidance for grammar-first authoring

## 3. Compile-based validation workflow

- [x] 3.1 Replace any editor-specific validation requirement with a `typst compile`-based grammar validation workflow
- [x] 3.2 Add documented HTML validation commands and guidance for checking rendered text output
- [x] 3.3 Add documented SVG generation and Playwright MCP guidance for visual inspection of rendered output

## 4. Verification and cleanup

- [x] 4.1 Smoke-test successful and failing `typst compile` runs on representative `.typ` files
- [ ] 4.2 Smoke-test HTML and SVG output generation plus a Playwright-based visual inspection path
- [x] 4.3 Validate the final skill contents and retire or overwrite any superseded Typst skill prototype
