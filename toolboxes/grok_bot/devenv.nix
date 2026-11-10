{ config, pkgs, lib, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
  q = lib.escapeShellArg;
  # used so journeyman can write skills
  skillSrc = "${inputs.mattpocock-skills}/skills/productivity/writing-for-agents";
  skillDest = "${config.devenv.root}/.toolboxes/grok_bot_toolbox/skills/writing-for-agents";
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
    # Upstream skill, kept identical to the pinned copy; files are read-only.
    // {
      "grok_bot_toolbox:refresh_writing_for_agents" = {
        description = "Refresh .toolboxes/grok_bot_toolbox/skills/writing-for-agents from mattpocock/skills";
        before = [ "devenv:enterShell" ];
        status = ''
          diff -r ${q skillSrc} ${q skillDest} >/dev/null 2>&1
        '';
        exec = ''
          rm -rf ${q skillDest}
          mkdir -p "$(dirname ${q skillDest})"
          cp -rL --no-preserve=mode ${q skillSrc} ${q skillDest}
          find ${q skillDest} -type f -exec chmod 444 {} +
        '';
      };
    };
  };
}
