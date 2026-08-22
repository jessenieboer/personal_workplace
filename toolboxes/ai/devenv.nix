{ pkgs, lib, config, inputs, ... }:
let
  agentTemplate = ./templates/agent_template.md;
  ecaConfig = ./settings/eca/config.json;
  opencodeConfig = ./settings/opencode/opencode.json;
  ruleTemplate = ./templates/rule_template.md;
  skillTemplate = ./templates/skill_template.md;
in
{
  enterShell = ''
    echo ai toolbox available
  '';

  packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
  ];

  tasks = {
    "ai_toolbox:copy_setup_files" = {
      before = [ "devenv:enterShell" ];
      exec = ''
        TOOLBOX_DIR="${config.devenv.root}/.toolboxes/ai_toolbox"
        mkdir -p "$TOOLBOX_DIR/templates"
        cp -f ${agentTemplate} "$TOOLBOX_DIR/templates/agent_template.md"
        cp -f ${ruleTemplate} "$TOOLBOX_DIR/templates/rule_template.md"
        cp -f ${skillTemplate} "$TOOLBOX_DIR/templates/skill_template.md"

        ECA_DIR="${config.devenv.root}/.eca"

        mkdir -p "$ECA_DIR"
        mkdir -p "$ECA_DIR/agents"
        mkdir -p "$ECA_DIR/rules"
        mkdir -p "$ECA_DIR/skills"

        if [ -f "$ECA_DIR/config.json" ]; then
        echo "$ECA_DIR/config.json already exists — skipping copy."
        else
        cp -f ${ecaConfig} "$ECA_DIR/config.json"
        fi

        OPENCODE_DIR="${config.devenv.root}/.opencode"
        mkdir -p "$OPENCODE_DIR"

        if [ -f "$OPENCODE_DIR/opencode.json" ]; then
        echo "$OPENCODE_DIR/opencode.json already exists — skipping copy."
        else
        cp -f ${opencodeConfig} "$OPENCODE_DIR/opencode.json"
        fi

        echo "agentic_coding_toolbox set up successfully"
      '';
      showOutput = true;
    };
  };
}
