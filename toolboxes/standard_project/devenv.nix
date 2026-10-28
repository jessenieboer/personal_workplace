{ pkgs, lib, config, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  templatesRoot = ./templates;
  toolboxDir = "${config.devenv.root}/.toolboxes/standard_project_toolbox";
  templateDest = "${toolboxDir}/templates";

  templateDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir templatesRoot);
  templateNames = builtins.attrNames templateDirs;
in
{
  config = {
    enterShell = ''
      ${tt.announce "standard project"}
    '';

    tasks = tt.refresh {
      name = "standard_project"; task = "generate_dir_locals";
      description = "Render standard_project_toolbox_dir_locals from the template";
      dest = ".toolboxes/standard_project_toolbox/standard_project_toolbox_dir_locals";
      src = pkgs.replaceVars ./templates/dir-locals.el.in {
        STANDARD_PROJECT_DIRECTORY = config.devenv.root;
      };
    }
    // tt.gitignoreFor { name = "standard_project"; }
    // {
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
