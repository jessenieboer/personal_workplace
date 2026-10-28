#!/usr/bin/env bash
# Smoke test for the bash toolbox.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock

log=$(mktemp)
trap 'rm -f "$log"' EXIT
script -qec "devenv shell -- true" "$log" >/dev/null || { tail -30 "$log"; exit 1; }

fail() { echo "FAIL: $*"; exit 1; }
s=.toolboxes/bash_toolbox/practices/skills/bash-script-validator

[ -f "$s/SKILL.md" ] || fail "SKILL.md missing from the mirror"
grep -q '^name: bash-script-validator' "$s/SKILL.md" || fail "skill content wrong"
grep -q 'Apache License' "$s/LICENSE" || fail "upstream LICENSE not shipped"
[ -f "$s/scripts/validate.sh" ] || fail "validator script missing"
[ -f .eca/skills/bash-script-validator/SKILL.md ] || fail ".eca copy missing"
devenv shell -- shellcheck --version >/dev/null 2>&1 || fail "shellcheck not on PATH"
devenv shell -- bash "$s/scripts/validate.sh" "$s/examples/good-bash.sh" >/dev/null 2>&1 || fail "validator rejects its own good example"
grep -q '✔ bash toolbox available' "$log" || fail "announce line not printed under a tty"

echo "PASS: bash toolbox"
