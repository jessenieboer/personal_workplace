#!/usr/bin/env bash
# Smoke test for the nixos toolbox.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock

log=$(mktemp)
trap 'rm -f "$log"' EXIT
script -qec "devenv shell -- true" "$log" >/dev/null || { tail -30 "$log"; exit 1; }

fail() { echo "FAIL: $*"; exit 1; }
practices=.toolboxes/nixos_toolbox/practices
lib=$practices/LIBRARIAN.md

[ -f "$lib" ] || fail "LIBRARIAN.md missing from the mirror"
cmp -s "$lib" ../../nixos/practices/LIBRARIAN.md || fail "installed LIBRARIAN.md differs from source"
for url in \
  'devenv: https://github.com/h0rv/agent-skills/tree/main/devenv' \
  'nix-best-practices: https://github.com/alleneubank/claude-code/tree/main/.claude/skills/nix-best-practices' \
  'nixos-best-practices: https://github.com/lihaoze123/my-claude-code/tree/main/skills/nixos-best-practices' \
  'nix-ecosystem: https://github.com/takeokunn/nixos-configuration/tree/main/home-manager/ai-tools/agent-skills/skills/nix-ecosystem'
do
  grep -qxF "$url" "$lib" || fail "LIBRARIAN.md missing $url"
done
[ -f .toolboxes/bash_toolbox/practices/skills/bash-scripting/SKILL.md ] || fail "bash toolbox not imported"
[ -f "$practices/skills/nix-bash-scripts/SKILL.md" ] || fail "nix-bash-scripts skill missing"
grep -q '✔ nixos toolbox available' "$log" || fail "announce line not printed under a tty"

# Nothing is copied into .eca, and no eca manifest is kept.
[ -e .eca ] && fail ".eca was created"
find .toolboxes -name eca_manifest 2>/dev/null | grep -q . && fail "eca_manifest was written"

echo "PASS: nixos toolbox"
