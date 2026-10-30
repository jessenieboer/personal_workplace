---
name: java-skill-guide
description: Use when writing or changing Java in a project that imported this toolbox or has pom.xml — discovers commands from pom.xml, runs mvn from PATH when .envrc and devenv.nix exist, else ./mvnw.
license: MIT
---

# Java Skill Guide

## When not to use

- Other language → that toolbox's skill guide
- Process (increments, RED/GREEN) → already-loaded skills

## Instructions

1. Read `pom.xml`. It wins over every skill and over this guide.
2. No catalog Java skills ship with this toolbox. After `pom.xml`, follow the conventions of the existing code in `src/main/java` and `src/test/java`.
3. Before the first test file: JUnit Jupiter from the `pom.xml` BOM, tests under `src/test/java` in the package under test, class names ending in `Test`.
4. Discover commands from this `pom.xml` only: lifecycle phases (`mvn test`, `mvn verify`, `mvn package`) plus the plugins and profiles it declares. Format changed `.java` files with `google-java-format --replace <files>` only when `pom.xml` or the project docs name it. After editing `pom.xml` or other XML, check it with `xmllint --noout <file>` before running Maven.
5. Run `mvn` from PATH when `.envrc` and `devenv.nix` both exist. Otherwise `./mvnw` when the project has it. File presence is the signal — not direnv hook, not `which`.
6. Return skills loaded and commands to use.

## Constraints

- Do not add dependencies or plugins this `pom.xml` did not choose, run `mvn archetype:generate`, add a Gradle build, overwrite `pom.xml`, change `maven.compiler.release`, replace TDD, or use `./mvnw` when both devenv files exist

## If blocked

- No `pom.xml` → stop
- No devenv files and no `./mvnw` → stop and say so
- Named skill missing from `.eca/skills` → stop and name it
