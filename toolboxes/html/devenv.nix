{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
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

    tasks = tt.gitignore "html" ./settings/.gitignore
      // tt.seed {
        name = "html"; task = "copy_index_html_template";
        src = ./templates/index.html; dest = "index.html";
      };
  };
}
