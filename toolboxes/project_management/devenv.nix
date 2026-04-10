{ pkgs, lib, config, inputs, ... }:

{
  # files = {
    # ".envrc".text = ''
    #   #!/usr/bin/env bash

    #   eval "$(devenv direnvrc)"
    # '';
    # };

    config = {
      enterShell = ''
        echo "jessenieboer's project management toolbox available"
      '';

      project_management = {
        project_name = "my-super-app";
      };

      # todo use pkgs.replaceVars instead of sed?
      tasks = {
        "project_management_toolbox:setup" = {
          before = [ "devenv:enterShell" ];
          exec = ''
            echo "Generating .dir-locals.el (project_name: ${config.project_management.project_name})"

            sed "s|@PROJECT_NAME@|${config.project_management.project_name}|g" \
            templates/dir-locals.el.in > .dir-locals.el

            echo ".dir-locals.el generated successfully"
          '';
          showOutput = true;
        };
      };
    };

    options = {
      project_management = {
        project_name = lib.mkOption {
          description = "The name of this project";
          example = "My cool project";
          type = lib.types.str;
        };
      };
    };
}
