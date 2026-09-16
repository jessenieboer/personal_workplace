{ pkgs, lib, config, inputs, ... }:
let
  gitignore = ./settings/.gitignore;
  secretspecTemplate = ./templates/secretspec.toml;
  root = config.devenv.root;
  ghDest = "${root}/.toolboxes/secrets_toolbox/gh_devenv.sh";
  gitignoreDest = "${root}/.toolboxes/secrets_toolbox/.gitignore";
  secretspecDest = "${root}/secretspec.toml";
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "secrets toolbox available"
      fi
    '';

    packages = with pkgs; [
      bws
      secretspec
    ];

    tasks = {

      "secrets_toolbox:copy_gitignore" = {
        description = "Refresh the secrets_toolbox gitignore fragment from the toolbox";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${gitignoreDest}" ] && cmp -s ${gitignore} "${gitignoreDest}"
        '';
        exec = ''
          install -D -m 0644 ${gitignore} "${gitignoreDest}"
        '';
      };

      "secrets_toolbox:copy_secretspec_template" = {
        description = "Seed secretspec.toml once from the toolbox template";
        before = [ "devenv:enterShell" ];
        status = ''
          test -f "${secretspecDest}"
        '';
        exec = ''
          install -D -m 0644 ${secretspecTemplate} "${secretspecDest}"
        '';
      };
    };
  };
}
