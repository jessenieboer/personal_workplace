# Install a toolbox's practices into .eca and its readable mirror, and remove
# the .eca items an earlier install shipped but this one no longer does.
#
# Usage: practices_sync status|apply <built> <manifest> <eca> <mirror> <installed>
#   built      store dir shaped like practices/ (skills/<n>, agents/<f>, ...)
#   manifest   store file listing built's top-level items, one per line
#   eca        the project's .eca dir, shared by every toolbox
#   mirror     .toolboxes/<name>_toolbox/practices, replaced whole
#   installed  .toolboxes/<name>_toolbox/eca_manifest, the manifest last applied
#
# Only items named in `installed` are ever removed from .eca, so other
# toolboxes' items and the user's own survive.
mode=${1:-}
built=${2:-}
manifest=${3:-}
eca=${4:-}
mirror=${5:-}
installed=${6:-}

if [ -z "$installed" ]; then
  echo "usage: practices_sync status|apply <built> <manifest> <eca> <mirror> <installed>" >&2
  exit 2
fi

# A manifest line must be <dir>/<leaf>, with no empty, "." or ".." parts.
is_item() {
  local top=${1%%/*} leaf=${1#*/}
  case $1 in
  */*) ;;
  *) return 1 ;;
  esac
  case $top in '' | . | ..) return 1 ;; esac
  case $leaf in '' | . | .. | */*) return 1 ;; esac
}

status() {
  local item
  diff -r "$built" "$mirror" >/dev/null 2>&1 || return 1
  cmp -s "$manifest" "$installed" || return 1
  while IFS= read -r item; do
    diff -r "$built/$item" "$eca/$item" >/dev/null 2>&1 || return 1
  done <"$manifest"
}

# True when another toolbox's manifest still lists the item.
shipped_elsewhere() {
  local other
  for other in "$(dirname "$installed")"/../*_toolbox/eca_manifest; do
    [ -f "$other" ] || continue
    [ "$other" -ef "$installed" ] && continue
    grep -qxF -- "$1" "$other" && return 0
  done
  return 1
}

apply() {
  local item tmp
  if [ -f "$installed" ]; then
    while IFS= read -r item; do
      is_item "$item" || continue
      grep -qxF -- "$item" "$manifest" && continue
      shipped_elsewhere "$item" && continue
      rm -rf -- "${eca:?}/$item"
    done <"$installed"
  fi

  rm -rf -- "$mirror"
  mkdir -p "$(dirname "$mirror")" "$eca"
  cp -r --no-preserve=mode "$built" "$mirror"
  while IFS= read -r item; do
    rm -rf -- "${eca:?}/$item"
    mkdir -p "$(dirname "$eca/$item")"
    cp -r --no-preserve=mode "$built/$item" "$eca/$item"
  done <"$manifest"

  tmp=$(mktemp "$installed.XXXXXX")
  trap 'rm -f "$tmp"' EXIT
  cp "$manifest" "$tmp"
  chmod 0644 "$tmp"
  mv "$tmp" "$installed"
}

case $mode in
status) status ;;
apply) apply ;;
*)
  echo "practices_sync: unknown mode '$mode'" >&2
  exit 2
  ;;
esac
