{ pkgs, lib, config, inputs, ... }:
let
  dirLocalsTemplate = ./templates/dir-locals.el.in;
  dirLocalsDest = "${pmDir}/project_management_toolbox_dir_locals";
  # Org files (<project>.org, its _archive) live at the project root so
  # Dropbox/beorg can see them. Only the generated dir-locals fragment
  # stays under .toolboxes/project_management_toolbox.
  orgDir = config.devenv.root;
  pmDir = "${config.devenv.root}/.toolboxes/project_management_toolbox";
  subprojectAgendaFiles = lib.concatMapStringsSep " " (s: "\"${s}\"") config.project_management_toolbox.subproject_agenda_files;
  workerList = lib.concatMapStringsSep " " (w: w.name) config.project_management_toolbox.workers;
in
{
  config = {
    # project_management_toolbox = {
    #   project_name = "project_management_toolbox";
    #   workers = [
    #     { name = "jessenieboer"; email = "jessenieboer@protonmail.com"; }
    #     { name = "Vizier"; }
    #   ];
    # };

    enterShell = ''
      if [ -t 1 ]; then
      echo "project management toolbox available"
      fi
    '';

    tasks = {
      "project_management_toolbox:generate_dir_locals" = {
        description = "Render project_management_toolbox_dir_locals from devenv options";
        before = [ "devenv:enterShell" ];
        status = ''
          tmp=$(mktemp)
          sed -e 's|@PROJECT_NAME@|${config.project_management_toolbox.project_name}|g' \
          -e 's|@ORG_DIRECTORY@|${orgDir}|g' \
          -e 's|@SUBPROJECT_AGENDA_FILES@|${subprojectAgendaFiles}|g' \
          -e 's|@WORKER_LIST@|${workerList}|g' \
          ${dirLocalsTemplate} > "$tmp"
          if [ -f "${dirLocalsDest}" ] && cmp -s "$tmp" "${dirLocalsDest}"; then
          rm -f "$tmp"
          exit 0
          fi
          rm -f "$tmp"
          exit 1
        '';
        exec = ''
          mkdir -p "$(dirname "${dirLocalsDest}")"
          sed -e 's|@PROJECT_NAME@|${config.project_management_toolbox.project_name}|g' \
          -e 's|@ORG_DIRECTORY@|${orgDir}|g' \
          -e 's|@SUBPROJECT_AGENDA_FILES@|${subprojectAgendaFiles}|g' \
          -e 's|@WORKER_LIST@|${workerList}|g' \
          ${dirLocalsTemplate} > "${dirLocalsDest}"
        '';
      };
    };
  };

  options = {
    project_management_toolbox = {
      project_name = lib.mkOption {
        description = "The name of this project";
        example = "My cool project";
        type = lib.types.strMatching "[^[:space:]]+";
      };

      project_benefit = lib.mkOption {
        default = [ ];
        description = "The good this project is aiming at";
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
              type = lib.types.strMatching "[^[:space:]]+";
              description = "Name of worker (one word, no spaces)";
              example = "Jane";
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
          { name = "Alice"; email = "alice@example.com"; }
          { name = "Bob"; }
        ];
      };
    };
  };
}
