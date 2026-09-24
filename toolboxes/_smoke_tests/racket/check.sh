#!/usr/bin/env bash
set -euo pipefail
command -v racket >/dev/null
command -v raco >/dev/null
# langserver install needs network on first run; warn but do not fail smoke.
if ! raco pkg show --user racket-langserver >/dev/null 2>&1; then
  echo "NOTE: racket-langserver not installed yet (first-run network install)"
fi
echo "PASS: racket smoke"
