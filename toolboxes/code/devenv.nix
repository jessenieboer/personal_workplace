{ config, inputs, pkgs, ... }:
let
  gitignore = ./settings/.gitignore;
  opencodeConfig = ./settings/opencode/opencode.json;
  root = config.devenv.root;
  gitignoreDest = "${root}/.toolboxes/code_toolbox/.gitignore";
  opencodeDest = "${root}/.opencode/opencode.json";
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "code toolbox available"
        echo "opencode: $(command -v opencode)"
      fi
    '';

    packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
    ];

    tasks = {
      "code_toolbox:copy_gitignore" = {
        description = "Refresh the code_toolbox gitignore fragment from the toolbox";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${gitignoreDest}" ] && cmp -s ${gitignore} "${gitignoreDest}"
        '';
        exec = ''
          install -D -m 0644 ${gitignore} "${gitignoreDest}"
        '';
      };

      "code_toolbox:copy_opencode_config" = {
        description = "Seed .opencode/opencode.json once from the toolbox template";
        before = [ "devenv:enterShell" ];
        status = ''
          test -f "${opencodeDest}"
        '';
        exec = ''
          install -D -m 0644 ${opencodeConfig} "${opencodeDest}"
        '';
      };
    };
  };
}
