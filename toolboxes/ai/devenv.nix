{ pkgs, lib, config, inputs, ... }:
let
  aiToolboxSetup = ./programs/ai_toolbox_setup.el;
  dirLocals = ./programs/ai_toolbox_dir_locals.el;
in
{
  config = {
    enterShell = ''
      echo "jessenieboer's ai toolbox available"
    '';

    tasks = {
      "ai_toolbox:copy_setup_files" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          mkdir -p ${config.devenv.root}/toolboxes/ai_toolbox
          cat ${aiToolboxSetup} > toolboxes/ai_toolbox/ai_toolbox_setup.el
          cat ${dirLocals} > toolboxes/ai_toolbox/ai_toolbox_dir_locals.el

          echo "ai toolbox setup files copied successfully"
        '';
        # execIfModified = [
          #   "devenv.nix"
          # ];
          showOutput = true;
      };
    };
  };
}
