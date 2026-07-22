{ pkgs, lib, config, inputs, ... }:

{
  enterShell = ''
    echo "managing ${config.project_management_toolbox.project_name}"
  '';

  project_management_toolbox.project_name = ;
}
