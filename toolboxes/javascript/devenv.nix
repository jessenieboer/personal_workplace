{ config, pkgs, inputs, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };

  wshobson = "${inputs.wshobson-agents}/plugins/javascript-typescript/skills";
  practicesTasks = tt.practices {
    name = "javascript";
    local = ./practices;
    extra = {
      "skills/javascript-testing-patterns" = "${wshobson}/javascript-testing-patterns";
      "skills/modern-javascript-patterns" = "${wshobson}/modern-javascript-patterns";
      "skills/nodejs-backend-patterns" = "${wshobson}/nodejs-backend-patterns";
      "skills/typescript-advanced-types" = "${wshobson}/typescript-advanced-types";
    };
  };
in
{
  config = {
    enterShell = ''
      ${tt.announce "javascript"}
    '';

    languages.javascript = {
      enable = true;
      package = pkgs.nodejs_24;
      npm = {
        enable = true;
        install.enable = true;
      };
    };

    # tsc and typescript-language-server (which also serves JavaScript).
    languages.typescript.enable = true;

    packages = with pkgs; [
      prettier
    ];

    tasks = practicesTasks
      // tt.gitSettings "javascript" ./settings
      // tt.seed {
        name = "javascript"; task = "copy_package_json_template";
        src = ./templates/package.json; dest = "package.json";
      };
  };
}
