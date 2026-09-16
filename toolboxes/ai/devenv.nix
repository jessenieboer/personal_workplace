{ config, inputs, lib, pkgs, ... }:
let
  aiInputEngineer = ./settings/agents/ai-input-engineer.md;
  ecaConfig = ./settings/eca/config.json;
  gitignore = ./settings/.gitignore;
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
    install -D -m 0644 ${cek}/${rel}/SKILL.md "$ECA_DIR/skills/${baseNameOf rel}/SKILL.md"
    install -D -m 0644 ${cekLicense} "$ECA_DIR/skills/${baseNameOf rel}/LICENSE"
  '';

  root = config.devenv.root;
  ecaDir = "${root}/.eca";
  gitignoreDest = "${root}/.toolboxes/ai_toolbox/.gitignore";
  agentDest = "${ecaDir}/agents/ai-input-engineer.md";
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "ai toolbox available"
      fi
    '';

    tasks = {
      "ai_toolbox:copy_gitignore" = {
        description = "Refresh the ai_toolbox gitignore fragment from the toolbox";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${gitignoreDest}" ] && cmp -s ${gitignore} "${gitignoreDest}"
        '';
        exec = ''
          install -D -m 0644 ${gitignore} "${gitignoreDest}"
        '';
      };

      "ai_toolbox:copy_setup_files" = {
        description = "Seed ECA config once; refresh the input-engineer agent";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${ecaDir}/config.json" ] \
            && [ -f "${agentDest}" ] \
            && cmp -s ${aiInputEngineer} "${agentDest}"
        '';
        exec = ''
          mkdir -p "${ecaDir}/agents" "${ecaDir}/rules" "${ecaDir}/skills"
          install -D -m 0644 ${aiInputEngineer} "${agentDest}"

          if [ ! -f "${ecaDir}/config.json" ]; then
            install -D -m 0644 ${ecaConfig} "${ecaDir}/config.json"
          fi
        '';
      };

      "ai_toolbox:copy_skills" = {
        description = "Refresh CEK and local skills under .eca/skills";
        before = [ "devenv:enterShell" ];
        status = ''
          same() { [ -f "$2" ] && cmp -s "$1" "$2"; }
          ${lib.concatMapStringsSep "\n" (rel: ''
            same ${cek}/${rel}/SKILL.md "${ecaDir}/skills/${baseNameOf rel}/SKILL.md" || exit 1
            same ${cekLicense} "${ecaDir}/skills/${baseNameOf rel}/LICENSE" || exit 1
          '') cekSkillRels}
          if [ -d ${localSkills} ]; then
            for d in ${localSkills}/*; do
              [ -d "$d" ] || continue
              [ -f "$d/SKILL.md" ] || continue
              same "$d/SKILL.md" "${ecaDir}/skills/$(basename "$d")/SKILL.md" || exit 1
            done
          fi
        '';
        exec = ''
          ECA_DIR="${ecaDir}"
          mkdir -p "$ECA_DIR/skills"
          ${lib.concatMapStringsSep "\n" copyCekSkill cekSkillRels}
          if [ -d ${localSkills} ]; then
            for d in ${localSkills}/*; do
              [ -d "$d" ] || continue
              name=$(basename "$d")
              if [ -f "$d/SKILL.md" ]; then
                install -D -m 0644 "$d/SKILL.md" "$ECA_DIR/skills/$name/SKILL.md"
              fi
            done
          fi
        '';
      };
    };
  };
}
