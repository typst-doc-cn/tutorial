---
name: update-typst-grammar-authoring
description: Use when maintaining the portable typst-grammar-authoring skill from this repository's canonical Typst grammar source.
metadata:
  short-description: Regenerate the portable Typst grammar skill
---

# Update Typst Grammar Authoring

Use this skill when a maintainer needs to refresh the portable
`typst-grammar-authoring` skill after changing the canonical grammar examples in
`src/tutorial/reference-grammar.typ`.

## Inputs And Outputs

- Canonical source: `src/tutorial/reference-grammar.typ`
- Portable skill: `.codex/skills/typst-grammar-authoring/SKILL.md`
- Traceability artifact:
  `.codex/skills/update-typst-grammar-authoring/references/grammar-catalog.json`

## Workflow

1. Review the source edits in `src/tutorial/reference-grammar.typ` and confirm
   they are ready to publish into the portable skill.
2. Regenerate the portable skill body and traceability artifact:

   ```sh
   python .codex/skills/update-typst-grammar-authoring/scripts/generate_grammar_catalog.py
   ```

3. Review the generated diff for the portable skill and the traceability JSON:

   ```sh
   git diff -- .codex/skills/typst-grammar-authoring/SKILL.md .codex/skills/update-typst-grammar-authoring/references/grammar-catalog.json
   ```

4. Verify the portable skill stayed single-file:

   ```powershell
   Get-ChildItem -Force .codex/skills/typst-grammar-authoring
   ```

5. Verify the portable skill's command examples stayed platform-neutral and did
   not reintroduce Windows absolute paths:

   ```sh
   rg -n "[A-Za-z]:\\\\|path\\\\to|target\\\\typst-grammar-authoring-check|\\.codex\\\\skills|src\\\\tutorial" .codex/skills/typst-grammar-authoring/SKILL.md
   ```

6. If the regenerated lookup looks correct, keep the portable skill focused on
   author guidance only. Any exact source mapping belongs in the updater-owned
   traceability JSON, not in the portable `SKILL.md`.

## Guardrails

- Keep the distributed `typst-grammar-authoring` folder limited to `SKILL.md`.
- Treat `.codex/skills/update-typst-grammar-authoring/references/grammar-catalog.json`
  as the source-mapping artifact for maintainers.
- Keep maintenance-only commands, source-path references, and review steps in
  this updater skill rather than the portable one.
- If the generator output reveals a design issue in the portable skill, update
  the portable template first and rerun the generator before final review.
