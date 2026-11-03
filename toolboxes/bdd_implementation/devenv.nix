{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  aos = inputs.addyosmani-agent-skills;

  # Upstream skills are copied file by file to keep their current names.
  practicesTasks = tt.practices {
    name = "bdd_implementation";
    extra = {
      "rules/bdd-implementation-paths.md" = ./settings/rules/bdd-implementation-paths.md;
      "skills/incremental-implementation/SKILL.md" = "${aos}/skills/incremental-implementation/SKILL.md";
      "skills/planning-and-task-breakdown/SKILL.md" = "${aos}/skills/planning-and-task-breakdown/SKILL.md";
      "skills/test-driven-development/SKILL.md" = "${aos}/skills/test-driven-development/SKILL.md";
      "skills/context-engineering/SKILL.md" = "${aos}/skills/context-engineering/SKILL.md";
      "skills/context-engineering/LICENSE" = "${aos}/LICENSE";
    };
  };
in
{
  enterShell = ''
    ${tt.announce "bdd_implementation"}
  '';

  tasks = practicesTasks
    // tt.gitSettings "bdd_implementation" ./settings
    // tt.refresh {
      name = "bdd_implementation";
      task = "refresh_definition_of_done";
      src = "${aos}/references/definition-of-done.md";
      dest = ".toolboxes/bdd_implementation_toolbox/definition-of-done.md";
      description = "Refresh definition-of-done.md from addyosmani/agent-skills";
    };
}
