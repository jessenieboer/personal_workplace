{ pkgs, lib, config, inputs, ... }:
let
  gherkinAuthorSkill = ./settings/gherkin-author/SKILL.md;
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
        SKILL_DIR="${config.devenv.root}/.agents/skills/gherkin-author"
        REF_DIR="$SKILL_DIR/references"

        mkdir -p "$REF_DIR"
        cp -f ${gherkinAuthorSkill} "$SKILL_DIR/SKILL.md"
        cp -f ${gherkinGuidelines} "$REF_DIR/gherkin-guidelines.md"

        mkdir -p ${config.devenv.root}/features

        echo "bdd_toolbox set up successfully"
      '';
      showOutput = true;
    };
  };
}
