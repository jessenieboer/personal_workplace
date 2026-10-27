{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
in
{
  config = {
    enterShell = ''
      ${tt.announce "readme"}
    '';

    tasks = tt.seed {
      name = "readme"; task = "copy_readme_template";
      src = ./templates/readme.org; dest = ".toolboxes/readme_toolbox/readme.org";
    };
  };
}
