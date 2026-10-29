# Toolbox smoke tests

One fixture per toolbox. Each fixture imports only its toolbox from this
checkout (`/toolboxes/<name>`), so uncommitted changes are tested.

Run:

    toolboxes/_smoke_tests/bash/check.sh
    toolboxes/_smoke_tests/emacs/check.sh
    toolboxes/_smoke_tests/git/check.sh
    toolboxes/_smoke_tests/glossary/check.sh
    toolboxes/_smoke_tests/nixos/check.sh
    toolboxes/_smoke_tests/project_management/check.sh
    toolboxes/_smoke_tests/readme/check.sh
    toolboxes/_smoke_tests/standard_project/check.sh
    toolboxes/_smoke_tests/tracked_paths/check.sh

The check wipes the fixture's generated files, enters the shell under a
pseudo-tty, and asserts what the toolbox should leave behind. Every check also asserts
that no `.eca` directory and no `eca_manifest` is created: toolboxes install
practices only under `.toolboxes/<name>_toolbox/practices`.

The git fixture also covers the managed `.gitignore`/`.gitattributes` merge and the
seeded, user-editable `settings/.gitconfig` (and its include migration).

`tracked_paths` is not a fixture. It reads the git index and checks that every
relative path a devenv.nix (and `_lib`) refers to is tracked, for the toolboxes
the fixtures import and what those import. A path that exists only on disk
passes every fixture but breaks consumers pulling the repo. Staged files count;
untracked ones do not. Toolboxes without a fixture are not checked yet.
