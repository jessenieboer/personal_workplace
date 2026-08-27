{ config, pkgs, ... }:
let
  gitignore = ./settings/.gitignore;
  pyprojectTemplate = ./templates/pyproject.toml;
in
{
  config = {
    enterShell = ''
      echo "python toolbox available"
      echo "Python version: $(python --version)"
      echo "uv version: $(uv --version)"
    '';

    env = {
      PYTHONUTF8 = "1";
      PYTHONDONTWRITEBYTECODE = "1";
    };
    
    languages.python = {
      enable = true;
      lsp = {
        enable = true;
        package = pkgs.pyright;
      };
      #requirements = 
      uv = {
        enable = true;
        sync.enable = true; 
      };
      venv.enable = true;
      version = "3.12";
    };


    tasks = {
      "python_toolbox:copy_gitignore" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          mkdir -p "${config.devenv.root}/.toolboxes/python_toolbox"
          cp -f ${gitignore} "${config.devenv.root}/.toolboxes/python_toolbox/.gitignore"
          echo "copied python_toolbox .gitignore"
        '';
        showOutput = true;
      };
      "python_toolbox:copy_pyproject_template" = {
        before = [ "devenv:enterShell" "devenv:python:uv" ];
        exec = ''
          if [ -f "${config.devenv.root}/pyproject.toml" ]; then
          echo "pyproject.toml already exists — skipping copy."
          exit 0
          fi
          cp ${pyprojectTemplate} ${config.devenv.root}/pyproject.toml
          chmod u+w ${config.devenv.root}/pyproject.toml

          echo "copied templates/pyproject.toml to pyproject.toml"
        '';
        showOutput = true;
      };
    };

    # packages = with pkgs; [
      #     pytest
      #   ripgrep
      #   fd
      #]
  };
}
