#!/usr/bin/env bash
set -euo pipefail
command -v node >/dev/null
command -v npm >/dev/null
command -v tsc >/dev/null
command -v typescript-language-server >/dev/null
command -v prettier >/dev/null
test -f package.json
test -f .toolboxes/javascript_toolbox/.gitignore
test -f .eca/skills/javascript-skill-guide/SKILL.md
test -f .eca/skills/modern-javascript-patterns/SKILL.md
echo "PASS: javascript smoke"
