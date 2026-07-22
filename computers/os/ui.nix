{ config, lib, pkgs, ... }: {

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}
