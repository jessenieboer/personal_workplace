{ pkgs, lib, config, inputs, ... }:
let
  # agents
  builder = ./settings/agents/builder.md;
  designer = ./settings/agents/designer.md;
  planner = ./settings/agents/planner.md;

  # rules
  bddPaths = ./settings/rules/bdd-paths.md;

  # skills
  dmADR = "${inputs.mattpocock-skills}/skills/engineering/domain-modeling/ADR-FORMAT.md";
  dmContext = "${inputs.mattpocock-skills}/skills/engineering/domain-modeling/CONTEXT-FORMAT.md";
  dmSkill = "${inputs.mattpocock-skills}/skills/engineering/domain-modeling/SKILL.md";

  gherkin = ./settings/skills/gherkin-authoring/SKILL.md;
  gherkinGuidelines = "${inputs.gherkin-guidelines}/gherkin-guidelines.md";

  grSkill = "${inputs.mattpocock-skills}/skills/productivity/grilling/SKILL.md";
  grDocsSkill = "${inputs.mattpocock-skills}/skills/engineering/grill-with-docs/SKILL.md";

  inc = "${inputs.addyosmani-agent-skills}/skills/incremental-implementation/SKILL.md";

  planningSkill = "${inputs.addyosmani-agent-skills}/skills/planning-and-task-breakdown/SKILL.md";

  tdd = "${inputs.addyosmani-agent-skills}/skills/test-driven-development/SKILL.md";

  # references
  ddone = "${inputs.addyosmani-agent-skills}/references/definition-of-done.md";
in
{
  enterShell = ''
  if [ -t 1 ]; then
    echo bdd toolbox available
    fi
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
        install -D ${builder} "$ECA_DIR/agents/builder.md"
        install -D ${designer} "$ECA_DIR/agents/designer.md"
        install -D ${planner} "$ECA_DIR/agents/planner.md"

        # rules
        install -D ${bddPaths} "$ECA_DIR/rules/bdd-paths.md"

        # references
        install -D ${ddone} ${config.devenv.root}/.toolboxes/bdd_toolbox/definition-of-done.md

        # skills
        install -D ${dmSkill} "$ECA_DIR/skills/domain-modeling/SKILL.md"
        install -D ${dmADR} "$ECA_DIR/skills/domain-modeling/ADR-FORMAT.md"
        install -D ${dmContext} "$ECA_DIR/skills/domain-modeling/CONTEXT-FORMAT.md"

        install -D ${gherkin} "$ECA_DIR/skills/gherkin-authoring/SKILL.md"
        install -D ${gherkinGuidelines} "$ECA_DIR/skills/gherkin-authoring/references/gherkin-guidelines.md"

        install -D ${grSkill} "$ECA_DIR/skills/grilling/SKILL.md"
        install -D ${grDocsSkill} "$ECA_DIR/skills/grill-with-docs/SKILL.md"

        install -D ${inc} "$ECA_DIR/skills/incremental-implementation/SKILL.md"

        install -D ${planningSkill} "$ECA_DIR/skills/planning-and-task-breakdown/SKILL.md"

        install -D ${tdd} "$ECA_DIR/skills/test-driven-development/SKILL.md"

        # bdd stuff
        mkdir -p ${config.devenv.root}/.toolboxes/bdd_toolbox/features
        touch ${config.devenv.root}/.toolboxes/bdd_toolbox/brainstorm.txt

        echo "bdd_toolbox set up successfully"
      '';
      showOutput = true;
    };
  };
}
