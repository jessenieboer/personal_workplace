# Task helpers shared by the toolboxes.
#
#   tt = import ../_lib/toolbox_tasks.nix { inherit config pkgs; };
#   tasks = tt.practices { name = "python"; local = ./practices; }
#     // tt.gitignore "python" ./settings/.gitignore
#     // tt.seed { name = "python"; task = "copy_pyproject_template";
#                  src = ./templates/pyproject.toml; dest = "pyproject.toml"; }
#     // { ...other tasks... };
#
# Every helper returns { "<name>_toolbox:<task>" = { ... }; }, ready to
# merge into tasks, and runs before devenv:enterShell (plus any extra
# `before`). dest paths are relative to the project root.
{ config, pkgs, lib ? pkgs.lib }:
let
  root = config.devenv.root;

  # Shell-escape any string or path (paths are interpolated, so they land in
  # the store first). Use it for every value spliced into a shell snippet.
  q = x: lib.escapeShellArg "${x}";

  practicesSync = pkgs.writeShellApplication {
    name = "practices_sync";
    runtimeInputs = with pkgs; [ coreutils diffutils gnugrep ];
    text = builtins.readFile ./programs/practices_sync.sh;
  };

  mkTask = { name, task, description, before ? [ ], status, exec }: {
    "${name}_toolbox:${task}" = {
      inherit description status exec;
      before = [ "devenv:enterShell" ] ++ before;
    };
  };
in
rec {
  # Bold green "✔ <name> toolbox available" line for enterShell, tty only.
  announce = name: ''
    if [ -t 1 ]; then
      printf '\033[1;32m✔ %s toolbox available\033[0m\n' ${q name}
    fi
  '';

  # Keep dest identical to src; overwrite it whenever they differ.
  refresh = { name, task, src, dest, before ? [ ]
            , description ? "Refresh ${dest} from the ${name} toolbox" }:
    mkTask {
      inherit name task description before;
      status = ''
        [ -f ${q "${root}/${dest}"} ] && cmp -s ${q src} ${q "${root}/${dest}"}
      '';
      exec = ''
        install -D -m 0644 ${q src} ${q "${root}/${dest}"}
      '';
    };

  # Copy src to dest once; never touch it again (the project may edit it).
  # postExec runs only on that first copy, with $dest set.
  seed = { name, task, src, dest, before ? [ ], postExec ? ""
         , description ? "Seed ${dest} once from the toolbox template" }:
    mkTask {
      inherit name task description before;
      status = ''
        test -f ${q "${root}/${dest}"}
      '';
      exec = ''
        dest=${q "${root}/${dest}"}
        if [ ! -f "$dest" ]; then
          install -D -m 0644 ${q src} "$dest"
          ${postExec}
        fi
      '';
    };

  # The .toolboxes/<name>_toolbox/.gitignore fragment the git toolbox merges.
  gitignore = name: src: refresh {
    inherit name src;
    task = "copy_gitignore";
    dest = ".toolboxes/${name}_toolbox/.gitignore";
    description = "Refresh the ${name}_toolbox gitignore fragment from the toolbox";
  };

  # ECA practices (skills, agents, rules). Builds one store directory shaped
  # like practices/ (skills/<n>/..., agents/..., rules/...) from the
  # toolbox's own practices/ plus any extra sources, then copies it to both
  #   .eca/                                  (where ECA loads it)
  #   .toolboxes/<name>_toolbox/practices/   (a readable mirror)
  #
  #   extra: attrset of destination (relative to practices/) -> source.
  #          A directory source is copied whole; a file source to that name.
  #   postBuild: shell run in $out after copying, for transforms.
  #
  # .eca is shared by every toolbox, so only this toolbox's top-level items
  # (skills/<n>, agents/<f>, rules/<f>) are replaced there; the mirror is
  # replaced whole.
  # The items installed are recorded in .toolboxes/<name>_toolbox/eca_manifest;
  # items listed there but no longer shipped are removed from .eca, and nothing
  # else is (other toolboxes' items and the user's own stay).
  practices = { name, local ? null, extra ? { }, postBuild ? "" }:
    let
      eca = "${root}/.eca";
      mirror = "${root}/.toolboxes/${name}_toolbox/practices";
      installed = "${root}/.toolboxes/${name}_toolbox/eca_manifest";

      built = pkgs.runCommandLocal "${name}-toolbox-practices" { } ''
        mkdir -p "$out"
        ${lib.optionalString (local != null) ''cp -rL --no-preserve=mode ${q "${local}/."} "$out/"''}
        ${lib.concatStrings (lib.mapAttrsToList (dest: src: ''
          d=${q dest}
          mkdir -p "$(dirname "$out/$d")"
          if [ -d ${q src} ]; then
            mkdir -p "$out/$d"
            cp -rL --no-preserve=mode ${q "${src}/."} "$out/$d/"
          else
            cp -L --no-preserve=mode ${q src} "$out/$d"
          fi
        '') extra)}
        cd "$out" || exit 1
        ${postBuild}
      '';

      # `built`'s top-level items (skills/<n>, agents/<f>, rules/<f>), one per
      # line. Recorded in `installed` so a later run can remove the ones this
      # toolbox stops shipping.
      manifest = pkgs.runCommandLocal "${name}-eca-manifest" { } ''
        cd ${q built}
        for i in */*; do
          if [ -e "$i" ]; then echo "$i"; fi
        done | LC_ALL=C sort > "$out"
      '';

      sync = mode: lib.concatStringsSep " " [
        (lib.getExe practicesSync)
        mode
        (q built)
        (q manifest)
        (q eca)
        (q mirror)
        (q installed)
      ];
    in
    mkTask {
      inherit name;
      task = "copy_practices";
      description = "Refresh ${name} practices under .eca and .toolboxes/${name}_toolbox/practices";
      status = sync "status";
      exec = sync "apply";
    };
}
