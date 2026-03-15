## 1. Split the skill topology

- [x] 1.1 Create a repo-local `update-typst-grammar-authoring` skill target under `.codex/skills/`
- [x] 1.2 Move generator scripts, traceability artifacts, and updater-only metadata out of `typst-grammar-authoring` and into `update-typst-grammar-authoring`
- [x] 1.3 Reduce `.codex/skills/typst-grammar-authoring/` to a distributable single-file skill that contains only `SKILL.md`

## 2. Rewrite the portable authoring skill

- [x] 2.1 Rewrite `typst-grammar-authoring/SKILL.md` to remove Windows-specific command paths and use platform-neutral path examples
- [x] 2.2 Keep grammar lookup and validation guidance self-contained inside the distributed `typst-grammar-authoring/SKILL.md`
- [x] 2.3 Remove repo-local maintenance instructions, source-path dependencies, and sidecar-file assumptions from the distributed `typst-grammar-authoring/SKILL.md`

## 3. Build the updater skill workflow

- [x] 3.1 Add updater instructions for regenerating `typst-grammar-authoring/SKILL.md` from `src/tutorial/reference-grammar.typ`
- [x] 3.2 Keep exact source traceability available as updater-owned artifacts without expanding the portable skill context
- [x] 3.3 Add updater validation guidance for refreshing, reviewing, and diffing the distributed skill output

## 4. Verify the split

- [x] 4.1 Verify `.codex/skills/typst-grammar-authoring/` contains only `SKILL.md`
- [x] 4.2 Verify the distributed `SKILL.md` contains no Windows-specific or absolute repo-local paths in command examples
- [x] 4.3 Smoke-test the updater workflow and the portable skill after the split
