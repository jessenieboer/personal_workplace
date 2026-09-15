{ config, inputs, lib, pkgs, ... }:
let
  aiInputEngineer = ./settings/agents/ai-input-engineer.md;
  ecaConfig = ./settings/eca/config.json;
  gitignore = ./settings/.gitignore;
  opencodeConfig = ./settings/opencode/opencode.json;
  localSkills = ./settings/skills;

  cek = inputs.neolabhq-cek;
  cekLicense = "${cek}/LICENSE";

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

  copyCekSkill = rel: ''
    install -D ${cek}/${rel}/SKILL.md "$ECA_DIR/skills/${baseNameOf rel}/SKILL.md"
    install -D ${cekLicense} "$ECA_DIR/skills/${baseNameOf rel}/LICENSE"
  '';
in
{
  config = {
    enterShell = ''
    if [ -t 1 ]; then
      echo "ai toolbox available"
    fi
    '';

    packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
    ];

    tasks = {
      "ai_toolbox:copy_gitignore" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          mkdir -p "${config.devenv.root}/.toolboxes/ai_toolbox"
          install -D ${gitignore} "${config.devenv.root}/.toolboxes/ai_toolbox/.gitignore"
          echo "copied ai_toolbox .gitignore"
        '';
        showOutput = true;
      };

      "ai_toolbox:copy_setup_files" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          TOOLBOX_DIR="${config.devenv.root}/.toolboxes/ai_toolbox"

          ECA_DIR="${config.devenv.root}/.eca"
          mkdir -p "$ECA_DIR/agents" "$ECA_DIR/rules" "$ECA_DIR/skills"
          if [ -f ${aiInputEngineer} ]; then
             install -D ${aiInputEngineer} "$ECA_DIR/agents/ai-input-engineer.md"
          fi

          if [ -f "$ECA_DIR/config.json" ]; then
            echo "$ECA_DIR/config.json already exists — skipping copy."
          else
            install -D ${ecaConfig} "$ECA_DIR/config.json"
          fi

          OPENCODE_DIR="${config.devenv.root}/.opencode"
          mkdir -p "$OPENCODE_DIR"
          if [ -f "$OPENCODE_DIR/opencode.json" ]; then
            echo "$OPENCODE_DIR/opencode.json already exists — skipping copy."
          else
            install -D ${opencodeConfig} "$OPENCODE_DIR/opencode.json"
          fi

          echo "ai_toolbox set up successfully"
        '';
        showOutput = true;
      };

      "ai_toolbox:copy_skills" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          ECA_DIR="${config.devenv.root}/.eca"
          mkdir -p "$ECA_DIR/skills"

          ${lib.concatMapStringsSep "\n" copyCekSkill cekSkillRels}

          if [ -d ${localSkills} ]; then
            for d in ${localSkills}/*; do
              [ -d "$d" ] || continue
              name=$(basename "$d")
              if [ -f "$d/SKILL.md" ]; then
                install -D "$d/SKILL.md" "$ECA_DIR/skills/$name/SKILL.md"
              fi
            done
          fi

          echo "ai toolbox CEK skills copied to $ECA_DIR/skills"
        '';
        showOutput = true;
      };
    };
  };
}
