{ pkgs, lib, config, inputs, ... }:

{
  enterShell = ''
    echo "managing ${config.project_management.project_name}"
  '';

  project_management.project_name = ;
}
