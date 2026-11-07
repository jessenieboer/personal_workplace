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

# Consumer-created file survives a second enterShell (seed must not wipe).
echo 'keep-me' >"$bots/consumer-bot.md"
devenv shell -- true >/dev/null 2>&1
grep -qx 'keep-me' "$bots/consumer-bot.md" || fail "re-entry removed consumer bot file"
[ -f "$keep" ] || fail ".gitkeep missing after re-entry"
[ ! -e .toolboxes/grok_bot_toolbox/practices/_bots ] || fail "re-entry created stale _bots"

[ ! -e .toolboxes/grok_bot_toolbox/practices/bots ] || fail "re-entry created stale practices/bots"

# No practices mirror wipe / eca side effects from this toolbox.
[ -e .eca ] && fail ".eca was created"
find .toolboxes -name eca_manifest 2>/dev/null | grep -q . && fail "eca_manifest was written"

echo "PASS: grok_bot toolbox"
