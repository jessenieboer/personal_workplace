{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };

  # No skills yet; add them under extra.
  practicesTasks = tt.practices {
    name = "html";
  };
in
{
  config = {
    enterShell = ''
      ${tt.announce "html"}
    '';

    # devenv has no languages.html. These are the HTML and CSS language
    # servers (vscode-html-language-server, vscode-css-language-server) and
    # the formatter.
    packages = with pkgs; [
      prettier
      vscode-langservers-extracted
    ];

    tasks = practicesTasks
      // tt.gitSettings "html" ./settings
      // tt.seed {
        name = "html"; task = "copy_index_html_template";
        src = ./templates/index.html; dest = "index.html";
      };
  };
}
