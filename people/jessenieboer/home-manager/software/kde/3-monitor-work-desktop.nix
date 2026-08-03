# todo: plasma manager + window rules don't work great together yet
{ inputs, pkgs, ... }: {

  programs = {
    plasma = {
      window-rules = [
        # screen on left (1)
        {
          apply = {
            screen = { apply = "force"; value = 1; };
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

        # {
        #   apply = {
        #     screen = { apply = "force"; value = 1; };
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
            screen = { apply = "force"; value = 1; };
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
            screen = { apply = "force"; value = 1; };
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

        # screen in center (2)
        {
          apply = {
            screen = { apply = "force"; value = 2; };
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
            screen = { apply = "force"; value = 2; };
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

        # screen on right (0)
        {
          apply = {
            screen = { apply = "force"; value = 0; };
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
      ];
    };
  };
}
