{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  mp = "${inputs.mattpocock-skills}/skills";
  # The bdd-gherkin-specification skill lives at .claude/skills/bdd in the
  # repo; its reference/ folder comes along with SKILL.md.
  gherkin = "${inputs.jzallen-fred-simulations}/.claude/skills/bdd";

  featuresDir = "${config.devenv.root}/.toolboxes/bdd_spec_toolbox/features";

  practicesTasks = tt.practices {
    name = "bdd_spec";
    extra = {
      "rules/bdd-spec-paths.md" = ./settings/rules/bdd-spec-paths.md;
      # Whole folder: upstream renamed CONTEXT-FORMAT.md to GLOSSARY-FORMAT.md, and
      # with no version pin a copy file by file would break on such changes.
      "skills/domain-modeling" = "${mp}/engineering/domain-modeling";
      "skills/grilling/SKILL.md" = "${mp}/productivity/grilling/SKILL.md";
      "skills/grill-with-docs/SKILL.md" = "${mp}/engineering/grill-with-docs/SKILL.md";
      "skills/bdd-gherkin-specification" = gherkin;
    };
  };
in
{
  enterShell = ''
    ${tt.announce "bdd_spec"}
  '';

  # features/ is seeded once and then edited, so it stays visible to git.
  tasks = practicesTasks // {
    "bdd_spec_toolbox:seed_features" = {
      description = "Seed features/ once";
      before = [ "devenv:enterShell" ];
      status = ''[ -d "${featuresDir}" ]'';
      exec = ''mkdir -p "${featuresDir}"'';
    };
  };
}
