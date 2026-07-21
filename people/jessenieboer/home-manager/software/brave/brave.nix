{ config, pkgs, ... }:

{
  # todo: declaratively install bitwarden and other extensions 
  programs.chromium = {
    commandLineArgs = [
      "--ozone-platform=wayland"
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,WaylandWindowDecorations"
      "--gtk-version=4"
    ];
    enable = true;
    #extensions = [
    #  { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
    #];
    package = pkgs.brave;
  };
}
