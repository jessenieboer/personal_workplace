#!/usr/bin/env bash
set -euo pipefail
command -v node >/dev/null
command -v npm >/dev/null
command -v tsc >/dev/null
command -v prettier >/dev/null
test -f package.json
echo "PASS: javascript smoke"
