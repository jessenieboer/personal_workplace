{ config, pkgs, inputs, lib, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  cfg = config.sql_toolbox;

  # PostgreSQL 17: the nixpkgs 26.05 default. Pinned so the client and the
  # optional server agree, and so a nixpkgs bump never hands an existing
  # .devenv/state/postgres data dir to a newer major (that needs pg_upgrade).
  postgresql = pkgs.postgresql_17;

  wshobson = "${inputs.wshobson-agents}/plugins";
  practicesTasks = tt.practices {
    name = "sql";
    local = ./practices;
    extra = {
      "skills/postgresql-table-design" = "${wshobson}/database-design/skills/postgresql-table-design";
      "skills/sql-optimization-patterns" = "${wshobson}/developer-essentials/skills/sql-optimization-patterns";
      "skills/database-migration" = "${wshobson}/framework-migration/skills/database-migration";
    };
  };
in
{
  options.sql_toolbox = {
    postgres.enable = lib.mkEnableOption ''
      a project-local PostgreSQL server (devenv services.postgres, data
      under .devenv/state/postgres, Unix socket only). Start it with
      `devenv up`. Set further services.postgres.* options in the project
    '';
  };

  config = lib.mkMerge [
    {
      enterShell = ''
        ${tt.announce "sql"}
        if [ -t 1 ]; then
          echo "psql version: $(psql --version)"
          echo "sqlfluff version: $(sqlfluff --version)"
          echo "postgres-language-server version: $(postgres-language-server --version 2>&1)"
        fi
      '';

      # When any toolbox enables services.postgres (this one's opt-in or the
      # postgres toolbox), devenv already puts that server's psql on PATH.
      packages = [
        pkgs.postgres-language-server
        pkgs.sqlfluff
      ] ++ lib.optional (!config.services.postgres.enable) postgresql;

      tasks = practicesTasks
        // tt.gitSettings "sql" ./settings
        // tt.seed {
          name = "sql"; task = "copy_sqlfluff_template";
          src = ./templates/.sqlfluff; dest = ".sqlfluff";
        };
    }

    (lib.mkIf cfg.postgres.enable {
      # Weaker than mkDefault so the postgres toolbox (or the project)
      # picks the server version when both toolboxes are imported.
      services.postgres = {
        enable = true;
        package = lib.mkOverride 1200 postgresql;
      };
    })
  ];
}
