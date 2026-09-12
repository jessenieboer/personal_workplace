{ config, pkgs, ... }:
let
  gitignore = ./settings/.gitignore;
  racketAddon = "${config.devenv.state}/racket";
in
{
  config = {
    env.PLTADDONDIR = racketAddon;

    languages.racket = {
      enable = true;
      package = pkgs.racket;
    };

    enterShell = ''
      echo "racket toolbox available"
      echo "racket: $(racket --version)"
      echo "raco: $(command -v raco)"
      echo "PLTADDONDIR: $PLTADDONDIR"
      if raco pkg show --user racket-langserver >/dev/null 2>&1; then
        echo "racket-langserver: installed (user scope)"
      else
        echo "racket-langserver: missing"
      fi
    '';

    tasks = {
      "racket_toolbox:copy_gitignore" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          mkdir -p "${config.devenv.root}/.toolboxes/racket_toolbox"
          cp -f ${gitignore} "${config.devenv.root}/.toolboxes/racket_toolbox/.gitignore"
          echo "copied racket_toolbox .gitignore"
        '';
        showOutput = true;
      };

      "racket_toolbox:install_langserver" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          mkdir -p "${racketAddon}"
          export PLTADDONDIR="${racketAddon}"
          raco pkg install --auto --skip-installed --user racket-langserver
          echo "racket-langserver ready"
        '';
        showOutput = true;
      };
    };
  };
}
