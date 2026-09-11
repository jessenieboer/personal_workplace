---
name: python-skill-guide
description: Dispatch this toolbox's Python skills when writing or changing Python. Use when the project imported the python toolbox or has pyproject.toml plus uv.
license: MIT
---

# Python Skill Guide

Load the right Python skills for this change. Do not implement the change yourself until those skills are loaded.

## When to use

- Writing or changing Python in a project that imported this toolbox
- `pyproject.toml` exists and uv is the package manager

## When not to use

- Another language is the stack → that toolbox's skill guide
- Process (increments, RED/GREEN) → already-loaded skills; this file does not replace them

## Instructions

1. Read this project's `pyproject.toml`. That file wins over every skill below.
2. Load, in order, before the first test file:
   - `modern-python`
   - `python-project-structure`
   - `python-testing-patterns`
3. Load only if this change needs them:
   - `python-code-style` — naming, imports, docstrings
   - `python-type-safety` — new public signatures
   - `python-error-handling` — invalid input or failure paths
   - `python-design-patterns` — a third copy of the same idea
4. Discover commands from `pyproject.toml` and `modern-python`. Prefer `uv run pytest`, `uv run ruff`, `uv run ty check`.

## Constraints

- Do not load the optional skills by default
- Do not add tools a catalog skill likes if this `pyproject.toml` did not already choose them
- Do not run `uv init` or overwrite an existing `pyproject.toml`
- Do not replace a test-driven-development cycle

## Done when

- The always-load skills are loaded
- Any optional skill that this change needed is loaded
- Return: skills loaded, commands to use

## If blocked

- `pyproject.toml` missing → stop
- A named skill is missing from `.eca/skills` → stop and name it
