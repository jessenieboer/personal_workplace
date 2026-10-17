{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "readme toolbox available"
      fi
    '';

    tasks = tt.seed {
        name = "readme"; task = "copy_readme_template";
        src = ./templates/readme.org; dest = ".toolboxes/readme_toolbox/readme.org";
      }
      # Exporting glossary.org with ox-gfm writes GLOSSARY.md to the project root.
      // tt.seed {
        name = "readme"; task = "copy_glossary_template";
        src = ./templates/glossary.org; dest = ".toolboxes/readme_toolbox/glossary.org";
        postExec = ''sed -i "s/00000000-0000-0000-0000-000000000000/$(cat /proc/sys/kernel/random/uuid)/" "$dest"'';
      };
  };
}
