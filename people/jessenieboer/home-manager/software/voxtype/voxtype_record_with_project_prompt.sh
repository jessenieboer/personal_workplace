set -euo pipefail

DEBUG_LOG="${XDG_RUNTIME_DIR:-/tmp}/voxtype-record-with-project-prompt.log"

log() {
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" >> "$DEBUG_LOG"
}

find_project_root() {
  local dir pid

  # Prefer Emacs current project / buffer directory
  if command -v emacsclient >/dev/null 2>&1; then
    dir=$(emacsclient -e '(let ((d (or (when (fboundp '\''project-current)
                                         (when-let ((p (project-current)))
                                           (project-root p)))
                                       (with-current-buffer (window-buffer (selected-window))
                                         default-directory))))
                            (expand-file-name d))' 2>/dev/null | tr -d '"')
    if [[ -n "$dir" && -d "$dir" ]]; then
      while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/toolboxes" || -f "$dir/.envrc" || -f "$dir/devenv.nix" || -f "$dir/flake.nix" || -d "$dir/.git" ]]; then
          echo "$dir"
          return 0
        fi
        dir=$(dirname "$dir")
      done
    fi
  fi

  # Fallback: focused window cwd (Konsole / other)
  if command -v kdotool >/dev/null 2>&1; then
    pid=$(kdotool getactivewindow getwindowpid 2>/dev/null || true)
    if [[ -n "$pid" && -d "/proc/$pid/cwd" ]]; then
      dir=$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)
      while [[ -n "$dir" && "$dir" != "/" ]]; do
        if [[ -d "$dir/toolboxes" || -f "$dir/.envrc" || -f "$dir/devenv.nix" || -f "$dir/flake.nix" || -d "$dir/.git" ]]; then
          echo "$dir"
          return 0
        fi
        dir=$(dirname "$dir")
      done
    fi
  fi

  return 1
}

# Stop if already recording
if voxtype status 2>/dev/null | grep -qi recording; then
  voxtype record stop
  exit 0
fi

project_root=$(find_project_root || true)
prompt=""

if [[ -n "$project_root" ]]; then
  prompt_file="$project_root/.toolboxes/voxtype_toolbox/initial_prompt.txt"
  if [[ -f "$prompt_file" ]]; then
    prompt=$(tr '\n' ' ' < "$prompt_file" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  fi
fi

log "project_root=${project_root:-<none>}"
log "prompt_file=${prompt_file:-<none>}"
log "prompt=$prompt"

if [[ -n "$prompt" ]]; then
  log "starting with initial_prompt"
  voxtype --initial-prompt "$prompt" record start
else
  log "starting with no initial_prompt"
  voxtype record start
fi
