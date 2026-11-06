# Syncthing shares ~/kingdoms with the iPhone (Möbius Sync) only. Laptop and nucbox
# do NOT sync with each other: the wd-1T drive moves between them.
# GUI: http://127.0.0.1:8384 (each machine has its own device ID, shown under Actions > Show ID).
{ config, pkgs, utils, lib, ... }:
let
  home = config.users.users.jessenieboer.home;
  kingdoms = "${home}/kingdoms";
  mount = "${utils.escapeSystemdPath kingdoms}.mount";
  # Paste the iPhone's device ID (Möbius Sync > Menu > Show My ID) to make the pairing
  # declarative. Until then add it in the GUI; folder devices reset on the next restart.
  iphoneId = "AACNMOR-Y7T65IT-YDTY2AP-FD7TY3K-QGRVR3V-VX3ERDI-M65EIGY-TUNKFA5";
  stignore = pkgs.writeText "stignore" ''
    !/beorg-*.org
    !/init.org
    !**/project_management_toolbox/*.org
    *
  '';
  # Copy, not symlink: Syncthing does not follow a link into the store. Only write on change.
  installStignore = pkgs.writeShellApplication {
    name = "install-kingdoms-stignore";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      dest=${lib.escapeShellArg kingdoms}/.stignore
      cmp -s ${stignore} "$dest" || install -m644 ${stignore} "$dest"
    '';
  };
in
{
  services.syncthing = {
    enable = true;
    user = "jessenieboer";
    group = "users";
    dataDir = home;
    configDir = "${home}/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = false; # keep devices added in the GUI
    overrideFolders = true; # kingdoms is the only folder (drops the default ~/Sync)
    settings = {
      devices = lib.optionalAttrs (iphoneId != null) { iphone.id = iphoneId; };
      folders.kingdoms = {
        path = kingdoms;
        devices = lib.optional (iphoneId != null) "iphone";
      };
    };
  };

  # Run only while the wd-1T bind mount is up (like Maestral on ~/Dropbox): never start
  # without it, start when it appears, stop when it goes away.
  systemd.services = lib.mkMerge [
    (lib.genAttrs [ "syncthing" "syncthing-init" ] (_: {
      after = [ mount ];
      bindsTo = [ mount ];
      wantedBy = lib.mkForce [ mount ];
    }))
    # Runs as the service user, after the mount is up (bindsTo above).
    { syncthing.serviceConfig.ExecStartPre = lib.getExe installStignore; }
  ];
}
