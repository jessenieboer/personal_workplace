---
name: gherkin-authoring
description: Use when writing, improving, or organizing Gherkin `.feature` files, grouping examples under business-rule `Rule` blocks, or hoisting shared Givens into Feature- or Rule-level Backgrounds - produces Cucumber-compatible living documentation with one Feature per file and scenarios grouped by policy.
license: MIT
---

# Gherkin Authoring

Produce Gherkin that is readable by humans, concrete as specification by example, and automation-ready without leaking implementation.

**Principles:** describe what the system does, not how. One behavior per scenario. Scenarios run independently. Domain language only.

## When to use this skill

- Writing, improving, or organizing Gherkin feature files
- Grouping scenarios under a business-rule `Rule`
- Hoisting shared `Given` steps into a Feature- or Rule-level `Background`

## When not to use this skill

- Making code changes
- Implementing step definitions
- Brainstorming without `.feature` files

## Inputs

Freeform text about desired software features and behavior. It could describe one Feature or many.

## Workflow

Work in phases. Do not skip a phase unless explicitly instructed to do so.
This skill is the style and structure contract. Do not load a separate guidelines file.

### Phase 1: Understand the input

- Assess input for product behaviors
- If specific words or phrases cannot be made good sense of -> ask for clarification
- If any desired behaviors are ambiguous or contradictory -> ask for clarification

### Phase 2: Classify each requested behavior

- List `features/**/*.feature`
- For each behavior, read any file whose title indicates it might cover the same behavior. Then output exactly one:
  - SKIP - already specified in <path>
  - EDIT <path> - addition to or modification of existing behavior
  - NEW <path> - new `Feature`; kebab-case title
  - ASK - placement or meaning is unclear

Do not write Gherkin until every behavior is classified.
If any ASK remains, stop and ask.

### Phase 3: Group into business rules

Name each **policy** (one business rule) the examples illustrate.

- Two or more policies in one Feature -> put **every** scenario under a `Rule`. Do not leave Feature-level scenarios beside `Rule` blocks.
- One policy cluster -> MAY omit `Rule`. Do not wrap the Feature in a single `Rule` that restates the Feature title.
- Group by **policy**, not by scenario title or `Then` text. Success and refusal of the same policy belong in the same `Rule` (good-standing hold allowed vs lost title refused).
- MUST NOT split one policy into several one-scenario `Rule`s. A one-scenario `Rule` is allowed only when no other scenario in the file illustrates that policy.
- If two scenarios share a Given that is the policy's starting state, keep them in one `Rule` and hoist it into that Rule's `Background`. Coincidental example data (the same title name) is not a policy.
- `Scenario Outline` varies inputs of **one** behavior. `Rule` groups scenarios of **one** policy. A `Rule` may contain outlines. Do not skip `Rule` because an outline exists.

Do not split a Feature solely to avoid a second `Background` or to avoid `Rule`.

### Phase 4: Write

**Files**

- One `Feature` per `*.feature` file. Kebab-case names under `features/` (subdirectories by behavior area are fine).
- `Feature:` title is one line, named after the behavior area, aligned with the file name.
- Put a three-line story under the title: `As a <role>` / `I want <goal>` / `So that <reason>`.

**NEW**

- Write `features/**/`<kebab-from-title>.feature
- Tag each Scenario `@base` (simplest working), `@normal` (expected), or `@abnormal` (edge, unexpected, error)

**EDIT**

- Match the file's vocabulary
- Re-group under `Rule` when two or more policies are present
- If adding a Feature- or Rule-level `Background`, drop hoisted Givens from scenarios; keep the first remaining step as `Given`

**Background** (optional at Feature and at each Rule)

- Feature-level: immediately after the story, before the first `Rule` or ungrouped `Scenario`. Only Givens **every** scenario in the file needs. Not rule-specific setup.
- Rule-level: immediately under that `Rule`, before its first scenario. Use when **two or more** scenarios in **that Rule** share `Given` steps. Do not repeat Feature-level steps.
- At most one `Background` on the Feature and at most one on each `Rule`. A file with Rules may have several `Background` sections.
- MUST NOT use `Background` when only one scenario needs the setup. Keep backgrounds short.

**Scenarios**

- Single-line, behavior-focused title. Chronological. Declarative. Domain / product language.
- MUST NOT leak UI/automation (selectors, wait, click #foo) or HTTP/SQL/schema unless that layer **is** the behavior.
- Prefer state over navigation. Minimal sufficient `Given`. Concrete realistic data, not `foo`/`bar`/`test`.
- One concern per scenario (do not bundle performance or a11y with unrelated functional behavior).
- Target < 10 steps. Use tables or split if longer.
- `Scenario Outline` only when the **same** behavior needs input variations.

**Steps**

- Third person, present tense, subject–predicate. Double quotes for string parameters.
- Given = arrange, When = act, Then = assert. Strict order. Do not repeat a phase in one scenario.
- `And` continues the same type. `But` sparingly. Never `Or`.
- `Then` must be observable (what changed, what is shown, what is reported). Not "it works".
- Doc strings for multiline payloads. Step tables for lists (kebab-case headers, one screen).

**Formatting**

- Indent bodies of `Feature`, `Rule`, `Background`, `Scenario`, `Scenario Outline`, `Examples` by 2 spaces.
- One blank line between major sections and between adjacent `Rule` / `Scenario` / `Scenario Outline` blocks.
- MUST NOT put blank lines between steps inside a scenario or background.
- Lines under 120 characters. Avoid comments.

**Vocabulary**

- One stable vocabulary for roles, objects, and states. Do not swap synonyms unless the product distinguishes them.

After each file, run the checklist.

**If blocked:** state the blockage, stop, and ask.

### Phase 5: Done

Done when every behavior in the input has been processed.
Summarize additions and edits.

## Checklist

- [ ] One behavior per scenario; independent
- [ ] Two+ policies -> every scenario under the correct `Rule`; not split by `Then` text
- [ ] Shared Givens in the narrowest Background (Feature vs Rule); no duplicate Background steps
- [ ] No `Background` for a single scenario
- [ ] Stable vocabulary; domain-level steps; no UI/API/DB plumbing unless that is the behavior
- [ ] State over navigation; minimal `Given`; concrete data
- [ ] Third person, present tense, subject–predicate; Given → When → Then; observable `Then`
- [ ] Blank line between scenarios / Rules; no blank lines between steps
- [ ] Short scenarios; tables fit on one screen

## Example

Two policies, file-wide sign-in, rule-local standing:

```gherkin
Feature: Library holds
  As a member
  I want to place holds on titles
  So that I can borrow them when they become available

  Background:
    Given member "Ada" is signed in

  Rule: Members with overdue loans cannot place holds

    Background:
      Given member "Ada" has an overdue loan

    @normal
    Scenario: Overdue member is refused a hold on Dune
      Given the title "Dune" is on loan
      When the member places a hold on "Dune"
      Then the hold is refused with "overdue loans must be returned first"

    @normal
    Scenario: Overdue member is refused a hold on Neuromancer
      Given the title "Neuromancer" is on loan
      When the member places a hold on "Neuromancer"
      Then the hold is refused with "overdue loans must be returned first"

  Rule: Members in good standing may hold titles that are on loan

    Background:
      Given member "Ada" has no overdue loans

    @base
    Scenario: Member in good standing holds a title that is on loan
      Given the title "Dune" is on loan
      When the member places a hold on "Dune"
      Then a hold for "Ada" is queued on "Dune"

    @abnormal
    Scenario: Member in good standing cannot hold a lost title
      Given the title "Dune" is lost
      When the member places a hold on "Dune"
      Then the hold is refused with "lost titles cannot be held"
```
