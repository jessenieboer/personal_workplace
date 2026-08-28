{ config, pkgs, ... }:
let
  gitignore = ./settings/.gitignore;
  indexHtmlTemplate = ./templates/index.html;
in
{
  config = {
    enterShell = ''
      echo "html toolbox available"

      echo "html lsp: $(command -v vscode-html-language-server)"
      echo "css lsp: $(command -v vscode-css-language-server)"
      echo "tidy version: $(tidy -version 2>/dev/null | head -n1 || echo 'tidy missing')"
    '';

    packages = [
      pkgs.html-tidy
      pkgs.vscode-langservers-extracted
    ];

    tasks = {
      "html_toolbox:copy_gitignore" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          mkdir -p "${config.devenv.root}/.toolboxes/html_toolbox"
          cp -f ${gitignore} "${config.devenv.root}/.toolboxes/html_toolbox/.gitignore"
          echo "copied html_toolbox .gitignore"
        '';
        showOutput = true;
      };
      "html_toolbox:copy_index_html_template" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ -f "${config.devenv.root}/index.html" ]; then
          echo "index.html already exists — skipping copy."
          exit 0
          fi
          cp ${indexHtmlTemplate} ${config.devenv.root}/index.html
          chmod u+w ${config.devenv.root}/index.html

          echo "copied templates/index.html to index.html"
        '';
        showOutput = true;
      };
    };
  };
}
