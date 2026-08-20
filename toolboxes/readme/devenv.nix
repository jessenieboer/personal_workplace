
{ pkgs, lib, config, inputs, ... }:
let
  readmeTemplate = ./templates/readme.org;
  
in
{
  config = {
    enterShell = ''
      echo "readme toolbox available"
    '';

    tasks = {
      "readme_toolbox:copy_readme_template" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ -f "${config.devenv.root}/.toolboxes/readme_toolbox/readme.org" ]; then
          echo "readme.org already exists — skipping copy."
          exit 0
          fi
          mkdir -p ${config.devenv.root}/.toolboxes/readme_toolbox
          cp ${readmeTemplate} ${config.devenv.root}/.toolboxes/readme_toolbox/readme.org
          chmod u+w ${config.devenv.root}/.toolboxes/readme_toolbox/readme.org

          echo "copied readme template to .toolboxes/readme_toolbox/readme.org"
        '';
        showOutput = true;
      };
    };
  };
}
