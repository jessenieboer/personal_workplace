#!/usr/bin/env bash
set -euo pipefail
fail() { echo "FAIL: $*" >&2; exit 1; }

fragment=.toolboxes/standard_project_toolbox/standard_project_toolbox_dir_locals
test -f "$fragment" || fail "missing $fragment"
grep -q '"Journal entry"' "$fragment" || fail "no journal capture template in fragment"
# placeholder must be substituted (note: `! grep` does not trip set -e)
if grep -q '@[A-Z_]*@' "$fragment"; then fail "unsubstituted placeholder in fragment"; fi
grep -q '(org-directory \. "/' "$fragment" || fail "org-directory not an absolute path"
grep -q '"Journal entry"' .dir-locals.el || fail "fragment not merged into .dir-locals.el"

toolbox_dir=.toolboxes/standard_project_toolbox/templates
src_root=../../standard_project/templates
found=0
for src in "$src_root"/*/; do
  template=$(basename "$src")
  found=$((found + 1))
  test -d "$toolbox_dir/$template" || fail "template $template not copied"
  test -f "$toolbox_dir/$template/devenv.yaml" || fail "template $template has no devenv.yaml"
  # Dest should match source (covers refresh-on-update, not just first seed).
  diff -rq -x '.#*' "$src_root/$template" "$toolbox_dir/$template" >/dev/null || fail "template $template out of sync"
done
[ "$found" -gt 0 ] || fail "no templates found under $src_root"
if grep -rq 'personal_workplace/master' "$toolbox_dir"; then fail "a template still pins personal_workplace/master"; fi

echo "PASS: standard_project smoke ($found templates)"
