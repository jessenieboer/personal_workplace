{ pkgs, lib, config, inputs, ... }:
let
  gitIgnore = ./settings/.gitignore;
  root = config.devenv.root;
  dest = "${root}/.gitignore";
in
{
  config = {
    # Runs after other toolboxes' before-enterShell copy tasks so
    # .toolboxes/*/gitignore fragments exist before this merge.
    enterShell = lib.mkAfter ''
      tmp=$(mktemp)
      {
        cat ${gitIgnore}
        echo
        find "${root}" -path '*/.toolboxes/*' -name .gitignore -type f -exec cat {} \; -exec echo \;
      } 2>/dev/null | grep -v '^$' | sort -u > "$tmp"
      if [ ! -f "${dest}" ] || ! cmp -s "$tmp" "${dest}"; then
        mv "$tmp" "${dest}"
      else
        rm -f "$tmp"
      fi
      if [ -t 1 ]; then
        echo "git toolbox available"
      fi
    '';
  };
}
