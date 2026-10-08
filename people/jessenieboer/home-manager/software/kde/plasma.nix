{ config, inputs, lib, pkgs, ... }:
let
  panelCfg = config.personal_workplace.plasma.panel;
  screens = config.personal_workplace.plasma.screens;

  # Keys for moving focus / the active window to the monitor at each position.
  # They bind to KWin's "Switch to Screen N" / "Window to Screen N" actions, with
  # N taken from personal_workplace.plasma.screens, so the keys follow the layout.
  screenKeys = {
    left   = { switch = "Meta+F7"; window = "Meta+Ctrl+F7"; };
    center = { switch = "Meta+H";  window = "Meta+Ctrl+H"; };
    right  = { switch = "Meta+O";  window = "Meta+Ctrl+O"; };
  };
  # When positions share a screen (1 monitor), all their keys go to that one
  # action, center first; screens 0-2 that no position uses are left unbound.
  screenPositions = [ "center" "left" "right" ];
  screenIndices = lib.unique ([ 0 1 2 ] ++ map (p: screens.${p}) screenPositions);
  keysForScreen = kind: idx:
    lib.unique (map (p: screenKeys.${p}.${kind})
      (builtins.filter (p: screens.${p} == idx) screenPositions));
  screenShortcuts = lib.listToAttrs (lib.concatMap (idx: [
    { name = "Switch to Screen ${toString idx}"; value = keysForScreen "switch" idx; }
    { name = "Window to Screen ${toString idx}"; value = keysForScreen "window" idx; }
  ]) screenIndices);
in
{

  # todo: task switcher options for kwin; mouse follows focus?

  config.home.packages = [ pkgs.libnotify ];

  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];
  # Machine/feature modules tweak the shared layout through these.
  # Monitor layout modules (1-monitor-desktop.nix, 3-monitor-work-desktop.nix)
  # set the screens; the panel and window rules read them.
  options.personal_workplace.plasma = {
    screens = {
      center = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 0;
        description = "Plasma screen index of the center (main) monitor. The top panel goes here.";
      };
      left = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = config.personal_workplace.plasma.screens.center;
        defaultText = lib.literalExpression "config.personal_workplace.plasma.screens.center";
        description = "Plasma screen index of the left monitor (same as center on a single-screen machine).";
      };
      right = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = config.personal_workplace.plasma.screens.center;
        defaultText = lib.literalExpression "config.personal_workplace.plasma.screens.center";
        description = "Plasma screen index of the right monitor (same as center on a single-screen machine).";
      };
    };

    # (lists can't be patched across modules, so the panel is built from this)
    panel.extraWidgets = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [ ];
      description = "Widgets inserted after the panel spacer, before the system tray (e.g. the voxtype toggle from voxtype.nix).";
    };
  };


  config.programs = {
    plasma = {
      configFile = {
        "kwinrc" = {
          TabBox = {
            # 0 = Show windows from all screens (default)
            # 1 = Only windows on the current screen   ← what you want
            MultiScreenMode = 1;

            # Optional but commonly used together
            LayoutName = "thumbnail_grid";   # or "big_icons", "thumbnails", etc.
            HighlightWindows = true;
            ShowDesktopMode = 0;
          };
        };

        "plasmanotifyrc"."Notifications" = {
          PopupPosition = "BottomRight";
        };
      };

      enable = true;

      hotkeys.commands = {
        "reload-kwin-rules" = {
          name = "Reload KWin Window Rules";
          key = "Meta+Z";
          command = "qdbus org.kde.KWin /KWin reconfigure";
        };
      };

      input = {
        keyboard = {
          numlockOnStartup = "on";
          repeatDelay = 200;
        };
        # touchpads.*.tapToClick = false; todo 
      };

      krunner = {
        activateWhenTypingOnDesktop = false;
        position = "top";
        shortcuts.launch = "Meta+R";
      };

      kscreenlocker = {
        timeout = 10;
      };

      kwin.edgeBarrier = 0;

      overrideConfig = true;

      panels = [
        {
          height = 32;
          floating = false;
          location = "top";
          screen = screens.center;

          widgets = [
            "org.kde.plasma.panelspacer"
          ] ++ panelCfg.extraWidgets ++ [
            {
              systemTray = {
                icons = {
                  # optional
                  # scaleToFit = true;
                  # spacing = "medium"; # depending on plasma-manager version
                };
                items = {
                  shown = [
                    "org.kde.plasma.volume"
                    "org.kde.plasma.networkmanagement"
                    "org.kde.plasma.battery"
                  ];
                  hidden = [                    
                  "org.kde.plasma.clipboard"
                  "org.kde.plasma.brightness"
                  "org.kde.plasma.bluetooth"
                  "org.kde.plasma.notifications"
                  "org.kde.plasma.devicenotifier"
                  "org.kde.plasma.updates"
                  ];
                  # extra = [
                    #   "org.kde.plasma.notifications"
                    #   "org.kde.plasma.clipboard"
                    # ];
                };
              };
            }
            {
              digitalClock = {
                date.enable = true;
                time.format = "24h";
              };
            }
          ];
        }
      ];


      # todo: separate laptop and desktop specific stuff
      powerdevil = {
        AC = {
          autoSuspend.action = "nothing";
          powerButtonAction = "lockScreen";
          turnOffDisplay.idleTimeout = 600;
          whenLaptopLidClosed = "doNothing";
        };
        battery = {
          autoSuspend = {
            action = "sleep";
            idleTimeout = 600;
          };
          powerButtonAction = "lockScreen";
          turnOffDisplay.idleTimeout = 300;
          whenLaptopLidClosed = "lockScreen";
        };
      };

      # todo: setup desktops

      shortcuts = {

        ksmserver = {
          "LogOut" = ["Meta+L"];
          "Log Out" = ["Meta+Ctrl+L"]; # show logout screen
          "Reboot" = ["Meta+Ctrl+W"];
          "Shut Down" = ["Meta+Ctrl+F"];
        };

        kwin = {
          "Activate Window Demanding Attention"   = [];
          "ExposeClass"                           = [];  
          "ExposeClassCurrentDesktop"             = [];
          "Kill Window"                           = [];
          "Switch to Desktop 1"                   = [];
          "Switch to Next Desktop"                = [];
          "Switch to Next Screen"                 = [];
          "Switch to Previous Desktop"            = [];
          "Switch to Previous Screen"             = [];
          "Switch to Screen to the Left"          = [];
          "Switch to Screen to the Right"         = [];
          "Switch Window Down"                    = ["Meta+E"];
          "Switch Window Left"                    = ["Meta+S"];
          "Switch Window Right"                   = ["Meta+N"];
          "Switch Window Up"                      = ["Meta+I"];
          "Walk Through Windows"                  = ["Meta+Y"];
          "Walk Through Windows (Reverse)"        = [];
          #"Walk Through Windows Alternative"      = ["Meta+Y"];
          "Window Close"                          = ["Meta+F"];
          #"Window Fullscreen"                     = ["Meta+B"]; # annoying right now
          "Window Maximize"                       = ["Meta+C"];
          "Window Minimize"                       = ["Meta+U"];
          "Window No Border"                      = ["Meta+B"]; # less annoying than fullscreen
          "Window One Screen to the Left"         = ["Meta+Ctrl+Tab"];
          "Window One Screen to the Right"        = ["Meta+Ctrl+P"];
          "Window Quick Tile Bottom"              = ["Meta+Ctrl+E"];
          "Window Quick Tile Left"                = ["Meta+Ctrl+S"];
          "Window Quick Tile Right"               = ["Meta+Ctrl+N"];
          "Window Quick Tile Top"                 = ["Meta+Ctrl+I"];
        } // screenShortcuts; # + "Switch/Window to Screen N", built from personal_workplace.plasma.screens (see let)

        org_kde_powerdevil = {
          "Sleep" = ["Meta+Ctrl+D"];
        };

        # plasmashell = {
          #   "Activate Application Launcher" = [ "Meta+R" ];
          # };
      };


      #windows.allowWindowsToRememberPositions = true;

      workspace = {
        colorScheme = "BreezeDark";
        lookAndFeel = "org.kde.breezedark.desktop";
        theme = "breeze-dark";
        #wallpaperPlainColor = "0,0,0"; # solid black
      };
    };
  };  
}
