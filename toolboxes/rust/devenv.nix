{ config, pkgs, ... }:
let
  gitignore = ./settings/.gitignore;
  cargoTomlTemplate = ./templates/Cargo.toml;
  root = config.devenv.root;
  gitignoreDest = "${root}/.toolboxes/rust_toolbox/.gitignore";
  cargoTomlDest = "${root}/Cargo.toml";
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "rust toolbox available"
        echo "rustc version: $(rustc --version)"
        echo "cargo version: $(cargo --version)"
      fi
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
        description = "Refresh the rust_toolbox gitignore fragment from the toolbox";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${gitignoreDest}" ] && cmp -s ${gitignore} "${gitignoreDest}"
        '';
        exec = ''
          install -D -m 0644 ${gitignore} "${gitignoreDest}"
        '';
      };

      "rust_toolbox:copy_cargo_toml_template" = {
        description = "Seed Cargo.toml once from the toolbox template";
        before = [ "devenv:enterShell" ];
        status = ''
          test -f "${cargoTomlDest}"
        '';
        exec = ''
          install -D -m 0644 ${cargoTomlTemplate} "${cargoTomlDest}"
        '';
      };
    };
  };
}
