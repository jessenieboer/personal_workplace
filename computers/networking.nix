{ config, lib, pkgs, ... }: {

  config = {
    boot = {
      # tune for high-bandwidth
      kernel.sysctl = {
        "net.core.rmem_max" = 16777216;
        "net.core.wmem_max" = 16777216;
        # boosteroid stuff:
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";  # Excellent for high-bandwidth/low-latency
        "net.ipv4.tcp_fastopen" = 3;

      };
    };

    networking = {
      firewall = {
        enable = true;
        allowedUDPPorts = [ 3478 5349 ]; # STUN/TURN for Boosteroid if needed
      };
      nameservers = ["1.1.1.1" "1.0.0.1"]; # cloudflare
      networkmanager.enable = false; # enable to use network manager tools to get on wifi
      useDHCP = true;
      wireless.enable = true;
    };

    services = {
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };

    };
  };
}

