{ config, pkgs, ... }:

{
  # let maestral handle config
  # maestral auth
  # maestral config set path "/home/jessenieboer/Dropbox"
  # maestral excluded add "folder or file name"
  # put .mignore in "/home/jessenieboer/Dropbox":
    # .devenv/
    # devenv.*
    # .envrc
    # gh_devenv.sh
    # .gitignore
    # .dir-locals.el


  home.packages = with pkgs; [
    maestral      # CLI + daemon
  ];

  # Declarative systemd user service for the daemon
  systemd.user.services.maestral = {
    Unit = {
      Description = "Maestral Dropbox Client";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.maestral}/bin/maestral start --foreground";
      Restart = "on-failure";
      RestartSec = 5;

      # Environment variables that help with tray icons / Qt on NixOS
      # Environment = [
        #   "QT_QPA_PLATFORMTHEME=qt5ct"
        #   "XDG_CURRENT_DESKTOP=${config.xdg.desktopEnvironment or ""}"  # optional
        # ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
