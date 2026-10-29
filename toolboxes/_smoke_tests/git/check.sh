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
grep -qx '\* text=auto eol=lf' .gitattributes || fail ".gitattributes not written"
[ "$(stat -c %a .gitattributes)" = 644 ] || fail ".gitattributes is not mode 644"
[ "$(stat -c %a .gitignore)" = 644 ] || fail ".gitignore is not mode 644"
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


# .gitattributes: the base line comes first; fragments merge in after it, in
# order and without sorting; blank and repeated lines are dropped.
mkdir -p .toolboxes/a_toolbox .toolboxes/z_toolbox .toolboxes/n_toolbox/.toolboxes/inner_toolbox
printf '*.zz -diff\n\n* text=auto eol=lf\n' > .toolboxes/a_toolbox/project.gitattributes
printf '*.aa diff=aa' > .toolboxes/z_toolbox/project.gitattributes
printf '*.nested -diff\n' > .toolboxes/n_toolbox/.toolboxes/inner_toolbox/project.gitattributes
devenv shell -- true >/dev/null 2>&1
[ "$(sed -n 2p .gitattributes)" = '* text=auto eol=lf' ] || fail "base line is not first in the managed block"
[ "$(grep -cx '\* text=auto eol=lf' .gitattributes)" = 1 ] || fail "repeated fragment line not deduplicated"
[ "$(grep -nx '\*.zz -diff' .gitattributes | cut -d: -f1)" -lt "$(grep -nx '\*.aa diff=aa' .gitattributes | cut -d: -f1)" ] || fail "fragments not merged in path order"
grep -qx '\*.nested -diff' .gitattributes && fail "a nested project's fragment leaked into the merge"
grep -qx '\*.aa diff=aa' .gitattributes || fail "project.gitattributes without a trailing newline not merged"

# Idempotent, and the user's own lines survive, placed after the managed block.
before=$(mktemp); cp .gitattributes "$before"
devenv shell -- true >/dev/null 2>&1
cmp -s .gitattributes "$before" || fail ".gitattributes changed on a no-op re-entry"
printf '\n*.png binary\n*.lock -diff\n' >> .gitattributes
devenv shell -- true >/dev/null 2>&1
devenv shell -- true >/dev/null 2>&1
grep -qx '\*.png binary' .gitattributes || fail "user line removed"
grep -qx '\*.lock -diff' .gitattributes || fail "second user line removed"
[ "$(grep -c "toolbox-managed" .gitattributes)" = 2 ] || fail "managed markers duplicated"
[ "$(tail -n 2 .gitattributes | tr "\n" " ")" = "*.png binary *.lock -diff " ] || fail "user lines not kept at the end"
[ "$(grep -c "^$" .gitattributes)" = 1 ] || fail "blank lines accumulate"

# A removed fragment line leaves the file on the next merge.
rm .toolboxes/z_toolbox/project.gitattributes
devenv shell -- true >/dev/null 2>&1
grep -qx '\*.aa diff=aa' .gitattributes && fail "dropped fragment line stayed"
grep -qx '\*.png binary' .gitattributes || fail "user line lost when a fragment line dropped"

# An existing project with the old hand-seeded file: the base line moves into
# the block, other lines are kept.
rm -f "$before"
printf '* text=auto eol=lf\n*.svg text\n' > .gitattributes
devenv shell -- true >/dev/null 2>&1
[ "$(grep -cx '\* text=auto eol=lf' .gitattributes)" = 1 ] || fail "seeded base line duplicated"
grep -qx '\*.svg text' .gitattributes || fail "hand-written line lost on migration"

echo "PASS: git toolbox"
