{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
in
{
  config = {
    enterShell = ''
      ${tt.announce "grok_bot"}
    '';

    # Seed a placeholder so Git can keep an empty bots directory.
    # seed copies only when the dest file is missing, so consumer bot files stay.
    tasks = tt.seed {
      name = "grok_bot";
      task = "seed_bots_dir";
      src = ./templates/bots/.gitkeep;
      dest = ".toolboxes/grok_bot_toolbox/bots/.gitkeep";
      description = "Seed .toolboxes/grok_bot_toolbox/bots once for source-controlled bot files";
    }
    // tt.seed {
      name = "grok_bot";
      task = "seed_bot_template";
      src = ./templates/grok_bots_template.org;
      dest = ".toolboxes/grok_bot_toolbox/templates/grok_bot_template.org";
      description = "Seed an editable bot template once; it tangles to <bot-name>.json beside itself";
    }
    // tt.seed {
      name = "grok_bot";
      task = "seed_grok_bots_org";
      src = ./templates/grok_bots_template.org;
      dest = ".toolboxes/grok_bot_toolbox/grok_bots.org";
      description = "Seed an editable grok_bots.org once from the bot template";
    }
    // tt.gitSettings "grok_bot" ./settings;
  };
}
