{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  gitIgnore = ./settings/.gitignore;
  root = config.devenv.root;
  dest = "${root}/.gitignore";
  gitconfig = ".toolboxes/git_toolbox/gitconfig";
in
{
  config = {
    tasks = tt.refresh {
        name = "git"; task = "copy_gitconfig";
        src = ./settings/gitconfig; dest = gitconfig;
      }
      // tt.seed {
        name = "git"; task = "seed_gitattributes";
        src = ./templates/.gitattributes; dest = ".gitattributes";
      }
      // tt.practices {
        name = "git";
        local = ./practices;
        extra = {
          "skills/git-commit" = "${inputs.awesome-copilot}/skills/git-commit";
        };
      };

    # Runs after other toolboxes' before-enterShell copy tasks so
    # .toolboxes/*/gitignore fragments exist before this merge.
    enterShell = lib.mkAfter ''
      tmp=$(mktemp)
      {
        cat ${gitIgnore}
        echo
        if [ -d "${root}/.toolboxes" ]; then
          find "${root}/.toolboxes" -mindepth 2 -maxdepth 2 -name .gitignore -type f -exec cat {} \; -exec echo \;
        fi
      } | grep -v '^$' | sort -u > "$tmp"
      if [ ! -f "${dest}" ] || ! cmp -s "$tmp" "${dest}"; then
        mv "$tmp" "${dest}"
      else
        rm -f "$tmp"
      fi

      # Pull the toolbox gitconfig into this repo's local config, once.
      inc="${root}/${gitconfig}"
      if [ -e "${root}/.git" ] \
         && git -C "${root}" rev-parse --git-dir >/dev/null 2>&1 \
         && ! git -C "${root}" config --local --get-all include.path 2>/dev/null | grep -qxF "$inc"; then
        git -C "${root}" config --local --add include.path "$inc"
      fi
      ${tt.announce "git"}
    '';
  };
}
