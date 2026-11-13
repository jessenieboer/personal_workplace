{ config, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
in
{
  config = {
    enterShell = ''
      ${tt.announce "grok_bot"}
    '';

    # templates/grok_bot.org tracks the toolbox template (overwritten whenever
    # it changes, read-only); grok_bots.org is the consumer's copy, seeded once.
    tasks = tt.refresh {
      name = "grok_bot";
      task = "refresh_bot_template";
      src = ./templates/grok_bots_template.org;
      dest = ".toolboxes/grok_bot_toolbox/templates/grok_bots.org";
      mode = "444";
      description = "Keep .toolboxes/grok_bot_toolbox/templates/grok_bots.org identical to the toolbox template";
    }
    // tt.seed {
      name = "grok_bot";
      task = "seed_grok_bots_org";
      src = ./templates/grok_bots_template.org;
      dest = ".toolboxes/grok_bot_toolbox/grok_bots.org";
      description = "Seed an editable grok_bots.org once from the bot template";
    }
    // tt.practices {
      name = "grok_bot";
      local = ./practices;
    };
  };
}
