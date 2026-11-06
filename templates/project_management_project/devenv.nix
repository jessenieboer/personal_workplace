{ pkgs, lib, config, inputs, ... }:
{
  enterShell = ''
    echo "managing ${config.project_management_toolbox.project_name}"
  '';

  project_management_toolbox = {
    project_name = "CHANGE_ME";
    project_benefit = "CHANGE_ME";
    workers = [
      { name = "jessenieboer"; email = "jessenieboer@protonmail.com"; }
      { name = "CaptureBot"; }
    ];
  };
}
