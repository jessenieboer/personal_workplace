{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  root = config.devenv.root;
  dirLocalsDest = "${root}/.dir-locals.el";
  mergeDirLocals = pkgs.writeShellApplication {
    name = "merge_dir_locals";
    runtimeInputs = with pkgs; [ coreutils diffutils findutils gnused ];
    text = builtins.readFile ./programs/merge_dir_locals.sh;
  };
in
{
  config = {
    # Runs after other toolboxes' before-enterShell copy tasks so *dir_locals
    # fragments exist before this merge.
    enterShell = lib.mkAfter ''
      ${lib.getExe mergeDirLocals} ${lib.escapeShellArg root} ${lib.escapeShellArg dirLocalsDest}
      ${tt.announce "emacs"}
    '';

    tasks = tt.seed {
        name = "emacs"; task = "copy_envrc";
        src = ./programs/.envrc; dest = ".envrc";
      }
      // tt.gitignore "emacs" ./settings/.gitignore
      // tt.practices { name = "emacs"; local = ./practices; };
  };
}
