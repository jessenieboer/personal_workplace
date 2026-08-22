---
name: agent-name
description: Short one-line description (shown in the picker and used for routing).
mode: primary                 # primary | subagent | [primary, subagent]
model: xai/grok-4.5
# maxSteps: 25                # subagent turn cap
# spawnableBy:                # subagent-only
#   - vizier
# variant: high
# inherit: code
disabledTools:				  # hide tools from agent
  - preview_file_change
tools:
  byDefault: ask
  allow:
    - eca__read_file
    - eca__grep
    - eca__directory_tree
  ask:
    - eca__write_file
    - eca__edit_file
    - eca__shell_command
  deny:
    - eca__move_file
---

# Agent Name

One short paragraph that sets the personality and primary goal of this agent.

## What you do (always keep)

- Bullet list of the main responsibilities
- Keep this focused — one clear job is better than many vague ones

## What you do not do (always keep)

- Explicitly list things this agent should refuse or hand off
- Example: Do not write final production code / Do not invent requirements

## Inputs you expect

- What the user or parent agent should provide
- What you will infer vs what you must ask for

## How you work (always keep)

1. First step the agent should always take
2. Second step
3. When to ask clarifying questions
4. When / how to hand off to another agent or skill

## Project conventions (should be in rules)

- Where files live (e.g. `features/*.feature`)
- Naming, layout, or style rules this agent must follow
- Links to skills or `references/` files to load on demand

## Handoff

- Primary: which specialists to spawn, and the task shape to give them
- Subagent: what to return to the parent (format, length, artifacts)
- When to use a skill instead of spawning an agent

## Done when

- Concrete exit condition
- What you return (file path, summary, open questions)
- What “complete” does *not* include

## If blocked

- Ask one clarifying question, or state the assumption and continue
- What to do when a tool fails or the task is out of scope
- When to stop instead of guessing

## Output style

- Preferred format (bullets, short paragraphs, Gherkin, etc.)
- Tone (concise, collaborative, strict, etc.)
- Any formatting rules you care about

## Tools & skills

- Prefer using the `gherkin-author` skill when the user is ready for Feature files
- Only use shell / write tools when explicitly needed
- Which tools this role should avoid even if they are available

## Example

Good:
```text
...

```

Bad:
```text
...

```
