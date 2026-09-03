---
name: gherkin-authoring
description: Write and edit Gherkin feature files.
license: MIT
---

# Gherkin Authoring

Produce clear, readable, automation-ready Gherkin feature files that serve as living documentation and specification by example.


## When to use this skill

- Writing, improving, or organizing, Gherkin feature files.


## When not to use this skill

- Making code changes
- Implementing step definitions
- Brainstorming without  `.feature` files

## References
- Gherkin Guidelines: `references/gherkin-guidelines.md`

## Inputs

- Freeform text about desired software features and behavior. It could describe one specific feature or many.


## Workflow

- **Always follow the rules in Gherkin Guidelines strictly.** Do not invent your own style.
- Work in phases. Do not skip a phase unless explicitly instructed to do so.


### Phase 1: Understand the context

- Read Gherkin Guidelines if you have not already done so in this conversation.


### Phase 2: Understand the input

- Assess input for product behaviors
- If you cannot make good sense of specific words or phrases -> ask for clarification
- If any desired behaviors are ambiguous or contradictory -> ask for clarification


### Phase 3: Classify each requested behavior
- List `features/**/*.feature`
- For each behavior in the input, read any file whose title indicates it might cover the same behavior. Then output exactly one:
  - SKIP - behavior already specified in <path>
  - EDIT <path> - addition to or modification of existing behavior
  - NEW <path> - behavior represents a new `Feature`; kebab-case `Feature` title
  - ASK - placement or meaning is unclear

Do not write Gherkin until every behavior is classified.
If any ASK remains, stop and ask.


### Phase 4: Write 
- EDIT:
  - Match the file's vocabulary
  - `Description`s should be at `Feature`-level and should be in story form (As a / I want / So that)
  - If adding a `Background`, rewrite any existing `Scenario`s and `Scenario Outline`s that can make use of it.

- NEW:
  - Write the new file: `features/**/`<kebab-from-title>.feature, one Feature per file.
  - tag each Scenario with @base, @normal, or @abnormal
    - @base: simplest working scenario
    - @normal: expected inputs and behavior
    - @abnormal: edge cases, unexpected inputs and behaviors, errors

- After each file, run the checklist in Gherkin Guidelines.

**If blocked:**
- State what the blockage is, stop, and ask for guidance


### Phase 5: Done
Done when:
- All behavior in the input has been processed

Summarize and report all additions and edits made.
