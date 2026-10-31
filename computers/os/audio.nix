{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.alsa-utils
    pkgs.pavucontrol
  ];

  security.rtkit.enable = true;

  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
