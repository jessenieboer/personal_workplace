#!/usr/bin/env bash
set -euo pipefail
test -f .envrc
test -f .dir-locals.el
test -f .toolboxes/emacs_toolbox/.gitignore
echo "PASS: emacs smoke"
