{
  networking = {
    firewall = {
      enable = true;
      allowedUDPPorts = [ 3478 5349 ]; # STUN/TURN for Boosteroid if needed
    };
    nameservers = [ "1.1.1.1" "1.0.0.1" ]; # cloudflare
    networkmanager.enable = false; # enable to use network manager tools to get on wifi
    useDHCP = true;
    wireless.enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
