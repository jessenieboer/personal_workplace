---
name: readme-authoring
description: Use when creating or updating a project's readme. Covers where to edit, what each section holds, and which sections to ask the user about.
---
# Readme authoring

Edit `.toolboxes/readme_toolbox/readme.org`. It exports to `README.md` at the project root; never edit `README.md` directly. Keep the template's headings and tags. The readme glossary (`.toolboxes/glossary_toolbox/glossary.org`, readme_toolbox terms) defines each section.

Write tersely. Prefer bullet points.

## Sections
- **What, Features, Requirements, Installation, Use:** fill from reading the project.
- **Why, For Whom:** ask the user. Don't infer them from the code.
- **Details:** add headings between Details and Troubleshooting when Details needs more structure.
- **Troubleshooting:** when you know a common problem and its fix, suggest the entry to the user before adding it.
- **License:** link to the project's license file. If there is none, ask the user which license to use.
- **Instructions (For humans, For bots):** record important project-specific instructions as they come up. Send each For bots candidate to Bot Engineer, which owns bot instructions, and act on its answer.
- **Important Decisions:** when a major decision comes up, ask the user whether to record it. If yes, add a brief overview of the decision and why it was made.
- **To Do, Contributing:** leave alone.
- **By Whom:** acknowledge any outside repos or help the project uses.
