# run devenv commands, giving Nix a Github Personal Access Token, fetched from Bitwarden Secrets Manager, using an Access Token stored locally in pass

set -euo pipefail

# machine account token in pass
MAT_NAME_IN_PASS="bws/<token name>"

# nix_github_pat id in bw secrets manager
SECRET_ID="2e5149d3-f58c-4e43-87ef-b42601056f73"

# get bws token from pass
BWS_TOKEN=$(pass show "$MAT_NAME_IN_PASS" 2>/dev/null | head -n1)

if [ -z "$BWS_TOKEN" ]; then
  echo "  Failed to retrieve BWS access token from pass."
  echo "  Make sure the token is stored at: $PASS_NAME"
  echo "  Run: pass show $PASS_NAME"
  exit 1
fi

echo "Successfully loaded BWS machine access token from pass"

# get nix_github_pat from bws
NIX_GITHUB_PAT=$(bws secret get "$SECRET_ID" --output json -t "$BWS_TOKEN" | jq -r '.value')

if [ -z "$NIX_GITHUB_PAT" ]; then
 echo "  Failed to fetch GitHub token from Bitwarden Secrets Manager."
 echo "  Check that the secret UUID is correct and your Machine Account has access."
 exit 1
fi

echo "Successfully loaded GitHub token from Bitwarden Secrets Manager (via pass)"

NIX_CONFIG="access-tokens = github.com=$NIX_GITHUB_PAT" devenv "$@"
