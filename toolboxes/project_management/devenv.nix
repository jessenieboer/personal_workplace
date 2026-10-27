{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  # Org files (<project>.org, its _archive) live at the project root so
  # Dropbox/beorg can see them. Only the generated dir-locals fragment
  # stays under .toolboxes/project_management_toolbox.
  orgDir = config.devenv.root;
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
      ${tt.announce "project management"}
    '';

    tasks = tt.refresh {
      name = "project_management"; task = "generate_dir_locals";
      description = "Render project_management_toolbox_dir_locals from devenv options";
      dest = ".toolboxes/project_management_toolbox/project_management_toolbox_dir_locals";
      # replaceVars fails the build if any @PLACEHOLDER@ is left unfilled.
      src = pkgs.replaceVars ./templates/dir-locals.el.in {
        PROJECT_NAME = config.project_management_toolbox.project_name;
        ORG_DIRECTORY = orgDir;
        SUBPROJECT_AGENDA_FILES = subprojectAgendaFiles;
        WORKER_LIST = workerList;
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
