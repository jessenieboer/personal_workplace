{ inputs, pkgs, ... }:
let
  voxtypeProjectCorrect = pkgs.writeShellApplication {
    name = "voxtype-project-correct";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      findutils
      gnugrep
      gnused
      jq
      ollama
      kdotool
    ];
    text = builtins.readFile ./voxtype_project_correct.sh;
  };
  voxtypeRecordWithProjectPrompt = pkgs.writeShellApplication {
    name = "voxtype-record-with-project-prompt";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      gnused
      kdotool
    ];
    text = builtins.readFile ./voxtype_record_with_project_prompt.sh;
  };
in
{
  imports = [
    inputs.voxtype.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    curl
    dotool
    #inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.osd-gtk4
    jq
    kdotool
    voxtypeRecordWithProjectPrompt
  ];

  programs.voxtype = {
    enable = true;
    package = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.vulkan;

    # Whisper model
    model.name = "large-v3-turbo"; # base.en, small.en, medium.en

    service.enable = true;  

    settings = {
      hotkey.enabled = false;
      output = {
        fallback_to_clipboard = true;
        driver_order = ["dotool" "wtype" "clipboard" ]; # note that dotool requires user be in the "input" group
        mode = "type";
        notification = {
          on_recording_start = false;
          on_recording_stop = false;
          on_transcription = false;
        };
        # osd = {
        #   frontend = "gtk4";
        # };
        pre_type_delay_ms = 150;
        # post_process = {
        #   command = "${voxtypeProjectCorrect}/bin/voxtype-project-correct";
        #   timeout_ms = 30000;   # Ollama can be slow; give it time
        # };
        type_delay_ms = 5;
      };

      status.icon_theme = "nerd-font";

      text = {
        spoken_punctuation = false;
        replacements = {
          "box type" = "voxtype";
          "nix os" = "NixOS";
          # add your own common mis-hearings
        };
      };

      vad.enabled = false;

      whisper = {
        language = "en";
        translate = false;
        on_demand_loading = false;
      };
    };
  };

  xdg.dataFile."plasma/plasmoids/org.eversole.voxtype-toggle" = {
    source = ./voxtype-toggle-plasmoid; # vendored, upstream repo is gone; see VENDORED.md
  };

  # Plasma bits that only make sense where voxtype runs (nucbox: it needs the GPU).
  personal_workplace.plasma.panel.extraWidgets = [ "org.eversole.voxtype-toggle" ];

  programs.plasma = {
    hotkeys.commands."voxtype-toggle" = {
      name = "Voxtype Toggle";
      key = "F2";
      command = "voxtype-record-with-project-prompt";
    };

    shortcutSchemes.dolphin.Custom = {
      "rename_file" = [ ]; # disable F2 so i can use it for voice toggle
      # Some versions use this name instead:
      # "edit_rename" = [ ];
    };
  };
}
