#!/usr/bin/env bash
# Refresh every toolbox so it picks up the latest versions of what it imports.
# For each toolbox: devenv update, then re-enter the shell with fresh caches.
# Continues past failures and lists the failed toolboxes at the end.
#
# Usage: programs/refresh_toolboxes.sh [--dry-run] [toolbox ...]
#   No toolbox names: every toolboxes/<name>/ with a devenv.nix,
#   skipping _lib and _smoke_tests.
set -uo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
dry_run=false
if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=true
  shift
fi

dirs=()
if (($# > 0)); then
  for name in "$@"; do
    dirs+=("$repo_root/toolboxes/$name")
  done
else
  for dir in "$repo_root"/toolboxes/*/; do
    dir=${dir%/}
    case "$(basename "$dir")" in _lib | _smoke_tests) continue ;; esac
    [[ -f "$dir/devenv.nix" ]] && dirs+=("$dir")
  done
fi

failed=()
for dir in "${dirs[@]}"; do
  name=$(basename "$dir")
  if [[ ! -f "$dir/devenv.nix" ]]; then
    echo "FAIL $name: no devenv.nix" >&2
    failed+=("$name")
    continue
  fi
  if $dry_run; then
    echo "would refresh $name"
    continue
  fi
  echo "== $name"
  if (cd "$dir" && devenv update &&
    devenv shell --refresh-eval-cache --refresh-task-cache -- true); then
    echo "ok   $name"
  else
    echo "FAIL $name" >&2
    failed+=("$name")
  fi
done

if ((${#failed[@]} > 0)); then
  echo "Failed: ${failed[*]}" >&2
  exit 1
fi
$dry_run && exit 0
echo "All ${#dirs[@]} toolboxes refreshed."
