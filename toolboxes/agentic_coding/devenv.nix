{ pkgs, lib, config, inputs, ... }:
let
  opencodeConfig = ./settings/opencode.json;
in
{
  enterShell = ''
    export XAI_API_KEY=$(secretspec get XAI_API_KEY)
    echo jessenieboer's agentic coding toolbox available
  '';

  packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
  ];

  tasks = {
    "agentic_coding_toolbox:copy_setup_files" = {
      before = [ "devenv:enterShell" ];
      exec = ''
        mkdir -p ${config.devenv.root}/.opencode
        cat ${opencodeConfig} > ${config.devenv.root}/opencode.json

        echo "agentic_coding_toolbox set up successfully"
      '';
      showOutput = true;
    };
  };
}
