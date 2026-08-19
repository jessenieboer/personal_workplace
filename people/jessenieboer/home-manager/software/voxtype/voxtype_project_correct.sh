# correct voice transcription based on relevant project context

set -euo pipefail

DEBUG_LOG="${XDG_RUNTIME_DIR:-/tmp}/voxtype-project-correct.log"

log() {
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" >> "$DEBUG_LOG"
}

transcript=$(cat)
log "=== new transcription ==="
log "raw: $transcript"

DEFAULT_PROMPT="You are a careful text corrector for a user dictating text by voice.

Rules:
- Fix grammar, punctuation, and obvious speech-to-text errors.
- Do NOT add explanations, quotes, or markdown fences.
- Output ONLY the corrected text.
"

# ---------- helpers ----------
get_focused_pid() {
  if command -v kdotool >/dev/null 2>&1; then
    kdotool getactivewindow getwindowpid 2>/dev/null || true
  fi
}

get_focused_class() {
  if command -v kdotool >/dev/null 2>&1; then
    kdotool getactivewindow getwindowclassname 2>/dev/null || true
  fi
}

is_opencode_session() {
  local pid=$1
  if tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | grep -q '[o]pencode'; then
    return 0
  fi

  local children_file="/proc/$pid/task/$pid/children"
  [[ -r "$children_file" ]] || return 1

  local -a child_pids
  read -r -a child_pids < "$children_file" || return 1

  local cpid
  for cpid in "${child_pids[@]}"; do
    [[ -n "$cpid" ]] || continue
    if tr '\0' ' ' < "/proc/$cpid/cmdline" 2>/dev/null | grep -q '[o]pencode'; then
      return 0
    fi
  done
  return 1
}

find_project_root() {
  local dir

  if [[ "$class" == *emacs* ]] && command -v emacsclient >/dev/null 2>&1; then
    dir=$(emacsclient -e '(let ((dir (or (when (fboundp '\''project-current)
                                            (when-let ((p (project-current)))
                                              (project-root p)))
                                          (with-current-buffer (window-buffer (selected-window))
                                            default-directory))))
                           (expand-file-name dir))' 2>/dev/null | tr -d '"')

    if [[ -n "$dir" && -d "$dir" ]]; then
      while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.envrc" || -f "$dir/devenv.nix" || -f "$dir/flake.nix" || -d "$dir/.git" ]]; then
          echo "$dir"
          return 0
        fi
        dir=$(dirname "$dir")
      done
    fi
  fi

  local cwd
  [[ -d "/proc/$pid/cwd" ]] || return 1
  cwd=$(readlink -f "/proc/$pid/cwd" 2>/dev/null) || return 1

  dir="$cwd"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.envrc" || -f "$dir/devenv.nix" || -f "$dir/flake.nix" || -d "$dir/.git" ]]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

# ---------- decide whether to process ----------
pid=$(get_focused_pid)
class=$(get_focused_class | tr '[:upper:]' '[:lower:]')

should_process=false

if [[ -n "$pid" ]]; then
  if [[ "$class" == *emacs* ]]; then
    should_process=true
  elif [[ "$class" == *konsole* ]] && is_opencode_session "$pid"; then
    should_process=true
  fi
fi

log "focused pid=$pid class=$class should_process=$should_process"

if [[ "$should_process" != true ]]; then
  log "skipping post-process (not emacs/opencode)"
  printf '%s' "$transcript"
  exit 0
fi

project_root=$(find_project_root || true)
log "project_root=${project_root:-<none>}"

# ---------- load project-specific Ollama prompt ----------
instruction="$DEFAULT_PROMPT"
if [[ -n "$project_root" ]]; then
  prompt_file="$project_root/.toolboxes/voxtype_toolbox/post_process_prompt.txt"
  if [[ -f "$prompt_file" ]]; then
    instruction=$(cat "$prompt_file")
    log "using project prompt file: $prompt_file"
  else
    log "no project prompt file, using default"
  fi
else
  log "no project root, using default prompt"
fi

# ---------- Ollama ----------
model="${VOXTYPE_OLLAMA_MODEL:-llama3.2:1b}" # this is specified in computers/llm.nix

prompt="$instruction

Dictated text to correct:
$transcript
"

corrected=$(
  curl -sf http://127.0.0.1:11434/api/generate \
    -H 'Content-Type: application/json' \
    -d "$(jq -n \
      --arg model "$model" \
      --arg prompt "$prompt" \
      '{model:$model, prompt:$prompt, stream:false, options:{temperature:0.1, num_predict:256}}')" \
  | jq -r '.response // empty' \
  | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
)

log "corrected: $corrected"
log "=== done ==="

if [[ -z "$corrected" ]]; then
  printf '%s' "$transcript"
else
  printf '%s' "$corrected"
fi
