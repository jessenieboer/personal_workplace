#!/usr/bin/env bash
# update all my devenv projects under ~/kingdoms to the latest version of my toolboxes
# Usage: refresh_devenv.sh [ROOT_DIR]   (default: the directory this script lives in)
# For each project (a directory with devenv.yaml), runs devenv update, refreshes the
# devenv caches, and runs direnv allow if there is an .envrc and direnv is installed.
# Continues on failure and shows full error output. At the end, lists directories that had errors.

set -euo pipefail

ROOT_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# ~/kingdoms is a bind mount from the external drive; refuse to run on the bare mount point.
if ! mountpoint -q "$HOME/kingdoms"; then
    echo "❌ ~/kingdoms is not mounted (wd-1T missing?). Nothing done." >&2
    exit 1
fi

ERROR_LOG=$(mktemp /tmp/devenv-refresh-errors.XXXXXX)
trap 'rm -f "$ERROR_LOG"' EXIT

echo "🚀 Starting devenv refresh under: $ROOT_DIR"
echo "==================================================="

# Skip git internals, generated toolbox dirs, node_modules and devenv/direnv state.
while IFS= read -r -d '' file; do
    dir=$(dirname "$file")
    echo "📁 Processing: $dir"

    if (
        cd "$dir" || { echo "❌ ERROR: Failed to cd into $dir" >&2; exit 1; }

        echo "   🔄 Running: devenv update"
        devenv update || { echo "   ❌ Failed: devenv update" >&2; exit 1; }

        echo "   🔄 Running: devenv shell --refresh-eval-cache --refresh-task-cache"
        devenv shell --refresh-eval-cache --refresh-task-cache -- true ||
            { echo "   ❌ Failed: devenv shell refresh" >&2; exit 1; }

        # The emacs/standard_project toolboxes write .envrc on shell entry, so allow it last.
        if [ -f .envrc ] && command -v direnv >/dev/null; then
            echo "   🔄 Running: direnv allow"
            direnv allow . || { echo "   ❌ Failed: direnv allow" >&2; exit 1; }
        fi
    ); then
        echo "   ✅ Finished successfully"
    else
        echo "$dir" >> "$ERROR_LOG"
        echo "   ⚠️  Recorded as FAILED"
    fi
    echo "---------------------------------------------------"
done < <(find "$ROOT_DIR" \
    \( -name .git -o -name .toolboxes -o -name node_modules -o -name .devenv -o -name .direnv -o -name personal_workplace \) -prune \
    -o -type f -name devenv.yaml -print0 | sort -z)

echo "==================================================="
if [ -s "$ERROR_LOG" ]; then
    echo "⚠️  The following directories had errors:"
    sort -u "$ERROR_LOG" | sed 's/^/   • /'
else
    echo "✅ No errors occurred. All refreshes completed successfully!"
fi
