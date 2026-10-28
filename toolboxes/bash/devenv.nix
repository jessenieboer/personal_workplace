{ config, pkgs, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  src = inputs.cc-devops-skills;
in
{
  config = {
    # The skill's validate.sh uses a system shellcheck before falling back
    # to a pip-installed one, so provide it here.
    packages = [ pkgs.shellcheck ];

    enterShell = ''
      ${tt.announce "bash"}
    '';

    # Apache-2.0: ship the upstream LICENSE inside the skill folder.
    tasks = tt.practices {
      name = "bash";
      local = ./practices;
      extra = {
        "skills/bash-script-validator" = "${src}/devops-skills-plugin/skills/bash-script-validator";
        "skills/bash-script-validator/LICENSE" = "${src}/LICENSE";
      };
    };
  };
}
