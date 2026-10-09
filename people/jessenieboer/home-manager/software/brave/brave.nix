{ config, pkgs, ... }:

{
  # todo: declaratively install bitwarden and other extensions 
  programs.chromium = {
    commandLineArgs = [
      "--ozone-platform=wayland"
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,WaylandWindowDecorations"
      "--gtk-version=4"
    ];
    enable = true;
    #extensions = [
    #  { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
    #];
    package = pkgs.brave;
  };

  # Make Brave the default browser explicitly. Without these, KDE has no
  # default and falls back to whichever installed browser it finds first
  # (firefox-devedition).
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "text/html" = "brave-browser.desktop";
      "application/xhtml+xml" = "brave-browser.desktop";
    };
  };

  # KDE replaces the managed ~/.config/mimeapps.list symlink with a regular file
  # whenever a default app is picked in System Settings or a "Open with" dialog,
  # which makes the next home-manager switch fail with "would be clobbered".
  # Let the declared defaults win.
  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;
}
