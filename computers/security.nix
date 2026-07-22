{ config, inputs, lib, pkgs, ...}: {

  environment.systemPackages = with pkgs;
  [
    gnupg
    yubikey-manager
  ];

  hardware.gpgSmartcards.enable = true;

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };
    ssh.extraConfig = ''
      Host github.com
      IdentitiesOnly yes
      IdentityFile ~/.ssh/id_ed25519_sk
    '';
  };

  services = {
    pcscd = {
      enable = true;
      plugins = [ pkgs.ccid pkgs.yubikey-personalization ];
    };
    udev.packages = [ pkgs.yubikey-personalization ];
  };
}
