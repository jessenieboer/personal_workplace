{ config, lib, pkgs, modulesPath, ... }: {

  # bios lenovo n27et58w (1.44) 10/7/2025
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
      initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      initrd.kernelModules = [ ];
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/ad504285-51cc-409d-91a9-c63702feaa41";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/669E-6D24";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    # setting hostname makes brave not work
    #networking.hostName = "thinkpad";

    swapDevices = [ ];

    time.timeZone = "America/Chicago";
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
