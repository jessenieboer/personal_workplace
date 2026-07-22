{
  config,
  lib,
  pkgs,
  ...
}:
{
  fileSystems."/var/lib/postgres_drive" = {
    device = "/dev/disk/by-uuid/3c4900a8-f63f-4df9-b39c-dc0078d50e10";
    fsType = "ext4";
    options = ["defaults" "noatime" "nofail"];# "x-systemd.growfs"]; # noatime for performance; growfs if resizing needed
  };

  systemd = {
    services.postgresql = {
      after = [ "var-lib-postgres_drive.mount" ];
      # requires = [ "var-lib-postgres_drive.mount" ]; # errors on startup if no drive connected
      wants = lib.mkIf config.services.postgresql.enable [ "var-lib-postgres_drive.mount" ]; # less strict
      wantedBy = lib.mkForce []; # prevent postgres from auto-starting
    };
    tmpfiles.rules = [
      # Create PostgreSQL data directory with correct ownership/permissions
      # make sure dataDir in postgres.nix uses this directory
      "d /var/lib/postgres_drive/postgresql/16 0700 postgres postgres - -"
    ];
  };
}
