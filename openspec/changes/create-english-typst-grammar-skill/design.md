## Context

This repository contains a detailed Typst grammar catalog in `src/tutorial/reference-grammar.typ`. The proposed change turns that tutorial asset into a repo-local Codex skill that helps author user Typst documents by selecting valid grammar patterns from canonical examples instead of inventing syntax ad hoc.

The skill needs to be English-only from Codex's perspective, even though the source tutorial and some example literals are Chinese. The same change also needs a validation workflow that does not depend on IDE-specific language services. The user explicitly wants grammar validation to come from Typst compilation, then separate validation passes for text output through HTML and visual output through SVG plus Playwright MCP inspection.

## Goals / Non-Goals

**Goals:**
- Create a repo-local Codex skill for user Typst document authoring.
- Ground the skill in canonical grammar examples extracted from `src/tutorial/reference-grammar.typ`.
- Keep all skill-authored prose, metadata, navigation, and workflow documentation in English.
- Make `typst compile` the authoritative validation path for grammar and compile-time failures.
- Define a repeatable text-validation workflow using Typst HTML output.
- Define a repeatable visual-validation workflow using Typst SVG output and Playwright MCP.

**Non-Goals:**
- Translate the full Chinese tutorial into English.
- Replace Typst's own compiler diagnostics with a custom parser or validator.
- Depend on Tinymist, VS Code, or any specific editor integration for the required validation path.
- Build a general-purpose Typst skill for all repositories outside this repo's structure and assets.

## Decisions

### Decision: Build the skill around extracted grammar references

The skill will not point Codex at the full tutorial file every time. Instead, it will maintain generated reference material derived from `src/tutorial/reference-grammar.typ` so Codex can search a compact catalog first and only open the source file when deeper context is needed.

Why this approach:
- It keeps the skill's active context smaller than loading the full tutorial source.
- It preserves direct traceability back to the source grammar table.
- It allows English-facing headings and navigation even when the source material is not in English.

Alternative considered:
- Read `src/tutorial/reference-grammar.typ` directly on every use. Rejected because it is larger, noisier, and less friendly to repeated low-context lookups.

### Decision: Treat English-only as a requirement for skill-authored materials, not for verbatim source code blocks

The skill's `SKILL.md`, generated headings, navigation labels, validation guidance, and agent metadata will be written in English. Verbatim code examples may still contain non-English literals when they come directly from canonical source examples.

Why this approach:
- It satisfies the requirement that the skill itself is written in English.
- It avoids mutating canonical Typst examples in ways that could accidentally change grammar or semantics.
- It keeps the extracted references trustworthy as grammar sources.

Alternative considered:
- Rewrite all source examples into English text. Rejected because it introduces translation work and risks changing the exact shape of canonical grammar examples.

### Decision: Use `typst compile` as the mandatory validation source of truth

The skill will validate authored Typst documents with `typst compile`, not with editor-specific LSP diagnostics. Compiler exit status and compiler diagnostics will be treated as the required pass/fail signal for grammar and compile-time correctness.

Why this approach:
- It matches the requested workflow.
- It works consistently outside any specific IDE.
- It keeps the validation path aligned with the actual renderer and compiler used for outputs.

Alternative considered:
- Use Tinymist or another LSP as the main validator. Rejected because the requested change explicitly prefers Typst compilation over IDE tooling.

### Decision: Split validation into compile, text, and visual passes

The skill will define three validation layers:
- compile validation with `typst compile`
- text validation with `typst compile --features html`
- visual validation with `typst compile ... a.svg` plus Playwright MCP inspection

Why this approach:
- Grammar correctness does not guarantee correct text output.
- Correct text output does not guarantee correct layout or rendering.
- The separation maps directly to the user's requested workflow and keeps the skill operationally clear.

Alternative considered:
- Treat a successful PDF or SVG compile as sufficient validation. Rejected because it misses easy-to-inspect text structure issues that HTML surfaces well.

### Decision: Make Playwright an inspection layer over generated SVG, not the rendering source

The skill will rely on Typst to generate SVG and on Playwright MCP to inspect that output in a browser-compatible context. The browser step is observational only; it will not replace Typst rendering.

Why this approach:
- Typst remains the authoritative renderer.
- Playwright is strong at visual verification and DOM/screenshot workflows.
- It keeps the boundary between generation and inspection simple.

Alternative considered:
- Use Playwright to render HTML instead of inspecting SVG. Rejected because the requested visual path is explicitly based on Typst SVG output.

## Risks / Trade-offs

- Strict English-only expectations may conflict with verbatim source examples that include Chinese literals. → Mitigation: keep all authored guidance in English and document that canonical code blocks are source data, not translated prose.
- HTML export is still an in-development Typst feature and may emit warnings or change behavior over time. → Mitigation: treat HTML as a validation aid for text structure, not as a production output contract.
- SVG inspection can depend on the execution environment and how Playwright accesses generated files. → Mitigation: document a browser-compatible inspection path and keep SVG generation itself independent from Playwright.
- Grammar extraction logic can drift if `src/tutorial/reference-grammar.typ` changes structure. → Mitigation: keep extraction logic small, source-specific, and covered by representative regeneration checks.

## Migration Plan

1. Add or replace the repo-local skill under `.codex/skills/`.
2. Generate English-facing reference material from `src/tutorial/reference-grammar.typ`.
3. Switch validation guidance from any editor-specific path to `typst compile`.
4. Add HTML and SVG validation guidance and any supporting scripts needed for repeatable execution.
5. If a previous prototype skill exists, retire or overwrite it so only the new English-only workflow remains.

Rollback strategy:
- Remove the new skill folder and generated references, then restore the previous repo-local skill state if needed.

## Open Questions

- None at proposal time. The current request is specific enough to proceed with implementation planning.
