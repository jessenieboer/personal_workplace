#!/usr/bin/env bash
# Smoke test for the bdd_spec toolbox.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock

log=$(mktemp)
trap 'rm -f "$log"' EXIT
script -qec "devenv shell -- true" "$log" >/dev/null || { tail -30 "$log"; exit 1; }

fail() { echo "FAIL: $*"; exit 1; }
tb=.toolboxes/bdd_spec_toolbox
skills=$tb/practices/skills

for n in domain-modeling grilling grill-with-docs bdd-gherkin-specification; do
  grep -q "^name: $n" "$skills/$n/SKILL.md" 2>/dev/null || fail "$n SKILL.md missing or wrong"
done
[ -f "$skills/domain-modeling/ADR-FORMAT.md" ] || fail "domain-modeling/ADR-FORMAT.md missing"
# Upstream renamed CONTEXT-FORMAT.md to GLOSSARY-FORMAT.md; either is fine.
[ -f "$skills/domain-modeling/CONTEXT-FORMAT.md" ] || [ -f "$skills/domain-modeling/GLOSSARY-FORMAT.md" ] || fail "domain-modeling format file missing"
[ -f "$skills/bdd-gherkin-specification/reference/gherkin-syntax.md" ] || fail "gherkin skill reference/ missing"
[ -f "$tb/practices/rules/bdd-spec-paths.md" ] || fail "bdd-spec-paths rule missing"
[ -d "$tb/features" ] || fail "features/ not seeded"
# Spec writing only: none of bdd's other skills.
for n in gherkin-authoring design-review incremental-implementation planning-and-task-breakdown test-driven-development context-management; do
  [ -e "$skills/$n" ] && fail "$n should not be shipped"
done
[ -e $tb/definition-of-done.md ] && fail "definition-of-done.md should not be shipped"
grep -q '✔ bdd_spec toolbox available' "$log" || fail "announce line not printed under a tty"

# Nothing is copied into .eca, and no eca manifest is kept.
[ -e .eca ] && fail ".eca was created"
find .toolboxes -name eca_manifest 2>/dev/null | grep -q . && fail "eca_manifest was written"

echo "PASS: bdd_spec toolbox"
