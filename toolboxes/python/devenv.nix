{ config, inputs, pkgs, ... }:
let
  codeStyle = "${wshobsonPython}/python-code-style";
  designPatterns = "${wshobsonPython}/python-design-patterns";
  errorHandling = "${wshobsonPython}/python-error-handling";  
  gitignore = ./settings/.gitignore;
  modernPython = "${inputs.trailofbits-skills}/plugins/modern-python/skills/modern-python";
  projectStructure = "${wshobsonPython}/python-project-structure";
  pyprojectTemplate = ./templates/pyproject.toml;
  testingPatterns = "${wshobsonPython}/python-testing-patterns";
  typeSafety = "${wshobsonPython}/python-type-safety";
  wshobsonPython = "${inputs.wshobson-agents}/plugins/python-development/skills";
in
{
  config = {
    enterShell = ''
      echo "python toolbox available"
      echo "Python version: $(python --version)"
      echo "uv version: $(uv --version)"
      echo "ruff version: $(ruff --version)"
    '';

    env = {
      PYTHONUTF8 = "1";
      PYTHONDONTWRITEBYTECODE = "1";
    };

    languages.python = {
      enable = true;
      uv = {
        enable = true;
        sync.enable = true;
      };
      venv.enable = true;
      version = "3.12";
    };

    packages = with pkgs; [
      ruff
    ];

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
      "python_toolbox:copy_skills" = {
        before = [ "devenv:enterShell" ];
        exec = ''
          ECA_DIR="${config.devenv.root}/.eca"
          mkdir -p "$ECA_DIR/skills"

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
