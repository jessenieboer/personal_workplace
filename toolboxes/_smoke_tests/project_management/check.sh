#!/usr/bin/env bash
# Smoke test for the project_management toolbox together with emacs: the
# merged .dir-locals.el holds the journal template once plus PM's templates.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock probe.txt

log=$(mktemp)
trap 'rm -f "$log" probe.txt' EXIT
script -qec "devenv shell -- true" "$log" >/dev/null || { tail -30 "$log"; exit 1; }

fail() { echo "FAIL: $*"; exit 1; }

[ -f .toolboxes/project_management_toolbox/project_management_toolbox_dir_locals ] || fail "PM fragment not generated"
[ -f .toolboxes/emacs_toolbox/emacs_toolbox_dir_locals ] || fail "emacs journal fragment not generated"
[ -f .dir-locals.el ] || fail ".dir-locals.el missing"
grep -q '"Journal entry"' .toolboxes/project_management_toolbox/project_management_toolbox_dir_locals && fail "PM fragment still defines the journal template"
[ "$(grep -c '"Journal entry"' .dir-locals.el)" = 1 ] || fail "journal template is not in .dir-locals.el exactly once"
grep -q 'org-agenda-custom-commands' .dir-locals.el || fail "PM agenda commands missing from .dir-locals.el"
grep -q '@[A-Z_]*@' .dir-locals.el && fail "unfilled placeholder in .dir-locals.el"

if command -v emacs >/dev/null; then
  touch probe.txt
  got=$(emacs --batch -Q --eval '(progn
    (setq enable-local-variables :all)
    (find-file "probe.txt")
    (princ (format "%S %S" org-directory (mapcar (function car) org-capture-templates))))' 2>/dev/null)
  # PM's 11 templates and the journal one, in one list.
  tab=$'\t'
  want="\"$(pwd)/\" (\"b\" \"s\" \"y\" \"$tab\" \"e\" \"i\" \"z\" \"n\" \"p\" \"c\" \"h\" \"o\")"
  [ "$got" = "$want" ] || fail "capture templates are not the journal plus PM's: $got"
fi

# Nothing is copied into .eca, and no eca manifest is kept.
[ -e .eca ] && fail ".eca was created"
find .toolboxes -name eca_manifest 2>/dev/null | grep -q . && fail "eca_manifest was written"

echo "PASS: project_management toolbox"
