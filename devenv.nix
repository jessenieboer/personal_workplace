{ pkgs, lib, config, inputs, ... }:

{
  enterShell = ''
    echo "managing ${config.org_project_management_toolbox.project_name}"
  '';

  org_project_management_toolbox = {
    project_name = "personal_workplace";
    project_benefit = "Build and maintain my personal computer environment";
    workers = [
      { name = "jessenieboer"; email = "jessenieboer@protonmail.com"; }
      { name = "Vizier"; }
      { name = "CaptureBot"; }
    ];
  };
}
