#!/usr/bin/env bash
set -euo pipefail
command -v rustc >/dev/null
command -v cargo >/dev/null
test -f Cargo.toml
echo "PASS: rust smoke"
