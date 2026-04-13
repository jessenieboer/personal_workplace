{ pkgs, lib, config, inputs, ... }:
let
  dirLocalsTemplate = ./templates/dir-locals.el.in;
  gitIgnore = ./configs/.gitignore;
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

    project_management = {
      project_name = "project_management_toolbox";
    };

    # todo use pkgs.replaceVars instead of sed?
    tasks = {
      "project_management_toolbox:generate_dir_locals" = {
        before = [ "devenv:enterShell" ];
        exec = let
          subprojectDirs = lib.concatStringsSep " " config.project_management.subproject_directories;
        in ''
          sed -e "s|@PROJECT_NAME@|${config.project_management.project_name}|g" \
          -e "s|@PROJECT_DIRECTORY@|${config.devenv.root}|g" \
          -e "s|@SUBPROJECT_DIRECTORIES@|${subprojectDirs}|g" \
          ${dirLocalsTemplate} > .dir-locals.el

          echo ".dir-locals.el generated successfully"
        '';
        execIfModified = [
          "devenv.nix"
        ];        
        showOutput = true;
      };
      "project_management_toolbox:update_gitignore" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ ! -f .gitignore ]; then
          rsync -a --chmod=a+rw ${gitIgnore} .gitignore
          echo "Copied new .gitignore"
          else
          cat ${gitIgnore} .gitignore | sort -u >  .gitignore.tmp && mv .gitignore.tmp .gitignore
          echo "Updated existing .gitignore"
          fi
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

      subproject_directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of directories to subprojects";
        example = [ "/path/to/subproj1/" "/path/to/subproj2/"];
      };
    };
  };
}
