{ config, pkgs, ... }:
let
  gitignore = ./settings/.gitignore;
  packageJsonTemplate = ./templates/package.json;
  root = config.devenv.root;
  gitignoreDest = "${root}/.toolboxes/javascript_toolbox/.gitignore";
  packageJsonDest = "${root}/package.json";
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
        echo "jessenieboer's javascript toolbox available"
        echo "node: $(node --version)"
        echo "npm: $(npm --version)"
        echo "tsc: $(tsc --version)"
        echo "ts-ls: $(command -v typescript-language-server)"
        echo "prettier: $(command -v prettier)"
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

    tasks = {
      "javascript_toolbox:copy_gitignore" = {
        description = "Refresh the javascript_toolbox gitignore fragment from the toolbox";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${gitignoreDest}" ] && cmp -s ${gitignore} "${gitignoreDest}"
        '';
        exec = ''
          install -D -m 0644 ${gitignore} "${gitignoreDest}"
        '';
      };

      "javascript_toolbox:copy_package_json_template" = {
        description = "Seed package.json once from the toolbox template";
        before = [ "devenv:enterShell" ];
        status = ''
          test -f "${packageJsonDest}"
        '';
        exec = ''
          install -D -m 0644 ${packageJsonTemplate} "${packageJsonDest}"
        '';
      };
    };
  };
}
