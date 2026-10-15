---
name: python-skill-guide
description: Use when writing or changing Python in a project that imported this toolbox or has pyproject.toml — dispatches Python skills, discovers commands from pyproject.toml, runs them from PATH when .envrc and devenv.nix exist, else uv run.
license: MIT
---

# Python Skill Guide

## When not to use

- Other language → that toolbox's skill guide
- Process (increments, RED/GREEN) → already-loaded skills

## Instructions

1. Read `pyproject.toml`. It wins over every skill, including `modern-python`.
2. Always load before the first test file: `modern-python`, `python-project-structure`, `python-testing-patterns`.
3. Load only if needed: `python-code-style`, `python-type-safety`, `python-error-handling`, `python-design-patterns`.
4. Discover commands from this `pyproject.toml` only. Catalog skills do not choose tools.
5. Run discovered commands from PATH when `.envrc` and `devenv.nix` both exist. Otherwise `uv run <command>`. File presence is the signal — not direnv hook, not `which`.
6. Return skills loaded and commands to use.

## Constraints

- Do not load optional skills by default, add tools this `pyproject.toml` did not choose, run `uv init`, overwrite `pyproject.toml`, replace TDD, or prefix `uv run` when both devenv files exist

## If blocked

- No `pyproject.toml` → stop
- Named skill missing from `.eca/skills` → stop and name it
