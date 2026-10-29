{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
in
{
  config = {
    enterShell = ''
      ${tt.announce "html"}
      if [ -t 1 ]; then
        echo "html-ls: $(command -v vscode-html-language-server)"
        echo "css-ls: $(command -v vscode-css-language-server)"
        echo "prettier: $(command -v prettier)"
      fi
    '';

    packages = with pkgs; [
      prettier
      vscode-langservers-extracted
    ];

    tasks = tt.gitSettings "html" ./settings
      // tt.seed {
        name = "html"; task = "copy_index_html_template";
        src = ./templates/index.html; dest = "index.html";
      };
  };
}
