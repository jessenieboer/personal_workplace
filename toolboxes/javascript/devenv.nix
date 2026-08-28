{ config, pkgs, ... }:
let
  gitignore = ./settings/.gitignore;
  packageJsonTemplate = ./templates/package.json;
in
{
  config = {
    enterShell = ''
      echo "jessenieboer's javascript toolbox available"
      echo "node: $(node --version)"
      echo "npm: $(npm --version)"
      echo "tsc: $(tsc --version)"
      echo "ts-ls: $(command -v typescript-language-server)"
      echo "prettier: $(command -v prettier)"
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
