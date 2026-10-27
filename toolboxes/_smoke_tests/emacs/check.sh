#!/usr/bin/env bash
# Smoke test for the emacs toolbox.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock

log=$(mktemp)
trap 'rm -f "$log"' EXIT
# Two fragments, to check the merge yields one form holding both.
mkdir -p .toolboxes/a_toolbox .toolboxes/b_toolbox
echo "((org-mode . ((a-var . 1))))" > .toolboxes/a_toolbox/a_dir_locals
echo "((nil . ((b-var . 2))))" > .toolboxes/b_toolbox/b_dir_locals

script -qec "devenv shell -- true" "$log" >/dev/null

fail() { echo "FAIL: $*"; exit 1; }

[ -f .dir-locals.el ] || fail ".dir-locals.el missing"
if command -v emacs >/dev/null; then
  emacs --batch -Q --eval "
    (with-temp-buffer
      (insert-file-contents \".dir-locals.el\")
      (let ((form (read (current-buffer))))
        (unless (and (assq (quote org-mode) form) (assq nil form)) (kill-emacs 2)))
      (condition-case nil
          (progn (read (current-buffer)) (kill-emacs 1))
        (end-of-file (kill-emacs 0))))" 2>/dev/null \
    || fail ".dir-locals.el is not one form holding both fragments"
fi
[ -f .envrc ] || fail ".envrc not seeded"
cmp -s .envrc ../../emacs/programs/.envrc || fail ".envrc differs from template"
[ -f .toolboxes/emacs_toolbox/.gitignore ] || fail "gitignore fragment missing"
grep -q '✔ emacs toolbox available' "$log" || fail "announce line not printed under a tty"
devenv shell -- true 2>/dev/null | grep -q 'toolbox available' && fail "announce printed without a tty"

echo "PASS: emacs toolbox"
