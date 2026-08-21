{ pkgs, lib, config, inputs, ... }:
let
  ecaConfig = ./settings/config.json;
  opencodeConfig = ./settings/opencode.json;
in
{
  enterShell = ''
    export XAI_API_KEY=$(secretspec get XAI_API_KEY)
    echo agentic coding toolbox available using grok build
  '';

  packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
  ];

  tasks = {
    "agentic_coding_toolbox:copy_setup_files" = {
      before = [ "devenv:enterShell" ];
      exec = ''
        mkdir -p ${config.devenv.root}/.opencode
        mkdir -p ${config.devenv.root}/.eca
        mkdir -p ${config.devenv.root}/.eca/skills

        if [ -f "${config.devenv.root}/opencode.json" ]; then
          echo "opencode.json already exists — skipping copy."
        else
          cat ${opencodeConfig} > ${config.devenv.root}/.opencode/opencode.json
        fi

        if [ -f "${config.devenv.root}/.eca/config.json" ]; then
          echo ".eca/config.json already exists — skipping copy."
        else
          cat ${ecaConfig} > ${config.devenv.root}/.eca/config.json
        fi

        echo "agentic_coding_toolbox set up successfully"
      '';
      showOutput = true;
    };
  };
}
