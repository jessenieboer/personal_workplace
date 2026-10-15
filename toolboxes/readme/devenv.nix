{ config, ... }:
let
  readmeTemplate = ./templates/readme.org;
  readmeDest = "${config.devenv.root}/.toolboxes/readme_toolbox/readme.org";
  # Exporting glossary.org with ox-gfm (C-c C-e g g) writes GLOSSARY.md to the project root.
  glossaryTemplate = ./templates/glossary.org;
  glossaryDest = "${config.devenv.root}/.toolboxes/readme_toolbox/glossary.org";
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "readme toolbox available"
      fi
    '';

    tasks = {
      "readme_toolbox:copy_readme_template" = {
        description = "Seed .toolboxes/readme_toolbox/readme.org once from the toolbox template";
        before = [ "devenv:enterShell" ];
        status = ''
          test -f "${readmeDest}"
        '';
        exec = ''
          install -D -m 0644 ${readmeTemplate} "${readmeDest}"
        '';
      };

      "readme_toolbox:copy_glossary_template" = {
        description = "Seed .toolboxes/readme_toolbox/glossary.org once from the toolbox template";
        before = [ "devenv:enterShell" ];
        status = ''
          test -f "${glossaryDest}"
        '';
        exec = ''
          install -D -m 0644 ${glossaryTemplate} "${glossaryDest}"
          sed -i "s/00000000-0000-0000-0000-000000000000/$(cat /proc/sys/kernel/random/uuid)/" "${glossaryDest}"
        '';
      };
    };
  };
}
