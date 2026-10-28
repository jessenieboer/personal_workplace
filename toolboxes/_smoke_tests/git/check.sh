#!/usr/bin/env bash
# Smoke test for the git toolbox.
set -euo pipefail
cd "$(dirname "$0")"
here=$(pwd)

[ -d toolboxes ] && chmod -R u+w toolboxes
rm -rf .git toolboxes .devenv .devenv.* .direnv .dir-locals.el .envrc .toolboxes .eca .gitignore .gitattributes devenv.lock
git init -q .
# This fixture is its own repo, so /toolboxes resolves inside it: copy the
# checkout's toolboxes in (minus generated state and the smoke tests).
mkdir toolboxes
(cd ../.. && tar --exclude=.devenv --exclude=.direnv --exclude=.eca --exclude=.toolboxes --exclude=_smoke_tests -cf - .) | tar -xf - -C toolboxes

log=$(mktemp)
# Drop the nested repo afterwards so the outer repo never sees an embedded repo.
trap 'chmod -R u+w toolboxes 2>/dev/null; rm -rf "$log" .git toolboxes' EXIT
script -qec "devenv shell -- true" "$log" >/dev/null || { tail -30 "$log"; exit 1; }

fail() { echo "FAIL: $*"; exit 1; }
cfg() { git config "$@" 2>/dev/null || true; }

inc="$here/.toolboxes/git_toolbox/gitconfig"
[ -f "$inc" ] || fail "gitconfig not written"
for k in pull.rebase pull.ff merge.ff core.autocrlf core.safecrlf tag.sort push.followTags fetch.prune rebase.autoStash; do
  git config -f "$inc" --get "$k" >/dev/null || fail "gitconfig lacks $k"
done
[ "$(git config --local --get-all include.path)" = "$inc" ] || fail "include.path does not point to gitconfig"
[ "$(cfg pull.rebase)" = true ] || fail "pull.rebase"
[ "$(cfg pull.ff)" = only ] || fail "pull.ff"
[ "$(cfg merge.ff)" = only ] || fail "merge.ff"
[ "$(cfg tag.sort)" = version:refname ] || fail "tag.sort"
[ "$(cfg push.followTags)" = true ] || fail "push.followTags"
[ "$(git config -f "$inc" --get-all versionsort.suffix | tr "\n" " ")" = "-alpha -beta -rc " ] || fail "versionsort.suffix"
git config -f "$inc" --get user.name >/dev/null && fail "toolbox sets user identity"
git config -f "$inc" --get-regexp "^commit\." >/dev/null && fail "toolbox config sets commit.*"
[ -z "$(cfg commit.template)" ] || fail "commit.template is set"
git config -f "$inc" --get core.filemode >/dev/null && fail "toolbox sets core.fileMode"
grep -qx '\* text=auto eol=lf' .gitattributes || fail ".gitattributes not seeded"
grep -qx '.devenv' .gitignore || fail ".gitignore merge missing toolbox entries"
grep -qx '\*' .gitignore && fail ".gitignore merge picked up a lone * from a fragment"
grep -q '✔ git toolbox available' "$log" || fail "announce line not printed under a tty"

devenv shell -- true >/dev/null 2>&1
[ "$(git config --local --get-all include.path | wc -l)" = 1 ] || fail "include.path duplicated on re-entry"

for f in .toolboxes/git_toolbox/practices/skills/git-commit/SKILL.md .eca/skills/git-commit/SKILL.md; do
  [ -f "$f" ] || fail "$f missing"
done
grep -q "^name: git-commit" .toolboxes/git_toolbox/practices/skills/git-commit/SKILL.md || fail "git-commit skill content wrong"

# The merge reads project.gitignore files only: a toolbox's own lone-* .gitignore stays out.
mkdir -p .toolboxes/x_toolbox
printf 'fromfrag\n' > .toolboxes/x_toolbox/project.gitignore
printf '*\n' > .toolboxes/x_toolbox/.gitignore
devenv shell -- true >/dev/null 2>&1
grep -qx 'fromfrag' .gitignore || fail "project.gitignore not merged"
grep -qx '\*' .gitignore && fail "a toolbox's own .gitignore leaked into the merge"

# git_toolbox does not ignore itself. A stale generated .gitignore there is
# removed; one the user wrote is left alone.
printf '*\n' > .toolboxes/git_toolbox/.gitignore
devenv shell -- true >/dev/null 2>&1
[ ! -e .toolboxes/git_toolbox/.gitignore ] || fail "stale generated .gitignore not removed"
printf 'mine\n' > .toolboxes/git_toolbox/.gitignore
devenv shell -- true >/dev/null 2>&1
[ "$(cat .toolboxes/git_toolbox/.gitignore)" = mine ] || fail "a user-written .gitignore was removed"


echo "PASS: git toolbox"
