{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
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

    tasks = tt.gitignore "racket" ./settings/.gitignore
      // {

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
