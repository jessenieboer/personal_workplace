#!/usr/bin/env bash
set -euo pipefail
command -v bws >/dev/null
command -v secretspec >/dev/null
test -f secretspec.toml
echo "PASS: secrets smoke"
echo "NOTE: run 'secretspec check' separately if verifying BWS/XAI access"
