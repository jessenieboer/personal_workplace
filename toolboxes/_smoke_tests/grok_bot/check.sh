#!/usr/bin/env bash
# Smoke test for the grok_bot toolbox (bots directory infrastructure).
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
bots=.toolboxes/grok_bot_toolbox/bots
keep=$bots/.gitkeep

[ -d "$bots" ] || fail "bots directory not created"
[ -f "$keep" ] || fail ".gitkeep not seeded"
[ -w "$bots" ] || fail "bots is not writable"
# Must be a real directory in the project, not a store symlink.
[ ! -L "$bots" ] || fail "bots is a symlink"
[ ! -L .toolboxes/grok_bot_toolbox ] || fail "grok_bot_toolbox is a symlink"
# Must not recreate either retired bot path.
[ ! -e .toolboxes/grok_bot_toolbox/practices/bots ] || fail "stale practices/bots path still present"
[ ! -e .toolboxes/grok_bot_toolbox/practices/_bots ] || fail "stale practices/_bots path still present"

template=.toolboxes/grok_bot_toolbox/templates/grok_bot_template.org
[ -f "$template" ] || fail "bot template not seeded"
[ ! -L "$template" ] || fail "bot template is a symlink"
[ -w "$template" ] || fail "bot template is not writable"
cmp -s "$template" ../../grok_bot/templates/grok_bots_template.org || fail "seeded template differs from source"
grok_bots=.toolboxes/grok_bot_toolbox/grok_bots.org
[ -f "$grok_bots" ] || fail "grok_bots.org not seeded"
[ ! -L "$grok_bots" ] || fail "grok_bots.org is a symlink"
[ -w "$grok_bots" ] || fail "grok_bots.org is not writable"
cmp -s "$grok_bots" ../../grok_bot/templates/grok_bots_template.org || fail "grok_bots.org differs from source"

grep -q '✔ grok_bot toolbox available' "$log" || fail "announce line not printed under a tty"

# Ignore exceptions must be merged so bot files are trackable.
grep -qF '!.toolboxes/grok_bot_toolbox/bots/' .gitignore ||
	fail "root .gitignore missing bots un-ignore"

repo=$(mktemp -d)
trap 'rm -f "$log"; rm -rf "$repo"' EXIT
cp -a .gitignore "$repo/"
mkdir -p "$repo/$bots"
echo 'synthetic-bot' >"$repo/$bots/smoke-bot.md"
git -C "$repo" init -q
git -C "$repo" check-ignore -q "$bots/smoke-bot.md" && fail "bot file is ignored by git"
git -C "$repo" add "$bots/smoke-bot.md"
git -C "$repo" status --porcelain | grep -qF "$bots/smoke-bot.md" || fail "bot file not staged in disposable repo"

# Consumer-created and edited files survive a second enterShell (seed must not wipe).
echo 'keep-me' >"$bots/consumer-bot.md"
echo 'edited' >>"$template"
echo 'edited' >>"$grok_bots"
devenv shell -- true >/dev/null 2>&1
grep -qx 'keep-me' "$bots/consumer-bot.md" || fail "re-entry removed consumer bot file"
tail -n1 "$template" | grep -qx 'edited' || fail "re-entry overwrote edited template"
tail -n1 "$grok_bots" | grep -qx 'edited' || fail "re-entry overwrote edited grok_bots.org"
[ -f "$keep" ] || fail ".gitkeep missing after re-entry"
[ ! -e .toolboxes/grok_bot_toolbox/practices/_bots ] || fail "re-entry created stale _bots"

[ ! -e .toolboxes/grok_bot_toolbox/practices/bots ] || fail "re-entry created stale practices/bots"

# No practices mirror wipe / eca side effects from this toolbox.
[ -e .eca ] && fail ".eca was created"
find .toolboxes -name eca_manifest 2>/dev/null | grep -q . && fail "eca_manifest was written"

echo "PASS: grok_bot toolbox"
