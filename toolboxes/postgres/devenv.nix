{ config, pkgs, inputs, lib, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  cfg = config.postgres_toolbox;

  wshobson = "${inputs.wshobson-agents}/plugins";
  practicesTasks = tt.practices {
    name = "postgres";
    local = ./practices;
    extra = {
      "skills/postgresql-table-design" = "${wshobson}/database-design/skills/postgresql-table-design";
      "skills/sql-optimization-patterns" = "${wshobson}/developer-essentials/skills/sql-optimization-patterns";
    };
  };
in
{
  options.postgres_toolbox = {
    database = lib.mkOption {
      type = lib.types.strMatching "[a-z_][a-z0-9_]*";
      default = "culab";
      example = "myapp";
      description = ''
        Database created on the first `devenv up` and exported as
        PGDATABASE, so plain `psql` and `pgcli` connect to it.
      '';
    };
  };

  config = {
    enterShell = ''
      ${tt.announce "postgres"}
      if [ -t 1 ]; then
        echo "psql version: $(psql --version)"
        echo "pgcli version: $(pgcli --version)"
        echo "database: $PGDATABASE (start the server with devenv up -d)"
      fi
    '';

    env.PGDATABASE = cfg.database;

    # PostgreSQL 16, a devenv process (data in .devenv/state/postgres,
    # Unix socket only). mkDefault so a project can turn it off or move
    # to another major (that needs pg_upgrade of the data dir).
    services.postgres = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.postgresql_16;
      initialDatabases = [ { name = cfg.database; } ];
    };

    # The service adds psql when enabled; keep it on PATH when it is not.
    packages = [
      pkgs.pgcli
    ] ++ lib.optional (!config.services.postgres.enable) config.services.postgres.package;

    tasks = practicesTasks
      // tt.gitSettings "postgres" ./settings;
  };
}
