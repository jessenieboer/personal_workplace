{ pkgs, lib, config, inputs, ... }:
let
  gh_devenv = ./programs/gh_devenv.sh;
  gitignore = ./settings/.gitignore;
  secretspecTemplate = ./templates/secretspec.toml;
in
{
  config = {
    enterShell = ''
      echo "secrets toolbox available"
    '';

    packages = with pkgs; [
      bws
      secretspec
    ];

    tasks = {
      "secrets_toolbox:copy_github_devenv" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ -f "${config.devenv.root}/.toolboxes/secrets_toolbox/gh_devenv.sh" ]; then
          echo "gh_devenv.sh already exists — skipping copy."
          exit 0
          fi
          mkdir -p ${config.devenv.root}/.toolboxes/secrets_toolbox
          cp ${gh_devenv} ${config.devenv.root}/.toolboxes/secrets_toolbox/gh_devenv.sh

          echo "copied github devenv program to .toolboxes/secrets_toolbox/gh_devenv.sh"
        '';
        showOutput = true;
      };
      # "secrets_toolbox:copy_gitignore" = {
      #   before = [ "devenv:enterShell" ];
      #   exec = ''
      #     mkdir -p ${config.devenv.root}/.toolboxes/secrets_toolbox
      #     cat ${gitignore} > ${config.devenv.root}/.toolboxes/secrets_toolbox/.gitignore
      #     echo "copied secrets_toolbox .gitignore"
      #   '';
      #   showOutput = true;
      # };
      "secrets_toolbox:copy_secretspec_template" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ -f "${config.devenv.root}/secretspec.toml" ]; then
          echo "secretspec.toml already exists — skipping copy."
          exit 0
          fi
          cp ${secretspecTemplate} ${config.devenv.root}/secretspec.toml
          chmod u+w ${config.devenv.root}/secretspec.toml

          echo "copied secretspec template to secretspec.toml"
        '';
        showOutput = true;
      };
    };
  };
}
