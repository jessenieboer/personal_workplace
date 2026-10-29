---
name: learning-project-setup
description: >-
  Set up a project folder for a new study topic when the user asks to start a
  learning project, turn a study plan into a project, or says to create a
  project before lessons begin. Copies the learning devenv template, names the
  folder, and seeds the study plan.
---
# Learning project setup

Work on the user's own computer (ListMachines, pick their desktop), not the box. Learning projects live in `~/kingdoms/Household/Jesse/_learning_projects/`, not Dropbox. A study plan written before the project existed may be a loose file elsewhere; copy it into the project.

1. Name. If the user has not given a name, ask once for a short snake_case name (example: `design_studio_business`). Do not invent one.
2. Target: `~/kingdoms/Household/Jesse/_learning_projects/<name>/`. List it first. If it already exists, stop and ask.
3. Create the folder. Copy `devenv.nix` and `devenv.yaml` from the learning template (`templates/learning_project/` in personal_workplace). If the template is not there, stop and say so. Do not copy another template as a stand-in. Do not run devenv, direnv, or git commands.
4. Seed `<name>.org` in the folder. If a plan exists, copy it with `cp -n` and keep the old one for now. If not, write a short plan: goal, what the user already knows, 4 to 6 milestones with sources, a Progress section with the next milestone marked, and an empty "Struggles / to review" section. For any later edit of an existing .org, use `org-safe-edit`.
5. Check: `ls -la` the folder and `cmp` the copied plan against its source.
6. Old copy: ask whether to delete it. Delete only after `cmp` matches and the user says yes. Tell them it is gone.
7. Reply with the folder path and the first lesson topic. Save the project name and path to memory so later lessons update the plan in the project.
