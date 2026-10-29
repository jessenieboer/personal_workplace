# Merge the toolbox .gitignore template and every toolbox's project.gitignore
# into the project .gitignore.
# Usage: merge_gitignore <project-root> <template>
root=$1
template=$2
dest=$root/.gitignore

tmp=$(mktemp "$root/.gitignore.XXXXXX")
trap 'rm -f "$tmp"' EXIT

{
  cat "$template"
  echo
  # Only the toolboxes' own project.gitignore files
  # (.toolboxes/<name>/project.gitignore), not those of nested projects.
  if [ -d "$root/.toolboxes" ]; then
    find "$root/.toolboxes" -mindepth 2 -maxdepth 2 -name project.gitignore -type f \
      -exec cat {} \; -exec echo \;
  fi
} | { grep -v '^$' || true; } | sort -u >"$tmp"

if [ ! -f "$dest" ] || ! cmp -s "$tmp" "$dest"; then
  chmod 0644 "$tmp"
  mv "$tmp" "$dest"
fi
# Older runs left it 0600 (mktemp default); fix in place.
chmod 0644 "$dest"
