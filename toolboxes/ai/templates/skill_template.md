---
name: my-skill-name
description: Say what and when in one or two sentences
license: MIT
---

# Skill Title

What is the skill’s single job?

## When to use

- Concrete trigger situation 1
- Concrete trigger situation 2

## When not to use

- Situation where another skill or agent is better -> hand off to skill/agent
- Situation where there is no work to do

## References

- Point to any supporting files the agent should load on demand (only specify path once)
  - guidelines: `references/some-guidelines.md`
  - examples: `references/examples.md`

Keep this section short; the real content lives in the referenced files.

## Inputs you expect

- Provided:
- Infer:
- Ask:

## Instructions 

1. First action (often read a reference)
2. Steps
3. Decision points
4. What “finished” looks like

## Workflow 

Work in phases. Do not skip a phase unless explicitly instructed to do so.

### Phase 1. Title

### Phase 2. Title

### Phase X: Close

## Constraints

- Hard rules
- Style / quality
- Never invent or assume

## Done when

- Exit condition
- What you return

### Output format

- If there is a specific format requried; skip otherwise

## If blocked

- Ask one question, or state the assumption and continue
- What is out of scope
- When to stop

## Next step

## Tools & scripts

- Optional scripts in `scripts/` this skill may run
- Tools the agent must avoid while this skill is active

## Example

Good:
```text
...

```

Bad:
```text
...

```
