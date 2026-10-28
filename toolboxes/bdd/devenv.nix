{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  mp = "${inputs.mattpocock-skills}/skills";
  aos = inputs.addyosmani-agent-skills;
  ddone = "${aos}/references/definition-of-done.md";

  root = config.devenv.root;
  bddDir = "${root}/.toolboxes/bdd_toolbox";
  ddoneDest = "${bddDir}/definition-of-done.md";

  # Local agents and skills, the bdd-paths rule, and upstream skills.
  # Upstream skills are copied file by file to keep their current names.
  practicesTasks = tt.practices {
    name = "bdd";
    local = ./practices;
    extra = {
      "rules/bdd-paths.md" = ./settings/rules/bdd-paths.md;
      "skills/domain-modeling/SKILL.md" = "${mp}/engineering/domain-modeling/SKILL.md";
      "skills/domain-modeling/ADR-FORMAT.md" = "${mp}/engineering/domain-modeling/ADR-FORMAT.md";
      "skills/domain-modeling/CONTEXT-FORMAT.md" = "${mp}/engineering/domain-modeling/CONTEXT-FORMAT.md";
      "skills/grilling/SKILL.md" = "${mp}/productivity/grilling/SKILL.md";
      "skills/grill-with-docs/SKILL.md" = "${mp}/engineering/grill-with-docs/SKILL.md";
      "skills/incremental-implementation/SKILL.md" = "${aos}/skills/incremental-implementation/SKILL.md";
      "skills/planning-and-task-breakdown/SKILL.md" = "${aos}/skills/planning-and-task-breakdown/SKILL.md";
      "skills/test-driven-development/SKILL.md" = "${aos}/skills/test-driven-development/SKILL.md";
      # addyosmani context-engineering, renamed to context-management below.
      "skills/context-management/SKILL.md" = "${aos}/skills/context-engineering/SKILL.md";
      "skills/context-management/LICENSE" = "${aos}/LICENSE";
    };
    postBuild = ''
      sed -i 's/^name: context-engineering$/name: context-management/' \
        skills/context-management/SKILL.md
    '';
  };
in
{
  enterShell = ''
    ${tt.announce "bdd"}
  '';

  # brainstorm.txt and features/ are seeded once and then edited, so the
  # folder stays visible to git.
  tasks = practicesTasks
    // tt.gitignoreFor { name = "bdd"; ignoreSelf = false; }
    // {
    "bdd_toolbox:copy_setup_files" = {
      description = "Refresh definition-of-done.md; seed features/ and brainstorm.txt once";
      before = [ "devenv:enterShell" ];
      status = ''
        [ -f "${ddoneDest}" ] && cmp -s ${ddone} "${ddoneDest}" || exit 1
        [ -d "${bddDir}/features" ] && [ -f "${bddDir}/brainstorm.txt" ]
      '';
      exec = ''
        install -D -m 0644 ${ddone} "${ddoneDest}"
        mkdir -p "${bddDir}/features"
        if [ ! -f "${bddDir}/brainstorm.txt" ]; then
          : > "${bddDir}/brainstorm.txt"
        fi
      '';
    };
  };
}
