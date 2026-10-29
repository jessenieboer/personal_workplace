#!/usr/bin/env bash
# Smoke test for the emacs toolbox.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock probe.txt

log=$(mktemp)
trap 'rm -f "$log" probe.txt' EXIT
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
[ -f .toolboxes/emacs_toolbox/emacs_toolbox_dir_locals ] || fail "journal fragment not generated"

# What Emacs sees for a file in this project: org-directory, then the
# org-capture-templates keys. Skipped when emacs is not installed.
probe() {
  touch probe.txt
  emacs --batch -Q --eval '(progn
    (setq enable-local-variables :all)
    (find-file "probe.txt")
    (princ (format "%S %S" org-directory (mapcar (function car) org-capture-templates))))' 2>/dev/null
}
if command -v emacs >/dev/null; then
  [ "$(grep -c '"b" "Journal entry"' .dir-locals.el)" = 1 ] || fail "journal template is not in .dir-locals.el exactly once"
  [ "$(probe)" = "\"$(pwd)/\" (\"b\")" ] || fail "emacs-only project lacks journal capture rooted at the project: $(probe)"

  # A later fragment adds its own template and takes org-directory; the
  # journal template stays, once.
  mkdir -p .toolboxes/x_toolbox
  cat > .toolboxes/x_toolbox/x_dir_locals <<'EOF'
((nil . ((org-capture-templates . (("z" "Zed" plain (file "z.org") "%?")
                                   ("b" "Mine" plain (file "mine.org") "%?")))
         (org-directory . "/x/"))))
EOF
  devenv shell -- true >/dev/null 2>&1
  [ "$(probe)" = '"/x/" ("b" "z")' ] || fail "capture templates not combined or org-directory not taken from the later fragment: $(probe)"
  grep -q '"Mine"' .dir-locals.el || fail "later template with the same key did not replace the journal one"
  rm -rf .toolboxes/x_toolbox
  devenv shell -- true >/dev/null 2>&1
  [ "$(probe)" = "\"$(pwd)/\" (\"b\")" ] || fail "removing the fragment did not restore journal-only capture: $(probe)"
fi
[ -f .envrc ] || fail ".envrc not seeded"
cmp -s .envrc ../../emacs/programs/.envrc || fail ".envrc differs from template"
[ -f .toolboxes/emacs_toolbox/project.gitignore ] || fail "project.gitignore missing"
grep -qx '.dir-locals.el' .toolboxes/emacs_toolbox/project.gitignore || fail "project.gitignore lacks the toolbox ignores"
[ "$(cat .toolboxes/emacs_toolbox/.gitignore)" = "*" ] || fail "emacs_toolbox/.gitignore is not a lone *"
grep -q '✔ emacs toolbox available' "$log" || fail "announce line not printed under a tty"
devenv shell -- true 2>/dev/null | grep -q 'toolbox available' && fail "announce printed without a tty"

echo "PASS: emacs toolbox"
