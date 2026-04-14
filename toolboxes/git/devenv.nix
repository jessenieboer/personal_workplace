{ pkgs, lib, config, inputs, ... }:
let
  gitIgnore = ./configs/.gitignore;
in
{
  config = {
    enterShell = ''
      echo "jessenieboer's git toolbox available"
    '';

    tasks = {
      "project_management_toolbox:update_gitignore" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ ! -f .gitignore ]; then
          rsync -a --chmod=a+rw ${gitIgnore} .gitignore
          echo "Copied new .gitignore"
          else
          cat ${gitIgnore} .gitignore | sort -u >  .gitignore.tmp && mv .gitignore.tmp .gitignore
          echo "Updated existing .gitignore"
          fi
        '';      
        showOutput = true;
      };
    };
  };
}
