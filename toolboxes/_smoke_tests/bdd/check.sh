#!/usr/bin/env bash
set -euo pipefail
test -f .eca/agents/builder.md
test -f .eca/agents/designer.md
test -f .eca/agents/planner.md
test -d .toolboxes/bdd_toolbox/features
test -f .toolboxes/bdd_toolbox/brainstorm.txt
echo "PASS: bdd smoke"
