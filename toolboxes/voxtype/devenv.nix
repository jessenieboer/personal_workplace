{ pkgs, lib, config, ... }:

{
  options.voxtype_toolbox = {
    initial_prompt = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Initial prompt passed to Whisper for vocabulary hints.
        Often a comma-separated list of project-specific terms.
      '';
      example = "Jesse Nieboer, Voxtype, NixOS, devenv";
    };

    post_process_prompt = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Instructions for Voxtype post-processing (Ollama cleanup prompt).
      '';
      example = ''
        You are a careful text corrector for a user dictating text by voice.
        Fix grammar and speech-to-text errors.
        Output ONLY the corrected text.
      '';
    };
  };


  config = {
    enterShell = ''
      echo "voxtype toolbox available"
    '';

    tasks = {
      "voxtype_toolbox:generate_initial_prompt" = {
        before = [ "devenv:enterShell" ];
        showOutput = true;
        exec = ''
          set -euo pipefail
          dir="${config.devenv.root}/.toolboxes/voxtype_toolbox"
          mkdir -p "$dir"

          # Only write when the project set a prompt
          if [ -n ${lib.escapeShellArg config.voxtype_toolbox.initial_prompt} ]; then
          printf '%s\n' ${lib.escapeShellArg config.voxtype_toolbox.initial_prompt} \
          > "$dir/initial_prompt.txt"
          echo "wrote $dir/initial_prompt.txt"
          else
          echo "voxtype_toolbox.initial_prompt is empty; skipped initial_prompt.txt"
          fi
        '';
      };
      "voxtype_toolbox:generate_post_process_prompt" = {
        before = [ "devenv:enterShell" ];
        showOutput = true;
        exec = ''
          set -euo pipefail
          dir="${config.devenv.root}/.toolboxes/voxtype_toolbox"
          mkdir -p "$dir"

          # Only write when the project sets a prompt
          if [ -n ${lib.escapeShellArg config.voxtype_toolbox.post_process_prompt} ]; then
          printf '%s\n' ${lib.escapeShellArg config.voxtype_toolbox.post_process_prompt} \
          > "$dir/post_process_prompt.txt"
          echo "wrote $dir/post_process_prompt.txt"
          else
          echo "voxtype_toolbox.post_process_prompt is empty; skipped post_process_prompt.txt"
          fi
        '';
      };
    };

    # voxtype_toolbox = {
    #   initial_prompt = "test";
    #   post_process_prompt = "test2";
    # };
  };
}
