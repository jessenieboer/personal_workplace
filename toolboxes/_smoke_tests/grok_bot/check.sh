#!/usr/bin/env bash
# Smoke test for the grok_bot toolbox (bot template and grok_bots.org).
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock

log=$(mktemp)
trap 'rm -f "$log"' EXIT
script -qec "devenv shell -- true" "$log" >/dev/null || {
	cat "$log"
	exit 1
}

fail() {
	echo "FAIL: $*"
	exit 1
}
src=../../grok_bot/templates/grok_bots_template.org
box=.toolboxes/grok_bot_toolbox

[ ! -L "$box" ] || fail "grok_bot_toolbox is a symlink"
# Must not recreate any retired bots path.
[ ! -e "$box/bots" ] || fail "retired bots directory created"
[ ! -e "$box/practices/bots" ] || fail "stale practices/bots path still present"
[ ! -e "$box/practices/_bots" ] || fail "stale practices/_bots path still present"

template=$box/templates/grok_bots.org
[ -f "$template" ] || fail "bot template not installed"
[ ! -L "$template" ] || fail "bot template is a symlink"
[ "$(stat -c %a "$template")" = 444 ] || fail "bot template is not read-only"
cmp -s "$template" "$src" || fail "bot template differs from source"
grok_bots=$box/grok_bots.org
[ -f "$grok_bots" ] || fail "grok_bots.org not seeded"
[ ! -L "$grok_bots" ] || fail "grok_bots.org is a symlink"
[ -w "$grok_bots" ] || fail "grok_bots.org is not writable"
cmp -s "$grok_bots" "$src" || fail "grok_bots.org differs from source"

lib=$box/practices/LIBRARIAN.md
[ -f "$lib" ] || fail "LIBRARIAN.md missing from the mirror"
cmp -s "$lib" ../../grok_bot/practices/LIBRARIAN.md || fail "installed LIBRARIAN.md differs from source"
grep -qxF 'writing-for-agents: https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-for-agents' "$lib" || fail "LIBRARIAN.md missing writing-for-agents URL"
[ ! -e "$box/practices/AGENTS.md" ] || fail "stale AGENTS.md skill-librarian list still present"

grep -q '✔ grok_bot toolbox available' "$log" || fail "announce line not printed under a tty"

# Re-entry restores a drifted template but keeps the user's grok_bots.org.
chmod u+w "$template"
echo 'drift' >>"$template"
echo 'edited' >>"$grok_bots"
devenv shell -- true >/dev/null 2>&1
cmp -s "$template" "$src" || fail "re-entry did not refresh bot template"
tail -n1 "$grok_bots" | grep -qx 'edited' || fail "re-entry overwrote edited grok_bots.org"
[ ! -e "$box/bots" ] || fail "re-entry created bots directory"
cmp -s "$lib" ../../grok_bot/practices/LIBRARIAN.md || fail "re-entry drifted LIBRARIAN.md"

# No practices mirror wipe / eca side effects from this toolbox.
[ -e .eca ] && fail ".eca was created"
find .toolboxes -name eca_manifest 2>/dev/null | grep -q . && fail "eca_manifest was written"

echo "PASS: grok_bot toolbox"
