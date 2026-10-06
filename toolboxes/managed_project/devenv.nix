{ pkgs, lib, config, ... }:
let
  gitignore = ./settings/.gitignore;
  dirLocalsTemplate = ./templates/dir-locals.el.in;
  templatesRoot = ./templates;
  toolboxDir = "${config.devenv.root}/.toolboxes/managed_project_toolbox";
  templateDest = "${toolboxDir}/templates";
  gitignoreDest = "${toolboxDir}/.gitignore";
  dirLocalsDest = "${toolboxDir}/managed_project_toolbox_dir_locals";

  templateDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir templatesRoot);
  templateNames = builtins.attrNames templateDirs;
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

      "managed_project_toolbox:copy_templates" = {
        description = "Seed each templates/ subdirectory under .toolboxes/managed_project_toolbox/templates once";
        before = [ "devenv:enterShell" ];
        status = ''
          ${lib.concatMapStringsSep "\n" (name: ''
            [ -d "${templateDest}/${name}" ] || exit 1
          '') templateNames}
        '';
        exec = ''
          mkdir -p "${templateDest}"
          ${lib.concatMapStringsSep "\n" (name: let
            src = templatesRoot + "/${name}";
          in ''
            if [ ! -d "${templateDest}/${name}" ]; then
              cp -a ${src} "${templateDest}/${name}"
              chmod -R u+w "${templateDest}/${name}"
            fi
          '') templateNames}
        '';
      };
    };
  };
}
