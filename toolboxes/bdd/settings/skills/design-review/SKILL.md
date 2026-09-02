---
name: design-review
description: Audit whether context and features are ready to hand to an implementation planner. Use after those files exist, when the user asks if the design holds or is about to plan implementation.
license: MIT
---

# Design Review

Read product context and features. Report whether the design is internally consistent and example-complete enough to implement.

## When to use

- Feature files and context exist and the user wants to know if the design holds
- User asked for a pre-implementation review or is about to hand off to planning

## When not to use

- Behavior is still fuzzy -> `grilling`
- A term or policy just settled and is not in context -> `domain-modeling`
- Features need to be written or rewritten -> `gherkin-authoring`
- User asked for step definitions, pytest, Playwright, or production code -> out of scope
- A current review already says Ready and the sources have not changed -> summarize and stop

## References
- Review template: `references/review-template.md`.

## Inputs

- Product context and features
- Review if it exists
- Review template

## Workflow

Work in phases. Do not skip a phase unless the user says to.

### Phase 1: Read only

- Read context. If it is missing, stop and send the user to `domain-modeling`.
- List feature files. Read the ones that match the request (all of them if the user said "the design"). If there are no feature files, stop.
- Read the existing review only to see if this pass can be a no-op.

### Phase 2: Check alignment

Walk terms, policies, and scenarios. You are looking for drift and missing *examples of rules that can fail*, not a 1:1 map.

For each policy and each scenario, output exactly one:

- ALIGNED — scenario uses defined terms; policy that can fail has at least one example
- THIN — an important edge, error, or actor is missing for a policy that can fail
- ORPHAN-POLICY — a rule that can fail has no scenario (terms and rejected synonyms are not policies)
- ORPHAN-SCENARIO — a scenario introduces a word or outcome context does not define
- CLASH — context and a scenario disagree
- ASK — cannot tell

Do not write the review while any ASK remains. Stop and ask.

### Phase 3: Write the review

Write or replace review using review template. This file is a gate, not a spec. Do not restate context or features here.

The file may contain only:

- Sources read (paths)
- Verdict — Ready or Not ready
- Findings (THIN / ORPHAN-* / CLASH), each pointing at a source path and the skill that should close it

Verdict is ready only if no CLASH or ORPHAN-*.

### Phase 4: Report

Return, short:

- Verdict
- Findings, each tagged `grilling`, `domain-modeling`, or `gherkin-authoring`

## Constraints

- Stay in product language
- Do not write `.feature` files, context, step definitions, or production code
- Do not invent actors, terms, policies, or outcomes
- Do not assume a language toolbox or test runner
- Do not hand off to planner, user will decide that

## Done when

- Review on disk matches the current context and features for the requested scope
- Findings are listed, not silently closed
- User can hand context + features to the implementation planner, or send findings back to design skills

## If blocked

- Missing context or features -> name which skill should run first
- Clash between context and a scenario -> stop and load `grilling`
- User starts talking stack -> remind them this layer is design-only
- User wants the missing scenarios written now -> stop and load `gherkin-authoring`
