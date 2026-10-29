#!/usr/bin/env bash
# Smoke test for the standard_project toolbox: it enters, ignores itself,
# and no longer contributes a dir-locals fragment (emacs owns journal capture).
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock

log=$(mktemp)
trap 'rm -f "$log"' EXIT
script -qec "devenv shell -- true" "$log" >/dev/null || { tail -30 "$log"; exit 1; }

fail() { echo "FAIL: $*"; exit 1; }

[ -e .toolboxes/standard_project_toolbox/standard_project_toolbox_dir_locals ] && fail "standard_project still generates a dir-locals fragment"
[ "$(cat .toolboxes/standard_project_toolbox/.gitignore)" = "*" ] || fail "standard_project_toolbox/.gitignore is not a lone *"
grep -q '"Journal entry"' .dir-locals.el || fail "journal capture (from the emacs toolbox) missing from .dir-locals.el"
[ "$(grep -c '"Journal entry"' .dir-locals.el)" = 1 ] || fail "journal template is not in .dir-locals.el exactly once"
grep -q '✔ standard project toolbox available' "$log" || fail "announce line not printed under a tty"

echo "PASS: standard_project toolbox"
