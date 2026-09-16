{ pkgs, lib, config, inputs, ... }:
let
  builder = ./settings/agents/builder.md;
  designer = ./settings/agents/designer.md;
  planner = ./settings/agents/planner.md;

  bddPaths = ./settings/rules/bdd-paths.md;

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
  ddone = "${inputs.addyosmani-agent-skills}/references/definition-of-done.md";

  root = config.devenv.root;
  eca = "${root}/.eca";
  bddDir = "${root}/.toolboxes/bdd_toolbox";

  managed = [
    { src = builder; dest = "${eca}/agents/builder.md"; }
    { src = designer; dest = "${eca}/agents/designer.md"; }
    { src = planner; dest = "${eca}/agents/planner.md"; }
    { src = bddPaths; dest = "${eca}/rules/bdd-paths.md"; }
    { src = ddone; dest = "${bddDir}/definition-of-done.md"; }
    { src = dmSkill; dest = "${eca}/skills/domain-modeling/SKILL.md"; }
    { src = dmADR; dest = "${eca}/skills/domain-modeling/ADR-FORMAT.md"; }
    { src = dmContext; dest = "${eca}/skills/domain-modeling/CONTEXT-FORMAT.md"; }
    { src = gherkin; dest = "${eca}/skills/gherkin-authoring/SKILL.md"; }
    { src = gherkinGuidelines; dest = "${eca}/skills/gherkin-authoring/references/gherkin-guidelines.md"; }
    { src = grSkill; dest = "${eca}/skills/grilling/SKILL.md"; }
    { src = grDocsSkill; dest = "${eca}/skills/grill-with-docs/SKILL.md"; }
    { src = inc; dest = "${eca}/skills/incremental-implementation/SKILL.md"; }
    { src = planningSkill; dest = "${eca}/skills/planning-and-task-breakdown/SKILL.md"; }
    { src = tdd; dest = "${eca}/skills/test-driven-development/SKILL.md"; }
  ];
in
{
  enterShell = ''
    if [ -t 1 ]; then
      echo "bdd toolbox available"
    fi
  '';

  tasks = {
    "bdd_toolbox:copy_setup_files" = {
      description = "Refresh BDD agents/skills/rules; seed features/ and brainstorm.txt once";
      before = [ "devenv:enterShell" ];
      status = ''
        same() { [ -f "$2" ] && cmp -s "$1" "$2"; }
        ${lib.concatMapStringsSep "\n" (m: ''
          same ${m.src} "${m.dest}" || exit 1
        '') managed}
        [ -d "${bddDir}/features" ] && [ -f "${bddDir}/brainstorm.txt" ]
      '';
      exec = ''
        mkdir -p "${eca}/agents" "${eca}/rules" "${eca}/skills"
        ${lib.concatMapStringsSep "\n" (m: ''
          install -D -m 0444 ${m.src} "${m.dest}"
        '') managed}
        mkdir -p "${bddDir}/features"
        if [ ! -f "${bddDir}/brainstorm.txt" ]; then
          : > "${bddDir}/brainstorm.txt"
        fi
      '';
    };
  };
}
