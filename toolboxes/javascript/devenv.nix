{ config, pkgs, ... }:
let
  gitignore = ./settings/.gitignore;
  packageJsonTemplate = ./templates/package.json;
in
{
  config = {
    enterShell = ''
      echo "javascript toolbox available"
      echo "Node version: $(node --version)"
      echo "npm version: $(npm --version)"
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

    tasks = {
      "javascript_toolbox:copy_gitignore" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          mkdir -p "${config.devenv.root}/.toolboxes/javascript_toolbox"
          cp -f ${gitignore} "${config.devenv.root}/.toolboxes/javascript_toolbox/.gitignore"
          echo "copied javascript_toolbox .gitignore"
        '';
        showOutput = true;
      };
      "javascript_toolbox:copy_package_json_template" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          if [ -f "${config.devenv.root}/package.json" ]; then
          echo "package.json already exists — skipping copy."
          exit 0
          fi
          cp ${packageJsonTemplate} ${config.devenv.root}/package.json
          chmod u+w ${config.devenv.root}/package.json

          echo "copied templates/package.json to package.json"
        '';
        showOutput = true;
      };
    };
  };
}
