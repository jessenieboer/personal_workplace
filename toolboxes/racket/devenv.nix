{ config, pkgs, ... }:
let
  gitignore = ./settings/.gitignore;
  racketAddon = "${config.devenv.state}/racket";
  gitignoreDest = "${config.devenv.root}/.toolboxes/racket_toolbox/.gitignore";
in
{
  config = {
    env.PLTADDONDIR = racketAddon;

    languages.racket = {
      enable = true;
      package = pkgs.racket;
    };

    enterShell = ''
      if [ -t 1 ]; then
        echo "racket toolbox available"
        echo "racket: $(racket --version)"
        echo "raco: $(command -v raco)"
        echo "PLTADDONDIR: $PLTADDONDIR"
        if raco pkg show --user racket-langserver >/dev/null 2>&1; then
          echo "racket-langserver: installed (user scope)"
        else
          echo "racket-langserver: missing"
        fi
      fi
    '';

    tasks = {
      "racket_toolbox:copy_gitignore" = {
        description = "Refresh the racket_toolbox gitignore fragment from the toolbox";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${gitignoreDest}" ] && cmp -s ${gitignore} "${gitignoreDest}"
        '';
        exec = ''
          install -D -m 0644 ${gitignore} "${gitignoreDest}"
        '';
      };

      "racket_toolbox:install_langserver" = {
        description = "Install racket-langserver into PLTADDONDIR if missing";
        before = [ "devenv:enterShell" ];
        status = ''
          export PLTADDONDIR="${racketAddon}"
          raco pkg show --user racket-langserver >/dev/null 2>&1
        '';
        exec = ''
          mkdir -p "${racketAddon}"
          export PLTADDONDIR="${racketAddon}"
          raco pkg install --auto --skip-installed --user racket-langserver
        '';
      };
    };
  };
}
