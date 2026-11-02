{ pkgs, lib, config, inputs, ... }:
{
  enterShell = ''
    echo "managing ${config.project_management_toolbox.project_name}"
  '';

  project_management_toolbox = {
    project_name = "CHANGE_ME";
    project_benefit = "CHANGE_ME";
    # subproject_agenda_files = [
    #   "${config.devenv.root}/_election_integrity_projects/iowa_canvassing_support/iowa_canvassing_support.org"
    #   "${config.devenv.root}/jesse_personal_relationships/jesse_personal_relationships.org"
    #   "${config.devenv.root}/personal_workplace/personal_workplace.org"
    #   "${config.devenv.root}/professional_maintenance/professional_maintenance.org"
    #   "${config.devenv.root}/psalm_18/psalm_18.org"
    #   "${config.devenv.root}/relax_keyboard_layout/relax_keyboard_layout.org"
    #   "${config.devenv.root}/spiritual_formation/spiritual_formation.org"
    # ];
    workers = [
      { name = "jessenieboer"; email = "jessenieboer@protonmail.com"; }
      { name = "CaptureBot"; }
    ];
  };
}
