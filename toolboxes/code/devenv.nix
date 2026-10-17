{ config, inputs, pkgs, lib, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  # opencodeConfig = ./settings/opencode/opencode.json;

  root = config.devenv.root;
  # opencodeDest = "${root}/.opencode/opencode.json";

  practicesTasks = tt.practices {
    name = "code";
    local = ./practices;
    extra."skills/how" = "${inputs.atomic}/packages/workflows/skills/how";
  };
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "code toolbox available"
        echo "opencode: $(command -v opencode)"
      fi
    '';

    # packages = [
    #   inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
    # ];

    tasks = practicesTasks
      // tt.gitignore "code" ./settings/.gitignore
      // {

      # "code_toolbox:copy_opencode_config" = {
      #   description = "Seed .opencode/opencode.json once from the toolbox template";
      #   before = [ "devenv:enterShell" ];
      #   status = ''
      #     test -f "${opencodeDest}"
      #   '';
      #   exec = ''
      #     install -D -m 0644 ${opencodeConfig} "${opencodeDest}"
      #   '';
      # };
    };
  };
}
