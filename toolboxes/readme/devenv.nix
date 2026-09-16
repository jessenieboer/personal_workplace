{ config, ... }:
let
  readmeTemplate = ./templates/readme.org;
  readmeDest = "${config.devenv.root}/.toolboxes/readme_toolbox/readme.org";
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
    };
  };
}
