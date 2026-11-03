<h1 align="center">BDD Implementation Toolbox</h1>


# What

Skills and rules for implementing BDD-style specifications: planning, small increments, test-driven development and context engineering, plus a definition of done. Nothing else: no spec writing or domain modeling (see the `bdd_spec` toolbox for that).

Skills installed under `.toolboxes/bdd_implementation_toolbox/practices/skills`, all from addyosmani: `planning-and-task-breakdown`, `incremental-implementation`, `test-driven-development`, and `context-engineering` (with its LICENSE). The definition of done is at `.toolboxes/bdd_implementation_toolbox/definition-of-done.md`; the plan and task list go next to it.


# Installation

```yaml
addyosmani-agent-skills:
    flake: false
    url: github:addyosmani/agent-skills
personal_workplace:
  flake: false
  url: github:jessenieboer/personal_workplace/jn

imports:
  - personal_workplace/toolboxes/bdd_implementation
```


# By Whom

Me and Grok, with gratitude to <https://github.com/addyosmani/agent-skills> (planning, incremental implementation, test-driven development, context engineering and the definition of done)
