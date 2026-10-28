---
name: nix-bash-scripts
description: When writing, moving, or reviewing bash inside Nix files (devenv.nix enterShell, scripts.*.exec, tasks.*.exec/status, home-manager scripts). Decides inline vs external .sh and checks every script with the bash toolbox's skills and tools.
---

# Bash in Nix files

The bash toolbox (`.toolboxes/bash_toolbox/practices/skills/`) supplies the bash know-how; this skill only adds the Nix parts. Load the one that fits:
- `bash-scripting`: the workflow for writing a new script.
- `bash-defensive-patterns`: error handling, quoting, traps, safe temp files. Read it before writing anything longer than a few lines.
- `bash-pro`: a deeper review of a script that has to be solid.
- `bash-linux`: everyday commands and pipes.

The toolbox puts `shellcheck`, `shfmt` and `bats` on PATH.

## Where the script goes
1. Inline in the Nix file if it is 10 lines or fewer and has no loops or functions.
2. Otherwise, an external file `toolboxes/<toolbox>/programs/<name>.sh`, wrapped with `pkgs.writeShellApplication { name; runtimeInputs; runtimeEnv; text = builtins.readFile ./programs/<name>.sh; }` and called with `lib.getExe`. Use the `_lib` helper for this if one exists.
3. Exception: anything that must export variables or change the current shell stays inline in `enterShell`, whatever its length. A child process cannot change the parent shell.
4. External files cannot use Nix `${...}`. Pass store paths and settings through `runtimeInputs` (commands on PATH) or `runtimeEnv` (variables), or use `$DEVENV_ROOT`.

## Writing
- External: no shebang or `set -euo pipefail` needed; `writeShellApplication` adds both and runs shellcheck at build. Fix warnings rather than adding `excludeShellChecks`.
- Inline: quote every expansion, use `lib.escapeShellArg` for interpolated values, and write `''${var}` for a bash variable inside a Nix `''` string.
- Tasks: put the done-check in `status` so `exec` is skipped when nothing changed.

## Checking
1. External `.sh`: `bash -n`, `shellcheck`, and `shfmt -d` on the file. If it has a `bats` test beside it, run it.
2. Inline: copy each block to a temp file with `#!/usr/bin/env bash` on top. Replace each Nix `${...}` with a dummy value such as `/nix/store/x`, and turn `''${` into `${`. Run `bash -n` and `shellcheck` on it, then map each line number back to the Nix file. Skip `shfmt` for inline blocks; Nix indentation is fine.
3. Fix every error and warning, using `bash-defensive-patterns` for the fix. Then build or enter the shell (`devenv shell -- true`, or the toolbox's smoke test) to confirm the Nix still evaluates.
4. Report per script: where it lives, the rule it follows, and check results.
