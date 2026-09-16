{ pkgs, lib, config, inputs, ... }:
let
  dirLocalsTemplate = ./templates/dir-locals.el.in;
  dest = "${config.devenv.root}/.toolboxes/project_management_toolbox/project_management_toolbox_dir_locals";
  subprojectAgendaFiles = lib.concatMapStringsSep " " (s: "\"${s}\"") config.project_management_toolbox.subproject_agenda_files;
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "jessenieboer's project management toolbox available"
      fi
    '';

    tasks = {
      "project_management_toolbox:generate_dir_locals" = {
        description = "Render project_management_toolbox_dir_locals from devenv options";
        before = [ "devenv:enterShell" ];
        status = ''
          tmp=$(mktemp)
          sed -e 's|@PROJECT_NAME@|${config.project_management_toolbox.project_name}|g' \
              -e 's|@PROJECT_MANAGEMENT_DIRECTORY@|${config.devenv.root}|g' \
              -e 's|@SUBPROJECT_AGENDA_FILES@|${subprojectAgendaFiles}|g' \
              ${dirLocalsTemplate} > "$tmp"
          if [ -f "${dest}" ] && cmp -s "$tmp" "${dest}"; then
            rm -f "$tmp"
            exit 0
          fi
          rm -f "$tmp"
          exit 1
        '';
        exec = ''
          mkdir -p "$(dirname "${dest}")"
          sed -e 's|@PROJECT_NAME@|${config.project_management_toolbox.project_name}|g' \
              -e 's|@PROJECT_MANAGEMENT_DIRECTORY@|${config.devenv.root}|g' \
              -e 's|@SUBPROJECT_AGENDA_FILES@|${subprojectAgendaFiles}|g' \
              ${dirLocalsTemplate} > "${dest}"
        '';
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
        example = [ "/path/to/subproj1/subproj1.org" "/path/to/subproj2/subproj2.org" ];
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
