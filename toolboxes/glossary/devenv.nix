{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
in
{
  config = {
    enterShell = ''
      ${tt.announce "glossary"}
    '';

    # Exporting glossary.org with ox-gfm writes GLOSSARY.md to the project root.
    tasks = tt.seed {
      name = "glossary"; task = "copy_glossary_template";
      src = ./templates/glossary.org; dest = ".toolboxes/glossary_toolbox/glossary.org";
      postExec = ''sed -i "s/00000000-0000-0000-0000-000000000000/$(cat /proc/sys/kernel/random/uuid)/" "$dest"'';
    };
  };
}
