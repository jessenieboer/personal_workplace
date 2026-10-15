#!/usr/bin/env bash
set -euo pipefail
frag=.toolboxes/project_management_toolbox/project_management_toolbox_dir_locals
test -f "$frag"
# Org files live at the project root (visible to Dropbox/beorg), not under .toolboxes.
grep -qF "(org-directory . \"$PWD/\")" "$frag"
grep -qF "\"$PWD/smoke-project-management.org\"" "$frag"
grep -qF "(org-directory . \"$PWD/\")" .dir-locals.el
if grep -q 'project_management_toolbox/' "$frag" .dir-locals.el; then
  echo "FAIL: old .toolboxes/project_management_toolbox org path still referenced" >&2
  exit 1
fi
echo "PASS: project_management smoke"
