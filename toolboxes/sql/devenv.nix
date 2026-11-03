{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };

  # No skills yet; add them under extra.
  practicesTasks = tt.practices {
    name = "sql";
  };
in
{
  config = {
    enterShell = ''
      ${tt.announce "sql"}
    '';

    # devenv has no languages.sql. sqlfluff lints and formats (its dialect is
    # set in .sqlfluff); postgres-language-server is the language server.
    packages = with pkgs; [
      sqlfluff
      postgres-language-server
    ];

    tasks = practicesTasks
      // tt.gitSettings "sql" ./settings
      // tt.seed {
        name = "sql"; task = "copy_sqlfluff_template";
        src = ./templates/.sqlfluff; dest = ".sqlfluff";
      };
  };
}
