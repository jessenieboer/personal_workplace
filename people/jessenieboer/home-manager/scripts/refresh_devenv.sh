# update all my _project_management stuff to the latest version of my toolbox
# Continues on failure and shows full error output.
# At the end, lists directories that had errors.

set -uo pipefail

ROOT_DIR="${1:-.}"
ERROR_LOG=$(mktemp /tmp/devenv-refresh-errors.XXXXXX)

echo "🚀 Starting devenv refresh under: $ROOT_DIR"
echo "==================================================="

find "$ROOT_DIR" -type d -exec test -f {}/devenv.nix \; -print0 |
while IFS= read -r -d '' dir; do
    echo "📁 Processing: $dir"

    (
        cd "$dir" || { echo "❌ ERROR: Failed to cd into $dir" >&2; exit 1; }

        echo "   🔄 Running: devenv update"
        devenv update || { echo "   ❌ Failed: devenv update" >&2; exit 1; }

        echo "   🔄 Running: devenv shell --refresh-eval-cache --refresh-task-cache"
        devenv shell --refresh-eval-cache --refresh-task-cache -- true ||
            { echo "   ❌ Failed: devenv shell refresh" >&2; exit 1; }
    )

    if [ $? -ne 0 ]; then
        echo "$dir" >> "$ERROR_LOG"
        echo "   ⚠️  Recorded as FAILED"
    else
        echo "   ✅ Finished successfully"
    fi
    echo "---------------------------------------------------"
done

echo "==================================================="
if [ -s "$ERROR_LOG" ]; then
    echo "⚠️  The following directories had errors:"
    sort -u "$ERROR_LOG" | sed 's/^/   • /'
else
    echo "✅ No errors occurred. All refreshes completed successfully!"
fi

rm -f "$ERROR_LOG"
