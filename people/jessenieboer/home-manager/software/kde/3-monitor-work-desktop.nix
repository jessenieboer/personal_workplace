# todo: plasma manager + window rules don't work great together yet
# use qdbus org.kde.KWin /KWin org.kde.KWin.queryWindowInfo to see window classes
{ config, inputs, pkgs, ... }:
let
  screens = config.personal_workplace.plasma.screens;
in
{

  # Plasma screen indices for the nucbox desk (see 3-monitor-work-desktop.sh):
  # left = DP-1, center = DP-2 (primary; gets the top panel), right = HDMI-A-1
  personal_workplace.plasma.screens = {
    left = 1;
    center = 2;
    right = 0;
  };

  programs = {
    plasma = {
      window-rules = [
        # left screen
        {
          apply = {
            screen = { apply = "force"; value = screens.left; };
          };
          description = "brave: left";
          match = {
            window-class = {
              match-whole = false;
              type = "exact";
              value = "brave-browser";
            };
          };
        }

        {
          apply = {
            screen = { apply = "force"; value = screens.left; };
          };
          description = "grok-bot";
          match = {
            window-class = {
              match-whole = false;
              type = "exact";
              value = "grok-bot";
            };
          };
        }

        # {
        #   apply = {
        #     screen = { apply = "force"; value = screens.left; };
        #   };
        #   description = "konsole: left";
        #   match = {
        #     window-class = {
        #       match-whole = false;
        #       type = "exact";
        #       value = "org.kde.konsole";
        #     };
        #   };
        # }

        {
          apply = {
            screen = { apply = "force"; value = screens.left; };
          };
          description = "dolphin: left";
          match = {
            window-class = {
              match-whole = false;
              type = "exact";
              value = "org.kde.dolphin";
            };
          };
        }

        {
          apply = {
            screen = { apply = "force"; value = screens.left; };
          };
          description = "emacs: left";
          match = {
            title = "jn_left"; 
            window-class = {
              match-whole = false;
              type = "exact";
              value = "emacs";
            };
          };
        }

        # center screen
        {
          apply = {
            screen = { apply = "force"; value = screens.center; };
          };
          description = "emacs: center";
          match = {
            title = "jn_center"; 
            window-class = {
              match-whole = false;
              type = "exact";
              value = "emacs";
            };
          };
        }

        {
          apply = {
            screen = { apply = "force"; value = screens.center; };
          };
          description = "konsole: center";
          match = {
            window-class = {
              match-whole = false;
              type = "exact";
              value = "org.kde.konsole";
            };
          };
        }

        # right screen
        {
          apply = {
            screen = { apply = "force"; value = screens.right; };
          };
          description = "emacs: right";
          match = {
            title = "jn_right"; 
            window-class = {
              match-whole = false;
              type = "exact";
              value = "emacs";
            };
          };
        }
        {
          apply = {
            screen = { apply = "force"; value = screens.right; };
          };
          description = "firefox-devedition: right";
          match = {
            window-class = {
              match-whole = false;
              type = "exact";
              value = "firefox-devedition";
            };
          };
        }
      ];
    };
  };
}
