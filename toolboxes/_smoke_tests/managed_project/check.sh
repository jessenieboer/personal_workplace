#!/usr/bin/env bash
set -euo pipefail
fragment=.toolboxes/managed_project_toolbox/managed_project_toolbox_dir_locals
test -f "$fragment"
grep -q '"Journal entry"' "$fragment"
! grep -q '@MANAGED_PROJECT_DIRECTORY@' "$fragment"
grep -q '"Journal entry"' .dir-locals.el
echo "PASS: managed_project smoke"
