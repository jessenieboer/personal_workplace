{ pkgs, lib, config, inputs, ... }:
let
  bddPaths = ./settings/rules/bdd-paths.md;
  designReviewSkill = ./settings/skills/design-review/SKILL.md;
  designReviewTemplate = ./settings/skills/design-review/references/design-review-template.md;
  domainModelingSkill = ./settings/skills/domain-modeling/SKILL.md;
  gherkinAuthoringSkill = ./settings/skills/gherkin-authoring/SKILL.md;
  gherkinGuidelines = "${inputs.gherkin-guidelines}/gherkin-guidelines.md";
  grillingSkill = ./settings/skills/grilling/SKILL.md;
  implementationPlanningSkill = ./settings/skills/implementation-planning/SKILL.md;
  implementationVizier = ./settings/agents/implementation-vizier.md;
  planTemplate = ./settings/skills/implementation-planning/references/plan-template.md;
  productDesignAssistant = ./settings/agents/product-design-assistant.md;
  taskTemplate = ./settings/skills/implementation-planning/references/task-template.md;
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
        install -D ${implementationVizier} "$ECA_DIR/agents/implementation-vizier.md"
        install -D ${productDesignAssistant} "$ECA_DIR/agents/product-design-assistant.md"

        # rules
        install -D ${bddPaths} "$ECA_DIR/rules/bdd-paths.md"

        # skills
        install -D ${designReviewSkill} "$ECA_DIR/skills/design-review/SKILL.md"
        install -D ${designReviewTemplate} "$ECA_DIR/skills/design-review/references/design-review-template.md"

        install -D ${domainModelingSkill} "$ECA_DIR/skills/domain-modeling/SKILL.md"

        install -D ${gherkinAuthoringSkill} "$ECA_DIR/skills/gherkin-authoring/SKILL.md"
        install -D ${gherkinGuidelines} "$ECA_DIR/skills/gherkin-authoring/references/gherkin-guidelines.md"

        install -D ${grillingSkill} "$ECA_DIR/skills/grilling/SKILL.md"

        install -D ${implementationPlanningSkill} "$ECA_DIR/skills/implementation-planning/SKILL.md"
        install -D ${planTemplate} "$ECA_DIR/skills/implementation-planning/references/plan-template.md"
        install -D ${taskTemplate} "$ECA_DIR/skills/implementation-planning/references/task-template.md"

        # bdd stuff
        mkdir -p ${config.devenv.root}/.toolboxes/bdd_toolbox/features

        echo "bdd_toolbox set up successfully"
      '';
      showOutput = true;
    };
  };
}
