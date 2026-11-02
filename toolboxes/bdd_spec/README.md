<h1 align="center">BDD Spec Toolbox</h1>


# What

Skills and rules for writing BDD-style specifications in Gherkin. Nothing else: no planning, implementation or definition-of-done tooling (see the `bdd` toolbox for that).

Skills installed under `.toolboxes/bdd_spec_toolbox/practices/skills`: `grilling`, `grill-with-docs` and `domain-modeling` from mattpocock, and `bdd-gherkin-specification` from jzallen. Specs go in `.toolboxes/bdd_spec_toolbox/features/`.


# Installation

```yaml
mattpocock-skills:
    flake: false
    url: github:mattpocock/skills
jzallen-fred-simulations:
    flake: false
    url: github:jzallen/fred_simulations
personal_workplace:
  flake: false
  url: github:jessenieboer/personal_workplace/jn

imports:
  - personal_workplace/toolboxes/bdd_spec
```


# By Whom

Me and Grok, with gratitude to <https://github.com/mattpocock/skills> (grilling and domain modeling) and <https://github.com/jzallen/fred_simulations> (`bdd-gherkin-specification`, `.claude/skills/bdd`; the repo declares no license, so check with the author before redistributing).
