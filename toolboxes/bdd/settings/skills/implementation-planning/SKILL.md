---
name: implementation-planning
description: Order tagged Gherkin scenarios into a Plan and Task List. Use when Features, Context, and a Ready Design Review exist and implementation has not started, or work will span sessions. Do not use while design is still moving or for a single obvious file change.
license: MIT
---

# Implementation Planning

Decompose a Spec (Context + Features + Design Review) into a stack-agnostic implementation order (Plan and Task List). Plan and Task List are the handoff, not another spec. Do not invent behavior. Do not write production code.

## When to use

- Features, Context, and Design Review exist
- User asked to plan implementation, or work should survive a new chat or language
- Scenario order is not already recorded in a current Plan

## When not to use

- User is still shaping product behavior
- There are no Features
- Design Review is missing → `design-review`
- Design Review says Not ready
- A complete Task List already covers the requested Features and those files have not changed
- Single-file change with obvious scope
- A complete Task List already exists for Spec
- User is still shaping product behavior
- Design Review says Not ready

## References

- Plan template: `references/plan-template.md`
- Task template: `references/task-template.md`

## Inputs

- Design Review — gate only (Ready or Not ready)
- Context — terms and policies
- Features — behavior + scenarios; scenarios tagged with exactly one of `@base`, `@normal`, `@abnormal`
- Plan and Task List if they exist

## Workflow

Work in phases. Do not skip a phase unless the user says to.

### Phase 1: Orient

- Read Design Review. If missing, stop, -> `design-review`. If Not ready, stop and name the findings. Do not plan around them.
- Read Plan.
- List Features. Ignore Features with complete implementations (all boxes checked in Plan) unless explicitly asked. Otherwise read the files that match the request. 
- Read Context.

### Phase 2: Inventory scenarios

From the Features just read, list every `Scenario` and `Scenario Outline`.

For each one scenario record:

- Feature path
- Title
- Tag — exactly one of `@base`, `@normal`, `@abnormal`
- One-line Given (dependencies)
- One-line Then (outcome)
- Verification (human or machine)

Tag meaning (same as `gherkin-authoring`):

- `@base` — simplest working path
- `@normal` — expected inputs and behavior
- `@abnormal` — edges, unexpected input, errors

If a scenario has none of those tags, or more than one of those, stop and ask. Do not guess. Do not retag Features.

Verification should be human only if requested or automated test is not possible.

### Phase 3: Order scenarios

Begin like this:
1. All `@base`, then by Feature title
2. Then all `@normal`, same
3. Then all `@abnormal`, same

Then re-order: if one scenario obviously depends on another, that scenario should go later. If dependencies are unclear or go in circles, stop and ask.

Summarize ordering decisions for use in next phase

### Phase 4: Write Plan and Task List

Read the templates and use those shapes. Write Task List, then Plan. **Never** edit or reorder checked items in Plan or Task List; this is in-flight work. One scenario → one task.

Task List contains one entry per ordered scenario:

- Title = terse title based on scenario title
- Description = the user-visible path in product language
- Acceptance criteria = the Thens / outcomes from that scenario
- Verification = Checkboxes for tests and build; human review checkbox if necessary / requested
- Dependencies = previous task numbers, or None
- Files likely touched = guessed from existing repo layout
- Scope = [Small: 1-2 files | Medium: 3-5 files | Large: 5+ files]

Plan contains:

- Overview = One paragraph summary of what we are implementing. Behavior only, stack-agnostic
- Spec sources = Feature paths read
- Ordering decisions = summary from Phase 3
- Task sequence = tasks from Task List in order, grouped into phases with checkpoints interspersed
- Out of scope = scenarios the user deferred. Omit if none.
- Open questions = if none, create heading anyway for later use

Add a Checkpoint:
- after first working path
- when human verification is requested or required

### Phase 5: Done

Done when every in-scope scenario is one task in Task List and one row in Plan.

Summarize the ordered titles. Do not start implementing.
