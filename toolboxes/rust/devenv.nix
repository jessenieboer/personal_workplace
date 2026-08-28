{ config, pkgs, ... }:
let
  gitignore = ./settings/.gitignore;
  cargoTomlTemplate = ./templates/Cargo.toml;
in
{
  config = {
    enterShell = ''
      echo "rust toolbox available"
      echo "rustc version: $(rustc --version)"
      echo "cargo version: $(cargo --version)"
    '';

    env = {
      RUST_BACKTRACE = "1";
    };

    languages.rust = {
      enable = true;
      channel = "stable";
      version = "latest";
      components = [
        "rustc"
        "cargo"
        "clippy"
        "rustfmt"
        "rust-analyzer"
      ];
    };

    tasks = {
      "rust_toolbox:copy_gitignore" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          mkdir -p "${config.devenv.root}/.toolboxes/rust_toolbox"
          cp -f ${gitignore} "${config.devenv.root}/.toolboxes/rust_toolbox/.gitignore"
          echo "copied rust_toolbox .gitignore"
        '';
        showOutput = true;
      };
      "rust_toolbox:copy_cargo_toml_template" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ -f "${config.devenv.root}/Cargo.toml" ]; then
          echo "Cargo.toml already exists — skipping copy."
          exit 0
          fi
          cp ${cargoTomlTemplate} ${config.devenv.root}/Cargo.toml
          chmod u+w ${config.devenv.root}/Cargo.toml

          echo "copied templates/Cargo.toml to Cargo.toml"
        '';
        showOutput = true;
      };
    };
  };
}
