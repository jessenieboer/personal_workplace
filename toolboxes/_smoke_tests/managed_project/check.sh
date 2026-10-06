#!/usr/bin/env bash
set -euo pipefail
fragment=.toolboxes/managed_project_toolbox/managed_project_toolbox_dir_locals
test -f "$fragment"
grep -q '"Journal entry"' "$fragment"
! grep -q '@MANAGED_PROJECT_DIRECTORY@' "$fragment"
grep -q '"Journal entry"' .dir-locals.el

toolbox_dir=.toolboxes/managed_project_toolbox/templates
src_root=../../managed_project/templates
for template in ai_project bdd_project bdd_python_project; do
  test -d "$toolbox_dir/$template"
  test -f "$toolbox_dir/$template/devenv.yaml"
  # Dest should match source (covers refresh-on-update, not just first seed).
  diff -rq -x '.#*' "$src_root/$template" "$toolbox_dir/$template" >/dev/null
done

echo "PASS: managed_project smoke"
