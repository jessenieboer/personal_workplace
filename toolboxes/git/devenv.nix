{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  gitIgnore = ./settings/.gitignore;
  root = config.devenv.root;
  gitconfig = ".toolboxes/git_toolbox/gitconfig";
  mergeGitignore = pkgs.writeShellApplication {
    name = "merge_gitignore";
    runtimeInputs = with pkgs; [ coreutils diffutils findutils git gnugrep ];
    text = builtins.readFile ./programs/merge_gitignore.sh;
  };
in
{
  config = {
    # gitconfig is committed so clones pick up the include.path target.
    tasks = tt.gitignoreFor { name = "git"; ignoreSelf = false; }
      // tt.refresh {
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
      ${lib.getExe mergeGitignore} \
        ${lib.escapeShellArg root} \
        ${lib.escapeShellArg gitIgnore} \
        ${lib.escapeShellArg gitconfig}
      ${tt.announce "git"}
    '';
  };
}
