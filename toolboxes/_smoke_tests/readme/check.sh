#!/usr/bin/env bash
set -euo pipefail
test -f .toolboxes/readme_toolbox/readme.org
test -f .toolboxes/readme_toolbox/glossary.org
! grep -q 00000000-0000-0000-0000-000000000000 .toolboxes/readme_toolbox/glossary.org
echo "PASS: readme smoke"
