# Merge the toolbox .gitignore template and every toolbox's fragment into the
# project .gitignore, then pull the toolbox gitconfig into the repo's config.
# Usage: merge_gitignore <project-root> <template> <gitconfig-relative-path>
root=$1
template=$2
gitconfig=$3
dest=$root/.gitignore

tmp=$(mktemp "$root/.gitignore.XXXXXX")
trap 'rm -f "$tmp"' EXIT

{
  cat "$template"
  echo
  # Only the toolboxes' own fragments (.toolboxes/<name>/.gitignore), not
  # those of nested projects.
  if [ -d "$root/.toolboxes" ]; then
    find "$root/.toolboxes" -mindepth 2 -maxdepth 2 -name .gitignore -type f \
      -exec cat {} \; -exec echo \;
  fi
} | { grep -v '^$' || true; } | sort -u >"$tmp"

if [ ! -f "$dest" ] || ! cmp -s "$tmp" "$dest"; then
  mv "$tmp" "$dest"
fi

# Pull the toolbox gitconfig into this repo's local config, once.
inc=$root/$gitconfig
if [ -e "$root/.git" ] && git -C "$root" rev-parse --git-dir >/dev/null 2>&1; then
  existing=$(git -C "$root" config --local --get-all include.path || true)
  if ! grep -qxF "$inc" <<<"$existing"; then
    git -C "$root" config --local --add include.path "$inc"
  fi
fi
