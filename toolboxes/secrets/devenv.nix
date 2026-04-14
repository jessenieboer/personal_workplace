{ pkgs, lib, config, inputs, ... }:
let
  gh_devenv_script = ./programs/gh_devenv.sh;
in
{
  enterShell = ''
    echo "jessenieboer's secrets toolbox available"
  '';

  files."gh_devenv.sh".source = ./programs/gh_devenv.sh;

  packages = with pkgs; [
    gnupg
    pass
    secretspec
  ];
}
