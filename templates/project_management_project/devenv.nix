{ pkgs, lib, config, inputs, ... }:
{
  enterShell = ''
    echo "managing ${config.project_management_toolbox.project_name}"
  '';

  project_management_toolbox = {
    project_name = "CHANGE_ME";
    project_benefit = "CHANGE_ME";
    # subproject_agenda_files = [
    #   "${config.devenv.root}/_election_integrity_projects/iowa_canvassing_support/.toolboxes/project_management_toolbox/iowa_canvassing_support.org"
    #   "${config.devenv.root}/jesse_personal_relationships/.toolboxes/project_management_toolbox/jesse_personal_relationships.org"
    #   "${config.devenv.root}/personal_workplace/.toolboxes/project_management_toolbox/personal_workplace.org"
    #   "${config.devenv.root}/professional_maintenance/.toolboxes/project_management_toolbox/professional_maintenance.org"
    #   "${config.devenv.root}/psalm_18/.toolboxes/project_management_toolbox/psalm_18.org"
    #   "${config.devenv.root}/relax_keyboard_layout/.toolboxes/project_management_toolbox/relax_keyboard_layout.org"
    #   "${config.devenv.root}/spiritual_formation/.toolboxes/project_management_toolbox/spiritual_formation.org"
    # ];
    workers = [
      { name = "jessenieboer"; email = "jessenieboer@protonmail.com"; }
      { name = "CaptureBot"; }
    ];
  };
}
