{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
in
{
  config = {
    enterShell = ''
      ${tt.announce "secrets"}
    '';

    packages = with pkgs; [
      bws
      secretspec
    ];

    tasks = tt.gitSettings "secrets" ./settings
      // tt.seed {
        name = "secrets"; task = "copy_secretspec_template";
        src = ./templates/secretspec.toml; dest = "secretspec.toml";
      }
      // {

    };
  };
}
