# wd-1T is the home of ~/Dropbox and ~/kingdoms. nofail: machines boot without it.
let
  drive = "/media/wd-1T";
  home = "/home/jessenieboer";
  bind = dir: {
    device = "${drive}/${dir}";
    fsType = "none";
    options = [ "bind" "nofail" "x-systemd.requires-mounts-for=${drive}" ];
  };
in
{
  fileSystems.${drive} = {
    device = "/dev/disk/by-uuid/83f6ba14-4954-4b83-a927-15dcc581d6bb";
    fsType = "ext4";
    options = [ "defaults" "noatime" "nofail" ];
  };
  fileSystems."${home}/Dropbox" = bind "Dropbox";
  fileSystems."${home}/kingdoms" = bind "kingdoms";
}
