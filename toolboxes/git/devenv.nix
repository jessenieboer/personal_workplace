{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  root = config.devenv.root;
  # The project's own git settings: seeded once from templates/gitconfig, never
  # refreshed. The refreshed gitconfig it replaced is no longer included.
  gitconfig = ".toolboxes/git_toolbox/settings/.gitconfig";
  replacedGitconfigs = [
    ".toolboxes/git_toolbox/gitconfig"
  ];
  mergeManaged = pkgs.writeShellApplication {
    name = "merge_managed";
    runtimeInputs = with pkgs; [ coreutils diffutils findutils gawk ];
    text = builtins.readFile ./programs/merge_managed.sh;
  };
  includeGitconfigs = pkgs.writeShellApplication {
    name = "include_gitconfigs";
    runtimeInputs = with pkgs; [ git ];
    text = builtins.readFile ./programs/include_gitconfigs.sh;
  };

  # Every toolbox's refresh of its settings/.gitignore and settings/.gitattributes
  # (see tt.gitSettings). The merges run after all of them, so they see every
  # toolbox's file.
  settingsTasks = lib.filter
    (n: lib.hasSuffix ":refresh_gitignore" n || lib.hasSuffix ":refresh_gitattributes" n)
    (lib.attrNames config.tasks);

  mergeTask = file: {
    description = "Merge every toolbox's settings/${file} into the project's ${file}";
    before = [ "devenv:enterShell" ];
    after = settingsTasks;
    exec = ''
      ${lib.getExe mergeManaged} ${lib.escapeShellArgs [ root file ]}
    '';
  };
in
{
  config = {
    tasks = tt.gitSettings "git" ./settings
      // tt.seed {
        name = "git"; task = "seed_gitconfig";
        src = ./templates/gitconfig;
        dest = gitconfig;
        description = "Seed the project's own gitconfig once from the toolbox defaults";
      }
      // tt.practices {
        name = "git";
        extra = {
          "skills/git-commit" = "${inputs.awesome-copilot}/skills/git-commit";
        };
      }
      // {
        "git_toolbox:merge_gitignore" = mergeTask ".gitignore";
        "git_toolbox:merge_gitattributes" = mergeTask ".gitattributes";
        "git_toolbox:include_gitconfigs" = {
          description = "Include the project gitconfig in .git/config";
          before = [ "devenv:enterShell" ];
          exec = ''
            ${lib.getExe includeGitconfigs} ${lib.escapeShellArgs ([ root gitconfig ] ++ replacedGitconfigs)}
          '';
        };
      };

    enterShell = tt.announce "git";
  };
}
