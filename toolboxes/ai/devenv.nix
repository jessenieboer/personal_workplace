{ pkgs, lib, config, inputs, ... }:

{
  packages = [ pkgs.git ];

  # https://devenv.sh/basics/
  enterShell = ''
    echo "jessenieboer's ai toolbox available"
  '';
}
