{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
in
{
  config = {
    enterShell = ''
      ${tt.announce "nixos"}
    '';

    tasks = tt.practices {
      name = "nixos";
      local = ./practices;
    }
    // tt.gitSettings "nixos" ./settings;
  };
}
