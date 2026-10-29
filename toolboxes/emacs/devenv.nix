{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  root = config.devenv.root;
  dirLocalsDest = "${root}/.dir-locals.el";
  mergeCaptureTemplates = pkgs.writers.writePerlBin "merge_capture_templates" { }
    (builtins.readFile ./programs/merge_capture_templates.pl);
  mergeDirLocals = pkgs.writeShellApplication {
    name = "merge_dir_locals";
    runtimeInputs = [ mergeCaptureTemplates ] ++ (with pkgs; [ coreutils diffutils findutils ]);
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
      // tt.refresh {
        name = "emacs"; task = "generate_dir_locals";
        description = "Render emacs_toolbox_dir_locals (journal capture) from the template";
        dest = ".toolboxes/emacs_toolbox/emacs_toolbox_dir_locals";
        # replaceVars fails the build if any @PLACEHOLDER@ is left unfilled.
        src = pkgs.replaceVars ./templates/dir-locals.el.in {
          ORG_DIRECTORY = root;
        };
      }
      // tt.gitSettings "emacs" ./settings
      // tt.practices { name = "emacs"; local = ./practices; };
  };
}
