{ config, lib, pkgs, ...}: {
  config = {
    boot = {
      initrd = {
        systemd.enable = true; # Faster initrd with systemd
      };
      kernel.sysctl = {
        "net.core.rmem_max" = 26214400; # Sets read buffer to 25MB
        "net.core.wmem_max" = 26214400; # Sets write buffer to 25MB
      };
      kernelModules = [ "uinput" ]; # for dotool
      kernelPackages = pkgs.linuxPackages_latest; # Use the latest stable kernel
      kernelParams = [
        "quiet"
        "splash"
      ];
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };

    # for dotool
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    '';

    virtualisation.docker.enable = true;
  };

}
