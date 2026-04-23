{ pkgs, lib, config, inputs, ... }:
let
  dirLocalsTemplate = ./templates/dir-locals.el.in;
in
{
  config = {
    enterShell = ''
      echo "jessenieboer's project management toolbox available"
    '';

    files = {
      ".envrc".text = ''
        #!/usr/bin/env bash

        eval "$(devenv direnvrc)"
      '';
    };

    # project_management_toolbox = {
    #     project_name = "project_management_toolbox";
    #   };

      # todo use pkgs.replaceVars instead of sed?
      tasks = {
        "project_management_toolbox:generate_dir_locals" = {
          before = [ "devenv:enterShell" ];
          exec = let
            # annoying to produce a series of double-quoted strings
            subprojectAgendaFiles = lib.concatMapStringsSep " " (s: "\"${s}\"") config.project_management_toolbox.subproject_agenda_files;
          in ''
            sed -e 's|@PROJECT_NAME@|${config.project_management_toolbox.project_name}|g' \
            -e 's|@PROJECT_MANAGEMENT_DIRECTORY@|${config.devenv.root}|g' \
            -e 's|@SUBPROJECT_AGENDA_FILES@|${subprojectAgendaFiles}|g' \
            ${dirLocalsTemplate} > .dir-locals.el

            echo ".dir-locals.el generated successfully"
          '';
          # execIfModified = [
          #   "devenv.nix"
          # ];
          showOutput = true;
        };
      };
  };

  options = {
    project_management_toolbox = {
      project_name = lib.mkOption {
        description = "The name of this project";
        example = "My cool project";
        type = lib.types.str;
      };

      subproject_agenda_files = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of project management directories of subprojects";
        example = [ "/path/to/subproj1/subproj1.org" "/path/to/subproj2/subproj2.org"];
      };
    };
  };
}
