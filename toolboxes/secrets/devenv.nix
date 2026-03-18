{ pkgs, lib, config, inputs, ... }:

{
  enterShell = ''
    echo "jessenieboer's secrets toolbox available"
  '';

  packages = with pkgs; [
    gnupg
    pass
    secretspec
  ];
}
