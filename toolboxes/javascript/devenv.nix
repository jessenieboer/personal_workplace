{ config, pkgs, inputs, lib, ... }:
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
      if [ -t 1 ]; then
        echo "node version: $(node --version)"
        echo "npm version: $(npm --version)"
        echo "tsc version: $(tsc --version)"
        echo "typescript-language-server version: $(typescript-language-server --version)"
        echo "prettier version: $(prettier --version)"
      fi
    '';

    languages.javascript = {
      enable = true;
      package = pkgs.nodejs_22;
      lsp.enable = true;
      npm = {
        enable = true;
        install.enable = true;
      };
    };

    languages.typescript = {
      enable = true;
      lsp.enable = true;
    };

    packages = with pkgs; [
      prettier
    ];

    tasks = practicesTasks
      // tt.gitSettings "javascript" ./settings
      // tt.seed {
        name = "javascript"; task = "copy_package_json_template";
        src = ./templates/package.json; dest = "package.json";
      }
      // {

      # npm install runs inside devenv's enterShell, so seeding before
      # devenv:enterShell is enough for it to see package.json.
    };
  };
}
