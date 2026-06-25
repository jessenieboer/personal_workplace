{ pkgs, lib, config, inputs, ... }:
let
  dirLocalsTemplate = ./templates/dir-locals.el.in;
in
{
  config = {
    enterShell = ''
      echo "jessenieboer's project management toolbox available"
    '';

    # project_management_toolbox = {
    #   project_name = "project_management_toolbox";
    #   workers = [
    #     {
    #       worker_name = "Jesse";
    #       worker_email = "jessenieboer@protonmail.com";
    #     }
    #     {
    #       worker_name = "Grok";
    #     }
    #   ];
    # };

    # todo use pkgs.replaceVars instead of sed?
    tasks = {
      "project_management_toolbox:generate_dir_locals" = {
        before = [ "devenv:enterShell" ];
        exec = let
          # annoying to produce a series of double-quoted strings
          subprojectAgendaFiles = lib.concatMapStringsSep " " (s: "\"${s}\"") config.project_management_toolbox.subproject_agenda_files;
        in ''
          mkdir -p ${config.devenv.root}/toolboxes/project_management_toolbox
          sed -e 's|@PROJECT_NAME@|${config.project_management_toolbox.project_name}|g' \
          -e 's|@PROJECT_MANAGEMENT_DIRECTORY@|${config.devenv.root}|g' \
          -e 's|@SUBPROJECT_AGENDA_FILES@|${subprojectAgendaFiles}|g' \
          ${dirLocalsTemplate} > ${config.devenv.root}/toolboxes/project_management_toolbox/project_management_toolbox_dir_locals

          echo "project_management_toolbox_dir_locals generated successfully"
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
      workers = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Name of worker";
              example = "Jane Doe";
            };

            email = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Email address of the worker (optional)";
              example = "jane.doe@example.com";
            };
          };
        });
        default = [ ];
        description = "List of workers for this project";
        example = [
          { name = "Alice Smith"; email = "alice@example.com"; }
          { name = "Bob Johnson"; }
        ];
      };
    };
  };
}
