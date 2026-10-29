{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  root = config.devenv.root;
  # The project's own git settings: seeded once from templates/gitconfig, never
  # refreshed. The two files it replaced are no longer included.
  gitconfig = ".toolboxes/git_toolbox/settings/.gitconfig";
  replacedGitconfigs = [
    ".toolboxes/git_toolbox/gitconfig"
    ".toolboxes/git_toolbox/project.gitconfig"
  ];
  projectGitattributes = ".toolboxes/git_toolbox/project.gitattributes";
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
  # toolbox's file, plus the seeded project file.
  settingsTasks = lib.filter
    (n: lib.hasSuffix ":refresh_gitignore" n || lib.hasSuffix ":refresh_gitattributes" n)
    (lib.attrNames config.tasks);

  mergeTask = { file, project ? "" }: {
    description = "Merge every toolbox's settings/${file} into the project's ${file}";
    before = [ "devenv:enterShell" ];
    after = settingsTasks ++ lib.optional (project != "") "git_toolbox:seed_project_gitattributes";
    exec = ''
      ${lib.getExe mergeManaged} ${lib.escapeShellArgs ([ root file ] ++ lib.optional (project != "") project)}
    '';
  };
in
{
  config = {
    tasks = tt.gitSettings "git" ./settings
      // tt.seed {
        name = "git"; task = "seed_project_gitattributes";
        src = ./templates/project.gitattributes;
        dest = projectGitattributes;
        description = "Seed the project's own .gitattributes lines once";
      }
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
        "git_toolbox:merge_gitignore" = mergeTask { file = ".gitignore"; };
        "git_toolbox:merge_gitattributes" = mergeTask { file = ".gitattributes"; project = projectGitattributes; };
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
