# Subproject Org files for org-agenda-files.
#
#   discover = import ../_lib/subproject_agenda_files.nix { inherit lib; };
#   discover config.devenv.root
#
# Scans the live tree at `root` (not a Nix store copy of this toolbox). Returns
# sorted absolute path strings built from `root`. Only regular .org files that
# sit directly in a .toolboxes/project_management_toolbox directory are
# collected. The root project's own directory is left out; the toolbox template
# adds that project's file itself. Symlinks are not followed.
{ lib }:
root:
let
  # Path for readDir. Do not interpolate it: that would copy the tree into
  # the Nix store and the agenda would point at the copy.
  absPath = p: /. + p;

  skipDir = name:
    name == ".git"
    || name == ".devenv"
    || name == ".direnv"
    || name == "node_modules"
    || name == "result"
    || name == ".cache";

  # Emacs lock (.#name), autosave (#name), and backup (name~) files are not agenda files.
  isAgendaOrg = name:
    lib.hasSuffix ".org" name
    && !(lib.hasPrefix ".#" name)
    && !(lib.hasPrefix "#" name)
    && !(lib.hasSuffix "~" name);

  # Only files directly in .../.toolboxes/project_management_toolbox/
  isPmtDir = rel:
    rel == ".toolboxes/project_management_toolbox"
    || lib.hasSuffix "/.toolboxes/project_management_toolbox" rel;

  # Recurse with readDir; type "symlink" is skipped, so directory links are not followed.
  walk = rel:
    let
      dir = if rel == "" then root else "${root}/${rel}";
      entries = builtins.readDir (absPath dir);
      inPmt = isPmtDir rel;
    in
    lib.concatLists (
      lib.mapAttrsToList (
        name: typ:
        let
          childRel = if rel == "" then name else "${rel}/${name}";
        in
        if typ == "regular" && inPmt && isAgendaOrg name then
          [ "${root}/${childRel}" ]
        else if typ == "directory" && !skipDir name then
          walk childRel
        else
          [ ]
      ) entries
    );

  ownPrefix = "${root}/.toolboxes/project_management_toolbox/";
in
lib.sort (a: b: a < b) (
  builtins.filter (p: !lib.hasPrefix ownPrefix p) (walk "")
)
