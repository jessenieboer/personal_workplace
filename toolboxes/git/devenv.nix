{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  gitIgnore = ./settings/.gitignore;
  gitAttributes = ./settings/.gitattributes;
  root = config.devenv.root;
  gitconfig = ".toolboxes/git_toolbox/gitconfig";
  mergeGitignore = pkgs.writeShellApplication {
    name = "merge_gitignore";
    runtimeInputs = with pkgs; [ coreutils diffutils findutils git gnugrep ];
    text = builtins.readFile ./programs/merge_gitignore.sh;
  };
  mergeGitattributes = pkgs.writeShellApplication {
    name = "merge_gitattributes";
    runtimeInputs = with pkgs; [ coreutils diffutils findutils gawk ];
    text = builtins.readFile ./programs/merge_gitattributes.sh;
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
      // tt.practices {
        name = "git";
        local = ./practices;
        extra = {
          "skills/git-commit" = "${inputs.awesome-copilot}/skills/git-commit";
        };
      };

    # Runs after other toolboxes' before-enterShell copy tasks so the
    # .toolboxes/*/project.gitignore and project.gitattributes fragments exist
    # before these merges. The git toolbox's own .gitattributes lines come
    # from settings/.gitattributes, so it needs no fragment of its own.
    enterShell = lib.mkAfter ''
      ${lib.getExe mergeGitignore} \
        ${lib.escapeShellArg root} \
        ${lib.escapeShellArg gitIgnore} \
        ${lib.escapeShellArg gitconfig}
      ${lib.getExe mergeGitattributes} \
        ${lib.escapeShellArg root} \
        ${lib.escapeShellArg gitAttributes}
      ${tt.announce "git"}
    '';
  };
}
