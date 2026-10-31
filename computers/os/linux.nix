{ pkgs, ... }: {
  boot = {
    initrd.systemd.enable = true; # Faster initrd with systemd
    kernel.sysctl = {
      "net.core.rmem_max" = 26214400; # 25MB read buffer for high bandwidth
      "net.core.wmem_max" = 26214400; # 25MB write buffer
      # boosteroid stuff:
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr"; # Excellent for high-bandwidth/low-latency
      "net.ipv4.tcp_fastopen" = 3;
    };
    kernelModules = [ "uinput" ]; # for dotool
    kernelPackages = pkgs.linuxPackages_latest; # Use the latest stable kernel
    kernelParams = [ "quiet" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # for dotool
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
  '';

  time.timeZone = "America/Chicago";

  virtualisation.docker.enable = true;
}
