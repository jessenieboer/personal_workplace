{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.grok-bot.packages.${pkgs.system}.default
  ];

  # Plasma is Wayland; without this the app falls back to XWayland.
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # Login redirects use sand:// (and sometimes grokbot://).
  # This only works once the desktop file is on XDG_DATA_DIRS,
  # which Home Manager install does automatically.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/sand" = "grok-bot.desktop";
      "x-scheme-handler/grokbot" = "grok-bot.desktop";
    };
  };
}
