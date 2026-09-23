#!/usr/bin/env bash
set -euo pipefail
command -v opencode >/dev/null
test -f .opencode/opencode.json
test -f .eca/agents/code-explainer.md
test -f .toolboxes/code_toolbox/.gitignore
echo "PASS: code smoke"
