#!/usr/bin/env bash
# Smoke test for the nixos toolbox.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock

log=$(mktemp)
trap 'rm -f "$log"' EXIT
script -qec "devenv shell -- true" "$log" >/dev/null || { tail -30 "$log"; exit 1; }

fail() { echo "FAIL: $*"; exit 1; }
s=.toolboxes/nixos_toolbox/practices/skills/nixos

[ -f "$s/SKILL.md" ] || fail "nixos SKILL.md missing from the mirror"
grep -q '^name: nixos' "$s/SKILL.md" || fail "nixos skill content wrong"
[ -f "$s/references/flakes.md" ] || fail "references not copied"
[ -e "$s/install.sh" ] || [ -e "$s/scripts" ] && fail "repo scripts leaked into the skill"
[ -f .eca/skills/nixos/SKILL.md ] || fail ".eca copy missing"
[ -f .toolboxes/bash_toolbox/practices/skills/bash-scripting/SKILL.md ] || fail "bash toolbox not imported"
[ -f "$s/../nix-bash-scripts/SKILL.md" ] || fail "nix-bash-scripts skill missing"
grep -q '✔ nixos toolbox available' "$log" || fail "announce line not printed under a tty"

echo "PASS: nixos toolbox"
