{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };

  # No skills yet; add them under extra.
  practicesTasks = tt.practices {
    name = "rust";
  };
in
{
  config = {
    enterShell = ''
      ${tt.announce "rust"}
    '';

    env.RUST_BACKTRACE = "1";

    # The default channel is the nixpkgs toolchain, with cargo, rustc, clippy,
    # rustfmt and rust-analyzer.
    languages.rust.enable = true;

    tasks = practicesTasks
      // tt.gitSettings "rust" ./settings
      // tt.seed {
        name = "rust"; task = "copy_cargo_toml_template";
        src = ./templates/Cargo.toml; dest = "Cargo.toml";
      };
  };
}
