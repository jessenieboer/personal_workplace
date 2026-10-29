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

inc="$here/.toolboxes/git_toolbox/settings/.gitconfig"
[ -f "$inc" ] || fail "settings/.gitconfig not seeded"
[ ! -e .toolboxes/git_toolbox/gitconfig ] || fail "the old refreshed gitconfig was written"
for k in pull.rebase pull.ff merge.ff core.autocrlf core.safecrlf tag.sort push.followTags fetch.prune rebase.autoStash; do
  git config -f "$inc" --get "$k" >/dev/null || fail "gitconfig lacks $k"
done
[ "$(git config --local --get-all include.path)" = "$inc" ] || fail "include.path is not the seeded settings/.gitconfig"
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

# Each toolbox's settings files are copied identically and read-only into
# .toolboxes/<name>_toolbox/settings/, and refreshed when they drift.
sg=.toolboxes/git_toolbox/settings/.gitignore
sa=.toolboxes/git_toolbox/settings/.gitattributes
cmp -s "$sg" toolboxes/git/settings/.gitignore || fail "settings/.gitignore is not identical to its source"
cmp -s "$sa" toolboxes/git/settings/.gitattributes || fail "settings/.gitattributes is not identical to its source"
[ "$(stat -c %a "$sg")" = 444 ] || fail "settings/.gitignore is not read-only"
[ "$(stat -c %a "$sa")" = 444 ] || fail "settings/.gitattributes is not read-only"
chmod 644 "$sg"; printf 'edited\n' >> "$sg"
chmod 644 "$sa"
devenv shell -- true >/dev/null 2>&1
cmp -s "$sg" toolboxes/git/settings/.gitignore || fail "an edited settings/.gitignore was not refreshed"
[ "$(stat -c %a "$sg")" = 444 ] || fail "refreshed settings/.gitignore is not read-only"
[ "$(stat -c %a "$sa")" = 444 ] || fail "a settings/.gitattributes with a changed mode was not made read-only again"
# The managed block comes first in .gitignore, the git toolbox's lines first in it.
[ "$(sed -n 1p .gitignore | cut -c1-23)" = '# >>> toolbox-managed: ' ] || fail ".gitignore does not start with the managed block"
[ "$(sed -n 2p .gitignore)" = "$(sed -n 1p toolboxes/git/settings/.gitignore)" ] || fail "git toolbox lines are not first in the .gitignore block"
# Lines outside the block are the project's own and survive.
printf '\nmy-own-ignore\n' >> .gitignore
devenv shell -- true >/dev/null 2>&1
devenv shell -- true >/dev/null 2>&1
grep -qx 'my-own-ignore' .gitignore || fail "a user line in .gitignore was removed"
[ "$(grep -c 'toolbox-managed' .gitignore)" = 2 ] || fail ".gitignore managed markers duplicated"
[ "$(tail -n 1 .gitignore)" = my-own-ignore ] || fail "user line is not kept after the .gitignore block"


devenv shell -- true >/dev/null 2>&1
[ "$(git config --local --get-all include.path)" = "$inc" ] || fail "include.path duplicated or changed on re-entry"

for f in .toolboxes/git_toolbox/practices/skills/git-commit/SKILL.md; do
  [ -f "$f" ] || fail "$f missing"
done
grep -q "^name: git-commit" .toolboxes/git_toolbox/practices/skills/git-commit/SKILL.md || fail "git-commit skill content wrong"

# The merge reads each toolbox's settings/.gitignore only.
mkdir -p .toolboxes/x_toolbox/settings
printf 'fromfrag\n' > .toolboxes/x_toolbox/settings/.gitignore
devenv shell -- true >/dev/null 2>&1
grep -qx 'fromfrag' .gitignore || fail "settings/.gitignore not merged"


# .gitattributes: the base line comes first; fragments merge in after it, in
# order and without sorting; blank and repeated lines are dropped.
mkdir -p .toolboxes/a_toolbox/settings .toolboxes/z_toolbox/settings .toolboxes/n_toolbox/.toolboxes/inner_toolbox/settings
printf '*.zz -diff\n\n* text=auto eol=lf\n' > .toolboxes/a_toolbox/settings/.gitattributes
printf '*.aa diff=aa' > .toolboxes/z_toolbox/settings/.gitattributes
printf '*.nested -diff\n' > .toolboxes/n_toolbox/.toolboxes/inner_toolbox/settings/.gitattributes
devenv shell -- true >/dev/null 2>&1
[ "$(sed -n 2p .gitattributes)" = '* text=auto eol=lf' ] || fail "base line is not first in the managed block"
[ "$(grep -cx '\* text=auto eol=lf' .gitattributes)" = 1 ] || fail "repeated fragment line not deduplicated"
[ "$(grep -nx '\*.zz -diff' .gitattributes | cut -d: -f1)" -lt "$(grep -nx '\*.aa diff=aa' .gitattributes | cut -d: -f1)" ] || fail "fragments not merged in path order"
grep -qx '\*.nested -diff' .gitattributes && fail "a nested project's fragment leaked into the merge"
grep -qx '\*.aa diff=aa' .gitattributes || fail "settings/.gitattributes without a trailing newline not merged"

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
rm .toolboxes/z_toolbox/settings/.gitattributes
devenv shell -- true >/dev/null 2>&1
grep -qx '\*.aa diff=aa' .gitattributes && fail "dropped fragment line stayed"
grep -qx '\*.png binary' .gitattributes || fail "user line lost when a fragment line dropped"

# The project's own .toolboxes/git_toolbox/project.gitattributes: seeded once
# with a comment header, merged last.
pf=.toolboxes/git_toolbox/project.gitattributes
[ -f "$pf" ] || fail "project.gitattributes not seeded"
grep -q 'Project-specific' "$pf" || fail "seeded project.gitattributes lacks its header"
grep -q 'Project-specific' .gitattributes || fail "seeded project header not merged"
printf '*.zz diff=mine\n* text=auto eol=lf\n*.last -diff\n' > "$pf"
cp "$pf" "$before"
devenv shell -- true >/dev/null 2>&1
devenv shell -- true >/dev/null 2>&1
cmp -s "$pf" "$before" || fail "project.gitattributes overwritten after a user edit"
[ "$(sed -n 2p .gitattributes)" = '* text=auto eol=lf' ] || fail "base line no longer first with a project file"
[ "$(grep -cx '\*.last -diff' .gitattributes)" = 1 ] || fail "project line duplicated or missing"
[ "$(grep -nx '\*.zz -diff' .gitattributes | cut -d: -f1)" -lt "$(grep -nx '\*.zz diff=mine' .gitattributes | cut -d: -f1)" ] || fail "project line does not come after the toolbox fragment it overrides"
[ "$(grep -B1 -x '# <<< toolbox-managed <<<' .gitattributes | head -n1)" = '*.last -diff' ] || fail "project file is not last in the managed block"
[ "$(grep -cx '\*.png binary' .gitattributes)" = 1 ] || fail "user line lost or duplicated"

# An existing project with the old hand-seeded file: the base line moves into
# the block, other lines are kept.
rm -f "$before"
printf '# mine\n' > "$pf"
printf '* text=auto eol=lf\n*.svg text\n' > .gitattributes
devenv shell -- true >/dev/null 2>&1
[ "$(grep -cx '\* text=auto eol=lf' .gitattributes)" = 1 ] || fail "seeded base line duplicated"
grep -qx '\*.svg text' .gitattributes || fail "hand-written line lost on migration"

# settings/.gitconfig: seeded once from the toolbox defaults, user-editable
# (mode 644), never refreshed, included once in .git/config, and not ignored
# (it is committed with the project, unlike the other settings/ copies).
[ "$(stat -c %a "$inc")" = 644 ] || fail "settings/.gitconfig is not mode 644"
grep -q 'seeds this file once' "$inc" || fail "seeded settings/.gitconfig lacks its header"
git check-ignore -q "$inc" && fail "settings/.gitconfig is gitignored"
git check-ignore -q "$sg" || fail "settings/.gitignore copy is not ignored"
[ "$(cfg pull.rebase)" = true ] || fail "seeded settings/.gitconfig changed pull.rebase"
git config -f "$inc" pull.rebase false
git config -f "$inc" user.marker mine
before=$(mktemp); cp "$inc" "$before"
devenv shell -- true >/dev/null 2>&1
devenv shell -- true >/dev/null 2>&1
cmp -s "$inc" "$before" || fail "settings/.gitconfig overwritten after a user edit"
[ "$(cfg pull.rebase)" = false ] || fail "an edit to settings/.gitconfig does not take effect"
[ "$(cfg pull.ff)" = only ] || fail "a seeded default was lost after an edit"
[ "$(cfg user.marker)" = mine ] || fail "added key not visible"
[ "$(git config --local --get-all include.path)" = "$inc" ] || fail "include.path changed on re-entry with an edited settings/.gitconfig"
git check-ignore -q "$inc" && fail "edited settings/.gitconfig is gitignored"

# Migration: the two files this one replaced are swapped out of include.path,
# at the place the first one sat, and are left on disk.
old1="$here/.toolboxes/git_toolbox/gitconfig"
old2="$here/.toolboxes/git_toolbox/project.gitconfig"
printf '[pull]\n\trebase = true\n' > "$old1"
printf '[user]\n\toldmarker = x\n' > "$old2"
git config --local --unset-all include.path
git config --local --add include.path "/nonexistent/first.gitconfig"
git config --local --add include.path "$old1"
git config --local --add include.path "$old2"
git config --local --add include.path "/nonexistent/last.gitconfig"
devenv shell -- true >/dev/null 2>&1
devenv shell -- true >/dev/null 2>&1
[ "$(git config --local --get-all include.path | tr "\n" " ")" = "/nonexistent/first.gitconfig $inc /nonexistent/last.gitconfig " ] || fail "old includes not swapped for settings/.gitconfig in place"
[ -f "$old1" ] && [ -f "$old2" ] || fail "an old gitconfig file was deleted"
[ -z "$(cfg user.oldmarker)" ] || fail "an old file is still included"
[ "$(cfg pull.rebase)" = false ] || fail "the replaced gitconfig still overrides settings/.gitconfig"
# With no old includes, a repo that had none gets the single include; a repeat
# collapses, and a list that is already right is left alone.
git config --local --unset-all include.path
devenv shell -- true >/dev/null 2>&1
[ "$(git config --local --get-all include.path)" = "$inc" ] || fail "settings/.gitconfig not included in a repo without includes"
git config --local --add include.path "$inc"
git config --local --add include.path "/nonexistent/after.gitconfig"
devenv shell -- true >/dev/null 2>&1
[ "$(git config --local --get-all include.path | tr "\n" " ")" = "$inc /nonexistent/after.gitconfig " ] || fail "a duplicate include was not collapsed"
rm -f "$before" "$old1" "$old2"

# Generated practices (skills, agents, rules) and the settings copies in every
# toolbox's folder are ignored by the base .gitignore (.toolboxes/*/practices/,
# .toolboxes/*/settings/*), except the project's settings/.gitconfig. A toolbox
# whose folder is all generated adds its own folder line to its
# settings/.gitignore; the visible folders (git, readme, glossary, bdd, voxtype)
# hold project-owned files that must stay tracked.
grep -qx '\.toolboxes/\*/practices/' .gitignore || fail "base .gitignore lacks .toolboxes/*/practices/"
grep -qx '\.toolboxes/\*/settings/\*' .gitignore || fail "base .gitignore lacks .toolboxes/*/settings/*"
grep -qx '!\.toolboxes/\*/settings/\.gitconfig' .gitignore || fail "base .gitignore does not re-include settings/.gitconfig"
mkdir -p .toolboxes/p_toolbox/practices/skills/s .toolboxes/p_toolbox/settings .toolboxes/q_toolbox/settings
printf 'x\n' > .toolboxes/p_toolbox/practices/skills/s/SKILL.md
printf 'x\n' > .toolboxes/p_toolbox/settings/other
printf 'x\n' > .toolboxes/p_toolbox/notes.org
printf 'x\n' > .toolboxes/p_toolbox/settings.json
printf '.toolboxes/q_toolbox/\n' > .toolboxes/q_toolbox/settings/.gitignore
printf 'x\n' > .toolboxes/q_toolbox/practices.org
devenv shell -- true >/dev/null 2>&1
git check-ignore -q .toolboxes/p_toolbox/practices/skills/s/SKILL.md || fail "a toolbox's practices mirror is not ignored"
git check-ignore -q .toolboxes/git_toolbox/practices/skills/git-commit/SKILL.md || fail "git_toolbox practices mirror is not ignored"
for f in .toolboxes/git_toolbox/settings/.gitconfig .toolboxes/git_toolbox/project.gitattributes \
  .toolboxes/p_toolbox/notes.org .toolboxes/p_toolbox/settings.json; do
  git check-ignore -q "$f" && fail "$f is ignored but is project-owned"
done
git check-ignore -q .toolboxes/p_toolbox/settings/other || fail "a toolbox's settings copies are not ignored"
# A toolbox that lists its own folder in settings/.gitignore is hidden whole.
git check-ignore -q .toolboxes/q_toolbox/practices.org || fail "the folder line in settings/.gitignore does not hide the folder"
# The rule is anchored to the project's own .toolboxes, not nested projects'.
git check-ignore -q .toolboxes/n_toolbox/.toolboxes/inner_toolbox/practices/x && fail "practices rule reaches into a nested project"
rm -rf .toolboxes/p_toolbox .toolboxes/q_toolbox

# Nothing is copied into .eca, and no eca manifest is kept.
[ -e .eca ] && fail ".eca was created"
find .toolboxes -name eca_manifest 2>/dev/null | grep -q . && fail "eca_manifest was written"

echo "PASS: git toolbox"
