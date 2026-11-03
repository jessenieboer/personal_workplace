#!/usr/bin/env bash
# Smoke test for the bdd_implementation toolbox.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore devenv.lock

log=$(mktemp)
trap 'rm -f "$log"' EXIT
script -qec "devenv shell -- true" "$log" >/dev/null || { tail -30 "$log"; exit 1; }

fail() { echo "FAIL: $*"; exit 1; }
tb=.toolboxes/bdd_implementation_toolbox
skills=$tb/practices/skills

for n in incremental-implementation planning-and-task-breakdown test-driven-development context-engineering; do
  grep -q "^name: $n\$" "$skills/$n/SKILL.md" 2>/dev/null || fail "$n SKILL.md missing or wrong name"
done
[ -f "$skills/context-engineering/LICENSE" ] || fail "context-engineering LICENSE missing"
[ -f "$tb/practices/rules/bdd-implementation-paths.md" ] || fail "bdd-implementation-paths rule missing"
[ -s "$tb/definition-of-done.md" ] || fail "definition-of-done.md missing or empty"
# Implementation only: none of the spec-writing skills.
for n in domain-modeling grilling grill-with-docs bdd-gherkin-specification gherkin-authoring design-review; do
  [ -e "$skills/$n" ] && fail "$n should not be shipped"
done
grep -q '✔ bdd_implementation toolbox available' "$log" || fail "announce line not printed under a tty"

# Nothing is copied into .eca, and no eca manifest is kept.
[ -e .eca ] && fail ".eca was created"
find .toolboxes -name eca_manifest 2>/dev/null | grep -q . && fail "eca_manifest was written"

echo "PASS: bdd_implementation toolbox"
