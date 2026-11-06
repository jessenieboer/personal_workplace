{ pkgs, lib, config, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  # Live absolute paths. An explicit subproject_agenda_files list replaces this.
  discoverSubprojectAgendaFiles = import ../_lib/subproject_agenda_files.nix { inherit lib; };
  # Org files (<project>.org, its _archive, journal.org) live in the toolbox
  # directory, next to the generated dir-locals fragment. Syncthing sends only
  # **/project_management_toolbox/*.org to the phone, so keep them directly there.
  orgDir = "${config.devenv.root}/.toolboxes/project_management_toolbox";
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

    tasks = tt.gitSettings "project_management" ./settings
    # Everything in .toolboxes/project_management_toolbox is kept out of git: the
    # org files travel by Syncthing, and the dir-locals fragment is generated.
    // tt.refresh {
      name = "project_management"; task = "refresh_gitignore_dir";
      description = "Keep .toolboxes/project_management_toolbox/.gitignore ignoring everything";
      dest = ".toolboxes/project_management_toolbox/.gitignore";
      src = pkgs.writeText "project_management_toolbox_gitignore" "*\n";
    }
    // tt.refresh {
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
        default = baseNameOf config.devenv.root;
        description = "The name of this project";
        example = "My cool project";
        type = lib.types.strMatching "[^[:space:]]+";
      };

      project_benefit = lib.mkOption {
        default = "";
        description = "The good this project is aiming at";
        example = "My cool project";
        type = lib.types.str;
      };

      subproject_agenda_files = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = discoverSubprojectAgendaFiles config.devenv.root;
        description = "Org files of subprojects, added to org-agenda-files. When unset, regular .org files directly inside nested .toolboxes/project_management_toolbox directories, excluding this project's own. An explicit list is used as given.";
        example = [
          "/path/to/subproj1/.toolboxes/project_management_toolbox/subproj1.org"
          "/path/to/subproj2/.toolboxes/project_management_toolbox/subproj2.org"
        ];
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
