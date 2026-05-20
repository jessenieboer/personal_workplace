{ pkgs, lib, config, inputs, ... }:
let
  gh_devenv = ./programs/gh_devenv.sh;
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

    tasks = {
      "secrets_toolbox:copy_github_devenv" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ -f "${config.devenv.root}/toolboxes/secrets_toolbox/gh_devenv.sh" ]; then
          echo "gh_devenv.sh already exists — skipping copy."
          exit 0
          fi
          mkdir -p ${config.devenv.root}/toolboxes/secrets_toolbox
          cp ${gh_devenv} ${config.devenv.root}/toolboxes/secrets_toolbox/gh_devenv.sh
          chmod u+w ${config.devenv.root}/toolboxes/secrets_toolbox/gh_devenv.sh

          echo "copied github devenv program to toolboxes/secrets_toolbox/gh_devenv.sh"
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

          echo "copied secretspec template to secretspec.toml"
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
