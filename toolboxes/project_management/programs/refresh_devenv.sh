# update all my _project_management stuff to the latest version of my toolbox
# Continues on failure and shows full error output.
# At the end, lists directories that had errors.

set -uo pipefail

# ==================== Configuration ====================
MAT_NAME_IN_PASS="bws/nucbox_access_token"
SECRET_ID="2e5149d3-f58c-4e43-87ef-b42601056f73"

ROOT_DIR="${1:-.}"

# ==================== Error tracking ====================
ERROR_LOG=$(mktemp /tmp/devenv-refresh-errors.XXXXXX)

# ==================== Fetch tokens once at the start ====================
echo "🔑 Fetching GitHub Personal Access Token via pass + Bitwarden..."

BWS_TOKEN=$(pass show "$MAT_NAME_IN_PASS" 2>/dev/null | head -n1)

if [ -z "$BWS_TOKEN" ]; then
    echo "❌ ERROR: Failed to retrieve BWS access token from pass."
    exit 1
fi

echo "   ✓ Loaded BWS machine access token from pass"

NIX_GITHUB_PAT=$(bws secret get "$SECRET_ID" --output json -t "$BWS_TOKEN" | jq -r '.value')

if [ -z "$NIX_GITHUB_PAT" ] || [ "$NIX_GITHUB_PAT" = "null" ]; then
    echo "❌ ERROR: Failed to fetch GitHub token from Bitwarden Secrets Manager."
    exit 1
fi

echo "   ✓ Successfully loaded GitHub token from Bitwarden Secrets Manager"
echo

# ==================== Start processing ====================
echo "🚀 Starting devenv refresh under: $ROOT_DIR"
echo "==================================================="

find "$ROOT_DIR" -type d -exec test -f {}/devenv.nix \; -print0 |
while IFS= read -r -d '' dir; do
    echo "📁 Processing: $dir"
    local_failed=0

    (
        cd "$dir" || {
            echo "❌ ERROR: Failed to cd into $dir" >&2
            exit 1
        }

        echo "   🔄 Running: devenv update"
        if ! NIX_CONFIG="access-tokens = github.com=$NIX_GITHUB_PAT" devenv update; then
            echo "   ❌ Failed: devenv update" >&2
            exit 1   # exit subshell on failure
        else
            echo "   ✅ Success: devenv update"
        fi

        echo "   🔄 Running: devenv shell --refresh-eval-cache --refresh-task-cache"
        if ! devenv shell --refresh-eval-cache --refresh-task-cache -- \
             echo "✅ devenv shell cache refreshed successfully"; then
            echo "   ❌ Failed: devenv shell --refresh-eval-cache --refresh-task-cache" >&2
            exit 1
        else
            echo "   ✅ Success: devenv shell --refresh-eval-cache --refresh-task-cache"
        fi
    )

    if [ $? -ne 0 ]; then
        echo "$dir" >> "$ERROR_LOG"
        echo "   ⚠️  Recorded as FAILED"
    else
        echo "   ✅ Finished successfully"
    fi

    echo "---------------------------------------------------"
done

# ==================== Final Report ====================
echo "==================================================="
echo "🎉 All directories processed!"

if [ -s "$ERROR_LOG" ]; then
    echo "⚠️  The following directories had errors:"
    cat "$ERROR_LOG" | sort | uniq | sed 's/^/   • /'
    echo
    echo "You may want to check these directories manually."
else
    echo "✅ No errors occurred. All refreshes completed successfully!"
fi

rm -f "$ERROR_LOG"
echo "Done."
