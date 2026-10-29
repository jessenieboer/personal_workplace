# Make the repo's local git config include the project's gitconfig once, and
# stop including the files it replaced. The include goes where the first
# replaced include sat (or at the end when there is none); other include.path
# entries stay where they are. The replaced files are not touched.
# Idempotent.
# Usage: include_gitconfigs <project-root> <gitconfig> [<replaced-gitconfig>...]
# (all paths relative to the project root)
root=$1
new=$root/$2
shift 2

git -C "$root" rev-parse --git-dir >/dev/null 2>&1 || exit 0

replaced=()
for rel in "$@"; do
  replaced+=("$root/$rel")
done

is_replaced() {
  local r
  for r in "${replaced[@]}"; do
    [ "$r" = "$1" ] && return 0
  done
  return 1
}

mapfile -t existing < <(git -C "$root" config --local --get-all include.path || true)

wanted=()
placed=0
for p in "${existing[@]}"; do
  if [ "$p" = "$new" ] || is_replaced "$p"; then
    if [ "$placed" = 0 ]; then
      wanted+=("$new")
      placed=1
    fi
    continue
  fi
  wanted+=("$p")
done
[ "$placed" = 1 ] || wanted+=("$new")

if [ "${existing[*]}" = "${wanted[*]}" ] && [ "${#existing[@]}" = "${#wanted[@]}" ]; then
  exit 0
fi

git -C "$root" config --local --unset-all include.path || true
for p in "${wanted[@]}"; do
  git -C "$root" config --local --add include.path "$p"
done
