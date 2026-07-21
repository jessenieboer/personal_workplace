{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    docker
    docker-compose
  ];

  # home.sessionVariables = {
  #   DOCKER_HOST = "unix:///run/docker.sock";   # usually not needed
  # };
}
