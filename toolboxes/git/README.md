# git toolbox

Git settings for a consumer project, shared by every toolbox.

## What a toolbox ships

A toolbox may have `settings/.gitignore` and `settings/.gitattributes`. On every
shell entry each one is copied to `.toolboxes/<name>_toolbox/settings/`, kept
identical to its source and read-only (mode 444). Do not edit the copies.

A toolbox whose `.toolboxes/<name>_toolbox/` folder is all generated puts the
line `.toolboxes/<name>_toolbox/` in its own `settings/.gitignore`. Toolboxes
with project-owned files in the folder (git, readme, glossary, bdd, voxtype)
do not.

## What the git toolbox does

- Merges every `.toolboxes/*_toolbox/settings/.gitignore` into the project root
  `.gitignore`, and every `settings/.gitattributes` into the root
  `.gitattributes`. The merged lines sit in a managed block at the top; lines
  you write below it, in either file, are kept and win over the block. Nested
  `.toolboxes` are not read.
- Its own `.gitignore` ignores `.toolboxes/*/practices/` and
  `.toolboxes/*/settings/*`, except `settings/.gitconfig`.
- Seeds `.toolboxes/git_toolbox/settings/.gitconfig` once from
  `templates/gitconfig` and includes it in `.git/config`. It is yours: edit it
  and commit it. It is never refreshed. It replaces the earlier refreshed
  `.toolboxes/git_toolbox/gitconfig`, which is left on disk but no longer
  included.

Toolboxes that do not import the git toolbox (directly or through another
toolbox) still write their settings copy, but nothing merges it, so their
folder is not hidden from git.
