{ pkgs, lib, config, inputs, ... }:

{
  packages = [
    pkgs.hello
  ];

  # https://devenv.sh/basics/
  enterShell = ''
    echo "jessenieboer's project management toolbox available"
  '';
}
