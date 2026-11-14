---
name: capture-term
description: Add a new term to a project's glossary.org. Use when the user wants a word or phrase defined in the glossary.
---

# Capturing a glossary term

The glossary is `.toolboxes/glossary_toolbox/glossary.org`, git-tracked and seeded by devenv. Edit only that file. `GLOSSARY.md` is its ox-gfm export: leave it to Emacs and tell the user to re-export.

1. Take the definition as the user gives it. Don't judge its clarity, correctness, or vagueness. Only check whether an existing term or alias already covers it.
2. Write the entry from [`term.org`](term.org) as a top-level heading, lowercase and singular, placed alphabetically among its siblings.
3. Link the new term into the rest of the glossary with maintain-glossary steps 2 and 4 (link, then check). Skip its diff proposal and vagueness flags.
4. Confirm each captured term by name. Don't show a diff.
