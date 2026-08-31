{ pkgs, lib, config, inputs, ... }:
let
  featureAssistant = ./settings/agents/feature-assistant.md;
  gherkinAuthoringSkill = ./settings/skills/gherkin-authoring/SKILL.md;
  gherkinGuidelines = "${inputs.gherkin-guidelines}/gherkin-guidelines.md";
in
{
  enterShell = ''
    echo bdd toolbox available
  '';

  tasks = {
    "bdd_toolbox:copy_setup_files" = {
      before = [ "devenv:enterShell" ];
      exec = ''
        ECA_DIR="${config.devenv.root}/.eca"
        mkdir -p "$ECA_DIR"
        mkdir -p "$ECA_DIR/agents"
        mkdir -p "$ECA_DIR/rules"
        mkdir -p "$ECA_DIR/skills"

        # agents
        cp -f ${featureAssistant} "$ECA_DIR/agents/feature-assistant.md"

        # skills
        GA_DIR="$ECA_DIR/skills/gherkin-authoring"
        mkdir -p "$GA_DIR/references"
        cp -f ${gherkinAuthoringSkill} "$GA_DIR/SKILL.md"
        cp -f ${gherkinGuidelines} "$GA_DIR/references/gherkin-guidelines.md"

        # bdd stuff
        mkdir -p ${config.devenv.root}/features

        echo "bdd_toolbox set up successfully"
      '';
      showOutput = true;
    };
  };
}
