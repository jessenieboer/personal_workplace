{ config, inputs, pkgs, ... }:
let
  explainer = ./settings/agents/code-explainer.md;
  gitignore = ./settings/.gitignore;
  opencodeConfig = ./settings/opencode/opencode.json;

  atomic = inputs.atomic;
  howSkill = "${atomic}/packages/workflows/skills/how";

  root = config.devenv.root;
  ecaDir = "${root}/.eca";
  howDest = "${ecaDir}/skills/how";
  explainerDest = "${ecaDir}/agents/code-explainer.md";
  gitignoreDest = "${root}/.toolboxes/code_toolbox/.gitignore";
  opencodeDest = "${root}/.opencode/opencode.json";
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "code toolbox available"
        echo "opencode: $(command -v opencode)"
      fi
    '';

    packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
    ];

    tasks = {
      "code_toolbox:copy_gitignore" = {
        description = "Refresh the code_toolbox gitignore fragment from the toolbox";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${gitignoreDest}" ] && cmp -s ${gitignore} "${gitignoreDest}"
        '';
        exec = ''
          install -D -m 0644 ${gitignore} "${gitignoreDest}"
        '';
      };

      "code_toolbox:copy_opencode_config" = {
        description = "Seed .opencode/opencode.json once from the toolbox template";
        before = [ "devenv:enterShell" ];
        status = ''
          test -f "${opencodeDest}"
        '';
        exec = ''
          install -D -m 0644 ${opencodeConfig} "${opencodeDest}"
        '';
      };

      "code_toolbox:copy_setup_files" = {
        description = "Refresh the code-explainer agent";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${ecaDir}/config.json" ] \
            && [ -f "${explainerDest}" ] \
            && cmp -s ${explainer} "${explainerDest}"
        '';
        exec = ''
          mkdir -p "${ecaDir}/agents" "${ecaDir}/rules" "${ecaDir}/skills"
          install -D -m 0644 ${explainer} "${explainerDest}"
        '';
      };

      "code_toolbox:copy_skills" = {
        description = "Refresh the Atomic how skill under .eca/skills";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -d "${howDest}" ] \
            && cmp -s ${howSkill}/SKILL.md "${howDest}/SKILL.md" \
            && diff -rq --exclude LICENSE.txt ${howSkill} "${howDest}" >/dev/null
        '';
        exec = ''
          rm -rf "${howDest}"
          mkdir -p "${howDest}"
          cp -a ${howSkill}/. "${howDest}/"
          find "${howDest}" -type f -exec chmod 0444 {} +
        '';
      };
    };
  };
}
