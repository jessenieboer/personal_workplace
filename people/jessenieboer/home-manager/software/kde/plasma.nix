{ inputs, pkgs, ... }: {

  # todo: task switcher options for kwin; mouse follows focus?

  home.packages = [ pkgs.libnotify ];

  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  programs = {
    plasma = {
      configFile."kwinrc" = {
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

      enable = true;

      hotkeys.commands = {
        "reload-kwin-rules" = {
          name = "Reload KWin Window Rules";
          key = "Meta+Z";
          command = "qdbus org.kde.KWin /KWin reconfigure";
        };
        "voxtype-toggle" = {
          name = "Voxtype Toggle";
          key = "F2";
          command = "voxtype-record-with-project-prompt";
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
          location = "top";       # change to "bottom" if you prefer
          height = 32;
          floating = false;

          widgets = [
            {
              digitalClock = {
                date.enable = true;
                time.format = "24h";
              };
            }

            "org.eversole.voxtype-toggle"
            "org.kde.plasma.systemtray"
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
          "Switch to Screen 0"                    = ["Meta+O"];
          "Switch to Screen 1"                    = ["Meta+F7"];
          "Switch to Screen 2"                    = ["Meta+H"];
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
          "Window to Screen 0"                    = ["Meta+Ctrl+O"];
          "Window to Screen 1"                    = ["Meta+Ctrl+F7"];
          "Window to Screen 2"                    = ["Meta+Ctrl+H"];
          "Window Quick Tile Bottom"              = ["Meta+Ctrl+E"];
          "Window Quick Tile Left"                = ["Meta+Ctrl+S"];
          "Window Quick Tile Right"               = ["Meta+Ctrl+N"];
          "Window Quick Tile Top"                 = ["Meta+Ctrl+I"];
        };

        org_kde_powerdevil = {
          "Sleep" = ["Meta+Ctrl+D"];
        };

        # plasmashell = {
          #   "Activate Application Launcher" = [ "Meta+R" ];
          # };
      };

      shortcutSchemes = {
        dolphin.Custom = {
          "rename_file" = [ ]; # disable F2 so i can use it for voice toggle
          # Some versions use this name instead:
          # "edit_rename" = [ ];
        };
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
