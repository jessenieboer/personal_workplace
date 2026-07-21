{ config, inputs, lib, pkgs, ... }:
let
  boosteroidRelease = "v1.1.34";
in
{
  home = {
    packages = with pkgs; [ flatpak mangohud ];
    sessionVariables = {
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:${config.home.homeDirectory}/.local/share/flatpak/exports/share";
    };
    
    file = {
    ".config/MangoHud/Mangohud.conf".text = ''
      fps=1
      frame_timing=1
      cpu_stats=1
      gpu_stats=1
      ram=1
      vram=1
      position=top-right
      text_color=FFFFFF
      text_outline=1
      no_display=0
    '';
  };
  };
  
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];
  
  services.flatpak = {
    enable = true;
    update.onActivation = true;

    # see notes
    # packages = [
    #   # Boosteroid Flatpak (using the bundle)
    #   {
    #     appId = "org.schelstraete.boosteroid";
    #     origin = "flathub";
    #     bundle = "${pkgs.fetchurl {
    #       url = "https://github.com/bschelst/boosteroid-steamos/releases/download/${boosteroidRelease}/org.schelstraete.boosteroid.flatpak";
    #       sha256 = "sha256-z7FVSIiuZ+9HQZBaQGfCw6XyXLcFtdZD56co45SDe4E=";
    #     }}";
    #   }
    # ];

    overrides = {
      "org.schelstraete.boosteroid" = {
        Context = {
          env = [
            "AMD_VULKAN_ICD=radeonsi"
            "BOOSTEROID_FORCE_H265=1"   # better quality on AMD
            "GAMEMODE_AUTO=1"
            "MESA_LOADER_DRIVER_OVERRIDE=radeonsi"
            # "DEBUG=1"                 # enable debug logs
            "MANGOHUD=1"
            "NOSPLASH=1"
          ];
          #sockets = [ "session-bus" "system-bus" ];
          sockets = [ "session-bus"];
          shares = [ "ipc" ];
          # shares = [ "ipc" "network" ];
          #devices = [ "dri" ];
        };
        # SessionBus = {
        #   talk = [ "org.freedesktop.portal.Desktop" ];
        # };
      };
    };
  };

  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde     # Best for Plasma
      xdg-desktop-portal-gtk     # Fallback
    ];

    # Tell portals which backend to prefer
    config = {
      common = {
        default = [ "kde" "gtk" ];
      };
    };
  };
}
