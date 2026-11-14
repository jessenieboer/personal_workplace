---
name: maintain-glossary
description: Rename, redefine, or link existing terms in a project's glossary.org. Use when changing a glossary term's name, aliases, or definition, or linking terms together.
---

# Maintaining the glossary

The glossary is `.toolboxes/glossary_toolbox/glossary.org`, git-tracked. Edit only that file. `GLOSSARY.md` is its ox-gfm export: leave it to Emacs and tell the user to re-export. Entry fields and link format are in [`term.org`](../capture-term/term.org).

1. Propose the change as a diff; write only after the user OKs it, since the user decides what terms mean. A rename re-places the heading alphabetically and rewords the links that used the old name; the `:ID:` stays, so links keep resolving.
2. Link: for each term or alias added or renamed, find every other definition that uses the word and link it there. Set `:PRIME:` on each entry whose links changed. Done when every such use is linked.
3. Flag definitions that are vague or that mean the same as another term.
4. Run `glossary-check <file>`. Done when it prints `ok`.
