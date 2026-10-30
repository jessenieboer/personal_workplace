---
name: sql-skill-guide
description: Use when writing or changing SQL (schemas, migrations, queries) in a project that imported this toolbox or has .sqlfluff — dispatches SQL skills, lints and formats with sqlfluff per .sqlfluff, runs it from PATH when .envrc and devenv.nix exist, and uses psql only against the project's devenv PostgreSQL.
license: MIT
---

# SQL Skill Guide

## When not to use

- SQL inside another language's ORM or query builder → that toolbox's skill guide first; come back here for schemas and raw SQL
- Other language → that toolbox's skill guide
- Process (increments, RED/GREEN) → already-loaded skills

## Instructions

1. Read `.sqlfluff`. Its `dialect` wins over every skill. The catalog skills below assume PostgreSQL.
2. Always load before the first table, schema, or migration file: `postgresql-table-design` (dialect `postgres` only).
3. Load only if needed: `sql-optimization-patterns` (slow queries, indexes, `EXPLAIN`), `database-migration` (changing schemas that already hold data).
4. Discover commands from `.sqlfluff` and the project's own migration tooling only. Catalog skills do not choose tools or migration frameworks.
5. Run `sqlfluff lint <paths>` and `sqlfluff fix <paths>` on the files you changed, from PATH when `.envrc` and `devenv.nix` both exist. Use `psql` only when `devenv.nix` sets `sql_toolbox.postgres.enable = true` and `devenv up` is running; devenv's `PGHOST` and `PGPORT` then point at the project's server. File presence is the signal — not direnv hook, not `which`.
6. Return skills loaded and commands to use.

## Constraints

- Do not load optional skills by default, change the `.sqlfluff` dialect, overwrite `.sqlfluff`, run `sqlfluff` on `.` (it can walk `.devenv`), connect to any database other than the project's devenv server unless the user names it, run destructive statements (`DROP`, `TRUNCATE`, `DELETE` or `UPDATE` without `WHERE`) without asking, or replace TDD

## If blocked

- No `.sqlfluff` → stop
- A database is needed but `sql_toolbox.postgres.enable` is off or `devenv up` is not running → stop and say so
- Named skill missing from `.toolboxes/*_toolbox/practices/skills` → stop and name it
