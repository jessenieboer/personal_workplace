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
      if [ -t 1 ]; then
        echo "voxtype toolbox available"
      fi
    '';

    tasks = {
      "voxtype_toolbox:generate_initial_prompt" = {
        description = "Write initial_prompt.txt when the project set a prompt";
        before = [ "devenv:enterShell" ];
        status = ''
          dest="${config.devenv.root}/.toolboxes/voxtype_toolbox/initial_prompt.txt"
          if [ -z ${lib.escapeShellArg config.voxtype_toolbox.initial_prompt} ]; then
            exit 0
          fi
          [ -f "$dest" ] && cmp -s "$dest" <(printf '%s\n' ${lib.escapeShellArg config.voxtype_toolbox.initial_prompt})
        '';
        exec = ''
          set -euo pipefail
          dir="${config.devenv.root}/.toolboxes/voxtype_toolbox"
          mkdir -p "$dir"
          printf '%s\n' ${lib.escapeShellArg config.voxtype_toolbox.initial_prompt} \
            > "$dir/initial_prompt.txt"
        '';
      };

      "voxtype_toolbox:generate_post_process_prompt" = {
        description = "Write post_process_prompt.txt when the project set a prompt";
        before = [ "devenv:enterShell" ];
        status = ''
          dest="${config.devenv.root}/.toolboxes/voxtype_toolbox/post_process_prompt.txt"
          if [ -z ${lib.escapeShellArg config.voxtype_toolbox.post_process_prompt} ]; then
            exit 0
          fi
          [ -f "$dest" ] && cmp -s "$dest" <(printf '%s\n' ${lib.escapeShellArg config.voxtype_toolbox.post_process_prompt})
        '';
        exec = ''
          set -euo pipefail
          dir="${config.devenv.root}/.toolboxes/voxtype_toolbox"
          mkdir -p "$dir"
          printf '%s\n' ${lib.escapeShellArg config.voxtype_toolbox.post_process_prompt} \
            > "$dir/post_process_prompt.txt"
        '';
      };
    };
  };
}
