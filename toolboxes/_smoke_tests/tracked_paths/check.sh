#!/usr/bin/env bash
# Tracked-paths check. Consumers get a toolbox from git, so every relative
# path a toolbox's devenv.nix refers to (./practices, ../_lib/x.nix, ...) has
# to be in git. A path that exists only on disk passes every fixture here but
# breaks consumers with "path does not exist". This reads the index, so staged
# files count; nothing is built.
#
# Checks the toolboxes any fixture imports, the toolboxes those import through
# their devenv.yaml, and _lib. Toolboxes with no fixture are not checked.
set -euo pipefail
cd "$(dirname "$0")/../.."
tbx=$(pwd)

fail() { echo "FAIL: $*"; exit 1; }

# Fixture imports, then everything they import in turn.
queue=$(grep -hE '^[[:space:]]*-[[:space:]]*/toolboxes/' _smoke_tests/*/devenv.yaml \
  | sed -E 's|^[[:space:]]*-[[:space:]]*/toolboxes/||; s|[[:space:]].*||' | sort -u || true)
[ -n "$queue" ] || fail "no fixture imports found in _smoke_tests/*/devenv.yaml"
seen=
while [ -n "$queue" ]; do
  name=$(head -n1 <<<"$queue")
  queue=$(tail -n +2 <<<"$queue")
  case " $seen " in *" $name "*) continue ;; esac
  seen="$seen $name"
  [ -d "$name" ] || fail "imported toolbox $name has no directory under toolboxes/"
  if [ -f "$name/devenv.yaml" ]; then
    more=$(grep -E '^[[:space:]]*-[[:space:]]*/toolboxes/' "$name/devenv.yaml" \
      | sed -E 's|^[[:space:]]*-[[:space:]]*/toolboxes/||; s|[[:space:]].*||' || true)
    queue=$(printf '%s\n%s\n' "$queue" "$more" | sed '/^$/d')
  fi
done

checked=0
for name in _lib $seen; do
  for nix in "$name"/*.nix; do
    [ -f "$nix" ] || continue
    dir=$(dirname "$nix")
    # Path literals: ./x, ../x. Skips comment lines and anything glued to a
    # word, string quote or ${...} (those are strings, not nix paths).
    while IFS= read -r rel; do
      [ -n "$rel" ] || continue
      abs=$(realpath -m "$dir/$rel")
      rp=${abs#"$tbx"/}
      case "$abs" in "$tbx"/*) ;; *) fail "$nix: path $rel leaves toolboxes/" ;; esac
      # A path missing on disk is not this bug: a fixture fails on it unless
      # the toolbox allows it to be absent (builtins.pathExists).
      [ -e "$abs" ] || continue
      checked=$((checked + 1))
      [ -n "$(git ls-files -- "$rp")" ] \
        || fail "toolbox '$name': $nix refers to $rel (toolboxes/$rp), which exists on disk but is not tracked by git. Consumers pulling this repo would fail with 'path does not exist'. git add it."
    done < <(perl -ne 'next if /^\s*#/; while (/(?<![\w.\/\$\x27"{}-])(\.\.?\/[\w.\/-]*[\w])/g) { print "$1\n" }' "$nix" | sort -u)
  done
done

[ "$checked" -gt 0 ] || fail "found no path literals to check"
echo "PASS: tracked paths ($checked paths across: _lib$seen)"
