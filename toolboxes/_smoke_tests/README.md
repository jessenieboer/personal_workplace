# Toolbox smoke tests

One fixture per toolbox. Each fixture imports only its toolbox from this
checkout (`/toolboxes/<name>`), so uncommitted changes are tested.

Run:

    toolboxes/_smoke_tests/emacs/check.sh
    toolboxes/_smoke_tests/git/check.sh
    toolboxes/_smoke_tests/glossary/check.sh
    toolboxes/_smoke_tests/nixos/check.sh
    toolboxes/_smoke_tests/readme/check.sh

The check wipes the fixture's generated files, enters the shell under a
pseudo-tty, and asserts what the toolbox should leave behind.
