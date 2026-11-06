{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
in
{
  config = {
    enterShell = ''
      ${tt.announce "grok_bot"}
    '';

    # Seed a placeholder so Git can keep an empty practices/_bots directory.
    # seed copies only when the dest file is missing, so consumer bot files stay.
    tasks = tt.seed {
      name = "grok_bot";
      task = "seed_bots_dir";
      src = ./templates/_bots/.gitkeep;
      dest = ".toolboxes/grok_bot_toolbox/practices/_bots/.gitkeep";
      description = "Seed .toolboxes/grok_bot_toolbox/practices/_bots once for source-controlled bot files";
    }
    // tt.gitSettings "grok_bot" ./settings;
  };
}
