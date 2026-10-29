---
name: javascript-skill-guide
description: Use when writing or changing JavaScript or TypeScript in a project that imported this toolbox or has package.json — dispatches JavaScript skills, discovers commands from package.json scripts, runs them from PATH when .envrc and devenv.nix exist, else npx.
license: MIT
---

# JavaScript Skill Guide

## When not to use

- Other language → that toolbox's skill guide
- Process (increments, RED/GREEN) → already-loaded skills

## Instructions

1. Read `package.json` (and `tsconfig.json` when present). They win over every skill, including `modern-javascript-patterns`.
2. Always load before the first test file: `modern-javascript-patterns`, `javascript-testing-patterns`.
3. Load only if needed: `typescript-advanced-types` (TypeScript sources or `tsconfig.json`), `nodejs-backend-patterns` (servers, APIs, workers).
4. Discover commands from this `package.json` `scripts` only. Catalog skills do not choose tools, test runners, or package managers.
5. Run scripts with `npm run <script>`. Run tools (`node`, `npm`, `tsc`, `prettier`) from PATH when `.envrc` and `devenv.nix` both exist. Otherwise `npx <tool>`. File presence is the signal — not direnv hook, not `which`.
6. Return skills loaded and commands to use.

## Constraints

- Do not load optional skills by default, add tools or dependencies this `package.json` did not choose, run `npm init`, overwrite `package.json`, switch package managers, replace TDD, or prefix `npx` when both devenv files exist

## If blocked

- No `package.json` → stop
- Named skill missing from `.eca/skills` → stop and name it
