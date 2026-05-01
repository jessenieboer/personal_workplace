{ pkgs, lib, config, inputs, ... }:
let
  gh_devenv_script = ./programs/gh_devenv.sh;
  secretspecTemplate = ./templates/secretspec.toml;
in
{
  enterShell = ''
    echo "jessenieboer's secrets toolbox available"
  '';

  files."gh_devenv.sh".source = ./programs/gh_devenv.sh;

  packages = with pkgs; [
    gnupg
    pass
    secretspec
  ];

  tasks = {
      "secrets_toolbox:copy_secretspec_template" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ -f "${config.devenv.root}/secretspec.toml" ]; then
          echo "docs readme.org already exists — skipping copy."
          exit 0
          fi
          cp ${secretspecTemplate} ${config.devenv.root}/secretspec.toml
          chmod u+w ${config.devenv.root}/secretspec.toml

          echo "copied secretspec template to secretspec.toml
        '';
        showOutput = true;
      };
    };
}
