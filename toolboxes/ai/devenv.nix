{ pkgs, lib, config, inputs, ... }:
let
  dirLocals = ./programs/ai_dir_locals;
  gitignore = ./settings/.gitignore;
  helloWorldAgent = ./settings/ai_hello_world_agent.org;
  # mcpFsScript = pkgs.writeShellScriptBin "mcp-filesystem" ''
  #   exec npx @modelcontextprotocol/server-filesystem "${config.devenv.root}"
  # '';
  setupTesterAgent = ./settings/ai_setup_tester_agent.org;
  toolboxSetup = ./programs/ai_toolbox_setup;
  vizier = ./settings/ai_vizier.org;
in
{
  imports = [ inputs.mcp-servers-nix.devenvModules.default ];

  config = {
    enterShell = ''
      cat << EOF
      jessenieboer's ai toolbox available:
      EOF
    '';

    mcp-servers.programs = {
      filesystem = {
        enable = true;
        args = [ "." ];
      };
    };

    packages = [
      inputs.mcp-servers-nix.packages.${pkgs.stdenv.hostPlatform.system}.mcp-server-filesystem
    ];

    tasks = {
      "ai_toolbox:copy_agents" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          mkdir -p ${config.devenv.root}/.toolboxes/agents
          cat ${helloWorldAgent} > ${config.devenv.root}/.toolboxes/agents/ai_hello_world_agent.org
          cat ${setupTesterAgent} > ${config.devenv.root}/.toolboxes/agents/ai_setup_tester_agent.org
          cat ${vizier} > ${config.devenv.root}/.toolboxes/agents/ai_vizier.org

          echo "ai_toolbox agents copied successfully"
        '';
        showOutput = true;
      };
      "ai_toolbox:copy_gitignore" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          mkdir -p ${config.devenv.root}/.toolboxes/ai_toolbox
          cat ${gitignore} > ${config.devenv.root}/.toolboxes/ai_toolbox/.gitignore
          echo "copied ai_toolbox .gitignore"
        '';
        showOutput = true;
      };
      "ai_toolbox:copy_setup_files" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          mkdir -p ${config.devenv.root}/.toolboxes/ai_toolbox

          cat ${toolboxSetup} > ${config.devenv.root}/.toolboxes/ai_toolbox/ai_toolbox_setup
          cat ${dirLocals} > ${config.devenv.root}/.toolboxes/ai_toolbox/ai_dir_locals

          echo "ai_toolbox setup files copied successfully"
        '';
        # execIfModified = [
          #   "devenv.nix"
          # ];
          showOutput = true;
      };
    };
  };
}
