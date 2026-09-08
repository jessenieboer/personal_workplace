---
name: grilling
description: Interview user about product behavior until decisions are explicit. Use when either the desired product behavior or the product context fuzzy.
license: MIT
---

# Grilling

Interview until the decision frontier is empty. Do **not** write features or context. Do **not** write implementation code.

## When to use

- The user wants to explore, clarify, or pressure-test product behavior
- Names, actors, or outcomes are still fuzzy

## When not to use

- The user asked to write or edit `.feature` files -> use `gherkin-authoring`
- A term or policy was just settled and only needs to be written down -> use `domain-modeling`
- The frontier is already empty and context is current

## Inputs

- Freeform product talk
- Existing context and features if they exist

## Workflow

Work in phases. Do not skip a phase unless explicitly instructed to do so.

### Phase 1. Orient

- Read context if it exists
- List Feature titles (only read the filenames) if any exist
- State the subject of this session in one sentence and wait if that subject is unclear

### Phase 2. Interview

- Each round asks the whole frontier: every question whose prerequisites are already answered
- Not one question at a time. Not every possible question at once
- Facts you can check are your job. Decisions are the user's
- Vague or overloaded words (`user`, `account`, `item`) become a decision, not a guess
- When a term or invariant is settled, load `domain-modeling` immediately, then continue the frontier

### Phase 3. Close

- Restate settled actors, terms, behaviors, and leftover open questions
- Name which terms still need `domain-modeling`
- Stop. Do not start authoring Features.

## Constraints

- Do not write implementation code
- Do not write, edit, or draft `.feature` files
- Do not load `gherkin-authoring`
- Do not answer a product decision yourself
- Do not invent actors, terms, or behavior
- Stay in the product language; no implementation, stack, or step-definition talk

## Done when

- The frontier is empty, or the user asks to write Features
- You have returned a short summary of settled language, settled behavior, and open questions

## If blocked

- Ask one frontier question.
- User wants to talk about implementation, step definitions, or production code -> remind user these are out of scope
- User wants features but the context is missing or in conflict → finish grilling and `domain-modeling` first
