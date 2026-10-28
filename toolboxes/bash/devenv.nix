{ config, pkgs, lib, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };

  # sickn33/agentic-awesome-skills, pinned. Bump rev and the hashes together.
  rev = "e9809578fd426a284af017c5db99f8eb6628e6ca";
  raw = path: hash: pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/sickn33/agentic-awesome-skills/${rev}/${path}";
    inherit hash;
  };

  # Skill text is CC BY 4.0 (LICENSE-CONTENT); code is MIT (LICENSE).
  # Each skill folder gets both notices for attribution.
  license = raw "LICENSE" "sha256-r5g3Cn7cDwDsRpedBJUXgzyaf6K6dOPPjMQvfbVXKZ0=";
  licenseContent = raw "LICENSE-CONTENT" "sha256-3q4H7OUi+8plqzPwwYypYwsQd6jz8jPAr0RSNbP7b88=";

  # skill name -> { file within the skill folder -> hash }
  skills = {
    bash-defensive-patterns = {
      "SKILL.md" = "sha256-7SoJbrbwjUjtDX6foArn6dSrewf5V1cQRTtSfrURd8g=";
      "resources/implementation-playbook.md" = "sha256-aDMBfodiR+0dLwKIVo2TESARRZg3OBgaoSRegcaSFqg=";
    };
    bash-linux."SKILL.md" = "sha256-9TM18klUpj768rGUUn6f4QYqw4yLzjTfxyhOEKAlnaY=";
    bash-pro."SKILL.md" = "sha256-BrSEe+dfq9QRmAi4KhvO/1CyfiQssuQC6bZdcTwFZoU=";
    bash-scripting."SKILL.md" = "sha256-7tFHHvSBm+ZloFGZvocRunqSztT6c6mkSfdE3c/Zx9A=";
  };

  extra = lib.concatMapAttrs (skill: files:
    lib.mapAttrs' (file: hash:
      lib.nameValuePair "skills/${skill}/${file}" (raw "skills/${skill}/${file}" hash)) files
    // {
      "skills/${skill}/LICENSE" = license;
      "skills/${skill}/LICENSE-CONTENT" = licenseContent;
    }) skills;
in
{
  config = {
    # The skills lint with ShellCheck, format with shfmt, and test with Bats.
    packages = [ pkgs.shellcheck pkgs.shfmt pkgs.bats ];

    enterShell = ''
      ${tt.announce "bash"}
    '';

    tasks = tt.practices { name = "bash"; local = ./practices; inherit extra; }
      // tt.gitignoreFor { name = "bash"; };
  };
}
