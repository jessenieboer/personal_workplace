{ config, inputs, lib, pkgs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };

  cek = inputs.neolabhq-cek;

  cekSkillRels = [
    # create
    #"plugins/customaize-agent/skills/create-agent"
    #"plugins/customaize-agent/skills/create-command"
    #"plugins/customaize-agent/skills/create-hook"
    "plugins/customaize-agent/skills/create-skill"
    "plugins/customaize-agent/skills/create-rule"
    #"plugins/customaize-agent/skills/create-workflow-command"
    "plugins/customaize-agent/skills/prompt-engineering"
    "plugins/customaize-agent/skills/context-engineering"
    "plugins/customaize-agent/skills/apply-anthropic-skill-best-practices"
    # improve
    "plugins/reflexion/skills/reflect"
    "plugins/reflexion/skills/critique"
    "plugins/reflexion/skills/memorize"
    # evaluate
    "plugins/customaize-agent/skills/agent-evaluation"
    "plugins/customaize-agent/skills/test-skill"
    "plugins/customaize-agent/skills/test-prompt"
    #"plugins/customaize-agent/skills/thought-based-reasoning"
  ];

  # Local practices plus each CEK skill (with the CEK license beside it).
  practicesTasks = tt.practices {
    name = "ai";
    local = ./practices;
    extra = lib.listToAttrs (lib.concatMap (rel: [
      (lib.nameValuePair "skills/${baseNameOf rel}" "${cek}/${rel}")
      (lib.nameValuePair "skills/${baseNameOf rel}/LICENSE" "${cek}/LICENSE")
    ]) cekSkillRels);
  };
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "ai toolbox available"
      fi
    '';

    tasks = practicesTasks
      // tt.gitignore "ai" ./settings/.gitignore
      // tt.seed {
        name = "ai"; task = "copy_setup_files"; src = ./settings/eca/config.json;
        dest = ".eca/config.json"; description = "Seed ECA config once";
        postExec = ''mkdir -p "$(dirname "$dest")/rules"'';
      };
  };
}
