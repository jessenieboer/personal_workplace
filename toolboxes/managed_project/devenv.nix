{ pkgs, lib, config, ... }:
let
  gitignore = ./settings/.gitignore;
  dirLocalsTemplate = ./templates/dir-locals.el.in;
  toolboxDir = "${config.devenv.root}/.toolboxes/managed_project_toolbox";
  gitignoreDest = "${toolboxDir}/.gitignore";
  dirLocalsDest = "${toolboxDir}/managed_project_toolbox_dir_locals";
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "managed project toolbox available"
      fi
    '';

    tasks = {
      "managed_project_toolbox:copy_gitignore" = {
        description = "Refresh the managed_project_toolbox gitignore fragment from the toolbox";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${gitignoreDest}" ] && cmp -s ${gitignore} "${gitignoreDest}"
        '';
        exec = ''
          install -D -m 0644 ${gitignore} "${gitignoreDest}"
        '';
      };

      "managed_project_toolbox:generate_dir_locals" = {
        description = "Render managed_project_toolbox_dir_locals from the template";
        before = [ "devenv:enterShell" ];
        status = ''
          tmp=$(mktemp)
          sed -e 's|@MANAGED_PROJECT_DIRECTORY@|${config.devenv.root}|g' ${dirLocalsTemplate} > "$tmp"
          if [ -f "${dirLocalsDest}" ] && cmp -s "$tmp" "${dirLocalsDest}"; then
            rm -f  "$tmp"
            exit 0
          fi
          rm -f "$tmp"
          exit 1
        '';
        exec = ''
          mkdir -p "${toolboxDir}"
          sed -e 's|@MANAGED_PROJECT_DIRECTORY@|${config.devenv.root}|g' ${dirLocalsTemplate} > "${dirLocalsDest}"
        '';
      };
    };
  };
}
