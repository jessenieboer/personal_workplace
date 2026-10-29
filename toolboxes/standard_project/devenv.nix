{ pkgs, lib, config, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  templatesRoot = ./templates;
  toolboxDir = "${config.devenv.root}/.toolboxes/standard_project_toolbox";
  templateDest = "${toolboxDir}/templates";

  # templates/ holds one subdirectory per project template; it may be absent.
  templateDirs = lib.optionalAttrs (builtins.pathExists templatesRoot)
    (lib.filterAttrs (_: type: type == "directory") (builtins.readDir templatesRoot));
  templateNames = builtins.attrNames templateDirs;
in
{
  config = {
    enterShell = ''
      ${tt.announce "standard project"}
    '';

    tasks = tt.gitignoreFor { name = "standard_project"; }
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
