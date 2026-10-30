---
name: standard-project-work
description: Use when starting or doing any work in a project that uses the standard_project toolbox. Covers what to read first, which skills to use, and how to commit.
---
# Standard project work

1. **Read the README.** Read all of `README.org` or `README.md` at the project root, if one exists, for general context. Pay special attention to the For bots section if it exists, and follow its instructions; they override your defaults.
2. **Read the glossary.** If `.toolboxes/glossary_toolbox/glossary.org` (or a root `glossary.org` or `glossary.md`) exists, read it, and use its terms as defined.
3. **Inventory the skills.** List every skill under `.toolboxes/*/practices/skills/`. When one fits the task, load it and follow it in place of a general habit.
4. **Commit only when asked.** When the user says to commit, follow the git-commit skill on the staged changes only, split into logical commits. Leave unstaged and untracked changes alone unless the user names them.
5. **Prefer declarative changes.** Change the environment through the Nix and devenv files, not one-off installs or imperative fixes.
6. **Expect the user's edits.** The user edits files directly, so unexpected changes in any file they can edit are normal. Don't flag them, undo them, or work around them; build on the current contents.
7. **Never delete a file without the user's explicit OK** in this chat, even when it looks stale, generated, or redundant.
