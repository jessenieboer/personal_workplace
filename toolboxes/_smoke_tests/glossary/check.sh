#!/usr/bin/env bash
# Smoke test for the glossary toolbox.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock

log=$(mktemp)
trap 'rm -f "$log"' EXIT
script -qec "devenv shell -- true" "$log" >/dev/null || { tail -30 "$log"; exit 1; }

fail() { echo "FAIL: $*"; exit 1; }
f=.toolboxes/glossary_toolbox/glossary.org

[ -f "$f" ] || fail "glossary.org not seeded"
grep -qx '#+EXPORT_FILE_NAME: ../../GLOSSARY.md' "$f" || fail "export target is not GLOSSARY.md in the project root"
grep -q '00000000-0000-0000-0000-000000000000' "$f" && fail "placeholder ID not replaced"
grep -Eq '^:ID: +[0-9a-f]{8}-[0-9a-f]{4}-' "$f" || fail "seeded term lacks a UUID"
[ -e .toolboxes/readme_toolbox ] && fail "glossary toolbox seeded readme files"
grep -q '✔ glossary toolbox available' "$log" || fail "announce line not printed under a tty"


# glossary.org is user-edited: the toolbox must not ignore its own folder.
repo=$(mktemp -d)
trap 'rm -f "$log"; rm -rf "$repo"' EXIT
cp -r --no-preserve=mode .toolboxes "$repo/"
git -C "$repo" init -q
[ ! -e .toolboxes/glossary_toolbox/.gitignore ] || fail "glossary_toolbox wrote a .gitignore"
git -C "$repo" check-ignore -q .toolboxes/glossary_toolbox/glossary.org && fail "glossary.org is ignored"
git -C "$repo" status --porcelain -uall | grep -qF '.toolboxes/glossary_toolbox/glossary.org' || fail "glossary.org not visible to git"

# A second entry must keep the user's edits.
echo "* my term" >> "$f"
devenv shell -- true >/dev/null 2>&1
grep -qx '\* my term' "$f" || fail "re-entry overwrote glossary.org"

echo "PASS: glossary toolbox"
