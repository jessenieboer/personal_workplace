{ config, pkgs, ... }:
let
  gitignore = ./settings/.gitignore;
  indexHtmlTemplate = ./templates/index.html;
  root = config.devenv.root;
  gitignoreDest = "${root}/.toolboxes/html_toolbox/.gitignore";
  indexDest = "${root}/index.html";
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "html toolbox available"
        echo "html-ls: $(command -v vscode-html-language-server)"
        echo "css-ls: $(command -v vscode-css-language-server)"
        echo "prettier: $(command -v prettier)"
      fi
    '';

    packages = with pkgs; [
      prettier
      vscode-langservers-extracted
    ];

    tasks = {
      "html_toolbox:copy_gitignore" = {
        description = "Refresh the html_toolbox gitignore fragment from the toolbox";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${gitignoreDest}" ] && cmp -s ${gitignore} "${gitignoreDest}"
        '';
        exec = ''
          install -D -m 0644 ${gitignore} "${gitignoreDest}"
        '';
      };

      "html_toolbox:copy_index_html_template" = {
        description = "Seed index.html once from the toolbox template";
        before = [ "devenv:enterShell" ];
        status = ''
          test -f "${indexDest}"
        '';
        exec = ''
          install -D -m 0644 ${indexHtmlTemplate} "${indexDest}"
        '';
      };
    };
  };
}
