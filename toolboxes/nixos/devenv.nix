{ config, pkgs, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  skill = inputs.nixos-ai-skill;
in
{
  config = {
    enterShell = ''
      ${tt.announce "nixos"}
    '';

    # Only SKILL.md and references/; the repo's install and update scripts stay out.
    tasks = tt.practices {
      name = "nixos";
      local = ./practices;
      extra = {
        "skills/nixos/SKILL.md" = "${skill}/SKILL.md";
        "skills/nixos/references" = "${skill}/references";
      };
    }
    // tt.gitignoreFor { name = "nixos"; };
  };
}
