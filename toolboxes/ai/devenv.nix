{ pkgs, lib, config, inputs, ... }:
let
  dirLocals = ./programs/ai_dir_locals;
  helloWorldAgent = ./settings/ai_hello_world_agent.org;
  mcpFsScript = pkgs.writeShellScriptBin "mcp-filesystem" ''
    exec npx @modelcontextprotocol/server-filesystem "${config.devenv.root}"
  '';
  setupTesterAgent = ./settings/ai_setup_tester_agent.org;
  toolboxSetup = ./programs/ai_toolbox_setup;
  vizier = ./settings/ai_vizier.org;
in
{
  config = {
    enterShell = ''
      cat << EOF
      jessenieboer's ai toolbox available                     
      EOF
    '';

    packages = [
      mcpFsScript
      pkgs.nodejs
    ];

    tasks = {
      "ai_toolbox:copy_setup_files" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          mkdir -p ${config.devenv.root}/toolboxes/ai_toolbox
          chmod 644 ${config.devenv.root}/toolboxes/ai_toolbox/* 2>/dev/null || true
          cat ${toolboxSetup} > ${config.devenv.root}/toolboxes/ai_toolbox/ai_toolbox_setup
          cat ${dirLocals} > ${config.devenv.root}/toolboxes/ai_toolbox/ai_dir_locals
          cat ${helloWorldAgent} > ${config.devenv.root}/toolboxes/ai_toolbox/ai_hello_world_agent.org
          cat ${setupTesterAgent} > ${config.devenv.root}/toolboxes/ai_toolbox/ai_setup_tester_agent.org
          cat ${vizier} > ${config.devenv.root}/toolboxes/ai_toolbox/ai_vizier.org
          chmod 444 ${config.devenv.root}/toolboxes/ai_toolbox/*
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
