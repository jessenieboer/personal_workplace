{ config, lib, pkgs, modulesPath, ... }:
{
  config = {
    boot = {
      extraModulePackages = [ ];

      initrd = {
        availableKernelModules = [ "nvme" "sd_mod" "usbhid" "usb_storage" "xhci_pci"];
        kernelModules = [ "amdgpu" ]; # ensure it loads early
      };

      kernelModules = [ "kvm-amd" ];
      kernelParams = [
        "amd_pstate=active"   # modern scaling (try it)
        "amdgpu.dcdebugmask=0x10"        # Helps Vega iGPU stability
        "amdgpu.gpu_recovery=1"          # Better error recovery
        "usbcore.autosuspend=-1"  # Disable USB autosuspend to avoid delays
        "usbcore.usbfs_snoop=0"  # Disable USB filesystem snooping
        "xhci_hcd.quirks=0x400"  # Add quirks for better hub handling (e.g., reduce polling delays)
      ];
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };

    environment.systemPackages = with pkgs; [ gamemode lm_sensors ]; # lm_sensors monitor thermal

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/579ea923-076a-472f-9a79-c88870ecdf67";
      fsType = "ext4";
      options = [
        "defaults"
        "noatime"
        "nodiratime"
      ]; # Reduce disk writes
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/AAD0-8E7E";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    fileSystems."/var/lib/postgres_drive" = {
      device = "/dev/disk/by-uuid/3c4900a8-f63f-4df9-b39c-dc0078d50e10";
      fsType = "ext4";
    };

    hardware = {
      bluetooth.enable = true;
      #enableAllFirmware = true;
      cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      enableRedistributableFirmware = true;
      graphics = {
        enable = true;
        enable32Bit = true; # Important for some games/Flatpak
        extraPackages = with pkgs; [
          mesa # Usually pulled in, but explicit is good
        ];
        extraPackages32 = with pkgs; [
          driversi686Linux.mesa
        ];
      };
      # xone.enable = true; seems to not be necessary; boosteroid works
    };

    # setting hostname makes brave not work
    #networking.hostName = "nucbox";

    nix.settings.max-jobs = lib.mkDefault 16;
    nix.settings.cores = 8;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    powerManagement.cpuFreqGovernor = "performance";

    programs.gamemode = {
      enable = true;
      enableRenice = true;        # optional but nice
      settings = {
        general = {
          reaper_freq = 5;
          desiredgov = "performance";
          desiredprof = "performance";
          softrealtime = "auto";     
          renice = 0;           
          ioprio = 0;
          inhibit_screensaver = 1;
          disable_splitlock = 1;
        };

        #igpu_desiredgov = "performance";

        cpu = {
          park_cores = "no";
          pin_cores = "yes";               # Helps keep game-related threads on best cores
        };
      };
    };

    services = {
      flatpak.enable = true; # for boosteroid app
      fstrim.enable = true;
      thermald.enable = true;
    };

    swapDevices = [ ]; # todo: i think the nucbox has a swap partition that i'm not using

    time.timeZone = "America/Chicago";

    zramSwap.enable = true; # In-memory compressed swap

  };
}
