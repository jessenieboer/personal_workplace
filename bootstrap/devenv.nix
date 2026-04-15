{ pkgs, lib, config, inputs, ... }:

{
  enterShell = ''
    echo "management for ${config.project_management.project_name} available"
  '';

  project_management.project_name = "my_project";
}
