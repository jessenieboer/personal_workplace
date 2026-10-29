# Make the repo's local git config include the toolbox gitconfig and then the
# project's own project.gitconfig, in that order, so project values win.
# Idempotent. Other include.path entries stay where they are. A project include
# that sits before the toolbox include is moved to follow it. A project include
# that already follows the toolbox include is left in place.
# Usage: include_gitconfigs <project-root> <toolbox-gitconfig> <project-gitconfig>
# (both paths relative to the project root)
root=$1
toolbox_inc=$root/$2
project_inc=$root/$3

git -C "$root" rev-parse --git-dir >/dev/null 2>&1 || exit 0

mapfile -t existing < <(git -C "$root" config --local --get-all include.path || true)

wanted=()
seen_toolbox=0
seen_project=0
for p in "${existing[@]}"; do
  if [ "$p" = "$toolbox_inc" ]; then
    [ "$seen_toolbox" = 1 ] && continue
    seen_toolbox=1
  elif [ "$p" = "$project_inc" ]; then
    # Before the toolbox include (or a repeat): drop it, re-added last below.
    if [ "$seen_toolbox" = 0 ] || [ "$seen_project" = 1 ]; then
      continue
    fi
    seen_project=1
  fi
  wanted+=("$p")
done
[ "$seen_toolbox" = 1 ] || wanted+=("$toolbox_inc")
[ "$seen_project" = 1 ] || wanted+=("$project_inc")

if [ "${existing[*]}" = "${wanted[*]}" ] && [ "${#existing[@]}" = "${#wanted[@]}" ]; then
  exit 0
fi

git -C "$root" config --local --unset-all include.path || true
for p in "${wanted[@]}"; do
  git -C "$root" config --local --add include.path "$p"
done
