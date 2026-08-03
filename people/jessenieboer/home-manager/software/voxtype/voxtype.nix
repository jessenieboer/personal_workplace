{ inputs, pkgs, ... }:
{
  imports = [
    inputs.voxtype.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    dotool
    inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.osd-gtk4
    vulkan-loader
    vulkan-tools
  ];

  programs.voxtype = {
    enable = true;
    package = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.vulkan;

    # Whisper model
    model.name = "base.en"; # small.en, medium.en, large-v3-turbo

    service.enable = true;  

    settings = {
      hotkey.enabled = false;  # recommended on Plasma — use compositor/custom shortcuts instead
      output = {
        fallback_to_clipboard = true;
        driver_order = ["dotool" "wtype" "clipboard" ]; # note that dotool requires user be in the "input" group
        mode = "type";
        osd = {
          frontend = "gtk4";
        };
        # type_delay_ms = 0;
        # pre_type_delay_ms = 100;     # sometimes helps on Plasma
        # post_process = {
          # }
      };

      text = {
        spoken_punctuation = true;     # "period" → .
        replacements = {
          "box type" = "voxtype";
          "nix os" = "NixOS";
          # add your own common mis-hearings
        };
      };

      vad.enabled = false;

      whisper = {
        #initial_prompt =
          language = "en";
          translate = false;
          on_demand_loading = false;
      };
    };
  };
}
