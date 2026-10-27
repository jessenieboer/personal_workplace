{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
in
{
  config = {
    enterShell = ''
      ${tt.announce "rust"}
      if [ -t 1 ]; then
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

    tasks = tt.gitignore "rust" ./settings/.gitignore
      // tt.seed {
        name = "rust"; task = "copy_cargo_toml_template";
        src = ./templates/Cargo.toml; dest = "Cargo.toml";
      };
  };
}
