#!/usr/bin/env bash
# Smoke test for the bash toolbox.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock

log=$(mktemp)
trap 'rm -f "$log"' EXIT
script -qec "devenv shell -- true" "$log" >/dev/null || { tail -30 "$log"; exit 1; }

fail() { echo "FAIL: $*"; exit 1; }
skills=.toolboxes/bash_toolbox/practices/skills

for n in bash-defensive-patterns bash-linux bash-pro bash-scripting; do
  s=$skills/$n
  grep -q "^name: $n" "$s/SKILL.md" 2>/dev/null || fail "$n SKILL.md missing or wrong"
  grep -q 'MIT License' "$s/LICENSE" 2>/dev/null || fail "$n lacks LICENSE"
  grep -q 'CC BY 4.0' "$s/LICENSE-CONTENT" 2>/dev/null || fail "$n lacks LICENSE-CONTENT"
done
[ -f "$skills/bash-defensive-patterns/resources/implementation-playbook.md" ] || fail "defensive-patterns resources missing"
[ -e "$skills/bash-script-validator" ] && fail "old bash-script-validator still shipped"
for tool in shellcheck shfmt bats; do
  devenv shell -- "$tool" --version >/dev/null 2>&1 || fail "$tool not on PATH"
done
grep -q '✔ bash toolbox available' "$log" || fail "announce line not printed under a tty"

# The toolbox asks to be ignored through its settings/.gitignore, which the git
# toolbox merges into the project .gitignore. This fixture does not import the
# git toolbox, so the folder is not hidden here: check the copy and the absence
# of a folder .gitignore.
cmp -s .toolboxes/bash_toolbox/settings/.gitignore ../../bash/settings/.gitignore || fail "settings/.gitignore not copied from the toolbox"
grep -qx '.toolboxes/bash_toolbox/' .toolboxes/bash_toolbox/settings/.gitignore || fail "settings/.gitignore lacks the folder line"
[ ! -e .toolboxes/bash_toolbox/.gitignore ] || fail "bash_toolbox wrote a folder .gitignore"

# Nothing is copied into .eca, and no eca manifest is kept.
[ -e .eca ] && fail ".eca was created"
find .toolboxes -name eca_manifest 2>/dev/null | grep -q . && fail "eca_manifest was written"

echo "PASS: bash toolbox"
