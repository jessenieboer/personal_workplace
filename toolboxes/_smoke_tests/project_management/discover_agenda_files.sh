#!/usr/bin/env bash
# Discovery tests for project_management_toolbox.subproject_agenda_files.
# Builds a nested fixture, then evaluates the toolbox twice:
#   - repository source layout (toolboxes/project_management)
#   - a copy under .toolboxes/, the way a deployed tree names that directory
# The copy imports ../_lib by the same relative path. Needs Nix.
set -euo pipefail

if ! command -v nix-build >/dev/null; then
  echo "FAIL: nix-build is not on PATH" >&2
  exit 1
fi

script_dir=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$script_dir/../../.." && pwd)
test -f "$repo/toolboxes/project_management/devenv.nix"
test -f "$repo/toolboxes/_lib/subproject_agenda_files.nix"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fixture=$tmp/fixture
deployed=$tmp/deployed/.toolboxes

live() {
  mkdir -p "$(dirname "$1")"
  printf 'live\n' >"$1"
}

junk() {
  mkdir -p "$(dirname "$1")"
  printf 'junk\n' >"$1"
}

# Included: directly inside a nested project_management_toolbox directory.
live "$fixture/a_first/.toolboxes/project_management_toolbox/a_first_inbox.org"
live "$fixture/a_first/.toolboxes/project_management_toolbox/z.org"
live "$fixture/a_first/nested/.toolboxes/project_management_toolbox/nested.org"
live "$fixture/m_mid/.toolboxes/project_management_toolbox/m.org"
live "$fixture/spiritual_formation/.toolboxes/project_management_toolbox/spiritual_formation.org"
live "$fixture/spiritual_formation/.toolboxes/project_management_toolbox/spiritual_formation_inbox.org"

# Root project's own toolbox dir. Discovery leaves it out; the template adds
# <project_name>.org itself.
junk "$fixture/.toolboxes/project_management_toolbox/empire_capitol.org"
junk "$fixture/.toolboxes/project_management_toolbox/empire_inbox.org"
junk "$fixture/.toolboxes/project_management_toolbox/.#empire.org"

# Lock, autosave, backup, non-org, nested under the toolbox dir, other toolbox.
junk "$fixture/a_first/.toolboxes/project_management_toolbox/.#lock.org"
junk "$fixture/a_first/.toolboxes/project_management_toolbox/#autosave.org#"
junk "$fixture/a_first/.toolboxes/project_management_toolbox/backup.org~"
junk "$fixture/a_first/.toolboxes/project_management_toolbox/notes.txt"
junk "$fixture/a_first/.toolboxes/project_management_toolbox/extra/deep.org"
junk "$fixture/a_first/not_in_toolbox.org"
junk "$fixture/a_first/.toolboxes/other_toolbox/other.org"

# Symlink file, and a symlink directory. The target is outside the fixture, so
# the org file is reachable only by following the link.
outside=$tmp/outside_target
mkdir -p "$outside/.toolboxes/project_management_toolbox"
printf 'hidden\n' >"$outside/.toolboxes/project_management_toolbox/hidden.org"
printf 'outside\n' >"$outside/outside.org"
ln -s "$outside/outside.org" "$fixture/a_first/.toolboxes/project_management_toolbox/linked.org"
ln -s "$outside" "$fixture/linked_dir"

for skip in .git .devenv .direnv node_modules result .cache; do
  junk "$fixture/$skip/nested/.toolboxes/project_management_toolbox/no.org"
done

mkdir -p "$deployed/project_management"
cp -a "$repo/toolboxes/_lib" "$deployed/_lib"
cp -a "$repo/toolboxes/project_management/devenv.nix" "$deployed/project_management/devenv.nix"
cp -a "$repo/toolboxes/project_management/templates" "$deployed/project_management/templates"
cp -a "$repo/toolboxes/project_management/settings" "$deployed/project_management/settings"
grep -q 'import ../_lib/subproject_agenda_files.nix' "$deployed/project_management/devenv.nix"
test -f "$deployed/_lib/subproject_agenda_files.nix"
test "$deployed/project_management/devenv.nix" != "$repo/toolboxes/project_management/devenv.nix"

run() {
  expect_new=$1
  nix-build --option eval-cache false --no-out-link \
    "$script_dir/discover_agenda_files.nix" \
    --argstr fixture "$fixture" \
    --argstr sourceModule "$repo/toolboxes/project_management/devenv.nix" \
    --argstr deployedModule "$deployed/project_management/devenv.nix" \
    --argstr deployedHelper "$deployed/_lib/subproject_agenda_files.nix" \
    --arg expectNew "$expect_new" >/dev/null
}

echo "phase 1: nested org files already in the fixture"
run false
echo "phase 2: new nested regular org file"
live "$fixture/nested_new/deep/.toolboxes/project_management_toolbox/brand_new.org"
run true

echo "PASS: subproject agenda discovery"
