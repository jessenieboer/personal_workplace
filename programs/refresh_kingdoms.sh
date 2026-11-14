#!/usr/bin/env bash
# Update every devenv project under ~/kingdoms to the latest version of my toolboxes.
# Usage: refresh_kingdoms.sh [ROOT_DIR]   (default: ~/kingdoms)
# First runs refresh_toolboxes.sh so the toolboxes themselves are fresh. Then, for each
# project (a directory with devenv.yaml), runs devenv update, refreshes the devenv caches,
# and runs direnv allow if there is an .envrc and direnv is installed.
# Continues on failure and shows full error output. At the end, lists what failed and exits 1.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR="${1:-$HOME/kingdoms}"

# ~/kingdoms is a bind mount from the external drive; refuse to run on the bare mount point.
if ! mountpoint -q "$HOME/kingdoms"; then
    echo "❌ ~/kingdoms is not mounted (wd-1T missing?). Nothing done." >&2
    exit 1
fi

failed=()

echo "🧰 Refreshing toolboxes first"
echo "==================================================="
if ! "$SCRIPT_DIR/refresh_toolboxes.sh"; then
    failed+=("toolboxes (see refresh_toolboxes.sh output above)")
    echo "   ⚠️  Toolbox refresh had failures; continuing with projects"
fi

echo "🚀 Starting devenv refresh under: $ROOT_DIR"
echo "==================================================="

# Commands read /dev/null so they cannot eat the find list on stdin.
# Skip git internals, generated toolbox dirs, node_modules, devenv/direnv state,
# and personal_workplace (its toolboxes were refreshed above).
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
    ) </dev/null; then
        echo "   ✅ Finished successfully"
    else
        failed+=("$dir")
        echo "   ⚠️  Recorded as FAILED"
    fi
    echo "---------------------------------------------------"
done < <(find "$ROOT_DIR" \
    \( -name .git -o -name .toolboxes -o -name node_modules -o -name .devenv -o -name .direnv -o -name personal_workplace \) -prune \
    -o -type f -name devenv.yaml -print0 | sort -z)

echo "==================================================="
if ((${#failed[@]} > 0)); then
    echo "⚠️  The following had errors:" >&2
    printf '   • %s\n' "${failed[@]}" >&2
    exit 1
fi
echo "✅ No errors occurred. All refreshes completed successfully!"
