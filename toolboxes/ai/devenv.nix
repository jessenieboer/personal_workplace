{ pkgs, lib, config, inputs, ... }:
let
  aiToolboxSetup = ./configs/ai_toolbox_setup.el;
  dirLocals = ./configs/dir-locals.el;
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
          cat ${aiToolboxSetup} > ai_toolbox_setup.el
          cat ${dirLocals} > .dir-locals.el

          echo "ai setup files copied successfully"
        '';
        # execIfModified = [
          #   "devenv.nix"
          # ];
          showOutput = true;
      };
    };
  };
}
