{ config, pkgs, inputs, lib, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };

  root = config.devenv.root;
  venvBin = "${root}/.devenv/state/venv/bin";
  tyExe = lib.getExe pkgs.ty;
  ruffExe = lib.getExe pkgs.ruff;

  wshobson = "${inputs.wshobson-agents}/plugins/python-development/skills";
  practicesTasks = tt.practices {
    name = "python";
    local = ./practices;
    extra = {
      "skills/modern-python" = "${inputs.trailofbits-skills}/plugins/modern-python/skills/modern-python";
      "skills/python-code-style" = "${wshobson}/python-code-style";
      "skills/python-design-patterns" = "${wshobson}/python-design-patterns";
      "skills/python-error-handling" = "${wshobson}/python-error-handling";
      "skills/python-project-structure" = "${wshobson}/python-project-structure";
      "skills/python-testing-patterns" = "${wshobson}/python-testing-patterns";
      "skills/python-type-safety" = "${wshobson}/python-type-safety";
    };
  };
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

    tasks = practicesTasks
      // tt.gitignore "python" ./settings/.gitignore
      // tt.seed {
        name = "python"; task = "copy_pyproject_template"; src = ./templates/pyproject.toml;
        dest = "pyproject.toml"; before = [ "devenv:python:uv" ];
      }
      // {
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

    };
  };
}
