#!/usr/bin/env bash
set -euo pipefail
test -f .toolboxes/readme_toolbox/readme.org
echo "PASS: readme smoke"
