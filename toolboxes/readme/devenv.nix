{ pkgs, lib, config, inputs, ... }:
let
  readmeTemplate = ./templates/readme.org;
in
{
  config = {
    enterShell = ''
      echo "jessenieboer's readme toolbox available"
    '';

    tasks = {
      "readme_toolbox:copy_readme_template" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ -f "${config.devenv.root}/docs/readme.org" ]; then
          echo "docs readme.org already exists — skipping copy."
          exit 0
          fi
          mkdir -p ${config.devenv.root}/docs
          cp ${readmeTemplate} ${config.devenv.root}/docs/readme.org
          chmod u+w ${config.devenv.root}/docs/readme.org

          echo "copied readme template to docs/readme.org"
        '';
        showOutput = true;
      };
    };
  };
}
