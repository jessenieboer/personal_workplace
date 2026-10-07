{ pkgs, lib, config, ... }:
let
  gitignore = ./settings/.gitignore;
  dirLocalsTemplate = ./templates/dir-locals.el.in;
  templatesRoot = ./templates;
  toolboxDir = "${config.devenv.root}/.toolboxes/standard_project_toolbox";
  templateDest = "${toolboxDir}/templates";
  gitignoreDest = "${toolboxDir}/.gitignore";
  dirLocalsDest = "${toolboxDir}/standard_project_toolbox_dir_locals";

  templateDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir templatesRoot);
  templateNames = builtins.attrNames templateDirs;
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "standard project toolbox available"
      fi
    '';

    tasks = {
      "standard_project_toolbox:copy_gitignore" = {
        description = "Refresh the standard_project_toolbox gitignore fragment from the toolbox";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${gitignoreDest}" ] && cmp -s ${gitignore} "${gitignoreDest}"
        '';
        exec = ''
          install -D -m 0644 ${gitignore} "${gitignoreDest}"
        '';
      };

      "standard_project_toolbox:generate_dir_locals" = {
        description = "Render standard_project_toolbox_dir_locals from the template";
        before = [ "devenv:enterShell" ];
        status = ''
          tmp=$(mktemp)
          sed -e 's|@STANDARD_PROJECT_DIRECTORY@|${config.devenv.root}|g' ${dirLocalsTemplate} > "$tmp"
          if [ -f "${dirLocalsDest}" ] && cmp -s "$tmp" "${dirLocalsDest}"; then
            rm -f  "$tmp"
            exit 0
          fi
          rm -f "$tmp"
          exit 1
        '';
        exec = ''
          mkdir -p "${toolboxDir}"
          sed -e 's|@STANDARD_PROJECT_DIRECTORY@|${config.devenv.root}|g' ${dirLocalsTemplate} > "${dirLocalsDest}"
        '';
      };

      "standard_project_toolbox:copy_templates" = {
        description = "Refresh each templates/ subdirectory under .toolboxes/standard_project_toolbox/templates when source changes";
        before = [ "devenv:enterShell" ];
        status = ''
          ${lib.concatMapStringsSep "\n" (name: let
            src = templatesRoot + "/${name}";
          in ''
            [ -d "${templateDest}/${name}" ] || exit 1
            diff -rq -x '.#*' ${src} "${templateDest}/${name}" >/dev/null || exit 1
          '') templateNames}
        '';
        exec = ''
          mkdir -p "${templateDest}"
          ${lib.concatMapStringsSep "\n" (name: let
            src = templatesRoot + "/${name}";
          in ''
            rm -rf "${templateDest}/${name}"
            cp -a ${src} "${templateDest}/${name}"
            chmod -R u+w "${templateDest}/${name}"
            # Drop Emacs lock files if the source tree had any.
            find "${templateDest}/${name}" -name '.#*' -delete
          '') templateNames}
        '';
      };
    };
  };
}
