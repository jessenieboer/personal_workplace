# Smoke consumer for the python toolbox.
# This file must exist: devenv 2.2+ finds the project root by walking up
# to the nearest devenv.nix. Without it, devenv would use toolboxes/
# as the root and ignore this fixture's devenv.yaml.
{ ... }:
{ }
