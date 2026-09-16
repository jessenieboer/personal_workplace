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

  root = config.devenv.root;
  eca = "${root}/.eca/skills";
  gitignoreDest = "${root}/.toolboxes/python_toolbox/.gitignore";
  pyprojectDest = "${root}/pyproject.toml";
  venvBin = "${root}/.devenv/state/venv/bin";
  tyExe = lib.getExe pkgs.ty;
  ruffExe = lib.getExe pkgs.ruff;
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
        description = "Point venv ty/ruff at nixpkgs binaries when those shims exist";
        before = [ "devenv:enterShell" ];
        after = [ "devenv:python:uv" ];
        status = ''
          need=0
          if [ -e "${venvBin}/ty" ] || [ -L "${venvBin}/ty" ]; then
            [ "$(readlink -f "${venvBin}/ty")" = "${tyExe}" ] || need=1
          fi
          if [ -e "${venvBin}/ruff" ] || [ -L "${venvBin}/ruff" ]; then
            [ "$(readlink -f "${venvBin}/ruff")" = "${ruffExe}" ] || need=1
          fi
          [ "$need" = 0 ]
        '';
        exec = ''
          mkdir -p "${venvBin}"
          if [ -e "${venvBin}/ty" ] || [ -L "${venvBin}/ty" ]; then
            ln -sfn ${tyExe} "${venvBin}/ty"
          fi
          if [ -e "${venvBin}/ruff" ] || [ -L "${venvBin}/ruff" ]; then
            ln -sfn ${ruffExe} "${venvBin}/ruff"
          fi
        '';
      };

      "python_toolbox:copy_gitignore" = {
        description = "Refresh the python_toolbox gitignore fragment from the toolbox";
        before = [ "devenv:enterShell" ];
        status = ''
          [ -f "${gitignoreDest}" ] && cmp -s ${gitignore} "${gitignoreDest}"
        '';
        exec = ''
          install -D -m 0644 ${gitignore} "${gitignoreDest}"
        '';
      };

      "python_toolbox:copy_pyproject_template" = {
        description = "Seed pyproject.toml once from the toolbox template";
        before = [ "devenv:enterShell" "devenv:python:uv" ];
        status = ''
          test -f "${pyprojectDest}"
        '';
        exec = ''
          install -D -m 0644 ${pyprojectTemplate} "${pyprojectDest}"
        '';
      };

      "python_toolbox:copy_skills" = {
        description = "Refresh Python skills under .eca/skills";
        before = [ "devenv:enterShell" ];
        status = ''
          same() { [ -f "$2" ] && cmp -s "$1" "$2"; }
          same ${skillGuide} "${eca}/python-skill-guide/SKILL.md" || exit 1
          same ${modernPython}/SKILL.md "${eca}/modern-python/SKILL.md" || exit 1
          same ${codeStyle}/SKILL.md "${eca}/python-code-style/SKILL.md" || exit 1
          same ${designPatterns}/SKILL.md "${eca}/python-design-patterns/SKILL.md" || exit 1
          same ${errorHandling}/SKILL.md "${eca}/python-error-handling/SKILL.md" || exit 1
          same ${projectStructure}/SKILL.md "${eca}/python-project-structure/SKILL.md" || exit 1
          same ${typeSafety}/SKILL.md "${eca}/python-type-safety/SKILL.md" || exit 1
          same ${testingPatterns}/SKILL.md "${eca}/python-testing-patterns/SKILL.md" || exit 1
          if [ -d ${modernPython}/references ]; then
            for f in ${modernPython}/references/*; do
              [ -f "$f" ] || continue
              same "$f" "${eca}/modern-python/references/$(basename "$f")" || exit 1
            done
          fi
          if [ -d ${testingPatterns}/references ]; then
            for f in ${testingPatterns}/references/*; do
              [ -f "$f" ] || continue
              same "$f" "${eca}/python-testing-patterns/references/$(basename "$f")" || exit 1
            done
          fi
        '';
        exec = ''
          install -D -m 0444 ${skillGuide} "${eca}/python-skill-guide/SKILL.md"
          install -D -m 0444 ${modernPython}/SKILL.md "${eca}/modern-python/SKILL.md"
          if [ -d ${modernPython}/references ]; then
            for f in ${modernPython}/references/*; do
              [ -f "$f" ] || continue
              install -D -m 0444 "$f" "${eca}/modern-python/references/$(basename "$f")"
            done
          fi
          install -D -m 0444 ${codeStyle}/SKILL.md "${eca}/python-code-style/SKILL.md"
          install -D -m 0444 ${designPatterns}/SKILL.md "${eca}/python-design-patterns/SKILL.md"
          install -D -m 0444 ${errorHandling}/SKILL.md "${eca}/python-error-handling/SKILL.md"
          install -D -m 0444 ${projectStructure}/SKILL.md "${eca}/python-project-structure/SKILL.md"
          install -D -m 0444 ${typeSafety}/SKILL.md "${eca}/python-type-safety/SKILL.md"
          install -D -m 0444 ${testingPatterns}/SKILL.md "${eca}/python-testing-patterns/SKILL.md"
          if [ -d ${testingPatterns}/references ]; then
            for f in ${testingPatterns}/references/*; do
              [ -f "$f" ] || continue
              install -D -m 0444 "$f" "${eca}/python-testing-patterns/references/$(basename "$f")"
            done
          fi
        '';
      };
    };
  };
}
