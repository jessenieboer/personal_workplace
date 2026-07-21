{ inputs, pkgs, ... }: {
  
  programs = {
    konsole = {
      defaultProfile = "jessenieboer";
      enable = true;

      profiles = {
        "jessenieboer" = {
          name = "jessenieboer";
          extraConfig = {
            "Mouse.Misc" = {
              AllowClicksAndDrags = false; #prevent mouse reporting from dumping text into konsole
            };
          };
        };
      };
    };
  };  
}

