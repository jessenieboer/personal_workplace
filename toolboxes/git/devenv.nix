{ pkgs, lib, config, inputs, ... }:
let
  gitIgnore = ./settings/.gitignore;
in
{
  config = {
    enterShell = lib.mkAfter ''
      tmp=$(mktemp)
      {
      cat ${gitIgnore}
      echo
      find . -name .gitignore -type f -exec cat {} \; -exec echo \;
      } 2>/dev/null | grep -v '^$' | sort -u > "$tmp" && mv "$tmp" .gitignore
      echo "Merged template + all nested .gitignore files into ./.gitignore"
      echo "jessenieboer's git toolbox available"
    '';
  };
}
