---
name: postgres-skill-guide
description: Use when a project that imported this toolbox needs its local PostgreSQL — dispatches PostgreSQL skills, starts and checks the devenv server, connects with psql or pgcli from PATH (PGHOST, PGPORT and PGDATABASE already set), and never touches other databases.
license: MIT
---

# PostgreSQL Skill Guide

## When not to use

- SQL style, linting or formatting → `sql-skill-guide` (sql toolbox)
- Other language → that toolbox's skill guide
- Process (increments, RED/GREEN) → already-loaded skills

## Instructions

1. Read `devenv.nix` for `postgres_toolbox.database` and any `services.postgres.*` settings. They win over every skill.
2. Always load before the first table, schema, or migration file: `postgresql-table-design`.
3. Load only if needed: `sql-optimization-patterns` (slow queries, indexes, `EXPLAIN`).
4. Discover schema, seed and migration commands from the project's own files only. Catalog skills do not choose migration tools or drivers.
5. Check the server with `devenv processes list`. Start it with `devenv up -d` and stop it with `devenv processes down`. Run `psql` and `pgcli` from PATH when `.envrc` and `devenv.nix` both exist; they already point at the project database, so pass no host, port, user or password. File presence is the signal — not direnv hook, not `which`.
6. Return skills loaded and commands to use.

## Constraints

- Do not connect to any other server, add passwords or listen addresses, change the PostgreSQL major version, delete `.devenv/state/postgres`, run destructive statements (`DROP`, `TRUNCATE`, `DELETE` or `UPDATE` without `WHERE`) without asking, or replace TDD

## If blocked

- The server will not start or is not ready → read `devenv processes logs postgres`, report it, and stop
- Named skill missing from `.toolboxes/*_toolbox/practices/skills` → stop and name it
