{ pkgs, lib, config, inputs, ... }:

{
  enterShell = ''
    echo "jessenieboer's project management toolbox available"
  '';

  files = {
    ".envrc".text = ''
      #!/usr/bin/env bash

      eval "$(devenv direnvrc)"
    '';

    "project_management/project_info.org".source = ./templates/project_info.org;
    "project_management/static_config.org".source = ./configs/static_config.org;
  };
}
