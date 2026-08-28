{ config, pkgs, ... }:

{
  programs.firefox = {
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    enable = true;
    package = pkgs.firefox-devedition;
    profiles."dev-edition-default" = {
      id = 0;
      isDefault = true;
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.startup.page" = 0;                 # blank window
        "browser.startup.homepage" = "about:blank";
        "browser.shell.checkDefaultBrowser" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "privacy.donottrackheader.enabled" = true;
        "devtools.toolbox.host" = "right";
        "devtools.responsive.viewport.width" = 1280;
        "devtools.responsive.viewport.height" = 800;
      };
    };
  };
}
