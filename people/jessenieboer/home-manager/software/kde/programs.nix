{ inputs, pkgs, ... }: {
  
  programs = {
    konsole = {
      defaultProfile = "jessenieboer";
      enable = true;

      profiles = {
        "jessenieboer" = {
          font.name = "Hack";
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
