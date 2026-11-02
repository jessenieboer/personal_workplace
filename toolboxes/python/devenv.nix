{ config, pkgs, inputs, lib, ... }:
let
  tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };

  venvBin = "${config.devenv.state}/venv/bin";

  # uv drops manylinux ty/ruff into the venv. Those ELFs need Nix's dynamic
  # linker. Point the venv shims at the nixpkgs binaries so Emacs ty-ls (which
  # resolves venv/bin/ty) keeps working.
  shims = {
    ty = lib.getExe pkgs.ty;
    ruff = lib.getExe pkgs.ruff;
  };
  shimNames = lib.attrNames shims;
  # A shim is only touched when uv put something at its path (even a broken link).
  forEachShim = body: lib.concatMapStringsSep "\n" (n: ''
    shim=${lib.escapeShellArg "${venvBin}/${n}"}
    want=${lib.escapeShellArg shims.${n}}
    if [ -e "$shim" ] || [ -L "$shim" ]; then
    ${body}
    fi
  '') shimNames;

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
      ${tt.announce "python"}
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
      package = pkgs.python312;
    };

    packages = with pkgs; [
      ruff
    ];

    tasks = practicesTasks
      // tt.gitSettings "python" ./settings
      // tt.seed {
        name = "python"; task = "copy_pyproject_template"; src = ./templates/pyproject.toml;
        dest = "pyproject.toml"; before = [ "devenv:python:uv" ];
      }
      // {
      "python_toolbox:nixos_venv_bins" = {
        description = "Point venv ty/ruff at nixpkgs binaries when those shims exist";
        before = [ "devenv:enterShell" ];
        after = [ "devenv:python:uv" ];
        status = ''
          ${forEachShim ''  [ "$(readlink -f "$shim")" = "$want" ] || exit 1''}
          exit 0
        '';
        exec = ''
          set -eu
          mkdir -p ${lib.escapeShellArg venvBin}
          ${forEachShim ''  ln -sfn "$want" "$shim"''}
        '';
      };
    };
  };
}
