# update all my _project_management stuff to the latest version of my toolbox
# Recursively run "devenv update" + "devenv shell --refresh-eval-cache"
# in every subdirectory that contains a devenv.nix file,
# with a Github Personal Access Token, fetched from Bitwarden Secrets Manager, using an Access Token stored locally in pass
# Continues on failure and shows full error output.

set -uo pipefail

# ==================== Configuration ====================
MAT_NAME_IN_PASS="bws/nucbox_access_token"
SECRET_ID="2e5149d3-f58c-4e43-87ef-b42601056f73"

ROOT_DIR="${1:-.}"

# ==================== Fetch tokens once at the start ====================
echo "🔑 Fetching GitHub Personal Access Token via pass + Bitwarden..."

BWS_TOKEN=$(pass show "$MAT_NAME_IN_PASS" 2>/dev/null | head -n1)

if [ -z "$BWS_TOKEN" ]; then
    echo "❌ ERROR: Failed to retrieve BWS access token from pass."
    echo "   Make sure the token is stored at: $MAT_NAME_IN_PASS"
    echo "   Run: pass show $MAT_NAME_IN_PASS"
    exit 1
fi

echo "   ✓ Loaded BWS machine access token from pass"

NIX_GITHUB_PAT=$(bws secret get "$SECRET_ID" --output json -t "$BWS_TOKEN" | jq -r '.value')

if [ -z "$NIX_GITHUB_PAT" ] || [ "$NIX_GITHUB_PAT" = "null" ]; then
    echo "❌ ERROR: Failed to fetch GitHub token from Bitwarden Secrets Manager."
    echo "   Check that the secret UUID is correct and your Machine Account has access."
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

    (
        cd "$dir" || {
            echo "❌ ERROR: Failed to cd into $dir"
            exit 1
        }

        echo "   🔄 Running: devenv update"
        if ! NIX_CONFIG="access-tokens = github.com=$NIX_GITHUB_PAT" devenv update; then
            echo "   ❌ Failed: devenv update"
        else
            echo "   ✅ Success: devenv update"
        fi

        echo "   🔄 Running: devenv shell --refresh-eval-cache --refresh-task-cache "
        if ! devenv shell --refresh-eval-cache --refresh-task-cache -- \
             echo "✅ devenv shell cache refreshed successfully"; then
             echo "   ❌ Failed: devenv shell --refresh-eval-cache --refresh-task-cache "
        else
            echo "   ✅ Success: devenv shell --refresh-eval-cache --refresh-task-cache "
        fi
    )

    echo "   ✅ Finished"
    echo "---------------------------------------------------"
done

echo "==================================================="
echo "🎉 All directories processed! (script continued through any errors)"
