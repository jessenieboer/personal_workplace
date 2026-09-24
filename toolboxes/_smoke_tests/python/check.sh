#!/usr/bin/env bash
set -euo pipefail
command -v python >/dev/null
command -v uv >/dev/null
command -v ruff >/dev/null
command -v ty >/dev/null
test -f pyproject.toml
test -f .toolboxes/python_toolbox/.gitignore
echo "PASS: python smoke"
