{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "secrets toolbox available"
      fi
    '';

    packages = with pkgs; [
      bws
      secretspec
    ];

    tasks = tt.gitignore "secrets" ./settings/.gitignore
      // tt.seed {
        name = "secrets"; task = "copy_secretspec_template";
        src = ./templates/secretspec.toml; dest = "secretspec.toml";
      }
      // {

    };
  };
}
