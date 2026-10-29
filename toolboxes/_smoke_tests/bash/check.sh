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

# The toolbox keeps its generated folder out of git by itself. Check in a
# scratch repo: this fixture sits under a repo that already ignores .toolboxes.
repo=$(mktemp -d)
trap 'rm -f "$log"; rm -rf "$repo"' EXIT
cp -r --no-preserve=mode .toolboxes "$repo/"
git -C "$repo" init -q
git -C "$repo" check-ignore -q .toolboxes/bash_toolbox/practices/skills/bash-pro/SKILL.md || fail "bash_toolbox is not ignored"
[ -z "$(git -C "$repo" status --porcelain -uall)" ] || fail "bash_toolbox shows up in git status"
[ "$(cat .toolboxes/bash_toolbox/.gitignore)" = "*" ] || fail "bash_toolbox/.gitignore is not a lone *"
[ ! -e .toolboxes/bash_toolbox/project.gitignore ] || fail "bash_toolbox wrote a project.gitignore without project ignores"

# Nothing is copied into .eca, and no eca manifest is kept.
[ -e .eca ] && fail ".eca was created"
find .toolboxes -name eca_manifest 2>/dev/null | grep -q . && fail "eca_manifest was written"

echo "PASS: bash toolbox"
