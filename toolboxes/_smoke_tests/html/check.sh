#!/usr/bin/env bash
set -euo pipefail
command -v vscode-html-language-server >/dev/null
command -v vscode-css-language-server >/dev/null
command -v prettier >/dev/null
test -f index.html
echo "PASS: html smoke"
