{ pkgs, lib, config, inputs, ... }:
let 
  envrc = ./programs/.envrc;
in
{
  config = {
    enterShell = ''
      echo "jessenieboer's emacs toolbox available"
    '';

    tasks = {
      "emacs_toolbox:copy_envrc" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ -f "${config.devenv.root}/.envrc" ]; then
          echo ".envrc already exists — skipping copy."
          exit 0
          fi
          cp ${envrc} ${config.devenv.root}/.envrc
          chmod u+w ${config.devenv.root}/.envrc

          echo "copied programs/envrc to .envrc"
        '';
        showOutput = true;
      };
    };
  };
}
