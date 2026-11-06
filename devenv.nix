{ pkgs, lib, config, inputs, ... }:

{
  enterShell = ''
    echo "managing ${config.project_management_toolbox.project_name}"
  '';

  project_management_toolbox = {
    project_name = "personal_workplace";
    project_benefit = "Build and maintain my personal computer environment";
    workers = [
      { name = "jessenieboer"; email = "jessenieboer@protonmail.com"; }
      { name = "Vizier"; }
      { name = "CaptureBot"; }
    ];
  };
}
