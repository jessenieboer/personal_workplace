{ config, lib, pkgs, ... }:
{
  fileSystems."/media/external/backup_drive" = {
    device = "/dev/disk/by-uuid/83f6ba14-4954-4b83-a927-15dcc581d6bb";
    fsType = "ext4";
    options = [ "defaults" "noatime" "nofail" "user" ];
  };
}
