{ config, pkgs, inputs, lib, ... }:
let
  gitignore = ./settings/.gitignore;
  pyprojectTemplate = ./templates/pyproject.toml;
  skillGuide = ./settings/skills/python-skill-guide/SKILL.md;

  modernPython = "${inputs.trailofbits-skills}/plugins/modern-python/skills/modern-python";

  wshobsonPython = "${inputs.wshobson-agents}/plugins/python-development/skills";
  codeStyle = "${wshobsonPython}/python-code-style";
  designPatterns = "${wshobsonPython}/python-design-patterns";
  errorHandling = "${wshobsonPython}/python-error-handling";
  projectStructure = "${wshobsonPython}/python-project-structure";
  testingPatterns = "${wshobsonPython}/python-testing-patterns";
  typeSafety = "${wshobsonPython}/python-type-safety";
in
{
  config = {
    enterShell = ''
      if [ -t 1 ]; then
      echo "python toolbox available"
      echo "Python version: $(python --version)"
      echo "uv version: $(uv --version)"
      echo "ruff version: $(ruff --version)"
      echo "ty version: $(ty --version)"
      fi
    '';

    env = {
      PYTHONUTF8 = "1";
      PYTHONDONTWRITEBYTECODE = "1";
    };

    languages.python = {
      enable = true;
      lsp = {
        enable = true;
        package = pkgs.ty;
      };
      uv = {
        enable = true;
        sync.enable = true;
      };
      venv.enable = true;
      version = "3.12";
    };

    packages = with pkgs; [
      ruff
      ty
    ];

    tasks = {
      # uv drops manylinux ty/ruff into the venv. Those ELFs need Nix's
      # dynamic linker. Point the venv shims at the nixpkgs binaries so
      # Emacs ty-ls (which resolves venv/bin/ty) keeps working.
      "python_toolbox:nixos_venv_bins" = {
        before = [ "devenv:enterShell" ];
        after = [ "devenv:python:uv" ];
        exec = ''
          VENV_BIN="${config.devenv.root}/.devenv/state/venv/bin"
          mkdir -p "$VENV_BIN"
          if [ -e "$VENV_BIN/ty" ] || [ -L "$VENV_BIN/ty" ]; then
          ln -sfn ${lib.getExe pkgs.ty} "$VENV_BIN/ty"
          fi
          if [ -e "$VENV_BIN/ruff" ] || [ -L "$VENV_BIN/ruff" ]; then
          ln -sfn ${lib.getExe pkgs.ruff} "$VENV_BIN/ruff"
          fi
        '';
        showOutput = true;
      };

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

      "python_toolbox:copy_skills" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          ECA_DIR="${config.devenv.root}/.eca"
          mkdir -p "$ECA_DIR/skills"

          install -D ${skillGuide} "$ECA_DIR/skills/python-skill-guide/SKILL.md"

          install -D ${modernPython}/SKILL.md "$ECA_DIR/skills/modern-python/SKILL.md"
          for f in ${modernPython}/references/*; do
          install -D "$f" "$ECA_DIR/skills/modern-python/references/$(basename "$f")"
          done

          install -D ${codeStyle}/SKILL.md "$ECA_DIR/skills/python-code-style/SKILL.md"
          install -D ${designPatterns}/SKILL.md "$ECA_DIR/skills/python-design-patterns/SKILL.md"
          install -D ${errorHandling}/SKILL.md "$ECA_DIR/skills/python-error-handling/SKILL.md"
          install -D ${projectStructure}/SKILL.md "$ECA_DIR/skills/python-project-structure/SKILL.md"
          install -D ${typeSafety}/SKILL.md "$ECA_DIR/skills/python-type-safety/SKILL.md"

          install -D ${testingPatterns}/SKILL.md "$ECA_DIR/skills/python-testing-patterns/SKILL.md"
          for f in ${testingPatterns}/references/*; do
          install -D "$f" "$ECA_DIR/skills/python-testing-patterns/references/$(basename "$f")"
          done

          echo "python toolbox skills copied to $ECA_DIR/skills"
        '';
        showOutput = true;
      };
    };
  };
}
