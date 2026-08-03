{ config, pkgs, ... }: {
  config = {
    nix.settings.trusted-users = [ "root" "@wheel" ];
    users = {
      mutableUsers = false;
      users = {
        jessenieboer = {
          createHome = true;
          description = "Jesse Nieboer";
          extraGroups = [
            "docker"
            "gamemode"
            "input" # dotool
            "plugdev" # yubikey stuff
            "wheel"
          ];
          group = "users";
          hashedPasswordFile = "/root/secrets/jessenieboer.hash";
          home = "/home/jessenieboer";
          isNormalUser = true;
        };
        root = {
          hashedPasswordFile = "/root/secrets/root.hash";
          packages = with pkgs; [ sops ];
          shell = pkgs.bash;
        };
      };
    };

    # git config for root user
    programs.git = {
      enable = true;
      config = {
        user = {
          name = "Jesse Nieboer";
          email = "jessenieboer@protonmail.com";
        };
      };
    };
  };
}
