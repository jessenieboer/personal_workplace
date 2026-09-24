#!/usr/bin/env bash
set -euo pipefail
test -f .eca/agents/ai-input-engineer.md
test -f .eca/config.json
echo "PASS: ai smoke"
