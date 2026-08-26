---
name: my-skill-name
description: One or two sentences that tell the agent when to use this skill. Be specific enough that the agent can decide correctly.
# license: MIT
# compatibility: eca
# metadata:
#   audience: developers
#   workflow: bdd
---

# Skill Title

Short paragraph that states the skill’s single job and the outcome it should produce.

## When to use this skill

- Concrete trigger 1 (e.g. “user asks to write or improve a Gherkin feature file”)
- Concrete trigger 2
- Concrete trigger 3

## When not to use this skill

- Situations where another skill or the plain agent is more appropriate
- Explicit hand-off cases

## Inputs you expect

- What the user or parent agent should provide
- What you will infer vs what you must ask for

## Instructions

1. First thing the agent must do (often “read references/…” if you have them)
2. Core workflow steps, numbered and strict
3. Decision points (“If X is ambiguous, ask a clarifying question before continuing”)
4. Final output requirements (complete file, ready to save, etc.)

## Rules / constraints

- Hard rules the agent must never violate
- Style or quality requirements
- Things it must never invent or assume

## Project conventions

- Where files live
- Naming or layout rules this skill must follow

## Done when

- Concrete exit condition
- What you return (file path, summary, open questions)

## If blocked

- Ask one clarifying question, or state the assumption and continue
- What to do when the task is out of scope
- When to stop instead of guessing

## Output format

Describe exactly what the agent should produce (file path, structure, tone, etc.).

## Tools & scripts

- Optional scripts in `scripts/` this skill may run
- Tools the agent should prefer or avoid while this skill is active

## References

- Point to any supporting files the agent should load on demand:
  - `references/some-guidelines.md`
  - `references/examples.md`

Keep this section short; the real content lives in the referenced files.

## Example

Good:
```text
...

```

Bad:
```text
...

```
