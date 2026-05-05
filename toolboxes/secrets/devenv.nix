{ pkgs, lib, config, inputs, ... }:
let
  envrc_config = ./configs/.envrc;
  gh_devenv_script = ./programs/gh_devenv.sh;
  secretspecTemplate = ./templates/secretspec.toml;
in
{
  config = {
    enterShell = ''
      # get bws token from pass
      export BWS_ACCESS_TOKEN=$(pass show ${config.secrets_toolbox.mat_name_in_pass} 2>/dev/null | head -n1)

      if [ -z "$BWS_ACCESS_TOKEN" ]; then
      echo "  Failed to retrieve BWS access token from pass."
      echo "  Make sure the token is stored at: $PASS_NAME"
      echo "  Run: pass show $PASS_NAME"
      exit 1
      fi

      echo "Successfully loaded BWS machine access token from pass"
      echo "jessenieboer's secrets toolbox available"
    '';

    env = {
      PERSONAL_WORKPLACE_TEST = config.secretspec.secrets.PERSONAL_WORKPLACE_TEST or "secret not found";
    };

    files = {
      "gh_devenv.sh".source = ./programs/gh_devenv.sh;
    };

    languages.rust = {
      enable = true;
      channel = "stable";
      version = "1.95.0";
      components = [ "cargo" "rustc" "clippy" "rustfmt" "rust-src" "rust-analyzer" ];
      #targets = [ "wasm32-unknown-unknown" ];  # if needed
    };

    packages = with pkgs; [
      (pkgs.rustPlatform.buildRustPackage {
        pname = "secretspec";
        version = "v0.8.2";  # or pin to a specific commit/tag

        src = pkgs.fetchFromGitHub {
          owner = "cachix";
          repo = "secretspec";
          rev = "ccc50db26efc47f8eb3c4fe73c44bf0c66f890b9";
          hash = "sha256-0aGv1ZUMEVAk3cNvwZHMNwgKoasVTffJ8xOMclNyAMw=";
        };

        cargoHash = "sha256-XqDWUQ9hzptNfGtTUftaokuuBsgMbE4HwiIZRQNp/C4=";
        cargoBuildFlags = [ "--package" "secretspec" "--features" "bws" ];
        #buildFeatures = [ "bws" ];

        # Optional: native build inputs if needed
        nativeBuildInputs = [ pkg-config ];
        buildInputs = [ dbus openssl ];  # often needed for Rust crates

        meta = {
          mainProgram = "secretspec";
        };
      })
      gnupg
      pass
    ];

    secrets_toolbox.mat_name_in_pass = "bws/nucbox_access_token";

    # note that .envrc must be writable to work properly with the emacs envrc package
    tasks = {
      "secrets_toolbox:copy_envrc" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ -f "${config.devenv.root}/.envrc" ]; then
          echo ".envrc already exists — skipping copy."
          exit 0
          fi
          cp ${envrc_config} ${config.devenv.root}/.envrc
          chmod u+w ${config.devenv.root}/.envrc

          echo "copied envrc config to .envrc
        '';
        showOutput = true;
      };
      "secrets_toolbox:copy_secretspec_template" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ -f "${config.devenv.root}/secretspec.toml" ]; then
          echo "secretspec.toml already exists — skipping copy."
          exit 0
          fi
          cp ${secretspecTemplate} ${config.devenv.root}/secretspec.toml
          chmod u+w ${config.devenv.root}/secretspec.toml

          echo "copied secretspec template to secretspec.toml
        '';
        showOutput = true;
      };
    };
  };

  options = {
    secrets_toolbox = {
      mat_name_in_pass = lib.mkOption {
        description = "The name of the bws machine access token that lives in the local pass store";
        example = "bws/my_token_name";
        type = lib.types.str;
      };
    };
  };
}
