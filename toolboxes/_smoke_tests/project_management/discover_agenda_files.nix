# Eval-time checks for subproject agenda discovery, plus a derivation that
# builds the project_management dir-locals fragment and checks its text.
#
# The module is loaded twice: from the repo (source layout) and from a copied
# .toolboxes/ tree (deployed layout). Both must import ../_lib by relative
# path and produce the same option value and the same template.
{ fixture
, sourceModule
, deployedModule
, deployedHelper
, expectNew ? false
}:
let
  pkgs = import (builtins.fetchTarball {
    # nixpkgs-src rev pinned in toolboxes/project_management/devenv.lock
    url = "https://github.com/NixOS/nixpkgs/archive/674a2028661e550a97400c1cc992b9cca9a668a1.tar.gz";
    sha256 = "sha256-T2+XBfNbf9pecLUWS4+RtuVNZ3W8K5taG5QdV71mWlk=";
  }) { };
  lib = pkgs.lib;

  die = msg: throw msg;

  abs = rel: "${fixture}/${rel}";

  # Literal ascending order. Not passed through lib.sort first: that would hide
  # a reversed comparator shared with the implementation.
  baseRels = [
    "a_first/.toolboxes/project_management_toolbox/a_first_inbox.org"
    "a_first/.toolboxes/project_management_toolbox/z.org"
    "a_first/nested/.toolboxes/project_management_toolbox/nested.org"
    "m_mid/.toolboxes/project_management_toolbox/m.org"
    "spiritual_formation/.toolboxes/project_management_toolbox/spiritual_formation.org"
    "spiritual_formation/.toolboxes/project_management_toolbox/spiritual_formation_inbox.org"
  ];
  newRel = "nested_new/deep/.toolboxes/project_management_toolbox/brand_new.org";
  rels =
    if expectNew then
      lib.take 4 baseRels ++ [ newRel ] ++ lib.drop 4 baseRels
    else
      baseRels;
  expected = map abs rels;

  explicit = [ "/explicit/b.org" "/explicit/a.org" ];

  load = path:
    if !(lib.hasPrefix "/" path) then die "module path must be absolute: ${path}"
    else import (/. + path);

  base = {
    options.devenv.root = lib.mkOption {
      type = lib.types.str;
    };
    # The toolbox assigns these; devenv declares them. The test only needs the values.
    options.enterShell = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
    options.tasks = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.anything;
      default = { };
    };
    config.devenv.root = fixture;
    config.project_management_toolbox = {
      project_name = "empire_capitol";
      project_benefit = "Oversight of all kingdoms I have responsibility in";
      workers = [
        { name = "jessenieboer"; email = "jessenieboer@protonmail.com"; }
        { name = "CaptureBot"; }
      ];
    };
  };

  eval = mod: extra: lib.evalModules {
    modules = [ (load mod) base extra ];
    specialArgs = { inherit pkgs; inputs = { }; };
  };

  sourceDefault = eval sourceModule { };
  deployedDefault = eval deployedModule { };
  sourceOverride = eval sourceModule {
    config.project_management_toolbox.subproject_agenda_files = explicit;
  };
  deployedOverride = eval deployedModule {
    config.project_management_toolbox.subproject_agenda_files = explicit;
  };
  sourceEmpty = eval sourceModule {
    config.project_management_toolbox.subproject_agenda_files = [ ];
  };
  deployedEmpty = eval deployedModule {
    config.project_management_toolbox.subproject_agenda_files = [ ];
  };

  filesOf = ev: ev.config.project_management_toolbox.subproject_agenda_files;
  helperFiles = (load deployedHelper) { inherit lib; } fixture;

  assertList = label: got: want:
    if got == want then true
    else die ''
      ${label}
      got:
      ${builtins.concatStringsSep "\n" got}
      expected:
      ${builtins.concatStringsSep "\n" want}
    '';

  assertMeta = label: ev:
    let
      pm = ev.config.project_management_toolbox;
      workers = pm.workers;
    in
    if pm.project_name != "empire_capitol" then die "${label}: project_name ${pm.project_name}"
    else if pm.project_benefit != "Oversight of all kingdoms I have responsibility in" then die "${label}: project_benefit changed"
    else if map (w: w.name) workers != [ "jessenieboer" "CaptureBot" ] then die "${label}: worker names changed"
    else if (builtins.elemAt workers 0).email != "jessenieboer@protonmail.com" then die "${label}: worker email changed"
    else if (builtins.elemAt workers 1).email != null then die "${label}: CaptureBot email changed"
    else true;

  assertLive = paths:
    let
      bad = builtins.filter (p:
        !(builtins.isString p)
        || lib.hasPrefix "/nix/store/" p
        || !(lib.hasPrefix "${fixture}/" p)
        || builtins.readFile (/. + p) != "live\n"
      ) paths;
    in
    if bad == [ ] then true
    else die "discovered paths are not live fixture strings:\n${builtins.concatStringsSep "\n" bad}";

  checks = builtins.foldl' (acc: ok: acc && ok) true [
    (assertList "source default" (filesOf sourceDefault) expected)
    (assertList "expected order is sorted" expected (lib.sort (a: b: a < b) expected))
    (assertList "deployed default" (filesOf deployedDefault) expected)
    (assertList "deployed helper" helperFiles expected)
    (assertLive helperFiles)
    (assertList "source explicit list" (filesOf sourceOverride) explicit)
    (assertList "deployed explicit list" (filesOf deployedOverride) explicit)
    (assertList "source explicit empty" (filesOf sourceEmpty) [ ])
    (assertList "deployed explicit empty" (filesOf deployedEmpty) [ ])
    (assertMeta "source default" sourceDefault)
    (assertMeta "deployed default" deployedDefault)
    (assertMeta "source explicit" sourceOverride)
    (assertMeta "deployed explicit" deployedOverride)
    (assertMeta "source empty" sourceEmpty)
    (assertMeta "deployed empty" deployedEmpty)
  ];

  # First store path in the refresh task is the replaceVars output.
  # escapeShellArg leaves a path unquoted when it has no shell metacharacters.
  rendered = ev:
    let
      exec = ev.config.tasks."project_management_toolbox:generate_dir_locals".exec or
        (die "generate_dir_locals task missing");
      unquote = s:
        if lib.hasPrefix "'" s && lib.hasSuffix "'" s then
          lib.removePrefix "'" (lib.removeSuffix "'" s)
        else s;
      path = unquote (lib.findFirst
        (p: lib.hasPrefix "/nix/store/" (unquote p))
        ""
        (lib.splitString " " exec));
    in
    if path == "" then die "no rendered template in:\n${exec}"
    else if builtins.getContext path == { } then die "rendered template is not a build dependency: ${path}\n${exec}"
    else path;

  ownFile = "${fixture}/.toolboxes/project_management_toolbox/empire_capitol.org";
  quotedExpected = lib.concatMapStringsSep " " (s: "\"${s}\"") expected;
  quotedExplicit = lib.concatMapStringsSep " " (s: "\"${s}\"") explicit;

  absent = [
    "${fixture}/.toolboxes/project_management_toolbox/empire_inbox.org"
    "${fixture}/a_first/.toolboxes/project_management_toolbox/.#lock.org"
    "${fixture}/a_first/.toolboxes/project_management_toolbox/#autosave.org#"
    "${fixture}/a_first/.toolboxes/project_management_toolbox/backup.org~"
    "${fixture}/a_first/.toolboxes/project_management_toolbox/linked.org"
    "${fixture}/a_first/.toolboxes/project_management_toolbox/extra/deep.org"
    "${fixture}/linked_dir/.toolboxes/project_management_toolbox/hidden.org"
    "${fixture}/node_modules/nested/.toolboxes/project_management_toolbox/no.org"
    "${fixture}/.git/nested/.toolboxes/project_management_toolbox/no.org"
  ];

  require = file: text: ''
    if ! grep -F ${lib.escapeShellArg text} ${file} >/dev/null; then
      printf '%s\n' ${lib.escapeShellArg "missing: ${text}"} >&2
      exit 1
    fi
  '';
  reject = file: text: ''
    if grep -F ${lib.escapeShellArg text} ${file} >/dev/null; then
      printf '%s\n' ${lib.escapeShellArg "unexpected: ${text}"} >&2
      exit 1
    fi
  '';
in
assert checks;
pkgs.runCommand "discover-agenda-files-test" { } ''
  cmp -s ${lib.escapeShellArg (rendered sourceDefault)} ${lib.escapeShellArg (rendered deployedDefault)}
  cmp -s ${lib.escapeShellArg (rendered sourceOverride)} ${lib.escapeShellArg (rendered deployedOverride)}
  cmp -s ${lib.escapeShellArg (rendered sourceEmpty)} ${lib.escapeShellArg (rendered deployedEmpty)}

  def=${rendered sourceDefault}
  over=${rendered sourceOverride}
  empty=${rendered sourceEmpty}

  ${require "\"$def\"" ownFile}
  ${require "\"$def\"" quotedExpected}
  ${require "\"$def\"" "jessenieboer CaptureBot"}
  ${lib.concatMapStrings (t: reject "\"$def\"" t) absent}

  ${require "\"$over\"" ownFile}
  ${require "\"$over\"" quotedExplicit}
  ${require "\"$over\"" "jessenieboer CaptureBot"}
  ${reject "\"$over\"" (abs "spiritual_formation/.toolboxes/project_management_toolbox/spiritual_formation.org")}
  ${reject "\"$over\"" (abs "a_first/.toolboxes/project_management_toolbox/a_first_inbox.org")}
  ${reject "\"$over\"" (abs newRel)}

  ${require "\"$empty\"" ownFile}
  ${require "\"$empty\"" "jessenieboer CaptureBot"}
  ${reject "\"$empty\"" (abs "spiritual_formation/.toolboxes/project_management_toolbox/spiritual_formation.org")}
  ${reject "\"$empty\"" (abs "a_first/.toolboxes/project_management_toolbox/a_first_inbox.org")}
  ${reject "\"$empty\"" (abs newRel)}
  ${lib.concatMapStrings (t: reject "\"$empty\"" t) absent}

  touch "$out"
''
