#!/usr/bin/env bash
# Smoke test for the readme toolbox.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock

log=$(mktemp)
trap 'rm -f "$log"' EXIT
script -qec "devenv shell -- true" "$log" >/dev/null || { tail -30 "$log"; exit 1; }

fail() { echo "FAIL: $*"; exit 1; }
f=.toolboxes/readme_toolbox/readme.org

[ -f "$f" ] || fail "readme.org not seeded"
cmp -s "$f" ../../readme/templates/readme.org || fail "readme.org differs from template"
grep -qx '#+EXPORT_FILE_NAME: ../../README.md' "$f" || fail "export target is not README.md in the project root"
[ -e .toolboxes/readme_toolbox/glossary.org ] && fail "readme toolbox still seeds glossary.org"
grep -q '✔ readme toolbox available' "$log" || fail "announce line not printed under a tty"

echo "* my section" >> "$f"
devenv shell -- true >/dev/null 2>&1
grep -qx '\* my section' "$f" || fail "re-entry overwrote readme.org"

# Nothing is copied into .eca, and no eca manifest is kept.
[ -e .eca ] && fail ".eca was created"
find .toolboxes -name eca_manifest 2>/dev/null | grep -q . && fail "eca_manifest was written"

echo "PASS: readme toolbox"
