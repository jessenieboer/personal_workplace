{ pkgs, lib, config, inputs, ... }:
let
  toolboxSetup = ./programs/ai_toolbox_setup;
  dirLocals = ./programs/dir_locals;
  helloWorldAgent = ./settings/hello_world_agent.org;
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
          cat ${toolboxSetup} > ${config.devenv.root}/toolboxes/ai_toolbox/ai_toolbox_setup
          cat ${dirLocals} > ${config.devenv.root}/toolboxes/ai_toolbox/ai_toolbox_dir_locals
          cat ${helloWorldAgent} > ${config.devenv.root}/toolboxes/ai_toolbox/hello_world_agent.org

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
